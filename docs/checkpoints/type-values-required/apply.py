"""Admit source-coordinate movement without changing frozen observations or production."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
baseline = json.loads((ROOT / (P + 'baseline.json')).read_bytes())
assert baseline['returncode'] == 0 and baseline['claim'] == preserved['original_claim'] == c.read(c.CLAIM)
for path, item in preserved['inputs'].items():
    assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
assert c.unchanged(preserved['before'])
module = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
anchor = c.run(['git', 'show', c.BASE + ':' + module])
assert anchor['returncode'] == 0
python_path = 't/lib/method_locations.py'
perl_path = 't/lib/LinkedSpecTest/MethodLocations.pm'
python_source = r'''"""Map unchanged statements in the same named routine to real c053 coordinates."""
import difflib
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
BEFORE = 'c053c9dcf24a78cc8b551187f47cdb7aefb03eb3'


def routines(lines):
    starts = [(index, match[1]) for index, line in enumerate(lines)
              if (match := re.match(rb'^sub\s+([A-Za-z_]\w*)\b', line))]
    names = [name for _, name in starts]
    assert len(names) == len(set(names)), 'duplicate named routine in coordinate authority'
    result = {b'(module preamble)': (0, starts[0][0])}
    result.update({name: (start, starts[index + 1][0] if index + 1 < len(starts) else len(lines))
                   for index, (start, name) in enumerate(starts)})
    return result


def main():
    before = subprocess.check_output(['git', 'show', BEFORE + ':' + SOURCE], cwd=ROOT)
    current = (ROOT / SOURCE).read_bytes()
    left, right = before.splitlines(keepends=True), current.splitlines(keepends=True)
    old, new = routines(left), routines(right)
    ranges = []
    for name in old.keys() & new.keys():
        a, b = old[name], new[name]
        for match in difflib.SequenceMatcher(None, left[a[0]:a[1]], right[b[0]:b[1]], autojunk=False).get_matching_blocks():
            if match.size:
                ranges.append(dict(routine=name.decode(), before=a[0] + match.a + 1,
                    current=b[0] + match.b + 1, count=match.size))
    ranges.sort(key=lambda row: row['current'])
    print(json.dumps(dict(source=SOURCE, before_revision=BEFORE,
        before_sha256=hashlib.sha256(before).hexdigest(), current_sha256=hashlib.sha256(current).hexdigest(),
        ranges=ranges), sort_keys=True))


if __name__ == '__main__':
    main()
'''
perl_source = r'''package LinkedSpecTest::MethodLocations;
use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my ($coordinates, %original);
sub _coordinates {
 return $coordinates if $coordinates;
 local $@;
 open my $pipe, '-|', 'bash', 'tools/run_python_project_data.sh', 't/lib/method_locations.py'
  or die "start method coordinate reader: $!";
 my $raw = do { local $/; <$pipe> };
 close $pipe or die "method coordinate reader failed: $?";
 my $value = JSON::PP->new->decode($raw);
 open my $source, '<:raw', $value->{source} or die "read method source: $!";
 my $bytes = do { local $/; <$source> };
 close $source or die "close method source: $!";
 die 'method coordinate/source identity mismatch'
  unless sha256_hex($bytes) eq $value->{current_sha256};
 for my $range (@{$value->{ranges}}) {
  for my $offset (0 .. $range->{count} - 1) {
   my $line = $range->{current} + $offset;
   die 'duplicate current source coordinate' if exists $original{$line};
   $original{$line} = $range->{before} + $offset;
  }
 }
 $coordinates = $value;
 return $coordinates;
}

sub original_line {
 my ($line) = @_;
 _coordinates();
 die "no unchanged MethodLowering statement for current line $line"
  unless exists $original{$line};
 return $original{$line};
}

sub original_coordinates {
 my ($value, $error_context) = @_;
 return [map {original_coordinates($_, $error_context)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_ => original_coordinates($value->{$_}, /(?:^|_)error\z/ ? 1 : 0)} keys %$value}
  if ref($value) eq 'HASH';
 return $value if ref($value) || !defined($value) || !$error_context;
 my $copy = $value;
 $copy =~ s{(\bat [^\n]*?\bperl/LinkedSpec/ActionIR/MethodLowering\.pm line )(\d+)}{$1.original_line($2)}ge;
 return $copy;
}

1;
'''
ast.parse(python_source, filename=python_path)
texts = {python_path: python_source, perl_path: perl_source}
packages = dict(array_receiver_required='ArrayReceiverRequiredProbe',
    scalar_receiver_required='ScalarReceiverRequiredProbe', hash_receiver_required='HashReceiverRequiredProbe',
    array_end_required='ArrayEndRequiredProbe', hash_index_required='HashIndexRequiredProbe')
normal = 'LinkedSpecTest::MethodLocations::original_coordinates'
names = tuple(packages) + ('dropped_trim', 'small_kind', 'method_kind',
                          'source_assignment_kind', 'ast_optional', 'formal_trim')
for name in names:
    path = 't/actionir_' + name + '_capture.t'
    source = c.decode(preserved['before'][path]['base64']).decode()
    use = 'use warnings;\n'
    assert source.count(use) == 1
    source = source.replace(use, use + "require './t/lib/LinkedSpecTest/MethodLocations.pm';\n"
        '# Current diagnostics use bound original coordinates; frozen records stay unchanged.\n', 1)
    if name in packages:
        old = 'my $current=' + packages[name] + '::observations();'
        new = 'my $current=' + normal + '(' + packages[name] + '::observations());'
    elif name == 'dropped_trim':
        old = 'my $current = JSON::PP->new->decode($out);'
        new = 'my $current = ' + normal + '(JSON::PP->new->decode($out));'
    elif name == 'small_kind':
        old = 'return JSON::PP->new->decode($out);'
        new = 'return ' + normal + '(JSON::PP->new->decode($out));'
    elif name == 'method_kind':
        old = '$current{$surface} = $json->decode($actual->{stdout});'
        new = '$current{$surface} = ' + normal + '($json->decode($actual->{stdout}));'
    else:
        old = 'my $actual = $json->decode($run->{stdout});'
        new = 'my $actual = ' + normal + '($json->decode($run->{stdout}));'
    assert source.count(old) == 1, path
    source = source.replace(old, new, 1)
    if name == 'method_kind':
        old = 'is_deeply($json->decode($actual_authority->{original_replay}), $current{observe},'
        new = 'is_deeply(' + normal + '($json->decode($actual_authority->{original_replay})), $current{observe},'
        assert source.count(old) == 1
        source = source.replace(old, new, 1)
    texts[path] = source
path = 't/actionir_method_general_return_capture.t'
source = c.decode(preserved['before'][path]['base64']).decode()
old = 'my @public = public_cases();\n'
new = '''sub public_return_observation {
 my ($source) = @_;
 my @Top = (1, 'two');
 my $execute = eval 'sub { ' . $source . ' }';
 return {error => "compile: $@"} unless ref($execute) eq 'CODE';
 my $value;
 my $ok = eval { $value = $execute->(); 1 };
 return $ok ? {value => $value} : {error => "execute: $@"};
}
my @public = public_cases();
'''
assert source.count(old) == 1
source = source.replace(old, new, 1)
old = ' is($row->{value}, $expected, "$name public Toolbox keeps actual return surface");'
new = ''' if ($name eq 'current-copy') {
  is_deeply(public_return_observation($row->{value}), {value => [[1, 'two']]},
   'current-copy public Toolbox preserves the evaluated nested return value');
 } else { is($row->{value}, $expected, "$name public Toolbox keeps actual return surface") }
'''.rstrip()
assert source.count(old) == 1
texts[path] = source.replace(old, new, 1)
before = {path: preserved['before'][path] for path in texts if path in preserved['before']}
assert not (ROOT / python_path).exists() and not (ROOT / perl_path).exists()
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()),
    mode=before[path]['mode'] if path in before else 0o644) for path, text in texts.items()}
c.write_new(P + 'proposals.json.gz', dict(before=before, after=after, producer=c.read(P + 'apply.py'),
    anchor_module=anchor, current_module=c.read(module),
    scope='No production edits or frozen observation changes. Current error fields map only '
          'unchanged statements within the same named routine to real c053 coordinates; '
          'diagnostic stems, callback names, filenames and other fields remain exact. '
          'All existing plans/assertions stay. The single current-copy source-spelling '
          'assertion instead executes the emitted return and checks its nested value.'), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(c.decode(item['base64']))
    target.chmod(item['mode'])
    assert c.read(path) == item
print('Twelve recurring consumers updated; source-coordinate identity and complete native rows remain checked')

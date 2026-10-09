"""Observe the public empty-span defect at live/original source and intervene."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0-'
BASE = '0d52a407c4c508cfb00d45765471f741a10de616'
CASES = [{'source': s, 'base': 7} for s in ('', '  ', '\r\n', ' \r\n\t\u2003')]
CODE = '''use LinkedSpec::ActionIR::AST (); use LinkedSpec::ActionIR::AST::Parser (); use JSON::PP ();
my $j = JSON::PP->new->utf8->canonical;
my $cases = $j->decode($ARGV[0]); my @rows;
my $trim = \\&LinkedSpec::ActionIR::AST::Parser::_trim_with_offsets;
for my $case (@$cases) {
 my ($source, $base) = @{$case}{qw(source base)};
 my $normal = LinkedSpec::ActionIR::AST::parse_action_expr($source, {base_start => $base});
 my ($corrected, @trims);
 { no warnings 'redefine';
   local *LinkedSpec::ActionIR::AST::Parser::_trim_with_offsets = sub {
    my @result = $trim->(@_); my @caller = caller;
    push @trims, {input => $_[0], base => $_[1], result => [@result],
                 caller => $caller[1], line => $caller[2]};
    $result[2] = $result[1] if $result[2] < $result[1];
    return @result;
   };
   $corrected = LinkedSpec::ActionIR::AST::parse_action_expr($source, {base_start => $base});
 }
 push @rows, {source => $source, base => $base, normal => $normal, corrected => $corrected, trims => \\@trims};
}
print $j->encode(\\@rows), "\\n";
'''

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs'], cwd=ROOT).decode().split('\0')
paths = [p for p in paths if p and (ROOT / p).is_file()]
command = ['perl', '-Iperl', '-e', CODE, json.dumps(CASES, ensure_ascii=True)]
def execute(root, name, files):
    result = subprocess.run(command, cwd=root, env=dict(os.environ, PERL5LIB='', PERL5OPT=''),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return {'name': name, 'command': command, 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode(),
            'inputs': {p: digest(raw) for p, raw in sorted(files.items())}}

live = {p: (ROOT / p).read_bytes() for p in paths}
live[PREFIX + 'empty-probe.py'] = Path(__file__).read_bytes()
rows = [execute(ROOT, 'live', live)]
assert all(digest((ROOT / p).read_bytes()) == h for p, h in rows[0]['inputs'].items())
original = {p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT) for p in paths}
original[PREFIX + 'empty-probe.py'] = Path(__file__).read_bytes()
with tempfile.TemporaryDirectory(prefix='empty-span-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    for p, raw in original.items():
        target = supplied / p
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    rows.append(execute(supplied, 'original', original))
(ROOT / (PREFIX + 'empty.json')).write_text(json.dumps({'base': BASE, 'cases': CASES, 'routes': rows}, indent=2) + '\n')
assert all(row['returncode'] == 0 for row in rows)
print('Actual public empty-span original/live and trim intervention captured.')

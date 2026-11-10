"""One-shot source-normal authoring from the acquired public observations."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
PRIOR = Path('docs/checkpoints/array-pipeline-result-perl-2026-11-10')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'fe4906fb0bdac1ff7dc4f33728862cd6d47cf79d'
assert not (BASE / 'template-identities.json').exists()
templates = ['observer.pl', 'cases.json', 'delimiter-cases.json', 'acquired-profiles.json',
             'preflight/stdout.log.gz', 'delimiter_controls/stdout.log.gz']
identities = {}
for name in templates:
    p = PRIOR / name
    raw = p.read_bytes()
    target = BASE / 'templates' / (name.replace('/', '-') + '.gz')
    target.parent.mkdir(exist_ok=True)
    target.write_bytes(gzip.compress(raw, mtime=0))
    identities[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
                              retained=str(target))
(BASE / 'template-identities.json').write_text(json.dumps(identities, indent=2) + '\n')
cases = json.loads((PRIOR / 'cases.json').read_bytes()) + json.loads((PRIOR / 'delimiter-cases.json').read_bytes())
assert len(cases) == 184
observations = {}
for phase in ('preflight', 'delimiter_controls'):
    for line in gzip.decompress((PRIOR / phase / 'stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith('ARRAY_PIPELINE_PERL '):
            _, key, value = line.split(' ', 2)
            assert key not in observations
            observations[key] = json.loads(value)
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')
excluded = {h + suffix for h in helpers for suffix in ('_free_hash_guard', '_receiver_hash_guard')}
excluded |= {'trim_later_with', 'uniq_copy_later_with', 'lower_logical_later_with', 'needed_split_delimiter_receiver'}
profiles = []
for case in cases:
    if case['id'] in excluded:
        continue
    expected = {k: v for k, v in observations[case['id']].items()
                if k not in ('substitution', 'module_input', 'handler_input')}
    is_defect = case.get('host_literal') and case.get('seed') == 'main'
    if is_defect:
        expected.update(native=[], fresh=[])
    profiles.append(dict(case=case, expected_observation=expected,
                         role='source-repair' if is_defect else 'preservation'))
assert len(profiles) == 166 and sum(p['role'] == 'source-repair' for p in profiles) == 14
fixture = Path('tests/fixtures/array_pipeline_source_isolation_perl_cases.json')
assert not fixture.exists()
fixture.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')

original = (PRIOR / 'observer.pl').read_text()
observer = original.replace(str(PRIOR), str(BASE))
(BASE / 'observer.pl').write_text(observer)
start = original.index('sub plain_error_value')
loop = original.index('for my $case (@$cases) {')
functions = original[start:loop].replace(' my $path=', ' return undef unless defined $output;\n my $path=', 1)
body = original[loop + len('for my $case (@$cases) {'):].rsplit('}', 1)[0]
body = body.replace(" print 'ARRAY_PIPELINE_INPUT '", " print STDERR 'ARRAY_PIPELINE_SOURCE_INPUT '")
body = body.replace('$json->encode({source=>$source,emitted=>$emitted,handler=>$handler}),"\\n";',
                    '$json->encode({source=>$source,emitted=>$emitted,handler=>$handler}),"\\n" if defined $output;')
body = body.replace(" print 'ARRAY_PIPELINE_PERL '.$id.' '.$json->encode(\\%row),\"\\n\";", ' return \\%row;')
assert "return \\%row;" in body
prefix = original[:original.index('my ($fixture,$output)=@ARGV;')]
prefix += '''use Test::More;
my $output = $ENV{LINKEDSPEC_ARRAY_PIPELINE_SOURCE_CAPTURE};
die 'unsafe source capture' if defined($output) &&
 ($output !~ m{\\Adocs/checkpoints/array-pipeline-source-perl-2026-11-10/[a-z_]+\\z} || !-d $output || -l $output);
'''
tail = '''
sub normalize_serials {
 my ($value)=@_;
 return $value if JSON::PP::is_bool($value);
 return [map { normalize_serials($_) } @$value] if ref($value) eq 'ARRAY';
 return {map {$_=>normalize_serials($value->{$_})} keys %$value} if ref($value) eq 'HASH';
 return $value if !defined($value) || ref($value);
 $value =~ s/\\(eval \\d+\\)/(eval SERIAL)/g;
 return $value;
}
sub projection {
 my ($row)=@_;
 return normalize_serials({map {$_=>$row->{$_}}
   grep {$_ ne 'substitution' && $_ ne 'module_input' && $_ ne 'handler_input'} keys %$row});
}
open my $file,'<:raw','tests/fixtures/array_pipeline_source_isolation_perl_cases.json' or die $!;
my $profiles=$json->decode(do{local $/;<$file>}); close $file or die $!;
for my $profile (@$profiles) {
 my $case=$profile->{case};
 subtest $case->{id} => sub {
  my $row=observe($case);
  diag('ARRAY_PIPELINE_SOURCE_PERL '.$case->{id}.' '.$json->encode($row));
  is($json->encode(projection($row)), $json->encode(normalize_serials($profile->{expected_observation})),
     $profile->{role} eq 'source-repair' ? 'Number source ignores unrelated host Array' : 'acquired source policy preserved');
 };
}
done_testing();
'''
normal = prefix + functions + 'sub observe {\n my ($case)=@_;' + body + '}\n' + tail
Path('t/array_pipeline_source_isolation.t').write_text(normal)
print('Authored166 source/policy groups, including14 host-read RED controls; retained all184 sources')

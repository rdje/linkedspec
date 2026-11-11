"""Freeze independent current oracles and author the bounded result normal."""
import gzip
import hashlib
import json
from pathlib import Path
import re

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-pipeline-callable-perl-2026-11-11')
FIXTURE = Path('tests/fixtures/array_pipeline_callable_result_guard_perl_cases.json')
NORMAL = Path('t/array_pipeline_callable_result_guard_composition.t')
assert not FIXTURE.exists() and not NORMAL.exists()


def observations(phase):
    raw = gzip.decompress((BASE / phase / 'run-stdout.log.gz').read_bytes()).decode()
    return {m[1]: json.loads(m[2]) for line in raw.splitlines()
            if (m := re.fullmatch(r'ARRAY_PIPELINE_CALLABLE_PERL_PERL (\w+) (.*)', line))}


def normalize(value):
    if isinstance(value, dict):
        return {key: normalize(item) for key, item in value.items()
                if key not in ('substitution', 'module_input', 'handler_input')}
    if isinstance(value, list):
        return [normalize(item) for item in value]
    if isinstance(value, str):
        return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value)
    return value


ready = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])
cases = json.loads((OLD / 'cases.json').read_bytes())
extra = json.loads((BASE / 'signature-cases.json').read_bytes())
observed = observations('intake'); signatures = observations('signatures')
assert len(cases) == len(observed) == 178 and len(extra) == len(signatures) == 10
roles = json.loads((OLD / 'classification.json').read_bytes())['roles']
oracles = {
    'needed_source_composed': 'needed_source_terminal',
    'needed_delimiter_composed': 'needed_delimiter_terminal',
    'invalid_range_receiver_composed': 'invalid_range_receiver_terminal',
}
profiles = []
for case in cases:
    key = case['id']; role = roles[key]
    if role == 'supported-target':
        if key.startswith('own_needed_'):
            oracle = key.removesuffix('_receiver') + '_free'
        else:
            oracle = oracles.get(key)
        if oracle:
            expected = normalize(observed[oracle]); expected['metadata'] = ready
            profiles.append(dict(case=case, role='needed-error-target', oracle=oracle,
                expected_observation=expected))
        else:
            expected = [None, 'S'] if key == 'own_source_before_rejection' else case['expected']
            profiles.append(dict(case=case, role='result-target', expected=expected))
    elif role == 'pattern-producer-boundary':
        # Preserve literal normalization/no-P and the complete observed payload/error
        # projection. Readiness movement is disclosed separately, not product-RED credit.
        expected = normalize(observed[key]); expected['metadata'] = ready
        profiles.append(dict(case=case, role='compatibility-readiness', expected_observation=expected))
    else:
        profiles.append(dict(case=case, role='preservation', original_role=role,
            expected_observation=normalize(observed[key])))
for case in extra:
    if case['question'] == 'valid' and case['form'] == 'composed':
        profiles.append(dict(case=case, role='result-target', expected=case['authored_expected']))
    else:
        profiles.append(dict(case=case, role='preservation', original_role=case['question'],
            expected_observation=normalize(signatures[case['id']])))
assert len(profiles) == 188
assert sum(p['role'] in ('result-target', 'needed-error-target') for p in profiles) == 27
assert sum(p['role'] == 'compatibility-readiness' for p in profiles) == 3
assert sum(p['role'] == 'preservation' for p in profiles) == 158
FIXTURE.write_text(json.dumps(profiles, indent=2) + '\n')
(BASE / 'classification.json').write_text(json.dumps(dict(original_roles=roles,
    error_oracles={p['case']['id']: p['oracle'] for p in profiles if 'oracle' in p},
    roles={p['case']['id']: p['role'] for p in profiles},
    original_supported_targets=25, added_variadic_targets=2, compatibility_readiness=3,
    limits='Three legacy pattern-source readiness movements are separate from supported result targets; no eager pattern or first-class regex authority. Invalid signatures and malformed free composed observations stay unready.'), indent=2) + '\n')

source = (BASE / 'observer.pl').read_text()
assert hashlib.sha256(source.encode()).hexdigest() == json.loads((BASE / 'intake/input-identities.json').read_bytes())[str(BASE / 'observer.pl')]['sha256']
head = source[:source.index('my ($fixture,$output)=@ARGV;')]
helpers = source[source.index('sub plain_error_value {'):source.index('for my $case (@$cases) {')]
assert helpers.count(' return undef unless defined $body;') == 1
helpers = helpers.replace(' return undef unless defined $body;', ' return undef unless defined $body;\n return undef unless defined $output;')
body = source[source.index('for my $case (@$cases) {') + len('for my $case (@$cases) {\n'):source.index(" print 'ARRAY_PIPELINE_CALLABLE_PERL_PERL ")]
assert body.count(" print 'ARRAY_PIPELINE_CALLABLE_PERL_INPUT ") == 1
body = body.replace(" print 'ARRAY_PIPELINE_CALLABLE_PERL_INPUT ", " print STDERR 'CALLABLE_PIPELINE_RESULT_INPUT ")
body = body.replace('"\\n";\n', '"\\n" if defined $output;\n')
prefix = head + '''use Test::More;
my $output = $ENV{LINKEDSPEC_CALLABLE_PIPELINE_RESULT_CAPTURE};
die 'unsafe owned source capture' if defined($output) &&
 ($output !~ m{\\Adocs/checkpoints/array-pipeline-callable-result-perl-2026-11-11/[a-z_]+\\z} || !-d $output || -l $output);
''' + helpers + 'sub observe {\n my ($case)=@_;\n' + body + ' return \\%row;\n}\n'
tail = r'''
sub normalized {
 my ($value)=@_;
 return $value if JSON::PP::is_bool($value);
 return [map {normalized($_)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_=>normalized($value->{$_})} keys %$value} if ref($value) eq 'HASH';
 return $value if !defined($value) || ref($value);
 $value =~ s/\(eval \d+\)/(eval SERIAL)/g;
 return $value;
}
sub projection {
 my ($row)=@_;
 return normalized({map {$_=>$row->{$_}} grep {$_ ne 'substitution' && $_ ne 'module_input' && $_ ne 'handler_input'} keys %$row});
}
open my $file,'<:raw','tests/fixtures/array_pipeline_callable_result_guard_perl_cases.json' or die $!;
my $profiles=$json->decode(do{local $/;<$file>});close $file or die $!;
for my $profile (@$profiles) {
 my $case=$profile->{case};
 subtest $case->{id} => sub {
  my $row=observe($case);
  diag('CALLABLE_PIPELINE_RESULT_ROW '.$case->{id}.' '.$json->encode($row));
  if ($profile->{role} eq 'result-target') {
   ok($row->{native_callable} && !$row->{build_error}, 'native parser builds');
   ok($row->{loaded} && !$row->{load_error}, 'fresh module loads');
   is_deeply($row->{native_error}, undef, 'native error absent');
   is_deeply($row->{fresh_error}, undef, 'fresh error absent');
   is($json->encode($row->{native}),$json->encode($profile->{expected}),'native result and effects');
   is($json->encode($row->{fresh}),$json->encode($profile->{expected}),'fresh result and effects');
   is_deeply($row->{warnings},[],'warning-free');
   is_deeply($row->{metadata},{language_agnostic_action_ir_ready=>1,raw_perl_dependency_count=>0,
    canonical_action_ir_fallback_count=>0,unresolved_helper_count=>0,unresolved_helpers=>[]},'full-source canonical eligibility');
  } else {
   is($json->encode(projection($row)),$json->encode($profile->{expected_observation}),
    $profile->{role} eq 'needed-error-target' ? 'complete required producer error retained' : 'acquired projection and disclosed readiness preserved');
  }
 };
}
done_testing();
'''
NORMAL.write_text(prefix + tail)
(BASE / 'prepared-identities.json').write_text(json.dumps({str(p): hashlib.sha256(p.read_bytes()).hexdigest()
    for p in (FIXTURE, NORMAL, BASE / 'classification.json')}, indent=2) + '\n')
print('188 groups:27 supported targets/three disclosed compatibility-readiness movements/158 preservation records')

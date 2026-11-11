"""Verify fresh producers/preservation before writing the bounded regression normal."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-transform-callable-perl-2026-11-11')
FIXTURE = Path('tests/fixtures/array_transform_callable_result_guard_perl_cases.json')
NORMAL = Path('t/array_transform_callable_result_guard_composition.t')
assert not FIXTURE.exists() and not NORMAL.exists()
cases = json.loads((BASE / 'cases.json').read_bytes())
policy = json.loads((OLD / 'policy-contract.json').read_bytes())
old = json.loads((OLD / 'observations.json').read_bytes())
old.update(json.loads((OLD / 'terminal-observations.json').read_bytes()))
rows, inputs = {}, {}
for line in gzip.decompress((BASE / 'intake/run-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL_PERL '):
        _, key, raw = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(raw)
    elif line.startswith('ARRAY_TRANSFORM_CALLABLE_PERL_INPUT '):
        _, key, raw = line.split(' ', 2)
        assert key not in inputs
        inputs[key] = json.loads(raw)
assert set(rows) == set(inputs) == {case['id'] for case in cases}


def normalized(value):
    if isinstance(value, dict):
        return {k: normalized(v) for k, v in value.items() if k not in ('substitution', 'module_input', 'handler_input')}
    if isinstance(value, list):
        return [normalized(v) for v in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


ready = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])


def matches(row, intent):
    if row['metadata'] != ready:
        return False
    for route, usable in (('native', 'native_callable'), ('fresh', 'loaded')):
        if row.get(usable) != 1 or route not in row:
            return False
        error = row.get(route + '_error')
        if intent['kind'] == 'value':
            if error or json.dumps(row[route], sort_keys=True) != json.dumps(intent['value'], sort_keys=True):
                return False
        else:
            text = json.dumps(error, sort_keys=True)
            if not error or intent['code'] not in text or (intent.get('identifier') and 'identifier=' + intent['identifier'] not in text):
                return False
    return True


for case in cases:
    key = case['id']
    assert inputs[key]['source'] == case['source']
    for field, source in (('module_input', 'emitted'), ('handler_input', 'handler')):
        artifact = rows[key][field]
        raw = inputs[key][source].encode()
        assert gzip.decompress(Path(artifact['path']).read_bytes()) == raw
        assert len(raw) == artifact['bytes'] and hashlib.sha256(raw).hexdigest() == artifact['sha256']
        if key in old:
            original = old[key][field]
            assert raw == gzip.decompress(Path(original['path']).read_bytes()), (key, field, 'original source body changed')
    if key in old:
        assert normalized(rows[key]) == normalized(old[key]), (key, 'original full record changed')
assert len(old) == 288
assert all(not matches(rows[key], intent) for key, intent in policy['targets'].items())
assert all(matches(rows[key], intent) for key, intent in policy['healthy_intents'].items())
positive = cases[288:]
producers = [case for case in positive if case['form'] != 'receiver_composed']
assert len(producers) == 16
assert all(matches(rows[case['id']], dict(kind='value', value=case['expected'])) for case in producers), 'producer prerequisite: stop before production'
profiles, oracles, extra_targets = [], {}, []
for case in cases:
    key = case['id']
    intent = policy['targets'].get(key)
    if key.startswith('positive_') and case['form'] == 'receiver_composed':
        desired = dict(kind='value', value=case['expected'])
        if not matches(rows[key], desired):
            intent = desired
            extra_targets.append(key)
    if intent:
        if intent['kind'] == 'needed-error':
            oracle = key + '_terminal_probe' if key.startswith('own_') else key.replace('_composed', '_terminal')
            assert oracle in rows and matches(rows[oracle], intent), (key, oracle)
            expected = normalized(copy.deepcopy(rows[oracle]))
            expected['metadata'] = ready
            profiles.append(dict(case=case, role='needed-error-target', oracle=oracle, expected_observation=expected))
            oracles[key] = oracle
        else:
            profiles.append(dict(case=case, role='result-target', expected=intent['value']))
    else:
        profiles.append(dict(case=case, role='preservation', expected_observation=normalized(rows[key])))
assert len(profiles) == 312
FIXTURE.write_text(json.dumps(profiles, indent=2) + '\n')
classification = dict(original_records_preserved=288, original_supported_targets=35,
    terminal_positive_controls=16, new_source_order_targets=extra_targets,
    targets=35 + len(extra_targets), protected_records=277 - len(extra_targets),
    error_oracles=oracles, roles={p['case']['id']: p['role'] for p in profiles},
    limits='Finite authored current records; protected profiles are not semantic PASS. Modules precede fresh eval; native dumps follow internal compilation and precede invocation. Native precompile closure4.2/SESSION5 is open.')
(BASE / 'classification.json').write_text(json.dumps(classification, indent=2, sort_keys=True) + '\n')

source = (BASE / 'observer.pl').read_text()
record = json.loads((BASE / 'intake/input-identities.json').read_bytes())[str(REL / 'observer.pl')]
assert hashlib.sha256(source.encode()).hexdigest() == record['sha256']
head = source[:source.index('my ($fixture,$output)=@ARGV;')]
helpers = source[source.index('sub plain_error_value {'):source.index('for my $case (@$cases) {')]
assert helpers.count(' return undef unless defined $body;') == 1
helpers = helpers.replace(' return undef unless defined $body;', ' return undef unless defined $body;\n return undef unless defined $output;')
body = source[source.index('for my $case (@$cases) {') + len('for my $case (@$cases) {\n'):source.index(" print 'ARRAY_TRANSFORM_CALLABLE_PERL_PERL ")]
lines = body.splitlines()
input_lines = [i for i, line in enumerate(lines) if line.startswith(" print 'ARRAY_TRANSFORM_CALLABLE_PERL_INPUT ")]
assert len(input_lines) == 1
i = input_lines[0]
lines[i] = lines[i].replace(" print 'ARRAY_TRANSFORM_CALLABLE_PERL_INPUT ", " print STDERR 'CALLABLE_ARRAY_TRANSFORM_RESULT_INPUT ").removesuffix(';') + ' if defined $output;'
body = '\n'.join(lines) + '\n'
prefix = head + '''use Test::More;
my $output = $ENV{LINKEDSPEC_CALLABLE_TRANSFORM_RESULT_CAPTURE};
die 'unsafe owned source capture' if defined($output) &&
 ($output !~ m{\\Adocs/checkpoints/array-transform-callable-result-perl-2026-11-11/[a-z_]+\\z} || !-d $output || -l $output);
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
open my $file,'<:raw','tests/fixtures/array_transform_callable_result_guard_perl_cases.json' or die $!;
my $profiles=$json->decode(do{local $/;<$file>});close $file or die $!;
for my $profile (@$profiles) {
 my $case=$profile->{case};
 subtest $case->{id} => sub {
  my $row=observe($case);
  diag('CALLABLE_ARRAY_TRANSFORM_RESULT_ROW '.$case->{id}.' '.$json->encode($row)) if defined $output;
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
    $profile->{role} eq 'needed-error-target' ? 'complete required producer error retained' : 'full acquired observation preserved');
  }
 };
}
done_testing();
'''
NORMAL.write_text(prefix + tail)
print(json.dumps(dict(result='PASS', original288_exact=True, positive_terminal_controls=16,
    groups=312, targets=classification['targets'], protected_records=classification['protected_records']), sort_keys=True))

"""Freeze terminal-derived targets/compatibility and full acquired fences before repair."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
FIXTURE = Path('tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json')
NORMAL = Path('t/array_concat_open_arity_result_guard_composition.t')
LEGACY = Path('tests/fixtures/array_transform_callable_result_guard_perl_cases.json')
LEGACY_NORMAL = Path('t/array_transform_callable_result_guard_composition.t')
assert all(not path.exists() for path in (FIXTURE, NORMAL, BASE / 'baseline.json'))
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs']) == b''
cases = json.loads((BASE / 'cases.json').read_bytes())
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
cold = assessment['observed']
targets = assessment['original_supported_targets'] + assessment['additional_supported_targets']
compatibility = ['own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver']
assert len(targets) == len(set(targets)) == 26 and not set(targets) & set(compatibility)
ready = dict(language_agnostic_action_ir_ready=1, raw_perl_dependency_count=0,
    canonical_action_ir_fallback_count=0, unresolved_helper_count=0, unresolved_helpers=[])


def normalized(value):
    if isinstance(value, dict):
        return {key: normalized(child) for key, child in value.items()}
    if isinstance(value, list):
        return [normalized(child) for child in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def projection(row):
    return normalized({key: value for key, value in row.items() if key not in ('substitution', 'module_input', 'handler_input')})


profiles, values, oracles = [], {}, {}
for case in cases:
    key = case['id']
    if key in targets:
        if 'expected_error' in case:
            oracle = key[:-len(case['tail'])] + 'terminal'
            expected = projection(cold[oracle])
            assert expected['metadata'] == ready
            assert all('binding_kind_mismatch' in json.dumps(expected[route + '_error']) for route in ('native', 'fresh'))
            profiles.append(dict(case=case, role='needed-error-target', oracle=oracle, expected_observation=expected))
            oracles[key] = oracle
        else:
            if case['origin'] == 'selection84':
                expected = case['expected']
            elif case['question'] == 'valid-rest-source':
                expected = [None, 'SXTU' if case['signature'] == 'rest_multi' else 'STU']
                oracle = key.removesuffix('_composed') + '_terminal'
                assert cold[oracle]['native'] == cold[oracle]['fresh'] == [['head', 'tail', 'end'], expected[1]]
            else:
                assert case['question'] == 'source-snapshot'
                expected = [None, ['head', 'changed']]
                oracle = key.removesuffix('_hash') + '_terminal'
                assert cold[oracle]['native'] == [['head', 'tail', 'end'], ['head', 'changed']]
            values[key] = expected
            profiles.append(dict(case=case, role='result-target', expected=expected))
    elif key in compatibility:
        oracle = key + '_terminal_probe'
        assert cold[oracle]['metadata'] == ready and cold[oracle]['native'] == cold[oracle]['fresh'] == [['head', 'tail', 'tail'], 'SX']
        expected = projection(cold[key])
        assert expected['native_error'] is None and expected['fresh_error'] is None and not expected['warnings']
        expected.update(native=[None, 'SX'], fresh=[None, 'SX'], metadata=copy.deepcopy(ready))
        profiles.append(dict(case=case, role='compatibility-result-guard', oracle=oracle, expected_observation=expected))
        oracles[key] = oracle
    else:
        profiles.append(dict(case=case, role='preservation', expected_observation=projection(cold[key])))
assert len(profiles) == 504 and sum(row['role'] == 'preservation' for row in profiles) == 476
FIXTURE.write_text(json.dumps(profiles, indent=2) + '\n')
(BASE / 'baseline.json').write_text(json.dumps(dict(observed=cold, supported_targets=targets,
    separate_compatibility=compatibility, value_targets=values, error_oracles=oracles,
    preserved=[row['case']['id'] for row in profiles if row['role'] == 'preservation']), indent=2, sort_keys=True) + '\n')

# Prepare an exact two-object splice of the existing legacy fixture, leaving every
# other byte and each authored source intact. Applying it belongs to repair.py.
before = LEGACY.read_text()
decoder = json.JSONDecoder()
position = before.index('[') + 1
splices, original, transferred = [], json.loads(before), []
profile_by_id = {row['case']['id']: row for row in profiles}
while True:
    while before[position].isspace() or before[position] == ',':
        position += 1
    if before[position] == ']':
        break
    row, end = decoder.raw_decode(before, position)
    key = row['case']['id']
    if key in compatibility:
        after = copy.deepcopy(row)
        after['role'] = 'compatibility-result-guard'
        after['expected_observation'] = profile_by_id[key]['expected_observation']
        assert after['case'] == row['case']
        splices.append((position, end, json.dumps(after, indent=2).replace('\n', '\n  ')))
        transferred.append(key)
    position = end
after = before
for start, end, replacement in reversed(splices):
    after = after[:start] + replacement + after[end:]
assert len(splices) == 2 and set(transferred) == set(compatibility)
for old, new in zip(original, json.loads(after)):
    assert old == new if old['case']['id'] not in compatibility else old['case'] == new['case']
for phase, body in (('before', before), ('after', after)):
    (BASE / ('legacy-fixture-' + phase + '.json.gz')).write_bytes(gzip.compress(body.encode(), mtime=0))
legacy_before = LEGACY_NORMAL.read_text()
old = '''   is($json->encode(projection($row)),$json->encode($profile->{expected_observation}),
    $profile->{role} eq 'needed-error-target' ? 'complete required producer error retained' : $profile->{role} eq 'compatibility-readiness' ? 'payload/error boundaries and disclosed readiness' : 'full acquired observation preserved');'''
new = '''   my $label = $profile->{role} eq 'needed-error-target' ? 'complete required producer error retained'
    : $profile->{role} eq 'compatibility-readiness' ? 'payload/error boundaries and disclosed readiness'
    : $profile->{role} eq 'compatibility-result-guard' ? 'disclosed concat result-guard compatibility'
    : 'full acquired observation preserved';
   is($json->encode(projection($row)),$json->encode($profile->{expected_observation}),$label);'''
assert legacy_before.count(old) == 1
for phase, body in (('before', legacy_before), ('after', legacy_before.replace(old, new))):
    (BASE / ('legacy-normal-' + phase + '.t.gz')).write_bytes(gzip.compress(body.encode(), mtime=0))
(BASE / 'legacy-transfer.json').write_text(json.dumps(dict(ids=compatibility, unchanged_profiles=310,
    scope='Two non-Array excess-operand later continuations use their acquired terminal SX; no product-RED/input-domain credit. All authored cases and other310 profiles stay exact. Test-source change only names the disclosed compatibility comparison.'), indent=2) + '\n')

observer = (BASE / 'observer.pl').read_text()
record = json.loads((BASE / 'intake/input-identities.json').read_bytes())[str(BASE / 'observer.pl')]
assert hashlib.sha256(observer.encode()).hexdigest() == record['sha256']
head = observer[:observer.index('my ($fixture,$output)=@ARGV;')]
helpers = observer[observer.index('sub plain_error_value {'):observer.index('for my $case (@$cases) {')]
helpers = helpers.replace(' return undef unless defined $body;', ' return undef unless defined $body;\n return undef unless defined $output;')
body = observer[observer.index('for my $case (@$cases) {\n') + len('for my $case (@$cases) {\n'):observer.index(" print 'ARRAY_CONCAT_PERL ")]
old_input = ''' print 'ARRAY_CONCAT_INPUT '.$id.' '.$json->encode({source=>$source,emitted=>$emitted,handler=>$handler}),"\\n";'''
new_input = ''' diag('ARRAY_CONCAT_NORMAL_INPUT '.$id.' '.$json->encode({source=>$source,emitted=>$emitted,handler=>$handler})) if defined $output;'''
assert body.count(old_input) == 1
body = body.replace(old_input, new_input)
normal = head + '''use Test::More;
my $output = $ENV{LINKEDSPEC_ARRAY_CONCAT_CAPTURE};
die 'unsafe owned capture' if defined($output) &&
 ($output !~ m{\\Adocs/checkpoints/array-concat-open-arity-perl-2026-11-12/[a-z_]+\\z} || !-d $output || -l $output);
require LinkedSpec::ActionIR::MethodLowering;
my $owner = $INC{'LinkedSpec/ActionIR/MethodLowering.pm'};
open my $owner_file,'<:raw',$owner or die $!;
my $owner_body = do {local $/;<$owner_file>};close $owner_file or die $!;
diag('ARRAY_CONCAT_NORMAL_OWNER '.$json->encode({path=>$owner,bytes=>length($owner_body),sha256=>sha256_hex($owner_body)}));
''' + helpers + 'sub observe {\n my ($case)=@_;\n' + body + ' return \\%row;\n}\n'
normal += r'''
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
open my $file,'<:raw','tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json' or die $!;
my $profiles=$json->decode(do{local $/;<$file>});close $file or die $!;
for my $profile (@$profiles) {
 my $case=$profile->{case};
 subtest $case->{id} => sub {
  my $row=observe($case);
  diag('ARRAY_CONCAT_NORMAL_ROW '.$case->{id}.' '.$json->encode($row)) if defined $output;
  if ($profile->{role} eq 'result-target') {
   ok($row->{native_callable} && !$row->{build_error},'native parser builds');
   ok($row->{loaded} && !$row->{load_error},'fresh module loads');
   is_deeply($row->{native_error},undef,'native error absent');
   is_deeply($row->{fresh_error},undef,'fresh error absent');
   is($json->encode($row->{native}),$json->encode($profile->{expected}),'native result and effects');
   is($json->encode($row->{fresh}),$json->encode($profile->{expected}),'fresh result and effects');
   is_deeply($row->{warnings},[],'warning-free');
   is_deeply($row->{metadata},{language_agnostic_action_ir_ready=>1,raw_perl_dependency_count=>0,
    canonical_action_ir_fallback_count=>0,unresolved_helper_count=>0,unresolved_helpers=>[]},'full-source eligibility');
  } else {
   is($json->encode(projection($row)),$json->encode($profile->{expected_observation}),
    $profile->{role} eq 'needed-error-target' ? 'full required producer error retained'
    : $profile->{role} eq 'compatibility-result-guard' ? 'disclosed concat result-guard compatibility'
    : 'full acquired observation preserved');
  }
 };
}
done_testing();
'''
NORMAL.write_text(normal)
(BASE / 'baseline-summary.json').write_text(json.dumps(dict(programs=504, supported_targets=26,
    separate_compatibility=2, complete_preserved_records=476, initial_policies=80,
    invalid_signature_profiles=8, actual_module_dump_pairs=504), indent=2) + '\n')
assert LEGACY.read_text() == before and LEGACY_NORMAL.read_text() == legacy_before
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs']) == b''
print('Frozen26 supported targets/two compatibility/476 full records and exact two-profile future transfer; source unchanged')

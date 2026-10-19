"""Retain the failed reviewer; correct its payload schema and strengthen source/lineage checks."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'runtime-reviewer-repair.json')
final = ROOT / (PREFIX + 'review-runtime-final.py')
assert not target.exists() and not final.exists()
original = (ROOT / (PREFIX + 'review-runtime.py')).read_bytes()
old = b"decode(values[MODULE]['bytes_base64']) == old(MODULE)"
new = b"decode(values[MODULE]['base64']) == old(MODULE)"
assert original.count(old) == 1
corrected = original.replace(old, new).replace(b"'runtime-review.json'", b"'runtime-review-final.json'")
anchor = b'for index, row in enumerate(rows):'
assert corrected.count(anchor) == 1
strength = r"""# Independent exact source recipes: a different hash alone cannot identify an inverse.
def source_change(before, after):
    assert candidate.count(before) == 1
    return candidate.replace(before, after)

scope_body = (b' return LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], sub {\n'
              b'  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)\n })')
expected_sources = {
    'positive': candidate, 'all-direct-consumers': candidate,
    'missing-producer-scope': source_change(scope_body,
        b' return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)'),
    'missing-input-scope': source_change(
        b'  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)', b'  return $work->()'),
    'scopes-before-source-invocation': source_change(
        b' return LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($code, sub { return _with_pipeline_emission_scopes(sub {',
        b' return _with_pipeline_emission_scopes(sub { return LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($code, sub {'),
    'duplicate-apply-fetch': source_change(b'my $apply = $rewrite_by_id{$contract_id}{apply};',
        b'my $apply = $rewrite_by_id{$contract_id}{apply}; my $second = $rewrite_by_id{$contract_id}{apply};'),
    'scope-retains-opaque-callback': source_change(b' my $opaque = shift;',
        b" my $opaque = shift;\n $LinkedSpec::ActionIR::SourceEmissions::_producers->{held_opaque} = $callback if ref($LinkedSpec::ActionIR::SourceEmissions::_producers) eq 'HASH';"),
    'register-every-supplied-apply': source_change(b' my $opaque = shift;',
        b' my $opaque = shift;\n LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($callback);'),
    'non-CODE-dispatch-moves-source': source_change(b"ref($callback) eq 'CODE' ? $callback : $opaque", b'$callback'),
    'coerce-invocation-body-scalar': source_change(
        b'  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs($work)',
        b'  return LinkedSpec::ActionIR::SourceEmissions::_with_source_inputs(sub { scalar $work->() })'),
}
for role, token in [('factory', b'my $contracts = '), ('collect', b'my $ir_diag = '),
                    ('canonical', b'my $canonical_ir_diag = '), ('find', b'my $diag = '),
                    ('apply', b'my $lowered_stmt = ')]:
    definitions = [item for item in implementation['replacements']
                   if decode(item['before_base64']).lstrip().startswith(token)]
    assert len(definitions) == 1
    expected_sources['missing-' + role + '-capture'] = source_change(
        decode(definitions[0]['after_base64']), decode(definitions[0]['before_base64']))
assert set(expected_sources) == set(expected_names)

# Every original helper remains whole; each distinct finisher has one exact recipe.
repair = read('red-repair.json')
old_fixture = decode(repair['original_fixture_base64'])
fixed_fixture = old_fixture.replace(decode(repair['replacement_before_base64']),
                                    decode(repair['replacement_after_base64']))
assert sha(old_fixture) == repair['original_fixture_sha256']
assert sha(fixed_fixture) == repair['corrected_fixture_sha256']
assert sha(raw(PREFIX + 'capture-red.py')) == repair['original_capture_sha256']
assert sha(raw(PREFIX + 'capture-red-final.py')) == repair['corrected_capture_sha256']
assert b'AssertionError' in decode(repair['outer_combined_log_base64'])
fixed_plan = read('assertion-finalization.json')
original_assertions = raw(PREFIX + 'pipeline-assertions.pl')
assert sha(original_assertions) == fixed_plan['original_assertion_sha256']
assert original_assertions.count(decode(fixed_plan['removed_base64'])) == 1
fixed_assertions = original_assertions.replace(decode(fixed_plan['removed_base64']),
                                              decode(fixed_plan['replacement_base64']))
assert fixed_assertions == raw(PREFIX + 'pipeline-assertions-final.pl')
assert sha(fixed_assertions) == fixed_plan['final_assertion_sha256']
acceptance = read('assertion-acceptance.json')
assert sha(fixed_assertions) == acceptance['original_assertion_sha256']
accepted_assertions = fixed_assertions
for change in acceptance['replacements']:
    before, after = decode(change['before_base64']), decode(change['after_base64'])
    assert accepted_assertions.count(before) == 1
    accepted_assertions = accepted_assertions.replace(before, after)
assert accepted_assertions == raw(PREFIX + 'pipeline-assertions-accepted.pl')
assert sha(accepted_assertions) == acceptance['accepted_assertion_sha256']
oracle = read('native-oracle-finalization.json')
assert sha(accepted_assertions) == oracle['previous_assertion_sha256']
current_assertions = accepted_assertions.replace(b"'native-context-before.json'", b"'native-prove-context-before.json'")
assert current_assertions == raw(PREFIX + 'pipeline-assertions-current.pl')
assert sha(current_assertions) == oracle['current_assertion_sha256']
portable_assertions = current_assertions.replace(decode(portable['replacement_before_base64']),
                                                decode(portable['replacement_after_base64']))
assert current_assertions == decode(portable['before_source_base64'])
assert portable_assertions == raw(PREFIX + 'pipeline-assertions-portable.pl')
assert sha(portable_assertions) == portable['after_source_sha256']
assert portable_assertions == decode(reader['original_source_base64'])
final_assertions = portable_assertions.replace(decode(reader['replacement_before_base64']),
                                              decode(reader['replacement_after_base64']))
assert final_assertions == raw(PREFIX + 'pipeline-assertions-portable-final.pl')
assert sha(final_assertions) == reader['corrected_source_sha256']
observer = read('fault-observer-preparation.json')
old_probe = raw(PREFIX + 'native-factory-probe.pl')
assert sha(old_probe) == observer['original_probe_sha256']
current_probe = old_probe
for scope in ('producers', 'inputs'):
    before = f"ref(${scope}) eq 'HASH' && ref($token)".encode()
    after = f"ref(${scope}) eq 'HASH' && ref(${scope}->{{source_token}}) && ref($token)".encode()
    assert current_probe.count(before) == 1
    current_probe = current_probe.replace(before, after)
assert current_probe == raw(PREFIX + 'native-factory-current-probe.pl')
assert sha(current_probe) == observer['current_probe_sha256']
old_composition = raw(PREFIX + 'pipeline-composition-assertions.pl')
assert old_composition == decode(portable['composition_source_base64'])
assert sha(old_composition) == observer['original_assertions_sha256']
new_composition = old_composition.replace(b'/native-factory-probe.pl"', b'/native-factory-current-probe.pl"')
new_composition = new_composition.replace(decode(observer['public_loop_before_base64']),
                                          decode(observer['public_loop_after_base64']))
assert new_composition == raw(PREFIX + 'pipeline-composition-fixed.pl')
assert sha(new_composition) == observer['current_assertions_sha256']
appendix = b'''{
 require File::Basename;
 require File::Spec;
 my $root = File::Spec->rel2abs(File::Basename::dirname(__FILE__).'/..');
 require "$root/docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/pipeline-assertions-portable-final.pl";
 require "$root/docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/pipeline-composition-fixed.pl";
}

'''
assert old(FIXTURE).count(b'done_testing;\n') == 1
assert raw(FIXTURE) == old(FIXTURE).replace(b'done_testing;\n', appendix + b'done_testing;\n')
""".encode()
corrected = corrected.replace(anchor, strength + b'\n' + anchor)
old_check = b"    assert row['source_sha256'] == (sha(candidate) if index in (0, 14) else sha(source))\n    assert source != candidate if index not in (0, 14) else source == candidate"
new_check = b"    assert source == expected_sources[row['name']], ('exact source inverse', row['name'])\n    assert row['source_sha256'] == sha(expected_sources[row['name']])"
assert corrected.count(old_check) == 1
corrected = corrected.replace(old_check, new_check)
compile(corrected, str(final), 'exec')
failure = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-runtime-review-attempt1.log').read_bytes()
assert b"KeyError: 'bytes_base64'" in failure
record = dict(result='exact capsule-key correction plus independent source and helper-lineage guards',
              producer_sha256=sha(Path(__file__).read_bytes()), original_source_base64=encode(original),
              corrected_source_sha256=sha(corrected), tool_observed_returncode=1,
              actual_combined_failure_base64=encode(failure),
              channel_limit='Original checking shell merged streams; separate outer streams unavailable. '
                            'No native/runtime command or artifact is replayed or refreshed.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
with final.open('xb') as output:
    output.write(corrected)
print('Original reviewer failure retained; corrected independent source/lineage reviewer written')

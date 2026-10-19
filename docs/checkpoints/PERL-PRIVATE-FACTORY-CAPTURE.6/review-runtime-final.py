"""Independent readonly custody, native-context and complete semantic-TAP review."""
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
MODULE = 'perl/LinkedSpec/ActionIR/RewritePipeline.pm'
FIXTURE = 't/actionir_factory_capture.t'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = base64.b64decode
raw = lambda name: (ROOT / name).read_bytes()
read = lambda name: json.loads(raw(PREFIX + name))
old = lambda name: subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT)
assert sys.argv[1:] in ([], ['--capture'])

def capsule(name, metadata, key='base64'):
    packed = raw(PREFIX + name)
    assert sha(packed) == metadata.get('input_capsule_sha256', metadata.get('capsule_sha256'))
    values = json.loads(gzip.decompress(packed))
    assert set(values) == set(metadata['inputs'])
    for path, item in values.items():
        field = key if key in item else 'bytes_base64'
        assert sha(decode(item[field])) == item['sha256'] == metadata['inputs'][path]['sha256'], path
        assert item['mode'] == metadata['inputs'][path]['mode'], path
    return values

def tap(stdout, count, failed=None):
    plans = re.findall(rb'^1\.\.(\d+)\s*$', stdout, re.M)
    assert plans == [str(count).encode()], ('complete TAP plan', plans, count)
    statuses = re.findall(rb'^(not )?ok (\d+)(?:\s+-\s+(.*))?$', stdout, re.M)
    assert [int(number) for _, number, _ in statuses] == list(range(1, count + 1))
    failures = [name for negative, _, name in statuses if negative]
    assert b'Bail out!' not in stdout
    assert re.findall(rb'^Files=(\d+), Tests=(\d+),', stdout, re.M) == [(b'1', str(count).encode())]
    if failed is not None:
        assert len(failures) == failed, (len(failures), failed)
    return failures

preservation = read('preservation.json')
assert preservation['result'] == 'PASS' and preservation['base'] == BASE
names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE,
                                 '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
assert [item['path'] for item in preservation['census']] == names
assert len(preservation['selected']) == 1
selected = preservation['selected'][0]
assert selected['path'] == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json'
original_claim = decode(selected['original_base64'])
assert original_claim == old(selected['path']) and sha(original_claim) == selected['sha256']
assert len(original_claim) == 115985 and len(selected['hits']) == 1
original_record = json.loads(original_claim)
assert len(original_record['claims'][0]['durability']['inputs']) == 603
bindings = selected['hits'][0]['bindings']
assert set(bindings) == {row['path'] for row in original_record['claims'][0]['durability']['inputs']}
for item in original_record['claims'][0]['durability']['inputs']:
    assert sha(old(item['path'])) == item['sha256'] == bindings[item['path']]['sha256']
    assert len(old(item['path'])) == bindings[item['path']]['bytes']
changed = copy.deepcopy(original_record)
changed['claims'][0]['durability'].update(mode='historical', revision=BASE)
assert json.loads(raw(selected['path'])) == changed
for item in preservation['census']:
    assert sha(old(item['path'])) == item['sha256']
    if item['path'] != selected['path']:
        assert raw(item['path']) == old(item['path'])
baseline = read('baseline.json')
assert baseline == preservation['baseline'] and baseline['returncode'] == 0
assert not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Supplied fixture admission publication PASS: 603 live inputs; 115985 bytes\n'

native_records = {}
for stem, population in [('native-before', 96), ('native-extra-before', 9),
                         ('native-context-before', 9), ('native-prove-context-before', 9)]:
    record = read(stem + '.json')
    values = capsule(stem + '-inputs.json.gz', record)
    assert record['returncode'] == 0 and not decode(record['stderr_base64'])
    assert decode(values[MODULE]['base64']) == old(MODULE)
    observations = json.loads(decode(record['stdout_base64']))
    assert len(observations) == population
    native_records[stem] = (record, observations, values)
native = native_records['native-before'][1]
expected_population = []
for context in ('list', 'scalar', 'void'):
    for supplied in (0, 1):
        for outcome in ('normal', 'undefined', 'empty', 'same', 'zero', 'reference'):
            expected_population.append((context, supplied, outcome, '', 0))
        expected_population.append((context, supplied, 'normal', '', 1))
        for role in ('factory', 'collect', 'canonical', 'apply', 'find'):
            if supplied and role == 'factory':
                continue
            for outcome in ('string', 'fatal'):
                expected_population.append((context, supplied, outcome, role, 0))
assert [tuple(row['ordinary'][key] for key in ('context', 'supplied', 'outcome', 'fail_at', 'mutate'))
        for row in native] == expected_population
for row in native:
    item = row['ordinary']
    roles = ['collect', 'canonical', 'apply', 'find'] if item['supplied'] else ['factory', 'collect', 'canonical', 'apply', 'find']
    if item['fail_at']:
        roles = roles[:roles.index(item['fail_at']) + 1]
    assert [call[0] for call in item['trace']] == roles
    assert all(call[1] == 'scalar' for call in item['trace'])
    assert item['dependency_identity'] == 1 and row['scopes_released'] == 1 and row['captures'] == []
    assert item['success'] == (0 if item['fail_at'] else 1)
    if item['fail_at']:
        assert item['error'] == ({'class': 'LinkedSpec::PipelineCaptureProbe::Fatal', 'actual_fatal': 1}
                                 if item['outcome'] == 'fatal' else 'intentional ' + item['fail_at'] + ' failure\n')
    else:
        assert item['success_error'] == 'find successful error'
assert native_records['native-extra-before'][1] == native_records['native-context-before'][1]
context_record, context_rows, _ = native_records['native-prove-context-before']
observations = context_record['include_observations']
assert len(observations) == 2 and all(item['returncode'] == 0 and not decode(item['stderr_base64']) for item in observations)
include_rows = [[json.loads(line[2:]) for line in decode(item['stdout_base64']).splitlines()
                 if line.startswith(b'# {')] for item in observations]
include_root = context_record['command'][1][2:]
assert include_rows[0][0]['module_preloaded'] == include_rows[1][0]['module_preloaded'] == 0
assert include_rows[0][0]['before_linkedspec'][0] == 'perl'
assert include_rows[1][0]['before_linkedspec'][0] == include_root
relative_module = 'perl/LinkedSpec/ActionIR/RewritePipeline.pm'
absolute_module = include_root + '/LinkedSpec/ActionIR/RewritePipeline.pm'
assert include_rows[0][1]['loaded_module'] == relative_module
assert include_rows[1][1]['loaded_module'] == absolute_module
expected_context_rows = copy.deepcopy(native_records['native-extra-before'][1])
for item in expected_context_rows:
    if item['error'] is not None:
        assert item['error'].count(relative_module + ' line 489.') == 1
        item['error'] = item['error'].replace(relative_module, absolute_module)
assert context_rows == expected_context_rows

red_counts = [('red', None, None), ('red-final', 1892, 1120), ('red-fixed', 1988, 1132),
              ('red-accepted', 1988, 1129), ('red-semantic', 1988, 1128)]
for stem, count, failed in red_counts:
    record = read(stem + '.json')
    values = capsule(stem + '-inputs.json.gz', record)
    assert decode(values[MODULE]['base64']) == old(MODULE)
    assert record['returncode'] != 0
    stdout = decode(record['stdout_base64'])
    if count is None:
        assert b'All 224 subtests passed' in stdout and b'No plan found' in stdout
        assert b'Can\'t locate t/../docs/checkpoints/' in decode(record['stderr_base64'])
    else:
        failures = tap(stdout, count, failed)
        assert any(b'pipeline producer source scope' in name for name in failures)
        if stem == 'red-semantic':
            allowed = re.compile(rb'^pipeline (?:producer source scope|input source scope|actual callback boundary|'
                                 rb'actual native arguments|retains every actual|actual registered factory)')
            assert all(allowed.match(name) for name in failures)
        else:
            assert b'pipeline native tied lookup non-CODE dispatch exact diagnostics and immediate callback release' in failures

implementation = read('implementation.json')
candidate = old(MODULE)
assert sha(candidate) == implementation['before_sha256']
assert len(implementation['replacements']) == 8
for item in implementation['replacements']:
    before, after = decode(item['before_base64']), decode(item['after_base64'])
    assert candidate.count(before) == 1 and before.count(b'\n') == after.count(b'\n')
    candidate = candidate.replace(before, after)
assert candidate.endswith(b'1;\n')
candidate = candidate[:-3] + decode(implementation['helpers_base64']) + b'1;\n'
assert candidate == raw(MODULE) and sha(candidate) == implementation['after_sha256']
assert b'$apply->(@_)' in candidate.splitlines()[488]
assert decode(read('first-green.json')['combined_stdout_stderr_base64']).count(b'Result: PASS') == 1
first = read('first-green.json')
first_values = capsule('first-green-inputs.json.gz', first)
assert decode(first_values[MODULE]['base64']) == candidate
tap(decode(first['combined_stdout_stderr_base64']), 1988, 0)
portable = read('portable-assertions.json')
tap(decode(portable['first_composition_combined_base64']), 2060, 0)
reader = read('reader-context-repair.json')
assert reader['tool_observed_returncode'] == 1
tap(decode(reader['actual_combined_failure_base64']), 2065, 1)
assert b'<$context_input> line 1' in decode(reader['actual_combined_failure_base64'])

factory = read('native-factory.json')
factory_values = capsule('native-factory-inputs.json.gz', factory)
assert decode(factory_values[MODULE]['base64']) == candidate
assert factory['returncode'] == 0 and not decode(factory['stderr_base64'])
actual_factory = json.loads(decode(factory['stdout_base64']))
assert len(actual_factory['canonical_calls']) == 1 and actual_factory['scopes_restored'] == 1
for item in actual_factory['canonical_calls']:
    assert all(item[key] == 1 for key in ('actual_public_apply', 'registered_actual', 'producer_token', 'input_token', 'actual_origin'))

runtime = read('runtime.json')
values = capsule('runtime-inputs.json.gz', runtime, 'bytes_base64')
assert runtime['result'] == 'PASS' and len(values) == 426
assert sha(raw(PREFIX + 'runtime-reached.json.gz')) == runtime['reached_sha256']
rows = json.loads(gzip.decompress(raw(PREFIX + 'runtime-reached.json.gz')))
assert len(rows) == len(runtime['rows']) == 15
expected_names = ['positive', 'missing-producer-scope', 'missing-input-scope', 'scopes-before-source-invocation',
                  'missing-factory-capture', 'missing-collect-capture', 'missing-canonical-capture',
                  'missing-find-capture', 'missing-apply-capture', 'duplicate-apply-fetch',
                  'scope-retains-opaque-callback', 'register-every-supplied-apply',
                  'non-CODE-dispatch-moves-source', 'coerce-invocation-body-scalar', 'all-direct-consumers']
assert [row['name'] for row in rows] == expected_names
# Independent exact source recipes: a different hash alone cannot identify an inverse.
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

for index, row in enumerate(rows):
    assert row['complete_inputs_unchanged'] and row['modes_unchanged'] and row['parent_inputs_unchanged']
    assert row['unexpected_outputs'] == {} and row['syntax_returncode'] == 0
    source = decode(row['source_base64'])
    assert sha(source) == row['source_sha256']
    assert source == expected_sources[row['name']], ('exact source inverse', row['name'])
    assert row['source_sha256'] == sha(expected_sources[row['name']])
    assert b'Bail out!' not in decode(row['stdout_base64']) + decode(row['stderr_base64'])
    summary_row = {key: value for key, value in row.items() if key not in
                   ('source_base64', 'stdout_base64', 'stderr_base64', 'syntax_stdout_base64', 'syntax_stderr_base64')}
    assert summary_row == runtime['rows'][index]
    if index < 14:
        failures = tap(decode(row['stdout_base64']), 2065)
        assert [name.decode() for name in failures] == row['failures']
        assert row['returncode'] == 0 and not failures if index == 0 else row['returncode'] != 0 and failures
    else:
        assert row['returncode'] == 0 and not row['failures'] and row['summaries'] == [[91, 32235]]
        assert len(row['plans']) == 91 and sum(row['plans']) == 32235
        suites = [value.decode() for value in re.findall(rb'^(\S+\.t)\s+\.+', decode(row['stdout_base64']), re.M)]
        assert suites == runtime['suites'] and len(suites) == 91
for name, item in values.items():
    assert sha(raw(name)) == item['sha256'] and (ROOT / name).stat().st_mode & 0o7777 == item['mode'], name
assert not any(name.startswith(('docs/knowledge/', 'docs/linkedspec-book/')) for name in values)
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
              population=dict(original_claim_inputs=603, original_claim_bytes=115985,
                              native_rows=96, supplemental_rows=9, public_native_calls=1,
                              supplied_inputs=426, focused_assertions=2065, semantic_inverses=13,
                              direct_suites=91, direct_assertions=32235),
              scope='Readonly complete retained native/custody/semantic-TAP review; no capture or native '
                    'writer is executed. Whole original claim and all artifact/capsule bytes/modes remain '
                    'bound; prior missing-plan, mismatched-context and reader-effect epochs remain distinct.')
target = ROOT / (PREFIX + 'runtime-review-final.json')
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Independent pipeline runtime review PASS:426 inputs;2065/13 controls;91/32235;native96/9')

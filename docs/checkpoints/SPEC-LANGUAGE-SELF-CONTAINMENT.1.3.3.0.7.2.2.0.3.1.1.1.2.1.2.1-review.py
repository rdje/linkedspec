"""Independently verify actual MethodExpr input identities, aliases and supplied evidence."""
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = '8f0cdaec69b80ce5a8f4edfd783199693498bae1'
PARSER = 'perl/LinkedSpec/ActionIR/MethodExpr.pm'
TEST = 't/actionir_method_input_captures.t'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
EXPECTED = {
 'no-input-scope': 'actual original input occurrence intervals',
 'copy-direct-aliases': 'direct input scalar alias preserved',
 'change-legacy-aliases': 'legacy wrapper copied scalar behavior preserved',
 'no-callback-check': 'foreign input callback denied',
 'no-array-check': 'copied CSV input argument array denied',
 'no-capture-value-check': 'changed capture result denied',
 'no-method-fields': 'changed method input root denied',
 'no-method-args-check': 'changed method argument reference denied',
 'no-shape-check': 'changed input array shape denied',
 'no-value-check': 'changed input occurrence denied',
 'shared-input-description': 'input description detached from authority',
 'no-input-unwind': 'input scope restored after nested success',
 'shift-private-span': 'actual original input occurrence intervals',
}
ARTIFACTS = {
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-cases.json': 't/actionir_method_argument_source_frames.t',
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json': 't/actionir_executable_source_membership.t',
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-cases.json': 't/actionir_compiler_source_membership.t',
}

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def read(suffix):
    return json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())

def channels(row):
    return tuple(base64.b64decode(row[k]).decode() for k in ('stdout_base64', 'stderr_base64'))

def identity(inputs):
    for p, h in inputs.items():
        assert digest((ROOT / p).read_bytes()) == h, 'actual input identity'

def validate(final, original, inverses, consumers, toolbox, artifacts):
    output, error = channels(final)
    assert final['returncode'] == 0 and not error, 'actual final successful channels'
    assert len(re.findall(r'^ok \d+ - ', output, re.M)) == 107 and output.endswith('1..107\n'), 'complete final TAP'
    assert final['command'] == ['perl', '-Iperl', TEST], 'actual final command'
    identity(final['inputs'])
    assert set(final['inputs']) == set(original['inputs']), 'same supplied closure'
    output, error = channels(original)
    assert original['returncode'] != 0 and 'actual MethodExpr input captures are available' in error, 'actual original interface RED'
    assert len(inverses) == 13 and {r['name'] for r in inverses} == set(EXPECTED), 'complete inverse population'
    for row in inverses:
        assert row['source'] == PARSER and row['command'] == final['command'], 'actual inverse source and command'
        raw = (ROOT / PARSER).read_bytes()
        assert raw.count(row['old'].encode()) == 1, 'exact inverse intervention'
        changed = raw.replace(row['old'].encode(), row['new'].encode(), 1)
        assert row['inputs'] == dict(final['inputs'], **{PARSER: digest(changed)}), 'actual inverse producer identity'
        output, error = channels(row)
        assert row['required_failure'] == EXPECTED[row['name']], 'named inverse oracle'
        assert row['returncode'] != 0 and re.search(r'^not ok \d+ - ' + re.escape(row['required_failure']) + '$', output, re.M), 'actual semantic assertion RED'
        assert row['required_failure'] in error and 'syntax error' not in error and 'Compilation failed' not in error, 'semantic RED channels'
    output, error = channels(consumers)
    assert consumers['returncode'] == 0 and consumers['unchanged'] and 'Result: PASS' in output and not error, 'actual consumers PASS'
    tests = ['t/' + name + '.t' for name in (
        'actionir_method_input_captures', 'actionir_method_argument_source_frames', 'actionir_empty_expression_spans', 'actionir_ast_input_frames', 'actionir_ast_constructions', 'actionir_ast_parser', 'actionir_source_emissions',
        'canonical_event_occurrence_order', 'actionir_nested_block_source_spans',
        'actionir_compiler_source_membership', 'actionir_executable_source_membership',
        'trace_actionir_method_lowering', 'trace_emit_context_bridge')]
    tests += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t']
    assert consumers['command'] == ['prove', '-v', '-Iperl'] + tests, 'complete consumer selection'
    identity(consumers['inputs'])
    assert set(consumers['inputs']) == set(final['inputs']) | set(tests) | set(ARTIFACTS), 'complete supplied consumer population'
    assert consumers['producer_sha256'] == digest((ROOT / (PREFIX + 'proof.py')).read_bytes()), 'actual consumer producer'
    assert len(artifacts['rows']) == 3 and {r['missing'] for r in artifacts['rows']} == set(ARTIFACTS), 'complete actual artifact controls'
    for row in artifacts['rows']:
        assert row['command'] == ['perl', '-Iperl', ARTIFACTS[row['missing']]], 'actual artifact reader command'
        assert row['inputs'] == {p: h for p, h in consumers['inputs'].items() if p != row['missing']}, 'actual missing artifact input boundary'
        assert row['returncode'] != 0 and 'No such file or directory' in channels(row)[1], 'actual missing artifact RED'
    assert artifacts['producer_sha256'] == digest((ROOT / (PREFIX + 'artifact-controls.py')).read_bytes()), 'actual artifact control producer'
    assert artifacts['baseline_sha256'] == digest((ROOT / (PREFIX + 'consumers.json')).read_bytes()), 'actual artifact baseline'

    assert toolbox['returncode'] == 0 and toolbox['unchanged'] and not channels(toolbox)[1], 'actual Toolbox channels'
    identity(toolbox['inputs'])
    previous = json.loads((ROOT / (PREVIOUS + 'actual.json')).read_text())
    expected = [{'id': row['id'], 'lowered': row['lowered']} for row in json.loads(channels(previous)[0])['cases'] if row['id'] != 'empty-slots']
    assert json.loads(channels(toolbox)[0]) == expected and len(expected) == 3, 'unchanged Toolbox oracle'

records = [read(s) for s in ('final', 'original', 'inverses', 'consumers', 'toolbox', 'artifact-controls')]
validate(*records)
final, original = records[:2]
paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs'], cwd=ROOT).decode().split('\0')
paths = {p for p in paths if p and (ROOT / p).is_file()}
assert set(final['inputs']) == paths | {TEST}
for p, h in original['inputs'].items():
    if p != TEST:
        assert digest(subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)) == h, 'original source closure'
        assert p == PARSER or final['inputs'][p] == h, 'only Parser production changes'
    else:
        assert h == final['inputs'][p], 'same independent regression'
freeze = read('freeze')
assert len(freeze['records']) == 1 and freeze['records'][0]['verified_bindings'] == 239
for row in freeze['records']:
    raw = (ROOT / row['before']).read_bytes()
    assert digest(raw) == row['original_sha256']
    previous = json.loads(raw)
    for claim in previous['claims']:
        for entry in claim['durability']['inputs']:
            assert digest(subprocess.check_output(['git', 'show', BASE + ':' + entry['path']], cwd=ROOT)) == entry['sha256']
        claim['durability'].update(mode='historical', revision=BASE)
    assert previous == json.loads((ROOT / row['path']).read_text()), 'historical mode and revision only'

controls = []
def red(name, index, mutate, reason):
    candidate = copy.deepcopy(records)
    mutate(candidate[index])
    try:
        validate(*candidate)
    except AssertionError as exc:
        assert str(exc) == reason, (name, str(exc))
        controls.append({'name': name, 'reason': str(exc), 'result': 'RED'})
        return
    raise AssertionError('ineffective evidence control: ' + name)

red('failed-final', 0, lambda r: r.update(returncode=1), 'actual final successful channels')
red('forged-final-source', 0, lambda r: r['inputs'].update({PARSER: '0' * 64}), 'actual input identity')
red('lost-original-RED', 1, lambda r: r.update(returncode=0), 'actual original interface RED')
red('missing-inverse', 2, lambda r: r.pop(), 'complete inverse population')
red('forged-inverse-source', 2, lambda r: r[0]['inputs'].update({PARSER: '0' * 64}), 'actual inverse producer identity')
red('failed-consumers', 3, lambda r: r.update(returncode=1), 'actual consumers PASS')
red('missing-consumer', 3, lambda r: r['command'].pop(), 'complete consumer selection')
red('forged-Toolbox', 4, lambda r: r.update(stdout_base64=base64.b64encode(b'[]').decode()), 'unchanged Toolbox oracle')
red('missing-artifact-control', 5, lambda r: r['rows'].pop(), 'complete actual artifact controls')
red('forged-artifact-input', 5, lambda r: r['rows'][0]['inputs'].update({PARSER: '0' * 64}), 'actual missing artifact input boundary')
draft = read('draft-inverses')
invalid = [r for r in draft if r['name'] == 'no-method-fields']
assert len(invalid) == 1 and invalid[0]['returncode'] != 0 and 'syntax error' in channels(invalid[0])[1]
assert set(records[3]['inputs']) - set(ARTIFACTS) <= set(read('draft-consumers')['inputs']), 'supplied reader inputs preserved from broader draft'
assert not set(ARTIFACTS).intersection(read('draft-consumers')['inputs']), 'original omitted artifact inputs disclosed'
report = {'result': 'PASS', 'assertions': 107, 'source_inverses': 13, 'consumer_suites': 14,
          'supplied_consumer_inputs': len(records[3]['inputs']), 'actual_missing_artifact_reds': 3,
          'toolbox_routes': 3, 'evidence_controls': controls, 'prior_bindings': 239,
          'producer_sha256': digest(Path(__file__).read_bytes()),
          'records': {s: digest((ROOT / (PREFIX + s + '.json')).read_bytes()) for s in ('final', 'original', 'inverses', 'consumers', 'toolbox', 'freeze', 'artifact-controls', 'draft-inverses', 'draft-consumers')},
          'scope': 'Actual MethodExpr capture/return/argument occurrence identity and direct alias semantics only. Legacy copied wrappers preserved. Initial invalid syntax control and incomplete broad consumer manifest remain rejected drafts; final inverses are semantic and final selected consumers use a supplied tree including three actual JSON inputs. Earlier finite supplemental consumer input audit is next P1 .2.1.2.5. No compiler-event grant, complete Phase0 or mapped/canonical admission.'}
(ROOT / (PREFIX + 'review.json')).write_text(json.dumps(report, indent=2) + '\n')
print('MethodExpr input review PASS:107/13,14 supplied consumers,3 Toolbox routes,3 actual missing-artifact REDs,10 evidence controls;239 prior bindings preserved.')

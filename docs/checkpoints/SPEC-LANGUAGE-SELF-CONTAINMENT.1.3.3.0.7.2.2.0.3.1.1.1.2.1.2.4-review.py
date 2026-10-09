"""Independently check the actual empty-span baseline, repair and semantic inverses."""
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = 'e0ebc8d24e6b473c74ad246873402ba9dcd7a3e3'
PARSER = 'perl/LinkedSpec/ActionIR/AST/Parser.pm'
TEST = 't/actionir_empty_expression_spans.t'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
EXPECTED = {
 'restore-double-trim': 'empty expression has ordered original public interval',
 'wrong-ordered-anchor': 'empty expression has ordered original public interval',
 'drop-public-base': 'empty expression has ordered original public interval',
 'consume-nonempty-body': 'nonempty original public text and interval remain exact',
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

def validate(final, original, inverses, consumers, toolbox):
    output, error = channels(final)
    assert final['returncode'] == 0 and not error, 'actual final successful channels'
    assert len(re.findall(r'^ok \d+ - ', output, re.M)) == 65 and output.endswith('1..65\n'), 'complete final TAP'
    assert final['command'] == ['perl', '-Iperl', TEST], 'actual final command'
    identity(final['inputs'])
    assert set(final['inputs']) == set(original['inputs']), 'same supplied closure'
    output, error = channels(original)
    failed = re.findall(r'^not ok \d+ - (.+)$', output, re.M)
    assert original['returncode'] == 18 and len(failed) == 18 and set(failed) == {
        'empty expression has ordered original public interval', 'empty statement has ordered original public interval'}, 'actual original semantic RED'
    assert len(re.findall(r'^ok \d+ - ', output, re.M)) == 47 and output.endswith('1..65\n'), 'original nonempty and native controls PASS'
    assert 'native AST input frames are available' not in error and 'Compilation failed' not in error, 'original semantic channels'
    assert len(inverses) == 4 and {r['name'] for r in inverses} == set(EXPECTED), 'complete inverse population'
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
        'actionir_empty_expression_spans', 'actionir_ast_input_frames', 'actionir_ast_constructions', 'actionir_ast_parser', 'actionir_source_emissions',
        'canonical_event_occurrence_order', 'actionir_nested_block_source_spans',
        'actionir_compiler_source_membership', 'actionir_executable_source_membership',
        'trace_actionir_method_lowering', 'trace_emit_context_bridge')]
    tests += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t']
    assert consumers['command'] == ['prove', '-v', '-Iperl'] + tests, 'complete consumer selection'
    identity(consumers['inputs'])
    assert toolbox['returncode'] == 0 and toolbox['unchanged'] and not channels(toolbox)[1], 'actual Toolbox channels'
    identity(toolbox['inputs'])
    previous = json.loads((ROOT / (PREVIOUS + 'actual.json')).read_text())
    expected = [{'id': row['id'], 'lowered': row['lowered']} for row in json.loads(channels(previous)[0])['cases'] if row['id'] != 'empty-slots']
    assert json.loads(channels(toolbox)[0]) == expected and len(expected) == 3, 'unchanged Toolbox oracle'

records = [read(s) for s in ('final', 'original', 'inverses', 'consumers', 'toolbox')]
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
original_parser = subprocess.check_output(['git', 'show', BASE + ':' + PARSER], cwd=ROOT)
old = b' my $start = $base_start + $leading;'
fix = b' my $remaining = length($text) - $leading;\n $trailing = $remaining if $trailing > $remaining;\n'
assert original_parser.count(old) == 1
assert original_parser.replace(old, fix + old, 1) == (ROOT / PARSER).read_bytes(), 'bounded two-line correction only'
freeze = read('freeze')
assert len(freeze['records']) == 1 and freeze['records'][0]['verified_bindings'] == 241
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
red('lost-original-RED', 1, lambda r: r.update(returncode=0), 'actual original semantic RED')
red('missing-inverse', 2, lambda r: r.pop(), 'complete inverse population')
red('forged-inverse-source', 2, lambda r: r[0]['inputs'].update({PARSER: '0' * 64}), 'actual inverse producer identity')
red('failed-consumers', 3, lambda r: r.update(returncode=1), 'actual consumers PASS')
red('missing-consumer', 3, lambda r: r['command'].pop(), 'complete consumer selection')
red('forged-Toolbox', 4, lambda r: r.update(stdout_base64=base64.b64encode(b'[]').decode()), 'unchanged Toolbox oracle')
report = {'result': 'PASS', 'assertions': 65, 'original_failed': 18, 'original_controls_passed': 47,
          'source_inverses': 4, 'consumer_suites': 12, 'toolbox_routes': 3, 'evidence_controls': controls,
          'prior_bindings': 241, 'producer_sha256': digest(Path(__file__).read_bytes()),
          'records': {s: digest((ROOT / (PREFIX + s + '.json')).read_bytes()) for s in ('final', 'original', 'inverses', 'consumers', 'toolbox', 'freeze')},
          'scope': 'Public empty AST span invariant repair only. No new source authority, runtime lowering, mapped repair or complete Phase0 admission.'}
(ROOT / (PREFIX + 'review.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Empty-span review PASS: original18 semantic RED/47 controls; final65/4 source inverses,12 suites,3 Toolbox routes,8 evidence controls;241 prior bindings preserved.')

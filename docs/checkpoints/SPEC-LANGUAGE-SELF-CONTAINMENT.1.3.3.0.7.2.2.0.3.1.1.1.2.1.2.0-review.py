"""Independent native interval/source-inverse and original empty-span review."""
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0-'
BASE = '0d52a407c4c508cfb00d45765471f741a10de616'
PARSER = 'perl/LinkedSpec/ActionIR/AST/Parser.pm'
TEST = 't/actionir_ast_input_frames.t'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-'
EXPECTED = {
 'no-native-record': 'twins root uses original input trim, not public base',
 'public-base-as-input': 'twins root uses original input trim, not public base',
 'no-csv-frames': 'twins actual argument occurrence follows CSV flush frame',
 'no-parent-rebase': 'twins actual argument occurrence follows CSV flush frame',
 'reuse-first-twin': 'twins actual argument occurrence follows CSV flush frame',
 'public-coordinate-authority': 'twins root uses original input trim, not public base',
 'foreign-callback-source': 'foreign input has no native original frame',
 'foreign-native-root': 'foreign native input root cannot borrow parent frame',
 'no-provided-frame': 'twins actual argument occurrence follows CSV flush frame',
 'shared-native-description': 'native frame description detached',
 'no-expression-unwind': 'unsupported split preserves its explicit native root',
}

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def read(suffix):
    return json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())

def channels(row):
    return (base64.b64decode(row['stdout_base64']).decode(), base64.b64decode(row['stderr_base64']).decode())

def identity(inputs):
    for p, h in inputs.items():
        assert digest((ROOT / p).read_bytes()) == h, 'actual input identity'

def validate(final, inverses, original, consumers, toolbox, empty):
    out, error = channels(final)
    assert final['returncode'] == 0 and not error, 'actual final successful channels'
    assert len(re.findall(r'^ok \d+ - ', out, re.M)) == 63 and out.endswith('1..63\n') and '\nnot ok' not in out, 'complete final TAP'
    assert final['command'] == ['perl', '-Iperl', TEST], 'actual final command'
    identity(final['inputs'])
    assert set(final['inputs']) == set(original['inputs']), 'same original supplied closure'
    assert original['returncode'] != 0 and 'native AST input frames are available' in channels(original)[1], 'original availability RED'
    assert len(inverses) == len(EXPECTED) and {r['name'] for r in inverses} == set(EXPECTED), 'complete inverse population'
    for row in inverses:
        assert row['source'] == PARSER and row['command'] == final['command'], 'actual inverse source/command'
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
        'actionir_ast_input_frames', 'actionir_ast_constructions', 'actionir_ast_parser', 'actionir_source_emissions',
        'canonical_event_occurrence_order', 'actionir_nested_block_source_spans',
        'actionir_compiler_source_membership', 'actionir_executable_source_membership',
        'trace_actionir_method_lowering', 'trace_emit_context_bridge')]
    tests += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t']
    assert consumers['command'] == ['prove', '-v', '-Iperl'] + tests, 'complete direct consumer selection'
    identity(consumers['inputs'])
    assert toolbox['returncode'] == 0 and toolbox['unchanged'] and not channels(toolbox)[1], 'actual Toolbox channels'
    identity(toolbox['inputs'])
    baseline = json.loads((ROOT / (PREVIOUS + 'actual.json')).read_text())
    expected = [{'id': row['id'], 'lowered': row['lowered']} for row in json.loads(channels(baseline)[0])['cases'] if row['id'] != 'empty-slots']
    assert json.loads(channels(toolbox)[0]) == expected and len(expected) == 3, 'actual unchanged Toolbox oracle'
    assert empty['cases'] == [{'source': s, 'base': 7} for s in ('', '  ', '\r\n', ' \r\n\t\u2003')], 'authored empty case population'
    assert [row['name'] for row in empty['routes']] == ['live', 'original'], 'empty original/live routes'
    for route in empty['routes']:
        assert route['returncode'] == 0 and not channels(route)[1], 'actual empty probe channels'
        observed = json.loads(channels(route)[0])
        assert len(observed) == len(empty['cases']), 'complete empty observation'
        for wanted, row in zip(empty['cases'], observed):
            assert row['source'] == wanted['source'] and row['base'] == wanted['base'], 'actual empty input'
            point = wanted['base'] + len(wanted['source'])
            fixed = {'kind': 'raw_perl', 'reason': 'empty_expression', 'source': '', 'source_span': {'start': point, 'end': point}}
            assert row['corrected'] == fixed, 'narrow trim intervention corrects original empty interval'
            normal = copy.deepcopy(fixed)
            normal['source_span']['end'] = wanted['base']
            assert row['normal'] == normal, 'same original/live inverted empty interval'
            assert len(row['trims']) == 1 and row['trims'][0]['result'] == ['', point, wanted['base']], 'actual trim producer mechanism'
    return True

records = [read(s) for s in ('final', 'inverses', 'original', 'consumers', 'toolbox', 'empty')]
validate(*records)
final, inverses, original, consumers, toolbox, empty = records
paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs'], cwd=ROOT).decode().split('\0')
paths = {p for p in paths if p and (ROOT / p).is_file()}
assert set(final['inputs']) == paths | {TEST}
for p, h in original['inputs'].items():
    if p != TEST:
        assert digest(subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)) == h
        assert p == PARSER or final['inputs'][p] == h, 'only Parser production owner changed'
    else:
        assert h == final['inputs'][p], 'same independent fixture'
identity(empty['routes'][0]['inputs'])
for p, h in empty['routes'][1]['inputs'].items():
    raw = Path(__file__).parent.joinpath(Path(p).name).read_bytes() if p == PREFIX + 'empty-probe.py' else subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
    assert digest(raw) == h, 'immutable original empty input identity'
freeze = read('freeze')
for row in freeze['records']:
    raw = (ROOT / row['before']).read_bytes()
    assert digest(raw) == row['original_sha256']
    previous = json.loads(raw)
    for claim in previous['claims']:
        for entry in claim['durability']['inputs']:
            assert digest(subprocess.check_output(['git', 'show', BASE + ':' + entry['path']], cwd=ROOT)) == entry['sha256']
        claim['durability'].update(mode='historical', revision=BASE)
    assert previous == json.loads((ROOT / row['path']).read_text()), 'historical mode/revision only'

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
red('forged-final-input', 0, lambda r: r['inputs'].update({PARSER: '0' * 64}), 'actual input identity')
red('missing-inverse', 1, lambda r: r.pop(), 'complete inverse population')
red('forged-inverse-producer', 1, lambda r: r[0]['inputs'].update({PARSER: '0' * 64}), 'actual inverse producer identity')
red('failed-consumers', 3, lambda r: r.update(returncode=1), 'actual consumers PASS')
red('missing-consumer', 3, lambda r: r['command'].pop(), 'complete direct consumer selection')
red('forged-Toolbox-output', 4, lambda r: r.update(stdout_base64=base64.b64encode(b'[]').decode()), 'actual unchanged Toolbox oracle')
red('missing-original-empty-route', 5, lambda r: r['routes'].pop(), 'empty original/live routes')

# These are observed product REDs, not a claim that the probe command failed.
empty_red = []
for route in empty['routes']:
    for row in json.loads(channels(route)[0]):
        span = row['normal']['source_span']
        if span['end'] < span['start']:
            empty_red.append({'route': route['name'], 'source': row['source'], 'result': 'RED',
                              'reason': 'public empty source interval is inverted'})
assert len(empty_red) == 6
report = {'result': 'PASS', 'fixture_assertions': 63, 'source_inverses': 11, 'consumer_suites': 11,
          'toolbox_routes': 3, 'empty_product_reds': empty_red, 'evidence_red_controls': controls,
          'producer_sha256': digest(Path(__file__).read_bytes()),
          'records': {s: digest((ROOT / (PREFIX + s + '.json')).read_bytes()) for s in ('final', 'inverses', 'original', 'consumers', 'toolbox', 'empty', 'freeze')},
          'scope': 'Native parser-relative frames only; no compiler-event/source-copy grant. Existing whitespace-only public-span defect is independently observed and scheduled next as .2.1.2.4; no fix is claimed.'}
(ROOT / (PREFIX + 'review.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Native-frame review PASS:63 assertions/11 source inverses,11 consumers,3 Toolbox routes,8 evidence REDs;6 original/live product REDs owned next.')

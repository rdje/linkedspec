"""Review exact supplied inputs, TAP, semantic inverses and historical bindings."""
import base64
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PARSER = 'perl/LinkedSpec/ActionIR/AST/Parser.pm'
TEST = 't/actionir_ast_constructions.t'
BASE = 'f61130d731d9901005d3332e0fbadf5c96896e2a'
EXPECTED = {
 'no-constructor-record': 'actual root has independent construction description',
 'shifted-description': 'actual root has independent construction description',
 'copied-capture': 'copied capture denied', 'foreign-callback': 'foreign callback denied',
 'mutated-scalars': 'mutated constructed scalar denied',
 'replaced-descendant': 'equal replacement descendant denied',
 'no-root-validation': 'changed ancestor denies child lookup',
 'unreturned-record': 'unreturned construction denied',
 'copied-arguments': 'scalar argument alias preserved',
 'list-callback': 'parse callback scalar context preserved',
 'double-callback': 'exactly one callback invocation',
 'no-recorder-unwind': 'outer recorder restored after nested fatal capture',
 'no-scope-unwind': 'outer scope restored', 'shared-description': 'returned description is detached',
 'cyclic-snapshot-back-edge': 'snapshot graph released after original cycle is broken',
}

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def read(suffix):
    return json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())

def channels(row):
    return (base64.b64decode(row['stdout_base64']).decode(),
            base64.b64decode(row['stderr_base64']).decode())

def validate(final, inverses, original, consumers):
    out, error = channels(final)
    assert final['returncode'] == 0 and not error, 'actual final successful channels'
    assert len(re.findall(r'^ok \d+ - ', out, re.M)) == 77 and out.endswith('1..77\n') and '\nnot ok' not in out, 'complete final TAP'
    assert final['command'] == ['perl', '-Iperl', TEST], 'actual final command'
    for p, h in final['inputs'].items():
        assert digest((ROOT / p).read_bytes()) == h, 'actual final input identity'
    assert set(final['inputs']) == set(original['inputs']), 'same original supplied closure'
    assert original['returncode'] != 0 and 'private AST construction collector is available' in channels(original)[1], 'original availability RED'
    assert len(inverses) == len(EXPECTED) and {r['name'] for r in inverses} == set(EXPECTED), 'complete semantic inverse population'
    for row in inverses:
        assert row['source'] == PARSER and row['command'] == final['command'], 'actual inverse source/command'
        raw = (ROOT / PARSER).read_bytes()
        assert raw.count(row['old'].encode()) == 1, 'exact inverse intervention'
        changed = raw.replace(row['old'].encode(), row['new'].encode(), 1)
        wanted = dict(final['inputs'], **{PARSER: digest(changed)})
        assert row['inputs'] == wanted, 'actual inverse producer identity'
        output, error = channels(row)
        assert row['required_failure'] == EXPECTED[row['name']], 'named inverse oracle'
        assert row['returncode'] != 0 and re.search(r'^not ok \d+ - ' + re.escape(row['required_failure']) + r'$', output, re.M), 'observed semantic assertion RED'
        assert row['required_failure'] in error and 'syntax error' not in error and 'Compilation failed' not in error, 'semantic RED channels'
    output, error = channels(consumers)
    assert consumers['returncode'] == 0 and consumers['unchanged'] and 'Result: PASS' in output and not error, 'actual direct consumers PASS'
    expected_tests = ['t/' + name + '.t' for name in (
        'actionir_ast_constructions', 'actionir_ast_parser', 'actionir_source_emissions',
        'canonical_event_occurrence_order', 'actionir_nested_block_source_spans',
        'actionir_compiler_source_membership', 'actionir_executable_source_membership',
        'trace_actionir_method_lowering', 'trace_emit_context_bridge')]
    expected_tests += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t']
    assert consumers['command'] == ['prove', '-v', '-Iperl'] + expected_tests, 'complete direct consumer selection'
    for p, h in consumers['inputs'].items():
        assert digest((ROOT / p).read_bytes()) == h, 'actual direct consumer input identity'

final, inverses, original, consumers = (read(s) for s in ('final', 'inverses', 'original', 'consumers'))
validate(final, inverses, original, consumers)
paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs'], cwd=ROOT).decode().split('\0')
paths = {p for p in paths if p and (ROOT / p).is_file()}
assert set(final['inputs']) == paths | {TEST}
for p, h in original['inputs'].items():
    if p != TEST:
        assert digest(subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)) == h
        if p != PARSER:
            assert final['inputs'][p] == h, 'only Parser production owner changed'
    else:
        assert h == final['inputs'][p], 'unchanged independent fixture'
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

cycle = read('cycle')
assert cycle['returncode'] != 0 and re.search(r'^not ok 77 - snapshot graph released after original cycle is broken$', channels(cycle)[0], re.M)
expected_cycle = dict(original['inputs'], **{PARSER: digest((ROOT / (PREFIX + 'draft-parser.pm.txt')).read_bytes())})
assert cycle['inputs'] == expected_cycle, 'exact retained lifetime defect producer'
toolbox = read('toolbox')
assert toolbox['returncode'] == 0 and toolbox['unchanged'] and not channels(toolbox)[1]
for p, h in toolbox['inputs'].items():
    assert digest((ROOT / p).read_bytes()) == h, 'actual Toolbox input identity'
baseline = json.loads((ROOT / (PREFIX.replace('.1.1-', '.1.0-') + 'actual.json')).read_text())
expected_toolbox = [{'id': row['id'], 'lowered': row['lowered']}
                    for row in json.loads(base64.b64decode(baseline['stdout_base64']))['cases']
                    if row['id'] != 'empty-slots']
assert json.loads(channels(toolbox)[0]) == expected_toolbox and len(expected_toolbox) == 3, 'unchanged actual Toolbox lowering'
assert (ROOT / (PREFIX + 'cycle-fixture.t')).read_bytes() == (ROOT / TEST).read_bytes()
assert (ROOT / (PREFIX + 'cycle-red.stdout')).read_bytes() == base64.b64decode(cycle['stdout_base64'])
assert (ROOT / (PREFIX + 'cycle-red.stderr')).read_bytes() == base64.b64decode(cycle['stderr_base64'])
assert int((ROOT / (PREFIX + 'cycle-red.exit')).read_text()) == cycle['returncode']

# The earlier74-assertion pass did not assess the newly found lifetime defect.
# Preserve and identify its actual producers instead of refreshing its hashes.
draft_final, draft_inverses, draft_original, draft_consumers, draft_review = (
    read('draft-' + s) for s in ('final', 'inverses', 'original', 'consumers', 'review'))
draft_parser_hash = digest((ROOT / (PREFIX + 'draft-parser.pm.txt')).read_bytes())
draft_fixture_hash = digest((ROOT / (PREFIX + 'draft-fixture.t')).read_bytes())
assert draft_final['inputs'] == dict(final['inputs'], **{PARSER: draft_parser_hash, TEST: draft_fixture_hash})
assert draft_final['returncode'] == 0 and channels(draft_final)[0].endswith('1..74\n') and not channels(draft_final)[1]
for row in draft_inverses:
    raw = (ROOT / (PREFIX + 'draft-parser.pm.txt')).read_bytes()
    assert raw.count(row['old'].encode()) == 1
    assert row['inputs'] == dict(draft_final['inputs'], **{PARSER: digest(raw.replace(row['old'].encode(), row['new'].encode(), 1))})
    assert row['returncode'] != 0 and EXPECTED[row['name']] in channels(row)[1]
assert len(draft_inverses) == 14
assert draft_consumers['inputs'] == dict(consumers['inputs'], **{
    PARSER: draft_parser_hash, TEST: draft_fixture_hash,
    PREFIX + 'proof.py': digest((ROOT / (PREFIX + 'draft-proof.py.txt')).read_bytes())})
assert draft_review['producer_sha256'] == digest((ROOT / (PREFIX + 'draft-review.py.txt')).read_bytes())
for suffix, h in draft_review['record_hashes'].items():
    path = PREFIX + ('freeze.json' if suffix == 'freeze' else 'draft-' + suffix + '.json')
    assert digest((ROOT / path).read_bytes()) == h

controls = []
def red(name, index, mutate, reason):
    records = copy.deepcopy([final, inverses, original, consumers])
    mutate(records[index])
    try:
        validate(*records)
    except AssertionError as exc:
        assert str(exc) == reason, (name, str(exc))
        controls.append({'name': name, 'reason': str(exc), 'result': 'RED'})
        return
    raise AssertionError('ineffective evidence control: ' + name)

red('failed-final', 0, lambda r: r.update(returncode=1), 'actual final successful channels')
red('forged-final-input', 0, lambda r: r['inputs'].update({PARSER: '0' * 64}), 'actual final input identity')
red('truncated-final', 0, lambda r: r.update(stdout_base64=base64.b64encode(b'ok 1 - fake\n1..1\n').decode()), 'complete final TAP')
red('missing-inverse', 1, lambda r: r.pop(), 'complete semantic inverse population')
red('forged-inverse-source', 1, lambda r: r[0]['inputs'].update({PARSER: '0' * 64}), 'actual inverse producer identity')
red('renamed-inverse-reason', 1, lambda r: r[0].update(required_failure='other failure'), 'named inverse oracle')
red('failed-consumers', 3, lambda r: r.update(returncode=1), 'actual direct consumers PASS')
red('missing-consumer', 3, lambda r: r['command'].pop(), 'complete direct consumer selection')
report = {'result': 'PASS', 'fixture_assertions': 77, 'semantic_source_inverses': len(inverses),
          'consumer_suites': 10, 'evidence_red_controls': controls,
          'public_toolbox_routes': 3,
          'producer_sha256': digest(Path(__file__).read_bytes()),
          'record_hashes': {s: digest((ROOT / (PREFIX + s + '.json')).read_bytes()) for s in ('final', 'inverses', 'original', 'cycle', 'consumers', 'toolbox', 'freeze')},
          'scope': 'Standalone constructor descriptions only; original availability RED is not semantic. Actual lifetime-defect RED and fifteen source inverses distinguish semantics. Original-source joining and producer integration remain open.'}
(ROOT / (PREFIX + 'review.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Constructor review PASS: 77 assertions, 15 source inverses, 10 consumer suites, 8 evidence REDs.')

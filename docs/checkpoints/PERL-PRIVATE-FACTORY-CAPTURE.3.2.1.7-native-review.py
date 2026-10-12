"""Readonly whole-population formal trim review; --capture writes once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'b1133da422bbf19b54818c97c2b67a5e6a402012'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_formal_trim_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
assert sys.argv[1:] in ([], ['--capture'])
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 240
observations = {}
for mode in ('before', 'before-recheck', 'after'):
    record = load(PREFIX + mode + '-native.json')
    expected = dict(seed['inputs'])
    expected[PROBE] = sha((ROOT / PROBE).read_bytes())
    if mode == 'after':
        expected[MODULE] = sha((ROOT / MODULE).read_bytes())
    producer = 'observe-recheck.py' if mode == 'before-recheck' else 'observe.py'
    assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + producer)).read_bytes())
    assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
    assert record['inputs'] == expected and len(expected) == 241
    assert set(record['modes']) == set(expected)
    assert all(value in (0o640, 0o644, 0o750, 0o755) for value in record['modes'].values())
    assert [row['surface'] for row in record['rows']] == ['observe', 'cold-observe']
    assert load(PREFIX + mode + '-reached.json') == {
        'inputs': record['inputs'], 'modes': record['modes'], 'rows': record['rows']}
    for row in record['rows']:
        surface = row['surface']
        assert row['command'] == ['perl', '-Iperl', './' + PROBE, surface]
        assert row['returncode'] == 0 and not decode(row['stderr_base64'])
        payload = json.loads(decode(row['stdout_base64']))
        assert payload['mode'] == surface and payload['loaded_before'] == 0
        assert payload['loaded_after'] == (1 if surface == 'observe' else 0)
        groups = ('callbacks', 'branches', 'authority', 'symbolic')
        assert [len(payload[group]) for group in groups] == ([52, 54, 40, 84] if surface == 'observe' else [24, 0, 0, 44])
        for group in groups:
            ids = [item['id'] for item in payload[group]]
            assert len(ids) == len(set(ids)), 'no duplicate native members'
        observations[mode, surface] = payload
    assert record['modes'] == load(PREFIX + 'before-native.json')['modes']
first = load(PREFIX + 'before-native.json')
recurrence = load(PREFIX + 'before-recheck-native.json')
assert recurrence['first_native_sha256'] == sha((ROOT / (PREFIX + 'before-native.json')).read_bytes())
assert recurrence['first_producer_sha256'] == first['producer_sha256']
assert first['rows'] == recurrence['rows'], 'complete unchanged-source recurrence bytes'
before = observations['before', 'observe']
after = observations['after', 'observe']
expected = copy.deepcopy(before)
for row in expected['authority']:
    if row['id'].split('/')[-2] not in ('bound', 'bound-registered'):
        row['eligible'] = [int(row['id'].endswith('/known-1'))] * len(row['eligible'])
    row['parent_packet'] = 0
for row in expected['symbolic']:
    if row['id'].endswith(('/known-0', '/known-1')):
        row['eligible'] = [0] * len(row['eligible'])
        row['parent_packet'] = 0
assert after == expected, 'complete native population / sole authority changes'
assert observations['before', 'cold-observe'] == observations['after', 'cold-observe']
changed = {group: [a['id'] for a, b in zip(before[group], after[group]) if a != b] for group in groups}
assert {group: len(ids) for group, ids in changed.items()} == {'callbacks': 0, 'branches': 0, 'authority': 20, 'symbolic': 32}
callbacks = {row['id']: row for row in before['callbacks']}
branches = {row['id']: row for row in before['branches']}
for target in ('brace/site-1', 'dot/site-1', 'dot/site-2', 'dot/site-3'):
    effect = callbacks[target + '/effect']
    assert effect['trace'][0]['expr_slot'] == 1 and effect['trace'][0]['caller_slot'] == 0
    assert all(item['context'] == 'scalar' for item in branches[target + '/context-list']['trace'])
    assert all(item['context'] == 'scalar' for item in branches[target + '/context-void']['trace'])
    replacement = branches[target + '/caller-replacement']
    roles = [item['role'] for item in replacement['trace']]
    assert roles == (['selected', 'replacement'] if target.startswith('brace') else ['selected'] * 3 + ['replacement'] * 3)
for outcome in ('undefined', 'empty'):
    assert len(callbacks['dot/site-2/' + outcome]['trace']) == 3
    assert callbacks['dot/site-2/' + outcome]['value'] is None
assert callbacks['dot/site-2/effect']['value'] == ['item', '.method()']
assert callbacks['dot/site-2/mutated']['value'] == ['item!', '.method()']
assert callbacks['dot/site-2/effect']['trace'][1]['pads_after']['$trimmed'] == 'item!.method()'
assert callbacks['dot/site-3/effect']['trace'][2]['pads_after']['$trimmed'] == 'item.method()!'
assert branches['dot/input-decimal']['value'] == ['1.25', 'round()']
outer_path = PREFIX + 'before-outer-completion.json'
outer = load(outer_path)
assert outer['actual_tool_session'] == 87948 and outer['actual_returncode'] == 0
assert outer['producer_sha256'] == first['producer_sha256']
assert outer['native_sha256'] == sha((ROOT / (PREFIX + 'before-native.json')).read_bytes())
assert decode(outer['merged_log_base64']) == b'Formal-trim before native commands retained: 241 inputs; 2 fresh processes\n'
paths = [SEED, MODULE, PROBE, PREFIX + 'observe.py', PREFIX + 'observe-recheck.py']
paths += [outer_path]
paths += [PREFIX + mode + tail for mode in ('before', 'before-recheck', 'after') for tail in ('-native.json', '-reached.json')]
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {path: sha((ROOT / path).read_bytes()) for path in paths},
    'loaded_rows': 230, 'cold_rows': 68, 'changed_complete_rows': 52, 'changed_ids': changed,
    'scope': 'Complete real brace/dot native helpers without stubs. Exact before recurrence and complete warm/cold channels. Four formal calls retain writable local expression and shared substr lvalues, snapshot selection, scalar context, parse order, callable forms, errors and nested isolation. Only child authority changes. No complete helper/private/parent/canonical admission.'}
target = ROOT / (PREFIX + 'native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot native review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'native-review.json') == report
print('Formal-trim native review PASS:230 loaded/68 cold;52 complete authority-row changes; exact recurrence')

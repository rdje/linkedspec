"""Readonly complete source/assignment native review; --capture writes once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'dd82f9cbced8311dca8ea8610282780e0c0adf3e'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-consumers-final.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_source_assignment_kind_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
assert sys.argv[1:] in ([], ['--capture'])
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 230
observations = {}
for mode in ('before', 'after'):
    record = load(PREFIX + mode + '-native.json')
    expected = dict(seed['inputs'])
    expected[PROBE] = sha((ROOT / PROBE).read_bytes())
    if mode == 'after':
        expected[MODULE] = sha((ROOT / MODULE).read_bytes())
    assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'observe.py')).read_bytes())
    assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
    assert record['inputs'] == expected and len(expected) == 231
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
        assert [len(payload[group]) for group in groups] == ([12, 88, 40, 16] if surface == 'observe' else [6, 0, 0, 0])
        for group in groups:
            ids = [item['id'] for item in payload[group]]
            assert len(ids) == len(set(ids)), 'no duplicate native members'
        observations[mode, surface] = payload
    if mode == 'after':
        assert record['modes'] == load(PREFIX + 'before-native.json')['modes']

before = observations['before', 'observe']
after = observations['after', 'observe']
expected = copy.deepcopy(before)
for row in expected['authority']:
    known_code = row['id'].endswith('/code/known-1') or row['id'].endswith('/tied-code/known-1')
    if row['eligible']:
        row['eligible'] = [int(known_code)]
    row['parent_packet'] = 0
assert after == expected, 'complete native population / sole authority changes'
assert observations['before', 'cold-observe'] == observations['after', 'cold-observe']
changed = sum(a != b for group in ('callbacks', 'branches', 'authority', 'symbolic')
              for a, b in zip(before[group], after[group]))
assert changed == 20
callbacks = {row['id']: row for row in before['callbacks']}
branches = {row['id']: row for row in before['branches']}
symbolic = {row['id']: row for row in before['symbolic']}
roles = lambda row: [item['role'] for item in row['trace'] if item['role'] in ('kind', 'replacement')]
assert roles(branches['read/replace-in-trim']) == ['kind']
assert roles(branches['assign/replace-in-trim']) == ['replacement']
reserved = 'undef true false descr STRING info minfo IMATCH IMATCH_LIST IMATCH_HASH IINDEX IPOS LMATCH LMATCH_LIST LMATCH_HASH LINDEX LSPOS CAPTURE'.split()
assert len(reserved) == 18
for name in reserved:
    row = branches['read/reserved-' + name]
    assert roles(row) == [] and row['value'] is None and row['error'] is None
    assert row['fetches'] == ['trim_action_ir_value', 'bare_symbol_kind', 'bare_symbol_kind']
for name in ('bare-target', 'wrapper-invalid', 'other-wrapper', 'colon'):
    assert 'bare_symbol_kind' not in branches['assign/' + name]['fetches']
for owner, line, caller in (('read', 6883, 'item'), ('assign', 7156, 'array(item)')):
    for variant in ('glob', 'undefined', 'array', 'hash', 'name-object'):
        assert symbolic[owner + '/tied-' + variant]['error'].endswith(f'MethodLowering.pm line {line}.\n')
    effect = callbacks[owner + '/effect']
    assert effect['caller_after'] == caller and effect['source_after'] == 'SOURCE'
    assert effect['written'] == 'item!' and effect['write_error'] is None and effect['unrelated'] == 1
    kind = [item for item in effect['trace'] if item['role'] == 'kind']
    assert len(kind) == 1 and kind[0]['context'] == 'scalar'
    assert kind[0]['readonly'] == kind[0]['caller_slot'] == kind[0]['source_slot'] == 0
assert callbacks['read/effect']['value'] == '[@item!]'
assert callbacks['assign/effect']['helpers'][-1]['target'] == 'item!'
paths = [SEED, MODULE, PROBE, PREFIX + 'observe.py']
paths += [PREFIX + mode + tail for mode in ('before', 'after') for tail in ('-native.json', '-reached.json')]
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {path: sha((ROOT / path).read_bytes()) for path in paths},
    'loaded_rows': 156, 'cold_rows': 6, 'changed_complete_rows': changed,
    'scope': 'Both real optional selections/calls with eager required acquisition, guards and extractors. Only downstream assignment value/tracked helpers are controls. All complete native rows, modes, aliases, errors, lookup timing and cold loading retained; known CODE eligibility survives without child-to-parent packet donation. No full-helper/private/canonical admission.'}
target = ROOT / (PREFIX + 'native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'native-review.json') == report
print('Source-assignment native review PASS:156 loaded/6 cold;20 complete authority-row changes')

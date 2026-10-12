"""Readonly whole-population predicate review; --capture writes once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '99f2939ac1d5e543bc2aa7f9c38b8166d5d510cc'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_tracking_predicate_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
assert sys.argv[1:] in ([], ['--capture'])
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 237
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
    assert record['inputs'] == expected and len(expected) == 238
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
        groups = ('callbacks', 'branches', 'authority')
        assert [len(payload[group]) for group in groups] == ([56, 152, 72] if surface == 'observe' else [16, 0, 0])
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
    if row['eligible']:
        row['eligible'] = [int(row['id'].endswith('/known-1'))]
    row['parent_packet'] = 0
assert after == expected, 'complete native population / sole authority changes'
assert observations['before', 'cold-observe'] == observations['after', 'cold-observe']
changed = [a['id'] for a, b in zip(before['authority'], after['authority']) if a != b]
callbacks = {row['id']: row for row in before['callbacks']}
branches = {row['id']: row for row in before['branches']}
for owner in ('receiver', 'nested'):
    role = 'receiver_mutation_target' if owner == 'receiver' else 'nested_write_target'
    for path in ('primary', 'consumer'):
        prefix = owner + '/' + path
        effect = callbacks[prefix + '/effect']
        assert effect['trace'][0]['helper_target_slot'] == 1
        assert effect['trace'][0]['caller_slot'] == 0
        assert effect['trace'][0]['helper_target_after'] == 'item!'
        assert effect['caller_after'] == 'item'
        assert branches[prefix + '/tied']['fetches'].count(role) == 1
        assert branches[prefix + '/target-newline']['fetches'] == []
        for case in ('replace-next', 'tied-switch', 'tied-replace-next'):
            assert [entry['role'] for entry in branches[prefix + '/' + case]['trace']] == ['selected', 'replacement']
        for case in ('qualified', 'unqualified', 'blessed-code'):
            assert branches[prefix + '/callback-' + case]['trace'] == []
        for outcome in ('bool-true', 'bool-false', 'bool-fatal'):
            assert callbacks[prefix + '/' + outcome]['boolean_calls'] == 1
        assert callbacks[prefix + '/bool-fatal']['error'] == {'type': 'TrackingPredicateProbe::Fatal', 'actual_fatal': 1}
        assert branches[prefix + '/context-list']['trace'][0]['context'] == 'scalar'
    assert callbacks[owner + '/primary/false-word']['value'] == 1
    assert callbacks[owner + '/primary/zero']['value'] == 0
    assert callbacks[owner + '/primary/array']['value'] == 1
assert callbacks['receiver/consumer/bool-false']['value'] == 'INNER'
assert callbacks['nested/consumer/bool-false']['value'] == '$item = INNER'
assert 'assert_receiver_writable' in callbacks['receiver/consumer/true']['value']
assert '$__ls_binding_presence' in callbacks['nested/consumer/true']['value']
paths = [SEED, MODULE, PROBE, PREFIX + 'observe.py', PREFIX + 'observe-recheck.py']
paths += [PREFIX + mode + tail for mode in ('before', 'before-recheck', 'after') for tail in ('-native.json', '-reached.json')]
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {path: sha((ROOT / path).read_bytes()) for path in paths},
    'loaded_rows': 280, 'cold_rows': 16, 'changed_complete_rows': len(changed), 'changed_ids': changed,
    'scope': 'Two actual predicates plus real receiver guard and scalar-assignment consumers, without secondary stubs. Complete native rows, exact recurrence bytes, target local-slot identity via readonly B, one map FETCH after validation, actual CODE selection, boolean1/0, aliases/effects/context/coercion/errors/fatal/cold preserved. Only child authority changes. No full-helper/private/parent/canonical admission.'}
target = ROOT / (PREFIX + 'native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot native review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'native-review.json') == report
print('Tracking-predicate native review PASS:280 loaded/16 cold;', len(changed), 'complete authority-row changes; exact recurrence')

"""Readonly whole-population named-dispatch review; --capture writes once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '22132b2b0eccb5ac38ef3c756f1b1e5b08992947'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_named_dispatch_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
assert sys.argv[1:] in ([], ['--capture'])
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 243
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
    assert record['inputs'] == expected and len(expected) == 244
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
        assert [len(payload[group]) for group in groups] == ([72, 53, 60] if surface == 'observe' else [18, 10, 0])
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
    row['eligible'] = [int(row['id'].endswith('/known-1'))] * len(row['eligible'])
    row['parent_packet'] = 0
assert after == expected, 'complete native population / sole authority changes'
assert observations['before', 'cold-observe'] == observations['after', 'cold-observe']
changed = {group: [a['id'] for a, b in zip(before[group], after[group]) if a != b] for group in groups}
assert {group: len(ids) for group, ids in changed.items()} == {'callbacks': 0, 'branches': 0, 'authority': 54}
callbacks = {row['id']: row for row in before['callbacks']}
branches = {row['id']: row for row in before['branches']}
assert before['names'] == ['_lower_scalar_assignment_operator_statement',
    '_lower_array_append_operator_statement', '_lower_array_end_mutation_method_statement',
    '_lower_hash_index_assignment_operator_statement', '_lower_set_key_statement', '_lower_push_statement']
for target in range(6):
    prefix = 'target-' + str(target) + '/'
    effect = callbacks[prefix + 'effect']
    assert effect['trace'][-1]['trimmed_slot'] == effect['trace'][-1]['deps_slot'] == 1
    assert effect['trace'][-1]['caller_input_slot'] == effect['trace'][-1]['caller_deps_slot'] == 0
    assert effect['caller_input'] == ' statement '
    assert [item['index'] for item in callbacks[prefix + 'string']['trace']] == list(range(target + 1))
    assert callbacks[prefix + 'zero']['value'] == '0'
    assert len(callbacks[prefix + 'empty']['trace']) == 6
    for context in ('list', 'void'):
        assert all(item['context'] == 'scalar' for item in branches[prefix + 'context-' + context]['trace'])
    for kind in ('array', 'hash', 'code', 'object'):
        assert callbacks[prefix + kind]['result_identity'][kind] == 1
assert [row['arguments'][0] for row in branches['target-0/mutate_trimmed']['trace']] == ['statement'] + ['statement!'] * 5
assert branches['target-0/mutate_map']['original_map']['effects'] == 1
assert [row['original_map'] for row in branches['target-0/replace_deps']['trace']] == [1] + [0] * 5
assert branches['target-0/replace_deps']['caller_deps']['marker'] == 'original'
assert branches['target-0/replace_deps']['auxiliary'][-1]['arguments'][1]['marker'] == 'replacement'
for index in (0, 3, 5):
    row = branches['snapshot-replace-' + str(index)]
    assert [item['role'] for item in row['trace'] if item['invocation'] == 1] == ['selected'] * 6
    second = [item for item in row['trace'] if item['invocation'] == 2]
    assert second[-1]['index'] == index and second[-1]['role'] == 'replacement'
    assert row['names_restored'] == branches['snapshot-fatal-' + str(index)]['names_restored'] == [1] * 6
assert branches['ast-zero']['value'] == '0' and branches['ast-zero']['trace'] == []
assert [row['role'] for row in branches['set-fallback']['auxiliary']] == ['trim', 'ast', 'parse', 'normalize', 'assign']
outer_path = PREFIX + 'before-outer-completion.json'
outer = load(outer_path)
assert outer['actual_tool_session'] == 61054 and outer['actual_returncode'] == 0
assert outer['producer_sha256'] == first['producer_sha256']
assert outer['native_sha256'] == sha((ROOT / (PREFIX + 'before-native.json')).read_bytes())
assert decode(outer['merged_log_base64']) == b'Named-dispatch before native commands retained: 244 inputs; 2 fresh processes\n'
paths = [SEED, MODULE, PROBE, PREFIX + 'observe.py', PREFIX + 'observe-recheck.py']
paths += [outer_path]
paths += [PREFIX + mode + tail for mode in ('before', 'before-recheck', 'after') for tail in ('-native.json', '-reached.json')]
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {path: sha((ROOT / path).read_bytes()) for path in paths},
    'loaded_rows': 185, 'cold_rows': 28, 'changed_complete_rows': 54, 'changed_ids': changed,
    'scope': 'Real complete selected dispatch owner with six explicit localized CODE callbacks and secondary AST/assignment/component controls. Exact before recurrence and complete warm/cold channels. Native order/actual selected identities/snapshot replacement, writable local trimmed/deps slots, caller copies versus shared maps, first nonempty/reference/zero results, scalar context, guards/fallback/coercion/errors/fatal/localization/cold remain exact. Only child authority changes. No complete named helper/private/parent/canonical admission.'}
target = ROOT / (PREFIX + 'native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot native review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'native-review.json') == report
print('Named-dispatch native review PASS:185 loaded/28 cold;54 complete authority-row changes; exact recurrence')

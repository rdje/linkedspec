"""Readonly complete optional AST native review; --capture writes once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '15197dfdf0f198a4eb25517e278edba491d12db7'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_ast_optional_stable_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
assert sys.argv[1:] in ([], ['--capture'])
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 233
observations = {}
for mode in ('before', 'after'):
    record = load(PREFIX + mode + '-stable-native.json')
    expected = dict(seed['inputs'])
    expected[PROBE] = sha((ROOT / PROBE).read_bytes())
    expected['t/actionir_ast_optional_probe.pl'] = sha((ROOT / 't/actionir_ast_optional_probe.pl').read_bytes())
    if mode == 'after':
        expected[MODULE] = sha((ROOT / MODULE).read_bytes())
    assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'observe-stable.py')).read_bytes())
    assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
    assert record['inputs'] == expected and len(expected) == 235
    assert set(record['modes']) == set(expected)
    assert all(value in (0o640, 0o644, 0o750, 0o755) for value in record['modes'].values())
    assert [row['surface'] for row in record['rows']] == ['observe', 'cold-observe']
    assert load(PREFIX + mode + '-stable-reached.json') == {
        'inputs': record['inputs'], 'modes': record['modes'], 'rows': record['rows']}
    for row in record['rows']:
        surface = row['surface']
        assert row['command'] == ['perl', '-Iperl', './' + PROBE, surface]
        assert row['returncode'] == 0 and not decode(row['stderr_base64'])
        payload = json.loads(decode(row['stdout_base64']))
        assert payload['mode'] == surface and payload['loaded_before'] == 0
        assert payload['loaded_after'] == (1 if surface == 'observe' else 0)
        groups = ('callbacks', 'branches', 'authority', 'symbolic')
        assert [len(payload[group]) for group in groups] == ([12, 78, 42, 16] if surface == 'observe' else [6, 0, 0, 0])
        for group in groups:
            ids = [item['id'] for item in payload[group]]
            assert len(ids) == len(set(ids)), 'no duplicate native members'
        observations[mode, surface] = payload
    if mode == 'after':
        assert record['modes'] == load(PREFIX + 'before-stable-native.json')['modes']

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
assert changed == 16
callbacks = {row['id']: row for row in before['callbacks']}
branches = {row['id']: row for row in before['branches']}
symbolic = {row['id']: row for row in before['symbolic']}
selected = lambda row: [item for item in row['trace'] if item['role'] in ('selected', 'replacement', 'fallback')]
for owner in ('pipeline', 'assign'):
    assert [item['role'] for item in selected(branches[owner + '/replace-next-call'])] == ['selected', 'replacement']
    assert branches[owner + '/zero']['value'] == '0'
    for outcome in ('string', 'effect', 'undefined', 'fatal', 'reference', 'coercion-fatal'):
        for item in selected(callbacks[owner + '/' + outcome]):
            assert item['context'] == 'scalar'
assert branches['pipeline/tied']['fetches'] == ['lower_array_pipeline_expr']
assert branches['assign/tied']['fetches'] == ['normalize_method_args_with_optional_scope', 'trim_action_ir_value', 'lower_assign_statement', 'lower_assign_statement']
effect = selected(callbacks['pipeline/effect'])[0]
assert effect['slots'][0]['node_source'] == effect['slots'][1]['node_span'] == effect['actual_span'] == 1
assert callbacks['pipeline/effect']['node_after']['source'] == 'SOURCE!'
assert callbacks['pipeline/effect']['span_after']['touch'] == 1
assert branches['pipeline/replace-span-slot']['node_after']['source_span'] == {'start': 20, 'end': 30}
assert callbacks['assign/effect']['args_after'] == ['item!', 'VALUE!']
assert branches['assign/separate-effective']['args_after'] == ['item', 'VALUE']
assert branches['assign/separate-effective']['effective_after'] == ['other!', 'PAYLOAD!']
effect = selected(branches['assign/separate-effective'])[0]
assert effect['slots'][0]['effective_arg0'] == effect['slots'][1]['effective_arg1'] == 1
assert effect['slots'][0]['raw_arg0'] == effect['slots'][1]['raw_arg1'] == 0
assert [item['role'] for item in selected(branches['assign/replace-in-normalize'])] == ['replacement']
assert selected(branches['assign/missing'])[0]['actual_map'] == 1
for variant in ('glob', 'undefined', 'array', 'hash', 'name-object'):
    assert symbolic['assign/tied-' + variant]['error'].endswith('MethodLowering.pm line 2170.\n')
    assert symbolic['pipeline/tied-' + variant]['error'] is None
    assert selected(symbolic['pipeline/tied-' + variant]) == []
iterator = load(PREFIX + 'iterator-review.json')
assert iterator['result'] == 'PASS'
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in iterator['inputs'].items())
paths = [SEED, MODULE, PROBE, 't/actionir_ast_optional_probe.pl', PREFIX + 'observe-stable.py', PREFIX + 'iterator-review.py', PREFIX + 'iterator-review.json']
paths += [PREFIX + mode + tail for mode in ('before', 'after') for tail in ('-stable-native.json', '-stable-reached.json')]
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {path: sha((ROOT / path).read_bytes()) for path in paths},
    'loaded_rows': 148, 'cold_rows': 6, 'changed_complete_rows': changed,
    'scope': 'Both real optional AST selections/calls, pipeline single-read CODE guard/source/span aliases and assignment required acquisition/normalization/two map reads/effective ARRAY aliases/local fallback thunk. Secondary helper bodies are controls. Complete native rows/modes/errors/context/coercion/guard/result/fatal/cold behavior retained, with16 complete authority-row changes. Original unordered iterator inputs/observations remain exact; distinct stable input was observed twice before authored assertions/production edits. No full-helper/private/canonical admission.'}
target = ROOT / (PREFIX + 'native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'native-review.json') == report
print('AST optional native review PASS:148 loaded/6 cold;16 complete authority-row changes')

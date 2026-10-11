"""Readonly diagnosis of first iterator variability and its distinct stable input."""
import base64
import hashlib
import json
import subprocess
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '15197dfdf0f198a4eb25517e278edba491d12db7'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
FIRST = 't/actionir_ast_optional_probe.pl'
STABLE = 't/actionir_ast_optional_stable_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
load = lambda path: json.loads((ROOT / path).read_bytes())
assert sys.argv[1:] in ([], ['--capture'])
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] and len(seed['inputs']) == 233
assert seed['inputs'][MODULE] == sha(old(MODULE))
original_probe = (ROOT / FIRST).read_bytes()
before_iterator = b' sub FIRSTKEY { my $reset = keys %{$_[0]{storage}}; each %{$_[0]{storage}} }\n sub NEXTKEY { each %{$_[0]{storage}} }'
stable_iterator = b' sub FIRSTKEY { $_[0]{iteration} = [sort keys %{$_[0]{storage}}]; shift @{$_[0]{iteration}} }\n sub NEXTKEY { shift @{$_[0]{iteration}} }'
assert original_probe.count(before_iterator) == 1
assert (ROOT / STABLE).read_bytes() == original_probe.replace(before_iterator, stable_iterator), 'sole two iterator bodies change'
definitions = [
    ('first', 'before-native.json', 'before-reached.json', 'observe.py', FIRST, 'before'),
    ('recheck', 'before-recheck-native.json', 'before-recheck-reached.json', 'observe-recheck.py', FIRST, 'before'),
    ('stable', 'before-stable-native.json', 'before-stable-reached.json', 'observe-stable.py', STABLE, 'before'),
    ('stable-recheck', 'before-recheck-stable-native.json', 'before-recheck-stable-reached.json', 'observe-stable.py', STABLE, 'before-recheck'),
]
payloads, channels, metadata = {}, {}, {}
paths = {SEED, FIRST, STABLE, PREFIX + 'iterator-review.py'}
for label, tail, reached_tail, producer, probe, mode in definitions:
    record = load(PREFIX + tail)
    expected = dict(seed['inputs'])
    expected[FIRST] = sha(original_probe)
    if probe == STABLE:
        expected[STABLE] = sha((ROOT / STABLE).read_bytes())
    assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + producer)).read_bytes())
    assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
    assert record['inputs'] == expected and len(expected) == (235 if probe == STABLE else 234)
    assert set(record['modes']) == set(expected)
    assert all(value in (0o640, 0o644, 0o750, 0o755) for value in record['modes'].values())
    assert load(PREFIX + reached_tail) == {'inputs': expected, 'modes': record['modes'], 'rows': record['rows']}
    assert [row['surface'] for row in record['rows']] == ['observe', 'cold-observe']
    for row in record['rows']:
        surface = row['surface']
        assert row['command'] == ['perl', '-Iperl', './' + probe, surface]
        assert row['returncode'] == 0 and not decode(row['stderr_base64'])
        raw = decode(row['stdout_base64'])
        payload = json.loads(raw)
        assert payload['mode'] == surface and payload['loaded_before'] == 0
        assert payload['loaded_after'] == (1 if surface == 'observe' else 0)
        assert [len(payload[group]) for group in ('callbacks', 'branches', 'authority', 'symbolic')] == ([12, 78, 42, 16] if surface == 'observe' else [6, 0, 0, 0])
        payloads[label, surface] = payload
        channels[label, surface] = raw
    metadata[label] = record
    paths.update(PREFIX + item for item in (tail, reached_tail, producer))
assert metadata['first']['inputs'] == metadata['recheck']['inputs']
assert metadata['first']['modes'] == metadata['recheck']['modes']
assert metadata['stable']['inputs'] == metadata['stable-recheck']['inputs']
assert metadata['stable']['modes'] == metadata['stable-recheck']['modes']

def compare(left, right):
    changes = []
    for surface in ('observe', 'cold-observe'):
        first, second = payloads[left, surface], payloads[right, surface]
        groups = ('callbacks', 'branches', 'authority', 'symbolic')
        assert {key: value for key, value in first.items() if key not in groups} == {key: value for key, value in second.items() if key not in groups}
        for group in groups:
            assert [row['id'] for row in first[group]] == [row['id'] for row in second[group]]
            for before, after in zip(first[group], second[group]):
                if before == after:
                    continue
                fields = [key for key in before if before[key] != after[key]]
                assert surface == 'observe' and before['owner'] == 'pipeline' and fields == ['fetches'], 'sole native clone FETCH-order variability'
                assert Counter(before['fetches']) == Counter(after['fetches'])
                assert before['fetches'][0] == after['fetches'][0] == 'lower_array_pipeline_expr'
                changes.append({'group': group, 'id': before['id'], 'changed_fields': fields,
                    'before_fetches': before['fetches'], 'after_fetches': after['fetches']})
    return changes

first_changes = compare('first', 'recheck')
assert len(first_changes) == 24, 'actual same-source distinguishing variability'
stable_changes = compare('first', 'stable')
assert stable_changes
assert compare('stable', 'stable-recheck') == []
assert all(channels['stable', surface] == channels['stable-recheck', surface] for surface in ('observe', 'cold-observe')), 'byte-exact complete stable recurrence'
ordered_clone = ['lower_array_pipeline_expr'] + sorted(['lower_array_pipeline_expr', 'normalize_method_args_with_optional_scope', 'trim_action_ir_value', 'unrelated'])
clone_rows = []
for group in ('callbacks', 'branches', 'authority', 'symbolic'):
    for row in payloads['stable', 'observe'][group]:
        if row['owner'] == 'pipeline' and len(row['fetches']) == 5:
            assert row['fetches'] == ordered_clone, 'explicit stable tied clone iteration'
            clone_rows.append(row['id'])
assert len(clone_rows) == 26
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)},
    'source_revision': BASE, 'original_module_sha256': sha(old(MODULE)),
    'first_native_inputs': 234, 'stable_native_inputs': 235,
    'loaded_rows': 148, 'cold_rows': 6, 'original_same_source_changes': first_changes,
    'first_to_stable_order_changes': stable_changes, 'stable_clone_rows': clone_rows,
    'stable_recheck_exact_stdout': True,
    'scope': 'First full native producer/observations stay immutable. Two fresh original-source captures vary in24 complete rows solely through tied diagnostic storage-hash clone iteration, with equal FETCH multisets and every other field exact. A distinct input changes only FIRSTKEY/NEXTKEY to sorted iteration. Stable148 loaded/six cold populations recur byte-for-byte twice on unchanged accepted production before assertions/source edits; first-vs-stable differs only in clone FETCH order. All26 stable clone rows have the explicit order. This repairs the proof fixture, not production behavior or an earlier native observation. Original runtime inputs are recoverable from acceptedBASE and the full supplied seed; no full-helper/private/parent/canonical admission.'}
target = ROOT / (PREFIX + 'iterator-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot iterator diagnosis capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'iterator-review.json') == report
print('AST iterator review PASS: original24 order-only changes; stable148/6 byte-exact recurrence;26 ordered clone rows')

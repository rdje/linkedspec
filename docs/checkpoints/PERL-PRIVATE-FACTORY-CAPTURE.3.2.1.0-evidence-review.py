"""Read-only review of originals, controls, preservation and instrument repair."""
import base64
import copy
import importlib.util
import json
import hashlib
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-'
BASE = '91e972cfa0d214784b0172828f7baa378c25f23e'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)


def load(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


def call(tail):
    actual = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert actual.returncode == 0 and not actual.stderr, ('readonly proof', tail, actual.stderr)


call('review.py')
call('book-review.py')
before_raw = (ROOT / (PREFIX + 'before-package-flow.json')).read_bytes()
assert before_raw == old(CLAIM) and len(before_raw) == 120239, 'original full publication'
before = json.loads(before_raw)
expected = copy.deepcopy(before)
live = [row for row in expected['claims'] if row['durability']['mode'] == 'live']
assert len(expected['claims']) == 3 and len(live) == 1 and len(live[0]['durability']['inputs']) == 355
live[0]['durability'].update(mode='historical', revision=BASE)
assert (ROOT / CLAIM).read_bytes() == (json.dumps(expected, indent=2) + '\n').encode(), 'sole original mode/revision change'
for entry in before['claims'][0]['durability']['inputs']:
    assert sha(old(entry['path'])) == entry['sha256'], 'original355 binding identity'
assert sum(len(row['durability']['inputs']) for row in before['claims'][1:]) == 172
freeze = load('freeze.json')
assert freeze['original_sha256'] == sha(before_raw) and freeze['after_sha256'] == sha((ROOT / CLAIM).read_bytes())
assert freeze['producer_sha256'] == sha((ROOT / (PREFIX + 'freeze.py')).read_bytes())
baseline = load('baseline.json')
assert baseline['producer_sha256'] == freeze['producer_sha256'] and baseline['returncode'] == 0
assert not base64.b64decode(baseline['stderr_base64']) and b'PASS' in base64.b64decode(baseline['stdout_base64'])
assert baseline['command'] == ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-publish-claim.py']
gap = load('gap.json')
actual_gap = json.loads(base64.b64decode(gap['stdout_base64']))
expected_gap = {'rows': [{'known': known, 'value': 'do { LOWERED; undef }', 'eligible': [1],
    'actual_map_identity': 1, 'parent_packet': 1,
    'calls': [{'args': ['call(value)'], 'context': 'scalar'}]} for known in (0, 1)]}
assert actual_gap == expected_gap, 'original inline-required diagnosis rows'

controls = load('controls.json')
assert controls['result'] == 'PASS' and len(controls['rows']) == 6
for key, tail in (('producer_sha256', 'controls.py'), ('oracle_sha256', 'control-oracle.py'), ('review_sha256', 'review.py')):
    assert controls[key] == sha((ROOT / (PREFIX + tail)).read_bytes())
mutations = {
    'omitted-direct-call': (b"(($deps->{bare_symbol_kind}->($name) // '') eq 'scalar')", b"((undef // '') eq 'scalar')"),
    'added-formal-call': (b'my ($expr, $trim_action_ir_value) = @_;', b'my ($expr, $trim_action_ir_value) = @_; $trim_action_ir_value->($expr);'),
    'unbound-required-resolver': (b'return _bind_emission_dependency($cb);', b'return $cb;'),
}
source = old(MODULE)
healthy_inventory = load('inventory.json')
seed = json.loads(old('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-consumers-final.json'))
assert len(seed['inputs']) == 211
for p, digest in seed['inputs'].items():
    assert sha((ROOT / p).read_bytes()) == digest and sha(old(p)) == digest, 'unchanged accepted runtime population'
for row in controls['rows']:
    raw = (ROOT / row['artifact']).read_bytes()
    assert sha(raw) == row['artifact_sha256']
    artifact = json.loads(raw)
    mutated = base64.b64decode(artifact['source_base64'])
    if row['name'] in mutations:
        first, second = mutations[row['name']]
        assert mutated == source.replace(first, second, 1), 'exact full-source counterfactual'
        assert artifact['replacement'] == {'old_base64': base64.b64encode(first).decode(), 'new_base64': base64.b64encode(second).decode()}
        inputs = dict(seed['inputs'])
        inputs[MODULE] = sha(mutated)
        for label in ('native', 'optree'):
            p = PREFIX + label + '-probe.pl'
            inputs[p] = sha((ROOT / p).read_bytes())
            command = artifact[label]
            assert command['command'] == ['perl', '-Iperl', './' + p, 'observe']
            assert command['returncode'] == 0 and not base64.b64decode(command['stderr_base64'])
            assert json.loads(base64.b64decode(command['stdout_base64']))
        assert artifact['inputs'] == inputs and len(inputs) == 213 and artifact['unchanged']
        assert artifact['syntax']['command'] == ['perl', '-Iperl', '-c', MODULE]
        assert artifact['syntax']['returncode'] == 0 and b'syntax OK' in base64.b64decode(artifact['syntax']['stderr_base64'])
        assert artifact['inventory'] == healthy_inventory
    else:
        assert mutated == source
        expected_inventory = copy.deepcopy(healthy_inventory)
        if row['name'] == 'omitted-member':
            expected_inventory['calls'].pop()
        elif row['name'] == 'shadow-binding-conflation':
            next(r for r in expected_inventory['calls'] if r['line'] == 3850)['binding'] = '_lower_method_value_expr:pad:44'
        else:
            assert row['name'] == 'wrong-ingress-family'
            next(r for r in expected_inventory['calls'] if r['line'] == 2066)['class'] = 'remaining-optional-kind'
        assert artifact['inventory'] == expected_inventory, 'exact inventory counterfactual'
    denied = row['denied']
    assert denied['command'] == ['python3', PREFIX + 'control-oracle.py', row['artifact']]
    assert denied['returncode'] != 0 and row['expected_reason'].encode() in base64.b64decode(denied['stderr_base64'])
    repeated = subprocess.run(denied['command'], cwd=ROOT, capture_output=True)
    assert repeated.returncode != 0 and row['expected_reason'].encode() in repeated.stderr, 'actual semantic denial recurrence'
    restored = row['restored']
    assert restored['command'] == ['python3', PREFIX + 'review.py'] and restored['returncode'] == 0
    assert not base64.b64decode(restored['stderr_base64']) and b'PASS' in base64.b64decode(restored['stdout_base64'])

first = (ROOT / (PREFIX + 'review-first.py')).read_text()
current = (ROOT / (PREFIX + 'review.py')).read_text()
old_walk = """            node = call['tree']
            while node['op'] in ('entersub', 'null'):
                node = node['children'][-1]
            if node['op'] == 'rv2cv':
                node = node['children'][0]
"""
new_walk = """            node = call['tree']['children'][-1]
            while node['op'] in ('null', 'rv2cv'):
                node = node['children'][-1]
            if node['op'] == 'entersub':
                assert cv['id'] == '_lower_mutation_slot_value_expr' and call['line'] == 6951
                observed[(cv['id'], call['path'])] = (6951,
                    '_bind_emission_dependency($lower_flow_composite_expr)', None)
                kinds['entersub'] += 1
                continue
"""
assert first.count(old_walk) == 1
corrected = first.replace(old_walk, new_walk)
start = corrected.index('    # Recover returned CODE calls separately')
end = corrected.index('    expected_names =', start)
assert current == corrected[:start] + corrected[end:], 'sole returned-CODE reviewer correction'
failure = load('review-first-failure.json')
assert failure['producer_sha256'] == sha(first.encode()) and failure['returncode'] == 1
assert failure['channel'] == 'shell-merged-stdout-stderr'
assert b'AssertionError: dynamic invocation population' in base64.b64decode(failure['merged_base64'])
spec = importlib.util.spec_from_file_location('first_review', ROOT / (PREFIX + 'review-first.py'))
first_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(first_module)
try:
    first_module.audit(source.decode(), json.loads(base64.b64decode(load('native.json')['stdout_base64'])),
        json.loads(base64.b64decode(load('optree.json')['stdout_base64'])), healthy_inventory)
except AssertionError as error:
    assert str(error) == 'dynamic invocation population', 'original reviewer denial reason'
else:
    raise AssertionError('original reviewer must reproduce its actual failure')
print('Inventory evidence review PASS: exact native gap/211 unchanged runtime inputs/355 original bindings/six semantic REDs and reviewer correction')

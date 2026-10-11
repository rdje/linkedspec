"""Actual preservation controls. Default review is readonly; --capture is one-shot."""
import base64
import copy
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-'
spec = importlib.util.spec_from_file_location('capacity', ROOT / (PREFIX + 'capacity.py'))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
assert sys.argv[1:] in ([], ['--capture'])
FILES = [PREFIX + 'before-scalar.json', PREFIX + 'freeze.json', 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2.json']
original = {p: m.read(p) for p in FILES}

def mutations(name):
    changed = dict(original)
    freeze = json.loads(original[FILES[1]])
    if name == 'forged_original_scalar_binding':
        data = json.loads(original[FILES[0]])
        data['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
        changed[FILES[0]] = (json.dumps(data, indent=2) + '\n').encode()
        freeze['original_sha256'] = m.sha(changed[FILES[0]])
        reason = 'exact original scalar claim'
    else:
        assert name == 'forged_preserved_scalar_statement'
        data = json.loads(original[FILES[2]])
        data['claims'][0]['statement'] += ' altered'
        changed[FILES[2]] = (json.dumps(data, indent=2) + '\n').encode()
        freeze['after_sha256'] = m.sha(changed[FILES[2]])
        reason = 'scalar claim mode/revision-only preservation'
    changed[FILES[1]] = (json.dumps(freeze, indent=2) + '\n').encode()
    return changed, reason

args = ['python3', PREFIX + 'capacity.py', 'review']
target = ROOT / (PREFIX + 'preservation-controls.json')
reached = ROOT / (PREFIX + 'preservation-reached.json')
if sys.argv[1:]:
    assert not target.exists() and not reached.exists()
    healthy = m.command(args)
    rows = []
    m.save('preservation-reached.json', {'healthy': healthy, 'rows': rows})
    assert healthy['exit_code'] == 0
    try:
        for name in ('forged_original_scalar_binding', 'forged_preserved_scalar_statement'):
            changed, reason = mutations(name)
            for p, raw in changed.items(): (ROOT / p).write_bytes(raw)
            observed = m.command(args)
            rows.append({'name': name, 'reason': reason, 'inputs': {p: m.channel(raw) for p, raw in changed.items()}, 'observed': observed})
            m.save('preservation-reached.json', {'healthy': healthy, 'rows': rows})
            assert observed['exit_code'] != 0 and reason.encode() in base64.b64decode(observed['stderr']['base64'])
            for p, raw in original.items(): (ROOT / p).write_bytes(raw)
            restored = m.command(args)
            rows[-1]['restored'] = restored
            m.save('preservation-reached.json', {'healthy': healthy, 'rows': rows})
            assert restored == healthy
    finally:
        for p, raw in original.items(): (ROOT / p).write_bytes(raw)
    m.save('preservation-controls.json', {'healthy': healthy, 'rows': rows, 'producer_sha256': m.sha(Path(__file__).read_bytes()), 'original_inputs': {p: m.sha(raw) for p, raw in original.items()}})
data = json.loads(target.read_bytes())
assert data['producer_sha256'] == m.sha(Path(__file__).read_bytes())
assert data['original_inputs'] == {p: m.sha(raw) for p, raw in original.items()}
assert json.loads(reached.read_bytes()) == {k: data[k] for k in ('healthy', 'rows')}
assert data['healthy'] == m.command(args)
assert [row['name'] for row in data['rows']] == ['forged_original_scalar_binding', 'forged_preserved_scalar_statement']
for row in data['rows']:
    expected, reason = mutations(row['name'])
    assert row['reason'] == reason and row['inputs'] == {p: m.channel(raw) for p, raw in expected.items()}
    assert row['restored'] == data['healthy']
    result = row['observed']
    assert result['args'] == args and result['exit_code'] != 0 and reason.encode() in base64.b64decode(result['stderr']['base64'])
    for part in ('stdout', 'stderr'):
        assert m.channel(base64.b64decode(result[part]['base64'])) == result[part]
print('Scalar337 preservation review PASS; two actual beyond-immediate-hash REDs/each restored PASS')

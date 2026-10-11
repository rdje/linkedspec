"""Actual reviewer corruptions; default readonly, --capture is one-shot."""
import copy
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-'
spec = importlib.util.spec_from_file_location('capacity', ROOT / (PREFIX + 'capacity.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
assert sys.argv[1:] in ([], ['--capture'])
original = m.read(PREFIX + 'plan.json')
names = ['missing_history_member', 'missing_engineering_member', 'forged_original_hash', 'forged_resulting_hash']
args = ['python3', PREFIX + 'capacity.py', 'review']

def mutant(name):
    data = json.loads(original)
    if name in ('missing_history_member', 'missing_engineering_member'):
        path = next(p for p in data['preserved'] if name != 'missing_engineering_member'
                    or p.startswith('docs/history/development-notes/'))
        del data['preserved'][path]
        reason = 'complete prior immutable population'
    elif name == 'forged_original_hash':
        data['preserved'][next(iter(data['preserved']))] = '0' * 64
        reason = 'original immutable identity'
    else:
        data['resulting_inputs'][m.REG] = '0' * 64
        reason = 'resulting input identities'
    return (json.dumps(data, indent=2) + '\n').encode(), reason

if sys.argv[1:]:
    assert not (ROOT / (PREFIX + 'evidence.json')).exists()
    assert not (ROOT / (PREFIX + 'evidence-reached.json')).exists()
    healthy = m.command(args)
    rows = []
    m.save('evidence-reached.json', {'healthy': healthy, 'rows': rows})
    assert healthy['exit_code'] == 0
    try:
        for name in names:
            raw, reason = mutant(name)
            (ROOT / (PREFIX + 'plan.json')).write_bytes(raw)
            observed = m.command(args)
            rows.append({'name': name, 'reason': reason, 'mutant': m.channel(raw), 'observed': observed})
            m.save('evidence-reached.json', {'healthy': healthy, 'rows': rows})
            assert observed['exit_code'] != 0 and reason.encode() in m.base64.b64decode(observed['stderr']['base64']), name
            (ROOT / (PREFIX + 'plan.json')).write_bytes(original)
            rows[-1]['restored'] = m.command(args)
            m.save('evidence-reached.json', {'healthy': healthy, 'rows': rows})
            assert rows[-1]['restored'] == healthy
    finally:
        (ROOT / (PREFIX + 'plan.json')).write_bytes(original)
    m.save('evidence.json', {'producer_sha256': m.sha(Path(__file__).read_bytes()),
        'plan_sha256': m.sha(original), 'healthy': healthy, 'rows': rows})
data = m.load('evidence.json')
assert data['producer_sha256'] == m.sha(Path(__file__).read_bytes())
assert data['plan_sha256'] == m.sha(original)
assert m.load('evidence-reached.json') == {k: data[k] for k in ('healthy', 'rows')}
assert data['healthy'] == m.command(args) and data['healthy']['exit_code'] == 0
assert [r['name'] for r in data['rows']] == names
for row in data['rows']:
    raw, reason = mutant(row['name'])
    assert row['reason'] == reason and row['mutant'] == m.channel(raw)
    assert row['restored'] == data['healthy']
    result = row['observed']
    assert result['args'] == args and result['exit_code'] != 0
    assert reason.encode() in m.base64.b64decode(result['stderr']['base64'])
    for key in ('stdout', 'stderr'):
        assert m.channel(m.base64.b64decode(result[key]['base64'])) == result[key]
print('Reviewer evidence PASS: four actual named REDs including omitted engineering archive; each restored')

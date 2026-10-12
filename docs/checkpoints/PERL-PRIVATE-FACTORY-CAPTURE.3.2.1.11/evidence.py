"""Actual semantic corruption/restoration controls for the final readonly reader."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/'
TARGET = ROOT / (PREFIX + 'evidence.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
command = ['python3', PREFIX + 'review.py']
registration_path = PREFIX + 'registration-final.json'
current_path = PREFIX + 'current.json'
card_path = json.loads((ROOT / current_path).read_bytes())['changed_cards'][0]
paths = (registration_path, current_path, card_path)
original = {p: (ROOT / p).read_bytes() for p in paths}

def invoke():
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'returncode': process.returncode, 'stdout_base64': base64.b64encode(process.stdout).decode(),
        'stderr_base64': base64.b64encode(process.stderr).decode()}

if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot semantic controls'
    good = invoke()
    assert good['returncode'] == 0 and not base64.b64decode(good['stderr_base64'])
    rows = []
    for name, reason in [('forged-registration-denial', b'registration semantic denial'),
                         ('orphan-current-header-rehashed', b'final current header association')]:
        try:
            if name == 'forged-registration-denial':
                data = json.loads(original[registration_path])
                data['controls'][0]['reason'] = 'forged accepted registration'
                (ROOT / registration_path).write_text(json.dumps(data, indent=2) + '\n')
            else:
                raw = original[card_path]
                end = raw.index(b'\n---\n', 4)
                raw = raw[:end] + b'\n  - "forged detached item"' + raw[end:]
                (ROOT / card_path).write_bytes(raw)
                data = json.loads(original[current_path])
                data['inputs'][card_path] = sha(raw)
                (ROOT / current_path).write_text(json.dumps(data, indent=2) + '\n')
            result = invoke()
            assert result['returncode'] != 0 and reason in base64.b64decode(result['stderr_base64']), (name, result)
            mutations = {p: base64.b64encode((ROOT / p).read_bytes()).decode() for p in paths if (ROOT / p).read_bytes() != original[p]}
            rows.append({'name': name, 'expected_reason': reason.decode(), 'mutated_bytes': mutations, **result})
        finally:
            for p, raw in original.items():
                (ROOT / p).write_bytes(raw)
        restored = invoke()
        assert restored == good
        rows[-1]['restoration'] = restored
    inputs = {p: sha((ROOT / p).read_bytes()) for p in (*paths, PREFIX + 'review.py', PREFIX + 'review.json', PREFIX + 'evidence.py')}
    TARGET.write_text(json.dumps({'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
        'command': command, 'baseline': good, 'rows': rows, 'inputs': inputs}, indent=2) + '\n')
else:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert [r['name'] for r in report['rows']] == ['forged-registration-denial', 'orphan-current-header-rehashed']
    assert report['baseline']['returncode'] == 0 and not base64.b64decode(report['baseline']['stderr_base64'])
    for row in report['rows']:
        assert row['returncode'] != 0 and row['expected_reason'].encode() in base64.b64decode(row['stderr_base64'])
        assert row['restoration'] == report['baseline'] and row['mutated_bytes']
    assert all(sha((ROOT / p).read_bytes()) == value for p, value in report['inputs'].items())
print('Final semantic evidence PASS: two reason-sensitive denials; exact restoration')

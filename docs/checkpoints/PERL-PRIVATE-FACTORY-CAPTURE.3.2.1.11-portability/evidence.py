"""Exact decoded diagnostics and independently parsed current headers reject forgery."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/'
TARGET = ROOT / (PREFIX + 'evidence.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
command = ['python3', PREFIX + 'review.py']
diagnostic = OLD + 'document-first-failure.json'
current = PREFIX + 'current-final.json'
card = json.loads((ROOT / current).read_bytes())['changed_cards'][0]
paths = (diagnostic, current, card)
original = {p: (ROOT / p).read_bytes() for p in paths}
def invoke():
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'returncode': process.returncode, 'stdout_base64': base64.b64encode(process.stdout).decode(),
        'stderr_base64': base64.b64encode(process.stderr).decode()}
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot semantic controls'
    good = invoke()
    assert good['returncode'] == 0 and not base64.b64decode(good['stderr_base64']), good
    rows = []
    for name, reason in [('changed-diagnostic-byte', 'decoded diagnostic bytes changed'),
                         ('orphan-header-rehashed', 'orphan current header')]:
        try:
            if name == 'changed-diagnostic-byte':
                data = json.loads(original[diagnostic])
                data['log_base64'] = base64.b64encode(base64.b64decode(data['log_base64']) + b'!').decode()
                (ROOT / diagnostic).write_text(json.dumps(data, indent=2) + '\n')
            else:
                raw = original[card]
                end = raw.index(b'\n---\n', 4)
                raw = raw[:end] + b'\n  - "forged detached item"' + raw[end:]
                (ROOT / card).write_bytes(raw)
                data = json.loads(original[current])
                data['inputs'][card] = sha(raw)
                (ROOT / current).write_text(json.dumps(data, indent=2) + '\n')
            result = invoke()
            assert result['returncode'] != 0 and reason.encode() in base64.b64decode(result['stderr_base64']), (name, result)
            mutations = {p: base64.b64encode((ROOT / p).read_bytes()).decode() for p in paths if (ROOT / p).read_bytes() != original[p]}
            rows.append({'name': name, 'expected_reason': reason, 'mutated_bytes': mutations, **result})
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
    assert [r['name'] for r in report['rows']] == ['changed-diagnostic-byte', 'orphan-header-rehashed']
    assert report['baseline']['returncode'] == 0 and not base64.b64decode(report['baseline']['stderr_base64'])
    for row in report['rows']:
        assert row['returncode'] != 0 and row['expected_reason'].encode() in base64.b64decode(row['stderr_base64'])
        assert row['restoration'] == report['baseline'] and row['mutated_bytes']
    assert all(sha((ROOT / p).read_bytes()) == h for p, h in report['inputs'].items())
print('Portable semantic evidence PASS: two reason-sensitive denials; exact restoration')

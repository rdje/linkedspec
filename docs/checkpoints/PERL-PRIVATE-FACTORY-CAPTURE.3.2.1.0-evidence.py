"""Observe beyond-immediate-hash evidence denials and exact restoration once."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-'
TARGET = ROOT / (PREFIX + 'evidence.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert not TARGET.exists(), 'one-shot evidence controls'


def run():
    command = ['python3', PREFIX + 'evidence-review.py']
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    return {'command': command, 'returncode': result.returncode,
        'stdout_base64': base64.b64encode(result.stdout).decode(),
        'stderr_base64': base64.b64encode(result.stderr).decode()}


healthy = run()
assert healthy['returncode'] == 0 and not base64.b64decode(healthy['stderr_base64'])
rows = []
for label, reason in (('forged-original-beyond-freeze-sha', 'original full publication'),
                      ('false-native-diagnosis', 'original inline-required diagnosis rows')):
    tails = ('before-package-flow.json', 'freeze.json') if label.startswith('forged') else ('gap.json',)
    originals = {tail: (ROOT / (PREFIX + tail)).read_bytes() for tail in tails}
    changed = {tail: json.loads(raw) for tail, raw in originals.items()}
    if label.startswith('forged'):
        changed['before-package-flow.json']['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
        raw = (json.dumps(changed['before-package-flow.json'], indent=2) + '\n').encode()
        changed['freeze.json']['original_sha256'] = sha(raw)
    else:
        data = json.loads(base64.b64decode(changed['gap.json']['stdout_base64']))
        data['rows'][0]['parent_packet'] = 0
        changed['gap.json']['stdout_base64'] = base64.b64encode(json.dumps(data).encode()).decode()
    mutated = {tail: (json.dumps(value, indent=2) + '\n').encode() for tail, value in changed.items()}
    try:
        for tail, raw in mutated.items():
            (ROOT / (PREFIX + tail)).write_bytes(raw)
        denied = run()
    finally:
        for tail, raw in originals.items():
            (ROOT / (PREFIX + tail)).write_bytes(raw)
    restored = run()
    row = {'name': label, 'reason': reason, 'denied': denied, 'restored': restored,
        'original_sha256': {tail: sha(raw) for tail, raw in originals.items()},
        'mutated_base64': {tail: base64.b64encode(raw).decode() for tail, raw in mutated.items()}}
    rows.append(row)
    TARGET.write_text(json.dumps({'result': 'pending', 'healthy': healthy, 'rows': rows}, indent=2) + '\n')
    assert denied['returncode'] != 0 and reason.encode() in base64.b64decode(denied['stderr_base64'])
    assert restored['returncode'] == 0 and not base64.b64decode(restored['stderr_base64'])
report = {'result': 'PASS', 'healthy': healthy, 'rows': rows,
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'review_sha256': sha((ROOT / (PREFIX + 'evidence-review.py')).read_bytes())}
TARGET.write_text(json.dumps(report, indent=2) + '\n')
print('Inventory evidence controls PASS: forged original beyond updated freeze SHA and false native flag reject; two exact restored PASS')

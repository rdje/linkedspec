"""Retain the actual current callback publication before the unrelated maintenance claim."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.17-'
TARGET = ROOT / (PREFIX + 'review-baseline.json')
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json'
PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/publish.py'
sha = lambda value: hashlib.sha256(value).hexdigest()
assert not TARGET.exists() and not (ROOT / 'docs/claims/REPO-HYGIENE.17.json').exists()
claim_raw = (ROOT / CLAIM).read_bytes()
claims = json.loads(claim_raw)
inputs = {p: sha((ROOT / p).read_bytes()) for p in (CLAIM, PRODUCER)}
assert len(claims['claims'][0]['durability']['inputs']) == 456 and len(claim_raw) == 108786
for item in claims['claims'][0]['durability']['inputs']:
    assert sha((ROOT / item['path']).read_bytes()) == item['sha256']
command = ['bash', 'tools/run_python_project_data.sh', PRODUCER]
p = subprocess.run(command, cwd=ROOT, capture_output=True)
r = {'command': command, 'returncode': p.returncode, 'inputs': inputs,
     'producer_sha256': sha(Path(__file__).read_bytes()),
     'stdout_base64': base64.b64encode(p.stdout).decode(), 'stderr_base64': base64.b64encode(p.stderr).decode(),
     'unchanged': all(sha((ROOT / path).read_bytes()) == digest for path, digest in inputs.items()),
     'scope': 'Actual supplemental readonly callback publication at accepted d432a955c before adding the '
              'unrelated metadata claim. The full456-input/108786-byte claim retains every original '
              'producer/artifact identity. All original bindings are checked before execution and remain '
              'unchanged; no new runtime behavior or broader admission is inferred.'}
with TARGET.open('x') as output:
    output.write(json.dumps(r, indent=2) + '\n')
assert p.returncode == 0 and not p.stderr and r['unchanged']
assert p.stdout == b'ControlFlow expansion publication PASS: 456 live inputs; 108786 bytes\n'
assert all(sha((ROOT / x['path']).read_bytes()) == x['sha256'] for x in claims['claims'][0]['durability']['inputs'])
print('Pre-maintenance callback readonly baseline PASS:456/full108786')

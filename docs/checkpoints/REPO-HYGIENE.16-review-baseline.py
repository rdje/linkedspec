"""Retain the actual preceding readonly endpoint before adding this unrelated claim."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGET = ROOT / 'docs/checkpoints/REPO-HYGIENE.16-review-baseline.json'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json'
PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-publish-claim.py'
assert not TARGET.exists(), 'one-shot baseline'
assert not (ROOT / 'docs/claims/REPO-HYGIENE.16.json').exists()
sha = lambda raw: hashlib.sha256(raw).hexdigest()
inputs = {p: sha((ROOT / p).read_bytes()) for p in (CLAIM, PRODUCER)}
command = ['python3', PRODUCER]
result = subprocess.run(command, cwd=ROOT, capture_output=True)
record = {'command': command, 'returncode': result.returncode,
          'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode(),
          'inputs': inputs, 'unchanged': all(sha((ROOT / p).read_bytes()) == digest for p, digest in inputs.items()),
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'scope': 'Actual supplemental readonly predecessor publication before adding the unrelated maintenance claim. Its full366-input/85779-byte publication at accepted fc96936fb retains the original input population; this observation does not admit new runtime behavior. Fixed-baseline current-namespace risk is owned by .3.2.1.10.'}
TARGET.write_text(json.dumps(record, indent=2) + '\n')
assert result.returncode == 0 and not result.stderr and record['unchanged']
assert b'Small optional-kind publication PASS: 366 live inputs; 85779 bytes' in result.stdout
print('Pre-maintenance readonly publication baseline PASS')

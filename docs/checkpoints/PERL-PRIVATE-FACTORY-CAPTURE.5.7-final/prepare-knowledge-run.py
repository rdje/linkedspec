"""Retain the before-write budget failure and run the bounded prose correction."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'preparation-run.json')
assert not target.exists() and not (ROOT / (PREFIX + 'knowledge-preparation.json')).exists()
rows = []
for name in ('prepare-knowledge-over-budget.py', 'prepare-knowledge.py'):
    command = ['python3', PREFIX + name]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    rows.append(dict(command=command, producer_sha256=sha((ROOT / (PREFIX + name)).read_bytes()),
        returncode=result.returncode, stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr)))
    if name == 'prepare-knowledge-over-budget.py':
        assert result.returncode != 0 and b'no writes before full preflight' in result.stderr
report = dict(result='PASS' if rows[-1]['returncode'] == 0 else 'FAIL',
    producer_sha256=sha(Path(__file__).read_bytes()), rows=rows,
    scope='Actual before-write budget rejection is retained under its unchanged source identity. Complete initial card bytes are recoverable from the546-input archive. A separate corrected producer further condenses prior framework chronology with original bodies retained; no budget or membership changes. The failed draft is not passing evidence.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
assert report['result'] == 'PASS', rows[-1]
print('Bounded final Knowledge preparation PASS; original oversized-source failure retained')

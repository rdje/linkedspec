"""Retain actual malformed-header rejection before the bounded current repair."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-'
target = ROOT / (PREFIX + 'headers-before.json')
assert not target.exists(), 'one-shot original header RED'
command = ['python3', PREFIX + 'headers-review.py', '--preflight']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
record = {'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    'command': command, 'returncode': process.returncode,
    'stdout_base64': base64.b64encode(process.stdout).decode(),
    'stderr_base64': base64.b64encode(process.stderr).decode(),
    'inputs': {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
        for path in (PREFIX + 'headers.py', PREFIX + 'headers-census.json', PREFIX + 'headers-review.py')},
    'scope': 'Actual original current-header RED before correction, with exact separate channels; no fact body or original observation is rewritten.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert process.returncode != 0 and b'current Knowledge header has orphan list entries' in process.stderr
print('Original current Knowledge headers RED retained: orphan list entries')

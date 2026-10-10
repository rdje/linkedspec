"""Retain actual wrong-prefix guard rejection and exact original input preservation."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.1.json'
TARGET = ROOT / (PREFIX + 'freeze-guard.json')
assert not TARGET.exists(), 'one-shot guard diagnosis'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
claim = json.loads((ROOT / CLAIM).read_bytes())
paths = {entry['path'] for row in claim['claims'] if row['durability'].get('mode') == 'live' for entry in row['durability']['inputs']}
assert len(paths) == 240
paths.update((CLAIM, 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.1-freeze.json'))
original = {p: (ROOT / p).read_bytes() for p in sorted(paths)}
command = ['python3', PREFIX + 'draft1-freeze.py']
result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
assert result.returncode != 0 and b'one-shot preservation already published' in result.stderr
assert all((ROOT / p).read_bytes() == raw for p, raw in original.items())
assert not (ROOT / (PREFIX + 'freeze.json')).exists() and not (ROOT / (PREFIX + 'before-inference.json')).exists()
TARGET.write_text(json.dumps({'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
    'failed_producer_sha256': digest((ROOT / command[1]).read_bytes()),
    'corrected_producer_sha256': digest((ROOT / (PREFIX + 'freeze.py')).read_bytes()),
    'original_inputs': {p: digest(raw) for p, raw in original.items()},
    'command': command, 'returncode': result.returncode,
    'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode(),
    'unchanged': True,
    'scope': 'The initial copied freezer retained the prior checkpoint PREFIX and stopped at its existing freeze.json guard before any input writes. Actual repeat rejection and all240 original live inputs plus original claim/prior guard file are byte-identical. Correct only PREFIX, docstring and console before successful current preservation; no failed measurement or historical input hash is refreshed.'}, indent=2) + '\n')
print('Wrong-prefix preservation guard PASS: actual rejection; all original inputs unchanged')

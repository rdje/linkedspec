"""Retain the actual last-owner fault-generator failure without refreshing probes."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-'
TARGET = ROOT / (PREFIX + 'fault-boundary.json')
COMMAND = ['python3', PREFIX + 'capture.py', 'inverses']
assert not TARGET.exists(), 'one-shot boundary control already retained'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
fixture = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
inputs = fixture['inputs']
assert len(inputs) == 182
assert all(digest((ROOT / p).read_bytes()) == sha for p, sha in inputs.items())
before = sorted(p.name for p in (ROOT / 'docs/checkpoints').glob('PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-inverse*.json'))
assert before == [], 'no mutant capture may predate the corrected generator'
result = subprocess.run(COMMAND, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
after = sorted(p.name for p in (ROOT / 'docs/checkpoints').glob('PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-inverse*.json'))
unchanged = all(digest((ROOT / p).read_bytes()) == sha for p, sha in inputs.items())
report = {'producer_sha256': digest(Path(__file__).read_bytes()),
          'original_producer_sha256': digest((ROOT / COMMAND[1]).read_bytes()),
          'command': COMMAND, 'returncode': result.returncode, 'inputs': inputs,
          'stdout_base64': base64.b64encode(result.stdout).decode(),
          'stderr_base64': base64.b64encode(result.stderr).decode(),
          'mutants_before': before, 'mutants_after': after, 'unchanged': unchanged,
          'scope': 'Actual recurrence of the first tool-observed failure: final module owner has no next sub delimiter. Original capture/probe/assertions and all successful runtime channels remain unchanged. Separate faults.py fixes only that boundary before any semantic mutant capture.'}
TARGET.write_text(json.dumps(report, indent=2) + '\n')
assert result.returncode != 0 and b'ValueError: substring not found' in result.stderr
assert b"end = source.index('\\nsub ', start + 1)" in result.stderr
assert before == after and unchanged
print('Fault-boundary control PASS: actual final-owner delimiter RED retained; runtime inputs unchanged')

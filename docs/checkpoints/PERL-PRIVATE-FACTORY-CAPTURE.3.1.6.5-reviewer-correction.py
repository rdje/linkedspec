"""Retain the erroneous name predicate and actual readonly failure reproduction."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
draft = PREFIX + 'native-review-draft.py'
command = ['python3', draft]
target = ROOT / (PREFIX + 'reviewer-correction.json')
assert not target.exists(), 'one-shot reviewer correction'
result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
report = {'producer_sha256': sha(Path(__file__).read_bytes()),
          'draft_sha256': sha((ROOT / draft).read_bytes()),
          'current_sha256': sha((ROOT / (PREFIX + 'native-review.py')).read_bytes()),
          'command': command, 'returncode': result.returncode,
          'stdout_base64': base64.b64encode(result.stdout).decode(),
          'stderr_base64': base64.b64encode(result.stderr).decode(),
          'scope': 'The first readonly review overmatched parser-missing-value as a required diagnostic and raised TypeError on its native null error. Exact draft source and this separate actual readonly reproduction are retained; the original tool transport envelope is unavailable. Replace only the name predicate with the exact ten dependency-control names. No runtime capture or production input is changed or refreshed.'}
target.write_text(json.dumps(report, indent=2) + '\n')
assert result.returncode == 1 and not result.stdout
assert b"TypeError: expected string or bytes-like object, got 'NoneType'" in result.stderr
print('Hash-index reviewer correction: exact failed predicate/source and readonly TypeError reproduction retained')

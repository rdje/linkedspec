"""Retain the exact rejected staged candidate and actual declaration RED."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-'
OWNER = PREFIX.removeprefix('docs/checkpoints/').removesuffix('-')
BASE = '997f1cb8f32ff4eaa1ba278e124cbaaac1942780'

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def channel(raw):
    return {'bytes': len(raw), 'sha256': sha(raw),
            'gzip_base64': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}

claim_path = 'docs/claims/' + OWNER + '.json'
original = (ROOT / claim_path).read_bytes()
claim = json.loads(original)
inputs = claim['claims'][0]['durability']['inputs']
for entry in inputs:
    assert sha((ROOT / entry['path']).read_bytes()) == entry['sha256'], entry['path']
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
delta = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
command = ['perl', 'tools/check_task_verification_fields.pl', '--owner']
watched = ['tools/check_task_verification_fields.pl', 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md', claim_path]
guards = {path: sha((ROOT / path).read_bytes()) for path in watched}
result = subprocess.run(command, cwd=ROOT, capture_output=True)
assert result.returncode != 0 and b'found 7' in result.stderr
assert guards == {path: sha((ROOT / path).read_bytes()) for path in watched}
(ROOT / (PREFIX + 'preparation-initial-claim.json')).write_bytes(original)
report = {'revision': BASE, 'complete': True, 'command': command, 'exit': result.returncode,
          'stdout': channel(result.stdout), 'stderr': channel(result.stderr),
          'staged_binary_delta': channel(delta), 'original_claim_sha256': sha(original),
          'original_bound_inputs': inputs, 'inputs_before': guards, 'inputs_after': guards,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'scope': 'Exact original unadmitted staged delta over immutable Git base, original live claim/input identities and actual one-owner declaration RED; no acceptance or input refresh.'}
(ROOT / (PREFIX + 'preparation-initial.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Retained original rejected candidate and actual seven-owner declaration RED.')

"""Preserve the actual first incomplete recovery and its producer before correction."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DIR = ROOT / 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1'
source = (DIR / 'review.py').read_bytes()
reached = (DIR / 'original-replay-reached.json').read_bytes()
data = json.loads(reached)
assert len(data['rows']) == 1
row = data['rows'][0]
assert row['name'] == 'accepted' and row['returncode'] == 1 and row['unchanged'] is True
assert len(row['inputs']) == 378
error = base64.b64decode(row['stderr_base64'], validate=True)
assert b'FileNotFoundError' in error and b'.gitignore' in error
for name in ('review-draft.py', 'original-replay-draft-reached.json', 'draft-correction.json'):
    assert not (DIR / name).exists(), 'one-shot draft preservation'
(DIR / 'review-draft.py').write_bytes(source)
(DIR / 'original-replay-reached.json').rename(DIR / 'original-replay-draft-reached.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
(DIR / 'draft-correction.json').write_text(json.dumps({
    'draft_sha256': sha(source), 'reached_sha256': sha(reached),
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'result': 'Original recovery exits1 before success assertion; all378 supplied inputs unchanged.',
    'cause': 'The primary live binding list omits17 historical hygiene inputs read by the actual preserved hygiene reviewer. Their original19-input claim and hashes are already retained at accepted Git.',
    'repair': 'Supply the additional historical inputs from accepted Git, deriving membership from their preserved claim. Keep original producer, observations and input hashes unchanged. Fresh original-publication recovery includes an omitted-.gitignore RED and exact restoration. No partial failed-replay success is claimed.'
}, indent=2) + '\n')
print('First failed recovery and actual draft producer retained exactly')

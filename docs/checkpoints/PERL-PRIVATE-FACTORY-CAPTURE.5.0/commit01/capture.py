"""Preserve the actual failed staged candidate before the unbound title repair."""
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.0/commit01/'
BASE = 'aa88233432976a019b41d05578f8e6a5f6e3c082'
sha = lambda value: hashlib.sha256(value).hexdigest()
target = ROOT / (PREFIX + 'capture.json')
assert not target.exists(), 'one-shot failed-candidate capture'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
live = (ROOT / 'LIVE_ACHIEVEMENT_STATUS.md').read_bytes()
original = subprocess.check_output(['git', 'show', BASE + ':LIVE_ACHIEVEMENT_STATUS.md'], cwd=ROOT)
assert live.startswith(b'# Live Achievement Status\n')
assert original.startswith(b'# LIVE ACHIEVEMENT STATUS\n')
assert subprocess.check_output(['git', 'show', ':LIVE_ACHIEVEMENT_STATUS.md'], cwd=ROOT) == live
patch = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
log = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.5.0-commit.log').read_bytes()
assert b'live_status current view heading order/shape mismatch' in log
assert b'FAIL  DOCUMENT-HISTORY' in log and b'FAIL  README-STABILITY' in log
assert b'PASS  CLAIM-VERIFICATION' in log and b'doctrines: one or more doctrines FAILED' in log
claim_path = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.0.json'
claim_raw = (ROOT / claim_path).read_bytes()
claim = json.loads(claim_raw)
inputs = {item['path']: item['sha256'] for measurement in claim['claims']
          for item in measurement['durability']['inputs']}
assert 'LIVE_ACHIEVEMENT_STATUS.md' not in inputs
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in inputs.items())
files = {'candidate.patch.gz': gzip.compress(patch, mtime=0),
         'live-before.md': live, 'live-accepted.md': original, 'hook.log': log}
for name, value in files.items():
    with (ROOT / (PREFIX + name)).open('xb') as output:
        output.write(value)
record = {'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.5.0', 'base': BASE,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'outer_session': 85114, 'outer_returncode': 1,
          'command': ['git', '--no-pager', 'commit', '-F', 'git_message_brief.txt'],
          'files': {name: sha(value) for name, value in files.items()},
          'staged_patch_sha256': sha(patch), 'staged_patch_bytes': len(patch),
          'claim_path': claim_path, 'whole_claim_sha256': sha(claim_raw),
          'claim_inputs': inputs,
          'root_cause': 'The continuity writer changed only the required title spelling from uppercase to title case. Document history requires an exact heading array; README freshness delegates to that same checker. Both actual hook failures have the same cause.',
          'repair_scope': 'Restore the exact accepted first heading. Runtime, book, Knowledge, all executed producers/observations and the complete published input population remain untouched. Original staged binary diff plus accepted Git recover the entire failed candidate; original hook output and both complete live documents remain retained.'}
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
print('Failed commit candidate retained; published inputs exact; one-line unbound title repair owned')

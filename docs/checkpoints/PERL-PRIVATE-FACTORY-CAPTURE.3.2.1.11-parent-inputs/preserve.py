"""Freeze the fourth publication and its eight mutable inputs before local snapshot routing."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-parent-inputs/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json'
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists(), 'one-shot complete preservation'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
claim = (ROOT / CLAIM).read_bytes()
bindings = json.loads(claim)['claims'][0]['durability']['inputs']
assert len(claim) == 51535 and len(bindings) == 198
assert all(sha((ROOT / r['path']).read_bytes()) == r['sha256'] for r in bindings)
tracked = set(subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0'))
assert [r['path'] for r in bindings if r['path'] not in tracked] == ['rgx/README.md']
result = subprocess.run(['python3', OLD + 'publish.py'], cwd=ROOT, capture_output=True)
assert result.returncode == 0 and not result.stderr
assert result.stdout == b'Portable Knowledge/documentation publication PASS: 198 live inputs; 51535 bytes\n'
cards = json.loads((ROOT / (OLD + 'current-final.json')).read_bytes())['changed_cards']
paths = cards + ['KNOWLEDGE_MAP.md', 'docs/linkedspec-book/src/development/documentation-workflow.md']
assert len(paths) == 8 and set(paths) <= {r['path'] for r in bindings}
overlays = {p: base64.b64encode((ROOT / p).read_bytes()).decode() for p in paths}
packed = gzip.compress(json.dumps(overlays, sort_keys=True).encode(), mtime=0)
(ROOT / (PREFIX + 'original-claim.json')).write_bytes(claim)
(ROOT / (PREFIX + 'original-overlays.json.gz')).write_bytes(packed)
public = (ROOT / 'rgx/README.md').read_bytes()
(ROOT / (PREFIX + 'rgx-public-readme.md')).write_bytes(public)
pin = subprocess.check_output(['git', 'ls-files', '--stage', '--', 'rgx'], cwd=ROOT)
assert pin.startswith(b'160000 ')
log = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical05.log').read_bytes()
(ROOT / (PREFIX + 'canonical05.log.gz')).write_bytes(gzip.compress(log, mtime=0))
candidate = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
target.write_text(json.dumps({'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'claim_sha256': sha(claim), 'claim_bytes': len(claim), 'bindings': len(bindings), 'capsule_sha256': sha(packed),
    'modes': {r['path']: (ROOT / r['path']).stat().st_mode & 0o777 for r in bindings},
    'baseline': {'returncode': result.returncode, 'stdout_base64': base64.b64encode(result.stdout).decode(),
        'stderr_base64': base64.b64encode(result.stderr).decode()},
    'public_input': 'rgx/README.md', 'snapshot': PREFIX + 'rgx-public-readme.md', 'snapshot_sha256': sha(public),
    'gitlink_stage': pin.decode(), 'canonical_session': 75557, 'canonical_returncode': 1,
    'canonical_log_sha256': sha(log), 'candidate_sha256': sha(candidate),
    'scope': 'All198 original bindings/full51535 record verified before eight bound route/card/map inputs change. Published public submodule README is copied read-only into a parent-owned byte snapshot; no implementation inspection, repository write or pin change. Original publication remains uncommitted; actual canonical5 rejects its sole parent-untracked binding. No full failed-candidate reconstruction or canonical admission is claimed.'}, indent=2) + '\n')
print('Fourth publication preserved:198 complete bindings/full51535; eight overlays; exact published README snapshot')

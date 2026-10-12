"""Preserve the complete third publication through unchanged inputs and ten byte overlays."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json'
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists(), 'one-shot complete publication preservation'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
raw = (ROOT / CLAIM).read_bytes()
bindings = json.loads(raw)['claims'][0]['durability']['inputs']
assert len(raw) == 44317 and len(bindings) == 177
assert all(sha((ROOT / r['path']).read_bytes()) == r['sha256'] for r in bindings)
process = subprocess.run(['python3', OLD + 'publish.py'], cwd=ROOT, capture_output=True)
assert process.returncode == 0 and not process.stderr
assert process.stdout == b'Current Knowledge/documentation publication PASS: 177 live inputs; 44317 bytes\n'
cards = json.loads((ROOT / (OLD + 'current-final.json')).read_bytes())['changed_cards']
paths = cards + ['KNOWLEDGE_MAP.md', 'docs/linkedspec-book/src/development/documentation-workflow.md',
    OLD + 'document-first-failure.json', OLD + 'document-first-after-failure.json']
assert len(paths) == 10 and set(paths) <= {r['path'] for r in bindings}
overlays = {p: base64.b64encode((ROOT / p).read_bytes()).decode() for p in paths}
packed = gzip.compress(json.dumps(overlays, sort_keys=True).encode(), mtime=0)
(ROOT / (PREFIX + 'original-claim.json')).write_bytes(raw)
(ROOT / (PREFIX + 'original-overlays.json.gz')).write_bytes(packed)
log = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical04.log').read_bytes()
(ROOT / (PREFIX + 'canonical04.log.gz')).write_bytes(gzip.compress(log, mtime=0))
candidate = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
target.write_text(json.dumps({'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'claim_sha256': sha(raw), 'claim_bytes': len(raw), 'bindings': len(bindings), 'capsule_sha256': sha(packed),
    'modes': {r['path']: (ROOT / r['path']).stat().st_mode & 0o777 for r in bindings},
    'baseline': {'returncode': process.returncode, 'stdout_base64': base64.b64encode(process.stdout).decode(),
        'stderr_base64': base64.b64encode(process.stderr).decode()},
    'canonical_session': 22423, 'canonical_returncode': 130, 'canonical_log_sha256': sha(log),
    'candidate_sha256': sha(candidate),
    'scope': 'All177 original publication bindings/full44317 record verified before mutation. Ten subsequently mutable inputs are supplied as complete original byte overlays; all other inputs remain retained unchanged and gated. Canonical4 reported portability rejection then was intentionally interrupted130; no full canonical PASS or full failed-candidate reconstruction is claimed. Diagnostic observations remain exact.'}, indent=2) + '\n')
print('Third publication preserved:177 complete bindings/full44317; ten original byte overlays; actual baseline PASS')

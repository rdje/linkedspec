"""Freeze the complete second uncommitted publication before public-book repair."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DEST = Path(__file__).resolve().parent
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json'
assert not (DEST / 'preservation.json').exists(), 'one-shot second candidate preservation'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
raw = (ROOT / CLAIM).read_bytes()
items = json.loads(raw)['claims'][0]['durability']['inputs']
assert len(raw) == 79329 and len(items) == 337
contents, modes = {}, {}
for item in items:
    path = ROOT / item['path']
    value = path.read_bytes()
    assert sha(value) == item['sha256'], ('all second-candidate inputs before writes', item['path'])
    contents[item['path']] = base64.b64encode(value).decode()
    modes[item['path']] = path.stat().st_mode & 0o777
command = ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/publish.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
assert process.returncode == 0 and not process.stderr
assert process.stdout == b'Final Knowledge publication PASS: 337 live inputs; 79329 bytes\n'
baseline = {'command': command, 'returncode': process.returncode,
    'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()}
candidate = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
log = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03.log').read_bytes()
assert b'public-aggregate-selector-surface:' in log and b'without explicit removed/rejected/migrated historical context' in log
data = [('original-claim.json', raw), ('original-inputs.json.gz', gzip.compress((json.dumps(contents, sort_keys=True) + '\n').encode(), mtime=0)),
    ('baseline.json', (json.dumps(baseline, indent=2) + '\n').encode()),
    ('candidate.diff.gz', gzip.compress(candidate, mtime=0)), ('canonical.log.gz', gzip.compress(log, mtime=0))]
for tail, value in data:
    with (DEST / tail).open('xb') as output:
        output.write(value)
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'bindings': len(items), 'claim_bytes': len(raw), 'claim_sha256': sha(raw), 'modes': modes,
    'capsule_sha256': sha((DEST / 'original-inputs.json.gz').read_bytes()),
    'candidate_sha256': sha(candidate), 'candidate_bytes': len(candidate),
    'canonical_log_sha256': sha(log), 'canonical_log_bytes': len(log),
    'actual_canonical_session': 25364, 'actual_canonical_returncode': 1,
    'scope': 'Complete second uncommitted337-input/full79329 publication, every original input byte/mode and actual readonly baseline are frozen before bound book/card/map writes. Exact canonical3 candidate and real documentation failure are retained. No fabricated accepted Git revision, refreshed native observation or full canonical admission.'}
(DEST / 'preservation.json').write_text(json.dumps(report, indent=2) + '\n')
print('Second candidate preservation PASS: all337/full79329; actual readonly baseline; exact canonical3 failure retained')

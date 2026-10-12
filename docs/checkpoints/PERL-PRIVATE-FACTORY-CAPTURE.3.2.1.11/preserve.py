"""Preserve the complete uncommitted focused publication before canonical repair."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json'
BASE = '328b11c5ed1d5ffbc870f6785448e3a8249fe882'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists(), 'one-shot original candidate preservation'
raw = (ROOT / CLAIM).read_bytes()
record = json.loads(raw)
inputs = record['claims'][0]['durability']['inputs']
assert len(inputs) == 136 and len(raw) == 35512
contents, modes = {}, {}
for item in inputs:
    path = ROOT / item['path']
    value = path.read_bytes()
    assert sha(value) == item['sha256'], ('every original binding before writes', item['path'])
    contents[item['path']] = base64.b64encode(value).decode()
    modes[item['path']] = path.stat().st_mode & 0o777
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
command = ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-publish-claim.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
baseline = {'command': command, 'returncode': process.returncode,
    'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()}
assert process.returncode == 0 and not process.stderr
assert process.stdout == b'Knowledge gate publication PASS: 136 live inputs; 35512 bytes\n'
for tail, value in [('original-claim.json', raw), ('original-inputs.json.gz', gzip.compress((json.dumps(contents, sort_keys=True) + '\n').encode(), mtime=0)),
                    ('baseline.json', (json.dumps(baseline, indent=2) + '\n').encode())]:
    with (ROOT / (PREFIX + tail)).open('xb') as output:
        output.write(value)
candidate = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
with (ROOT / (PREFIX + 'canonical1-candidate.diff.gz')).open('xb') as output:
    output.write(gzip.compress(candidate, mtime=0))
auditor = 'tests/language-readiness/verify_objectives.py'
before = (ROOT / auditor).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + auditor], cwd=ROOT)
with (ROOT / (PREFIX + 'auditor-before.py')).open('xb') as output:
    output.write(before)
log = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical01.log').read_bytes()
assert b'ValueError: unreviewed governance drift: tools/run_ci_local.sh' in log
result = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'claim_sha256': sha(raw), 'claim_bytes': len(raw), 'bindings': len(inputs), 'modes': modes,
    'capsule_sha256': sha((ROOT / (PREFIX + 'original-inputs.json.gz')).read_bytes()),
    'candidate_sha256': sha(candidate), 'candidate_bytes': len(candidate),
    'auditor_before_sha256': sha(before), 'actual_canonical_session': 5315, 'actual_canonical_returncode': 1,
    'canonical_log_base64': base64.b64encode(log).decode(),
    'scope': 'Complete first uncommitted focused publication and every136 input byte are retained before bound card/book/map writes. It is not assigned a fabricated historical Git revision. Canonical1 full staged binary candidate and actual failure remain exact. Original native/TAP/source-fault/book/evidence observations are unchanged; later current proof uses distinct nested producers.'}
target.write_text(json.dumps(result, indent=2) + '\n')
print('Original candidate preservation PASS: 136 bindings; full35512; actual readonly baseline; canonical1 candidate/failure retained')

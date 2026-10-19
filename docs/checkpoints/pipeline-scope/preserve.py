"""One-shot custody of the complete uncommitted pipeline draft before transport repair."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/pipeline-scope/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.6.json'
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
assert not (ROOT / (PREFIX + 'preserved.json.gz')).exists()
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
original = (ROOT / CLAIM).read_bytes()
claim = json.loads(original)
bindings = claim['claims'][0]['durability']['inputs']
assert len(bindings) == 625 and len(original) == 123401
inputs = {}
for item in bindings:
    path = ROOT / item['path']
    assert path.is_file() and not path.is_symlink()
    value = path.read_bytes()
    assert sha(value) == item['sha256'], item['path']
    inputs[item['path']] = dict(sha256=sha(value), mode=path.stat().st_mode & 0o7777,
                               base64=encode(value))
preflight = (ROOT / (OLD + 'publication-preflight.json')).read_bytes()
assert base64.b64decode(json.loads(preflight)['draft_base64']) == original
command = ['python3', OLD + 'publish.py']
baseline = subprocess.run(command, cwd=ROOT, capture_output=True)
assert baseline.returncode == 0 and not baseline.stderr
assert baseline.stdout == b'Pipeline invocation publication PASS: 625 live inputs; 123401 bytes\n'
for path, item in inputs.items():
    source = ROOT / path
    assert sha(source.read_bytes()) == item['sha256']
    assert source.stat().st_mode & 0o7777 == item['mode']
raw = dict(version=1, owner='PERL-PRIVATE-FACTORY-CAPTURE.6', base=BASE,
           claim_base64=encode(original), claim_sha256=sha(original),
           publication_preflight_base64=encode(preflight), inputs=inputs,
           producer_base64=encode(Path(__file__).read_bytes()),
           baseline=dict(command=command, returncode=baseline.returncode,
                         stdout_base64=encode(baseline.stdout), stderr_base64=encode(baseline.stderr)),
           scope='Complete original uncommitted625-input draft; BASE predates it and is not its revision. '
                 'No native, capture, preparation or repair writer is replayed. Actual readonly '
                 'baseline precedes every bound transport/documentation write.')
payload = gzip.compress(json.dumps(raw, sort_keys=True).encode(), mtime=0)
with (ROOT / (PREFIX + 'preserved.json.gz')).open('xb') as output:
    output.write(payload)
report = dict(result='PASS', input_count=len(inputs), original_claim_bytes=len(original),
              claim_sha256=sha(original), capsule_sha256=sha(payload),
              producer_sha256=sha(Path(__file__).read_bytes()), baseline=raw['baseline'])
with (ROOT / (PREFIX + 'preservation.json')).open('x') as output:
    output.write(json.dumps(report, indent=1) + '\n')
print('Preserved original uncommitted625/full123401 and actual readonly baseline')

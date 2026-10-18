"""Retain the count-preflight failure and run the one-constant final correction."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'faults-final-run.json')
assert not target.exists() and not (ROOT / (PREFIX + 'faults.json')).exists()
first = (ROOT / (PREFIX + 'faults.py')).read_bytes()
final = (ROOT / (PREFIX + 'faults-final.py')).read_bytes()
assert final == first.replace(b'assert len(variants) == 17', b'assert len(variants) == 18', 1)
assert final != first
capsule = json.loads(gzip.decompress((ROOT / (PREFIX + 'faults-builder-failure-inputs.json.gz')).read_bytes()))
paths = set(capsule) | {PREFIX + name for name in ('faults-correction.json',
    'faults-builder-failure-inputs.json.gz', 'faults-final.py', 'faults-final-run.py')}
inputs = {p: dict(sha256=sha((ROOT / p).read_bytes()), mode=(ROOT / p).stat().st_mode & 0o7777,
                 bytes_base64=encode((ROOT / p).read_bytes())) for p in sorted(paths)}
archive = ROOT / (PREFIX + 'faults-final-run-inputs.json.gz')
with archive.open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))
rows = []
for name in ('faults.py', 'faults-final.py'):
    command = ['python3', PREFIX + name]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    rows.append(dict(command=command, returncode=result.returncode,
        stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr)))
    if name == 'faults.py':
        assert result.returncode != 0 and b'assert len(variants) == 17' in result.stderr
report = dict(result='PASS' if rows[-1]['returncode'] == 0 else 'FAIL',
    producer_sha256=sha(Path(__file__).read_bytes()), capsule_sha256=sha(archive.read_bytes()),
    rows=rows, scope='Both prior failed sources/reports remain exact. This records an actual rerun of the retained count-preflight failure before faults.json exists, then the separately identified one-constant correction. All actual channels and supplied inputs are retained; no failed report is changed to PASS.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
assert report['result'] == 'PASS', rows[-1]
assert all(sha((ROOT / p).read_bytes()) == item['sha256'] for p, item in inputs.items())
print('Final source-control producer PASS: retained count-preflight RED; all18 actual source variants PASS')

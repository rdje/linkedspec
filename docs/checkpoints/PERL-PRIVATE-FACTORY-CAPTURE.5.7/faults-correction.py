"""Retain the original builder failure before running its scoped correction."""
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
target = ROOT / (PREFIX + 'faults-correction.json')
assert not target.exists()
assert not (ROOT / (PREFIX + 'faults.json')).exists()
original = json.loads(gzip.decompress((ROOT / (PREFIX + 'complete-after-inputs.json.gz')).read_bytes()))
paths = set(original) | {PREFIX + name for name in ('complete-after-inputs.json.gz',
    'complete-before-inputs.json.gz', 'complete-before.json', 'faults-builder-failure.py',
    'faults.py', 'faults-correction.py')}
capsule = {p: dict(sha256=sha((ROOT / p).read_bytes()),
    bytes_base64=encode((ROOT / p).read_bytes()), mode=(ROOT / p).stat().st_mode & 0o7777) for p in sorted(paths)}
archive = ROOT / (PREFIX + 'faults-builder-failure-inputs.json.gz')
with archive.open('xb') as output:
    output.write(gzip.compress(json.dumps(capsule, sort_keys=True).encode(), mtime=0))
rows = []
for name in ('faults-builder-failure.py', 'faults.py'):
    command = ['python3', PREFIX + name]
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    rows.append(dict(command=command, returncode=process.returncode,
        stdout_base64=encode(process.stdout), stderr_base64=encode(process.stderr)))
    if name == 'faults-builder-failure.py':
        assert process.returncode != 0 and b'AssertionError: all-facade-code-authorized' in process.stderr
report = dict(result='PASS' if rows[1]['returncode'] == 0 else 'FAIL',
    producer_sha256=sha(Path(__file__).read_bytes()), capsule_sha256=sha(archive.read_bytes()),
    rows=rows, scope='The retained original builder is rerun before any faults.json exists and rejects the repeated cross-catalogue predicate. The corrected producer targets the unique ControlFlow catalogue loop. These are actual retained rerun/correction channels; original tool-call channels are not reconstructed. Sources and every consumed supplied input remain recoverable.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
assert report['result'] == 'PASS', rows[1]
assert all(sha((ROOT / p).read_bytes()) == item['sha256'] for p, item in capsule.items())
print('Fault-builder correction PASS: exact original predicate failure; distinct scoped producer PASS')

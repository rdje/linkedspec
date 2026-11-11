"""Acquire only new qualified outputs; original programs/producers stay unchanged."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
stage = sys.argv[1]
assert stage in ('capture', 'inspect')
tag = 'qualified-' + stage
assert not (HERE / (tag + '-exit.txt')).exists(), 'one-shot acquisition'
images = {}
for path in sorted(HERE.glob('*.py')):
    raw = path.read_bytes()
    images[path.relative_to(ROOT).as_posix()] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
        mode=path.stat().st_mode & 0o777, base64=base64.b64encode(raw).decode())
for name in ('tools/project_data_env.sh', 'tools/project_data_run.sh'):
    path = ROOT / name
    raw = path.read_bytes()
    images[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
        mode=path.stat().st_mode & 0o777, base64=base64.b64encode(raw).decode())
(HERE / (tag + '-producer-images.json.gz')).write_bytes(gzip.compress(json.dumps(images, sort_keys=True).encode(), mtime=0))
script = 'capture_qualified.py' if stage == 'capture' else 'inspect_qualified.py'
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / script)]
(HERE / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (HERE / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(HERE / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
for name, row in images.items():
    path = ROOT / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
    assert path.stat().st_mode & 0o777 == row['mode']
assert result.returncode == 0 and result.stderr == b'', 'original actual channels retained; qualify separately on failure'
print(result.stdout.decode(), end='')

"""Capture actual child commands, source images and complete channels once per tag."""
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
tag = sys.argv[1]
assert tag in ('prepare', 'capture', 'inspect', 'review', 'current')
assert not (HERE / (tag + '-exit.txt')).exists(), 'one-shot acquisition'
names = {path.relative_to(ROOT).as_posix() for path in HERE.glob('*.py')}
names |= {'tools/project_data_env.sh', 'tools/project_data_run.sh',
    'docs/checkpoints/array-pipeline-callable-selection-2026-11-11/observer.pl',
    'docs/checkpoints/array-pipeline-callable-selection-2026-11-11/prepare.py',
    'docs/checkpoints/array-pipeline-callable-selection-2026-11-11/capture.py'}
images = {}
for name in sorted(names):
    path = ROOT / name
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    raw = path.read_bytes()
    images[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
        mode=path.stat().st_mode & 0o777, base64=base64.b64encode(raw).decode())
(HERE / (tag + '-producer-images.json.gz')).write_bytes(gzip.compress(json.dumps(images, sort_keys=True).encode(), mtime=0))
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / (tag + '.py'))]
(HERE / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (HERE / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(HERE / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
for name, image in images.items():
    path = ROOT / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == image['sha256']
    assert path.stat().st_mode & 0o777 == image['mode']
assert result.returncode == 0 and result.stderr == b'', 'first actual channels retained; qualify separately on failure'
print(result.stdout.decode(), end='')

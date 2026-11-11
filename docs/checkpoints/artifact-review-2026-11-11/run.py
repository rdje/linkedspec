"""Retain exact commands, child channels and project source images for this leaf."""
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
commands = {
    'prepare': ['prepare.py'],
    'census-capture': ['census.py', '--capture'],
    'census-review': ['census.py'],
    'retire': ['retire.py'],
    'readonly': ['review.py'],
}
assert tag in commands and not (HERE / (tag + '-exit.txt')).exists(), 'one-shot acquisition'
names = sorted(set(path.relative_to(ROOT).as_posix() for path in HERE.glob('*.py')) |
    {'tools/project_data_env.sh', 'tools/project_data_run.sh',
     'docs/checkpoints/artifact-review-2026-11-10/review.py',
     'docs/checkpoints/REPO-HYGIENE.19/census.py', 'docs/checkpoints/REPO-HYGIENE.18-census.py'})
images = {}
for name in names:
    path = ROOT / name
    assert not path.is_symlink() and path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
    raw = path.read_bytes()
    images[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
        mode=path.stat().st_mode & 0o777, base64=base64.b64encode(raw).decode())
(HERE / (tag + '-inputs.json.gz')).write_bytes(gzip.compress(json.dumps(images, sort_keys=True).encode(), mtime=0))
tail = commands[tag]
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P',
           str(BASE / tail[0]), *tail[1:]]
(HERE / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (HERE / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(HERE / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
for name, image in images.items():
    path = ROOT / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == image['sha256'], 'producer changed'
    assert path.stat().st_mode & 0o777 == image['mode'], 'producer mode changed'
assert result.returncode == 0 and result.stderr == b'', 'actual child channels retained; qualify separately on failure'
print(result.stdout.decode(), end='')

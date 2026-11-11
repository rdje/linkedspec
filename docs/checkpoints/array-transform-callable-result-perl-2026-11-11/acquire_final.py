"""One-shot current/independent-reader/seal commands with separate actual channels."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
tag = sys.argv[1]
assert tag in ('current', 'review_first', 'seal', 'review')
OUT = BASE / (tag + '-final-launch')
OUT.mkdir()
images = {}
for path in sorted(BASE.iterdir()):
    if path.is_file() and path.suffix in ('.py', '.pl', '.json'):
        raw = path.read_bytes()
        images[str(path.relative_to(ROOT))] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777, base64=base64.b64encode(raw).decode())
(OUT / 'producer-images.json.gz').write_bytes(gzip.compress(json.dumps(images, sort_keys=True).encode(), mtime=0))
script = 'review.py' if tag in ('review_first', 'review') else tag + '.py'
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / script)]
if tag == 'review_first':
    command.append('--first')
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
for name, row in images.items():
    path = ROOT / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
assert result.returncode == 0 and not result.stderr, 'Actual first failure retained; qualify separately'
print(result.stdout.decode(), end='')

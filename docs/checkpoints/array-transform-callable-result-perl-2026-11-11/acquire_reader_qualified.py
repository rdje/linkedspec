"""One-shot companion reader qualification, first recovery, seal and default recovery."""
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
stages = {
    'qualify': ('qualify_reader.py', [], 'reader-qualification-launch'),
    'first': ('review_qualified.py', ['--first'], 'review_qualified_first-final-launch'),
    'seal': ('seal_qualified.py', [], 'seal_qualified-final-launch'),
    'review': ('review_qualified.py', [], 'review_qualified-final-launch'),
}
script, args, directory = stages[sys.argv[1]]
OUT = BASE / directory
OUT.mkdir()
images = {}
for path in sorted(BASE.iterdir()):
    if path.is_file() and path.suffix in ('.py', '.pl', '.json'):
        raw = path.read_bytes()
        images[str(path.relative_to(ROOT))] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777, base64=base64.b64encode(raw).decode())
(OUT / 'producer-images.json.gz').write_bytes(gzip.compress(json.dumps(images, sort_keys=True).encode(), mtime=0))
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / script)] + args
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
for name, row in images.items():
    path = ROOT / name
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], name
assert result.returncode == 0 and not result.stderr, 'Actual companion failure retained; qualify separately'
print(result.stdout.decode(), end='')

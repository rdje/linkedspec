"""Seal completed finite proof inputs; leave review outputs outside their inputs."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
assert not (BASE / 'control-owner').exists()
target = BASE / 'sealed-identities.json'
assert not target.exists()
patch = subprocess.check_output(['git', 'diff', '--', 'dart/lib/src/runtime/interpreter.dart'], cwd=ROOT)
(BASE / 'producer-change.patch.gz').write_bytes(gzip.compress(patch, mtime=0))
files = {}
for path in sorted(BASE.rglob('*')):
    if not path.is_file() or path == target:
        continue
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    files[str(path.relative_to(ROOT))] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
target.write_text(json.dumps(files, indent=2, sort_keys=True) + '\n')
print('Finite proof inputs sealed; read-only recovery must qualify its own result')

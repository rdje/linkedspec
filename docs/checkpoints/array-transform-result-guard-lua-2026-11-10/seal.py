"""Seal completed Lua epochs and first readonly reader inputs without rewriting."""
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
patch = subprocess.check_output(['git', 'diff', '--', 'lua/src/linkedspec/interpreter.lua', 'lua/test/run.lua'], cwd=ROOT)
(BASE / 'producer-change.patch.gz').write_bytes(gzip.compress(patch, mtime=0))
rows = {}
for path in sorted(BASE.rglob('*')):
    if not path.is_file() or path == target:
        continue
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    rows[str(path.relative_to(ROOT))] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
target.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Completed installed-host epochs sealed before readonly recovery')

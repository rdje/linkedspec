"""Seal completed SDK epochs and the first readonly producer before use."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
target = BASE / 'sealed-identities.json'
assert not target.exists()
rows = {}
for p in sorted(BASE.rglob('*')):
    if not p.is_file():
        continue
    assert not p.is_symlink() and p.stat().st_dev == ROOT.stat().st_dev
    raw = p.read_bytes()
    rows[str(p.relative_to(ROOT))] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=p.stat().st_mode & 0o777)
target.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Completed SDK inputs, artifacts, channels and first readonly producer sealed')

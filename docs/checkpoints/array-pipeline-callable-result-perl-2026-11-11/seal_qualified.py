"""Seal actual SDK epochs and readonly instruments before their first review."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
target = BASE / 'qualified-identities.json'
assert not target.exists()
rows = {}
for path in sorted(BASE.rglob('*')):
    if path.is_file():
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        rows[str(path.relative_to(ROOT))] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
target.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Original epochs and first readonly instruments sealed')

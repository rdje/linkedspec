"""Seal completed qualified acquisition and readonly producers before review."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
target = BASE / 'sealed-identities.json'
assert not target.exists()
records = {}
for path in sorted(BASE.rglob('*')):
    if not path.is_file() or path == target:
        continue
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    records[str(path.relative_to(ROOT))] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Qualified acquisition inputs sealed before readonly recovery')

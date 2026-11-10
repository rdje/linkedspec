"""Seal completed actual data epochs and readonly producer inputs once."""
import hashlib
import json
from pathlib import Path
BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
target = BASE / 'sealed-identities.json'
assert not target.exists()
rows = {}
for path in sorted(BASE.rglob('*')):
    if not path.is_file():
        continue
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    rows[str(path.relative_to(ROOT))] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
target.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Actual migration/public queries and first readonly reader inputs sealed')

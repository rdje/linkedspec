"""Seal completed core evidence; later publication has its own frozen images."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
target = BASE / 'sealed-identities.json'
assert not target.exists()
rows = {}
for path in sorted(BASE.rglob('*')):
    if path.is_file() and path.name not in ('REVIEW.md', 'LANDING.md'):
        assert not path.is_symlink()
        body = path.read_bytes()
        rows[path.relative_to(BASE).as_posix()] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
target.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Sealed the completed field-observation core; publication remains separately bound')

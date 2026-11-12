"""Seal completed historical inputs/results; no SDK execution or claim refresh."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
assert not (BASE / 'sealed-identities.json').exists()
rows = {}
for path in sorted(BASE.rglob('*')):
    if not path.is_file() or 'launches' in path.relative_to(BASE).parts:
        continue
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    rows[str(path.relative_to(ROOT))] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
(BASE / 'sealed-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(sealed=len(rows), scope='Completed historical inputs/results only, excluding outer launch capsules; no native/cache/transitive closure.')))

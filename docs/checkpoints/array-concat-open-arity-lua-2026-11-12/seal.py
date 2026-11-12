"""Seal completed SDK epochs and the first historical reader before its use."""
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
target = BASE / 'sealed-identities.json'
assert not target.exists() and not (BASE / 'control-owner').exists()
rows = {}
for path in sorted(BASE.rglob('*')):
    if path.is_file():
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
target.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Completed actual SDK epochs and first reader inputs sealed; later launch/results/publication remain outside this boundary')

"""Freeze actual first inputs/products/readers; no source or profile normalization."""
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
assert not (HERE / 'sealed-identities.json').exists(), 'one-shot seal'
rows = {}
for path in sorted(path for path in HERE.rglob('*') if path.is_file()):
    assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    raw = path.read_bytes()
    rows[path.relative_to(ROOT).as_posix()] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
(HERE / 'sealed-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', sealed_files=len(rows), no_production_change=True), sort_keys=True))

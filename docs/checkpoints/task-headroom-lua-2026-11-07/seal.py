"""Bind actual first and qualified artifacts before first readonly review."""
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
target = BASE / 'sealed-identities.json'
assert not target.exists()
records = {}
for path in sorted(BASE.rglob('*')):
    if path.is_file() and path != target and path.name != 'README.md':
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        records[str(path.relative_to(ROOT))] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
target.write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Actual first/qualified inputs, producers and readonly instruments sealed')

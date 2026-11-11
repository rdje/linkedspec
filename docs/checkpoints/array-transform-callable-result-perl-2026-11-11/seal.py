"""Freeze completed proof bytes, including the actual first independent reader result."""
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
target = BASE / 'sealed-identities.json'
assert not target.exists()
assert (BASE / 'review_first-final-launch/exit.txt').read_text().strip() == '0'
rows = {}
for path in sorted(BASE.rglob('*')):
    if not path.is_file() or path.name == 'REVIEW.md':
        continue
    assert not path.is_symlink() and path.resolve().is_relative_to(BASE) and path.stat().st_dev == ROOT.stat().st_dev
    raw = path.read_bytes()
    rows[str(path.relative_to(ROOT))] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
target.write_text(json.dumps(rows, sort_keys=True, indent=2) + '\n')
print('Sealed', len(rows), 'existing proof files; future narrative/outer seal/default-review result channels are outside this catalog.')

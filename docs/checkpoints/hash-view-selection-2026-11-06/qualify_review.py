"""Preserve the actual failed reviewer; qualify its missing typed-error assertion."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-selection-2026-11-06')
target = BASE / 'review_qualified.py'
assert not target.exists(), 'one-shot review qualification'
original = (BASE / 'review.py').read_text()
needle = "if phase == 'intake' and identifier in VIEW_RED:\n"
assert original.count(needle) == 1
qualified = original.replace(needle, needle + "            assert isinstance(row['native_error'], dict), 'typed actual error object required'\n")
needle = 'def main():\n'
assert qualified.count(needle) == 1
qualified = qualified.replace(needle, needle + '''    for path, expected in json.loads((ROOT / BASE / 'qualification-input-identities.json').read_bytes()).items():
        raw = (ROOT / path).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected['sha256'] and len(raw) == expected['bytes']
''')
target.write_text(qualified)
for name in ('review-result.json', 'review-stderr.log'):
    path = BASE / name
    raw = path.read_bytes()
    packed = gzip.compress(raw, mtime=0)
    destination = Path(str(path) + '.gz')
    assert not destination.exists()
    destination.write_bytes(packed)
    assert gzip.decompress(destination.read_bytes()) == path.read_bytes()
    path.unlink()
paths = [BASE / name for name in ('review.py', 'review_qualified.py', 'qualify_review.py',
          'sealed-identities.json', 'review-result.json.gz', 'review-stderr.log.gz')]
records = {}
for path in paths:
    raw = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
(BASE / 'qualification-input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Original failed reader/full channels retained; qualified type assertion and producer inputs bound')

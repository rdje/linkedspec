"""Remove an unused redirected output mistakenly enumerated before publication."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
path = ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
original = path.read_bytes()
saved = HERE / 'implementation-overdeclared-callable-claim.json.gz'
assert not saved.exists(), 'one-shot declaration qualification'
record = json.loads(original)
claim = record['claims'][5]
assert claim['name'] == 'callable-prepared-index-and-count-snapshot-source-custody'
inputs = claim['durability']['inputs']
name = (HERE / 'callable-publication-result.json').relative_to(ROOT).as_posix()
row, = [row for row in inputs if row['path'] == name]
assert row['sha256'] == hashlib.sha256(b'').hexdigest() and row['role'] == 'input'
assert (ROOT / name).read_bytes() != b''
saved.write_bytes(gzip.compress(original, mtime=0))
empty = HERE / 'callable-publication-empty-output.gz'
assert not empty.exists()
empty.write_bytes(gzip.compress(b'', mtime=0))
inputs.remove(row)
for item in (saved, empty, Path(__file__)):
    inputs.append(dict(path=item.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(item.read_bytes()).hexdigest(),
                       role='producer' if item.suffix == '.py' else 'input'))
inputs.sort(key=lambda row: row['path'])
claim['scope'] += ' The first supplement writer accidentally enumerates its own shell-redirected, then-empty output among unused checkpoint files. Preserve that declaration and empty byte stream, remove only this unused output row, and retain this qualifier; no producer/source/result hash is refreshed and no first-publication completeness credit is claimed.'
path.write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps(dict(result='qualified', removed_unused_empty_output=name, retained_original=True), sort_keys=True))

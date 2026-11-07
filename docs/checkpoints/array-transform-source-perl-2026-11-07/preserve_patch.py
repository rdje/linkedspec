"""Preserve exact unified-diff bytes in gzip before removing the text artifact."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
source = BASE / 'source.patch'
raw = source.read_bytes()
digest = hashlib.sha256(raw).hexdigest()
target = BASE / 'source.patch.gz'
assert not target.exists()
target.write_bytes(gzip.compress(raw, mtime=0))
assert gzip.decompress(target.read_bytes()) == raw
logical = str(source.relative_to(Path.cwd()))
for name in ('readonly_review', 'result_preservation_review'):
    records = json.loads((BASE / name / 'input-identities.json').read_bytes())
    assert records[logical] == dict(bytes=len(raw), sha256=digest)
mapping = dict(logical_path=logical, storage_path=str(target.relative_to(Path.cwd())),
               encoding='gzip', bytes=len(raw), sha256=digest,
               reason='Valid unified-diff blank context has trailing spaces; preserve original bytes without a whitespace exemption')
(BASE / 'patch-storage.json').write_text(json.dumps(mapping, indent=2) + '\n')
assert gzip.decompress(target.read_bytes()) == source.read_bytes()
source.unlink()
assert not source.exists() and target.is_file()
print('Original unified diff copied, independently recovered, then exact text artifact removed; original input records unchanged')

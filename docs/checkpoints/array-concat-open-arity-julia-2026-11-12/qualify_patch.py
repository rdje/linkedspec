"""Retain/read exact diff bytes compressed before removing only their plain copy."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
source = BASE / 'source.diff'
target = BASE / 'source.diff.gz'
assert source.is_file() and not source.is_symlink() and not target.exists()
assert source.stat().st_dev == ROOT.stat().st_dev
body = source.read_bytes()
row = json.loads((BASE / 'sealed-identities.json').read_bytes())[str(source)]
assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
assert b'\n \n' in body, 'unified diff blank context precondition'
mode = source.stat().st_mode & 0o777
target.write_bytes(gzip.compress(body, mtime=0))
assert gzip.decompress(target.read_bytes()) == body and target.stat().st_dev == ROOT.stat().st_dev
receipt = dict(source=str(source), retained=str(target), original_bytes=len(body),
    original_sha256=row['sha256'], original_mode=mode,
    compressed_bytes=target.stat().st_size, compressed_sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
    scope='Exact already-sealed unified diff bytes/full original mode. Readback precedes deletion of this one plain duplicate; original seal, producers, archives and first readonly0 remain unchanged.')
(BASE / 'patch-retention.json').write_text(json.dumps(receipt, indent=2, sort_keys=True) + '\n')
assert source.read_bytes() == gzip.decompress(target.read_bytes())
source.unlink()
assert not source.exists()
print(json.dumps(dict(patch_retention='PASS', exact_original_sha256=row['sha256'], plain_duplicate_absent=True)))

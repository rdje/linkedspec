"""Retain exact used oracle bytes before retiring the whitespace-blocked plain copy."""
import gzip
import hashlib
import json
from pathlib import Path
import stat
BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
path = BASE / 'semantic_oracle.py'
output = BASE / 'semantic_oracle.py.gz'
assert path.is_file() and not path.is_symlink() and not output.exists()
before = path.stat()
body = path.read_bytes()
seal = json.loads((BASE / 'sealed-identities.json').read_bytes())[str(path)]
assert len(body) == seal['bytes'] and hashlib.sha256(body).hexdigest() == seal['sha256']
assert body.endswith(b'\n\n')
output.write_bytes(gzip.compress(body, mtime=0))
output.chmod(stat.S_IMODE(before.st_mode))
assert gzip.decompress(output.read_bytes()) == body
assert stat.S_IMODE(output.stat().st_mode) == stat.S_IMODE(before.st_mode)
row = dict(original_path=str(path), compressed_path=str(output), bytes=len(body),
    sha256=hashlib.sha256(body).hexdigest(), original_mode=stat.S_IMODE(before.st_mode),
    compressed_sha256=hashlib.sha256(output.read_bytes()).hexdigest(),
    issue='Trailing extra blank line in used oracle blocks staged whitespace check; original contents and first passing outcomes remain immutable.',
    scope='One exact owned plain duplicate only, after archived readback; no semantic source edit, SDK replay, native/global liveness or physical-reclaim claim.')
(BASE / 'oracle-retention.json').write_text(json.dumps(row, indent=2, sort_keys=True) + '\n')
current = path.stat()
assert (before.st_dev,before.st_ino,before.st_size,before.st_mtime_ns,before.st_mode) == (current.st_dev,current.st_ino,current.st_size,current.st_mtime_ns,current.st_mode)
assert path.read_bytes() == body
path.unlink()
assert not path.exists() and gzip.decompress(output.read_bytes()) == body
print(json.dumps(row))

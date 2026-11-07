"""Copy/verify/delete only the exact raw argv snapshot; never rewrite its bytes."""
import gzip
import hashlib
import json
import os
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
source = BASE / 'commit-correction/processes-before-termination.json'
target = Path(str(source) + '.gz')
mapping = BASE / 'commit-correction/process-storage.json'
assert source.is_file() and not source.is_symlink() and not target.exists() and not mapping.exists()
body = source.read_bytes()
mode = source.stat().st_mode & 0o777
target.write_bytes(gzip.compress(body, mtime=0))
os.chmod(target, mode)
assert gzip.decompress(target.read_bytes()) == body
assert source.stat().st_dev == target.stat().st_dev == Path.cwd().stat().st_dev
mapping.write_text(json.dumps(dict(owner='TYPE-REFERENCE-BOOK.1.2.23.3.78.2',
    logical_path=str(source), physical_path=str(target), sha256=hashlib.sha256(body).hexdigest(),
    bytes=len(body), original_mode=mode, carrier_sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
    role='Inert historical process observation only; never a repository locator or executable command source.'), indent=2) + '\n')
assert source.read_bytes() == body
source.unlink()
assert not source.exists() and gzip.decompress(target.read_bytes()) == body
print('exact raw argv bytes/mode preserved in verified same-volume gzip; only original text carrier removed')

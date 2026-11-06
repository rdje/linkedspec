"""Append lossless identities for the completed distinguishing numeric-source phase."""
import gzip
import hashlib
import json
from pathlib import Path
BASE = Path(__file__).parent.relative_to(Path.cwd())
records = json.loads((BASE / "raw-identities.json").read_text())
assert (BASE / "producer-seeds/exit.txt").read_text() == "0\n"
for channel in ("stdout", "stderr"):
    path = BASE / "producer-seeds" / (channel + ".log")
    assert str(path) not in records
    body = path.read_bytes(); capsule = gzip.compress(body, mtime=0)
    target = Path(str(path) + ".gz"); assert not target.exists()
    target.write_bytes(capsule)
    assert gzip.decompress(target.read_bytes()) == body == path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), capsule=str(target), capsule_sha256=hashlib.sha256(capsule).hexdigest())
    path.unlink()
(BASE / "raw-identities.json").write_text(json.dumps(records, indent=2, sort_keys=True) + "\n")
print("Numeric-source raw channels appended losslessly; prior capsule identities unchanged")

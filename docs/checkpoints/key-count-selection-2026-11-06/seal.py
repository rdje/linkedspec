"""Losslessly seal completed owned raw key-count intake channels."""
import gzip
import hashlib
import json
from pathlib import Path
BASE = Path(__file__).parent.relative_to(Path.cwd())
records = {}
for phase in ("initial", "diagnostics", "preservation", "seeds"):
    assert (BASE / phase / "exit.txt").read_text() == "0\n", "completed captures only"
    for channel in ("stdout", "stderr"):
        path = BASE / phase / (channel + ".log")
        body = path.read_bytes()
        capsule = gzip.compress(body, mtime=0)
        assert gzip.decompress(capsule) == body
        target = Path(str(path) + ".gz")
        assert not target.exists(), "one shot only"
        target.write_bytes(capsule)
        assert gzip.decompress(target.read_bytes()) == path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), capsule=str(target), capsule_sha256=hashlib.sha256(capsule).hexdigest())
        path.unlink()
(BASE / "raw-identities.json").write_text(json.dumps(records, indent=2, sort_keys=True) + "\n")
print("All completed raw channels sealed losslessly; no observation filtered")

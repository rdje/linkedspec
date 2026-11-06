"""Seal only completed owned source-domain raw channels losslessly."""
import gzip
import hashlib
import json
from pathlib import Path
BASE = Path(__file__).parent.relative_to(Path.cwd())
records = {}
for phase in ("before", "after", "nearest"):
    assert (BASE / phase / "normal-exit.txt").is_file()
    tags = ("normal", "owner-syntax") if phase == "after" else ("normal",)
    modules = {}
    for path in sorted((BASE / phase / "modules").glob("*.gz")):
        capsule = path.read_bytes(); body = gzip.decompress(capsule)
        modules[str(path)] = dict(sha256=hashlib.sha256(capsule).hexdigest(), mode=path.stat().st_mode & 0o777, raw_sha256=hashlib.sha256(body).hexdigest(), raw_bytes=len(body))
    assert len(modules) == 25
    (BASE / phase / "module-identities.json").write_text(json.dumps(modules, indent=2, sort_keys=True) + "\n")
    for tag in tags:
        assert (BASE / phase / (tag + "-exit.txt")).is_file()
        for channel in ("stdout", "stderr"):
            path = BASE / phase / (tag + "-" + channel + ".log")
            body = path.read_bytes(); capsule = gzip.compress(body, mtime=0)
            target = Path(str(path) + ".gz"); assert not target.exists()
            target.write_bytes(capsule)
            assert gzip.decompress(target.read_bytes()) == body == path.read_bytes()
            records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), capsule=str(target), capsule_sha256=hashlib.sha256(capsule).hexdigest())
            path.unlink()
(BASE / "raw-identities.json").write_text(json.dumps(records, indent=2, sort_keys=True) + "\n")
print("Full completed source-domain channels sealed losslessly; actual pre-run module files retained")

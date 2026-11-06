"""Seal completed owned raw channels and actual pre-load emitted/parsed files."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd()
BASE = Path(__file__).parent.relative_to(ROOT)
raw_records = {}
for phase in ("probe-before", "normal-before", "normal-after", "probe-after", "final"):
    out = BASE / phase
    assert (out / "exit.txt").is_file(), "never seal a running phase"
    records = {}
    artifact_root = out if phase.startswith("probe-") else out / "normal-artifacts"
    paths = sorted((artifact_root / "emitted").glob("*.jl")) + sorted((artifact_root / "parsed").glob("*.json"))
    assert len(paths) == 48
    archive_path = out / "actual-emitted-parsed.tar.gz"
    assert not archive_path.exists(), "one shot only"
    with tarfile.open(archive_path, "w:gz") as archive:
        for path in paths:
            body = path.read_bytes()
            records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    with tarfile.open(archive_path) as archive:
        assert archive.getnames() == [str(p) for p in paths]
        for path in paths:
            assert archive.extractfile(str(path)).read() == path.read_bytes()
    (out / "artifact-identities.json").write_text(json.dumps(records, indent=2, sort_keys=True) + "\n")
    for path in paths:
        path.unlink()
    for name in ("emitted", "parsed"):
        (artifact_root / name).rmdir()
    if artifact_root != out:
        artifact_root.rmdir()
    for name in ("stdout.log", "stderr.log"):
        path = out / name
        body = path.read_bytes()
        capsule = gzip.compress(body, mtime=0)
        assert gzip.decompress(capsule) == body
        destination = Path(str(path) + ".gz")
        assert not destination.exists()
        destination.write_bytes(capsule)
        assert gzip.decompress(destination.read_bytes()) == path.read_bytes()
        raw_records[str(path)] = dict(capsule=str(destination), capsule_sha256=hashlib.sha256(capsule).hexdigest(), sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
        path.unlink()
(BASE / "raw-identities.json").write_text(json.dumps(raw_records, indent=2, sort_keys=True) + "\n")
print("Completed channels sealed losslessly; actual emitted/parsed payloads recover byte-exactly")

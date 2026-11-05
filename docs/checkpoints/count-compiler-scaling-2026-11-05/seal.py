"""One-shot lossless compression of this leaf's actual observation channels."""
import gzip
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
emitted = HERE / "normal/emitted"
with tarfile.open(HERE / "normal/emitted.tar.gz", "x:gz") as archive:
    for path in sorted(emitted.iterdir()):
        archive.add(path, arcname=path.name, recursive=False)
with tarfile.open(HERE / "normal/emitted.tar.gz") as archive:
    for member in archive.getmembers():
        path = emitted / member.name
        assert archive.extractfile(member).read() == path.read_bytes()
        path.unlink()
emitted.rmdir()
for path in HERE.rglob("*"):
    if path.suffix not in (".stdout", ".stderr", ".tap", ".log"):
        continue
    raw = path.read_bytes()
    target = path.with_name(path.name + ".gz")
    assert not target.exists()
    target.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(target.read_bytes()) == raw
    path.unlink()

"""One-shot exact recovery-stream partition; copy, verify, use, remove duplicates."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c
import storage_partition as storage

PREFIX = storage.PREFIX
SELF = PREFIX + "partition_storage_inventory.py"
WRAPPER = PREFIX + "review_storage.py"
limit = 16 * 1024 * 1024


def write_new(path, value, packed=False):
    raw = (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()
    target = c.ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("xb") as output:
        output.write(gzip.compress(raw, mtime=0) if packed else raw)


baseline = c.run(["bash", "tools/run_python_project_data.sh", PREFIX + "storage_inventory.py"])
assert baseline["returncode"] == 0
before = dict(base=c.BASE, originals={path: dict(**c.identity(path), size=c.source(path).stat().st_size)
    for path in storage.INDEXES},
    sources={path: c.read(path) for path in (SELF, WRAPPER, PREFIX + "storage_partition.py",
        PREFIX + "storage_inventory.py", storage.PRODUCER, c.PREFIX + "common.py")},
    baseline=baseline, ignore=c.read(".gitignore"), task=c.read("docs/tasks/TYPE-REFERENCE-BOOK.md"),
    scope="Exact raw gzip streams, not regenerated observations. Retain the measured logical byte counts, hashes and modes before changing physical representation. The existing generic checkpoint reader owns chunk parsing and path guards.")
write_new(PREFIX + "storage-partition-before.json", before)
reader, _ = storage.physical_reader()
rows = []
for logical, index_path in storage.INDEXES.items():
    original = c.source(logical)
    parts, total = [], 0
    with original.open("rb") as stream:
        while payload := stream.read(limit):
            number = len(parts)
            part_path = str(Path(index_path).parent / f"part-{number:03d}.json.gz")
            write_new(part_path, dict(version=1, payload_base64=c.encode(payload)), packed=True)
            target = c.source(part_path)
            target.chmod(0o644)
            assert target.stat().st_size <= 32 * 1024 * 1024
            parts.append(dict(path=part_path, file_sha256=c.sha(target.read_bytes()),
                payload_sha256=c.sha(payload), size=len(payload), mode=0o644, offset=total, number=number))
            total += len(payload)
    expected = before["originals"][logical]
    index = dict(version=1, logical_path=logical, sha256=expected["sha256"],
        size=expected["size"], mode=expected["mode"], parts=parts)
    write_new(index_path, index)
    data, mode, actual = reader.read_partition(index_path)
    assert actual == index and data == original.read_bytes() and mode == expected["mode"]
    rows.append(dict(path=logical, parts=len(parts), **expected))
write_new(PREFIX + "storage-partition-copy.json", dict(originals=rows,
    payload_limit=limit, physical_limit=32 * 1024 * 1024,
    scope="Both original streams still exist; every physical/payload/whole identity and mode matches before any duplicate removal."))
# Actual bad chunk metadata must be denied by the retained generic reader.
index_path = next(iter(storage.INDEXES.values()))
target = c.source(index_path)
index_raw = target.read_bytes()
index = json.loads(index_raw)
denials = []
for name in ("missing", "reordered", "payload_hash"):
    faulty = json.loads(index_raw)
    if name == "missing":
        faulty["parts"].pop()
    elif name == "reordered":
        faulty["parts"][0], faulty["parts"][1] = faulty["parts"][1], faulty["parts"][0]
    else:
        faulty["parts"][0]["payload_sha256"] = "0" * 64
    target.write_bytes((json.dumps(faulty, sort_keys=True, separators=(",", ":")) + "\n").encode())
    try:
        try:
            reader.read_partition(index_path)
        except AssertionError:
            denials.append(name)
        else:
            raise RuntimeError("bad checkpoint index survived: " + name)
    finally:
        target.write_bytes(index_raw)
assert len(denials) == 3
backup_root = c.ROOT / ".linkedspec-data/verification/signed-storage-originals"
assert not backup_root.exists()
backup_root.mkdir()
backups = {}
for logical in storage.INDEXES:
    source = c.source(logical)
    backup = backup_root / source.name
    source.rename(backup)
    backups[logical] = backup
after = c.run(["bash", "tools/run_python_project_data.sh", WRAPPER])
write_new(PREFIX + "storage-partition-use.json", dict(command=after, denials=denials,
    scope="Original aliases were moved aside before the actual unchanged retained reader ran through chunk recovery. Complete stdout/stderr are compared with the original direct invocation."))
assert after["returncode"] == 0
assert after["stdout_base64"] == baseline["stdout_base64"] and after["stderr_base64"] == baseline["stderr_base64"]
for logical, backup in backups.items():
    expected = before["originals"][logical]
    assert c.identity(logical) == {key: expected[key] for key in ("sha256", "mode")}
    assert backup.stat().st_size == expected["size"]
    assert c.sha(backup.read_bytes()) == expected["sha256"]
    backup.unlink()
backup_root.rmdir()
ignore = Path(".gitignore")
text = ignore.read_text()
for logical in storage.INDEXES:
    assert "/" + logical not in text.splitlines()
    text += "/" + logical + "\n"
ignore.write_text(text)
write_new(PREFIX + "storage-partition-final.json", dict(originals=rows, denials=denials,
    restored=storage.ensure_all(), ignore=c.read(".gitignore"),
    duplicate_backups_absent=not backup_root.exists(),
    scope="Only byte-verified duplicate backups were removed after actual retained-reader success. Two regenerated aliases remain ignored on the repository volume; bounded tracked chunks preserve every original byte and mode."))
print("Exact storage partition PASS:", len(rows), "streams;", sum(row["parts"] for row in rows), "chunks; three actual denials; unchanged reader output")

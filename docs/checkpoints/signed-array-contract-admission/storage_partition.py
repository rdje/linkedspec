"""Restore two exact recovery aliases using the existing checkpoint chunk reader."""
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import common as c

PREFIX = "docs/checkpoints/signed-array-contract-admission/"
PRODUCER = "docs/checkpoints/type-values-selector/partition_storage.py"
INDEXES = {
    PREFIX + "storage-before.json.gz": PREFIX + "storage-parts/before/index.json",
    PREFIX + "storage-documentation-before.json.gz": PREFIX + "storage-parts/documentation/index.json",
}


def physical_reader():
    before = json.loads((c.ROOT / PREFIX / "storage-partition-before.json").read_bytes())
    assert c.read(PRODUCER) == before["sources"][PRODUCER]
    assert c.read(PREFIX + "storage_partition.py") == before["sources"][PREFIX + "storage_partition.py"]
    spec = importlib.util.spec_from_file_location("signed_storage_physical", c.source(PRODUCER))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module, before


def ensure_all():
    reader, before = physical_reader()
    assert set(before["originals"]) == set(INDEXES)
    restored = []
    for logical, index_path in INDEXES.items():
        data, mode, index = reader.read_partition(index_path)
        expected = before["originals"][logical]
        assert index["logical_path"] == logical
        assert dict(sha256=c.sha(data), size=len(data), mode=mode) == expected
        assert all((c.ROOT / part["path"]).stat().st_size <= 32 * 1024 * 1024 for part in index["parts"])
        target = reader.checked_target(logical)
        if not target.exists():
            scratch = Path(os.environ["TMPDIR"])
            assert scratch.resolve().is_relative_to(c.ROOT) and scratch.stat().st_dev == c.ROOT.stat().st_dev
            temporary = None
            try:
                with tempfile.NamedTemporaryFile(dir=scratch, delete=False) as output:
                    temporary = Path(output.name)
                    output.write(data)
                    output.flush()
                    os.fsync(output.fileno())
                    os.fchmod(output.fileno(), mode)
                os.link(temporary, target)
            finally:
                if temporary is not None:
                    temporary.unlink(missing_ok=True)
            restored.append(logical)
        assert c.identity(logical) == {key: expected[key] for key in ("sha256", "mode")}
        assert target.stat().st_size == expected["size"]
    return restored

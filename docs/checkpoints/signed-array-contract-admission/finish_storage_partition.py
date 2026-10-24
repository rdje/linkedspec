"""One-shot continuity for the verified physical recovery migration."""
import gzip
import json
from pathlib import Path
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c
import storage_partition as storage

PREFIX = storage.PREFIX
TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
CARD = "docs/knowledge/tool-project-data-ssd-storage.md"
paths = [TREE, CARD, PREFIX + "README.md", "CHANGES.md", "DEVELOPMENT_NOTES.md", "MEMORY.md"]
copy = json.loads(c.source(PREFIX + "storage-partition-copy.json").read_bytes())
use = json.loads(c.source(PREFIX + "storage-partition-use.json").read_bytes())
final = json.loads(c.source(PREFIX + "storage-partition-final.json").read_bytes())
assert use["command"]["returncode"] == 0 and len(use["denials"]) == 3
assert final["duplicate_backups_absent"] and not storage.ensure_all()
assert sum(row["parts"] for row in copy["originals"]) == 24
packet = dict(producer=c.read(PREFIX + "finish_storage_partition.py"),
    inputs={path: c.read(path) for path in paths},
    immutable_inputs={path.relative_to(c.ROOT).as_posix(): c.identity(path.relative_to(c.ROOT).as_posix())
        for path in (c.ROOT / PREFIX / "storage-parts").rglob("*") if path.is_file()},
    sources={path: c.read(path) for path in (PREFIX + "storage_partition.py", c.PREFIX + "common.py")},
    scope="Plain mutable sources are retained whole; immutable gzip/chunk inputs are hash-gated without recursively embedding them. Original logical streams retain their exact raw bytes and modes.")
with (c.ROOT / PREFIX / "storage-partition-documentation-before.json.gz").open("xb") as output:
    output.write(gzip.compress((json.dumps(packet, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))
p = Path(TREE)
text = p.read_text().replace("Status: `active` / exact recovery-archive partition",
    "Status: `completed` / neutral target, source custody and bounded storage enrollment", 1)
start = text.index("- ID: `" + c.OWNER + "`")
end = text.index("- ID: ", start + 5)
node = text[start:end]
node += "  Recovery representation closure: Both raw gzip streams retain exact whole bytes/counts/modes through24 bounded payload chunks and independent physical/payload/whole hashes. Three actually altered indexes reject and restore. Original aliases are moved aside before the unchanged retained reader executes through actual chunk reconstruction; complete output equals the original direct run. Only verified duplicate backups are removed afterward. Two exact ignored aliases are reproducible from committed chunks alone. The existing generic partition reader is retained at its original source identity; no old observation or producer is edited. Current review: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract-admission/review_storage.py. New input snapshots hash-gate immutable gzip/part inputs instead of recursively embedding them.\n\n"
p.write_text(text[:start] + node + text[end:])
p = Path(CARD)
text = p.read_text()
text = text.replace("Source/Git census and three record denials: docs/checkpoints/signed-array-contract-admission/storage_inventory.py.",
    "Source/Git census and three record denials: docs/checkpoints/signed-array-contract-admission/review_storage.py; exact ignored recovery aliases rehydrate from bounded tracked chunks.", 1)
p.write_text(text)
p = Path("MEMORY.md")
text = p.read_text().replace("retained separately in admission/storage packets.",
    "retained separately in admission/storage packets; review_storage.py restores two exact ignored aliases from24 bounded chunks before unchanged review.", 1)
p.write_text(text)
paragraph = "\n\nRecovery storage: preserve both oversized raw gzip streams through24 bounded chunks, exact whole hashes/counts/modes and physical/payload hashes. Three altered indexes reject; the unchanged retained reader executes using actually reconstructed aliases and returns byte-identical output. Remove only verified duplicate backups afterward; two exact aliases remain ignored and reproducible from committed chunks. Current command: docs/checkpoints/signed-array-contract-admission/review_storage.py under the project Python wrapper. Original measurements/producers are unchanged. Later snapshots gate immutable archive/chunk identities without recursive copies.\n"
for name in ("CHANGES.md", "DEVELOPMENT_NOTES.md"):
    p = Path(name)
    text = p.read_text()
    first = text.index("\n## 2026-10-24")
    end = text.index("\n## ", first + 2)
    p.write_text(text[:end].rstrip() + paragraph + text[end:])
p = Path(PREFIX + "README.md")
text = p.read_text()
text = text.replace("Read-only review:\n\n    bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract-admission/storage_inventory.py",
    "Current review (rehydrates ignored aliases, then runs the unchanged reader):\n\n    bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract-admission/review_storage.py", 1)
text += "\n## Exact recovery representation\n\nThe complete failed staged patch made storage-before191,179,508 bytes; the\nlater documentation snapshot also copied that immutable stream. These original\nraw gzip bytes now survive through24 bounded chunks in storage-parts/. Indexes\ngate physical/payload/whole hashes, sizes, order and original modes. The generic\nreader comes from the accepted type-values-selector checkpoint and is retained\nby source identity; it is unchanged.\n\npartition_storage_inventory.py copies and verifies before moving original aliases\naside. Three actually altered indexes reject. review_storage.py then reconstructs\nboth aliases and executes the unchanged storage_inventory.py; full output equals\nthe original direct run. Only byte-verified duplicate backups are removed after\nthat success. Two exact regenerated aliases are ignored; committed chunks alone\nrecover them. The wrapper may create those aliases on the repository volume,\nthen performs the read-only historical review. It never recaptures observations.\n\nNever rerun partition_storage_inventory.py, finish_storage_inventory.py or\nfinish_storage_partition.py. New snapshots retain plain mutable source overlays\nand hash-gate immutable gzip/chunk inputs; they do not recursively copy them.\nThe storage-partition-before/copy/use/final records preserve the migration.\n"
p.write_text(text)
generated = c.run(["bash", "knowledge-map/scripts/gen_knowledge_map.sh"])
assert generated["returncode"] == 0
with (c.ROOT / PREFIX / "storage-partition-documentation.json.gz").open("xb") as output:
    output.write(gzip.compress((json.dumps(dict(generator=generated, chunks=24,
        scope="Physical representation and current review pointers only; fresh exact staged canonical CI remains required."), sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))
print("Exact recovery representation documented; immutable inputs were not recursively copied")

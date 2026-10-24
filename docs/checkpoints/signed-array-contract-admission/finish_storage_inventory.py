"""One-shot documentation after the captured storage repair; never rerun."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c
import storage_inventory as review

PREFIX = review.PREFIX
TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
CARD = "docs/knowledge/tool-project-data-ssd-storage.md"
BOOK = "docs/linkedspec-book/src/development/local-ci-and-regression.md"
paths = [TREE, CARD, BOOK, "CHANGES.md", "DEVELOPMENT_NOTES.md", "MEMORY.md",
    "LIVE_ACHIEVEMENT_STATUS.md", "ROADMAP.md", "docs/TASK_TREE.md", PREFIX + "README.md"]
verified = review.check()
reader = review.load("storage-reader.json.gz")
assert reader["result"] == verified and reader["command"]["returncode"] == 0
assert json.loads(c.decode(reader["command"]["stdout_base64"])) == verified
before = review.load("storage-before.json.gz")
packet = dict(producer=c.read(PREFIX + "finish_storage_inventory.py"),
    inputs={path: c.read(path) for path in paths},
    sources={path: c.read(path) for path in (review.SELF, c.PREFIX + "common.py")},
    evidence={PREFIX + name: c.read(PREFIX + name) for name in
        ("storage-before.json.gz", "storage-result.json.gz", "storage-reader.json.gz")},
    verified=verified, scope="Continuity/public operational teaching only after actual storage PASS; sealed48-input neutral evidence and all historical observations remain unchanged.")


def write_new(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()
    with (c.ROOT / PREFIX / name).open("xb") as output:
        output.write(gzip.compress(raw, mtime=0))


write_new("storage-documentation-before.json.gz", packet)
p = Path(TREE)
text = p.read_text()
start = text.index("- ID: `" + c.OWNER + "`")
end = text.index("- ID: ", start + 5)
node = text[start:end].replace("Status: `active` / canonical storage-inventory repair",
    "Status: `completed` / neutral target, validator custody and storage enrollment", 1)
node = node.replace("  Focused checks: ",
    "  Focused checks: Actual storage census/direct FAIL-PASS and signed-checker hostile-root wrapper execution; ", 1)
node += "  Storage integration closure: The actual unchanged direct oracle rejects42/43; independently accepted9dd5e3555 source bytes identify42 old entrypoints and the signed checker as the sole addition. Enroll43 and explicitly execute the new checker under hostile-root managed-wrapper controls. The full storage oracle exits0; four Python temporary owners and15 shell allocator owners remain unchanged. The source-bound reader rejects missing-checker, incomplete-population and relabelled-failure records. Full original canonical4 log/candidate, all Python/shell source images, actual actors/imports and before/after channels survive; the48-input neutral publication remains unchanged and passes. This is an integration correction, with no new runtime admission. Fresh exact staged canonical CI is required; canonical4 supplies no complete receipt. Read-only: docs/checkpoints/signed-array-contract-admission/storage_inventory.py.\n\n"
p.write_text(text[:start] + node + text[end:])
memory = c.decode(before["continuity"]["MEMORY.md"]["base64"]).decode()
memory = memory.replace("Three original instrument qualifications earn no product RED.",
    "Three original instrument qualifications earn no product RED. Storage enrollment43/4/15 and actual direct FAIL-PASS are retained separately in admission/storage packets.", 1)
Path("MEMORY.md").write_text(memory)
paragraph = ("\n\nStorage integration: canonical4 reaches and fails the exact Python-entrypoint census42/43 after CLI12 passes. "
    "Preserve its whole log/candidate and all census sources before enrolling the signed checker, the sole addition against accepted9dd5e3555. "
    "The full direct oracle now passes with explicit hostile-root managed-wrapper execution; four Python temporary owners and15 shell allocator owners remain unchanged. "
    "Three corrupt-record controls reject. The sealed48-input neutral publication is unchanged. "
    "Fresh exact staged canonical proof remains required. Evidence: docs/checkpoints/signed-array-contract-admission/storage-before.json.gz and storage-result.json.gz; read-only storage_inventory.py.\n")
for name in ("CHANGES.md", "DEVELOPMENT_NOTES.md"):
    p = Path(name)
    text = p.read_text()
    first = text.index("\n## 2026-10-24")
    next_record = text.index("\n## ", first + 2)
    p.write_text(text[:next_record].rstrip() + paragraph + text[next_record:])
p = Path(CARD)
text = p.read_text().replace("date: 2026-10-20", "date: 2026-10-24", 1)
needle = "reverify: "
offset = text.index(needle)
text = text[:offset] + 'evidence_update_2026_10_24_signed_array: "TYPE-REFERENCE-BOOK.1.2.17.1 enrolls the sole added signed checker after actual census42/43 rejection. The full storage oracle passes with explicit hostile-root wrapper execution; allocator memberships stay unchanged. Source/Git census and three record denials: docs/checkpoints/signed-array-contract-admission/storage_inventory.py."\n' + text[offset:]
p.write_text(text)
p = Path(BOOK)
text = p.read_text()
needle = "It freezes the actual Python temporary-owner, shell allocator and Python-entrypoint inventories."
assert text.count(needle) == 1
text = text.replace(needle, needle + " A new Python checker entrypoint must be enrolled after comparing the complete source population with the previous accepted tree; temporary-owner membership is checked separately. The signed-array-selector checker also runs through the managed wrapper with hostile scratch/cache overrides, proving that its imports and output remain on repository storage.", 1)
p.write_text(text)
p = Path(PREFIX + "README.md")
text = p.read_text()
text += "\n## Signed-checker storage enrollment\n\nCanonical4 finishes the selected CLI12 checks and then rejects the exact Python\nentrypoint census42/43. It produces no complete canonical receipt.\n\nRe-derive: storage-before retains the full failed staged binary diff/base, opaque\ncanonical log, all Python/shell census sources, actual actors/imports, current\ncontinuity and unchanged neutral outputs. A distinct actual direct run fails.\nThe accepted Git source population has42 entrypoints; the sole added path is\ntools/check_signed_array_selector_contract.py. The repaired full storage oracle\npasses at43, including actual managed-wrapper execution of that checker under\nhostile root overrides. Four Python temporary owners and15 shell allocator\nowners retain their exact memberships.\n\nFalsify: the old42 predicate actually rejects the new43 population before edits.\nThe read-only reviewer independently checks accepted Git bytes and the complete\nsource populations, and rejects missing-checker, incomplete-population and\nrelabelled-failure records. These are finite integration/record controls, not\nnew backend admission or exhaustive allocator analysis.\n\nDurability: storage-before/result/reader packets retain the actual producers,\nsource images, complete candidate and execution channels. repair_storage_inventory.py\nand finish_storage_inventory.py are historical writers; never rerun them. The\nsealed48-input neutral publication remains byte-identical and passes before/after.\nFresh exact staged canonical CI still governs landing. Read-only review:\n\n    bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract-admission/storage_inventory.py\n"
p.write_text(text)
for name in ("LIVE_ACHIEVEMENT_STATUS.md", "ROADMAP.md", "docs/TASK_TREE.md"):
    p = Path(name)
    text = p.read_text()
    needle = "Fresh exact staged canonical"
    assert needle in text
    text = text.replace(needle, "Storage census enrollment and hostile-root execution pass with unchanged allocator membership. Fresh exact staged canonical", 1)
    p.write_text(text)
generator = c.run(["bash", "knowledge-map/scripts/gen_knowledge_map.sh"])
assert generator["returncode"] == 0
write_new("storage-documentation.json.gz", dict(verified=verified, generator=generator,
    scope="Storage integration teaching and intended clean handoff prepared; canonical5 must validate the exact newly staged candidate."))
print("Storage integration documented; sealed neutral48 unchanged; exact canonical5 remains required")

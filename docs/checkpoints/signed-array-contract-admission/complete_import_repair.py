"""One-shot continuity after the byte-complete validator import repair."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c
import import_epoch

ADMISSION = "docs/checkpoints/signed-array-contract-admission/"
TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
CARD = "docs/knowledge/write-vivification-neutral-contract.md"
paths = {"CHANGES.md", "DEVELOPMENT_NOTES.md", "MEMORY.md", "LIVE_ACHIEVEMENT_STATUS.md",
    "ROADMAP.md", "docs/TASK_TREE.md", TREE, CARD, "KNOWLEDGE_MAP.md"}
for name in subprocess.check_output(["git", "ls-files", "docs/claims"]).decode().splitlines():
    for claim in json.loads(Path(name).read_bytes())["claims"]:
        durability = claim["durability"]
        if durability.get("status") == "checked" and durability.get("mode") == "live":
            assert not paths & {item["path"] for item in durability["inputs"]}, name
bundle = c.load("validator-import-sources.json.gz")
import_epoch.verify_sources(bundle, c.load("artifact-controls-inputs.json.gz"))
verified = import_epoch.verify_replays(bundle, c.load("validator-import-replays.json.gz"), c.load("artifact-controls.json.gz"))
before = c.load("validator-import-before.json.gz")
count = len(c.load("publication-inputs.json.gz")["inputs"])
assert count == 48
snapshot = dict(inputs={path: c.read(path) for path in sorted(paths)},
    producer=c.read(ADMISSION + "complete_import_repair.py"), verified=verified,
    scope="Continuity/card only after source custody closes; protected48-input publication remains unchanged. Exact staged canonical CI still gates landing.")
with (c.ROOT / ADMISSION / "import-completion-before.json.gz").open("xb") as output:
    output.write(gzip.compress((json.dumps(snapshot, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))
text = Path(TREE).read_text()
start = text.index("- ID: `" + c.OWNER + "`")
end = text.index("- ID: ", start + 5)
node = text[start:end].replace("Status: `active` / validator import custody repair",
    "Status: `completed` / neutral target and validator source custody", 1)
node += "  Custody closure: Retain the exact recorded pre-artifact_detail reader (SHA ea8c35069e44e70b25ca2485a61a75ff311fc46930eca272c96da0d8b1ed567d), all four project-source modules, actual recovery/replay producers and complete original40-input state. Both module epochs reproduce20 original validator outcomes each (40 exact rc/stdout/stderr comparisons), while the source-identity oracle rejects the later epoch and restores the original. New default source/custody/floor checks and unchanged publisher pass with48 bounded inputs; old cases, targets, book/model/source-fault and validator observations remain unchanged. Original publication/manifest/claim copies are explicitly unpublished raw history, not retroactively accepted Git. Exact canonical candidate must be rerun after this evidence repair; no final credit from interrupted attempt3. Read-only: docs/checkpoints/signed-array-contract/import_epoch.py and the default publisher. Independent admission reader also verifies the original40-input archive and source reconstruction.\n\n"
Path(TREE).write_text(text[:start] + node + text[end:])
memory = c.decode(before["continuity"]["MEMORY.md"]["base64"]).decode()
memory = memory.replace("- proof: ", "- proof: ", 1)
memory = memory.replace("Three instrument qualifications earn no product RED.",
    "Exact original validator import/all four modules and40 replay outcomes are retained; wrong-source identity rejects. Three original instrument qualifications earn no product RED.", 1)
Path("MEMORY.md").write_text(memory)
for name in ("CHANGES.md", "DEVELOPMENT_NOTES.md"):
    p = Path(name)
    text = p.read_text()
    first = text.index("\n## 2026-10-24")
    next_record = text.index("\n## ", first + 2)
    paragraph = (
        "\n\nValidator source custody: the original controls imported an earlier reader than the initially retained file. "
        "Recover it exactly against the recorded SHA, retain all four project modules and actual producers, and replay both epochs:20 outcomes each remain byte-identical while the identity oracle rejects the later source. "
        "Whole original40-input publication/claim/manifest and actual readonly0 precede changes; the reader/README are the only changed old inputs. "
        "Default publication now binds48 inputs and the complete source/replay archive. No original observation is retargeted. "
        "Attempt3 was stopped143 without final canonical credit; fresh exact staged canonical CI remains required. "
        "Evidence: docs/checkpoints/signed-array-contract-admission/import-epoch-before.json.gz and import-epoch-result.json.gz.\n"
    )
    text = text[:next_record].rstrip() + paragraph + text[next_record:]
    p.write_text(text)
text = Path("LIVE_ACHIEVEMENT_STATUS.md").read_text()
text = text.replace("Exact staged canonical CI/normal hooks govern admission.",
    "Validator source custody retains the original imported reader and40 matching replay outcomes; new48-input publication passes. Fresh exact staged canonical CI/normal hooks govern admission.", 1)
Path("LIVE_ACHIEVEMENT_STATUS.md").write_text(text)
for name in ("ROADMAP.md", "docs/TASK_TREE.md"):
    p = Path(name)
    text = p.read_text()
    needle = "Exact staged canonical workflow governs landing;"
    assert needle in text
    text = text.replace(needle, "Original validator import custody/40 isolated replays are closed in the48-input publication. Fresh exact staged canonical workflow governs landing;", 1)
    p.write_text(text)
p = Path(CARD)
text = p.read_text()
question = '  - "can identical validator outcomes establish which source epoch was imported"\n'
assert question not in text
text = text.replace('\ndate: "2026-10-24"', "\n" + question + 'date: "2026-10-24"', 1)
line = next(line for line in text.splitlines() if line.startswith("reverify:"))
assert line.endswith('"')
text = text.replace(line, line[:-1] + " && bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract/import_epoch.py" + '"', 1)
text += "\nThe freeze's original validator import predates its published reader. Both source\nepochs reproduce the same20 control outcomes; the captured source identity still\nrejects the later epoch. `docs/checkpoints/signed-array-contract/import_epoch.py`\nverifies the retained original bytes and four-module closure; the default\npublisher checks the40 actual replay outcomes. Equal results do not identify an\ninstrument's imported source. Whole old state and actual producers remain in the\nvalidator-import packets and admission repair records.\n"
p.write_text(text)
generator = c.run(["bash", "knowledge-map/scripts/gen_knowledge_map.sh"])
assert generator["returncode"] == 0
readonly = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert readonly["returncode"] == 0
with (c.ROOT / ADMISSION / "import-completion.json.gz").open("xb") as output:
    output.write(gzip.compress((json.dumps(dict(verified=verified, generator=generator, readonly=readonly,
        scope="Source-custody completion; current target/runtime scope is unchanged. Final exact staged canonical proof remains required."), sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))
print("Source custody closed and continuity prepared;48-input read-only publication remains GREEN")

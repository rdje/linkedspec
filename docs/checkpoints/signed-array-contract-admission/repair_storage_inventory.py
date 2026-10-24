"""One-shot canonical storage-inventory repair; never rerun after capture."""
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
CONTINUITY = [TREE, CARD, BOOK, "CHANGES.md", "DEVELOPMENT_NOTES.md", "MEMORY.md",
    "LIVE_ACHIEVEMENT_STATUS.md", "ROADMAP.md", "docs/TASK_TREE.md", PREFIX + "README.md"]


def write_new(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()
    with (c.ROOT / PREFIX / name).open("xb") as output:
        output.write(gzip.compress(raw, mtime=0))


assert not c.decode(c.run(["git", "diff", "--name-only"])["stdout_base64"])
assert subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip() == c.BASE
planned = set(CONTINUITY) | {review.RULE}
census = {}
for name in subprocess.check_output(["git", "ls-files", "docs/claims"]).decode().splitlines():
    record = json.loads(Path(name).read_bytes())
    for claim in record["claims"]:
        durability = claim["durability"]
        if durability.get("status") == "checked" and durability.get("mode") == "live":
            inputs = {item["path"] for item in durability["inputs"]}
            assert not planned & inputs, name
            census[name] = c.read(name)
baseline = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert baseline["returncode"] == 0
gate = c.run(["bash", review.RULE])
assert gate["returncode"] == 1
patch = c.run(["git", "diff", "--cached", "--binary", "--full-index"])
assert patch["returncode"] == 0
manifest = c.load("publication-inputs.json.gz")
outputs = [c.PREFIX + name for name in ("publication-inputs.json.gz", "publication.json")]
outputs.append("docs/claims/" + c.OWNER + ".json")
python = sorted(Path("tools").glob("*.py"))
shell = sorted(set(Path("tools").glob("*.sh")) | set(Path("knowledge-map/scripts").glob("*.sh")))
entrypoints = c.run(["rg", "-l", "^#!/usr/bin/env python3$", *map(str, python)])
assert entrypoints["returncode"] == 0
before = dict(base=c.BASE, patch=patch, patch_sha256=c.sha(c.decode(patch["stdout_base64"])),
    rule=c.read(review.RULE), gate=gate,
    entrypoints=sorted(c.decode(entrypoints["stdout_base64"]).decode().splitlines()),
    entrypoint_command=entrypoints,
    python_sources={str(path): c.read(str(path)) for path in python},
    shell_sources={str(path): c.read(str(path)) for path in shell},
    sources={path: c.read(path) for path in (review.SELF, review.ACTOR, c.PREFIX + "common.py")},
    continuity={path: c.read(path) for path in CONTINUITY}, live_claims=census,
    neutral_inputs=manifest["inputs"], neutral_outputs={path: c.read(path) for path in outputs},
    neutral_readonly=baseline,
    canonical_log=c.read(".linkedspec-data/verification/signed-contract-canonical4.log"),
    scope="Canonical4 ended at the exact tool-entrypoint census after CLI12 passed. No completed canonical receipt is claimed. Preserve whole failed candidate, all census producer inputs, original rule and actual direct failure before enrolling the signed checker; the sealed48-input neutral publication is unchanged.")
write_new("storage-before.json.gz", before)
# Establish the expanded path ownership before the storage-test edit.
p = Path(TREE)
text = p.read_text()
start = text.index("- ID: `" + c.OWNER + "`")
end = text.index("- ID: ", start + 5)
node = text[start:end].replace("Status: `completed` / neutral target and validator source custody",
    "Status: `active` / canonical storage-inventory repair", 1)
node = node.replace("  Owned paths: ", "  Owned paths: tools/test_tool_project_data_storage.sh; docs/knowledge/tool-project-data-ssd-storage.md; docs/linkedspec-book/src/development/local-ci-and-regression.md; ", 1)
node += "  Owned storage integration defect / fix now: Canonical4 and a distinct direct run reject the exact Python-entrypoint census42/43 in tools/test_tool_project_data_storage.sh. The new signed checker is the sole added entrypoint; existing temporary-owner membership is unchanged. This blocks canonical landing. Retain the complete failed staged candidate, actual producer/source populations, log and direct failure before enrolling it in the census and hostile-root managed-wrapper controls. Evidence: docs/checkpoints/signed-array-contract-admission/storage-before.json.gz. No runtime or neutral authority change and no canonical PASS credit.\n\n"
p.write_text(text[:start] + node + text[end:])
p = Path(review.RULE)
p.write_bytes(review.repaired_rule(c.decode(before["rule"]["base64"])))
Path("MEMORY.md").write_text("# MEMORY\n\n- activation_commit: `" + c.BASE + "` — signed neutral17.1 base; derive current HEAD from Git.\n- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.17.8`; current17.1 is not committed.\n- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.1`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.\n- next_action: Finish owned storage-inventory integration, verify actual direct FAIL/PASS and source census, update book/Knowledge/continuity, then fresh staged canonical CI and normal commit before17.2.\n- in_flight_uncommitted: Neutral17.1 and storage correction. Canonical4 exited at census42/43; no background job or complete receipt. Never rerun historical writers.\n- proof: Sealed signed-array-contract/publish.py remains read-only and unchanged at48 bounded inputs. Admission/storage-before.json.gz retains the failed candidate, all source populations and actual direct RED.\n- steering: [-n]=[size-n] for size-n>=0; negative selectors cannot create. Perl17.2 and other runtime/admission children follow clean17.1.\n- limits: Other repositories/submodules read-only black boxes; project data stays on-volume; no push until PNT exhausted.\n")
after_gate = c.run(["bash", review.RULE])
after_neutral = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
write_new("storage-result.json.gz", dict(rule=c.read(review.RULE), gate=after_gate,
    neutral_readonly=after_neutral, scope="Actual full storage oracle after only census/message and explicit signed-checker hostile-root enrollment. No allocator list, wrapper, model, authority or neutral publication changed."))
assert after_gate["returncode"] == 0
assert after_neutral["returncode"] == 0
verified = review.check()
command = c.run(["bash", "tools/run_python_project_data.sh", review.SELF])
write_new("storage-reader.json.gz", dict(result=verified, command=command))
assert command["returncode"] == 0
print("Storage enrollment verified:", json.dumps(verified, sort_keys=True))

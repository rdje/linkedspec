"""One-shot task-acceptance format qualification, separate from neutral proof."""
import gzip
import json
from pathlib import Path
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c

PREFIX = "docs/checkpoints/signed-array-contract-admission/"
TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
rule = "scripts/check_diagnosis_evidence.sh"
card = "docs/knowledge/task-acceptance-evidence-gate-boundary.md"
assert c.run(["git", "diff", "--name-only"])["stdout_base64"] == ""
baseline = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert baseline["returncode"] == 0 and not c.decode(baseline["stderr_base64"])
staged = c.run(["git", "diff", "--cached", "--binary", "--full-index"])
task_before = c.read(TREE)
cached = c.run(["git", "show", ":" + TREE])
assert cached["returncode"] == 0 and c.decode(cached["stdout_base64"]) == c.decode(task_before["base64"])
before_gate = c.run(["bash", rule])
assert before_gate["returncode"] == 1
text = c.decode(task_before["base64"]).decode()
old = "**LOCKSTEP** — Explicit pending book table/status/snapshot teaching"
new = "**LOCKSTEP** — Explicit target-only book table/status/snapshot teaching"
assert text.count(old) == 1
inputs = [rule, card, "tools/project_data_env.sh", "tools/project_data_run.sh",
    "tools/run_python_project_data.sh", PREFIX + "qualify.py", c.PREFIX + "common.py"]
before = dict(base=c.BASE, task=task_before, staged_binary_diff=staged,
    staged_diff_sha256=c.sha(c.decode(staged["stdout_base64"])),
    inputs={path: c.read(path) for path in inputs}, direct_gate=before_gate,
    canonical_log=c.read(".linkedspec-data/verification/signed-contract-canonical1.log"),
    canonical_outcome="Owned process group95796 terminated143 after TASK-ACCEPTANCE diagnostic; no completed canonical PASS or receipt.",
    prior_neutral_readonly=baseline,
    prior_neutral_outputs={path: c.read(path) for path in [
        c.PREFIX + "publication-inputs.json.gz", c.PREFIX + "publication.json",
        "docs/claims/TYPE-REFERENCE-BOOK.1.2.17.1.json"]},
    scope="Known checklist-format constraint, already documented in the canonical gate-boundary card. Preserve exact failed staged candidate and actual diagnostic before metadata repair. Neutral authority/producers/evidence remain untouched; no product RED or new doctrine defect.",
)

def write_new(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()
    with (c.ROOT / PREFIX / name).open("xb") as output:
        output.write(gzip.compress(raw, mtime=0))

write_new("before.json.gz", before)
text = text.replace(old, new, 1)
owner_start = text.index("- ID: " + chr(96) + c.OWNER + chr(96))
owner_end = text.index("- ID: ", owner_start + 5)
node = text[owner_start:owner_end]
node = node.replace("normal task/roadmap/continuity. Frozen", "normal task/roadmap/continuity; docs/checkpoints/signed-array-contract-admission/ retains the canonical format qualification. Frozen", 1)
node += "  Canonical format qualification: The first exact staged attempt reports TASK-ACCEPTANCE because its checked LOCKSTEP line describes rollout with the forbidden literal. The canonical task-acceptance-evidence-gate-boundary card already documents this whole-file predicate. Retain the complete original staged binary diff, task/rule/card/producer and actual direct FAIL before wording repair; owned canonical job terminates143 with no PASS credit. Clarify only that checked line as target-only teaching, preserve open backend statuses, and observe the unchanged direct checker PASS. The neutral40-input publication stays live/unchanged before and after; final exact canonical candidate is separate. Evidence: docs/checkpoints/signed-array-contract-admission/.\n\n"
Path(TREE).write_text(text[:owner_start] + node + text[owner_end:])
stage = c.run(["git", "add", "--", TREE])
assert stage["returncode"] == 0 and not c.decode(stage["stderr_base64"])
after_gate = c.run(["bash", rule])
assert after_gate["returncode"] == 0 and not c.decode(after_gate["stderr_base64"])
after_publication = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert after_publication["returncode"] == 0 and not c.decode(after_publication["stderr_base64"])
assert all(c.read(path) == packet for path, packet in before["prior_neutral_outputs"].items())
assert all(c.read(path) == packet for path, packet in before["inputs"].items())
write_new("result.json.gz", dict(task=c.read(TREE), stage=stage, direct_gate=after_gate,
    neutral_readonly=after_publication, scope="Metadata-format repair only. Final exact staged canonical CI remains required; no neutral publication rebinding or backend admission."))
print("Known task-format qualification: actual direct FAIL -> PASS; neutral publication unchanged")

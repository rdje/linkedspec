"""One-shot custody after clean17.1 and task-only17.2 activation; never rerun."""
import gzip
import json
from pathlib import Path
import subprocess
import common as c

OLD = "docs/checkpoints/signed-array-contract/"
CLAIM = "docs/claims/TYPE-REFERENCE-BOOK.1.2.17.1.json"
TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
planned = {"perl/LinkedSpec/BindingRuntime.pm", "perl/LinkedSpec/CodeblockRuntime.pm",
    "t/signed_array_selector_perl_contract.t", "docs/knowledge/write-vivification-perl-reference.md",
    "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md",
    "examples/negative-array-write-perl.spec", "examples/negative-array-write-callable-perl.spec",
    "CHANGES.md", "DEVELOPMENT_NOTES.md", "MEMORY.md", "LIVE_ACHIEVEMENT_STATUS.md",
    "ROADMAP.md", "docs/TASK_TREE.md", TREE}
assert subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip() == c.BASE
assert Path("git_message_brief.txt").stat().st_size == 0
changed = set(subprocess.check_output(["git", "diff", "--name-only"], cwd=c.ROOT).decode().splitlines())
assert changed == {"MEMORY.md", TREE}, changed
untracked = subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard"], cwd=c.ROOT).decode().splitlines()
assert all(path.startswith(c.PREFIX) for path in untracked)
assert not subprocess.check_output(["git", "diff", "--cached", "--name-only"], cwd=c.ROOT)
census = {}
for name in subprocess.check_output(["git", "ls-files", "docs/claims"], cwd=c.ROOT).decode().splitlines():
    record = json.loads(Path(name).read_bytes())
    live = [claim for claim in record["claims"]
        if claim["durability"].get("status") == "checked" and claim["durability"].get("mode") == "live"]
    if live:
        inputs = sorted({item["path"] for claim in live for item in claim["durability"]["inputs"]})
        assert not planned & set(inputs), (name, planned & set(inputs))
        census[name] = dict(packet=c.read(name), inputs=inputs)
manifest_path = OLD + "publication-inputs.json.gz"
manifest = json.loads(gzip.decompress(c.source(manifest_path).read_bytes()))
names = sorted(set(manifest["inputs"]) | {manifest_path, OLD + "publication.json", CLAIM})
tree = {}
for row in subprocess.check_output(["git", "ls-tree", "-rz", c.BASE], cwd=c.ROOT).split(b"\0"):
    if row:
        meta, path = row.split(b"\t", 1)
        mode, kind, oid = meta.decode().split()
        if kind == "blob" and mode in ("100644", "100755"):
            tree[path.decode()] = dict(mode=mode, oid=oid)
images = {path: dict(**c.identity(path), git=tree[path]) for path in names}
for path, item in images.items():
    assert item["mode"] == (0o755 if item["git"]["mode"] == "100755" else 0o644)
proof = c.run(["git", "hash-object", "--stdin-paths"], input=("\n".join(names) + "\n").encode())
assert proof["returncode"] == 0
assert c.decode(proof["stdout_base64"]).decode().splitlines() == [images[path]["git"]["oid"] for path in names]
baseline = c.run(["bash", "tools/run_python_project_data.sh", OLD + "publish.py"])
assert baseline["returncode"] == 0
assert all(c.identity(path) == {key: item[key] for key in ("sha256", "mode")} for path, item in images.items())
c.write_new("activation.json.gz", dict(base=c.BASE,
    status=c.run(["git", "status", "--porcelain"]),
    previous_commit_log=c.read(".linkedspec-data/verification/signed-contract-commit1.log"),
    prior_images=images, git_verification=proof, prior_readonly=baseline,
    prior_outputs={path: c.read(path) for path in (manifest_path, OLD + "publication.json", CLAIM)},
    live_claims=census, planned_paths=sorted(planned),
    sources={path: c.read(path) for path in (c.PREFIX + "activate.py", c.PREFIX + "common.py", c.PREFIX + "context.py", *c.SOURCES)},
    scope="Clean committed17.1 boundary precedes this leaf. Only task/MEMORY activation and new owned instruments exist at custody capture; runtime/test/book sources remain accepted Git bytes. All51 prior neutral input/output images are independently Git-verified, and the actual prior read-only publication passes before production edits. Complete checked-live census has no intersections. Frozen authorities/prior measurements remain unchanged; no other backend or portable admission."))
memory = Path("MEMORY.md")
text = memory.read_text().replace("Perl17.2 task activation only; production/test sources unchanged; no background job.",
    "Perl17.2 activation/custody captured; production/test sources unchanged; no background job.", 1)
memory.write_text(text)
print("Perl17.2 custody PASS:", len(images), "accepted Git images; no live intersections; production unchanged")

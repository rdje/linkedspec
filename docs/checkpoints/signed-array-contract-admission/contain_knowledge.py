"""One-shot Knowledge containment; no limit or neutral-proof input changes."""
import gzip
import json
from pathlib import Path
import re
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c

PREFIX = "docs/checkpoints/signed-array-contract-admission/"
OLD = "docs/knowledge/write-vivification-neutral-contract.md"
NEW = "docs/knowledge/signed-array-selector-neutral-contract.md"
POLICY_CARD = "docs/knowledge/readme-routing-pressure-closure-plan.md"
TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
REGISTRY = "doctrine/readme_stability/routes.jsonl"
PRESSURE = ["bash", "tools/project_data_run.sh", "perl", "scripts/check_readme_routing_pressure.pl", "--report"]
assert not c.decode(c.run(["git", "diff", "--name-only"])["stdout_base64"])

def census():
    return {path.relative_to(c.ROOT).as_posix(): dict(**c.identity(path.relative_to(c.ROOT).as_posix()),
        bytes=path.stat().st_size, lines=len(path.read_bytes().splitlines()))
        for path in sorted((c.ROOT / "docs/knowledge").glob("*.md"))}

def write_new(name, value):
    with (c.ROOT / PREFIX / name).open("xb") as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))

planned = {OLD, NEW, POLICY_CARD, TREE, "KNOWLEDGE_MAP.md", "CHANGES.md"}
live = {}
for name in c.decode(c.run(["git", "ls-files", "docs/claims"])["stdout_base64"]).decode().splitlines():
    value = json.loads(c.source(name).read_bytes())
    claims = [item for item in value["claims"] if item["durability"].get("status") == "checked" and item["durability"].get("mode") == "live"]
    if claims:
        inputs = {row["path"] for claim in claims for row in claim["durability"]["inputs"]}
        assert not planned & inputs, (name, sorted(planned & inputs))
        live[name] = dict(packet=c.read(name), inputs=sorted(inputs))
before = census()
assert len(before) == 1351
assert set(before) == set(c.decode(c.run(["git", "ls-files", "docs/knowledge/*.md"])["stdout_base64"]).decode().splitlines())
assert c.read(NEW) == c.load("documentation.json.gz")["card"]
gate = c.run(PRESSURE)
assert gate["returncode"] == 1
assert b"knowledge_cards exceeds control: files 1351/1350" in c.decode(gate["stderr_base64"]) + c.decode(gate["stdout_base64"])
prior = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert prior["returncode"] == 0
raw_old = c.read(OLD)
raw_new = c.read(NEW)
raw_policy = c.read(POLICY_CARD)
staged = c.run(["git", "diff", "--cached", "--binary", "--full-index"])
write_new("knowledge-before.json.gz", dict(base=c.BASE, census=before, gate=gate, live_claims=live,
    staged_binary_diff=staged, staged_diff_sha256=c.sha(c.decode(staged["stdout_base64"])),
    inputs={path: c.read(path) for path in [OLD, NEW, POLICY_CARD, TREE, "KNOWLEDGE_MAP.md", "CHANGES.md",
        REGISTRY, "scripts/check_readme_routing_pressure.pl", "README_POLICY.md", "README.md",
        PREFIX + "contain_knowledge.py", c.PREFIX + "common.py", "tools/project_data_env.sh", "tools/project_data_run.sh"]},
    canonical_log=c.read(".linkedspec-data/verification/signed-contract-canonical2.log"),
    canonical_outcome="Owned group34613 terminated143 after the file-count diagnostic; no completed canonical PASS.",
    neutral_readonly=prior, neutral_outputs={path: c.read(path) for path in [
        c.PREFIX + "publication-inputs.json.gz", c.PREFIX + "publication.json", "docs/claims/" + c.OWNER + ".json"]},
    scope="Actual count failure, complete original staged candidate, all original card bytes/questions and unchanged policy before containment. README is a collection member. No cap increase, product failure or neutral-proof rebinding.",
))
old_text = c.decode(raw_old["base64"]).decode()
new_text = c.decode(raw_new["base64"]).decode()
questions = new_text.split("answers:\n", 1)[1].split("\ndate:", 1)[0]
old_text = old_text.replace("\ndate: 2026-09-07", "\n" + questions + "\ndate: \"2026-10-24\"", 1)
old_text = re.sub(r'^title:.*$', 'title: "Frozen write-v1 and the separate signed-array target"', old_text, count=1, flags=re.M)
old_text = re.sub(r'^status:.*$', "status: write-v1 portable; signed target frozen with implementation and admission separately owned", old_text, count=1, flags=re.M)
# Route only repetitive per-backend chronology to its exact accepted image.
retired = []
for line in old_text.splitlines():
    if re.match(r"evidence_update_2026_.*_(?:perl_reference|rust_reference|rust_composition|dart_reference|julia_reference|lua_reference|lua_composition):", line):
        retired.append(line)
assert len(retired) == 7
for line in retired:
    old_text = old_text.replace(line + "\n", "", 1)
history = 'evidence_update_2026_10_24_history: "Seven repetitive per-backend rollout rows remain whole in Git ' + c.BASE + ':' + OLD + ' and docs/checkpoints/signed-array-contract-admission/knowledge-before.json.gz; current v1 semantics and all lookup questions remain here."\n'
old_text = old_text.replace("\nreverify:", "\n" + history + "reverify:", 1)
match = re.search(r'^reverify:.*$', old_text, flags=re.M)
assert match.group(0).endswith('"')
old_text = old_text[:match.end() - 1] + " && bash tools/run_python_project_data.sh tools/check_signed_array_selector_contract.py" + old_text[match.end() - 1:]
tick = chr(96)
old_text += """

## Signed-array target (October24)

TYPE-REFERENCE-BOOK.1.2.17.1 freezes a separate target in
""" + tick + "capability_conformance/signed_array_selector_contract.json" + tick + """
and its owned checker. The v1 authorities, digests and historical proof stay exact.
For integer i<0 on an existing length-L array, select L+i only in [0,L).
Negative selectors cannot create or append; positive dense writes and quoted
harray keys remain unchanged.

Normalize during the isolated post-expression walk. Existing-array underflow
uses """ + tick + "nested_write_array_underflow" + tick + """ with authored index, encountered length,
resolved_index, segment, authored span and authored-value prefix. Missing
negative targets retain v1's invalid-segment error. Identity guard precedes
expressions; global invalid kinds precede structural checks. V1 atomicity,
expression effects and detachment remain required.

This is a neutral target. Backend implementation17.2–6 and portable admission17.7
remain separately owned; unrelated read coercions and receiver order stay outside
the extension. Retained proof: docs/checkpoints/signed-array-contract/.
"""
policy_text = c.decode(raw_policy["base64"]).decode()
question = '  - "does the Knowledge directory README count toward its file limit"\n'
policy_text = policy_text.replace("\ndate:", "\n" + question + "date:", 1)
policy_text += "\nThe knowledge_cards collection matches " + tick + "docs/knowledge/*.md" + tick + ", including its README.\nFact count and collection file count differ; use the registered resulting-tree\nreport when adding a card. Reuse the canonical home and preserve lookup questions\nand exact historical images when containing that collection.\n"
prospective = sum(row["bytes"] for row in before.values()) - len(c.decode(raw_old["base64"])) - len(c.decode(raw_new["base64"])) - len(c.decode(raw_policy["base64"])) + len(old_text.encode()) + len(policy_text.encode())
assert prospective <= 8388608 and len(old_text.encode()) <= 65536
for line in re.findall(r"^  - .*", c.decode(raw_old["base64"]).decode().split("\ndate:", 1)[0], flags=re.M):
    assert line in old_text
for line in questions.splitlines():
    assert line in old_text
Path(OLD).write_text(old_text)
Path(POLICY_CARD).write_text(policy_text)
Path(NEW).unlink()
generated = c.run(["bash", "knowledge-map/scripts/gen_knowledge_map.sh"])
assert generated["returncode"] == 0 and not c.decode(generated["stderr_base64"])
text = Path(TREE).read_text()
start = text.index("- ID: " + tick + c.OWNER + tick)
end = text.index("- ID: ", start + 5)
node = text[start:end].replace("one new canonical Knowledge card", "canonical write and routing-pressure Knowledge cards", 1)
node = node.replace("One bounded new Knowledge card/derived map and pending book teaching stay within existing budgets.",
    "Signed target facts/questions are consolidated into the existing canonical write card; the routing card records README membership. Derived map and target teaching stay within unchanged collection limits.", 1)
node += "  Knowledge containment: Canonical attempt2 and the unchanged direct routing checker reject knowledge_cards1351/1350 because the new card adds one file and README also counts. Preserve the complete candidate, all original card bytes/questions, full census and actual failure before edits. Merge all four signed questions/facts into the canonical write-vivification card, route seven repetitive historical header rows to accepted Git/whole before image, document collection membership in the existing routing card and regenerate the map. Actual unchanged routing checker PASS at1350 files; registry/caps and neutral40-input publication remain unchanged. Attempt2 terminates143 with no canonical PASS credit. Evidence: docs/checkpoints/signed-array-contract-admission/knowledge-before.json.gz and knowledge-result.json.gz.\n\n"
Path(TREE).write_text(text[:start] + node + text[end:])
p = Path("CHANGES.md")
text = p.read_text().replace("one bounded new card and pending table render agree with the target",
    "the consolidated canonical write card and target table agree under unchanged limits", 1)
p.write_text(text)
stage = c.run(["git", "add", "-A", "--", OLD, NEW, POLICY_CARD, TREE, "KNOWLEDGE_MAP.md", "CHANGES.md"])
assert stage["returncode"] == 0
after = census()
assert len(after) == 1350
assert sum(row["bytes"] for row in after.values()) == prospective
assert c.read(REGISTRY) == json.loads(gzip.decompress((c.ROOT / PREFIX / "knowledge-before.json.gz").read_bytes()))["inputs"][REGISTRY]
after_gate = c.run(PRESSURE)
assert after_gate["returncode"] == 0 and not c.decode(after_gate["stderr_base64"])
after_publication = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert after_publication["returncode"] == 0
write_new("knowledge-result.json.gz", dict(census=after, card=c.read(OLD), policy_card=c.read(POLICY_CARD),
    task=c.read(TREE), generator=generated, stage=stage, gate=after_gate,
    neutral_readonly=after_publication, retired_header_rows=retired,
    scope="All old and four new semantic lookup questions survive; one existing routing question is added. Exact old card/header bytes remain recoverable. No limits, historical authority, neutral proof input or runtime changed.",
))
print("Knowledge containment PASS:", len(before), "->", len(after), "files;", sum(row["bytes"] for row in after.values()), "bytes; unchanged limits/proof")

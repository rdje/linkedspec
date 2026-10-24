"""Finish containment after qualifying the generator's normal stderr notice."""
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

def load(name):
    return json.loads(gzip.decompress((c.ROOT / PREFIX / name).read_bytes()))

def write_new(name, value):
    with (c.ROOT / PREFIX / name).open("xb") as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))

before = load("knowledge-before.json.gz")
assert not (c.ROOT / NEW).exists()
source = c.read("knowledge-map/scripts/gen_knowledge_map.sh")
assert b'"$nq" >&2' in c.decode(source["base64"])
current = {path: c.read(path) for path in [OLD, POLICY_CARD, "KNOWLEDGE_MAP.md", TREE, "CHANGES.md"]}
generator = c.run(["bash", "knowledge-map/scripts/gen_knowledge_map.sh"])
assert generator["returncode"] == 0
assert not c.decode(generator["stdout_base64"])
notice = c.decode(generator["stderr_base64"])
assert notice == b"knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10509 question keys)\n"
assert c.read("KNOWLEDGE_MAP.md") == current["KNOWLEDGE_MAP.md"]
assert not (generator["returncode"] == 0 and not notice)
write_new("knowledge-generation.json.gz", dict(
    current=current, generator_source=source, generator=generator,
    actor=c.read(PREFIX + "resume_knowledge.py"),
    prior_actor=c.read(PREFIX + "contain_knowledge.py"),
    scope="Containment's original assertion stopped after the generator wrote the correct map. Its original generation channels were not separately retained, so they earn no channel credit. This distinct captured current command exits0 with the source-defined normal stderr success notice; the old empty-stderr predicate demonstrably rejects it. No generator, model or fixture change.",
))
old_text = c.decode(before["inputs"][OLD]["base64"]).decode()
new_text = c.decode(before["inputs"][NEW]["base64"]).decode()
merged = c.source(OLD).read_text()
for text in (old_text, new_text):
    for question in re.findall(r"^  - .*", text.split("\ndate:", 1)[0], flags=re.M):
        assert question in merged
retired = [line for line in old_text.splitlines()
    if re.match(r"evidence_update_2026_.*_(?:perl_reference|rust_reference|rust_composition|dart_reference|julia_reference|lua_reference|lua_composition):", line)]
assert len(retired) == 7
assert all(line not in merged for line in retired)
assert c.read(REGISTRY) == before["inputs"][REGISTRY]
tick = chr(96)
text = Path(TREE).read_text()
start = text.index("- ID: " + tick + c.OWNER + tick)
end = text.index("- ID: ", start + 5)
node = text[start:end].replace("one new canonical Knowledge card", "canonical write and routing-pressure Knowledge cards", 1)
node = node.replace("One bounded new Knowledge card/derived map and pending book teaching stay within existing budgets.",
    "Signed target facts/questions are consolidated into the existing canonical write card; the routing card records README membership. Derived map and target teaching stay within unchanged collection limits.", 1)
node += "  Knowledge containment: Canonical attempt2 and the unchanged direct routing checker reject knowledge_cards1351/1350 because the new card adds one file and README also counts. Preserve the complete candidate, all original card bytes/questions, full census and actual failure before edits. Merge all four signed questions/facts into the canonical write card, route seven repetitive historical header rows to accepted Git/whole before image, document collection membership in the existing routing card and regenerate the map. The first containment actor rejects the generator's normal stderr success notice after writing the correct map; a distinct captured idempotent run and source-defined notice qualify that wrapper mistake, without original-channel credit. Actual unchanged routing checker PASS at1350 files; registry/caps and neutral40-input publication remain unchanged. Attempt2 terminates143 with no canonical PASS credit. Evidence: docs/checkpoints/signed-array-contract-admission/knowledge-before.json.gz, knowledge-generation.json.gz and knowledge-result.json.gz.\n\n"
Path(TREE).write_text(text[:start] + node + text[end:])
p = Path("CHANGES.md")
text = p.read_text().replace("one bounded new card and pending table render agree with the target",
    "the consolidated canonical write card and target table agree under unchanged limits", 1)
p.write_text(text)
stage = c.run(["git", "add", "-A", "--", OLD, NEW, POLICY_CARD, TREE, "KNOWLEDGE_MAP.md", "CHANGES.md"])
assert stage["returncode"] == 0
after = {path.relative_to(c.ROOT).as_posix(): dict(**c.identity(path.relative_to(c.ROOT).as_posix()),
    bytes=path.stat().st_size, lines=len(path.read_bytes().splitlines()))
    for path in sorted((c.ROOT / "docs/knowledge").glob("*.md"))}
assert len(after) == 1350 and set(after) == set(before["census"]) - {NEW}
for path, item in after.items():
    if path not in (OLD, POLICY_CARD):
        assert item == before["census"][path]
total = sum(row["bytes"] for row in after.values())
assert total <= 8388608
after_gate = c.run(["bash", "tools/project_data_run.sh", "perl", "scripts/check_readme_routing_pressure.pl", "--report"])
assert after_gate["returncode"] == 0
after_publication = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert after_publication["returncode"] == 0
assert all(c.read(path) == packet for path, packet in before["neutral_outputs"].items())
write_new("knowledge-result.json.gz", dict(census=after, card=c.read(OLD), policy_card=c.read(POLICY_CARD),
    task=c.read(TREE), generator=generator, stage=stage, gate=after_gate,
    neutral_readonly=after_publication, retired_header_rows=retired,
    registry=c.read(REGISTRY),
    scope="All old and four signed semantic lookup questions survive; one routing question is added. Exact old card/header bytes remain recoverable. No limits, historical authority, neutral proof input or runtime changed.",
))
print("Knowledge containment PASS:1351 ->1350 files;", total, "bytes; unchanged limits/neutral proof")

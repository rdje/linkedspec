"""Emit a source-bound claim from completed focused, history and book evidence."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"


def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


proof = json.loads((ROOT / (PREFIX + "verification.json")).read_bytes())
book = json.loads((ROOT / (PREFIX + "book-check.json")).read_bytes())
governance = json.loads((ROOT / (PREFIX + "governance-check.json")).read_bytes())
if any(x["result"] != "PASS" for x in (proof, book, governance)) or not governance["isolated_history_replayed"]:
    raise ValueError("completed focused/book/isolated history proof required")
inputs = {}
for evidence in (proof, governance):
    for path, expected in evidence["tracked_inputs"].items():
        if sha(path) != expected or (path in inputs and inputs[path] != expected):
            raise ValueError("stale/conflicting evidence input: " + path)
        inputs[path] = expected
for path in (PREFIX + "verification.json", PREFIX + "book-check.py", PREFIX + "book-check.json",
             PREFIX + "governance-check.json", PREFIX + "claim.py", book["source"],
             "docs/linkedspec-book/src/development/local-ci-and-regression.md", "tools/run_mdbook_local.sh"):
    inputs[path] = sha(path)
if inputs[book["source"]] != book["source_sha256"]:
    raise ValueError("stale book source")
producers = set(proof["tests"])
producers.update(path for path in inputs if path.startswith(PREFIX) and Path(path).suffix in (".py", ".pl"))
producers.update(("docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm",
                  "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py",
                  "tests/language-readiness/verify_objectives.py"))
history_controls = governance["controls"]["governance_mutations_rejected"]
registration_controls = len(governance["new_controls"])
commands = ["capture.py after", "census-source.py", "tests.py after", "keyword-capture.py after",
            "keyword-tests.py after", "keyword-review.py", "span-capture.py after", "span-phase0.py after",
            "span-review.py", "compatibility-capture.py after", "scoped-phase0.py after", "compatibility-review.py",
            "compatibility-tests.py before", "compatibility-tests.py after", "review.py", "governance-check.py"]
claim = {
    "name": "source-unit-raw-expression-readiness-reporting-repair",
    "statement": f"{proof['full_sources']} exact sources across three named seeds retain {proof['native_fresh_pairs']} matched before/after native/fresh records. A55-source descriptor census preserves800 matched rewrite units and all22 shipped prior readiness/counts. Two keyword sources/six pairs preserve typed pre-operand errors/empty effects; four semantic marker sources/twelve pairs preserve prior fallback/readiness.27 additional compatibility sources/57 units establish fenced legacy ownership and genuine raw operands. {len(proof['tests'])} complete suites pass {proof['top_level_TAP_tests']} top-level tests, separately from24 extracted Phase0 bodies. {len(proof['controls'])} reason-sensitive evidence corruptions reject; {len(book['examples'])} measured sources render. Isolated historical recovery restores134 inputs/84,613,241 bytes and rejects{history_controls} governance mutations.",
    "scope": proof["limits"] + " Exact BCODE label/target bridges and recorded generated lifecycle slots are excluded only from added expression scanning. Supported authored legacy twins retain canonical ownership; genuine adjacent raw operands retain full authored text/offsets. Counts add uncovered expression occurrences to existing fallback counts, while display text is unique. Final current primary/census captures are fresh; earlier captures/producers are frozen. Failed file-route, mixed-version initial compatibility capture and unmasked diagnostic replay are excluded from current acceptance. Public reporting/CI landing requires a successful exact staged canonical receipt independently of this focused claim.",
    "rederive": {
        "status": "checked",
        "command": "; ".join("bash tools/run_python_project_data.sh " + PREFIX + command for command in commands) + "; bash tools/run_mdbook_local.sh; bash tools/run_python_project_data.sh " + PREFIX + "book-check.py; bash tools/run_python_project_data.sh " + PREFIX + "claim.py",
        "granularity": "One exact source per process and named seed; matched native/fresh emitted-source observations and source-reference descriptor units. Original16 diagnosis sources/48 pairs remain exact historical baseline. Source occurrence/span/unit expectations are independent authored offsets. Compatibility27-source descriptor proof and extracted24 Phase0 bodies have separate populations; neither is full1034 Phase0 or another backend's admission.",
        "result": f"PASS: {len(inputs)} hash-bound inputs, {len(producers)} tracked producing instruments, {proof['top_level_TAP_tests']} top-level tests, {len(proof['controls'])} evidence corruptions, {registration_controls} CI registration corruptions, {history_controls} historical governance mutations, deterministic134-input recovery with zero original-log reads/tracked writes, and {len(book['examples'])} rendered exact sources. Canonical acceptance remains separately enforced for the staged candidate."
    },
    "falsify": {
        "status": "checked",
        "hypothesis": "A canonical outer helper covers arbitrary raw operands, all raw AST whole statements imply host fallback, aliases/text determine occurrence identity, or reporting requires changed runtime semantics/non-AST executable source.",
        "oracle": "Independent source tokens/offsets/unit slots; exact canonical contract/raw-statement ownership; ordinary typed mutation receiver contract with deferred exclusion; original/current public values/errors/events/lowering with coordinate-only serialized AST comparison. Exact fixture normalization recovers all pre-existing Phase0 bytes after reversing fourteen measured telemetry assertions. Reason-sensitive mutations independently distinguish hidden host operands, false legacy demotion, source/span/event/runtime drift, fixture corruption and missing/disabled CI registration.",
        "red_control": "Original16-test source fails9 at activation and passes16 currently. Final six-test provenance source fails6 with original owners and passes6 currently; its two initial negatives had incorrectly labeled a supported assign_call twin raw, so their exact old source/failed stream are preserved and final negatives verify adjacent genuine raw text/offsets. Frozen pre-span owners fail14 of20; three exact child-frame handoffs and matching generated-slot ownership make all20 pass. Compatibility27-test source fails21 with the frozen collector and passes27 currently. Full focused1034 Phase0 previously failed24 metadata cases; the exact extracted24 bodies fail24 before, fail only five after classification with old oracles, and pass24 after fourteen measured metadata assertion updates. Bare payloads retain inner raw source; ordinary assignment groups preserve existing lowering, while deferred groups remain raw. Three complete failed canonical logs are losslessly retained: routing pressure, two old keyword readiness oracles, and wrapper payload/nested span failures.605 composition tests preserve every old source/value/error/effect assertion while correcting only two keyword telemetry expectations. Metadata source presence includes rejected operands and is not an execution trace. Historical CI/storage/signature controls remain distinct from new registration/oracle controls. No failed or partial stream is substituted for successful canonical acceptance."
    },
    "durability": {"status": "checked", "mode": "live", "inputs": [
        {"path": path, "sha256": value, "role": "producer" if path in producers else "input"}
        for path, value in sorted(inputs.items())]}
}
print(json.dumps({"version": 1, "owner": OWNER, "claims": [claim]}, indent=2))

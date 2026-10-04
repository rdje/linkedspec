"""Emit a claim from completed focused, historical-audit and book evidence."""
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
claim = {
    "name": "source-unit-raw-expression-readiness-reporting-repair",
    "statement": f"{proof['full_sources']} exact sources across three fixed seeds retain {proof['native_fresh_pairs']} matched before/after native-and-fresh records. A separate{proof['supplemental_keyword_sources']}-source/{proof['supplemental_keyword_native_fresh_pairs']}-pair keyword probe preserves typed pre-operand errors and empty effects while counting unsupported source. Nested raw occurrences now block readiness with original source-unit/span provenance. A55-source descriptor census preserves800 rewrite units, all22 shipped prior readiness/counts and existing event/lowering contracts. {len(proof['tests'])} suites pass {proof['top_level_TAP_tests']} top-level tests; {len(proof['controls'])} reason-sensitive evidence corruptions reject. {len(book['examples'])} measured book examples render. Isolated historical recovery restores134 inputs/84,613,241 bytes and rejects33 governance mutations.",
    "scope": proof["limits"] + " Exact BCODE label/target bridges alone are separated; authored bridge-shaped assignments and mismatched targets remain raw. Counts add uncovered expression occurrences to existing canonical fallback counts; unique display text is not an occurrence count. Public contract/CI landing requires the separately receipt-bound exact staged canonical gate; this claim does not substitute focused proof for that gate. Failed filename-route/Unicode-print census instruments remain preserved and excluded from successful shipped evidence.",
    "rederive": {
        "status": "checked",
        "command": f"bash tools/run_python_project_data.sh {PREFIX}capture.py after; bash tools/run_python_project_data.sh {PREFIX}census-source.py; bash tools/run_python_project_data.sh {PREFIX}tests.py after; bash tools/run_python_project_data.sh {PREFIX}keyword-capture.py after; bash tools/run_python_project_data.sh {PREFIX}keyword-tests.py after; bash tools/run_python_project_data.sh {PREFIX}keyword-review.py; bash tools/run_python_project_data.sh {PREFIX}review.py; bash tools/run_python_project_data.sh {PREFIX}governance-check.py; bash tools/run_mdbook_local.sh; bash tools/run_python_project_data.sh {PREFIX}book-check.py; bash tools/run_python_project_data.sh {PREFIX}claim.py",
        "granularity": "One exact source per process and named seed, with native/fresh emitted-source observations. Original16 diagnosis sources and48 pairs remain source/AST/metadata/lowering-byte exact at baseline. Complete source-reference descriptor census has per-unit public AST and diagnostics. Source occurrence expectations use authored tokens/positions and declared unit slots independently of the collector. Actual TAP RED/GREEN uses exact before owners; source spans index the recorded action unit, not absolute .spec offsets.",
        "result": f"PASS: {len(inputs)} hash-bound inputs, {len(producers)} producing instruments, {proof['top_level_TAP_tests']} top-level tests, {len(proof['controls'])} actual evidence corruptions, six CI registration corruptions, all33 historical governance mutations, deterministic134-input recovery with zero original-log reads/tracked writes, and {len(book['examples'])} rendered exact measured examples. Canonical acceptance is independently enforced for the exact staged candidate."
    },
    "falsify": {
        "status": "checked",
        "hypothesis": "Recognized top-level helpers exclude raw descendants, equal raw text or serialized aliases determine occurrence counts, every bridge-shaped assignment can be waived, or changed reporting requires changed execution/lowering.",
        "oracle": "Independent explicit source tokens/positions and lifecycle/action unit slots determine uncovered occurrence records. Canonical/literal-data/containing-raw controls distinguish executable raw from covered fallback. Shared aliases and repeated distinct spans/units check counts separately from unique display. Exact before/after public outputs and emitted digests bind native/fresh observations. Permanent authored-assignment twins and mismatched-target controls falsify blanket bridge masking. Exact anchored CI normalization recovers activation bytes and historical originals.",
        "red_control": "Actual activation metadata suite runs16 top-level subtests and fails9; provenance suite runs6 and fails6. Both unchanged suites pass after repair. The canonical blind-call readiness values were already healthy; their RED includes missing new fields, not an invented prior flag failure. Twenty-eight executed reviewer mutations reject changed readiness/count/span/repetitions/unit/bridge/display/events/lowering/value/warnings/TAP/source/fresh identity/original error/native trace and invalid failed-canonical envelope encoding/hash/length. The first canonical gate actually failed only README routing pressure: the new CI chapter exceeded its2048-line limit by5; exact first-candidate chapter/log bytes remain preserved, and only its new explanation is compacted within the existing budget. The second canonical gate reaches the unchanged605-test composition fixture and fails only its two old ready1 expectations (86/181). Six supplemental before/after native-fresh keyword observations prove original AST/lowering/emitted/error identity and zero operand effects. Source-presence telemetry intentionally reports ready0/raw1 even for typed pre-operand rejection. Only those two metadata oracles change; exact normalization recovers every old source/value/error/effect assertion. Updated605-test fixture fails exactly two telemetry assertions against old owners and passes all605 currently. Complete37,328,805-byte failed-gate log is recoverable from a deterministic gzip/base64 envelope with raw/compressed SHA and lengths; three corruptions reject. Six additional keyword evidence corruptions reject. The prior auditor actually rejects the new registration, while six new CI corruptions reject reason-sensitively under its exact successor. Existing fifteen CI, six storage and six Phase0 controls remain independent. Probe-only route/encoding and initial verifier reason/occurrence assumptions were corrected without changing production evidence or desired comment/quoted-data policy."
    },
    "durability": {"status": "checked", "mode": "live", "inputs": [
        {"path": path, "sha256": value, "role": "producer" if path in producers else "input"}
        for path, value in sorted(inputs.items())]}
}
print(json.dumps({"version": 1, "owner": OWNER, "claims": [claim]}, indent=2))

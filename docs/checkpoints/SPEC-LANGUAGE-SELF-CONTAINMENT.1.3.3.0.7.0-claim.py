"""Emit the claim from completed diagnosis and book results without mutating inputs."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0"
PREFIX = "docs/checkpoints/" + OWNER + "-"


def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


proof = json.loads((ROOT / (PREFIX + "verification.json")).read_bytes())
book = json.loads((ROOT / (PREFIX + "book-check.json")).read_bytes())
if proof["result"] != "PASS" or book["result"] != "PASS":
    raise ValueError("completed proof required")
inputs = dict(proof["tracked_inputs"])
for path, expected in inputs.items():
    if sha(path) != expected:
        raise ValueError("stale diagnostic input: " + path)
for path in (PREFIX + "verification.json", PREFIX + "book-check.py",
             PREFIX + "book-check.json", book["source"], "tools/run_mdbook_local.sh"):
    inputs[path] = sha(path)
if inputs[book["source"]] != book["source_sha256"]:
    raise ValueError("stale book source")
producers = set(proof["tests"])
producers.add("docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm")
producers.update(path for path in inputs if path.startswith(PREFIX) and
                 Path(path).suffix in (".py", ".pl"))
claim = {
    "name": "source-bound-nested-raw-readiness-diagnosis",
    "statement": f"{proof['full_sources']} exact sources across three fixed seeds produce {proof['case_seed_native_fresh_pairs']} native/fresh pairs and {proof['traces']} current lowering traces. Seven sources/{proof['missed_nested_case_seed_pairs']} pairs hide nested raw dependencies behind ready1/raw0/fallback0/unresolved0. Four unchanged suites pass {proof['top_level_TAP_tests']} top-level TAP tests; {len(proof['controls'])} actual reason-sensitive evidence corruptions reject. Four executed source-identical book examples render.",
    "scope": proof["limits"] + " Native deferred failures retain their two original timestamped DUMP_NONE records; no timestamp projection. Source-comment and quoted-helper defects are independently scheduled under .7.3/.7.2. Executable inputs remain activation-exact; no production or schema repair in this leaf. The broader .7.1 census and canonical landing remain required.",
    "rederive": {
        "status": "checked",
        "command": f"bash tools/run_python_project_data.sh {PREFIX}capture.py; bash tools/run_python_project_data.sh {PREFIX}trace-capture.py; bash tools/project_data_run.sh env PERL5LIB= PERL_HASH_SEED=0 PERL_PERTURB_KEYS=2 perl -Iperl {PREFIX}ast-alias.pl; bash tools/run_python_project_data.sh {PREFIX}tests.py; bash tools/run_python_project_data.sh {PREFIX}review.py; bash tools/run_mdbook_local.sh; bash tools/run_python_project_data.sh {PREFIX}book-check.py; bash tools/run_python_project_data.sh {PREFIX}claim.py",
        "granularity": "One complete authored source per Perl process; each source has native and independently loaded emitted observations under each named seed. Exact inner-action AST/source spans, original stdout/stderr, descriptor metadata and substitutions/dumps/emission retained. Shared control reference probes use two existing sources; one extra repeated-action fragment is AST-only, with no native/fresh admission. Complete TAP plans/results and raw current trace records checked.",
        "result": f"PASS: {len(inputs)} bound artifact inputs, {len(producers)} producing instruments, {len(proof['controls'])} observed corruptions rejected. All seven measured nested sources falsely ready; canonical alternatives/literal data raw-free. Desired comment-data oracle fails the actual AST and remains unchanged; the defect has an open prioritized repair owner. Deferred original-object identity and actual failure trace checked. No claim of portable infix results or repaired readiness."
    },
    "falsify": {
        "status": "checked",
        "hypothesis": "Ready metadata means no raw descendants, duplicated serialized conditions are separate source occurrences, equal raw text identifies one occurrence, or healthy literal/comment values prove accurate portability telemetry.",
        "oracle": "Independently authored raw-source expectations and canonical intended values distinguish hidden raw AST nodes from literals. Exact public spans/reference identity distinguish shared aliases and repeated distinct spans. Comment desired empty raw list intentionally disagrees with current AST. Actual routed trace shows passthrough_no_call then flow_composite_value with canonical fallback skipped; independent fresh loader and actual exception identity retain consumer evidence.",
        "red_control": "Actual current false-ready observations are retained, not a preclaimed repair RED/GREEN. Twelve reviewer controls independently reject changed readiness, erased raw child, shifted raw span, replaced source, replaced fresh source digest, wrong canonical value, removed host warnings, removed deferred failure trace, hidden shared condition identity, collapsed repeated occurrence, hidden failed TAP and removed reached branch. These are evidence controls, not runtime semantic mutants. Initial blanket quietness and HTML-entity extraction assumptions failed and were corrected with exact streams/source retained."
    },
    "durability": {"status": "checked", "mode": "live", "inputs": [
        {"path": path, "sha256": value, "role": "producer" if path in producers else "input"}
        for path, value in sorted(inputs.items())]}
}
print(json.dumps({"version": 1, "owner": OWNER, "claims": [claim]}, indent=2))

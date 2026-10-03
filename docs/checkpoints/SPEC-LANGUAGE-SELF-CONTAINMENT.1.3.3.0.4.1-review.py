"""Bind actual Perl normalization captures to preserved source and independent oracles."""
import copy
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1"
BASE = "03e2bb9a7f48abbe58771f624cb6aba3a068fd35"
PREFIX = ".linkedspec-data/scratch/normalization-correction-"
CONTRACT = "capability_conformance/composed_objective_contract.json"
ORIGINAL = "tests/language-readiness/composed/normalization.spec"
SUCCESSOR = "tests/language-readiness/composed/normalization-calls.spec"
OLD_LOOP = "while(i < count(pieces)) { visited = visited + 1; i = i + 1 }"
NEW_LOOP = "while(num_lt(i,count(pieces))) { visited = num_add(visited,1); i = num_add(i,1) }"
assert sys.argv[1:] in ([], ["--normalization-only"]), "unexpected review argument"
CASES = (
    ("P_ab_cd", "ab-cd", "collect"), ("P_mixed_case", "AB-cd", "collect"),
    ("P_short", "x-y", "collect"), ("P_quiet", "ab-cd", "absent"),
    ("P_prefix_bad", "!ab-cd", "collect"), ("P_suffix_bad", "ab-cd!", "collect"),
    ("P_empty", "", "collect"),
)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return (ROOT / path).read_bytes()


def at_base(path):
    return subprocess.check_output(["git", "show", BASE + ":" + path], cwd=ROOT)


def typed(value):
    # JSON serialization distinguishes boolean/number/string/null and ordered lists.
    return json.dumps(value, sort_keys=True, separators=(",", ":"), allow_nan=False)


def expected(text, sink):
    match = re.fullmatch(r"([A-Za-z]+)-([A-Za-z]+)", text)
    if match is None:
        return {"value": None, "events": [], "exit_status": 1, "detachment": None}
    a, b = match.groups()
    left, right = "new:" + a.upper(), "new:" + b.upper()
    return {
        "value": {"tree": {"a": left, "b": {"c": right}, "meta": {"count": 2}},
                  "mapped": {"a": left, "b": {"c": right}},
                  "original": {"a": a, "b": {"c": b}},
                  "seen": [a, b], "text": "outside", "visits": 2},
        "events": ([{"helper_name": "print_each", "rule_label": "Top", "message": "leaf:" + a + "!"},
                    {"helper_name": "print_each", "rule_label": "Top", "message": "leaf:" + b + "!"},
                    {"helper_name": "say", "rule_label": "Top", "message": "done:2\n"}]
                   if sink == "collect" else []),
        "exit_status": None,
        "detachment": {"mapped_unchanged": 1, "original_unchanged": 1,
                       "deliberately_aliased_control_rejected": 1},
    }


original = read(ORIGINAL)
successor = read(SUCCESSOR)
assert original == at_base(ORIGINAL)
assert original.decode().count(OLD_LOOP) == 1
assert original.decode().replace(OLD_LOOP, NEW_LOOP).encode() == successor
prior_contract = json.loads(at_base(CONTRACT))
contract = json.loads(read(CONTRACT))
restored = copy.deepcopy(contract)
correction = restored.pop("source_corrections")
assert correction == {"normalization": {
    "owner": OWNER,
    "original": {"path": ORIGINAL, "sha256": digest(original)},
    "successor": {"path": SUCCESSOR, "sha256": digest(successor)},
    "change": {"from": OLD_LOOP, "to": NEW_LOOP}}}
restored["sources"]["normalization"] = prior_contract["sources"]["normalization"]
assert typed(restored) == typed(prior_contract), "source correction changed another authority field"
assert len(contract["cases"]) == 16

public_path = PREFIX + "public-2.log"
public_log = read(public_path).decode()
records = re.findall(r"^# NORMALIZATION_OBSERVATIONS (.+)$", public_log, re.MULTILINE)
assert len(records) == 1
observations = json.loads(records[0])
assert "Files=1, Tests=21," in public_log and public_log.endswith("Result: PASS\n")


def review(actual):
    assert actual["source_path"] == SUCCESSOR
    assert actual["source_sha256"] == digest(successor)
    assert re.fullmatch(r"[0-9a-f]{64}", actual["emitted_sha256"])
    for route in ("native", "fresh"):
        rows = actual[route]
        assert [row["id"] for row in rows] == [case[0] for case in CASES], route
        for row, (ident, text, sink) in zip(rows, CASES):
            oracle = expected(text, sink)
            for field, value in oracle.items():
                assert typed(row[field]) == typed(value), (route, ident, field)
            assert row["unexpected_error"] is None, (route, ident)
            assert row["stdout"] == row["stderr"] == "", (route, ident)
    return True


review(observations)
rejected = []
for name in ("stringified-count", "lost-ordered-event", "false-detachment", "missing-typed-exit"):
    mutant = copy.deepcopy(observations)
    if name == "stringified-count":
        mutant["native"][0]["value"]["tree"]["meta"]["count"] = "2"
    elif name == "lost-ordered-event":
        mutant["fresh"][0]["events"].pop(0)
    elif name == "false-detachment":
        mutant["fresh"][0]["detachment"]["mapped_unchanged"] = 0
    else:
        mutant["native"][4]["exit_status"] = None
    assert typed(mutant) != typed(observations)
    try:
        review(mutant)
    except AssertionError:
        rejected.append(name)
    else:
        raise AssertionError("observation corruption accepted: " + name)
review(observations)

# This historical RED remains the captured original source, not a current bug lock.
diagnosis_path = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0-diagnosis.json"
diagnosis = json.loads(read(diagnosis_path))
assert read(diagnosis_path) == at_base(diagnosis_path)
old = next(row for row in diagnosis["native"] if row["id"] == "original")
old_fresh = next(row for row in diagnosis["fresh"] if row["id"] == "original")
assert old["source"].encode() == original
assert "::count called" in old["native"]["error"]["detail"]
assert "::count called" in old_fresh["error"]["detail"]
pilot = next(row for row in diagnosis["native"] if row["id"] == "original-helpers")
assert pilot["source"].encode() == successor
assert typed(pilot["native"]["value"]) == typed(expected("ab-cd", "collect")["value"])

neutral_path = PREFIX + "neutral-2.log"
neutral = read(neutral_path).decode()
assert "152 structural + 16 observation / 44 producer-report" in neutral
dependents_path = PREFIX + "dependents.log"
dependents = read(dependents_path).decode()
assert "Files=5, Tests=652," in dependents and dependents.endswith("Result: PASS\n")
book = "docs/linkedspec-book/src/architecture/structured-format-program.md"
assert "{{#include ../../../../" + SUCCESSOR + "}}" in read(book).decode()
html = read("docs/linkedspec-book/book/architecture/structured-format-program.html").decode()
assert "Governed fixtures and bounded Perl normalization" in html
assert "while(num_lt(i,count(pieces)))" in html
assert "false-detachment" not in html  # proof implementation stays outside the user example

production = subprocess.check_output(["git", "ls-files", "perl"], cwd=ROOT, text=True).splitlines()
authorities = ["capability_conformance/callable_codeblock_contract.json",
               "capability_conformance/callable_signature_contract.json",
               "capability_conformance/outward_descriptor_contract.json"]
unchanged = sorted(set(production + authorities))
for path in unchanged:
    assert read(path) == at_base(path), path
if sys.argv[1:] == ["--normalization-only"]:
    print(json.dumps({"scope": "normalization, neutral governance and direct proof; no legacy log read or tracked write",
        "normalization_paired_cases": len(CASES), "actual_object_alias_controls": 8,
        "public_top_level_tests": 21, "direct_dependent_tests": 652,
        "unchanged_case_oracles": len(contract["cases"]),
        "unchanged_production_and_normative_inputs": len(unchanged),
        "observation_corruptions_rejected": rejected}, sort_keys=True))
    raise SystemExit(0)

audit_path = PREFIX + "objective-audit-3.log"
audit = json.loads(read(audit_path))
assert (len(audit["checkpoints"]), audit["historical_source_references"],
        len(audit["latest_source_inputs"]), len(audit["retained_log_hashes"])) == (24, 257, 149, 134)
assert audit["controls"]["governance_mutations_rejected"] == 21
assert audit["controls"]["governance_mutations_by_source"] == {
    "tools/run_ci_local.sh": 12, "tools/test_perl_project_data_storage.sh": 6,
    "t/phase0_regression.t": 3}
phase0 = next(row for row in audit["governance_updates"] if row["path"] == "t/phase0_regression.t")
assert phase0["reconciliation_owner"] == OWNER
assert phase0["current"] == digest(read("t/phase0_regression.t"))
assert phase0["before_revision"] == "67af62f7aa6dff39b6c3fd64b15fb5139f691a0a"
assert phase0["after_revision"] == "446fb65fadca2e1bd31fec93bb9de779eb2134d1"
replay_proof_path = PREFIX + "mode-replay-proof.log"
old_mode_path = f"docs/checkpoints/{OWNER}-mode-proof-before.py"
mode_path = f"docs/checkpoints/{OWNER}-mode-proof.py"
producers = ["t/composed_normalization_perl.t", f"docs/checkpoints/{OWNER}-fresh.pl",
             f"docs/checkpoints/{OWNER}-review.py", "tools/check_composed_objective_contract.py",
             "tests/language-readiness/verify_objectives.py", mode_path,
             f"docs/checkpoints/{OWNER}-mode-replay-proof.py", old_mode_path]
inputs = unchanged + [CONTRACT, ORIGINAL, SUCCESSOR, diagnosis_path, "t/phase0_regression.t",
    "tools/run_ci_local.sh", "tools/test_perl_project_data_storage.sh",
    "tests/language-readiness/composed/diagnostic.spec",
    "tests/language-readiness/composed/diagnostic-invalid-arity.spec",
    "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1-selection.json", book,
    "docs/language-readiness/composed-objective-governance.md",
    "docs/language-readiness/composed-objective-selection.md",
    "docs/knowledge/composed-objective-neutral-governance.md",
    "docs/knowledge/perl-normalization-call-grammar.md",
    "docs/knowledge/historical-objective-audit-input-recovery.md",
    "docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md", "docs/TASK_TREE.md",
    "tools/project_data_run.sh", "tools/project_data_env.sh", "tools/run_python_project_data.sh",
    "tools/run_mdbook_local.sh", "tools/check_memory_handoff_state.py",
    "docs/language-readiness/objective-reconciliation.md",
    "t/diagnostic_output_perl_contract.t", "t/callable_codeblock_literal_contract.t",
    "t/codeblock_push_composition_perl.t", "t/uniform_binding_contract.t",
    "t/map_leaves_mutation_perl_contract.t"]
# The audit consumes the original checkpoints and current input bytes; bind those
# tracked inputs as well as the auditor, rather than only its reported totals.
inputs += list(audit["checkpoints"]) + list(audit["latest_source_inputs"])
watched = [{"path": path, "sha256": digest(read(path)),
            "role": "producer" if path in producers else "input"}
           for path in sorted(set(inputs + producers))]
summary = {"normalization_paired_cases": len(CASES), "actual_object_alias_controls": 8,
           "public_top_level_tests": 21, "direct_dependent_tests": 652,
           "unchanged_production_and_normative_inputs": len(unchanged),
           "unchanged_case_oracles": len(contract["cases"]),
           "observation_corruptions_rejected": rejected,
           "neutral_structural_observation_report": [152, 16, 44],
           "historical_checkpoints_references_inputs_logs": [24, 257, 149, 134],
           "historical_ci_storage_phase0_controls": [12, 6, 3]}
gap_owner = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2"
gap_example = ".linkedspec-data/scratch/context-lua-storage.log"
assert gap_example in audit["retained_log_hashes"]
assert digest(read(gap_example)) == audit["retained_log_hashes"][gap_example]
assert not subprocess.check_output(["git", "log", "--all", "--format=%H", "--", gap_example], cwd=ROOT)
timing_line = re.search(rb"Files=[^\r\n]*wallclock[^\r\n]*", read(gap_example)).group()
assert all(timing_line not in read(path) for path in audit["checkpoints"])
input_coverage = {"status": "gap", "repair_owner": gap_owner,
    "scope": "Historical audit artifact inputs only; normalization-only review skips them and writes no tracked files.",
    "required_local_logs": len(audit["retained_log_hashes"]),
    "local_log_bytes": sum((ROOT / path).stat().st_size for path in audit["retained_log_hashes"]),
    "selected_checkpoint_bytes": sum(len(read(path)) for path in audit["checkpoints"]),
    "example": {"path": gap_example, "sha256": digest(read(gap_example)), "bytes": len(read(gap_example)),
        "timing_line": timing_line.decode(), "git_path_history": "none",
        "timing_line_in_selected_checkpoints": False},
    "limits": "Concrete new-claim input-coverage gap; not a classification of every earlier proof or all possible archives. Hash membership does not establish byte recovery."}
# Snapshot-only evidence is checked after the guarded legacy-read boundary, so
# the mode-denial proof does not require its own later replay-proof output.
replay_proof = json.loads(read(replay_proof_path))
assert replay_proof["status"] == "PASS"
assert [row["mode"] for row in replay_proof["controls"]] == ["original", "repaired"]
before_mode, after_mode = replay_proof["controls"]
assert before_mode["source_sha256"] == digest(read(old_mode_path)) == \
    "9d186b46847aa51ec6e4cc031528f67faad3786dd9ce7b8c5fbfd56e6b20d94b"
assert after_mode["source_sha256"] == digest(read(mode_path))
assert before_mode["original_report_read_attempts"] == [PREFIX + "objective-audit-3.log"]
assert after_mode["original_report_read_attempts"] == []
assert before_mode["result"].startswith("RED:") and after_mode["result"].startswith("GREEN:")
summary["fresh_mode_replay_controls"] = len(replay_proof["controls"])
cp_path = f"docs/checkpoints/{OWNER}-verification.json"
checkpoint = {"format": 1, "owner": OWNER, "activation_commit": BASE, "summary": summary,
    "scope": "Seven Perl normalization pairs and governed source succession; no production, infix grammar or admission change. Full D/P semantic-mutant execution and other backends remain separate.",
    "correction": correction, "observations": observations, "tracked_inputs": watched,
    "historical_original_red": {"path": diagnosis_path, "sha256": digest(read(diagnosis_path)),
        "revision": BASE, "source_sha256": digest(original), "result": "native/fresh host count failure; preserved historical proof"},
    "audit_report": audit, "historical_audit_input_coverage": input_coverage,
    "fresh_mode_replay_control": replay_proof,
    "logs": [{"path": path, "sha256": digest(read(path)), "text": read(path).decode()}
             for path in (public_path, neutral_path, dependents_path, PREFIX + "book.log",
                          PREFIX + "mode-proof.log", replay_proof_path)],
    "early_audit_failure": {
        "scope": "Transient diagnostic chronology only: the original block-removal mutator changed zero bytes after successor insertion; early uncommitted producer version was not archived. Actual final byte-changing controls are captured above. Earlier task chronology is preserved in Git; this replay does not require that scratch failure."},
    "canonical_boundary": "Fully staged canonical receipt and commit body govern landing; this tracked capture records focused evidence before that boundary.",
    "replay": ["mkdir -p .linkedspec-data/scratch",
        "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/composed_normalization_perl.t > " + public_path + " 2>&1",
        "bash tools/run_python_project_data.sh tools/check_composed_objective_contract.py > " + neutral_path + " 2>&1",
        "bash tools/run_python_project_data.sh tests/language-readiness/verify_objectives.py > " + audit_path + " 2>&1",
        "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/diagnostic_output_perl_contract.t t/callable_codeblock_literal_contract.t t/codeblock_push_composition_perl.t t/uniform_binding_contract.t t/map_leaves_mutation_perl_contract.t > " + dependents_path + " 2>&1",
        "bash tools/run_mdbook_local.sh > " + PREFIX + "book.log 2>&1",
        "bash tools/run_python_project_data.sh " + mode_path + " > " + PREFIX + "mode-proof.log 2>&1",
        "bash tools/run_python_project_data.sh " + producers[6] + " > " + replay_proof_path + " 2>&1",
        "bash tools/run_python_project_data.sh " + producers[2]]}
# Project the build tool's runtime-root output only; raw log/hash stays in owned scratch.
runtime_prefix = str(ROOT) + "/"
for log in checkpoint["logs"]:
    count = log["text"].count(runtime_prefix)
    if count:
        log["text"] = log["text"].replace(runtime_prefix, "")
        log["projection"] = {"runtime_root_prefixes_removed": count,
                             "scope": "Only derived checkout-root prefixes; all other bytes retained. Raw digest above."}
(ROOT / cp_path).write_text(json.dumps(checkpoint, indent=2, sort_keys=True) + "\n")
watched_with_capture = watched + [{"path": cp_path, "sha256": digest(read(cp_path)), "role": "input"}]
normalization_replay = [command for command in checkpoint["replay"] if command !=
    "bash tools/run_python_project_data.sh tests/language-readiness/verify_objectives.py > " + audit_path + " 2>&1"]
normalization_replay[-1] += " --normalization-only"
claim = {"version": 1, "owner": OWNER, "claims": [{
    "name": "call-form-normalization-source-succession",
    "statement": "An explicit one-loop successor uses admitted arithmetic calls and executes the unchanged seven normalization oracles on native and fresh emitted Perl, with preserved tracked original RED.",
    "scope": "Seven paired cases/21 top-level tests and eight actual returned-object/alias controls; sixteen authority oracles unchanged. Neutral152/16/44 falsifiers are governance, not DSL semantic mutations; five direct suites/652 tests. Historical audit artifact recovery is a separate disclosed claim. No other backend or complete format admission.",
    "rederive": {"status": "checked", "command": " && ".join(normalization_replay),
        "granularity": "Each source binding, complete typed value/event/exit/quiet observation and actual-object producer assertion; normalization-only review consumes no legacy scratch log.",
        "result": "Seven native/fresh cases and eight actual-object alias controls PASS; four actual observation corruptions reject. Only one source loop and its explicit authority binding/provenance differ; all16 oracles and production/governing inputs remain exact. Direct dependents and neutral governance PASS. Original mode proof fails under actual ignored-report read denial; repaired mode proof recovers report data from the tracked capture and passes without an ignored-report read."},
    "falsify": {"status": "checked", "hypothesis": "Success refreshes old source/oracles, loses value kinds/events/exits, confuses consumer JSON copies with actual-object detachment, or replay silently requires an ignored intermediate report.",
        "oracle": "Independent ASCII/shape/event oracle, exact original/successor replacement and base authority equality; actual returned-tree root/nested mutation and deliberate actual-tree alias on both public producers; source-bound historical original host-count failure and preserved mode producer under actual ignored-report read denial.",
        "red_control": "Tracked historical original fails on both routes; successor passes all7 unchanged oracles. String count, lost event, false detachment and missing typed exit corrupt actual observation copies and reject; actual-tree alias controls reject in each producer, then healthy captures pass. Original mode producer fails on the denied intermediate-report read; repaired producer passes with zero original-report reads using only tracked report data."},
    "durability": {"status": "checked", "mode": "live", "inputs": watched_with_capture}}, {
    "name": "historical-objective-audit-byte-evolution",
    "statement": "The on-demand audit preserves historical source identities while permitting only exact owned CI/storage/Phase0 byte evolution; original artifact-input recovery remains incomplete.",
    "scope": "Actual local run:24 checkpoints/257 references/149 current source inputs/134 retained log hashes;12 CI/six storage/three Phase0 actual-byte corruption controls. Historical runtime proof is not a fresh objective or backend admission.",
    "rederive": {"status": "checked", "command": "bash tools/run_python_project_data.sh tests/language-readiness/verify_objectives.py",
        "granularity": "Each historical blob/current source/artifact hash and reason-sensitive governance mutation; command requires the presently retained local artifact inputs.",
        "result": "24/257/149/134 integrity and12/6/3 byte-changing mutation controls PASS; full output and exact auditor are captured. Fresh-checkout recovery of required log bytes is not established."},
    "falsify": {"status": "checked", "hypothesis": "Historical hashes are refreshed, unrelated edits are admitted, or no-op mutators count as controls.",
        "oracle": "Exact committed before/after subtest bytes and historical source hashes; unchanged source/corpus checkpoints plus independently specified CI insertion topology.",
        "red_control": "Actual missing/duplicate/unrelated CI edits, storage census changes, regression loss/plan weakening/outside edit and corrupted evidence reject their intended reasons; every counted governance mutant changes bytes."},
    "durability": {"status": "gap", "reason": "The audit consumes134 ignored retained local logs. The new capture records their hashes, not complete byte recovery; context-lua-storage.log is a501-byte timing-bearing example with no Git path history and no literal timing line in selected checkpoints. Existing raw inputs remain retained. Separate archival/recovery must resolve this selected leg before parent signoff; no blanket claim about earlier proof recoverability.",
        "repair_owner": gap_owner}}]}
(ROOT / f"docs/claims/{OWNER}.json").write_text(json.dumps(claim, indent=2) + "\n")
print(json.dumps(summary, sort_keys=True))

"""Review public diagnosis captures without evaluating DSL or changing its inputs."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / ".linkedspec-data/scratch/selfcontain133040"
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0"
BASE = "446fb65fadca2e1bd31fec93bb9de779eb2134d1"
ORIGINAL = "tests/language-readiness/composed/normalization.spec"
OLD_SHA = "ba9953c282e5e66956dc4b7d22c2acc7b1e879734654e7cb467ad41275cc4249"
OLD_LOOP = "while(i < count(pieces)) { visited = visited + 1; i = i + 1 }"
NEW_LOOP = "while(num_lt(i,count(pieces))) { visited = num_add(visited,1); i = num_add(i,1) }"
EXPECTED_PAIR = {
    "tree": {"a": "new:AB", "b": {"c": "new:CD"}, "meta": {"count": 2}},
    "mapped": {"a": "new:AB", "b": {"c": "new:CD"}},
    "original": {"a": "ab", "b": {"c": "cd"}},
    "seen": ["ab", "cd"], "text": "outside", "visits": 2,
}
VALUES = {"original-helpers": EXPECTED_PAIR, "count-direct": 2,
          "loop-helpers": 2, "loop-words": 2, "loop-symbols": 2,
          "increment-helper": 3, "condition-helper": "no",
          "increment-infix": 1, "condition-infix": "yes"}
IDS = set(VALUES) | {"original", "loop-infix"}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def raw_descendants(value):
    found = []
    if isinstance(value, dict):
        if value.get("kind") == "raw_perl":
            found.append({"source": value["source"], "reason": value["reason"],
                          "source_span": value["source_span"]})
        for child in value.values():
            found.extend(raw_descendants(child))
    elif isinstance(value, list):
        for child in value:
            found.extend(raw_descendants(child))
    return found


original = (ROOT / ORIGINAL).read_bytes()
assert digest(original) == OLD_SHA
assert original.decode().count(OLD_LOOP) == 1
successor = original.decode().replace(OLD_LOOP, NEW_LOOP)


def review(native, fresh):
    assert len(native) == len(fresh) == len(IDS)
    assert {r["id"] for r in native} == {r["id"] for r in fresh} == IDS
    children = {r["id"]: r for r in fresh}
    rows = {r["id"]: r for r in native}
    assert rows["original"]["source"].encode() == original
    assert rows["original-helpers"]["source"] == successor
    for row in native:
        ident = row["id"]
        child = children[ident]
        assert digest(row["source"].encode()) == row["source_sha256"], ident
        assert digest(row["emitted"].encode()) == row["emitted_sha256"], ident
        assert digest(row["dump"].encode()) == row["dump_sha256"], ident
        assert child["emitted_sha256"] == row["emitted_sha256"], ident
        assert child["load_error"] is None, ident
        meta = row["metadata"]
        assert meta["language_agnostic_action_ir_ready"] == 1, ident
        assert all(meta[k] == 0 for k in ("raw_perl_dependency_count",
                   "canonical_action_ir_fallback_count", "unresolved_helper_count")), ident
        assert row["native"]["exception"] is None, ident
        if ident in VALUES:
            assert row["native"]["value"] == child["value"] == VALUES[ident], ident
            assert row["native"]["error"] is None and child["error"] is None, ident
            assert row["native"]["stdout"] == child["stdout"] == "", ident
            if ident in ("increment-infix", "condition-infix"):
                assert row["native"]["stderr"] == "", ident
                assert 'Argument "i" isn\'t numeric' in child["stderr"], ident
            else:
                assert row["native"]["stderr"] == child["stderr"] == "", ident
        else:
            assert row["native"]["value"] is None and child["value"] is None, ident
            assert "Undefined subroutine" in row["native"]["error"]["detail"], ident
            assert "::count called" in row["native"]["error"]["detail"], ident
            assert child["error"]["code"] == "generated_execution_failed", ident
            assert "::count called" in child["error"]["detail"], ident
    for ident, source in (("loop-infix", "i < count(pieces)"),
                          ("increment-infix", "i+1"), ("condition-infix", "i < 1")):
        raw = raw_descendants(rows[ident]["ast"])
        assert any(r["source"] == source and r["reason"] == "unsupported_expression" for r in raw)
    assert "truthy(i < count(pieces))" in rows["original"]["emitted"]
    assert "$visited = visited + 1" in rows["original"]["emitted"]
    assert "$i = i + 1" in rows["original"]["emitted"]
    assert "$i = i+1" in rows["increment-infix"]["substitution"]
    assert "truthy(i < 1)" in rows["condition-infix"]["substitution"]
    for ident in ("loop-helpers", "loop-words", "loop-symbols",
                  "count-direct", "increment-helper", "condition-helper"):
        assert not raw_descendants(rows[ident]["ast"]), ident
    return rows


native = json.loads((OUT / "native.json").read_text())
fresh = json.loads((OUT / "fresh.json").read_text())
rows = review(native, fresh)
rejected = []
for name in ("false-original-success", "hidden-raw-child", "changed-successor-source"):
    n, f = copy.deepcopy((native, fresh))
    by_id = {r["id"]: r for r in n}
    if name == "false-original-success":
        by_id["original"]["native"]["value"] = EXPECTED_PAIR
    elif name == "hidden-raw-child":
        by_id["increment-infix"]["ast"]["statements"][1]["expr"]["value"] = {
            "kind": "variable", "name": "i"}
    else:
        row = by_id["original-helpers"]
        row["source"] = row["source"].replace('prefix = "new:"', 'prefix = "wrong:"')
        row["source_sha256"] = digest(row["source"].encode())
    try:
        review(n, f)
    except AssertionError:
        rejected.append(name)
    else:
        raise AssertionError("corrupted observation accepted: " + name)
review(native, fresh)

# No production or normative input changed during diagnosis.
production = subprocess.check_output(["git", "ls-files", "perl"], cwd=ROOT, text=True).splitlines()
authorities = ["capability_conformance/callable_codeblock_contract.json",
               "capability_conformance/callable_signature_contract.json",
               "capability_conformance/outward_descriptor_contract.json",
               "capability_conformance/composed_objective_contract.json",
               "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1-selection.json",
               "docs/language-readiness/composed-objective-selection.md",
               "docs/language-readiness/composed-objective-governance.md",
               "tools/check_composed_objective_contract.py",
               "tests/language-readiness/verify_objectives.py", "t/phase0_regression.t",
               ORIGINAL, "tests/language-readiness/composed/diagnostic.spec",
               "tests/language-readiness/composed/diagnostic-invalid-arity.spec"]
unchanged = []
for path in sorted(set(production + authorities)):
    current = (ROOT / path).read_bytes()
    prior = subprocess.check_output(["git", "show", BASE + ":" + path], cwd=ROOT)
    assert current == prior, path
    unchanged.append({"path": path, "sha256": digest(current), "role": "input"})
book = "docs/linkedspec-book/src/architecture/structured-format-program.md"
assert "```spec\n" + rows["loop-helpers"]["source"] + "\n```" in (ROOT / book).read_text()

producers = [f"docs/checkpoints/{OWNER}-{suffix}" for suffix in ("probe.pl", "fresh.pl", "review.py")]
watched = unchanged + [{"path": path, "sha256": digest((ROOT / path).read_bytes()),
                        "role": "producer"} for path in producers]
for path in (book, "docs/decisions/0003-raw-perl-free-spec-authoring.md",
             "docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md",
             "tools/project_data_run.sh", "tools/project_data_env.sh", "tools/run_python_project_data.sh"):
    watched.append({"path": path, "sha256": digest((ROOT / path).read_bytes()), "role": "input"})
summary = {"paired_sources": len(IDS), "admitted_form_successes": 7,
           "infix_host_failures": 2, "infix_host_behavior_controls": 2,
           "rejected_observation_controls": rejected,
           "unchanged_production_and_normative_inputs": len(unchanged),
           "verbatim_book_pair": "loop-helpers",
           "repair": "explicit canonical call-form successor under .0.4.1",
           "remaining_false_ready_owner": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7"}
audit_raw = (ROOT / ".linkedspec-data/scratch/normalization-diagnosis-objective-audit.log").read_bytes()
audit_text = audit_raw.decode()
runtime_root_prefix = str(ROOT) + "/"
assert audit_text.count(runtime_root_prefix) == 3
audit_relative = audit_text.replace(runtime_root_prefix, "")
assert "ValueError: current executable evidence drift: t/phase0_regression.t" in audit_relative
checkpoint = {"format": 1, "owner": OWNER, "activation_commit": BASE,
              "scope": "Diagnosis/value pilot only; no fixture, authority, production or admission change.",
              "summary": summary, "native": native, "fresh": fresh,
              "raw_descendants": {ident: raw_descendants(rows[ident]["ast"])
                                  for ident in ("loop-infix", "increment-infix", "condition-infix")},
              "tracked_inputs": watched,
              "initial_observer_failure": {"source": (OUT / "initial-probe.pl").read_text(),
                  "source_sha256": digest((OUT / "initial-probe.pl").read_bytes()),
                  "log": (ROOT / ".linkedspec-data/scratch/normalization-diagnosis-public.log").read_text(),
                  "result": "exit25; misuse of expression API on a statement sequence; not runtime proof"},
              "public_log": (ROOT / ".linkedspec-data/scratch/normalization-diagnosis-public-3.log").read_text(),
              "neutral_governance": (ROOT / ".linkedspec-data/scratch/normalization-diagnosis-neutral.log").read_text(),
              "historical_audit": {"result": "FAIL; retained, not waived",
                  "log": audit_relative, "raw_log_sha256": digest(audit_raw),
                  "projection": "Remove only three runtime repository-root prefixes from traceback file locations; preserve all other bytes. The owned scratch raw log and its digest retain the original capture; tracked paths are repository-relative.",
                  "repair_owner": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1",
                  "scope": "Phase0 signature regression changes the frozen test input; reconcile only the exact owned addition while preserving historical bytes and rejecting unrelated edits."},
              "replay": ["bash tools/project_data_run.sh env PERL5LIB= perl -Iperl " + producers[0],
                         "bash tools/run_python_project_data.sh " + producers[2]]}
cp_path = f"docs/checkpoints/{OWNER}-diagnosis.json"
(ROOT / cp_path).write_text(json.dumps(checkpoint, indent=2, sort_keys=True) + "\n")
watched.append({"path": cp_path, "sha256": digest((ROOT / cp_path).read_bytes()), "role": "input"})
claim = {"version": 1, "owner": OWNER, "claims": [{
    "name": "normalization-call-grammar-diagnosis",
    "statement": "Frozen infix expressions pass through as host source; admitted count and arithmetic/comparison calls execute. Select an explicit successor while preserving original source and independently owning false-ready telemetry.",
    "scope": "Eleven matched native/fresh sources at activation-exact production: seven admitted-form successes, two host-call failures and two retained infix host behaviors. The full call-form pilot proves one value only; seven-case/event/rejection/actual-object detachment and other backends are not claimed.",
    "rederive": {"status": "checked", "command": "; ".join(checkpoint["replay"]),
                 "granularity": "Each exact source, AST descendant, metadata, lowering/dump/emitted bytes and native/fresh value/error.",
                 "result": "Original and minimal infix loops fail host count; direct count and three admitted loop spellings return2. Infix increment/condition return1/yes while helpers return3/no. Only the loop changes in the successful full value pilot. All original production/normative inputs remain base-exact."},
    "falsify": {"status": "checked", "hypothesis": "count itself is unsupported, success changes unrelated source, or ready metadata proves raw-free AST.",
                "oracle": "Explicit literal expected values, direct count, three admitted call forms, exact one-loop source replacement and actual raw AST descendants; manual call grammar plus ADR0003. Native failure and independently loaded emitted error retain the actual host count detail.",
                "red_control": "Original/minimal host-call failures and wrong-intent infix results remain beside successful call controls; false-success, hidden-raw-child and changed-successor-source corruptions all reject, then the actual capture passes."},
    "durability": {"status": "checked", "mode": "live", "inputs": watched}}]}
(ROOT / f"docs/claims/{OWNER}.json").write_text(json.dumps(claim, indent=2) + "\n")
print(json.dumps(summary, sort_keys=True))

"""Verify exact public observations and retain deduplicated, recoverable captures."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import re

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / ".linkedspec-data/scratch/selfcontain13302131"
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1"
BASE = "67af62f7aa6dff39b6c3fd64b15fb5139f691a0a"
CORE = "perl/LinkedSpec/ActionIR/StatementSplit/Core.pm"
IDS = {f"{kind}-{name}" for kind in ("fixed", "rest")
       for name in ("y", "tr", "s", "q", "qq", "qx", "qr", "m")}
IDS |= {"zero", "nested", "quoted", "body-regex"}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def typed_detail(error):
    assert isinstance(error, dict)
    detail = error["detail"]
    assert detail["class"] == "LinkedSpec::CodeblockRuntime::Error"
    assert detail["fields"] == {"code": "unsupported_codeblock_actionir", "kind": "control_if"}


def review(native, fresh, healthy):
    assert {r["id"] for r in native} == IDS and len(native) == len(IDS)
    assert {r["id"] for r in fresh} == IDS and len(fresh) == len(IDS)
    children = {r["id"]: r for r in fresh}
    for row in native:
        ident = row["id"]
        child = children[ident]
        assert row["ast"]["kind"] == "codeblock_literal", ident
        assert row["source_sha256"] == digest(row["source"].encode()), ident
        assert row["emitted_sha256"] == digest(row["emitted"].encode()), ident
        assert row["dump_sha256"] == digest(row["dump"].encode()), ident
        assert child["emitted_sha256"] == row["emitted_sha256"], ident
        meta = row["metadata"]
        if healthy:
            assert meta["language_agnostic_action_ir_ready"] == 1, ident
            assert all(meta[k] == 0 for k in ("raw_perl_dependency_count",
                       "canonical_action_ir_fallback_count", "unresolved_helper_count")), ident
            assert child["load_error"] is None and len(row["statement_split"]) == 2, ident
            assert 'pack("H*"' in row["substitution"], ident
            if ident == "body-regex":
                assert row["native"]["value"] is None and child["value"] is None
                typed_detail(row["native"]["error"])
                typed_detail(child["error"])
            else:
                assert row["native"]["value"] == child["value"] == "ok", ident
                assert row["native"]["error"] is None and child["error"] is None, ident
        elif ident == "zero":
            assert row["native"]["value"] == child["value"] == "ok"
        else:
            assert row["native"]["value"] is None and row["native"]["error"], ident
            assert child["value"] is None and child["load_error"], ident
            assert len(row["statement_split"]) == (3 if ident == "nested" else 1), ident


phases = {}
for phase in ("red", "restored-red", "green", "reapplied-green"):
    native = json.loads((OUT / phase / "native.json").read_text())
    fresh = json.loads((OUT / phase / "fresh.json").read_text())
    review(native, fresh, phase in ("green", "reapplied-green"))
    phases[phase] = (native, fresh)

# Actual bad-observation controls distinguish compilation from runtime failure.
rejected = []
for name in ("false-healthy-control-if", "lost-typed-error", "merged-green-tail"):
    native, fresh = copy.deepcopy(phases["green"])
    row = next(r for r in native if r["id"] == "body-regex")
    if name == "false-healthy-control-if":
        row["native"]["value"] = "ok"
    elif name == "lost-typed-error":
        row["native"]["error"]["detail"] = "unsupported_codeblock_actionir"
    else:
        next(r for r in native if r["id"] == "fixed-y")["statement_split"] = ["merged"]
    try:
        review(native, fresh, True)
    except (AssertionError, TypeError):
        rejected.append(name)
    else:
        raise AssertionError(f"bad observation accepted: {name}")

for phase in ("restored-red", "green", "reapplied-green"):
    original = {r["id"]: r for r in phases["red"][0]}
    for row in phases[phase][0]:
        assert row["source"] == original[row["id"]]["source"], row["id"]
        # Inner whole-body statement ASTs are corrected by this same splitter;
        # the public literal signature/source/spans/record fields stay exact.
        for key in ("kind", "version", "signature", "source_text", "source_span", "body_source", "body_span"):
            assert row["ast"][key] == original[row["id"]]["ast"][key], (row["id"], key)
green_native, green_fresh = copy.deepcopy(phases["green"])
reapplied_native, reapplied_fresh = copy.deepcopy(phases["reapplied-green"])
for rows in (green_native, reapplied_native):
    for row in rows:
        # Preserve the actual permutation in the capture. Only this separately
        # owned metadata sequence is excluded from the runtime/compiler equality.
        row["metadata"].pop("canonical_action_ir_events")
assert green_native == reapplied_native and green_fresh == reapplied_fresh, "re-applied semantic/compiler drift"

baseline = subprocess.check_output(["git", "show", f"{BASE}:{CORE}"], cwd=ROOT)
assert (OUT / "baseline/perl/LinkedSpec/ActionIR/StatementSplit/Core.pm").read_bytes() == baseline
assert (OUT / "baseline/LiteralSignatureBaseline.pm").read_bytes() == (ROOT / f"docs/checkpoints/{OWNER}-baseline.pm").read_bytes()
inputs = []
production = subprocess.check_output(["git", "ls-files", "perl"], cwd=ROOT).decode().splitlines()
authorities = ["capability_conformance/callable_codeblock_contract.json",
               "capability_conformance/callable_signature_contract.json",
               "capability_conformance/outward_descriptor_contract.json"]
for path in production + authorities:
    data = (ROOT / path).read_bytes()
    previous = subprocess.check_output(["git", "show", f"{BASE}:{path}"], cwd=ROOT)
    assert data == previous if path != CORE else data != previous, path
    inputs.append({"path": path, "sha256": digest(data), "role": "input"})
for suffix in ("probe.pl", "fresh.pl", "baseline.pm", "review.py", "order.pl", "quotes.pl", "book.pl"):
    path = f"docs/checkpoints/{OWNER}-{suffix}"
    inputs.append({"path": path, "sha256": digest((ROOT / path).read_bytes()), "role": "producer"})
for path in ("tools/project_data_env.sh", "tools/project_data_run.sh", "tools/run_python_project_data.sh",
             "t/callable_codeblock_literal_contract.t", "t/phase0_regression.t",
             "t/actionir_ast_parser.t", "t/trace_actionir_method_lowering.t",
             "t/codeblock_push_composition_perl.t", "t/variadic_user_function_contract.t",
             "t/uniform_binding_contract.t", "t/map_leaves_mutation_perl_contract.t"):
    inputs.append({"path": path, "sha256": digest((ROOT / path).read_bytes()), "role": "input"})
book_path = "docs/linkedspec-book/src/architecture/structured-format-program.md"
inputs.append({"path": book_path, "sha256": digest((ROOT / book_path).read_bytes()), "role": "input"})

# Content references deduplicate identical source/compiler groups across all four
# captures. Every referenced object is retained and hash-checked; nothing depends
# on the ignored scratch JSON surviving. Expansion is an ordinary dictionary read.
objects = {}


def retain(value):
    key = digest(canonical(value))
    objects[key] = value
    return key


observations = {}
for phase, (native, fresh) in phases.items():
    children = {r["id"]: r for r in fresh}
    observations[phase] = []
    for row in native:
        source = {k: row[k] for k in ("source", "literal", "source_sha256", "ast")}
        compiler = {k: v for k, v in row.items() if k not in source and k not in ("id", "native")}
        observations[phase].append({"id": row["id"], "source_ref": retain(source),
                                    "compiler_ref": retain(compiler),
                                    "native": row["native"], "fresh": children[row["id"]]})
for key, value in objects.items():
    assert key == digest(canonical(value))
for phase, rows in observations.items():
    expanded = [{"id": r["id"], **objects[r["source_ref"]],
                 **objects[r["compiler_ref"]], "native": r["native"]} for r in rows]
    assert expanded == phases[phase][0], phase

order_controls = [json.loads(path.read_text()) for path in sorted((OUT / "order").glob("*.json"))]
assert len(order_controls) == 9
body_orders = []
baseline_readiness = []
for row in order_controls:
    assert row["substitution_sha256"] == digest(row["substitution"].encode())
    events = tuple(e["raw"] for e in row["metadata"]["canonical_action_ir_events"]
                   if e["source"] == "unmatched_helper_scan_event")
    # The restored baseline is identified by its raw literal substitution.
    if '{|x,y|' in row["substitution"]:
        baseline_readiness.append((row["metadata"]["language_agnostic_action_ir_ready"],
                                   row["metadata"]["unresolved_helper_count"]))
    elif row["id"] == "body":
        body_orders.append(events)
assert len(set(body_orders)) > 1, "controlled public ordering control did not go RED"
assert set(baseline_readiness) == {(1, 0), (0, 2)}, "controlled readiness observation changed"

quote_red = json.loads((OUT / "quotes-red.json").read_text())
quote_green = json.loads((OUT / "quotes-green.json").read_text())
assert quote_red["source"] == quote_green["source"]
assert quote_red["expected"] == quote_green["expected"]
assert quote_red["matches_oracle"] is False and quote_red["parts"] != quote_red["expected"]
assert quote_green["matches_oracle"] is True and quote_green["parts"] == quote_green["expected"]
book_observations = json.loads((OUT / "book/results.json").read_text())
assert len(book_observations) == 3
for row in book_observations:
    assert row["native"] == row["fresh"]["value"] == "ok"
    assert row["source_sha256"] == digest(row["source"].encode())
    assert row["fresh"]["emitted_sha256"] == digest(row["emitted"].encode())

logs = {}
for name in ("literal-repair-red.log", "literal-repair-public-red.log",
             "literal-repair-public-green.log", "literal-repair-public-green-final.log",
             "literal-repair-public-restored-red.log", "literal-repair-public-reapplied-green.log",
             "literal-repair-green.log", "literal-repair-dependents.log", "literal-repair-phase0.log",
             "literal-repair-phase0-2.log", "literal-repair-final-dependents.log",
             "literal-repair-public-green-final-2.log", "literal-repair-public-reapplied-green-2.log",
             "literal-repair-book-proof-final.log", "literal-repair-neutral.log"):
    data = (ROOT / ".linkedspec-data/scratch" / name).read_bytes()
    logs[name] = {"sha256": digest(data), "text": data.decode()}
phase0_name = "literal-repair-phase0-3.log"
phase0_data = (ROOT / ".linkedspec-data/scratch" / phase0_name).read_bytes()
phase0_text = phase0_data.decode()
assert "Result: PASS" in phase0_text and "All tests successful." in phase0_text
phase0_match = re.search(r"Files=(\d+), Tests=(\d+), (\d+) wallclock secs", phase0_text)
assert phase0_match
logs[phase0_name] = {"sha256": digest(phase0_data), "text": phase0_text}

capture = {"owner": OWNER, "activation_commit": BASE, "observations": observations,
           "objects": objects, "inputs": inputs,
           "order_controls": order_controls,
           "order_core_boundary": "The nine order controls used the intermediate Core archived below; CanonicalEvents and all other production/authority bytes remained unchanged. They are retained defect observations, not repair acceptance.",
           "quote_control": {"red": quote_red, "green": quote_green,
                             "intermediate_core_source": (OUT / "backtick-intermediate-Core.pm").read_text(),
                             "intermediate_core_sha256": digest((OUT / "backtick-intermediate-Core.pm").read_bytes())},
           "book_observations": book_observations,
           "baseline_core": {"revision": BASE, "path": CORE, "sha256": digest(baseline),
                             "source": baseline.decode()},
           "initial_observer_sources": {name: (OUT / name).read_text()
                                        for name in ("initial-probe.pl", "initial-fresh.pl")},
           "logs": logs,
           "review": {"paired_sources": len(IDS), "healthy_final_pairs": len(IDS) - 1,
                      "owned_failure": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5",
                      "owned_order_failure": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6",
                      "controlled_order_observations": len(order_controls),
                      "verbatim_book_pairs": len(book_observations),
                      "phase0": {"files": int(phase0_match[1]), "tests": int(phase0_match[2]),
                                 "wallclock_seconds": int(phase0_match[3]), "result": "PASS"},
                      "rejected_observation_controls": rejected,
                      "unchanged_production_authorities": len(production) + len(authorities) - 1},
           "limits": ["Initial green observer exits25 on blessed-error JSON serialization; not proof.",
                      "Final restored-red/green/reapplied-green use the same corrected producer.",
                      "body-regex compiles after the pipe fix but retains the separately owned typed control_if runtime failure.",
                      "Canonical unmatched-helper metadata event permutation and pre-fix readiness variation are retained, not graded as identical; .0.6 owns their diagnosis/repair.",
                      "No control-body/order repair, normalization or bridge/dispatcher closeout, new schema or other-backend admission."]}
checkpoint = f"docs/checkpoints/{OWNER}-verification.json"
(ROOT / checkpoint).write_text(json.dumps(capture, indent=2, ensure_ascii=True) + "\n")
inputs.append({"path": checkpoint, "sha256": digest((ROOT / checkpoint).read_bytes()), "role": "input"})
claim = {"version": 1, "owner": OWNER, "claims": [{
    "name": "literal-signature-pipe-repair",
    "statement": "Explicit signature delimiter ownership repairs the selected fixed/rest/nested/quoted callable pipeline without changing host pipe-quote modes or public records. The additional accepted attached-if source compiles and reaches its separately retained typed runtime gap.",
    "scope": "Twenty unchanged public native/fresh emitted sources at the final Core boundary: nineteen healthy final pairs, one explicit control_if failure owner. Exact restored-Core failures distinguish the scanner fix; final re-application reproduces values/errors/generated bytes/splits/literal fields and metadata apart from separately owned unmatched-event permutation. Preserve the nine intermediate-Core order observations and pre-fix readiness variation under .0.6; whole-record byte identity is not claimed. An actual quoted-opener lexer RED/GREEN and three verbatim native/fresh book pairs retain their boundaries. Separate selected suite results are validation, not proof that the unsupported body succeeds.",
    "rederive": {"status": "checked", "command": f"Run docs/checkpoints/{OWNER}-probe.pl through tools/project_data_run.sh for green/reapplied-green; reconstruct the exact checkpoint baseline Core and bootstrap in the owned mirror, set recorded PERL5OPT/digest and run restored-red. Then run docs/checkpoints/{OWNER}-review.py through tools/run_python_project_data.sh.",
                 "granularity": "Each of twenty identical sources, standalone AST, split boundary, metadata, substitution, dump/generated bytes and native/fresh outcomes across four captures; final paired result membership is exact.",
                 "result": "Nineteen native/fresh final pairs return ok; the twentieth loads correctly and preserves exact unsupported_codeblock_actionir/control_if on both routes. Exact prior Core restores compilation failures; re-applied values/errors/generated bytes/splits/literal fields match. Actual quoted-opener two-fragment RED becomes the independently expected three fragments; all three verbatim book sources return ok natively and in fresh children. Three corrupted observation controls reject. All production/authority inputs except Core remain activation-exact; unmatched-helper permutation retains its .0.6 owner."},
    "falsify": {"status": "checked", "hypothesis": "The apparent fix changes fixtures or suppresses a runtime failure, or another changed module causes success.",
                "oracle": "Identical source membership and literal signature/source/spans/record fields; inner body AST segmentation is corrected rather than asserted equal. Unchanged production except Core, exact committed-Core restoration with an asserted %INC binding and digest, then independent fresh emitted loading/execution. Retain the actual remaining typed control_if failure and reject deliberate healthy-result, error-kind-loss and merged-tail corruptions. Actual quoted-opener RED preserves its source and independent three-fragment oracle.",
                "red_control": "Complete new callable RED subtest fails48/48 assertions and one of11 top-level tests; exact restored Core reproduces the nineteen compile-failing public sources while zero-argument control stays healthy. Final nineteen successes and the explicit control_if error reappear after removing the override. All three observation corruptions reject; restored capture passes."},
    "durability": {"status": "checked", "mode": "live", "inputs": inputs}
}]}
(ROOT / f"docs/claims/{OWNER}.json").write_text(json.dumps(claim, indent=2) + "\n")
print(json.dumps(capture["review"], sort_keys=True))

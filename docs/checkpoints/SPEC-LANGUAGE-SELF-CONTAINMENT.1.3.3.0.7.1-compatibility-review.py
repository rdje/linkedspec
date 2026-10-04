"""Review exact compatibility ownership, genuine raw operands and oracle changes."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
TEST = "t/actionir_raw_dependency_compatibility.t"
NEW = {"raw_perl_expression_dependencies", "raw_perl_expression_source_units"}
CHANGED = NEW | {"raw_perl_dependency_count", "raw_perl_dependency_statements",
                "language_agnostic_action_ir_ready", "language_agnostic_action_ir_blocker_statements",
                "language_agnostic_action_ir_blocker_statement_count"}


def require(value, message):
    if not value:
        raise ValueError(message)


def read(suffix):
    return (ROOT / (PREFIX + suffix)).read_bytes()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


SPAN = load("compatibility_span_oracle", PREFIX + "span-normalize.py")
AUDIT = load("compatibility_oracle_normalizer", "tests/language-readiness/verify_objectives.py")


def captures(record, mode, cases):
    require(record["mode"] == mode and record["owner"] == OWNER
            and record["seed"] == "0" and record["perturbation"] == "2", "compatibility capture population")
    found = {}
    for row in record["rows"]:
        observation = row["observation"]
        ident = observation["id"].removeprefix("control:")
        require(ident in cases and ident not in found and row["exit"] == 0 and row["stderr"] == ""
                and json.loads(row["stdout"]) == observation, "compatibility actual producer")
        source = cases[ident]["source"]
        require(row["request"] == {"id": "control:" + ident, "source": source}
                and observation["source"] == source
                and row["source_sha256"] == hashlib.sha256(source.encode()).hexdigest()
                and row["command"] == ["perl", "-Iperl", PREFIX + "compatibility-probe.pl"],
                "compatibility source identity")
        found[ident] = observation
    require(set(found) == set(cases), "compatibility complete sources")
    return found


def expected(unit):
    source = unit["source"]
    tokens = []
    if "return(Leaf, $x)" in source:
        tokens = ["$x"]
    elif source.startswith("return(Top,(map {lc}"):
        tokens = ["(map {lc} @IMATCH_LIST)", "\\@Top"]
    elif source.strip() in ("return i+1", "return(i+1)"):
        tokens = ["i+1"]
    result = []
    for token in tokens:
        start = source.index(token)
        result.append({"source": token, "reason": "unsupported_expression", "source_unit": 0,
                       "source_span": {"start": start, "end": start + len(token)}})
    return result


def compare(before, after):
    for ident, current in after.items():
        prior = before[ident]
        require(set(prior) == set(current), "compatibility observation schema")
        for field in set(prior) - {"units", "metadata"}:
            require(prior[field] == current[field], "compatibility public behavior: " + field)
        require(len(prior["units"]) == len(current["units"]), "compatibility unit population")
        dependencies = {}
        for old, new in zip(prior["units"], current["units"]):
            require(old["label"] == new["label"] and old["source"] == new["source"]
                    and old["ast_error"] == new["ast_error"]
                    and SPAN.ast(old["ast"]) == new["ast"]
                    and SPAN.source_equal(old["rewritten"], new["rewritten"]), "compatibility AST/lowering behavior")
            a, b = old["diagnostics"], new["diagnostics"]
            require({k: v for k, v in a.items() if k not in NEW} ==
                    {k: v for k, v in b.items() if k not in NEW}, "compatibility canonical diagnostics")
            require(b["raw_perl_expression_dependencies"] == expected(new), "compatibility exact raw occurrences")
            dependencies.setdefault(new["label"], []).extend(expected(new))
        require(set(prior["metadata"]) == set(current["metadata"]), "compatibility rule population")
        for label, meta in current["metadata"].items():
            require({k: v for k, v in prior["metadata"][label].items() if k not in CHANGED} ==
                    {k: v for k, v in meta.items() if k not in CHANGED}, "compatibility stable public metadata")
            require(meta["raw_perl_dependency_count"] == meta["canonical_action_ir_fallback_count"] + len(dependencies.get(label, [])),
                    "compatibility raw count")
            require(meta["language_agnostic_action_ir_ready"] == int(
                meta["raw_perl_dependency_count"] == 0 and meta["unresolved_helper_count"] == 0), "compatibility readiness")


def reject(name, run, reason):
    try:
        run()
    except ValueError as error:
        require(str(error) == reason, "unrelated compatibility corruption: " + name)
        return {"name": name, "reason": str(error)}
    raise ValueError("compatibility corruption accepted: " + name)


def main():
    case_rows = json.loads(read("compatibility-cases.json"))
    require(len(case_rows) == 27, "compatibility declared27 sources")
    cases = {row["id"]: row for row in case_rows}
    original_fixture = read("before-span-phase0.t").decode()
    for index, row in enumerate(case_rows[:24]):
        body = re.search(r"^subtest '" + re.escape(row["id"]) + r"' => sub \{\n.*?(?=^subtest |\Z)",
                         original_fixture, re.M | re.S)
        require(body is not None, "compatibility original fixture marker")
        if index < 22:
            source = re.search(r"my \$spec_content = <<'SPEC';\n(.*?)^SPEC$", body.group(0), re.M | re.S)
            require(source is not None and source.group(1) == row["source"], "compatibility exact heredoc source")
        else:
            literal = r'"(?:[^"\\]|\\.)*"'
            source = re.search(r"my \$spec =\s*(" + literal + r"(?:\s*\.\s*" + literal + r")*)\s*;",
                               body.group(0))
            require(source is not None and "".join(json.loads(part) for part in re.findall(literal, source.group(1))) ==
                    row["source"], "compatibility exact concatenated source")
    records = {mode: captures(json.loads(read("compatibility-" + mode + ".json")), mode, cases)
               for mode in ("original", "before", "after")}
    for mode in ("original", "before"):
        compare(records[mode], records["after"])
    oracle = json.loads(read("compatibility-oracles.json"))
    fixture = (ROOT / "t/phase0_regression.t").read_bytes()
    require(AUDIT.restore_raw_readiness_oracles(fixture) == read("before-span-phase0.t"), "compatibility exact fixture recovery")
    test_hash = hashlib.sha256((ROOT / TEST).read_bytes()).hexdigest()
    for mode, failed in (("before", 21), ("after", 0)):
        tap = json.loads(read("compatibility-tests-" + mode + ".json"))
        stream = tap["stdout"]
        require(tap["mode"] == mode and tap["source_sha256"] == test_hash
                and tap["exit"] == failed
                and re.findall(r"^1\.\.(\d+)$", stream, re.M) == ["27"]
                and len(re.findall(r"^not ok ", stream, re.M)) == failed
                and (mode == "before" or "Result: PASS" in stream), "compatibility complete TAP")
        if mode == "after":
            require(tap["command"] == ["prove", "-v", "-Iperl", TEST], "compatibility actual TAP command")
        else:
            require(tap["command"][:3] == ["perl", "-Iperl", "-e"] and len(tap["command"]) == 4
                    and "require './" + PREFIX + "before-compat-RawDependencies.pm'" in tap["command"][3]
                    and "do './" + TEST + "'" in tap["command"][3], "compatibility actual frozen loader")
    scoped = {mode: json.loads(read("scoped-phase0-" + mode + ".json"))
              for mode in ("before", "first-after", "after")}
    require(scoped["before"]["exit"] == 24 and scoped["first-after"]["exit"] == 5
            and scoped["after"]["exit"] == 0
            and all(re.findall(r"^1\.\.(\d+)$", row["stdout"], re.M) == ["24"] for row in scoped.values())
            and not re.search(r"^not ok ", scoped["after"]["stdout"], re.M), "compatibility scoped Phase0 TAP")
    require(re.findall(r"^not ok \d+ - (.*)$", scoped["first-after"]["stdout"], re.M) ==
            [row["subtest"] for row in oracle["subtests"]], "compatibility measured oracle failures")
    require(AUDIT.restore_raw_readiness_oracles(scoped["after"]["program"].encode()) ==
            scoped["first-after"]["program"].encode(), "compatibility exact scoped program evolution")
    require(scoped["before"]["source_sha256"] == scoped["first-after"]["source_sha256"] ==
            hashlib.sha256(read("before-span-phase0.t")).hexdigest()
            and scoped["after"]["source_sha256"] == hashlib.sha256(fixture).hexdigest(),
            "compatibility scoped fixture identity")
    diagnostic = json.loads(read("metadata-replay.json"))
    require(diagnostic["result"] == "DIAGNOSTIC" and diagnostic["units"] == 800
            and len(diagnostic["differences"]) == 3
            and {(row["id"], row["unit"], row["seed"]) for row in diagnostic["differences"]} ==
            {("control:blind_edge_raw", 0, seed) for seed in ("0", "1", "2")}, "compatibility replay diagnostic limits")
    controls = []
    for name, ident, mutation, reason in (
        ("host operand masked", "emit_context_meta_exposes_language_agnostic_readiness",
         lambda x: x["units"][2]["diagnostics"].update(raw_perl_expression_dependencies=[]), "compatibility exact raw occurrences"),
        ("legacy falsely raw", "emit_context_canonical_action_ir_lowers_call_wrappers_without_raw_fallback",
         lambda x: x["units"][0]["diagnostics"].update(raw_perl_expression_dependencies=[{"source": "my $retv"}]), "compatibility exact raw occurrences"),
        ("event drift", "emit_context_canonical_action_ir_lowers_call_wrappers_without_raw_fallback",
         lambda x: x["units"][0]["diagnostics"]["canonical_action_ir_events"][0].update(kind="RAW_PERL"), "compatibility canonical diagnostics"),
        ("raw span shift", "canonical_return_raw_inner",
         lambda x: x["units"][0]["diagnostics"]["raw_perl_expression_dependencies"][0]["source_span"].update(start=9), "compatibility exact raw occurrences"),
        ("legacy demoted", "emit_context_canonical_action_ir_lowers_call_wrappers_without_raw_fallback",
         lambda x: x["metadata"]["Top"].update(language_agnostic_action_ir_ready=0), "compatibility readiness"),
        ("lowering drift", "canonical_return_raw_inner",
         lambda x: x["units"][0].update(rewritten="return 0"), "compatibility AST/lowering behavior"),
    ):
        changed = copy.deepcopy(records["after"])
        mutation(changed[ident])
        controls.append(reject(name, lambda: compare(records["before"], changed), reason))
    for row in oracle["subtests"]:
        changed = fixture.replace(row["assertions"][0]["after"].encode(), row["assertions"][0]["before"].encode(), 1)
        require(changed != fixture, "compatibility actual oracle mutation")
        controls.append(reject("stale oracle: " + row["subtest"], lambda: AUDIT.restore_raw_readiness_oracles(changed),
                               "raw-readiness oracle assertion mismatch: t/phase0_regression.t"))
    paths = {TEST, "t/phase0_regression.t", "tests/language-readiness/verify_objectives.py",
             "perl/LinkedSpec/ActionIR/RawDependencies.pm"}
    paths.update(PREFIX + name for name in (
        "compatibility-cases.json", "compatibility-original.json", "compatibility-before.json", "compatibility-after.json",
        "compatibility-capture.py", "compatibility-probe.pl", "compatibility-review.py", "compatibility-oracles.json",
        "compatibility-tests.py", "compatibility-tests-before.json", "compatibility-tests-after.json", "scoped-phase0.py", "scoped-phase0-before.json",
        "scoped-phase0-first-after.json", "scoped-phase0-after.json", "before-span-phase0.t", "span-normalize.py",
        "metadata-replay.py", "metadata-replay.pl", "metadata-replay.json"))
    paths.update(diagnostic["tracked_inputs"])
    for path, value in diagnostic["tracked_inputs"].items():
        require(hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == value, "compatibility diagnostic input identity")
    print(json.dumps({"owner": OWNER, "result": "PASS", "sources": 27, "rewrite_units": 57,
                      "top_level_TAP_tests": 27, "scoped_Phase0_subtests": 24,
                      "changed_Phase0_subtests": 5, "changed_Phase0_assertions": 14,
                      "controls": controls,
                      "tracked_inputs": {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in sorted(paths)},
                      "limits": "Exact legacy whole-statement ownership and ordinary supported assignment groups preserve prior canonical/AST/lowering contracts. Generic raw inner operands remain visible, and deferred groups retain unsupported AST classification.27-source descriptor observations and scoped24-subtest proof do not replace full1034 Phase0 or canonical acceptance. Diagnostic unmasked replay is excluded from unaffected acceptance; final fresh primary/census captures provide that proof."}, indent=2))


if __name__ == "__main__":
    main()

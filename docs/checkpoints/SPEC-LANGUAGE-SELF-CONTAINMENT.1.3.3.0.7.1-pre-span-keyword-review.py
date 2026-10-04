"""Review independent keyword-source telemetry and unchanged pre-operand errors."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
BASE = "c9673d7eff39836fdc94d59b8d47639db5e937d4"
TEST = "t/codeblock_push_composition_perl.t"
# Authored oracle: source tokens/offsets do not come from the collector.
EXPECTED = {
    "bridge_keyword_deferred": ("id", 'value:"x"', 18, 27, None),
    "bridge_keyword_effects": ("pair", 'second:"y"', 69, 79, []),
}
COMMENT = ("# Unsupported keyword arguments retain their typed pre-operand errors; their raw\n"
           "# AST source now reports ready0/raw1 under .7.1, regardless of operand execution.\n")
INSERTION = (",'metadata'=>{'canonical_action_ir_fallback_count'=>0,"
             "'language_agnostic_action_ir_ready'=>0,'raw_perl_dependency_count'=>1,"
             "'unresolved_helper_count'=>0}")
NEW = {"raw_perl_expression_dependencies", "raw_perl_expression_source_units"}
CHANGED = NEW | {"language_agnostic_action_ir_ready", "raw_perl_dependency_count",
                 "raw_perl_dependency_statements", "language_agnostic_action_ir_blocker_statements",
                 "language_agnostic_action_ir_blocker_statement_count"}


def require(value, message):
    if not value:
        raise ValueError(message)


def read(suffix):
    return (ROOT / (PREFIX + suffix)).read_bytes()


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def fixture():
    old = read("before-codeblock-push.t")
    require(old == subprocess.check_output(["git", "show", BASE + ":" + TEST], cwd=ROOT),
            "baseline fixture identity")
    current = (ROOT / TEST).read_text()
    require(current.count(COMMENT) == 1, "exact telemetry comment")
    current = current.replace(COMMENT, "", 1)
    for name in EXPECTED:
        selected = "'id'=>'" + name + "'" + INSERTION
        require(current.count(selected) == 1, "two explicit telemetry oracles")
        current = current.replace(selected, "'id'=>'" + name + "'", 1)
    require(current.encode() == old, "unchanged source/value/error/effect assertions")
    return old


def observations(record, mode, cases):
    require(record["owner"] == OWNER and record["mode"] == mode and
            record["seeds"] == ["0", "1", "2"] and record["perturbation"] == "2",
            "keyword capture population")
    for name in ("EmitContext", "Diagnostics"):
        require(record["baseline_owners"][name] == sha(read("before-" + name + ".pm")),
                "keyword before owner identity")
    found = {}
    for row in record["rows"]:
        require(row["exit"] == 0 and row["stderr"] == "" and
                json.loads(row["stdout"]) == row["observation"] and
                len(row["observation"]["cases"]) == 1, "keyword actual producer")
        x = row["observation"]["cases"][0]
        name, seed = x["id"], x["seed"]
        require(name in cases and seed in record["seeds"] and (name, seed) not in found and
                x["perturb"] == "2", "keyword source/seed membership")
        require(row["command"] == ["perl", "-Iperl", PREFIX + "keyword-probe.pl", name] and
                x["source"] == cases[name]["source"] and x["source_sha256"] == sha(x["source"].encode()),
                "keyword source identity")
        require(x["emitted_sha256"] == x["fresh"]["emitted_sha256"] == sha(x["emitted"].encode()),
                "keyword emitted identity")
        require(x["substitution_sha256"] == (sha(x["substitution"].encode()) if x["substitution"] else None),
                "keyword substitution identity")
        fn, token, start, end, effects = EXPECTED[name]
        detail = {"arguments_evaluated": 0, "code": "user_function_keyword_arguments_unsupported",
                  "function_name": fn, "got": 1, "kind": "codeblock_runtime_error",
                  "observed_class": "LinkedSpec::CodeblockRuntime::Error"}
        native, fresh = x["native"], x["fresh"]
        require(native["exception"] is None and native["context_error"]["type"] == "runtime_handler" and
                fresh["exception"]["type"] == "generated_source_error" and
                native["context_error"]["detail"] == fresh["exception"]["detail"] == detail and
                native["actual_error_identity"] == fresh["actual_error_identity"] == 1,
                "keyword original pre-operand error identity")
        for route in (native, fresh):
            require(route["value"] is None and route["stderr"] == "" and len(route["invocations"]) == 1,
                    "keyword failure channels")
            call = route["invocations"][0]
            require(call["identity"] == "cb" and call["error_class"] == detail["observed_class"] and
                    call["effects_before"] == call["effects_after"] == effects,
                    "keyword no operand effects")
        require(fresh["stdout"] == "", "keyword quiet fresh route")
        lines = native["stdout"].splitlines()
        prefix = r"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]\[NONE\]\[SpecEntry\.pm\]\[trace_decision:63\] "
        context = ("  Context: bless( {'arguments_evaluated' => 0,'code' => "
                   "'user_function_keyword_arguments_unsupported','function_name' => '" + fn +
                   "','got' => 1,'kind' => 'codeblock_runtime_error'}, 'LinkedSpec::CodeblockRuntime::Error' )")
        require(len(lines) == 2 and re.fullmatch(prefix + "DECISION rule_handler_eval:Top => SKIPPED", lines[0])
                and re.fullmatch(prefix + re.escape(context), lines[1]), "keyword retained native trace")
        source = x["action_probe_source"][1:-1]
        require(source[start:end] == token and source.count(token) == 1, "keyword independent source span")
        meta = x["metadata"]
        require(meta["canonical_action_ir_fallback_count"] == meta["unresolved_helper_count"] == 0,
                "keyword unchanged top-level diagnostics")
        require(meta["raw_perl_dependency_count"] == (0 if mode == "before" else 1) and
                meta["language_agnostic_action_ir_ready"] == (1 if mode == "before" else 0),
                "keyword source-presence policy")
        if mode == "after":
            require(meta["raw_perl_expression_dependencies"] == [{"reason": "unsupported_expression",
                    "source": token, "source_span": {"start": start, "end": end}, "source_unit": 0}] and
                    meta["raw_perl_expression_source_units"] == [{"kind": "icode", "index": 0, "source": source}],
                    "keyword occurrence provenance")
            require(meta["raw_perl_dependency_statements"] == meta["language_agnostic_action_ir_blocker_statements"] == [token]
                    and meta["language_agnostic_action_ir_blocker_statement_count"] == 1,
                    "keyword visible source blocker")
        found[(name, seed)] = x
    require(set(found) == {(name, seed) for name in cases for seed in record["seeds"]}, "keyword complete capture")
    return found


def test_capture(record, mode):
    require(record["owner"] == OWNER and record["mode"] == mode and len(record["rows"]) == 1,
            "keyword TAP population")
    row = record["rows"][0]
    require(row["command"][-1] == TEST and row["exit"] == (2 if mode == "before" else 0) and
            re.findall(r"^1\.\.(\d+)$", row["stdout"], re.M) == ["605"], "keyword TAP plan/exit")
    failures = re.findall(r"^not ok (\d+) - (.*)$", row["stdout"], re.M)
    expected = [("86", "bridge_keyword_deferred has exact readiness/fallback/unresolved metadata"),
                ("181", "bridge_keyword_effects has exact readiness/fallback/unresolved metadata")]
    require(failures == (expected if mode == "before" else []) and
            len(re.findall(r"^(?:not )?ok \d+", row["stdout"], re.M)) == 605,
            "keyword complete telemetry-only RED/GREEN")
    if mode == "after":
        require("Result: PASS" in row["stdout"] and re.search(r"Files=1, Tests=605\b", row["stdout"]),
                "keyword complete GREEN result")


def reject(name, action, reason):
    try:
        action()
    except ValueError as error:
        require(str(error) == reason, "unrelated rejection: " + name + ": " + str(error))
        return {"name": name, "reason": str(error)}
    raise ValueError("accepted mutation: " + name)


def main():
    old_fixture = fixture()
    cases = {x["id"]: x for x in json.loads(read("keyword-cases.json"))}
    require(set(cases) == set(EXPECTED), "keyword exact control sources")
    for name, case in cases.items():
        # Independently bind each complete source to unchanged authored fixture literals.
        fn, body = case["source"].split("\nTop:: I { ")
        body = body.removesuffix(" }\n\n")
        require("'functions'=>'" + fn + "'" in old_fixture.decode() and
                "'body'=>'" + body + "'" in old_fixture.decode() and case["input"] == "x",
                "keyword fixture source identity")
    before_record, after_record = (json.loads(read("keyword-" + mode + ".json")) for mode in ("before", "after"))
    before, after = observations(before_record, "before", cases), observations(after_record, "after", cases)
    for key, current in after.items():
        prior = before[key]
        for field in ("ast", "action_probe_source", "substitution", "dump", "emitted"):
            require(current[field] == prior[field], "keyword unchanged compiler output: " + field)
        require(set(current["metadata"]) == set(prior["metadata"]) | NEW and
                {k:v for k,v in current["metadata"].items() if k not in CHANGED} ==
                {k:v for k,v in prior["metadata"].items() if k not in CHANGED}, "keyword unchanged event diagnostics")
        for route in ("native", "fresh"):
            require({k:v for k,v in current[route].items() if k != "stdout"} ==
                    {k:v for k,v in prior[route].items() if k != "stdout"}, "keyword unchanged consumer observations")
        for field in ("ast", "metadata", "substitution", "dump", "emitted"):
            require(current[field] == after[(key[0], "0")][field], "keyword measured seed stability")
    for mode in ("before", "after"):
        test_capture(json.loads(read("keyword-tests-" + mode + ".json")), mode)
    controls = []
    for name, mutate, reason in (
        ("keyword readiness hidden", lambda x:x["metadata"].update(language_agnostic_action_ir_ready=1), "keyword source-presence policy"),
        ("keyword span shifted", lambda x:x["metadata"]["raw_perl_expression_dependencies"][0]["source_span"].update(start=0), "keyword occurrence provenance"),
        ("keyword operand effects", lambda x:x["fresh"]["invocations"][0].update(effects_after=["bad"]), "keyword no operand effects"),
        ("keyword error replaced", lambda x:x["fresh"].update(actual_error_identity=0), "keyword original pre-operand error identity"),
        ("keyword emitted digest replaced", lambda x:x["fresh"].update(emitted_sha256="0"*64), "keyword emitted identity"),
        ("keyword trace lost", lambda x:x["native"].update(stdout=""), "keyword retained native trace"),
    ):
        altered = copy.deepcopy(after_record)
        row = altered["rows"][0]
        mutate(row["observation"]["cases"][0])
        row["stdout"] = json.dumps(row["observation"])
        controls.append(reject(name, lambda:observations(altered, "after", cases), reason))
    spec = importlib.util.spec_from_file_location("keyword_canonical_failure", ROOT / (PREFIX + "canonical-runtime-failure.py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    failure = json.loads(read("canonical-runtime-before.json"))
    raw = module.validate(failure)
    for field, value, reason in (("base64", "!", "runtime canonical base64"),
                                 ("compressed_sha256", "0"*64, "runtime canonical compressed identity"),
                                 ("bytes", len(raw)+1, "runtime canonical raw identity")):
        altered = copy.deepcopy(failure)
        altered["log_envelope"][field] = value
        controls.append(reject("runtime failure envelope " + field, lambda:module.validate(altered), reason))
    paths = {TEST, "perl/LinkedSpec/CodeblockRuntime.pm", "perl/LinkedSpec/ActionIR/AST/Parser.pm"}
    paths.update(PREFIX + suffix for suffix in (
        "keyword-cases.json", "keyword-probe.pl", "keyword-fresh.pl", "keyword-capture.py",
        "keyword-before.json", "keyword-after.json", "keyword-tests.py", "keyword-tests-before.json",
        "keyword-tests-after.json", "keyword-review.py", "before-codeblock-push.t",
        "canonical-runtime-failure.py", "canonical-runtime-before.json", "before-EmitContext.pm", "before-Diagnostics.pm"))
    print(json.dumps({"owner": OWNER, "result": "PASS", "activation": BASE,
                      "sources": len(cases), "native_fresh_pairs": len(after), "top_level_TAP_tests": 605,
                      "actual_RED": {"plan": 605, "failed_top_level": 2, "assertions": [86,181]},
                      "second_canonical_failure_log_bytes": len(raw), "controls": controls,
                      "tracked_inputs": {path:sha((ROOT/path).read_bytes()) for path in sorted(paths)},
                      "limits": "Supplemental keyword controls are typed rejections, not syntax admission. Reporting counts unsupported source even though guard rejects before operands; every execution/lowering/error/effect assertion remains exact. Native timestamped traces are retained and shape-checked, not compared byte-for-byte. Three named seeds are not a probability interval."}, indent=2))


if __name__ == "__main__":
    main()

"""Read-only source/observation review for the deferred conditional diagnosis.

Only managed scratch logs are written. Complete stdout is the proof capture;
the separate observations file retains actual public sources and emitted bytes.
"""
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-"
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0"
OBSERVATIONS = PREFIX + "observations.json"
SUCCESS = {"direct_attached": "hit", "function_value_if": "ok", "bridged_value_if": "ok",
           "early_return_scope": ["inside", "outside"], "implicit_result": "hit"}
CONDITIONALS = {"deferred_original", "deferred_false", "deferred_true", "deferred_else",
                "deferred_elseif", "deferred_nested", "deferred_when", "deferred_marker",
                "deferred_effect", "deferred_effect_scope"}
OTHER_ERRORS = {"deferred_inline": ("unknown_helper", "codeblock_runtime_error", "else"),
                "deferred_matches": ("unsupported_codeblock_actionir", "regex", None),
                "bridged_attached": ("user_function_body_unsupported", "codeblock_runtime_error", None)}
UNSUPPORTED_FUNCTIONS = {"function_attached", "function_false"}
SUITES = ("t/callable_codeblock_literal_contract.t", "t/actionir_ast_parser.t",
          "t/codeblock_push_composition_perl.t", "t/composed_normalization_perl.t")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def check(observation):
    require("RuntimeLogical::truthy" in observation["direct_control_substitution"],
            "direct typed control substitution absent")
    rows = observation["cases"]
    expected_ids = set(SUCCESS) | CONDITIONALS | set(OTHER_ERRORS) | UNSUPPORTED_FUNCTIONS
    require(len(rows) == len(expected_ids) and {row["id"] for row in rows} == expected_ids,
            "observation population mismatch")
    by_id = {row["id"]: row for row in rows}
    for row in rows:
        require(digest(row["source"].encode()) == row["source_sha256"], "source identity mismatch")
        require(isinstance(row["dump"], str) and row["dump"], "public source dump absent")
        require(digest(row["emitted"].encode()) == row["emitted_sha256"] ==
                row["fresh"]["emitted_sha256"], "fresh emitted identity mismatch")
        require(row["native"]["exception"] is None, "unexpected native host exception")
        for route in ("native", "fresh"):
            actual = row[route]
            require(actual["stderr"] == "", "unexpected host stderr")
            error = actual["context_error"] if route == "native" else actual["exception"]
            ident = row["id"]
            if ident in SUCCESS:
                require(actual["value"] == SUCCESS[ident] and error is None and actual["stdout"] == "",
                        "positive value/scope oracle mismatch")
            elif ident in UNSUPPORTED_FUNCTIONS:
                require(actual["value"] is None and error is None and actual["stdout"] == "" and
                        row["metadata"]["language_agnostic_action_ir_ready"] == 0 and
                        row["metadata"]["unresolved_helper_count"] > 0,
                        "unsupported function boundary mismatch")
            else:
                require(actual["value"] is None and isinstance(error, dict), "typed failure absent")
                expected = ("unsupported_codeblock_actionir", "control_if", None) \
                    if ident in CONDITIONALS else OTHER_ERRORS[ident]
                detail = error["detail"]
                require(detail["observed_class"] == "LinkedSpec::CodeblockRuntime::Error" and
                        (detail["code"], detail["kind"], detail.get("name")) == expected,
                        "wrong typed failure boundary")
                require(actual["actual_error_identity"] == 1, "actual exception identity lost")
                require(error["type"] == ("runtime_handler" if route == "native" else "generated_source_error"),
                        "wrong public error carrier")
    for ident, failed in (("early_return_scope", False), ("deferred_effect_scope", True)):
        for route in ("native", "fresh"):
            invocations = by_id[ident][route]["invocations"]
            require(len(invocations) == 1, "actual invocation population mismatch")
            actual = invocations[0]
            require(actual["x_before"] == actual["x_after"] == "outside" and
                    actual["x_same_actual_slot"] == 1 and actual["equal_value_distinct_slot_rejected"] == 1,
                    "actual parameter restoration/identity mismatch")
            if failed:
                require(actual["effects_before"] == [] and actual["effects_after"] == ["before"],
                        "unsupported control effect boundary mismatch")
    ast = observation["literal_ast"]
    require(len(ast) == 4 and all(row["node"]["kind"] == "codeblock_literal" for row in ast),
            "literal AST population mismatch")
    kinds = [[stmt["expr"]["kind"] for stmt in row["node"]["body_ast"]["statements"]] for row in ast]
    require(kinds == [["control_if", "call"], ["control_if", "control_if", "control_else"],
                     ["control_if", "control_else"],
                     ["control_if", "call", "control_else", "call", "control_endif"]],
            "typed branch topology mismatch")


def main():
    observation_bytes = (ROOT / OBSERVATIONS).read_bytes()
    observation = json.loads(observation_bytes)
    check(observation)
    scratch = ROOT / ".linkedspec-data/scratch/deferred-control-diagnosis"
    scratch.mkdir(parents=True, exist_ok=True)
    require(scratch.resolve().is_relative_to(ROOT / ".linkedspec-data/scratch") and
            scratch.stat().st_dev == ROOT.stat().st_dev, "scratch escapes repository volume")
    replay_command = ["perl", "-Iperl", PREFIX + "probe.pl"]
    replay = subprocess.run(replay_command, cwd=ROOT, env=dict(os.environ, PERL5LIB=""), capture_output=True)
    (scratch / "public-replay.json").write_bytes(replay.stdout)
    require(replay.returncode == 0 and not replay.stderr, "public replay failed")
    current = json.loads(replay.stdout)
    check(current)

    def core(value):
        return [{key: row[key] for key in ("id", "source_sha256", "emitted_sha256", "native", "fresh")}
                for row in value["cases"]]

    def replay_comparison(value):
        projected = copy.deepcopy(core(value))
        for row in projected:
            if row["native"]["context_error"] is not None:
                row["native"]["stdout"] = re.sub(
                    r"(?m)^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]", "[wall-clock]",
                    row["native"]["stdout"])
        return projected

    # Raw descriptor event ordering retains its separate .0.6 owner. Published
    # values, typed carriers, real identities/effects and generated bytes agree.
    require(replay_comparison(current) == replay_comparison(observation),
            "replayed public semantic/source observation drift")
    controls = []

    def reject(name, changed):
        try:
            check(changed)
        except ValueError as error:
            controls.append({"name": name, "reason": str(error)})
        else:
            raise ValueError("corruption accepted: " + name)

    for name in ("typed-kind", "host-load", "positive-value", "source", "emitted", "restoration",
                 "equal-value-identity", "effect", "exception-identity", "branch-topology"):
        changed = copy.deepcopy(observation)
        rows = {row["id"]: row for row in changed["cases"]}
        if name == "typed-kind":
            rows["deferred_original"]["fresh"]["exception"]["detail"]["kind"] = "raw_perl"
        elif name == "host-load":
            rows["deferred_original"]["fresh"]["exception"] = "generated module did not load"
        elif name == "positive-value":
            rows["bridged_value_if"]["fresh"]["value"] = "miss"
        elif name == "source":
            rows["deferred_original"]["source"] += " changed"
        elif name == "emitted":
            rows["deferred_original"]["emitted"] += " changed"
        elif name == "restoration":
            rows["deferred_effect_scope"]["native"]["invocations"][0]["x_after"] = "inside"
        elif name == "equal-value-identity":
            rows["early_return_scope"]["fresh"]["invocations"][0]["x_same_actual_slot"] = 0
        elif name == "effect":
            rows["deferred_effect_scope"]["fresh"]["invocations"][0]["effects_after"].append("after")
        elif name == "exception-identity":
            rows["deferred_original"]["native"]["actual_error_identity"] = 0
        else:
            changed["literal_ast"][1]["node"]["body_ast"]["statements"].reverse()
        reject(name, changed)

    logs, tests = [], []
    for path in SUITES:
        command = ["prove", "-v", "-Iperl", path]
        process = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PERL5LIB=""), capture_output=True)
        output = process.stdout + process.stderr
        log = scratch / (Path(path).name + ".log")
        log.write_bytes(output)
        require(process.returncode == 0, "focused suite failed: " + path)
        match = re.search(r"Files=1, Tests=(\d+),", process.stdout.decode())
        require(match is not None and "Result: PASS" in process.stdout.decode(), "incomplete focused TAP")
        tests.append({"path": path, "tests": int(match.group(1))})
        logs.append({"path": log.relative_to(ROOT).as_posix(), "sha256": digest(output), "command": command,
                     "stdout": process.stdout.decode(), "stderr": process.stderr.decode(), "exit": 0})
    paths = set(subprocess.check_output(["git", "ls-files", "perl"], cwd=ROOT).decode().splitlines())
    paths.update(SUITES)
    paths.update(PREFIX + name for name in ("probe.pl", "fresh.pl", "observe.pm", "review.py",
                 "probe-before.pl", "observation-before.json", "observations.json"))
    paths.update(("capability_conformance/callable_codeblock_contract.json",
                  "capability_conformance/callable_signature_contract.json",
                  "capability_conformance/logical_helper_contract.json",
                  "tools/project_data_run.sh", "tools/project_data_env.sh", "tools/run_python_project_data.sh",
                  "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2-verification.json",
                  "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-fresh.pl",
                  "tests/language-readiness/composed/normalization-calls.spec"))
    inputs = {path: digest((ROOT / path).read_bytes()) for path in sorted(paths)}
    for path in paths:
        if path.startswith(("perl/", "t/", "capability_conformance/", "tests/")):
            baseline = subprocess.check_output(["git", "show", "e07f80f74c8c80b426c4b846a1293139848229db:" + path], cwd=ROOT)
            require(digest(baseline) == inputs[path], "production/test/authority changed: " + path)
    print(json.dumps({"version": 1, "owner": OWNER, "observations": {"path": OBSERVATIONS,
        "sha256": digest(observation_bytes), "cases": len(observation["cases"]), "literal_asts": 4},
        "successes": SUCCESS, "conditional_failure_ids": sorted(CONDITIONALS),
        "other_error_ids": sorted(OTHER_ERRORS), "unsupported_function_ids": sorted(UNSUPPORTED_FUNCTIONS),
        "actual_public_replay": {"command": replay_command, "exit": replay.returncode,
                                 "core": core(current), "retained_generated_bytes_exact": True,
                                 "comparison_projection": "Only native failure trace line wall-clock prefixes are projected; all original/current raw bytes are retained. Framework traces are not DSL effect events. Raw descriptor event ordering has separate .0.6 ownership."},
        "controls": controls, "tests": tests, "logs": logs, "tracked_inputs": inputs,
        "repair_owners": {"attached": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1",
                          "marker": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2",
                          "value": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3",
                          "matches": "SESSION-STARTUP-READING.87.2"},
        "limits": "Source-preserving diagnosis. Actual restoration/error/effect checks execute inside public invoke observers; report corruption is not a semantic runtime mutant. Function statement controls are not admitted by this value-oriented MVP proof. Metadata order/readiness, dispatcher/full16 and other backend repairs retain separate owners."}, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()

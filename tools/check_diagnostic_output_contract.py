#!/usr/bin/env python3
"""Validate the backend-neutral diagnostic-output event contract."""

from __future__ import annotations

import copy
import json
import math
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "diagnostic_output_contract.json"
TASK_PATH = ROOT / "docs" / "tasks" / "FUTURE-PARITY-BACKLOG.md"
CLI_MANIFEST_PATH = ROOT / "cli_conformance" / "manifest.json"

POLICY = {
    "arity_validation": "validate positional arity before evaluating any argument",
    "evaluation": "evaluate every valid call argument exactly once from left to right before formatting or delivery",
    "non_scalar_fragments": "null, array, harray, and codeblock render as empty diagnostic fragments without changing linkedspec-scalar-text-v1 cat behavior",
    "wrong_kind": "a print_each target that is not an array emits no events after all valid-call arguments evaluate",
    "result_neutrality": "each helper returns null and no event enters the rule accumulator, direct value, or parse output",
    "delivery": "an optional per-invocation caller sink receives synchronous ordered typed events; absent sink is quiet",
    "sink_failure": "propagate the caller failure unchanged, abort immediately, and evaluate or deliver nothing later",
    "exit_now": "deliver preceding events, then propagate typed exit status immediately without evaluating later actions",
    "trace_separation": "rich diagnostic events are distinct from native trace and ADR 0024 canonical primary phase trace",
}
EVENT_SCHEMA = {
    "native_type": "RuntimeDiagnosticOutputEvent",
    "fields": ["helper_name", "rule_label", "message"],
    "helper_names": ["print", "say", "print_each"],
    "rule_label": "the current executing rule label",
    "message": "exact Unicode text",
}
HELPERS = [
    {
        "name": "print",
        "arity": {"minimum": 1, "maximum": None, "expected_text": "at least 1 positional argument"},
        "grouping": "one event per call",
        "text": "concatenate all diagnostic fragments without an added newline",
        "return_kind": "null",
    },
    {
        "name": "say",
        "arity": {"minimum": 1, "maximum": None, "expected_text": "at least 1 positional argument"},
        "grouping": "one event per call",
        "text": "concatenate all diagnostic fragments and add exactly one trailing newline",
        "return_kind": "null",
    },
    {
        "name": "print_each",
        "arity": {"accepted": [2, 3], "expected_text": "2 or 3 positional arguments"},
        "grouping": "one event per array item in order",
        "text": "prefix plus diagnostic item fragment plus optional suffix; omitted suffix is empty",
        "return_kind": "null",
    },
]
PROGRAM_SOURCES = {
    "ordered_unicode": """Top::
 /x/
 E {
   seen = []
   items = ["α", false, undef, [1], { "k" : 1 }, "🙂"]
   print({ push(seen, "print-left"); return("pré") }, { push(seen, "print-right"); return("🙂") })
   say({ push(seen, "say"); return(" ligne") })
   print_each(
     { push(seen, "items"); return(items) },
     { push(seen, "prefix"); return("élément:") },
     { push(seen, "suffix"); return("!") }
   )
   print_each({ push(seen, "items-default"); return(items) }, "raw:")
   return(copy(seen))
 }
""",
    "wrong_kind": """Top::
 /x/
 E {
   seen = []
   print_each(
     { push(seen, "empty-target"); return([]) },
     { push(seen, "empty-prefix"); return("unused:") }
   )
   print_each(
     { push(seen, "target"); return("not-an-array") },
     { push(seen, "prefix"); return("unused:") },
     { push(seen, "suffix"); return("!") }
   )
   return(copy(seen))
 }
""",
    "sink_failure": """Top::
 /x/
 E {
   seen = []
   print({ push(seen, "before"); return("before") })
   say({ push(seen, "boom"); return("boom") })
   print({ push(seen, "after"); return("after") })
   return(copy(seen))
 }
""",
    "immediate_exit": """Top::
 /x/
 E {
   seen = []
   say({ push(seen, "before"); return("before") })
   exit_now(23)
   say({ push(seen, "after"); return("after") })
   return(copy(seen))
 }
""",
}
SCENARIO_IDS = [
    "ordered_unicode_with_sink",
    "ordered_unicode_quiet",
    "wrong_kind_no_events",
    "print_each_sink_failure",
    "synchronous_sink_failure",
    "event_before_immediate_exit",
]
PROJECTIONS = {
    "native": "optional caller-owned per-invocation sink; no sink is quiet; no implicit stdout or stderr",
    "generated": "every available generated execution entrypoint accepts an equivalent per-invocation sink and preserves native outcomes",
    "primary_cli": "install no rich sink; success emits canonical JSON of parse output plus one newline on stdout and empty stderr",
    "primary_trace": "ADR 0024 phase events only when requested; never include RuntimeDiagnosticOutputEvent data",
    "cli_options": "add no diagnostic-output-specific primary option",
}
RECURRING_GATE = {
    "driver": "tools/check_diagnostic_output_five_backend.sh",
    "consumer_schema": {
        "fields": ["backend", "runtime", "test_path", "roles"],
        "roles": ["native", "generated"],
    },
    "consumers": [
        {
            "backend": "perl",
            "runtime": "perl",
            "test_path": "t/diagnostic_output_perl_contract.t",
            "roles": ["native", "generated"],
        },
        {
            "backend": "rust",
            "runtime": "rust",
            "test_path": "rust/linkedspec-runtime/tests/diagnostic_output_contract.rs",
            "roles": ["native", "generated"],
        },
        {
            "backend": "dart",
            "runtime": "dart",
            "test_path": "dart/test/diagnostic_output_contract_test.dart",
            "roles": ["native", "generated"],
        },
        {
            "backend": "julia",
            "runtime": "julia",
            "test_path": "julia/test/diagnostic_output_contract_test.jl",
            "roles": ["native", "generated"],
        },
        {
            "backend": "lua",
            "runtime": "puc_lua",
            "test_path": "lua/test/diagnostic_output_contract_test.lua",
            "roles": ["native", "generated"],
        },
        {
            "backend": "lua",
            "runtime": "luajit",
            "test_path": "lua/test/diagnostic_output_contract_test.lua",
            "roles": ["native", "generated"],
        },
    ],
    "primary_cli": {
        "matrix_driver": "tools/run_primary_cli_matrix.sh",
        "case_id": "success_diagnostic_helpers_quiet",
        "backend_count": 5,
        "environments": ["default", "posix"],
    },
    "support_checks": [
        "tools/check_generated_source_contract.pl",
        "tools/check_capability_conformance.pl",
        "tools/check_language_capability_coverage.pl",
    ],
    "local_ci": {
        "driver": "tools/run_ci_local.sh",
        "switch": "LINKEDSPEC_RUN_DIAGNOSTIC_MATRIX",
    },
}
PUBLIC_CONTRACT = {
    "documents": [
        {
            "path": "README.md",
            "required_markers": [
                "tools/check_diagnostic_output_five_backend.sh",
                "LINKEDSPEC_RUN_DIAGNOSTIC_MATRIX=1",
            ],
        },
        {
            "path": "USER_GUIDE_ActionIR_ControlFlow.md",
            "required_markers": [
                "caller-owned `RuntimeDiagnosticOutputEvent`",
                "`print_each` requires exactly two or three",
            ],
        },
        {
            "path": "USER_GUIDE_ActionIR_EmittedPerlReference.md",
            "required_markers": [
                "`LinkedSpec::RuntimeDiagnosticOutput::emit`",
                "never raw host `print`/`say`",
            ],
        },
        {
            "path": "rust/README.md",
            "required_markers": [
                "## Diagnostic Output Events",
                "`execute_with_diagnostic_output`",
                "`execute_with_trace_and_diagnostic_output`",
            ],
        },
        {
            "path": "dart/README.md",
            "required_markers": ["`diagnosticOutputSink`", "`executeWithTrace`", "generated entrypoints"],
        },
        {
            "path": "julia/README.md",
            "required_markers": ["`diagnostic_output_sink`", "`LinkedSpecGeneratedParser.execute_with_trace`"],
        },
        {
            "path": "lua/README.md",
            "required_markers": ["`diagnostic_sink`", "`generated.execute_with_trace`", "PUC Lua and LuaJIT"],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/helper-contract-catalog.md",
            "required_markers": ["ADR `0042`", "`RuntimeDiagnosticOutputEvent`", "all five backends"],
        },
        {
            "path": "docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md",
            "required_markers": [
                "Generated modules expose",
                "`success_diagnostic_helpers_quiet`",
                "tools/check_diagnostic_output_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/dsl/action-model-and-helper-surface.md",
            "required_markers": ["`RuntimeDiagnosticOutputEvent`", "caller-owned"],
        },
        {
            "path": "docs/linkedspec-book/src/public-api/trace-api.md",
            "required_markers": ["## Diagnostic output is not trace", "ADR `0042`", "ADR `0024`"],
        },
        {
            "path": "docs/linkedspec-book/src/compiler/diagnostics.md",
            "required_markers": [
                "`GeneratedDiagnosticOutputExecutionError`",
                "`execute_with_trace_and_diagnostic_output`",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/formal-grammar.md",
            "required_markers": ["caller-owned diagnostic event"],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "required_markers": ["`linkedspec-diagnostic-output-v1`", "8 complete / 0 pending"],
        },
        {
            "path": "capability_conformance/README.md",
            "required_markers": ["20 representative", "8 complete / 0 pending"],
        },
        {
            "path": "cli_conformance/README.md",
            "required_markers": ["success_diagnostic_helpers_quiet", "5x2x63 matrix"],
        },
    ],
    "forbidden_current_claims": [
        {"path": "dart/README.md", "text": "Generated parser entrypoint propagation remains owned"},
        {"path": "julia/README.md", "text": "Generated entrypoint propagation remains separately pending"},
        {
            "path": "docs/linkedspec-book/src/compiler/diagnostics.md",
            "text": "Generated parser sink propagation remains separately pending",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/helper-contract-catalog.md",
            "text": "default-suffix drift remains explicitly owned",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "text": "Julia emits these messages through a",
        },
        {"path": "USER_GUIDE_ActionIR_ControlFlow.md", "text": "prints every item in one working array"},
        {
            "path": "USER_GUIDE_ActionIR_EmittedPerlReference.md",
            "text": '`print "item<<", $_, ">>\\n" foreach',
        },
        {
            "path": "docs/linkedspec-book/src/dsl/action-model-and-helper-surface.md",
            "text": "`say(...)` — print with newline",
        },
        {"path": "docs/linkedspec-book/src/appendix/formal-grammar.md", "text": "debug output each element"},
    ],
}
GATE_CONSUMER_MARKERS = {
    "perl": "t/diagnostic_output_perl_contract.t",
    "rust": "--test diagnostic_output_contract",
    "dart": "test/diagnostic_output_contract_test.dart",
    "julia": "julia/test/diagnostic_output_contract_test.jl",
    "puc_lua": "build_lua_native.sh puc",
    "luajit": "build_lua_native.sh luajit",
}
ROLLOUT = [
    ("perl_native", "complete", "FUTURE-PARITY-BACKLOG.5.1.2"),
    ("rust_native", "complete", "FUTURE-PARITY-BACKLOG.5.1.3"),
    ("dart_native", "complete", "FUTURE-PARITY-BACKLOG.5.1.4"),
    ("julia_native", "complete", "FUTURE-PARITY-BACKLOG.5.1.5"),
    ("lua_native", "complete", "FUTURE-PARITY-BACKLOG.5.1.6"),
    ("generated_and_primary_cli", "complete", "FUTURE-PARITY-BACKLOG.5.1.7"),
    ("recurring_five_backend_gate", "complete", "FUTURE-PARITY-BACKLOG.5.1.8"),
    ("public_no_drift", "complete", "FUTURE-PARITY-BACKLOG.5.1.9"),
]


class ContractError(ValueError):
    """Stable neutral-contract validation failure."""


class SinkFailure(RuntimeError):
    """Model a caller-owned sink failure without rewriting its identity."""

    def __init__(self, error_id: str):
        super().__init__(error_id)
        self.error_id = error_id


def fail(detail: str) -> None:
    raise ContractError(detail)


def require_fields(value: Any, fields: set[str], context: str) -> dict[str, Any]:
    if not isinstance(value, dict) or set(value) != fields:
        fail(f"{context} fields drifted")
    return value


def validate_typed_value(value: Any, context: str) -> dict[str, Any]:
    if not isinstance(value, dict) or not isinstance(value.get("kind"), str):
        fail(f"{context} is not a typed value")
    kind = value["kind"]
    if kind == "string":
        require_fields(value, {"kind", "value"}, context)
        if not isinstance(value["value"], str):
            fail(f"{context} string payload drifted")
    elif kind == "boolean":
        require_fields(value, {"kind", "value"}, context)
        if not isinstance(value["value"], bool):
            fail(f"{context} boolean payload drifted")
    elif kind == "number":
        require_fields(value, {"kind", "value"}, context)
        number = value["value"]
        if isinstance(number, bool) or not isinstance(number, (int, float)) or not math.isfinite(number):
            fail(f"{context} number payload is not finite")
    elif kind == "null":
        require_fields(value, {"kind"}, context)
    elif kind == "array":
        require_fields(value, {"kind", "items"}, context)
        if not isinstance(value["items"], list):
            fail(f"{context} array payload drifted")
        for index, item in enumerate(value["items"]):
            validate_typed_value(item, f"{context} item {index}")
    elif kind == "harray":
        require_fields(value, {"kind", "entries"}, context)
        if not isinstance(value["entries"], dict) or not all(isinstance(key, str) for key in value["entries"]):
            fail(f"{context} harray payload drifted")
        for key, item in value["entries"].items():
            validate_typed_value(item, f"{context} entry {key!r}")
    elif kind == "codeblock":
        require_fields(value, {"kind", "id"}, context)
        if not isinstance(value["id"], str) or value["id"] == "":
            fail(f"{context} codeblock id drifted")
    else:
        fail(f"{context} has unknown kind {kind!r}")
    return value


def diagnostic_text(value: dict[str, Any]) -> str:
    validate_typed_value(value, "diagnostic value")
    kind = value["kind"]
    if kind == "string":
        return value["value"]
    if kind == "boolean":
        return "1" if value["value"] else "0"
    if kind == "number":
        number = value["value"]
        if number == 0:
            return "0"
        if float(number).is_integer():
            return str(int(number))
        return format(number, ".15g")
    return ""


def arity_failure(helper_name: str, actual: int) -> dict[str, Any] | None:
    if helper_name in {"print", "say"} and actual < 1:
        expected = "at least 1 positional argument"
    elif helper_name == "print_each" and actual not in {2, 3}:
        expected = "2 or 3 positional arguments"
    else:
        return None
    return {
        "helper_name": helper_name,
        "actual_arity": actual,
        "expected_arity": expected,
        "expected_code": "helper_arity_mismatch",
        "arguments_evaluated": 0,
    }


def evaluate_program(program: dict[str, Any], sink: dict[str, Any]) -> dict[str, Any]:
    mode = sink.get("mode")
    if mode not in {"absent", "collect", "fail_on_invocation"}:
        fail(f"unknown sink mode {mode!r}")
    if mode == "fail_on_invocation":
        require_fields(sink, {"mode", "invocation", "error_id"}, "failing sink")
        if not isinstance(sink["invocation"], int) or sink["invocation"] < 1:
            fail("failing sink invocation drifted")
        if not isinstance(sink["error_id"], str) or sink["error_id"] == "":
            fail("failing sink error id drifted")
    else:
        require_fields(sink, {"mode"}, "sink")

    seen: list[str] = []
    evaluation_order: list[str] = []
    events: list[dict[str, str]] = []
    invocation = 0

    def deliver(event: dict[str, str]) -> None:
        nonlocal invocation
        if mode == "absent":
            return
        invocation += 1
        events.append(event)
        if mode == "fail_on_invocation" and invocation == sink["invocation"]:
            raise SinkFailure(sink["error_id"])

    try:
        for op_index, operation in enumerate(program["operations"]):
            if not isinstance(operation, dict) or "op" not in operation:
                fail(f"program {program['id']} operation {op_index} drifted")
            op = operation["op"]
            if op in {"print", "say", "print_each"}:
                require_fields(operation, {"op", "rule_label", "args"}, f"{program['id']} helper operation")
                if not isinstance(operation["rule_label"], str) or not isinstance(operation["args"], list):
                    fail(f"{program['id']} helper operation payload drifted")
                arity_error = arity_failure(op, len(operation["args"]))
                if arity_error is not None:
                    fail(f"fixture program contains invalid helper arity: {arity_error}")
                values: list[dict[str, Any]] = []
                for arg_index, argument in enumerate(operation["args"]):
                    require_fields(argument, {"effect", "value"}, f"{program['id']} argument {arg_index}")
                    effect = argument["effect"]
                    if effect is not None:
                        if not isinstance(effect, str) or effect == "":
                            fail(f"{program['id']} argument effect drifted")
                        seen.append(effect)
                        evaluation_order.append(effect)
                    values.append(validate_typed_value(argument["value"], f"{program['id']} argument value"))
                if op == "print_each":
                    if values[0]["kind"] != "array":
                        continue
                    prefix = diagnostic_text(values[1])
                    suffix = diagnostic_text(values[2]) if len(values) == 3 else ""
                    for item in values[0]["items"]:
                        deliver(
                            {
                                "helper_name": op,
                                "rule_label": operation["rule_label"],
                                "message": prefix + diagnostic_text(item) + suffix,
                            }
                        )
                else:
                    message = "".join(diagnostic_text(value) for value in values)
                    if op == "say":
                        message += "\n"
                    deliver({"helper_name": op, "rule_label": operation["rule_label"], "message": message})
            elif op == "exit_now":
                require_fields(operation, {"op", "status"}, f"{program['id']} exit operation")
                if not isinstance(operation["status"], int):
                    fail(f"{program['id']} exit status drifted")
                return {
                    "evaluation_order": evaluation_order,
                    "events": events,
                    "outcome": {"kind": "exit_now", "status": operation["status"]},
                }
            elif op == "return_seen":
                require_fields(operation, {"op"}, f"{program['id']} return operation")
                value = copy.deepcopy(seen)
                return {
                    "evaluation_order": evaluation_order,
                    "events": events,
                    "outcome": {"kind": "success", "value": value, "output": [copy.deepcopy(value)]},
                }
            else:
                fail(f"program {program['id']} has unknown operation {op!r}")
    except SinkFailure as error:
        return {
            "evaluation_order": evaluation_order,
            "events": events,
            "outcome": {"kind": "sink_failure", "error_id": error.error_id, "propagation": "unchanged"},
        }
    fail(f"program {program['id']} completed without return or exit")


def validate_contract(contract: dict[str, Any]) -> None:
    if set(contract) != {
        "format",
        "contract_id",
        "policy",
        "event_schema",
        "helpers",
        "scalar_render_cases",
        "invalid_arity_cases",
        "programs",
        "scenarios",
        "projections",
        "recurring_gate",
        "public_contract",
        "backend_rollout",
    }:
        fail("top-level fields drifted")
    if contract["format"] != 1 or contract["contract_id"] != "linkedspec-diagnostic-output-v1":
        fail("format or contract id drifted")
    if contract["policy"] != POLICY:
        fail("policy drifted")
    if contract["event_schema"] != EVENT_SCHEMA:
        fail("event schema drifted")
    if contract["helpers"] != HELPERS:
        fail("helper arity, grouping, text, or result contract drifted")

    render_cases = contract["scalar_render_cases"]
    expected_render_ids = [
        "string_unicode",
        "string_empty",
        "boolean_false",
        "boolean_true",
        "number_integral",
        "number_fraction",
        "number_negative_zero",
        "null",
        "array",
        "harray",
        "codeblock",
    ]
    if not isinstance(render_cases, list) or [case.get("id") for case in render_cases] != expected_render_ids:
        fail("scalar render case coverage or order drifted")
    for case in render_cases:
        require_fields(case, {"id", "value", "expected"}, f"scalar render case {case.get('id')}")
        if diagnostic_text(case["value"]) != case["expected"]:
            fail(f"scalar render result drifted for {case['id']}")

    invalid_cases = contract["invalid_arity_cases"]
    expected_invalid = [
        ("print_zero", "print", 0),
        ("say_zero", "say", 0),
        ("print_each_zero", "print_each", 0),
        ("print_each_one", "print_each", 1),
        ("print_each_four", "print_each", 4),
    ]
    if not isinstance(invalid_cases, list) or len(invalid_cases) != len(expected_invalid):
        fail("invalid arity coverage drifted")
    for case, (case_id, helper_name, actual) in zip(invalid_cases, expected_invalid):
        require_fields(
            case,
            {"id", "helper_name", "actual_arity", "expected_arity", "expected_code", "arguments_evaluated"},
            f"invalid arity case {case_id}",
        )
        expected = arity_failure(helper_name, actual)
        if case["id"] != case_id or case != {"id": case_id, **(expected or {})}:
            fail(f"invalid arity result drifted for {case_id}")

    programs = contract["programs"]
    if not isinstance(programs, list) or [program.get("id") for program in programs] != list(PROGRAM_SOURCES):
        fail("program coverage or order drifted")
    program_by_id: dict[str, dict[str, Any]] = {}
    for program in programs:
        require_fields(program, {"id", "input", "spec_source", "operations"}, f"program {program.get('id')}")
        if program["input"] != "x" or program["spec_source"] != PROGRAM_SOURCES[program["id"]]:
            fail(f"program source or input drifted for {program['id']}")
        if not isinstance(program["operations"], list) or not program["operations"]:
            fail(f"program operations drifted for {program['id']}")
        program_by_id[program["id"]] = program

    scenarios = contract["scenarios"]
    if not isinstance(scenarios, list) or [scenario.get("id") for scenario in scenarios] != SCENARIO_IDS:
        fail("scenario coverage or order drifted")
    for scenario in scenarios:
        require_fields(scenario, {"id", "program_id", "sink", "expected"}, f"scenario {scenario.get('id')}")
        if scenario["program_id"] not in program_by_id:
            fail(f"scenario {scenario['id']} references an unknown program")
        actual = evaluate_program(program_by_id[scenario["program_id"]], scenario["sink"])
        if actual != scenario["expected"]:
            fail(f"scenario result drifted for {scenario['id']}: {actual!r}")

    if contract["projections"] != PROJECTIONS:
        fail("native/generated/CLI projection drifted")
    if contract["recurring_gate"] != RECURRING_GATE:
        fail("recurring gate topology drifted")
    if contract["public_contract"] != PUBLIC_CONTRACT:
        fail("public diagnostic-output contract drifted")

    gate_path = ROOT / RECURRING_GATE["driver"]
    if not gate_path.is_file():
        fail("recurring gate driver is missing")
    gate_text = gate_path.read_text(encoding="utf-8")
    for consumer in RECURRING_GATE["consumers"]:
        test_path = consumer["test_path"]
        if not (ROOT / test_path).is_file():
            fail(f"recurring gate consumer is missing: {test_path}")
        if GATE_CONSUMER_MARKERS[consumer["runtime"]] not in gate_text:
            fail(f"recurring gate driver omits consumer: {consumer['runtime']}")
    for support_path in RECURRING_GATE["support_checks"]:
        if not (ROOT / support_path).is_file() or support_path not in gate_text:
            fail(f"recurring gate omits support check: {support_path}")

    primary = RECURRING_GATE["primary_cli"]
    if primary["matrix_driver"] not in gate_text or primary["case_id"] not in gate_text:
        fail("recurring gate omits the exact primary projection")
    cli_manifest = json.loads(CLI_MANIFEST_PATH.read_text(encoding="utf-8"))
    cli_cases = [case for case in cli_manifest.get("cases", []) if case.get("id") == primary["case_id"]]
    if len(cli_cases) != 1:
        fail("quiet primary projection case coverage drifted")
    quiet_case = cli_cases[0]
    if quiet_case.get("expect") != {
        "exit": 0,
        "stdout": {"text": '"visible"\n'},
        "stderr": {"text": ""},
        "files": [],
    }:
        fail("quiet primary projection bytes or status drifted")

    local_ci = RECURRING_GATE["local_ci"]
    local_ci_path = ROOT / local_ci["driver"]
    local_ci_text = local_ci_path.read_text(encoding="utf-8")
    if RECURRING_GATE["driver"] not in local_ci_text or local_ci["switch"] not in local_ci_text:
        fail("recurring gate local-CI registration drifted")

    for document in PUBLIC_CONTRACT["documents"]:
        public_path = ROOT / document["path"]
        if not public_path.is_file():
            fail(f"public diagnostic-output document is missing: {document['path']}")
        public_text = public_path.read_text(encoding="utf-8")
        for marker in document["required_markers"]:
            if marker not in public_text:
                fail(f"public diagnostic-output marker is missing from {document['path']}: {marker}")
    for forbidden in PUBLIC_CONTRACT["forbidden_current_claims"]:
        public_text = (ROOT / forbidden["path"]).read_text(encoding="utf-8")
        if forbidden["text"] in public_text:
            fail(f"stale public diagnostic-output claim remains in {forbidden['path']}: {forbidden['text']}")
    rollout = contract["backend_rollout"]
    if not isinstance(rollout, list) or len(rollout) != len(ROLLOUT):
        fail("backend rollout coverage drifted")
    task_text = TASK_PATH.read_text(encoding="utf-8")
    for row, (leg, status, owner) in zip(rollout, ROLLOUT):
        if row != {"leg": leg, "status": status, "owner": owner}:
            fail(f"backend rollout drifted for {leg}")
        if f"ID: `{owner}`" not in task_text:
            fail(f"backend rollout owner is absent from the task tree: {owner}")


def assert_mutation_rejected(contract: dict[str, Any], mutate: Any, label: str) -> None:
    changed = copy.deepcopy(contract)
    mutate(changed)
    try:
        validate_contract(changed)
    except ContractError:
        return
    fail(f"checker accepted drift mutation: {label}")


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(contract)
    mutations = [
        (lambda value: value["helpers"][0]["arity"].__setitem__("minimum", 0), "print arity"),
        (lambda value: value["event_schema"]["fields"].pop(), "event schema"),
        (lambda value: value["scalar_render_cases"][7].__setitem__("expected", "null"), "null rendering"),
        (lambda value: value["programs"][0].__setitem__("spec_source", "Top:: /x/"), "fixture source"),
        (lambda value: value["scenarios"].pop(), "scenario coverage"),
        (
            lambda value: value["scenarios"][0]["expected"]["events"][0].__setitem__("message", "drift"),
            "event text",
        ),
        (
            lambda value: value["scenarios"][0]["expected"]["events"].reverse(),
            "event order",
        ),
        (lambda value: value["scenarios"][1]["expected"]["events"].append({}), "quiet default"),
        (lambda value: value["scenarios"][3]["sink"].__setitem__("invocation", 5), "item sink failure"),
        (lambda value: value["backend_rollout"][0].__setitem__("status", "pending"), "Perl admission regression"),
        (lambda value: value["backend_rollout"][1].__setitem__("status", "pending"), "Rust admission regression"),
        (lambda value: value["recurring_gate"]["consumers"].pop(), "recurring backend coverage"),
        (
            lambda value: value["recurring_gate"]["consumers"][0]["roles"].pop(),
            "generated consumer coverage",
        ),
        (
            lambda value: value["recurring_gate"]["primary_cli"].__setitem__("case_id", "wrong_case"),
            "quiet primary projection",
        ),
        (lambda value: value["recurring_gate"]["support_checks"].pop(), "supporting proof coverage"),
        (
            lambda value: value["backend_rollout"][6].__setitem__("status", "pending"),
            "recurring gate admission regression",
        ),
        (lambda value: value["public_contract"]["documents"].pop(), "public document coverage"),
        (
            lambda value: value["public_contract"]["documents"][0]["required_markers"].pop(),
            "public marker coverage",
        ),
        (
            lambda value: value["public_contract"]["forbidden_current_claims"].pop(),
            "stale public claim coverage",
        ),
        (
            lambda value: value["backend_rollout"][7].__setitem__("status", "pending"),
            "public no-drift admission regression",
        ),
    ]
    for mutate, label in mutations:
        assert_mutation_rejected(contract, mutate, label)
    pending_count = sum(row["status"] == "pending" for row in contract["backend_rollout"])
    complete_count = sum(row["status"] == "complete" for row in contract["backend_rollout"])
    print(
        "diagnostic output contract: "
        f"{len(contract['helpers'])} helpers, {len(contract['scalar_render_cases'])} render cases, "
        f"{len(contract['scenarios'])} scenarios, {complete_count} complete / {pending_count} pending legs, "
        f"{len(mutations)} drift mutations"
    )


if __name__ == "__main__":
    main()

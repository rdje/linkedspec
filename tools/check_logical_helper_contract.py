#!/usr/bin/env python3
"""Validate the neutral logical-helper contract, fixtures, rollout, and drift mutations."""

from __future__ import annotations

import copy
import json
import math
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "logical_helper_contract.json"
TASK_PATH = ROOT / "docs" / "tasks" / "FUTURE-PARITY-BACKLOG.00-08.md"
CLI_MANIFEST_PATH = ROOT / "cli_conformance" / "manifest.json"
CONTRACT_ID = "linkedspec-logical-helper-v1"
TOP_LEVEL_FIELDS = [
    "format",
    "contract_id",
    "policy",
    "error_schema",
    "helpers",
    "truthiness_cases",
    "helper_cases",
    "effect_scenarios",
    "receiver_scenarios",
    "lazy_control_scenarios",
    "invalid_arity_cases",
    "fixtures",
    "projections",
    "recurring_gate",
    "public_contract",
    "rollout",
]
POLICY = {
    "arity_validation": "validate positional arity before evaluating any argument",
    "evaluation": "evaluate every valid call argument exactly once from left to right before boolean composition",
    "result_kind": "real boolean for every valid helper call",
    "truthiness": "typed null, boolean, finite-number, string, array, harray, and codeblock policy; never raw host truth",
    "string_truth": "false exactly when empty; nonempty 0, false, whitespace, and Unicode strings are true",
    "aggregate_truth": "false exactly when empty; true when at least one item or entry exists",
    "codeblock_truth": "true without invoking the codeblock",
    "codeblock_fixture_boundary": "codeblock truth is model and backend-unit evidence until FUTURE-PARITY-BACKLOG.11 admits portable explicit literals; this contract does not activate that syntax",
    "receiver": "a compatible continuation receives the boolean helper result",
    "lazy_controls": "if, switch, and while share typed truthiness but retain selected-branch or selected-body laziness",
}
HELPERS = [
    {
        "name": "and",
        "arity": {"minimum": 1, "maximum": None, "expected_text": "at least 1 positional argument"},
        "composition": "true exactly when every value is truthful",
        "return_kind": "boolean",
    },
    {
        "name": "or",
        "arity": {"minimum": 1, "maximum": None, "expected_text": "at least 1 positional argument"},
        "composition": "true exactly when at least one value is truthful",
        "return_kind": "boolean",
    },
    {
        "name": "not",
        "arity": {"minimum": 1, "maximum": 1, "expected_text": "exactly 1 positional argument"},
        "composition": "negate the single value's truthiness",
        "return_kind": "boolean",
    },
]
TRUTH_IDS = [
    "null",
    "boolean_false",
    "boolean_true",
    "number_zero",
    "number_negative_zero",
    "number_negative",
    "number_fraction",
    "string_empty",
    "string_zero",
    "string_false",
    "string_whitespace",
    "string_unicode",
    "array_empty",
    "array_nonempty_null",
    "harray_empty",
    "harray_nonempty_null",
    "codeblock",
]
HELPER_CASE_IDS = [
    "and_one_true",
    "and_one_false",
    "and_many_true",
    "and_many_false",
    "or_one_false",
    "or_one_true",
    "or_many_false",
    "or_many_true",
    "not_false",
    "not_true",
]
EFFECT_IDS = ["and_decisive_false_is_eager", "or_decisive_true_is_eager", "not_single_argument_once"]
RECEIVER_IDS = ["receiver_true", "receiver_false"]
LAZY_IDS = ["if_false_selects_else", "if_true_selects_then"]
INVALID_IDS = ["and_zero", "or_zero", "not_zero", "not_many"]
RECURRING_GATE = {
    "driver": "tools/check_logical_helper_five_backend.sh",
    "consumer_schema": {
        "fields": ["backend", "runtime", "test_path", "roles"],
        "role_policy": "ordered backend-specific roles; every listed role is required",
    },
    "consumers": [
        {
            "backend": "perl",
            "runtime": "perl",
            "test_path": "t/logical_helper_perl_contract.t",
            "roles": [
                "native",
                "primary",
                "generated_execute",
                "generated_execute_with_trace",
                "generated_get",
            ],
        },
        {
            "backend": "rust",
            "runtime": "rust",
            "test_path": "rust/linkedspec-runtime/tests/logical_helper_contract.rs",
            "roles": [
                "native",
                "serialized",
                "generated_v2_direct",
                "generated_v2_traced",
                "generated_compatibility_direct",
                "generated_compatibility_traced",
                "emitted_execute",
                "emitted_execute_with_trace",
                "emitted_parse",
                "emitted_parse_with_trace",
            ],
        },
        {
            "backend": "dart",
            "runtime": "dart",
            "test_path": "dart/test/logical_helper_contract_test.dart",
            "roles": [
                "native",
                "reconstructed",
                "primary",
                "generated_plan_direct",
                "generated_plan_traced",
                "emitted_direct",
                "emitted_traced",
            ],
        },
        {
            "backend": "julia",
            "runtime": "julia",
            "test_path": "julia/test/logical_helper_contract_test.jl",
            "roles": [
                "native",
                "reconstructed",
                "primary",
                "generated_plan_direct",
                "generated_plan_traced",
                "emitted_direct",
                "emitted_traced",
            ],
        },
        {
            "backend": "lua",
            "runtime": "puc_lua",
            "test_path": "lua/test/logical_helper_contract_test.lua",
            "roles": [
                "native",
                "reconstructed",
                "primary",
                "generated_plan_direct",
                "generated_plan_traced",
                "emitted_direct",
                "emitted_traced",
            ],
        },
        {
            "backend": "lua",
            "runtime": "luajit",
            "test_path": "lua/test/logical_helper_contract_test.lua",
            "roles": [
                "native",
                "reconstructed",
                "primary",
                "generated_plan_direct",
                "generated_plan_traced",
                "emitted_direct",
                "emitted_traced",
            ],
        },
    ],
    "primary_cli": {
        "matrix_driver": "tools/run_primary_cli_matrix.sh",
        "case_id": "success_logical_helpers_eager",
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
        "switch": "LINKEDSPEC_RUN_LOGICAL_MATRIX",
    },
}
PUBLIC_CONTRACT = {
    "documents": [
        {
            "path": "USER_GUIDE_ActionIR_ControlFlow.md",
            "required_markers": ["ADR `0043`", "`helper_arity_mismatch`", "all five backends"],
        },
        {
            "path": "USER_GUIDE_ActionIR_EmittedPerlReference.md",
            "required_markers": [
                "`LinkedSpec::RuntimeLogical::evaluate`",
                "never use host `&&` / `||`",
                "generated `ExecuteWithTrace`",
            ],
        },
        {
            "path": "rust/README.md",
            "required_markers": [
                "## Logical Helpers",
                "`RuntimeValue::as_bool`",
                "`execute_generated_parser_v2`",
                "`success_logical_helpers_eager`",
            ],
        },
        {
            "path": "dart/README.md",
            "required_markers": [
                "ADR `0043`",
                "`runtimeLogicalTruth`",
                "standalone-emitted direct/traced roles",
                "tools/check_logical_helper_five_backend.sh",
            ],
        },
        {
            "path": "julia/README.md",
            "required_markers": [
                "## Native and Generated Logical Helpers",
                "`_runtime_truthy`",
                "`LinkedSpecGeneratedParser.execute_with_trace`",
                "tools/check_logical_helper_five_backend.sh",
            ],
        },
        {
            "path": "lua/README.md",
            "required_markers": [
                "## Native and Generated logical helpers",
                "`runtime_truthy`",
                "`generated.execute_with_trace`",
                "tools/check_logical_helper_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/helper-contract-catalog.md",
            "required_markers": [
                "ADR `0043`",
                "8 complete / 0 pending",
                "tools/check_logical_helper_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md",
            "required_markers": [
                "`linkedspec-logical-helper-v1`",
                "8 complete / 0 pending",
                "tools/check_logical_helper_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/dsl/action-model-and-helper-surface.md",
            "required_markers": ["### Logical value helpers", "`helper_arity_mismatch`", "all five backends"],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "required_markers": ["`linkedspec-logical-helper-v1`", "8 complete / 0 pending"],
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "required_markers": [
                "`success_logical_helpers_eager`",
                "8 complete / 0 pending",
                "parent `.5.2` is closed",
            ],
        },
        {
            "path": "capability_conformance/README.md",
            "required_markers": ["26 semantic/topology/public drift mutations", "8 complete / 0 pending"],
        },
        {
            "path": "cli_conformance/README.md",
            "required_markers": ["success_logical_helpers_eager", "5x2x66 matrix"],
        },
        {
            "path": "ROADMAP.md",
            "required_markers": ["ledger is 8 complete / 0 pending", "parent `.5.2` is done"],
        },
        {
            "path": "ROADMAP_V2.md",
            "required_markers": ["ledger is 8 complete / 0 pending", "parent `.5.2` is done"],
        },
        {
            "path": "ARCHITECTURE_STATE.md",
            "required_markers": ["logical public no-drift", "8 complete / 0 pending"],
        },
        {
            "path": "docs/decisions/0067-live-achievement-status-history.md",
            "required_markers": [
                "FUTURE-PARITY-BACKLOG.5.2.9 — close logical-helper public no-drift",
                "8 complete / 0 pending",
            ],
        },
        {
            "path": "docs/TASK_TREE.md",
            "required_markers": ["Logical helper parent `.5.2` is closed at 8/0"],
        },
        {
            "path": "docs/knowledge/logical-helper-neutral-contract.md",
            "required_markers": ["8 complete / 0 pending", "public no-drift"],
        },
    ],
    "forbidden_current_claims": [
        {
            "path": "USER_GUIDE_ActionIR_ControlFlow.md",
            "text": "Perl `.5.2.2` is complete at 1/7 rollout",
        },
        {
            "path": "julia/README.md",
            "text": "recurring and public no-drift admission remain pending",
        },
        {
            "path": "lua/README.md",
            "text": "`.5.2.7-.9` retain cross-backend projection",
        },
        {
            "path": "lua/README.md",
            "text": "generated/primary, recurring-gate, and public\ncloseout remain `.5.2.7-.9`",
        },
        {
            "path": "ROADMAP_V2.md",
            "text": "Perl typed logical rollout `.5.2.2` advances the ledger to 1/7 before",
        },
        {
            "path": "ROADMAP.md",
            "text": "and logical truthiness/arity/lowering `.5.2` is next",
        },
        {
            "path": "capability_conformance/README.md",
            "text": "seven complete / one pending",
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "text": "Rollout is 7 complete / 1 pending",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "text": "ledger is 7 complete / 1 pending",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/helper-contract-catalog.md",
            "text": "Only public no-drift `.5.2.9` remains",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md",
            "text": "Rollout is 7 complete / 1 pending",
        },
        {"path": "ARCHITECTURE_STATE.md", "text": "rollout is 7 complete / 1 pending"},
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "text": "`and`/`or` keyword lowering and five-backend logical truthiness/arity remain separately owned by `.5.2`",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "text": "Neutral/backend/generated/gate/public leaves `.5.2.1-.9` are\ntherefore dependency-ordered before any behavior claim changes.",
        },
    ],
}
GATE_CONSUMER_MARKERS = {
    "perl": "t/logical_helper_perl_contract.t",
    "rust": "--test logical_helper_contract",
    "dart": "test/logical_helper_contract_test.dart",
    "julia": "julia/test/logical_helper_contract_test.jl",
    "puc_lua": "build_lua_native.sh puc",
    "luajit": "build_lua_native.sh luajit",
}
GATE_ROLE_MARKERS = {
    "perl": {
        "native": "run_parser($live)",
        "primary": "run_primary_command",
        "generated_execute": "[Execute =>",
        "generated_execute_with_trace": "[ExecuteWithTrace =>",
        "generated_get": "[Get =>",
    },
    "rust": {
        "native": "Engine::new(compiled.clone())",
        "serialized": "serde_json::from_str(&compiled_json)",
        "generated_v2_direct": "execute_generated_parser_v2(",
        "generated_v2_traced": "execute_generated_parser_with_trace_v2(",
        "generated_compatibility_direct": "execute_generated_parser(&compiled_json",
        "generated_compatibility_traced": "execute_generated_parser_with_trace(",
        "emitted_execute": "::execute(\"x\")",
        "emitted_execute_with_trace": "::execute_with_trace(\"x\"",
        "emitted_parse": "::parse(\"x\")",
        "emitted_parse_with_trace": "::parse_with_trace(\"x\"",
    },
    "dart": {
        "native": "LinkedSpecRuntimeEngine(compiled).parse('x')",
        "reconstructed": "LinkedSpecRuntimeEngine(reconstructed).parse('x')",
        "primary": "runLinkedSpecDartPrimaryCli",
        "generated_plan_direct": "executeGeneratedParserV2(",
        "generated_plan_traced": "executeGeneratedParserWithTraceV2(",
        "emitted_direct": "values.execute('x')",
        "emitted_traced": "values.executeWithTrace('x'",
    },
    "julia": {
        "native": "runtime_parse(LinkedSpecRuntimeEngine(compiled), \"x\")",
        "reconstructed": "runtime_parse(LinkedSpecRuntimeEngine(reconstructed), \"x\")",
        "primary": "_logical_helper_primary",
        "generated_plan_direct": "execute_generated_parser_v2(",
        "generated_plan_traced": "execute_generated_parser_with_trace_v2(",
        "emitted_direct": "LinkedSpecGeneratedParser.execute(\"x\")",
        "emitted_traced": "LinkedSpecGeneratedParser.execute_with_trace(",
    },
    "puc_lua": {
        "native": "execute_native(compiled)",
        "reconstructed": "execute_native(reconstructed)",
        "primary": "primary(fixture.spec_source)",
        "generated_plan_direct": "execute_generated(compiled, fixture_id)",
        "generated_plan_traced": "execute_generated_with_trace(compiled, fixture_id)",
        "emitted_direct": "emitted.execute(\"x\")",
        "emitted_traced": "emitted.execute_with_trace(\"x\"",
    },
    "luajit": {
        "native": "execute_native(compiled)",
        "reconstructed": "execute_native(reconstructed)",
        "primary": "primary(fixture.spec_source)",
        "generated_plan_direct": "execute_generated(compiled, fixture_id)",
        "generated_plan_traced": "execute_generated_with_trace(compiled, fixture_id)",
        "emitted_direct": "emitted.execute(\"x\")",
        "emitted_traced": "emitted.execute_with_trace(\"x\"",
    },
}
ROLLOUT = [
    ("perl_native", "complete", "FUTURE-PARITY-BACKLOG.5.2.2"),
    ("rust_native", "complete", "FUTURE-PARITY-BACKLOG.5.2.3"),
    ("dart_native", "complete", "FUTURE-PARITY-BACKLOG.5.2.4"),
    ("julia_native", "complete", "FUTURE-PARITY-BACKLOG.5.2.5"),
    ("lua_native", "complete", "FUTURE-PARITY-BACKLOG.5.2.6"),
    ("generated_and_primary_cli", "complete", "FUTURE-PARITY-BACKLOG.5.2.7"),
    ("recurring_five_backend_gate", "complete", "FUTURE-PARITY-BACKLOG.5.2.8"),
    ("public_no_drift", "complete", "FUTURE-PARITY-BACKLOG.5.2.9"),
]
ID = re.compile(r"[a-z][a-z0-9_]*\Z")


class ContractError(ValueError):
    """A deterministic neutral-contract validation failure."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def require_fields(value: Any, fields: set[str], context: str) -> dict[str, Any]:
    require(isinstance(value, dict), f"{context} must be an object")
    require(set(value) == fields, f"{context} fields drifted")
    return value


def typed_truth(value: Any, context: str = "value") -> bool:
    require(isinstance(value, dict), f"{context} must be a typed value object")
    kind = value.get("kind")
    if kind == "null":
        require_fields(value, {"kind"}, context)
        return False
    if kind == "boolean":
        require_fields(value, {"kind", "value"}, context)
        require(isinstance(value["value"], bool), f"{context} boolean payload is invalid")
        return value["value"]
    if kind == "number":
        require_fields(value, {"kind", "value"}, context)
        number = value["value"]
        require(
            not isinstance(number, bool) and isinstance(number, (int, float)) and math.isfinite(number),
            f"{context} number payload is invalid",
        )
        return number != 0
    if kind == "string":
        require_fields(value, {"kind", "value"}, context)
        require(isinstance(value["value"], str), f"{context} string payload is invalid")
        return value["value"] != ""
    if kind == "array":
        require_fields(value, {"kind", "items"}, context)
        require(isinstance(value["items"], list), f"{context} array payload is invalid")
        for index, item in enumerate(value["items"]):
            typed_truth(item, f"{context}.items[{index}]")
        return len(value["items"]) != 0
    if kind == "harray":
        require_fields(value, {"kind", "entries"}, context)
        require(isinstance(value["entries"], dict), f"{context} harray payload is invalid")
        for key, item in value["entries"].items():
            require(isinstance(key, str), f"{context} harray key is invalid")
            typed_truth(item, f"{context}.entries[{key!r}]")
        return len(value["entries"]) != 0
    if kind == "codeblock":
        require_fields(value, {"kind", "id"}, context)
        require(isinstance(value["id"], str) and value["id"], f"{context} codeblock id is invalid")
        return True
    raise ContractError(f"{context} has unknown kind {kind!r}")


def helper_record(name: str) -> dict[str, Any]:
    for helper in HELPERS:
        if helper["name"] == name:
            return helper
    raise ContractError(f"unknown logical helper {name!r}")


def arity_valid(name: str, count: int) -> bool:
    arity = helper_record(name)["arity"]
    maximum = arity["maximum"]
    return count >= arity["minimum"] and (maximum is None or count <= maximum)


def evaluate(name: str, args: list[Any], context: str) -> bool:
    require(arity_valid(name, len(args)), f"{context} has invalid arity")
    values = [typed_truth(value, f"{context}.args[{index}]") for index, value in enumerate(args)]
    if name == "and":
        return all(values)
    if name == "or":
        return any(values)
    if name == "not":
        return not values[0]
    raise ContractError(f"{context} has unknown helper {name!r}")


def render_value(value: dict[str, Any]) -> str:
    kind = value["kind"]
    if kind == "null":
        return "undef"
    if kind == "boolean":
        return "true" if value["value"] else "false"
    if kind == "number":
        return json.dumps(value["value"], allow_nan=False)
    if kind == "string":
        return json.dumps(value["value"], ensure_ascii=False)
    if kind == "array":
        return "[" + ", ".join(render_value(item) for item in value["items"]) + "]"
    if kind == "harray":
        if not value["entries"]:
            return "{}"
        return "{ " + ", ".join(
            f"{json.dumps(key, ensure_ascii=False)} : {render_value(item)}"
            for key, item in value["entries"].items()
        ) + " }"
    if kind == "codeblock":
        return "{|| return(true) }"
    raise ContractError(f"cannot render unknown typed value {kind!r}")


def source_renderable(value: dict[str, Any]) -> bool:
    kind = value["kind"]
    if kind == "codeblock":
        return False
    if kind == "array":
        return all(source_renderable(item) for item in value["items"])
    if kind == "harray":
        return all(source_renderable(item) for item in value["entries"].values())
    return True


def render_values_fixture(contract: dict[str, Any]) -> tuple[str, dict[str, bool]]:
    rows: list[str] = []
    expected: dict[str, bool] = {}
    for case in contract["truthiness_cases"]:
        if not source_renderable(case["value"]):
            continue
        key = f"truth_{case['id']}"
        rows.append(f"     {json.dumps(key)} : and({render_value(case['value'])})")
        expected[key] = case["expected"]
    for case in contract["helper_cases"]:
        if not all(source_renderable(value) for value in case["args"]):
            continue
        args = ", ".join(render_value(value) for value in case["args"])
        rows.append(f"     {json.dumps(case['id'])} : {case['helper']}({args})")
        expected[case["id"]] = case["expected"]
    source = "Top::\n /x/\n E {\n   return({\n" + ",\n".join(rows) + "\n   })\n }\n"
    return source, expected


def render_effects_fixture(contract: dict[str, Any]) -> tuple[str, dict[str, Any]]:
    lines = ["Top::", " /x/", " E {", "   seen = []"]
    effects: list[str] = []
    expected: dict[str, Any] = {}
    for scenario in contract["effect_scenarios"]:
        lines.append(f"   {scenario['id']} = {scenario['helper']}(")
        for index, arg in enumerate(scenario["args"]):
            suffix = "," if index + 1 < len(scenario["args"]) else ""
            lines.append(
                f"     {{ push(seen, {json.dumps(arg['effect'])}); return({render_value(arg['value'])}) }}{suffix}"
            )
            effects.append(arg["effect"])
        lines.append("   )")
        expected[scenario["id"]] = scenario["expected"]
    lines.extend(["   return({"])
    for scenario in contract["effect_scenarios"]:
        lines.append(f"     {json.dumps(scenario['id'])} : {scenario['id']},")
    lines.extend(["     \"seen\" : copy(seen)", "   })", " }", ""])
    expected["seen"] = effects
    return "\n".join(lines), expected


def render_receiver_lazy_fixture(contract: dict[str, Any]) -> tuple[str, dict[str, Any]]:
    lines = ["Top::", " /x/", " E {", "   seen = []"]
    expected: dict[str, Any] = {}
    seen: list[str] = []
    for scenario in contract["receiver_scenarios"]:
        args = ", ".join(render_value(value) for value in scenario["args"])
        lines.append(
            f"   {scenario['id']} = {scenario['helper']}({args}).with() {{ return(value) }}"
        )
        expected[scenario["id"]] = scenario["expected"]
    for scenario in contract["lazy_control_scenarios"]:
        lines.extend(
            [
                f"   {scenario['id']} = if(",
                f"     {render_value(scenario['condition'])},",
                f"     {{ push(seen, {json.dumps(scenario['then']['effect'])}); return({str(scenario['then']['result']).lower()}) }},",
                f"     {{ push(seen, {json.dumps(scenario['else']['effect'])}); return({str(scenario['else']['result']).lower()}) }}",
                "   )",
            ]
        )
        expected[scenario["id"]] = scenario["expected"]
        seen.extend(scenario["expected_effects"])
    lines.append("   return({")
    for scenario in contract["receiver_scenarios"] + contract["lazy_control_scenarios"]:
        lines.append(f"     {json.dumps(scenario['id'])} : {scenario['id']},")
    lines.extend(["     \"seen\" : copy(seen)", "   })", " }", ""])
    expected["seen"] = seen
    return "\n".join(lines), expected


def render_invalid_source(case: dict[str, Any]) -> str:
    name = case["helper_name"]
    if case["actual_arity"] == 0:
        call = f"{name}()"
    else:
        require(case["id"] == "not_many" and case["actual_arity"] == 2, "unsupported invalid fixture")
        call = 'not({ fail("first must not run") }, { fail("second must not run") })'
    return f"Top::\n /x/\n E {{ return({call}) }}\n"


def validate_contract(contract: dict[str, Any]) -> None:
    require(isinstance(contract, dict), "contract root must be an object")
    require(list(contract) == TOP_LEVEL_FIELDS, "top-level fields or order drifted")
    require(contract["format"] == 1 and contract["contract_id"] == CONTRACT_ID, "format/id drifted")
    require(contract["policy"] == POLICY, "policy drifted")
    require(
        contract["error_schema"]
        == {
            "code": "helper_arity_mismatch",
            "fields": ["code", "helper_name", "actual_arity", "expected_arity"],
            "evaluation": "no argument is evaluated",
        },
        "error schema drifted",
    )
    require(contract["helpers"] == HELPERS, "helper signature/composition drifted")

    truth_cases = contract["truthiness_cases"]
    require(isinstance(truth_cases, list), "truthiness_cases must be an array")
    require([case.get("id") for case in truth_cases] == TRUTH_IDS, "truthiness case topology drifted")
    for index, case in enumerate(truth_cases):
        require_fields(case, {"id", "value", "expected"}, f"truthiness case {index}")
        require(isinstance(case["expected"], bool), f"truthiness case {case['id']} expected is not boolean")
        require(typed_truth(case["value"], f"truthiness case {case['id']}") == case["expected"], f"truthiness case {case['id']} disagrees with typed policy")

    helper_cases = contract["helper_cases"]
    require([case.get("id") for case in helper_cases] == HELPER_CASE_IDS, "helper case topology drifted")
    for index, case in enumerate(helper_cases):
        require_fields(case, {"id", "helper", "args", "expected"}, f"helper case {index}")
        require(ID.fullmatch(case["id"]) is not None, f"helper case {index} id is invalid")
        require(isinstance(case["args"], list) and isinstance(case["expected"], bool), f"helper case {case['id']} payload is invalid")
        require(evaluate(case["helper"], case["args"], f"helper case {case['id']}") == case["expected"], f"helper case {case['id']} evaluator mismatch")

    effects = contract["effect_scenarios"]
    require([case.get("id") for case in effects] == EFFECT_IDS, "effect scenario topology drifted")
    for index, scenario in enumerate(effects):
        require_fields(scenario, {"id", "helper", "args", "expected_effects", "expected"}, f"effect scenario {index}")
        require(isinstance(scenario["args"], list) and arity_valid(scenario["helper"], len(scenario["args"])), f"effect scenario {scenario['id']} arity is invalid")
        observed_effects: list[str] = []
        values: list[dict[str, Any]] = []
        for arg_index, arg in enumerate(scenario["args"]):
            require_fields(arg, {"effect", "value"}, f"effect scenario {scenario['id']} arg {arg_index}")
            require(isinstance(arg["effect"], str) and arg["effect"], f"effect scenario {scenario['id']} effect is invalid")
            observed_effects.append(arg["effect"])
            values.append(arg["value"])
        require(observed_effects == scenario["expected_effects"], f"effect scenario {scenario['id']} order drifted")
        require(evaluate(scenario["helper"], values, f"effect scenario {scenario['id']}") == scenario["expected"], f"effect scenario {scenario['id']} result drifted")

    receivers = contract["receiver_scenarios"]
    require([case.get("id") for case in receivers] == RECEIVER_IDS, "receiver scenario topology drifted")
    for index, scenario in enumerate(receivers):
        require_fields(scenario, {"id", "helper", "args", "expected"}, f"receiver scenario {index}")
        require(evaluate(scenario["helper"], scenario["args"], f"receiver scenario {scenario['id']}") == scenario["expected"], f"receiver scenario {scenario['id']} result drifted")

    lazy_cases = contract["lazy_control_scenarios"]
    require([case.get("id") for case in lazy_cases] == LAZY_IDS, "lazy scenario topology drifted")
    for index, scenario in enumerate(lazy_cases):
        require_fields(scenario, {"id", "condition", "then", "else", "expected_effects", "expected"}, f"lazy scenario {index}")
        then = require_fields(scenario["then"], {"effect", "result"}, f"lazy scenario {scenario['id']} then")
        otherwise = require_fields(scenario["else"], {"effect", "result"}, f"lazy scenario {scenario['id']} else")
        selected = then if typed_truth(scenario["condition"], f"lazy scenario {scenario['id']} condition") else otherwise
        require(scenario["expected_effects"] == [selected["effect"]], f"lazy scenario {scenario['id']} evaluated an unselected branch")
        require(isinstance(selected["result"], bool) and selected["result"] == scenario["expected"], f"lazy scenario {scenario['id']} result drifted")

    invalid = contract["invalid_arity_cases"]
    require([case.get("id") for case in invalid] == INVALID_IDS, "invalid-arity topology drifted")
    for index, case in enumerate(invalid):
        require_fields(case, {"id", "helper_name", "actual_arity", "expected_arity", "expected_code", "arguments_evaluated"}, f"invalid arity case {index}")
        require(not arity_valid(case["helper_name"], case["actual_arity"]), f"invalid arity case {case['id']} is valid")
        expected_text = helper_record(case["helper_name"])["arity"]["expected_text"]
        require(case["expected_arity"] == expected_text, f"invalid arity case {case['id']} text drifted")
        require(case["expected_code"] == "helper_arity_mismatch" and case["arguments_evaluated"] == 0, f"invalid arity case {case['id']} diagnostic/effects drifted")

    fixtures = require_fields(contract["fixtures"], {"values", "effects", "receiver_and_lazy_control", "invalid_arity"}, "fixtures")
    for fixture_name, renderer in (
        ("values", render_values_fixture),
        ("effects", render_effects_fixture),
        ("receiver_and_lazy_control", render_receiver_lazy_fixture),
    ):
        fixture = require_fields(fixtures[fixture_name], {"spec_source", "expected"}, f"fixture {fixture_name}")
        source, expected = renderer(contract)
        require(fixture["spec_source"] == source, f"fixture {fixture_name} source is not deterministic")
        require(fixture["expected"] == expected and list(fixture["expected"]) == list(expected), f"fixture {fixture_name} expected result drifted")
    invalid_fixtures = fixtures["invalid_arity"]
    require(isinstance(invalid_fixtures, list) and [row.get("id") for row in invalid_fixtures] == INVALID_IDS, "invalid fixture topology drifted")
    for case, fixture in zip(invalid, invalid_fixtures, strict=True):
        require_fields(fixture, {"id", "spec_source"}, f"invalid fixture {case['id']}")
        require(fixture["spec_source"] == render_invalid_source(case), f"invalid fixture {case['id']} source drifted")

    require(
        contract["projections"]
        == {
            "native": "typed helper calls and lazy controls share one truthiness seam while retaining distinct evaluation semantics",
            "generated": "every available generated execution role preserves values, effects, receiver behavior, and typed arity failures",
            "primary_cli": "one shared case returns the same canonical JSON and failure projection under all five commands and both option environments",
            "trace": "logical helper evaluation does not invent a backend-specific trace contract",
        },
        "projection obligations drifted",
    )
    require(contract["recurring_gate"] == RECURRING_GATE, "recurring gate topology drifted")

    gate_path = ROOT / RECURRING_GATE["driver"]
    require(gate_path.is_file(), "recurring gate driver is missing")
    gate_text = gate_path.read_text(encoding="utf-8")
    for consumer in RECURRING_GATE["consumers"]:
        test_path = ROOT / consumer["test_path"]
        require(test_path.is_file(), f"recurring gate consumer is missing: {consumer['test_path']}")
        require(
            GATE_CONSUMER_MARKERS[consumer["runtime"]] in gate_text,
            f"recurring gate driver omits consumer: {consumer['runtime']}",
        )
        test_text = test_path.read_text(encoding="utf-8")
        for role in consumer["roles"]:
            require(
                GATE_ROLE_MARKERS[consumer["runtime"]][role] in test_text,
                f"recurring gate consumer omits role: {consumer['runtime']} {role}",
            )
    for support_path in RECURRING_GATE["support_checks"]:
        require(
            (ROOT / support_path).is_file() and support_path in gate_text,
            f"recurring gate omits support check: {support_path}",
        )

    primary = RECURRING_GATE["primary_cli"]
    require(
        primary["matrix_driver"] in gate_text and primary["case_id"] in gate_text,
        "recurring gate omits the exact primary projection",
    )
    cli_manifest = json.loads(CLI_MANIFEST_PATH.read_text(encoding="utf-8"))
    cli_cases = [case for case in cli_manifest.get("cases", []) if case.get("id") == primary["case_id"]]
    require(len(cli_cases) == 1, "logical primary projection case coverage drifted")
    require(
        cli_cases[0].get("expect")
        == {
            "exit": 0,
            "stdout": {
                "text": '{"and_decisive_false_is_eager":false,"not_single_argument_once":true,'
                '"or_decisive_true_is_eager":true,"seen":["and-first","and-second",'
                '"or-first","or-second","not-first"]}\n'
            },
            "stderr": {"text": ""},
            "files": [],
        },
        "logical primary projection bytes or status drifted",
    )

    local_ci = RECURRING_GATE["local_ci"]
    local_ci_text = (ROOT / local_ci["driver"]).read_text(encoding="utf-8")
    require(
        RECURRING_GATE["driver"] in local_ci_text and local_ci["switch"] in local_ci_text,
        "recurring gate local-CI registration drifted",
    )

    require(contract["public_contract"] == PUBLIC_CONTRACT, "public logical-helper contract drifted")
    for document in PUBLIC_CONTRACT["documents"]:
        public_path = ROOT / document["path"]
        require(public_path.is_file(), f"public logical-helper document is missing: {document['path']}")
        public_text = public_path.read_text(encoding="utf-8")
        for marker in document["required_markers"]:
            require(
                marker in public_text,
                f"public logical-helper marker is missing from {document['path']}: {marker}",
            )
    for forbidden in PUBLIC_CONTRACT["forbidden_current_claims"]:
        public_text = (ROOT / forbidden["path"]).read_text(encoding="utf-8")
        require(
            forbidden["text"] not in public_text,
            f"stale public logical-helper claim remains in {forbidden['path']}: {forbidden['text']}",
        )

    rollout = contract["rollout"]
    require(isinstance(rollout, list) and len(rollout) == len(ROLLOUT), "rollout topology drifted")
    task_text = TASK_PATH.read_text(encoding="utf-8")
    for index, (row, (row_id, status, owner)) in enumerate(zip(rollout, ROLLOUT, strict=True)):
        require_fields(row, {"id", "status", "owner"}, f"rollout row {index}")
        require(row == {"id": row_id, "status": status, "owner": owner}, f"rollout row {row_id} drifted or admitted prematurely")
        require(f"ID: `{owner}`" in task_text, f"rollout owner is absent from the task tree: {owner}")


def mutation_smoke(contract: dict[str, Any]) -> int:
    mutations: list[tuple[str, Any]] = [
        ("string-zero truth", lambda data: data["truthiness_cases"][8].__setitem__("expected", False)),
        ("empty-array truth", lambda data: data["truthiness_cases"][12].__setitem__("expected", True)),
        ("short-circuit policy", lambda data: data["policy"].__setitem__("evaluation", "short circuit")),
        ("and empty arity", lambda data: data["helpers"][0]["arity"].__setitem__("minimum", 0)),
        ("not variadic arity", lambda data: data["helpers"][2]["arity"].__setitem__("maximum", None)),
        ("effect omission", lambda data: data["effect_scenarios"][0].__setitem__("expected_effects", ["and-first"])),
        ("arity effect", lambda data: data["invalid_arity_cases"][3].__setitem__("arguments_evaluated", 1)),
        ("diagnostic code", lambda data: data["error_schema"].__setitem__("code", "invalid_arity")),
        ("native admission regression", lambda data: data["rollout"][0].__setitem__("status", "pending")),
        ("generated omission", lambda data: data["projections"].pop("generated")),
        ("duplicate truth case", lambda data: data["truthiness_cases"].append(copy.deepcopy(data["truthiness_cases"][0]))),
        ("fixture source", lambda data: data["fixtures"]["values"].__setitem__("spec_source", data["fixtures"]["values"]["spec_source"] + "\n")),
        ("lazy double effect", lambda data: data["lazy_control_scenarios"][0].__setitem__("expected_effects", ["if-false-then-skipped", "if-false-else"])),
        ("receiver result", lambda data: data["receiver_scenarios"][0].__setitem__("expected", False)),
        ("codeblock syntax scope", lambda data: data["policy"].__setitem__("codeblock_fixture_boundary", "portable source literal")),
        ("recurring backend omission", lambda data: data["recurring_gate"]["consumers"].pop()),
        ("generated role omission", lambda data: data["recurring_gate"]["consumers"][0]["roles"].pop()),
        ("logical primary omission", lambda data: data["recurring_gate"]["primary_cli"].__setitem__("case_id", "wrong_case")),
        ("support-ledger omission", lambda data: data["recurring_gate"]["support_checks"].pop()),
        ("CI registration omission", lambda data: data["recurring_gate"]["local_ci"].__setitem__("switch", "wrong_switch")),
        ("driver omission", lambda data: data["recurring_gate"].__setitem__("driver", "tools/missing.sh")),
        ("recurring admission regression", lambda data: data["rollout"][6].__setitem__("status", "pending")),
        ("public document omission", lambda data: data["public_contract"]["documents"].pop()),
        (
            "public marker omission",
            lambda data: data["public_contract"]["documents"][0]["required_markers"].pop(),
        ),
        (
            "stale public claim omission",
            lambda data: data["public_contract"]["forbidden_current_claims"].pop(),
        ),
        ("public admission regression", lambda data: data["rollout"][7].__setitem__("status", "pending")),
    ]
    for name, mutate in mutations:
        candidate = copy.deepcopy(contract)
        mutate(candidate)
        try:
            validate_contract(candidate)
        except ContractError:
            continue
        raise ContractError(f"mutation was not rejected: {name}")
    return len(mutations)


def main() -> None:
    try:
        contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
        validate_contract(contract)
        mutations = mutation_smoke(contract)
    except (OSError, json.JSONDecodeError, ContractError) as error:
        raise SystemExit(f"logical-helper-contract: {error}") from error
    complete = sum(row["status"] == "complete" for row in contract["rollout"])
    print(
        "logical-helper-contract: OK "
        f"({len(contract['truthiness_cases'])} truthiness; {len(contract['helper_cases'])} helper; "
        f"{len(contract['effect_scenarios'])} effect; {complete} complete / "
        f"{len(contract['rollout']) - complete} pending; "
        f"{len(contract['public_contract']['documents'])} public documents; "
        f"{len(contract['public_contract']['forbidden_current_claims'])} forbidden current claims; "
        f"{mutations} drift mutations)"
    )


if __name__ == "__main__":
    main()

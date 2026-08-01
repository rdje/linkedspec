#!/usr/bin/env python3
"""Validate the neutral callable-codeblock schema, semantics, and fixture."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any, Callable

from check_callable_signature_contract import ContractError, fail, parse_signature_source


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "callable_codeblock_contract.json"
SIGNATURE_PATH = ROOT / "capability_conformance" / "callable_signature_contract.json"
AST_FIELDS = {
    "kind",
    "version",
    "signature",
    "body_source",
    "body_ast",
    "source_text",
    "source_span",
    "body_span",
}
BEHAVIORS = {
    "join_fixed",
    "read_dynamic",
    "mutate_dynamic",
    "restore_parameter",
    "collect_rest",
    "early_return",
    "shadow_static",
}
CALLABLE_ROLES = [
    "neutral_contract",
    "inert_construction",
    "dynamic_caller_context",
    "static_callable_precedence",
    "contextual_final_blocks",
    "portable_failures",
    "native_execution",
    "reconstructed_execution",
    "generated_execution",
    "emitted_execution",
]
RECURRING_TOPOLOGY = {
    "driver": "tools/check_callable_codeblock_four_backend.sh",
    "neutral_checker": {
        "path": "tools/check_callable_codeblock_contract.py",
        "project_data_route": "tools/run_python_project_data.sh",
    },
    "consumers": [
        {
            "backend": "perl",
            "runtime": "perl",
            "test_path": "t/callable_codeblock_literal_contract.t",
            "driver_marker": "t/callable_codeblock_literal_contract.t",
            "project_data_route": "managed_driver",
            "roles": CALLABLE_ROLES.copy(),
        },
        {
            "backend": "rust",
            "runtime": "rust",
            "test_path": "rust/linkedspec-runtime/tests/callable_codeblock_literal_contract.rs",
            "driver_marker": "--test callable_codeblock_literal_contract",
            "project_data_route": "tools/run_cargo_local.sh",
            "roles": CALLABLE_ROLES.copy(),
        },
        {
            "backend": "dart",
            "runtime": "dart",
            "test_path": "dart/test/callable_codeblock_literal_contract_test.dart",
            "driver_marker": "test/callable_codeblock_literal_contract_test.dart",
            "project_data_route": "tools/run_dart_project_data.sh",
            "roles": CALLABLE_ROLES.copy(),
        },
        {
            "backend": "julia",
            "runtime": "julia",
            "test_path": "julia/test/callable_codeblock_literal_contract_test.jl",
            "driver_marker": "julia/test/callable_codeblock_literal_contract_test.jl",
            "project_data_route": "tools/run_julia_project_data.sh",
            "roles": CALLABLE_ROLES.copy(),
        },
    ],
    "local_ci": {
        "driver": "tools/run_ci_local.sh",
        "switch": "LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX",
    },
}
EXPECTED_FUTURE_EXCLUSION = {
    "id": "future.generic_final_codeblock",
    "reason": (
        "ADR 0031 plus ADR 0032 and linkedspec-callable-codeblock-v1 are adopted; Perl, Rust, Dart, and Julia "
        "construction, arbitrary dynamic invocation, contextual final-block normalization, and native/"
        "reconstructed/generated/emitted identity are current. Lua's declared contextual helper/user-function/"
        "receiver forms are current; Lua explicit callable values and general bound-codeblock invocation remain "
        "future under FUTURE-PARITY-BACKLOG.11.8."
    ),
    "owner": "FUTURE-PARITY-BACKLOG.11.8",
}
EXPECTED_PUBLIC_CONTRACT = {
    "documents": [
        {"path": "USER_GUIDE.md", "required_markers": [
            "Perl, Rust, Dart, and Julia support explicit deferred codeblock values",
            "callable-value work stays under `.11.8`",
        ]},
        {"path": "rust/README.md", "required_markers": [
            "### Callable codeblock values and invocation",
            "Rust recognizes exact brace-pipe forms",
            "no Rust closure or captured environment is encoded",
        ]},
        {"path": "dart/README.md", "required_markers": [
            "## Callable codeblock construction and invocation",
            "neutral eight-field `codeblock_literal` record",
            "independently compiled emitted Dart",
        ]},
        {"path": "julia/README.md", "required_markers": [
            "## Callable-Codeblock Values and Dynamic Invocation",
            "Bound-variable `cb(args)` execution is now implemented",
            "No Julia closure, lexical capture",
        ]},
        {"path": "lua/README.md", "required_markers": [
            "explicit callable codeblock values remain future `FUTURE-PARITY-BACKLOG.11.8`",
            "no-drift is complete under `.11.7`",
        ]},
        {"path": "capability_conformance/README.md", "required_markers": [
            "`callable_codeblock_contract.json` defines",
            "23 public documents",
            "Four-backend recurring/public no-drift is complete",
        ]},
        {"path": "ROADMAP.md", "required_markers": [
            "four-backend callable parent `.11.7` is closed",
            "Lua implementation/admission parent `.11.8.0-.4`",
        ]},
        {"path": "ROADMAP_V2.md", "required_markers": [
            "four-backend callable parent `.11.7` is closed",
            "Lua implementation/admission `.11.8.0-.4`",
        ]},
        {"path": "ARCHITECTURE_STATE.md", "required_markers": [
            "callable public no-drift / parent closeout",
            "parent `.11.7` is closed",
        ]},
        {"path": "LIVE_ACHIEVEMENT_STATUS.md", "required_markers": [
            "Four-backend callable public no-drift is signoff-complete",
            "parent `.11.7` is closed",
        ]},
        {"path": "docs/TASK_TREE.md", "required_markers": [
            "Callable-codeblock parent `.11.7` is closed at four current backends",
        ]},
        {"path": "docs/linkedspec-book/src/appendix/backend-handoff.md", "required_markers": [
            "four-backend recurring/public closeout is complete under `.11.7`",
            "Explicit callable codeblock values remain future `FUTURE-PARITY-BACKLOG.11.8`",
        ]},
        {"path": "docs/linkedspec-book/src/appendix/formal-grammar.md", "required_markers": [
            "### Callable-codeblock literal and dynamic call (Perl, Rust, Dart, and Julia)",
            "behavior is therefore not yet universally portable",
        ]},
        {"path": "docs/linkedspec-book/src/architecture/owner-tree.md", "required_markers": [
            "`LinkedSpec::CodeblockRuntime`",
            "`RuntimeContext` owns temporary uniform-binding",
        ]},
        {"path": "docs/linkedspec-book/src/compiler/pipeline-overview.md", "required_markers": [
            "same dynamic codeblock evaluator as explicit",
            "existing Julia dynamic codeblock",
        ]},
        {"path": "docs/linkedspec-book/src/development/local-ci-and-regression.md", "required_markers": [
            "### Callable-codeblock four-backend recurring proof",
            "`LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX=1`",
            "general bound-call parity remains `.11.8`",
        ]},
        {"path": "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md", "required_markers": [
            "Explicit construction and `cb(...)` invocation are current on Perl, Rust, Dart, and Julia",
            "public no-drift are complete under `.11.7`",
        ]},
        {"path": "docs/linkedspec-book/src/overview/project-status.md", "required_markers": [
            "**Callable codeblock design**",
            "Four-backend recurring/public no-drift is complete under `.11.7`",
        ]},
        {"path": "docs/linkedspec-book/src/public-api/descriptor-introspection.md", "required_markers": [
            "Perl, Rust, Dart, Julia, and Lua currently expose this exact record",
            "still-incomplete five-backend callable-codeblock capability",
        ]},
        {"path": "docs/knowledge/callable-codeblock-literal-contract.md", "required_markers": [
            "Perl .11.3, Rust .11.4, Dart .11.5, and Julia .11.6",
            "public no-drift closes parent `.11.7`",
        ]},
        {"path": "docs/knowledge/callable-codeblock-four-backend-recurring-gate.md", "required_markers": [
            "Seventeen mutations",
            "Public no-drift closes parent `.11.7`",
        ]},
        {"path": "docs/knowledge/callable-codeblock-four-backend-public-closeout.md", "required_markers": [
            "Four-backend callable public state is omission-locked",
            "user-facing specification surface",
        ]},
        {"path": "docs/knowledge/lua-explicit-callable-codeblock-gap.md", "required_markers": [
            "Lua's completed contextual surface",
            "`FUTURE-PARITY-BACKLOG.11.8`",
        ]},
    ],
    "forbidden_current_claims": [
        {"path": "USER_GUIDE.md", "text": "cross-backend closeout remain task-tree-owned future work"},
        {"path": "lua/README.md", "text": "four-backend governance closes"},
        {"path": "capability_conformance/README.md", "text": "adopts the future first-class callable-codeblock boundary without claiming"},
        {"path": "ROADMAP.md", "text": "public closeout remains `.11.7.2`"},
        {"path": "ROADMAP_V2.md", "text": "recurring/public governance `.11.7.1-.2`"},
        {"path": "docs/linkedspec-book/src/appendix/backend-handoff.md", "text": "after four-backend closeout"},
        {"path": "docs/linkedspec-book/src/appendix/formal-grammar.md", "text": "routes four-backend recurring/public closeout through `.11.7.1-.2`"},
        {"path": "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md", "text": "public no-drift close under `.11.7.1-.2`"},
        {"path": "docs/linkedspec-book/src/overview/project-status.md", "text": "routes their recurring/public closeout to `.11.7.1-.2`"},
    ],
}


def classify_braces(source: str) -> str:
    if not isinstance(source, str) or not source.startswith("{") or not source.endswith("}"):
        fail("invalid_brace_form", "brace form must be a complete string")
    if source.startswith("{|" ):
        return "codeblock_literal"
    if len(source) > 2 and source[1].isspace() and source[1:].lstrip().startswith("|"):
        fail("invalid_codeblock_opener", "codeblock opener must be exact {| without whitespace")
    inner = source[1:-1].strip()
    if not inner or has_top_level_colon(inner):
        return "harray_literal"
    return "block_value"


def has_top_level_colon(source: str) -> bool:
    depth = 0
    quote: str | None = None
    escaped = False
    for character in source:
        if quote is not None:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == quote:
                quote = None
            continue
        if character in {'"', "'"}:
            quote = character
        elif character in "([{":
            depth += 1
        elif character in ")]}":
            depth -= 1
        elif character == ":" and depth == 0:
            return True
    return False


def parse_final_codeblock_parameter(source: str) -> dict[str, str]:
    if not isinstance(source, str):
        fail("invalid_codeblock_parameter_declaration", "declaration must be text")
    if re.fullmatch(r"\s*:\s*codeblock\s*", source):
        fail("invalid_codeblock_parameter_name", "codeblock parameter needs a name")
    if re.fullmatch(r"\s*[A-Za-z_][A-Za-z0-9_]*\s*:\s*codeblock\s*\([^)]*\)\s*", source):
        fail("codeblock_declaration_has_no_argument_list", "the codeblock value owns its signature")
    if re.fullmatch(r"\s*[A-Za-z_][A-Za-z0-9_]*\s*:\s*codeblock\s*,.*", source):
        fail("codeblock_parameter_must_be_final", "codeblock parameter must be final")
    match = re.fullmatch(r"\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([A-Za-z_][A-Za-z0-9_]*)\s*", source)
    if match is None:
        fail("invalid_codeblock_parameter_declaration", "invalid parameter declaration")
    name, value_kind = match.groups()
    if value_kind != "codeblock":
        fail("unknown_parameter_type", f"unknown parameter type {value_kind}")
    return {"name": name, "value_kind": value_kind}


def parse_literal(source: str) -> dict[str, Any]:
    kind = classify_braces(source)
    if kind != "codeblock_literal":
        fail("not_codeblock_literal", f"brace form classified as {kind}")
    closer = source.find("|", 2)
    if closer < 0:
        fail("missing_codeblock_signature_closer", "missing signature-closing |")
    signature_source = source[2:closer]
    signature = parse_signature_source(signature_source)
    body_start = closer + 1
    body_end = len(source) - 1
    return {
        "kind": "codeblock_literal",
        "version": 1,
        "signature": signature,
        "body_source": source[body_start:body_end],
        "body_ast": None,
        "source_text": source,
        "source_span": [0, len(source)],
        "body_span": [body_start, body_end],
    }


def expected_arity(signature: dict[str, Any]) -> str:
    minimum = signature["min_arity"]
    return f"at least {minimum}" if signature["max_arity"] is None else f"exactly {minimum}"


def bind_arguments(signature: dict[str, Any], arguments: list[dict[str, Any]]) -> dict[str, Any] | dict[str, str | int]:
    keywords = sum(argument.get("kind") == "keyword" for argument in arguments)
    if keywords:
        return {
            "code": "codeblock_keyword_arguments_unsupported",
            "expected": "positional arguments",
            "got": keywords,
        }
    if any(set(argument) != {"kind", "value"} or argument["kind"] != "positional" for argument in arguments):
        fail("invalid_call_case", "positional arguments must contain only kind/value")
    values = [copy.deepcopy(argument["value"]) for argument in arguments]
    minimum = signature["min_arity"]
    maximum = signature["max_arity"]
    if len(values) < minimum or (maximum is not None and len(values) > maximum):
        return {
            "code": "codeblock_arity_mismatch",
            "expected": expected_arity(signature),
            "got": len(values),
        }
    fixed = len(signature["positional_params"])
    bindings = dict(zip(signature["positional_params"], values[:fixed], strict=True))
    if signature["rest_param"] is not None:
        bindings[signature["rest_param"]] = values[fixed:]
    return bindings


def invoke(literal: dict[str, Any], arguments: list[dict[str, Any]], state: dict[str, Any]) -> Any:
    parsed = literal["parsed"]
    bindings = bind_arguments(parsed["signature"], arguments)
    if "code" in bindings:
        return bindings
    saved = {name: copy.deepcopy(state[name]) for name in bindings if name in state}
    absent = {name for name in bindings if name not in state}
    state.update(copy.deepcopy(bindings))
    behavior = literal["behavior"]
    try:
        if behavior == "join_fixed":
            result: Any = str(state["left"]) + str(state["right"])
        elif behavior == "read_dynamic":
            result = copy.deepcopy(state["state"])
        elif behavior == "mutate_dynamic":
            state["state"] = str(state["state"]) + str(state["value"])
            result = state["state"]
        elif behavior == "restore_parameter":
            state["value"] = str(state["value"]) + "!"
            result = state["value"]
        elif behavior == "collect_rest":
            result = {"prefix": copy.deepcopy(state["prefix"]), "items": copy.deepcopy(state["items"])}
        elif behavior == "early_return":
            result = "done"
        elif behavior == "shadow_static":
            result = "shadow"
        else:
            fail("invalid_behavior", f"unknown behavior {behavior}")
    finally:
        for name in absent:
            state.pop(name, None)
        state.update(saved)
    return copy.deepcopy(result)


def execute_call(case: dict[str, Any], literals: dict[str, dict[str, Any]]) -> dict[str, Any]:
    state = copy.deepcopy(case.get("initial_state", {}))
    if case.get("operation") == "construct":
        return state
    literal = literals[case["literal"]]
    if case.get("callee") == "cat":
        values = [argument["value"] for argument in case["arguments"]]
        return {"result": "".join(str(value) for value in values), "state": state}
    calls = case.get("calls")
    if calls is not None:
        results = [invoke(literal, arguments, state) for arguments in calls]
        return {"results": results, "state": state}
    result = invoke(literal, case.get("arguments", []), state)
    if case.get("result_chain") == "items.length":
        result = len(result["items"])
    if case.get("discard_result"):
        result = None
    return {"result": result, "state": state}


def render_fixture(literals: dict[str, dict[str, Any]], fixture: dict[str, Any]) -> str:
    variables = {literal["variable"]: literal["source"] for literal in literals.values()}
    return (
        "Top::\n /x/ -> Done {\n"
        '   state = "initial";\n'
        f'   joiner = {variables["joiner"]};\n'
        f'   reader = {variables["reader"]};\n'
        f'   append_state = {variables["append_state"]};\n'
        f'   decorate = {variables["decorate"]};\n'
        f'   collector = {variables["collector"]};\n'
        f'   stop_early = {variables["stop_early"]};\n'
        "   construction_state = state;\n"
        '   state = "later";\n'
        "   dynamic_read = reader();\n"
        '   state = "";\n'
        '   mutation_first = append_state("a");\n'
        '   mutation_second = append_state("b");\n'
        '   value = "outer";\n'
        '   decorated = decorate("inner");\n'
        "   return({\n"
        '     "construction_is_deferred" : construction_state,\n'
        '     "fixed_exact" : joiner("a", "b"),\n'
        '     "dynamic_read_uses_call_time_state" : dynamic_read,\n'
        '     "nonparameter_mutation_results" : [mutation_first, mutation_second],\n'
        '     "nonparameter_mutation_state" : state,\n'
        '     "parameter_binding_result" : decorated,\n'
        '     "parameter_binding_restored" : value,\n'
        '     "rest_empty" : collector("p"),\n'
        '     "rest_mixed" : collector("p", 1, [2], { "k" : 3 }, false, undef),\n'
        '     "rest_result_receiver_chain" : collector("p", "a", "b")["items"].length(),\n'
        '     "block_local_return" : stop_early()\n'
        "   })\n }\n\nDone::\n /x/\n"
    )


def fixture_expected(literals: dict[str, dict[str, Any]]) -> dict[str, Any]:
    state = {"state": "initial"}
    construction = state["state"]
    state["state"] = "later"
    dynamic = invoke(literals["read_dynamic"], [], state)
    state["state"] = ""
    first = invoke(literals["mutate_dynamic"], [{"kind": "positional", "value": "a"}], state)
    second = invoke(literals["mutate_dynamic"], [{"kind": "positional", "value": "b"}], state)
    state["value"] = "outer"
    decorated = invoke(literals["restore_parameter"], [{"kind": "positional", "value": "inner"}], state)
    positional = lambda value: {"kind": "positional", "value": value}
    return {
        "construction_is_deferred": construction,
        "fixed_exact": invoke(literals["join_fixed"], [positional("a"), positional("b")], state),
        "dynamic_read_uses_call_time_state": dynamic,
        "nonparameter_mutation_results": [first, second],
        "nonparameter_mutation_state": state["state"],
        "parameter_binding_result": decorated,
        "parameter_binding_restored": state["value"],
        "rest_empty": invoke(literals["collect_rest"], [positional("p")], state),
        "rest_mixed": invoke(literals["collect_rest"], [positional(value) for value in ["p", 1, [2], {"k": 3}, False, None]], state),
        "rest_result_receiver_chain": len(invoke(literals["collect_rest"], [positional("p"), positional("a"), positional("b")], state)["items"]),
        "block_local_return": invoke(literals["early_return"], [], state),
    }


def require(condition: bool, code: str, detail: str) -> None:
    if not condition:
        fail(code, detail)


def validate_driver_text(text: str, topology: dict[str, Any]) -> None:
    driver = topology["driver"]
    require(
        text.count("tools/project_data_env.sh") == 1
        and text.count("linkedspec_project_data_enter_run") == 1
        and text.count(driver) == 1,
        "recurring_driver_drift",
        "recurring driver must enter one repository-rooted managed run",
    )
    ordered_markers = [topology["neutral_checker"]["path"]]
    ordered_markers.extend(consumer["driver_marker"] for consumer in topology["consumers"])
    positions: list[int] = []
    for marker in ordered_markers:
        require(
            text.count(marker) == 1,
            "recurring_consumer_drift",
            f"recurring driver omits or duplicates {marker}",
        )
        positions.append(text.index(marker))
    require(
        positions == sorted(positions),
        "recurring_order_drift",
        "neutral, Perl, Rust, Dart, and Julia consumers must stay ordered",
    )
    expected_routes = [
        topology["neutral_checker"]["project_data_route"],
        *[
            consumer["project_data_route"]
            for consumer in topology["consumers"]
            if consumer["project_data_route"] != "managed_driver"
        ],
    ]
    for route in expected_routes:
        require(
            text.count(route) == 1,
            "project_data_route_drift",
            f"recurring driver omits or duplicates project-data route {route}",
        )
    require(
        text.count("PERL5LIB= prove -Iperl") == 1,
        "project_data_route_drift",
        "Perl consumer must execute inside the managed driver with an empty ambient PERL5LIB",
    )
    forbidden = ["run_lua", "lua/test", "LuaJIT", "puc_lua", "five_backend"]
    require(
        not any(marker in text for marker in forbidden),
        "premature_lua_admission",
        "four-backend recurring driver must not admit Lua or a five-backend role",
    )


def validate_canonical_text(text: str, topology: dict[str, Any]) -> None:
    driver = topology["driver"]
    switch = topology["local_ci"]["switch"]
    execution = f'bash "$REPO_ROOT/{driver}"'
    branch = f'if [[ "${{{switch}:-0}}" == "1" ]]; then'
    require(
        text.count(execution) == 1,
        "canonical_registration_drift",
        "canonical CI must execute the recurring callable driver exactly once",
    )
    require(
        text.count(branch) == 1,
        "canonical_registration_drift",
        "canonical CI must expose exactly one callable matrix switch branch",
    )
    require(
        f"require_tracked_file {driver}" in text,
        "canonical_registration_drift",
        "canonical CI must require the recurring callable driver as tracked input",
    )


def validate_recurring_topology(topology: dict[str, Any], *, check_filesystem: bool) -> None:
    require(
        topology == RECURRING_TOPOLOGY,
        "recurring_topology_drift",
        "four-backend recurring topology or roles drifted",
    )
    consumers = topology["consumers"]
    require(
        [(row["backend"], row["runtime"]) for row in consumers]
        == [("perl", "perl"), ("rust", "rust"), ("dart", "dart"), ("julia", "julia")],
        "recurring_topology_drift",
        "recurring topology must contain exactly the four admitted backends in order",
    )
    if not check_filesystem:
        return
    for path in [topology["neutral_checker"]["path"], *[row["test_path"] for row in consumers]]:
        require((ROOT / path).is_file(), "recurring_path_drift", f"recurring input is missing: {path}")
    driver_path = ROOT / topology["driver"]
    require(driver_path.is_file(), "recurring_path_drift", "recurring callable driver is missing")
    require(
        bool(driver_path.stat().st_mode & 0o111),
        "recurring_path_drift",
        "recurring callable driver is not executable",
    )
    validate_driver_text(driver_path.read_text(encoding="utf-8"), topology)
    ci_path = ROOT / topology["local_ci"]["driver"]
    require(ci_path.is_file(), "canonical_registration_drift", "canonical CI driver is missing")
    validate_canonical_text(ci_path.read_text(encoding="utf-8"), topology)


def validate_future_exclusion(record: dict[str, Any]) -> None:
    require(
        record == EXPECTED_FUTURE_EXCLUSION,
        "callable_status_drift",
        "generic final-codeblock exclusion must name only the measured Lua gap and .11.8 owner",
    )


def validate_public_contract(public: dict[str, Any], *, check_filesystem: bool) -> None:
    require(
        public == EXPECTED_PUBLIC_CONTRACT,
        "callable_public_contract_drift",
        "callable public document inventory or stale-claim denylist drifted",
    )
    if not check_filesystem:
        return
    for document in public["documents"]:
        path = ROOT / document["path"]
        require(
            path.is_file(),
            "callable_public_document_missing",
            f"callable public document is missing: {document['path']}",
        )
        text = path.read_text(encoding="utf-8")
        for marker in document["required_markers"]:
            require(
                marker in text,
                "callable_public_marker_missing",
                f"callable public marker is missing from {document['path']}: {marker}",
            )
    for forbidden in public["forbidden_current_claims"]:
        text = (ROOT / forbidden["path"]).read_text(encoding="utf-8")
        require(
            forbidden["text"] not in text,
            "callable_stale_public_claim",
            f"stale callable claim remains in {forbidden['path']}: {forbidden['text']}",
        )


def expect_mutation_failure(name: str, check: Callable[[], None]) -> None:
    try:
        check()
    except ContractError:
        return
    fail("mutation_survived", name)


def governance_mutation_checks(
    driver_text: str,
    ci_text: str,
    future_record: dict[str, Any],
    public_contract: dict[str, Any],
) -> int:
    mutations: list[tuple[str, Callable[[], None]]] = []

    def topology_mutation(name: str, mutate: Callable[[dict[str, Any]], None]) -> None:
        def check() -> None:
            candidate = copy.deepcopy(RECURRING_TOPOLOGY)
            mutate(candidate)
            validate_recurring_topology(candidate, check_filesystem=False)

        mutations.append((name, check))

    topology_mutation("backend_omission", lambda value: value["consumers"].pop())
    topology_mutation("backend_reordering", lambda value: value["consumers"].reverse())
    topology_mutation("role_omission", lambda value: value["consumers"][1]["roles"].pop())
    topology_mutation("stale_consumer_path", lambda value: value["consumers"][2].__setitem__("test_path", "missing"))
    topology_mutation("project_data_bypass", lambda value: value["consumers"][1].__setitem__("project_data_route", "cargo"))
    topology_mutation("premature_lua_consumer", lambda value: value["consumers"].append({"backend": "lua"}))
    topology_mutation("canonical_switch_drift", lambda value: value["local_ci"].__setitem__("switch", "wrong"))

    rust_marker = RECURRING_TOPOLOGY["consumers"][1]["driver_marker"]
    dart_marker = RECURRING_TOPOLOGY["consumers"][2]["driver_marker"]
    reordered_driver = driver_text.replace(rust_marker, "__RUST__", 1).replace(
        dart_marker, rust_marker, 1
    ).replace("__RUST__", dart_marker, 1)
    mutations.extend(
        [
            (
                "driver_consumer_omission",
                lambda: validate_driver_text(
                    driver_text.replace(RECURRING_TOPOLOGY["consumers"][3]["driver_marker"], "", 1),
                    RECURRING_TOPOLOGY,
                ),
            ),
            ("driver_order_drift", lambda: validate_driver_text(reordered_driver, RECURRING_TOPOLOGY)),
            (
                "driver_project_data_bypass",
                lambda: validate_driver_text(
                    driver_text.replace("tools/run_cargo_local.sh", "cargo", 1), RECURRING_TOPOLOGY
                ),
            ),
            (
                "driver_premature_lua_admission",
                lambda: validate_driver_text(driver_text + "\nbash tools/run_lua_local.sh\n", RECURRING_TOPOLOGY),
            ),
        ]
    )

    execution = f'bash "$REPO_ROOT/{RECURRING_TOPOLOGY["driver"]}"'
    switch = RECURRING_TOPOLOGY["local_ci"]["switch"]
    mutations.extend(
        [
            (
                "canonical_execution_omission",
                lambda: validate_canonical_text(ci_text.replace(execution, "", 1), RECURRING_TOPOLOGY),
            ),
            (
                "canonical_execution_duplication",
                lambda: validate_canonical_text(ci_text + f"\n{execution}\n", RECURRING_TOPOLOGY),
            ),
            (
                "canonical_switch_loss",
                lambda: validate_canonical_text(ci_text.replace(switch, "WRONG_SWITCH"), RECURRING_TOPOLOGY),
            ),
        ]
    )

    for name, field, value in [
        ("future_owner_drift", "owner", "FUTURE-PARITY-BACKLOG.11.7"),
        ("stale_completed_backend_claim", "reason", "Rust and Julia remain future."),
        ("premature_five_backend_claim", "reason", "All five backends are current."),
    ]:
        def check(field: str = field, value: str = value) -> None:
            candidate = copy.deepcopy(future_record)
            candidate[field] = value
            validate_future_exclusion(candidate)

        mutations.append((name, check))

    for name, mutate in [
        ("public_document_omission", lambda value: value["documents"].pop()),
        ("public_marker_omission", lambda value: value["documents"][0]["required_markers"].pop()),
        ("stale_public_claim_omission", lambda value: value["forbidden_current_claims"].pop()),
    ]:
        def check(mutate: Callable[[dict[str, Any]], None] = mutate) -> None:
            candidate = copy.deepcopy(public_contract)
            mutate(candidate)
            validate_public_contract(candidate, check_filesystem=False)

        mutations.append((name, check))

    for name, check in mutations:
        expect_mutation_failure(name, check)
    return len(mutations)


def validate_governance(public_contract: dict[str, Any]) -> int:
    validate_recurring_topology(RECURRING_TOPOLOGY, check_filesystem=True)
    manifest = json.loads((ROOT / "capability_conformance" / "manifest.json").read_text(encoding="utf-8"))
    records = [
        record
        for record in manifest["excluded_or_future"]
        if record.get("id") == EXPECTED_FUTURE_EXCLUSION["id"]
    ]
    require(
        len(records) == 1,
        "callable_status_drift",
        "generic final-codeblock exclusion must occur exactly once",
    )
    future_record = records[0]
    validate_future_exclusion(future_record)
    validate_public_contract(public_contract, check_filesystem=True)
    driver_text = (ROOT / RECURRING_TOPOLOGY["driver"]).read_text(encoding="utf-8")
    ci_text = (ROOT / RECURRING_TOPOLOGY["local_ci"]["driver"]).read_text(encoding="utf-8")
    return governance_mutation_checks(driver_text, ci_text, future_record, public_contract)


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    signature_contract = json.loads(SIGNATURE_PATH.read_text(encoding="utf-8"))
    expected_top = {
        "format", "contract_id", "policy", "syntax", "brace_classification", "ast_schema",
        "resolution_precedence", "literals", "call_cases", "invalid_literal_cases",
        "invalid_call_cases", "final_codeblock_parameter_declaration",
        "contextual_final_block_cases", "public_contract", "fixture",
    }
    if set(contract) != expected_top or contract["format"] != 1 or contract["contract_id"] != "linkedspec-callable-codeblock-v1":
        fail("invalid_contract", "top-level fields, format, or id drifted")
    if set(contract["policy"]) != {
        "construction", "invocation", "context", "parameters", "results", "resolution", "failures",
        "trailing_blocks", "closures",
    } or any(not isinstance(value, str) or not value for value in contract["policy"].values()):
        fail("invalid_contract", "policy fields drifted")
    if signature_contract["contract_id"] != "linkedspec-callable-signature-v1":
        fail("invalid_contract", "callable-signature dependency drifted")
    if contract["syntax"] != {
        "opener": "{|", "opener_whitespace": False, "signature_closer": "|", "literal_closer": "}",
        "zero_parameter_form": "{|| body }", "parameter_separator": ",", "rest_form": "...IDENTIFIER",
        "rest_position": "final",
    }:
        fail("invalid_contract", "syntax policy drifted")
    declaration = contract["final_codeblock_parameter_declaration"]
    if set(declaration) != {
        "value_kind", "source", "parameter_name", "position", "callback_signature_owner",
        "contextual_block_invocation", "rest_parameter_after", "invalid",
    }:
        fail("invalid_contract", "final-codeblock declaration fields drifted")
    if declaration != {
        "value_kind": "codeblock",
        "source": "callback: codeblock",
        "parameter_name": "callback",
        "position": "final",
        "callback_signature_owner": "codeblock_value",
        "contextual_block_invocation": "zero positional arguments with dynamic caller context",
        "rest_parameter_after": False,
        "invalid": declaration["invalid"],
    } or parse_final_codeblock_parameter(declaration["source"]) != {"name": "callback", "value_kind": "codeblock"}:
        fail("invalid_contract", "final-codeblock declaration policy drifted")
    for case in declaration["invalid"]:
        if set(case) != {"id", "source", "expected_code"}:
            fail("invalid_contract", "invalid declaration case fields drifted")
        try:
            parse_final_codeblock_parameter(case["source"])
        except ContractError as error:
            if error.code != case["expected_code"]:
                fail("diagnostic_mismatch", f"{case['id']}: expected {case['expected_code']}, got {error.code}")
        else:
            fail("diagnostic_mismatch", f"{case['id']} declaration unexpectedly parsed")
    schema = contract["ast_schema"]
    if set(schema) != {"kind", "version", "fields", "signature_contract", "captured_environment_field"}:
        fail("invalid_contract", "AST schema fields drifted")
    if schema["kind"] != "codeblock_literal" or schema["version"] != 1 or set(schema["fields"]) != AST_FIELDS or len(schema["fields"]) != len(AST_FIELDS):
        fail("invalid_contract", "AST schema drifted")
    if schema["signature_contract"] != "capability_conformance/callable_signature_contract.json:signature_schema" or schema["captured_environment_field"] is not None:
        fail("invalid_contract", "signature dependency or no-capture marker drifted")
    expected_precedence = ["control", "helper", "registered_user_function", "bound_codeblock_variable", "bound_non_codeblock_diagnostic", "unknown_call_diagnostic"]
    if contract["resolution_precedence"] != expected_precedence:
        fail("invalid_contract", "call resolution precedence drifted")

    for case in contract["brace_classification"]:
        if classify_braces(case["source"]) != case["expected_kind"]:
            fail("brace_classification_mismatch", case["id"])

    literals: dict[str, dict[str, Any]] = {}
    for literal in contract["literals"]:
        if set(literal) != {"id", "variable", "signature_source", "source", "body_source", "behavior"}:
            fail("invalid_literal", "literal fields drifted")
        if literal["id"] in literals or literal["behavior"] not in BEHAVIORS:
            fail("invalid_literal", f"duplicate or unknown literal {literal['id']}")
        parsed = parse_literal(literal["source"])
        if set(parsed) != AST_FIELDS:
            fail("invalid_literal", f"AST fields drifted for {literal['id']}")
        if parsed["signature"] != parse_signature_source(literal["signature_source"]):
            fail("invalid_literal", f"signature mismatch for {literal['id']}")
        if parsed["body_source"] != literal["body_source"]:
            fail("invalid_literal", f"body mismatch for {literal['id']}")
        literal["parsed"] = parsed
        literals[literal["id"]] = literal

    calls = {case["id"]: case for case in contract["call_cases"]}
    if len(calls) != len(contract["call_cases"]):
        fail("invalid_call_case", "duplicate call id")
    for case in contract["call_cases"]:
        actual = execute_call(case, literals)
        if actual != case["expected"]:
            fail("call_mismatch", f"{case['id']}: expected {case['expected']!r}, got {actual!r}")

    for case in contract["invalid_literal_cases"]:
        try:
            parse_literal(case["source"])
        except ContractError as error:
            if error.code != case["expected_code"]:
                fail("diagnostic_mismatch", f"{case['id']}: expected {case['expected_code']}, got {error.code}")
        else:
            fail("diagnostic_mismatch", f"{case['id']} unexpectedly parsed")

    for case in contract["invalid_call_cases"]:
        if "literal" in case and case["id"] not in {"direct_recursion"}:
            actual = bind_arguments(literals[case["literal"]]["parsed"]["signature"], case["arguments"])
        elif case["id"] == "bound_non_codeblock":
            actual = {"code": "value_not_callable", "value_kind": "scalar"}
        elif case["id"] == "unknown_call":
            actual = {"code": "unknown_helper", "name": case["binding"]}
        elif case["id"] == "direct_recursion":
            name = literals[case["literal"]]["variable"]
            actual = {"code": "codeblock_recursion_unsupported", "cycle": [name, name]}
        else:
            fail("invalid_call_case", f"unknown invalid-call shape {case['id']}")
        if actual != case["expected_error"]:
            fail("diagnostic_mismatch", f"{case['id']}: expected {case['expected_error']!r}, got {actual!r}")

    expected_contextual = {
        "helper_attached": ("helper", "call", "codeblock_argument"),
        "helper_parenthesized": ("helper", "call", "codeblock_argument"),
        "user_function_attached": ("user_function", "call", "codeblock_argument"),
        "user_function_parenthesized": ("user_function", "call", "codeblock_argument"),
        "receiver_attached": ("receiver", "fluent_chain", "codeblock_argument"),
        "receiver_parenthesized": ("receiver", "fluent_chain", "codeblock_argument"),
        "explicit_literal": ("helper", "call", "codeblock_literal"),
    }
    for case in contract["contextual_final_block_cases"]:
        if case["id"] == "harray_not_promoted":
            if set(case) != {"id", "surface", "source", "parameter_declaration", "expected_error"}:
                fail("contextual_block_mismatch", case["id"])
            if classify_braces('{ "value" : value }') != "harray_literal" or case["expected_error"] != "final_argument_not_codeblock":
                fail("contextual_block_mismatch", case["id"])
            continue
        if set(case) != {"id", "surface", "source", "parameter_declaration", "canonical_kind", "final_argument_kind"}:
            fail("contextual_block_mismatch", case["id"])
        if parse_final_codeblock_parameter(case["parameter_declaration"])["value_kind"] != "codeblock":
            fail("contextual_block_mismatch", case["id"])
        actual = (case["surface"], case["canonical_kind"], case["final_argument_kind"])
        if actual != expected_contextual[case["id"]]:
            fail("contextual_block_mismatch", case["id"])

    fixture = contract["fixture"]
    if set(fixture) != {"literal_ids", "result_case_ids", "input", "spec_source", "expected"} or fixture["input"] != "xx":
        fail("fixture_mismatch", "fixture fields or input drifted")
    if fixture["spec_source"] != render_fixture(literals, fixture):
        fail("fixture_mismatch", "future fixture source drifted from literals")
    if fixture["expected"] != fixture_expected(literals):
        fail("fixture_mismatch", "future fixture values drifted from neutral execution")
    if set(fixture["literal_ids"]) != set(literals) - {"shadow_static"}:
        fail("fixture_mismatch", "fixture literal coverage drifted")
    if set(fixture["result_case_ids"]) != set(calls) - {"static_name_precedence", "standalone_discard_keeps_effects"}:
        fail("fixture_mismatch", "fixture call coverage drifted")

    governance_mutations = validate_governance(contract["public_contract"])
    print(
        "callable-codeblock-contract: OK "
        f"({len(literals)} literals; {len(calls)} calls; "
        f"{len(contract['invalid_literal_cases'])} invalid literals; "
        f"{len(contract['invalid_call_cases'])} invalid calls; "
        f"{len(contract['final_codeblock_parameter_declaration']['invalid'])} invalid declarations; "
        f"{len(contract['contextual_final_block_cases'])} contextual forms; "
        f"{governance_mutations} governance mutations)"
    )


if __name__ == "__main__":
    main()

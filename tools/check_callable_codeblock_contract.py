#!/usr/bin/env python3
"""Validate the neutral callable-codeblock schema, semantics, and fixture."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any

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


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    signature_contract = json.loads(SIGNATURE_PATH.read_text(encoding="utf-8"))
    expected_top = {
        "format", "contract_id", "policy", "syntax", "brace_classification", "ast_schema",
        "resolution_precedence", "literals", "call_cases", "invalid_literal_cases",
        "invalid_call_cases", "final_codeblock_parameter_declaration",
        "contextual_final_block_cases", "fixture",
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

    print(
        "callable-codeblock-contract: OK "
        f"({len(literals)} literals; {len(calls)} calls; "
        f"{len(contract['invalid_literal_cases'])} invalid literals; "
        f"{len(contract['invalid_call_cases'])} invalid calls; "
        f"{len(contract['final_codeblock_parameter_declaration']['invalid'])} invalid declarations; "
        f"{len(contract['contextual_final_block_cases'])} contextual forms)"
    )


if __name__ == "__main__":
    main()

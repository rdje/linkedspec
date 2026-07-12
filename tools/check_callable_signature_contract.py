#!/usr/bin/env python3
"""Validate the neutral callable-signature schema, cases, and rendered fixture."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "callable_signature_contract.json"
DESCRIPTOR_PATH = ROOT / "capability_conformance" / "outward_descriptor_contract.json"
IDENTIFIER = re.compile(r"[A-Za-z_]\w*\Z")
RESERVED_PARAMETERS = {
    "fn",
    "return",
    "I",
    "LS",
    "LE",
    "E",
    "EX",
    "IT",
    "LX",
    "STRING",
    "descr",
    "minfo",
    "LSPOS",
    "LEPOS",
    "LMATCH",
    "LSMATCH",
    "IMATCH",
    "IMATCH_LIST",
    "LMATCH_LIST",
    "IMATCH_HASH",
    "LMATCH_HASH",
    "SELF",
    "this",
    "ctx",
    "runtime_ctx",
}
SIGNATURE_FIELDS = {
    "kind",
    "version",
    "positional_params",
    "rest_param",
    "min_arity",
    "max_arity",
}
BEHAVIORS = {
    "return_fixed_array",
    "return_rest_array",
    "return_prefix_rest_object",
}


class ContractError(ValueError):
    """A stable contract-validation failure."""

    def __init__(self, code: str, detail: str):
        super().__init__(detail)
        self.code = code


def fail(code: str, detail: str) -> None:
    raise ContractError(code, detail)


def parse_signature_source(source: str) -> dict[str, Any]:
    if not isinstance(source, str):
        fail("invalid_signature", "signature source must be a string")
    if source == "":
        parts: list[str] = []
    else:
        parts = [part.strip() for part in source.split(",")]
        if any(not part for part in parts):
            fail("invalid_parameter", "signature contains an empty parameter")

    positional: list[str] = []
    rest_param: str | None = None
    seen: set[str] = set()
    for index, part in enumerate(parts):
        if part.startswith("..."):
            if index != len(parts) - 1:
                fail("rest_parameter_must_be_final", "rest parameter must be final")
            if not re.fullmatch(r"\.\.\.[A-Za-z_]\w*", part):
                fail("invalid_rest_parameter", "rest parameter must use ...IDENTIFIER")
            name = part[3:]
            rest_param = name
        else:
            if not IDENTIFIER.fullmatch(part):
                fail("invalid_parameter", "fixed parameter must be an identifier")
            name = part
            positional.append(name)
        if name in seen:
            fail("duplicate_parameter", f"duplicate parameter {name}")
        if name in RESERVED_PARAMETERS:
            fail("reserved_parameter", f"reserved parameter {name}")
        seen.add(name)

    return {
        "kind": "callable_signature",
        "version": 1,
        "positional_params": positional,
        "rest_param": rest_param,
        "min_arity": len(positional),
        "max_arity": None if rest_param is not None else len(positional),
    }


def render_signature(signature: dict[str, Any]) -> str:
    parts = list(signature["positional_params"])
    if signature["rest_param"] is not None:
        parts.append("..." + signature["rest_param"])
    return ", ".join(parts)


def validate_signature(signature: Any, context: str) -> None:
    if not isinstance(signature, dict) or set(signature) != SIGNATURE_FIELDS:
        fail("invalid_signature", f"{context} fields drifted")
    if signature["kind"] != "callable_signature" or signature["version"] != 1:
        fail("invalid_signature", f"{context} kind/version drifted")
    positional = signature["positional_params"]
    rest_param = signature["rest_param"]
    if not isinstance(positional, list) or any(not isinstance(item, str) for item in positional):
        fail("invalid_signature", f"{context} positional_params must be strings")
    rendered = render_signature(signature)
    parsed = parse_signature_source(rendered)
    if parsed != signature:
        fail("invalid_signature", f"{context} is not its canonical parsed signature")
    if rest_param is not None and not isinstance(rest_param, str):
        fail("invalid_signature", f"{context} rest_param must be string or null")


def render_definition(definition: dict[str, Any]) -> str:
    name = definition["name"]
    signature = render_signature(definition["signature"])
    behavior = definition["behavior"]
    positional = definition["signature"]["positional_params"]
    rest_param = definition["signature"]["rest_param"]
    if behavior == "return_fixed_array":
        body = "return([" + ", ".join(positional) + "])"
    elif behavior == "return_rest_array":
        body = f"return({rest_param})"
    elif behavior == "return_prefix_rest_object":
        body = f'return({{ "prefix" : {positional[0]}, "items" : {rest_param} }})'
    else:
        fail("invalid_behavior", f"unknown behavior {behavior}")
    return f"fn {name}({signature}) {{ {body} }}"


def render_value(value: Any) -> str:
    if value is None:
        return "undef"
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list):
        return "[" + ", ".join(render_value(item) for item in value) + "]"
    if isinstance(value, dict):
        return "{ " + ", ".join(
            f"{render_value(key)} : {render_value(item)}" for key, item in value.items()
        ) + " }"
    return json.dumps(value, ensure_ascii=False, allow_nan=False)


def resolve_call(definition: dict[str, Any], arguments: list[dict[str, Any]]) -> Any:
    keyword_count = sum(argument.get("kind") == "keyword" for argument in arguments)
    if keyword_count:
        return {
            "code": "user_function_keyword_arguments_unsupported",
            "expected": "positional arguments",
            "got": keyword_count,
        }
    if any(set(argument) != {"kind", "value"} or argument["kind"] != "positional" for argument in arguments):
        fail("invalid_call_case", "positional arguments must contain only kind/value")

    signature = definition["signature"]
    values = [copy.deepcopy(argument["value"]) for argument in arguments]
    minimum = signature["min_arity"]
    maximum = signature["max_arity"]
    if len(values) < minimum or (maximum is not None and len(values) > maximum):
        expected = f"exactly {minimum}" if maximum == minimum else f"at least {minimum}"
        return {"code": "user_function_arity_mismatch", "expected": expected, "got": len(values)}

    fixed_count = len(signature["positional_params"])
    fixed_values = values[:fixed_count]
    rest_values = values[fixed_count:]
    behavior = definition["behavior"]
    if behavior == "return_fixed_array":
        result: Any = fixed_values
    elif behavior == "return_rest_array":
        result = rest_values
    elif behavior == "return_prefix_rest_object":
        result = {"prefix": fixed_values[0], "items": rest_values}
    else:
        fail("invalid_behavior", f"unknown behavior {behavior}")
    return copy.deepcopy(result)


def render_call(call: dict[str, Any]) -> str:
    values = [render_value(argument["value"]) for argument in call["arguments"]]
    rendered = f'{call["function"]}(' + ", ".join(values) + ")"
    if call.get("result_chain") == "length":
        rendered += ".length()"
    return rendered


def render_fixture(
    definitions: dict[str, dict[str, Any]],
    calls: dict[str, dict[str, Any]],
    fixture: dict[str, Any],
) -> str:
    definition_source = "\n".join(render_definition(definitions[item]) for item in fixture["definition_ids"])
    rows = [
        f'     {json.dumps(case_id)} : {render_call(calls[case_id])}'
        for case_id in fixture["result_case_ids"]
    ]
    return (
        definition_source
        + "\n\nTop::\n /x/ -> Done {\n   return({\n"
        + ",\n".join(rows)
        + "\n   })\n }\n\nDone::\n /x/\n"
    )


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    expected_top = {
        "format",
        "contract_id",
        "policy",
        "syntax",
        "signature_schema",
        "definition_versions",
        "purpose_examples",
        "definitions",
        "call_cases",
        "invalid_definition_cases",
        "fixture",
    }
    if set(contract) != expected_top:
        fail("invalid_contract", "top-level fields drifted")
    if contract["format"] != 1 or contract["contract_id"] != "linkedspec-callable-signature-v1":
        fail("invalid_contract", "format or contract id drifted")
    if set(contract["policy"]) != {
        "variadic_definition",
        "fixed_definition",
        "arguments",
        "rest_binding",
        "call_resolution",
        "receiver_methods",
        "overloads",
        "results",
    }:
        fail("invalid_contract", "policy fields drifted")
    if contract["syntax"] != {
        "rest_marker": "...",
        "rest_form": "...IDENTIFIER",
        "rest_position": "final",
        "marker_name_whitespace": False,
        "zero_fixed_parameters": True,
        "empty_rest_values": True,
    }:
        fail("invalid_contract", "syntax policy drifted")
    schema = contract["signature_schema"]
    if (
        set(schema) != {"kind", "version", "fields"}
        or schema["kind"] != "callable_signature"
        or schema["version"] != 1
        or set(schema["fields"]) != SIGNATURE_FIELDS
        or len(schema["fields"]) != len(SIGNATURE_FIELDS)
    ):
        fail("invalid_contract", "signature schema drifted")

    descriptor = json.loads(DESCRIPTOR_PATH.read_text(encoding="utf-8"))
    versions = contract["definition_versions"]
    if set(versions) != {"fixed", "variadic"}:
        fail("invalid_contract", "definition versions drifted")
    if versions["fixed"] != {
        "function_version": 1,
        "record_fields_source": "capability_conformance/outward_descriptor_contract.json:function_record_keys",
        "signature_storage": ["params", "arity"],
    }:
        fail("invalid_contract", "fixed definition version drifted")
    if versions["variadic"]["function_version"] != 2 or versions["variadic"]["signature_storage"] != ["signature"]:
        fail("invalid_contract", "variadic definition version drifted")
    expected_v2_fields = [key for key in descriptor["function_record_keys"] if key not in {"params", "arity"}]
    expected_v2_fields.insert(4, "signature")
    if versions["variadic"]["record_fields"] != expected_v2_fields:
        fail("invalid_contract", "variadic record fields drifted")

    expected_purpose = {
        ("num_add", "helper", 2, None),
        ("num_sub", "helper", 2, 2),
        ("cat", "helper", 2, None),
        ("array", "helper", 0, None),
    }
    actual_purpose = {
        (item["name"], item["surface"], item["min_arity"], item["max_arity"])
        for item in contract["purpose_examples"]
        if item["surface"] == "helper"
    }
    if actual_purpose != expected_purpose:
        fail("invalid_contract", "helper purpose examples drifted")
    methods = [item for item in contract["purpose_examples"] if item["surface"] == "receiver_method"]
    if any(item.get("receiver_injection") != "prepend" for item in methods) or len(methods) != 2:
        fail("invalid_contract", "receiver purpose examples drifted")

    definitions: dict[str, dict[str, Any]] = {}
    definitions_by_name: dict[str, dict[str, Any]] = {}
    for definition in contract["definitions"]:
        if set(definition) != {"id", "name", "function_version", "signature", "behavior"}:
            fail("invalid_definition", "definition fields drifted")
        if definition["id"] in definitions or definition["name"] in definitions_by_name:
            fail("invalid_definition", "duplicate definition id or name")
        if not IDENTIFIER.fullmatch(definition["name"]):
            fail("invalid_definition", "invalid function name")
        validate_signature(definition["signature"], definition["id"])
        signature = definition["signature"]
        expected_version = 2 if signature["rest_param"] is not None else 1
        if definition["function_version"] != expected_version:
            fail("invalid_definition", "function version does not match signature")
        if definition["behavior"] not in BEHAVIORS:
            fail("invalid_definition", "invalid behavior")
        definitions[definition["id"]] = definition
        definitions_by_name[definition["name"]] = definition

    invalid_ids: set[str] = set()
    for case in contract["invalid_definition_cases"]:
        if set(case) != {"id", "signature_source", "expected_code"} or case["id"] in invalid_ids:
            fail("invalid_definition_case", "invalid definition case fields/id")
        invalid_ids.add(case["id"])
        try:
            parse_signature_source(case["signature_source"])
        except ContractError as error:
            if error.code != case["expected_code"]:
                fail("invalid_definition_case", f'{case["id"]} expected {case["expected_code"]}, got {error.code}')
        else:
            fail("invalid_definition_case", f'{case["id"]} unexpectedly parsed')

    calls: dict[str, dict[str, Any]] = {}
    for case in contract["call_cases"]:
        if case["id"] in calls or case["function"] not in definitions_by_name:
            fail("invalid_call_case", "duplicate call id or unknown function")
        expected_fields = {"id", "function", "arguments", "expected"}
        if "expected_error" in case:
            expected_fields = {"id", "function", "arguments", "expected_error"}
        if "result_chain" in case:
            expected_fields.add("result_chain")
        if set(case) != expected_fields or not isinstance(case["arguments"], list):
            fail("invalid_call_case", f'{case["id"]} fields drifted')
        actual = resolve_call(definitions_by_name[case["function"]], case["arguments"])
        if case.get("result_chain") == "length":
            if not isinstance(actual, list):
                fail("invalid_call_case", f'{case["id"]} receiver is not an array')
            actual = len(actual)
        expected = case.get("expected_error", case.get("expected"))
        if actual != expected:
            fail("invalid_call_case", f'{case["id"]} expected {expected!r}, got {actual!r}')
        calls[case["id"]] = case

    fixture = contract["fixture"]
    if set(fixture) != {"definition_ids", "result_case_ids", "input", "spec_source", "expected"}:
        fail("invalid_fixture", "fixture fields drifted")
    if fixture["input"] != "xx":
        fail("invalid_fixture", "fixture input drifted")
    if any("expected" not in calls[case_id] for case_id in fixture["result_case_ids"]):
        fail("invalid_fixture", "fixture may contain only successful call cases")
    rendered_expected = {case_id: calls[case_id]["expected"] for case_id in fixture["result_case_ids"]}
    if fixture["expected"] != rendered_expected:
        fail("invalid_fixture", "fixture expected object drifted")
    rendered_spec = render_fixture(definitions, calls, fixture)
    if fixture["spec_source"] != rendered_spec:
        fail("invalid_fixture", "fixture spec_source drifted from deterministic rendering")

    print(
        "callable-signature-contract: OK "
        f"({len(definitions)} definitions; {len(calls)} calls; {len(invalid_ids)} invalid definitions)"
    )


if __name__ == "__main__":
    try:
        main()
    except ContractError as error:
        raise SystemExit(f"callable-signature-contract: {error.code}: {error}") from error

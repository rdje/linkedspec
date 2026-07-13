#!/usr/bin/env python3
"""Validate the neutral punctuation-light zero-argument syntax contract."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "punctuation_light_zero_arg_contract.json"
IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")
STANDALONE_KINDS = {
    "else": "control_else",
    "endif": "control_endif",
    "default": "control_default",
    "endcase": "control_endcase",
    "endswitch": "control_endswitch",
    "next": "call",
}


class ContractError(ValueError):
    """Stable contract validation failure."""

    def __init__(self, code: str, detail: str):
        super().__init__(detail)
        self.code = code


def fail(code: str, detail: str) -> None:
    raise ContractError(code, detail)


def split_top_level_dots(source: str) -> list[str]:
    segments: list[str] = []
    start = 0
    quote: str | None = None
    escaped = False
    depths = {"(": 0, "[": 0, "{": 0}
    closes = {")": "(", "]": "[", "}": "{"}
    for index, char in enumerate(source):
        if quote is not None:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in {'"', "'"}:
            quote = char
            continue
        if char in depths:
            depths[char] += 1
            continue
        if char in closes:
            opener = closes[char]
            if depths[opener] == 0:
                fail("invalid_expression", f"unmatched {char} in {source!r}")
            depths[opener] -= 1
            continue
        if char == "." and all(depth == 0 for depth in depths.values()):
            segments.append(source[start:index].strip())
            start = index + 1
    if quote is not None or any(depth != 0 for depth in depths.values()):
        fail("invalid_expression", f"unbalanced expression {source!r}")
    segments.append(source[start:].strip())
    return segments


def split_top_level_arguments(payload: str) -> list[str]:
    if payload.strip() == "":
        return []
    parts: list[str] = []
    start = 0
    quote: str | None = None
    escaped = False
    depths = {"(": 0, "[": 0, "{": 0}
    closes = {")": "(", "]": "[", "}": "{"}
    for index, char in enumerate(payload):
        if quote is not None:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in {'"', "'"}:
            quote = char
        elif char in depths:
            depths[char] += 1
        elif char in closes:
            opener = closes[char]
            if depths[opener] == 0:
                fail("invalid_expression", f"unmatched {char} in argument payload")
            depths[opener] -= 1
        elif char == "," and all(depth == 0 for depth in depths.values()):
            parts.append(payload[start:index].strip())
            start = index + 1
    if quote is not None or any(depth != 0 for depth in depths.values()):
        fail("invalid_expression", "unbalanced argument payload")
    parts.append(payload[start:].strip())
    if any(part == "" for part in parts):
        fail("invalid_expression", "empty argument")
    return parts


def parse_call_segment(segment: str, allow_bare: bool) -> dict[str, Any]:
    call = re.fullmatch(r"([A-Za-z_][A-Za-z0-9_]*)\s*\((.*)\)", segment, re.DOTALL)
    if call is not None:
        return {"method": call.group(1), "args": split_top_level_arguments(call.group(2))}
    if allow_bare and IDENTIFIER.fullmatch(segment):
        return {"method": segment, "args": []}
    if IDENTIFIER.fullmatch(segment):
        fail("nonfinal_receiver_parentheses_required", f"non-final receiver segment {segment!r} is bare")
    fail("invalid_receiver_call", f"invalid receiver segment {segment!r}")


def parse_receiver(source: str) -> dict[str, Any]:
    segments = split_top_level_dots(source)
    if len(segments) < 2 or segments[0] == "":
        fail("invalid_receiver_call", f"receiver chain required for {source!r}")
    calls = [
        parse_call_segment(segment, allow_bare=index == len(segments) - 1)
        for index, segment in enumerate(segments[1:], start=1)
    ]
    return {"kind": "fluent_chain", "receiver_source": segments[0], "calls": calls}


def parse_standalone(source: str, markers: set[str]) -> dict[str, Any]:
    stripped = source.strip()
    match = re.fullmatch(r"([A-Za-z_][A-Za-z0-9_]*)(?:\s*\(\s*\))?", stripped)
    if match is None or match.group(1) not in markers:
        fail("invalid_standalone_alias", f"not a governed standalone alias: {source!r}")
    name = match.group(1)
    return {"kind": STANDALONE_KINDS[name], "canonical_name": name, "args": []}


def classify_invalid(source: str) -> str:
    stripped = source.strip()
    if re.match(r"^(?:if|while)\s+[A-Za-z_]", stripped):
        return "condition_header_parentheses_required"
    if re.match(r"^[A-Za-z_][A-Za-z0-9_]*\s+", stripped):
        return "call_parentheses_required"
    if re.search(r"\.[A-Za-z_][A-Za-z0-9_]*\s*\{", stripped):
        return "receiver_trailing_block_parentheses_required"
    try:
        parse_receiver(stripped)
    except ContractError as error:
        return error.code
    fail("invalid_negative_case", f"negative case unexpectedly parses: {source!r}")


def render_fixture(model: dict[str, Any]) -> str:
    values = json.dumps(model["values"], ensure_ascii=False)
    label = json.dumps(model["label"], ensure_ascii=False)
    if_condition = "true" if model["if_condition"] else "false"
    while_condition = "true" if model["while_condition"] else "false"
    switch_case = model["switch_case"]
    if not IDENTIFIER.fullmatch(switch_case):
        fail("invalid_fixture", "fixture switch case must be a bare literal label")
    return (
        "Top::\n /x/ -> Done {\n"
        f"   values = {values}\n"
        f"   label = {label}\n"
        f"   if({if_condition})\n"
        "     return(\"bad-if\")\n"
        "   else\n"
        "     result = label.trim\n"
        "   endif\n"
        "   switch(result)\n"
        "   case(no)\n"
        "     return(\"bad-case\")\n"
        "   endcase\n"
        f"   case({switch_case})\n"
        "     picked = values.sorted().first\n"
        "   endcase\n"
        "   default\n"
        "     return(\"bad-default\")\n"
        "   endswitch\n"
        f"   while({while_condition}) {{\n"
        "     next\n"
        "   }\n"
        "   return({ \"result\" : result, \"picked\" : picked, \"count\" : values.count })\n"
        " }\n\nDone::\n /x/\n"
    )


def evaluate_fixture(model: dict[str, Any]) -> dict[str, Any]:
    if model["if_condition"]:
        fail("invalid_fixture", "future fixture model must select else")
    result = model["label"].strip()
    if result != model["switch_case"]:
        fail("invalid_fixture", "future fixture model must select the intended case")
    values = copy.deepcopy(model["values"])
    if not isinstance(values, list) or not values:
        fail("invalid_fixture", "future fixture values must be a nonempty array")
    picked = sorted(values, key=str)[0]
    if model["while_condition"]:
        fail("invalid_fixture", "future fixture while must remain unentered")
    return {"result": result, "picked": picked, "count": len(values)}


def require_exact_fields(value: Any, fields: set[str], context: str) -> dict[str, Any]:
    if not isinstance(value, dict) or set(value) != fields:
        fail("invalid_contract", f"{context} fields drifted")
    return value


def validate_contract(contract: dict[str, Any]) -> None:
    expected_top = {
        "format",
        "contract_id",
        "policy",
        "syntax",
        "ast_schema",
        "standalone_cases",
        "receiver_cases",
        "retained_noncall_cases",
        "invalid_syntax_cases",
        "method_contract_cases",
        "future_fixture",
    }
    if set(contract) != expected_top:
        fail("invalid_contract", "top-level fields drifted")
    if contract["format"] != 1 or contract["contract_id"] != "linkedspec-punctuation-light-zero-arg-v1":
        fail("invalid_contract", "format or contract id drifted")
    if set(contract["policy"]) != {
        "general_call_grammar",
        "standalone_aliases",
        "terminal_receiver_alias",
        "arity",
        "parenthesized_forms",
        "rule_suffixes",
        "excluded_headers",
        "excluded_calls",
    }:
        fail("invalid_contract", "policy fields drifted")
    syntax = require_exact_fields(
        contract["syntax"],
        {
            "standalone_markers",
            "bare_receiver_position",
            "bare_receiver_authored_arguments",
            "general_call_form",
            "receiver_call_form",
            "bare_receiver_form",
            "condition_headers",
            "trailing_codeblock_receiver_form",
        },
        "syntax",
    )
    markers = syntax["standalone_markers"]
    if markers != list(STANDALONE_KINDS):
        fail("invalid_contract", "standalone marker order or membership drifted")
    if syntax["bare_receiver_position"] != "final" or syntax["bare_receiver_authored_arguments"] != 0:
        fail("invalid_contract", "bare receiver terminality drifted")
    if syntax["condition_headers"] != ["if(CONDITION)", "while(CONDITION)"]:
        fail("invalid_contract", "condition header contract drifted")

    schema = require_exact_fields(
        contract["ast_schema"],
        {"standalone_fields", "receiver_fields", "receiver_call_fields", "zero_args"},
        "ast schema",
    )
    if schema != {
        "standalone_fields": ["kind", "canonical_name", "args"],
        "receiver_fields": ["kind", "receiver_source", "calls"],
        "receiver_call_fields": ["method", "args"],
        "zero_args": [],
    }:
        fail("invalid_contract", "AST schema drifted")

    standalone_cases = contract["standalone_cases"]
    if not isinstance(standalone_cases, list) or len(standalone_cases) != len(markers):
        fail("invalid_contract", "standalone case count drifted")
    seen: set[str] = set()
    for case in standalone_cases:
        require_exact_fields(case, {"id", "bare", "parenthesized", "expected_ast"}, "standalone case")
        case_id = case["id"]
        if case_id in seen or case_id not in markers:
            fail("invalid_contract", f"invalid or duplicate standalone case {case_id!r}")
        seen.add(case_id)
        if case["bare"] != case_id or case["parenthesized"] != f"{case_id}()":
            fail("invalid_contract", f"standalone spellings drifted for {case_id}")
        bare_ast = parse_standalone(case["bare"], set(markers))
        parenthesized_ast = parse_standalone(case["parenthesized"], set(markers))
        if bare_ast != parenthesized_ast or bare_ast != case["expected_ast"]:
            fail("invalid_contract", f"standalone AST equivalence drifted for {case_id}")
    if seen != set(markers):
        fail("invalid_contract", "standalone case coverage drifted")

    receiver_cases = contract["receiver_cases"]
    if not isinstance(receiver_cases, list) or len(receiver_cases) < 4:
        fail("invalid_contract", "receiver case coverage is too small")
    receiver_ids: set[str] = set()
    for case in receiver_cases:
        require_exact_fields(case, {"id", "bare", "parenthesized", "expected_ast"}, "receiver case")
        if case["id"] in receiver_ids:
            fail("invalid_contract", f"duplicate receiver case {case['id']!r}")
        receiver_ids.add(case["id"])
        bare_ast = parse_receiver(case["bare"])
        parenthesized_ast = parse_receiver(case["parenthesized"])
        if bare_ast != parenthesized_ast or bare_ast != case["expected_ast"]:
            fail("invalid_contract", f"receiver AST equivalence drifted for {case['id']}")

    retained = contract["retained_noncall_cases"]
    if not isinstance(retained, list) or len(retained) < 3:
        fail("invalid_contract", "retained identifier coverage is too small")
    for case in retained:
        require_exact_fields(case, {"id", "source", "expected_ast"}, "retained noncall case")
        source = case["source"]
        if not IDENTIFIER.fullmatch(source) or source in markers:
            fail("invalid_contract", f"invalid retained identifier {source!r}")
        if case["expected_ast"] != {"kind": "variable", "name": source}:
            fail("invalid_contract", f"retained identifier AST drifted for {source}")

    invalid_cases = contract["invalid_syntax_cases"]
    expected_invalid_codes = {
        "condition_header_parentheses_required",
        "call_parentheses_required",
        "nonfinal_receiver_parentheses_required",
        "receiver_trailing_block_parentheses_required",
    }
    observed_codes: set[str] = set()
    for case in invalid_cases:
        require_exact_fields(case, {"id", "source", "expected_code"}, "invalid syntax case")
        actual = classify_invalid(case["source"])
        if actual != case["expected_code"]:
            fail("invalid_contract", f"invalid syntax classification drifted for {case['id']}: {actual}")
        observed_codes.add(actual)
    if observed_codes != expected_invalid_codes:
        fail("invalid_contract", "negative syntax coverage drifted")

    method_cases = contract["method_contract_cases"]
    if not isinstance(method_cases, list) or len(method_cases) != 2:
        fail("invalid_contract", "method contract case count drifted")
    resolutions: set[str] = set()
    for case in method_cases:
        require_exact_fields(
            case,
            {
                "id",
                "bare",
                "parenthesized",
                "authored_args",
                "method_min_authored_arity",
                "method_max_authored_arity",
                "expected_resolution",
            },
            "method contract case",
        )
        if parse_receiver(case["bare"]) != parse_receiver(case["parenthesized"]):
            fail("invalid_contract", f"method resolution spellings drifted for {case['id']}")
        minimum = case["method_min_authored_arity"]
        maximum = case["method_max_authored_arity"]
        authored = case["authored_args"]
        accepted = minimum <= authored <= maximum
        expected = "accepted" if accepted else "same_rejection_as_parenthesized"
        if case["expected_resolution"] != expected:
            fail("invalid_contract", f"method resolution drifted for {case['id']}")
        resolutions.add(expected)
    if resolutions != {"accepted", "same_rejection_as_parenthesized"}:
        fail("invalid_contract", "method resolution coverage drifted")

    fixture = require_exact_fields(
        contract["future_fixture"], {"input", "model", "spec_source", "expected"}, "future fixture"
    )
    if fixture["input"] != "xx":
        fail("invalid_fixture", "future fixture input drifted")
    if fixture["spec_source"] != render_fixture(fixture["model"]):
        fail("invalid_fixture", "future fixture source is not the deterministic rendering")
    if fixture["expected"] != evaluate_fixture(fixture["model"]):
        fail("invalid_fixture", "future fixture expected value drifted")
    for marker in markers:
        if not re.search(rf"(?m)^\s*{re.escape(marker)}(?:\s|$)", fixture["spec_source"]):
            fail("invalid_fixture", f"future fixture does not exercise bare {marker}")
    for receiver in ("label.trim", "values.sorted().first", "values.count"):
        if receiver not in fixture["spec_source"]:
            fail("invalid_fixture", f"future fixture lacks receiver alias {receiver}")
    if "if false" in fixture["spec_source"] or "while false" in fixture["spec_source"]:
        fail("invalid_fixture", "future fixture introduced parenthesis-free condition headers")


def expect_failure(contract: dict[str, Any], mutation: str, expected_code: str) -> None:
    mutated = copy.deepcopy(contract)
    if mutation == "missing_next":
        mutated["syntax"]["standalone_markers"].remove("next")
    elif mutation == "receiver_anywhere":
        mutated["syntax"]["bare_receiver_position"] = "any"
    elif mutation == "fixture_header_drift":
        mutated["future_fixture"]["spec_source"] = mutated["future_fixture"]["spec_source"].replace(
            "if(false)", "if false", 1
        )
    else:
        fail("invalid_self_test", f"unknown mutation {mutation}")
    try:
        validate_contract(mutated)
    except ContractError as error:
        if error.code != expected_code:
            fail("invalid_self_test", f"mutation {mutation} returned {error.code}, expected {expected_code}")
        return
    fail("invalid_self_test", f"mutation {mutation} unexpectedly passed")


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(contract)
    expect_failure(contract, "missing_next", "invalid_contract")
    expect_failure(contract, "receiver_anywhere", "invalid_contract")
    expect_failure(contract, "fixture_header_drift", "invalid_fixture")
    print(
        "punctuation-light-zero-arg: OK "
        f"({len(contract['standalone_cases'])} standalone, "
        f"{len(contract['receiver_cases'])} receiver, "
        f"{len(contract['invalid_syntax_cases'])} invalid, future fixture exact)"
    )


if __name__ == "__main__":
    main()

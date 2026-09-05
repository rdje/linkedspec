#!/usr/bin/env python3
"""Validate the future neutral nested write-vivification contract.

This checker is deliberately backend-independent.  It parses only the owned
assignment surface, evaluates frozen typed segment/RHS observations, and runs
the neutral copy-on-write state machine.  It does not claim that any current
LinkedSpec backend has admitted the future behavior.
"""

from __future__ import annotations

import copy
import hashlib
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "write_vivification_contract.json"
COMPOSITION_PATH = (
    ROOT / "capability_conformance" / "write_map_leaves_composition_contract.json"
)
IDENTIFIER_SOURCE = r"[A-Za-z_][A-Za-z0-9_]*"
IDENTIFIER = re.compile(IDENTIFIER_SOURCE + r"\Z")
INTEGER = re.compile(r"-?(?:0|[1-9][0-9]*)\Z")
CALL = re.compile(rf"{IDENTIFIER_SOURCE}\s*\(.*\)\Z", re.S)
OPERATION = "nested_write_vivification"


class ContractError(ValueError):
    """A stable contract-validation failure."""

    def __init__(
        self,
        code: str,
        detail: str,
        *,
        source_span: dict[str, int] | None = None,
    ):
        super().__init__(detail)
        self.code = code
        self.source_span = source_span


def fail(
    code: str,
    detail: str,
    *,
    source_span: dict[str, int] | None = None,
) -> None:
    raise ContractError(code, detail, source_span=source_span)


def cloned(value: Any) -> Any:
    return copy.deepcopy(value)


def canonical_json_sha256(value: Any) -> str:
    encoded = json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


CANONICAL_POLICY = {
    "write_only": "only an authored assignment lvalue may request path creation; reads and other value observations never create state",
    "addressable_root": "the root is one bare non-reserved uniform-binding identifier, not a literal, temporary, helper result, nested receiver, property, rule, or runtime pseudo-binding",
    "root_creation": "an absent binding is created as the container selected by the first evaluated segment; a present null or other scalar is not absence",
    "intermediate_creation": "a missing nonfinal child is created as the container selected by the next evaluated segment",
    "segment_selection": "an evaluated string selects an harray key and an evaluated nonnegative integer selects a zero-based array index; spelling does not select the kind and a quoted numeric string remains a key",
    "invalid_segments": "boolean, null, negative integer, fractional number, array, harray, and codeblock segment values are invalid typed path selectors",
    "existing_values": "existing values are never coerced or overwritten to manufacture a required container kind",
    "dense_arrays": "an array write replaces an existing index or appends at exactly length; an index greater than length is a typed gap failure and no filler values are invented",
    "evaluation_order": "segment expressions evaluate left to right exactly once, then the RHS evaluates exactly once, then segment-kind and structural validation begin",
    "evaluation_failure": "an expression evaluation failure stops later evaluation and propagates its original diagnostic without a nested-write wrapper",
    "post_evaluation_snapshot": "the isolated structural write snapshots the root after segment and RHS evaluation, so completed same-binding expression side effects are visible and are not rolled back by a later structural failure",
    "atomic_commit": "validation and building mutate only an isolated root copy; structural success commits once while structural failure preserves the post-evaluation binding state",
    "result": "success returns a detached updated-root value; structural failure returns the typed diagnostic and no partial root",
    "detachment": "the committed binding, returned result, initial input tree, and aggregate RHS are mutually detached values rather than host-language aliases",
    "single_segment": "one-segment and multi-segment bracket assignments use the same neutral AST and runtime contract",
    "current_boundary": "this contract does not admit current backend behavior; Perl, Rust, Dart, Julia, and Lua remain non-vivifying until their separately owned implementation leaves",
}

CANONICAL_SYNTAX = {
    "identifier_pattern": IDENTIFIER_SOURCE,
    "assignment": "IDENTIFIER[SEGMENT]... = VALUE",
    "minimum_segments": 1,
    "segment": "one existing ActionIR value expression between balanced square brackets",
    "root": "one bare addressable uniform-binding identifier",
    "reserved_root_names": [
        "CAPTURE",
        "IINDEX",
        "IMATCH",
        "IMATCH_HASH",
        "IMATCH_LIST",
        "IPOS",
        "LINDEX",
        "LMATCH",
        "LMATCH_HASH",
        "LMATCH_LIST",
        "LSPOS",
        "STRING",
        "descr",
        "false",
        "info",
        "minfo",
        "null",
        "retv",
        "true",
        "undef",
    ],
    "insignificant_whitespace": "whitespace may surround the root, brackets, segment expressions, assignment token, and RHS without changing ownership or spans",
    "no_wrapper": "no vivify helper or alternate assignment token exists",
    "excluded_roots": [
        "literal",
        "temporary",
        "helper_result",
        "nested_access",
        "property",
        "rule",
        "runtime_pseudo_binding",
    ],
}

CANONICAL_AST = {
    "node_kind": "assign_nested_access",
    "fields": ["kind", "source", "source_span", "base", "segments", "value"],
    "base": "the bare binding identifier string",
    "segment_node_kind": "path_segment",
    "segment_fields": ["kind", "source", "source_span", "expression"],
    "segment_kind": "expression",
    "segment_semantics": "all segment expressions retain their ordinary typed ActionIR; no parser-time key/index tag decides runtime behavior",
    "value": "one ordinary typed ActionIR value expression",
    "source_span": "half-open Unicode-scalar offsets over authored source; the assignment span covers the complete lvalue and RHS while each segment span excludes its brackets",
    "one_segment_node": "assign_nested_access",
    "forbidden_authored_assignment_nodes": [
        "assign_hash_index",
        "host_lvalue",
        "indexed_var_assignment",
    ],
}

CANONICAL_DIAGNOSTICS = {
    "syntax": {
        "stage": "action_parse",
        "codes": [
            "nested_write_root_not_addressable",
            "nested_write_root_reserved",
            "nested_write_segment_empty",
            "nested_write_segment_unclosed",
            "nested_write_segment_expression_invalid",
        ],
        "fields": ["code", "stage", "source_span", "message"],
    },
    "invalid_segment": {
        "code": "nested_write_segment_invalid",
        "fields": [
            "code",
            "operation",
            "binding",
            "segment_index",
            "path",
            "actual_kind",
            "reason",
            "source_span",
            "message",
        ],
    },
    "kind_conflict": {
        "code": "nested_write_kind_conflict",
        "fields": [
            "code",
            "operation",
            "binding",
            "segment_index",
            "path",
            "expected_kind",
            "actual_kind",
            "source_span",
            "message",
        ],
    },
    "array_gap": {
        "code": "nested_write_array_gap",
        "fields": [
            "code",
            "operation",
            "binding",
            "segment_index",
            "path",
            "index",
            "length",
            "source_span",
            "message",
        ],
    },
    "operation": OPERATION,
    "path": "the detached evaluated valid-segment prefix before the failing segment",
    "source_span": "the authored offending segment expression span as a half-open Unicode-scalar typed span",
    "precedence": [
        "expression_evaluation_failure",
        "first_invalid_segment",
        "first_structural_kind_conflict_or_gap",
    ],
}

EXPECTED_IDS = {
    "valid_syntax_cases": {
        "single_quoted_key_uses_unified_node",
        "mixed_literal_path",
        "dynamic_segments_preserve_expressions",
        "quoted_numeric_string_is_expression",
        "unicode_scalar_ast_spans",
    },
    "invalid_syntax_cases": {
        "temporary_root",
        "literal_root",
        "empty_segment",
        "unclosed_segment",
        "invalid_segment_expression",
        "property_root",
        "reserved_root",
    },
    "excluded_syntax_cases": {
        "ordinary_scalar_assignment",
        "read_expression",
        "invented_wrapper",
        "invented_operator",
    },
    "success_cases": {
        "absent_harray_array_harray_chain",
        "absent_array_root",
        "dynamic_string_selects_harray",
        "dynamic_integer_selects_array",
        "quoted_numeric_string_selects_harray",
        "missing_intermediate_exact_append",
        "replace_existing_leaf",
        "final_exact_array_append",
        "empty_string_key",
        "rhs_same_binding_side_effect_composes",
        "segment_same_binding_side_effect_composes",
    },
    "failure_cases": {
        "boolean_segment",
        "negative_integer_segment",
        "fractional_segment",
        "null_segment",
        "array_segment",
        "harray_segment",
        "codeblock_segment",
        "bound_null_is_not_absent",
        "scalar_root_conflict",
        "harray_root_rejects_integer",
        "array_root_rejects_string",
        "intermediate_scalar_conflict",
        "final_array_gap",
        "intermediate_array_gap",
        "rhs_side_effect_survives_outer_gap",
        "unicode_scalar_diagnostic_span",
    },
    "evaluation_failure_cases": {
        "first_segment_failure_stops_rhs",
        "second_segment_failure_stops_rhs",
        "rhs_failure_preserves_original_diagnostic",
    },
    "read_exclusion_cases": {
        "absent_root_read",
        "missing_intermediate_read",
        "wrong_kind_read",
    },
}


def runtime_kind(value: Any) -> str:
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "number"
    if isinstance(value, str):
        return "string"
    if isinstance(value, list):
        return "array"
    if isinstance(value, dict) and set(value) == {"$codeblock"}:
        return "codeblock"
    if isinstance(value, dict):
        return "harray"
    fail("invalid_contract", f"unsupported neutral value kind {type(value).__name__}")


def expression_kind(source: str) -> str | None:
    text = source.strip()
    if re.fullmatch(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', text, re.S):
        return "string_literal"
    if INTEGER.fullmatch(text):
        return "integer_literal"
    if IDENTIFIER.fullmatch(text):
        return "identifier"
    if CALL.fullmatch(text) and balanced_expression(text):
        return "call"
    if not text or top_level_contains(text, ":"):
        return None
    return "expression"


def expression_node(source: str, start: int, end: int) -> dict[str, Any]:
    kind = expression_kind(source)
    if kind is None:
        fail(
            "nested_write_segment_expression_invalid",
            "segment must be one balanced ActionIR value expression",
            source_span={"start": start, "end": end},
        )
    return {
        "kind": kind,
        "source": source,
        "source_span": {"start": start, "end": end},
    }


def top_level_contains(source: str, needle: str) -> bool:
    stack: list[str] = []
    quote: str | None = None
    escaped = False
    pairs = {")": "(", "]": "[", "}": "{"}
    for char in source:
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
        elif char in "([{":
            stack.append(char)
        elif char in ")]}" and stack and stack[-1] == pairs[char]:
            stack.pop()
        elif char == needle and not stack:
            return True
    return False


def balanced_expression(source: str) -> bool:
    stack: list[str] = []
    quote: str | None = None
    escaped = False
    pairs = {")": "(", "]": "[", "}": "{"}
    for char in source:
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
        elif char in "([{":
            stack.append(char)
        elif char in ")]}":
            if not stack or stack.pop() != pairs[char]:
                return False
    return quote is None and not stack


def find_assignment(source: str) -> int | None:
    stack: list[str] = []
    quote: str | None = None
    escaped = False
    pairs = {")": "(", "]": "[", "}": "{"}
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
        elif char in "([{":
            stack.append(char)
        elif char in ")]}" and stack and stack[-1] == pairs[char]:
            stack.pop()
        elif char == "=" and not stack:
            return index
    fallback = source.rfind("=")
    return fallback if fallback >= 0 else None


def parse_assignment(source: str, reserved: set[str]) -> dict[str, Any]:
    equal = find_assignment(source)
    if equal is None:
        fail("nested_write_assignment_missing", "nested write requires one assignment token")
    left = source[:equal]
    right = source[equal + 1 :]
    rhs_text = right.strip()
    if not rhs_text:
        fail("nested_write_rhs_missing", "nested write requires one RHS expression")
    rhs_start = equal + 1 + len(right) - len(right.lstrip())
    rhs_end = equal + 1 + len(right.rstrip())

    offset = len(left) - len(left.lstrip())
    match = re.match(IDENTIFIER_SOURCE, left[offset:])
    if match is None:
        root_end = left.find("[")
        if root_end < 0:
            root_end = len(left.rstrip())
        fail(
            "nested_write_root_not_addressable",
            "nested write root must be a bare identifier",
            source_span={"start": offset, "end": max(offset + 1, root_end)},
        )
    base = match.group(0)
    cursor = offset + match.end()
    if base in reserved:
        fail(
            "nested_write_root_reserved",
            f"nested write root {base!r} is reserved",
            source_span={"start": offset, "end": cursor},
        )

    segments: list[dict[str, Any]] = []
    while True:
        while cursor < len(left) and left[cursor].isspace():
            cursor += 1
        if cursor >= len(left):
            break
        if left[cursor] != "[":
            root_end = left.find("[", cursor)
            if root_end < 0:
                root_end = len(left.rstrip())
            fail(
                "nested_write_root_not_addressable",
                "nested write root must remain a bare identifier",
                source_span={"start": offset, "end": root_end},
            )
        opening = cursor
        cursor += 1
        payload_start = cursor
        stack: list[str] = []
        quote: str | None = None
        escaped = False
        pairs = {")": "(", "]": "[", "}": "{"}
        close: int | None = None
        while cursor < len(left):
            char = left[cursor]
            if quote is not None:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == quote:
                    quote = None
                cursor += 1
                continue
            if char in {'"', "'"}:
                quote = char
            elif char in "([{":
                stack.append(char)
            elif char == "]" and not stack:
                close = cursor
                break
            elif char in ")]}":
                if not stack or stack.pop() != pairs[char]:
                    fail(
                        "nested_write_segment_expression_invalid",
                        "segment delimiters are unbalanced",
                        source_span={"start": payload_start, "end": cursor + 1},
                    )
            cursor += 1
        if close is None:
            fail(
                "nested_write_segment_unclosed",
                "nested write segment is missing its closing bracket",
                source_span={"start": opening, "end": len(left.rstrip())},
            )
        raw = left[payload_start:close]
        text = raw.strip()
        if not text:
            fail(
                "nested_write_segment_empty",
                "nested write segment may not be empty",
                source_span={"start": opening, "end": close + 1},
            )
        start = payload_start + len(raw) - len(raw.lstrip())
        end = payload_start + len(raw.rstrip())
        kind = expression_kind(text)
        if kind is None or not balanced_expression(text):
            fail(
                "nested_write_segment_expression_invalid",
                "segment must be one balanced ActionIR value expression",
                source_span={"start": start, "end": end},
            )
        segments.append(
            {
                "kind": "path_segment",
                "source": text,
                "source_span": {"start": start, "end": end},
                "expression": expression_node(text, start, end),
            }
        )
        cursor = close + 1
        if cursor <= opening:
            fail("invalid_contract", "segment parser made no progress")

    if not segments:
        fail("nested_write_root_not_addressable", "nested write requires at least one bracket segment")
    first = len(source) - len(source.lstrip())
    last = len(source.rstrip())
    return {
        "kind": "assign_nested_access",
        "source": source[first:last],
        "source_span": {"start": first, "end": last},
        "base": base,
        "segments": segments,
        "value": expression_node(rhs_text, rhs_start, rhs_end),
    }


def typed_span(case: dict[str, Any], parsed: dict[str, Any], index: int) -> dict[str, Any]:
    span = parsed["segments"][index]["source_span"]
    return {
        "source_id": f"contract:{case['id']}",
        "start": span["start"],
        "end": span["end"],
        "unit": "unicode_scalar",
        "provenance": "authored",
    }


def syntax_diagnostic(case: dict[str, Any], error: ContractError) -> dict[str, Any]:
    if error.source_span is None:
        fail("invalid_contract", f"syntax case {case['id']} has no source span")
    return {
        "code": error.code,
        "stage": "action_parse",
        "source_span": {
            "source_id": f"contract:{case['id']}",
            **error.source_span,
            "unit": "unicode_scalar",
            "provenance": "authored",
        },
        "message": str(error),
    }


def selector(segment: dict[str, Any]) -> tuple[str | None, Any, str | None]:
    kind = segment.get("kind")
    value = segment.get("value")
    if kind == "string" and isinstance(value, str):
        return "harray", value, None
    if kind == "integer" and isinstance(value, int) and not isinstance(value, bool):
        if value < 0:
            return None, value, "negative_integer"
        return "array", value, None
    if kind == "number" and isinstance(value, (int, float)) and not isinstance(value, bool):
        return None, value, "fractional_number"
    if kind in {"boolean", "null", "array", "harray", "codeblock"}:
        return None, value, "kind_not_path_selector"
    fail("invalid_contract", f"segment carries inconsistent kind/value {kind!r}/{value!r}")


def require_fields(value: dict[str, Any], expected: set[str], label: str) -> None:
    if set(value) != expected:
        fail("invalid_contract", f"{label} fields drifted")


def validate_evaluation_error(value: Any, label: str) -> None:
    if not isinstance(value, dict) or set(value) != {"code", "message"}:
        fail("invalid_contract", f"{label} evaluation error fields drifted")
    if not isinstance(value["code"], str) or not isinstance(value["message"], str):
        fail("invalid_contract", f"{label} evaluation error values drifted")


def validate_segment_observation(observation: dict[str, Any], label: str) -> None:
    if "evaluation_error" in observation:
        require_fields(observation, {"source", "evaluation_error"}, label)
        validate_evaluation_error(observation["evaluation_error"], label)
        return
    expected = {"source", "kind", "value"}
    if "same_binding_after" in observation:
        expected.add("same_binding_after")
    require_fields(observation, expected, label)
    selector(observation)
    source = observation["source"].strip()
    if source.startswith('"') and source.endswith('"'):
        try:
            literal = json.loads(source)
        except json.JSONDecodeError:
            fail("invalid_contract", f"{label} string literal is invalid")
        if observation["kind"] != "string" or observation["value"] != literal:
            fail("invalid_contract", f"{label} string literal observation drifted")
    elif INTEGER.fullmatch(source):
        if observation["kind"] != "integer" or observation["value"] != int(source):
            fail("invalid_contract", f"{label} integer literal observation drifted")
    elif source in {"true", "false"}:
        expected_value = source == "true"
        if observation["kind"] != "boolean" or observation["value"] is not expected_value:
            fail("invalid_contract", f"{label} boolean literal observation drifted")
    elif source == "null" and (observation["kind"] != "null" or observation["value"] is not None):
        fail("invalid_contract", f"{label} null literal observation drifted")


def validate_rhs_observation(observation: dict[str, Any], label: str) -> None:
    if "evaluation_error" in observation:
        require_fields(observation, {"source", "evaluation_error"}, label)
        validate_evaluation_error(observation["evaluation_error"], label)
        return
    expected = {"source", "value"}
    if "same_binding_after" in observation:
        expected.add("same_binding_after")
    require_fields(observation, expected, label)


def state_from(value: dict[str, Any]) -> dict[str, Any]:
    if set(value) == {"present"} and value.get("present") is False:
        return {"present": False}
    if set(value) == {"present", "value"} and value.get("present") is True:
        return {"present": True, "value": cloned(value.get("value"))}
    fail("invalid_contract", "binding state must distinguish exact absent versus present value")


def apply_same_binding(state: dict[str, Any], observation: dict[str, Any]) -> None:
    if "same_binding_after" in observation:
        state.clear()
        state.update({"present": True, "value": cloned(observation["same_binding_after"])})


def invalid_diagnostic(
    case: dict[str, Any],
    parsed: dict[str, Any],
    index: int,
    path: list[Any],
    kind: str,
    reason: str,
) -> dict[str, Any]:
    return {
        "code": "nested_write_segment_invalid",
        "operation": OPERATION,
        "binding": case["binding"],
        "segment_index": index,
        "path": cloned(path),
        "actual_kind": kind,
        "reason": reason,
        "source_span": typed_span(case, parsed, index),
        "message": (
            f"nested write segment {index} for binding '{case['binding']}' must evaluate to a string "
            f"or nonnegative integer; got {kind} ({reason})"
        ),
    }


def conflict_diagnostic(
    case: dict[str, Any],
    parsed: dict[str, Any],
    index: int,
    path: list[Any],
    expected: str,
    actual: str,
) -> dict[str, Any]:
    return {
        "code": "nested_write_kind_conflict",
        "operation": OPERATION,
        "binding": case["binding"],
        "segment_index": index,
        "path": cloned(path),
        "expected_kind": expected,
        "actual_kind": actual,
        "source_span": typed_span(case, parsed, index),
        "message": (
            f"nested write segment {index} for binding '{case['binding']}' requires {expected}; "
            f"found {actual}"
        ),
    }


def gap_diagnostic(
    case: dict[str, Any],
    parsed: dict[str, Any],
    index: int,
    path: list[Any],
    array_index: int,
    length: int,
) -> dict[str, Any]:
    return {
        "code": "nested_write_array_gap",
        "operation": OPERATION,
        "binding": case["binding"],
        "segment_index": index,
        "path": cloned(path),
        "index": array_index,
        "length": length,
        "source_span": typed_span(case, parsed, index),
        "message": (
            f"nested write segment {index} for binding '{case['binding']}' cannot create array "
            f"index {array_index} at length {length}"
        ),
    }


def validate_case_source(case: dict[str, Any], reserved: set[str]) -> dict[str, Any]:
    parsed = parse_assignment(case.get("source", ""), reserved)
    if parsed["base"] != case.get("binding"):
        fail("invalid_contract", f"case {case.get('id')} source/binding drifted")
    observations = case.get("segments")
    if not isinstance(observations, list) or len(observations) != len(parsed["segments"]):
        fail("invalid_contract", f"case {case.get('id')} source/segment count drifted")
    for index, observation in enumerate(observations):
        validate_segment_observation(observation, f"case {case.get('id')} segment {index}")
        if observation.get("source") != parsed["segments"][index]["source"]:
            fail("invalid_contract", f"case {case.get('id')} segment {index} source drifted")
    rhs = case.get("rhs")
    if not isinstance(rhs, dict):
        fail("invalid_contract", f"case {case.get('id')} RHS must be an object")
    validate_rhs_observation(rhs, f"case {case.get('id')} RHS")
    if rhs.get("source") != parsed["value"]["source"]:
        fail("invalid_contract", f"case {case.get('id')} RHS source drifted")
    return parsed


def execute_write(
    case: dict[str, Any], reserved: set[str]
) -> tuple[dict[str, Any], Any, dict[str, Any] | None, list[str]]:
    parsed = validate_case_source(case, reserved)
    state = state_from(case["initial_binding"])
    effects: list[str] = []

    for index, observation in enumerate(case["segments"]):
        effects.append(f"segment:{index}")
        if "evaluation_error" in observation:
            return state, None, cloned(observation["evaluation_error"]), effects
        selector(observation)
        apply_same_binding(state, observation)

    rhs = case["rhs"]
    effects.append("rhs")
    if "evaluation_error" in rhs:
        return state, None, cloned(rhs["evaluation_error"]), effects
    apply_same_binding(state, rhs)

    selectors: list[tuple[str, Any]] = []
    path_values: list[Any] = []
    for index, observation in enumerate(case["segments"]):
        expected, key, reason = selector(observation)
        if reason is not None:
            return (
                state,
                None,
                invalid_diagnostic(case, parsed, index, path_values, observation["kind"], reason),
                effects,
            )
        selectors.append((expected or "", cloned(key)))
        path_values.append(cloned(key))

    if not state["present"]:
        work: Any = [] if selectors[0][0] == "array" else {}
    else:
        work = cloned(state["value"])
    cursor = work
    prefix: list[Any] = []
    rhs_value = cloned(rhs.get("value"))

    for index, (expected, key) in enumerate(selectors):
        actual = runtime_kind(cursor)
        if actual != expected:
            return state, None, conflict_diagnostic(case, parsed, index, prefix, expected, actual), effects
        last = index == len(selectors) - 1
        if expected == "harray":
            if last:
                cursor[key] = cloned(rhs_value)
            else:
                if key not in cursor:
                    cursor[key] = [] if selectors[index + 1][0] == "array" else {}
                cursor = cursor[key]
        else:
            if key > len(cursor):
                return state, None, gap_diagnostic(case, parsed, index, prefix, key, len(cursor)), effects
            if last:
                if key == len(cursor):
                    cursor.append(cloned(rhs_value))
                else:
                    cursor[key] = cloned(rhs_value)
            else:
                if key == len(cursor):
                    cursor.append([] if selectors[index + 1][0] == "array" else {})
                cursor = cursor[key]
        prefix.append(cloned(key))

    committed = cloned(work)
    return {"present": True, "value": committed}, cloned(work), None, effects


def resolve_expected_error(case: dict[str, Any], parsed: dict[str, Any]) -> dict[str, Any]:
    expected = case["expected_error"]
    code = expected.get("code")
    index = expected.get("segment_index")
    target = expected.get("source_target")
    if target != f"segment:{index}":
        fail("invalid_contract", f"case {case['id']} diagnostic source target drifted")
    if code == "nested_write_segment_invalid":
        return invalid_diagnostic(
            case,
            parsed,
            index,
            expected["path"],
            expected["actual_kind"],
            expected["reason"],
        )
    if code == "nested_write_kind_conflict":
        return conflict_diagnostic(
            case,
            parsed,
            index,
            expected["path"],
            expected["expected_kind"],
            expected["actual_kind"],
        )
    if code == "nested_write_array_gap":
        return gap_diagnostic(
            case,
            parsed,
            index,
            expected["path"],
            expected["index"],
            expected["length"],
        )
    fail("invalid_contract", f"case {case['id']} uses unknown structural diagnostic")


def read_path(initial: dict[str, Any], segments: list[dict[str, Any]]) -> tuple[dict[str, Any], Any]:
    state = state_from(initial)
    if not state["present"]:
        return state, None
    cursor = state["value"]
    for segment in segments:
        expected, key, reason = selector(segment)
        if reason is not None or runtime_kind(cursor) != expected:
            return state, None
        if expected == "harray":
            if key not in cursor:
                return state, None
            cursor = cursor[key]
        else:
            if key >= len(cursor):
                return state, None
            cursor = cursor[key]
    return state, cloned(cursor)


def set_path(root: Any, path: list[Any], value: Any) -> None:
    cursor = root
    for segment in path[:-1]:
        cursor = cursor[segment]
    cursor[path[-1]] = cloned(value)


def validate_id_set(contract: dict[str, Any], field: str) -> None:
    cases = contract.get(field)
    if not isinstance(cases, list):
        fail("invalid_contract", f"{field} must be an array")
    ids = [case.get("id") for case in cases if isinstance(case, dict)]
    if len(ids) != len(cases) or len(ids) != len(set(ids)) or set(ids) != EXPECTED_IDS[field]:
        fail("invalid_contract", f"{field} ids drifted")


def validate_contract(contract: dict[str, Any]) -> None:
    expected_top = {
        "format",
        "contract_id",
        "status",
        "policy",
        "syntax",
        "ast",
        "diagnostics",
        "valid_syntax_cases",
        "invalid_syntax_cases",
        "excluded_syntax_cases",
        "success_cases",
        "failure_cases",
        "evaluation_failure_cases",
        "read_exclusion_cases",
        "detachment_case",
    }
    if set(contract) != expected_top:
        fail("invalid_contract", "top-level fields drifted")
    if contract.get("format") != 1 or contract.get("contract_id") != "linkedspec-write-vivification-v1":
        fail("invalid_contract", "format or contract id drifted")
    if contract.get("status") != "future-neutral-contract; no backend behavior admitted":
        fail("invalid_contract", "future-only status drifted")
    if contract.get("policy") != CANONICAL_POLICY:
        fail("invalid_contract", "policy drifted")
    if contract.get("syntax") != CANONICAL_SYNTAX:
        fail("invalid_contract", "syntax drifted")
    if contract.get("ast") != CANONICAL_AST:
        fail("invalid_contract", "AST contract drifted")
    if contract.get("diagnostics") != CANONICAL_DIAGNOSTICS:
        fail("invalid_contract", "diagnostic catalog drifted")

    for field in EXPECTED_IDS:
        validate_id_set(contract, field)
    reserved = set(contract["syntax"]["reserved_root_names"])

    for case in contract["valid_syntax_cases"]:
        if set(case) != {"id", "source", "expected_ast"}:
            fail("invalid_contract", f"valid syntax case {case.get('id')} fields drifted")
        parsed = parse_assignment(case["source"], reserved)
        if parsed != case["expected_ast"]:
            fail("invalid_contract", f"valid syntax case {case['id']} AST drifted")

    for case in contract["invalid_syntax_cases"]:
        if set(case) != {"id", "source", "diagnostic"}:
            fail("invalid_contract", f"invalid syntax case {case.get('id')} fields drifted")
        try:
            parse_assignment(case["source"], reserved)
        except ContractError as exc:
            if syntax_diagnostic(case, exc) != case["diagnostic"]:
                fail("invalid_contract", f"invalid syntax case {case['id']} diagnostic drifted")
        else:
            fail("invalid_contract", f"invalid syntax case {case['id']} was accepted")

    exact_exclusions = {
        "ordinary_scalar_assignment": ("document = value", "not_nested_write"),
        "read_expression": ('document["x"]', "read_only"),
        "invented_wrapper": ('vivify(document, "x", value)', "unsupported_helper"),
        "invented_operator": ('document["x"] := value', "unsupported_operator"),
    }
    for case in contract["excluded_syntax_cases"]:
        if set(case) != {"id", "source", "classification"}:
            fail("invalid_contract", f"excluded syntax case {case.get('id')} fields drifted")
        if (case["source"], case["classification"]) != exact_exclusions[case["id"]]:
            fail("invalid_contract", f"excluded syntax case {case['id']} drifted")

    for case in contract["success_cases"]:
        require_fields(
            case,
            {
                "id",
                "source",
                "binding",
                "initial_binding",
                "segments",
                "rhs",
                "expected_effects",
                "expected_binding",
                "expected_result",
            },
            f"success case {case.get('id')}",
        )
        parsed = validate_case_source(case, reserved)
        state, result, error, effects = execute_write(case, reserved)
        if error is not None:
            fail("invalid_contract", f"success case {case['id']} produced {error.get('code')}")
        if effects != case.get("expected_effects"):
            fail("invalid_contract", f"success case {case['id']} evaluation order drifted")
        if state != {"present": True, "value": case.get("expected_binding")}:
            fail("invalid_contract", f"success case {case['id']} binding drifted")
        if result != case.get("expected_result"):
            fail("invalid_contract", f"success case {case['id']} result drifted")
        if parsed["source_span"]["end"] != len(case["source"]):
            fail("invalid_contract", f"success case {case['id']} authored span drifted")

    for case in contract["failure_cases"]:
        require_fields(
            case,
            {
                "id",
                "source",
                "binding",
                "initial_binding",
                "segments",
                "rhs",
                "expected_effects",
                "expected_binding",
                "expected_error",
            },
            f"failure case {case.get('id')}",
        )
        parsed = validate_case_source(case, reserved)
        state, result, error, effects = execute_write(case, reserved)
        if result is not None or error is None:
            fail("invalid_contract", f"failure case {case['id']} did not fail atomically")
        if effects != case.get("expected_effects"):
            fail("invalid_contract", f"failure case {case['id']} evaluation order drifted")
        if state != case.get("expected_binding"):
            fail("invalid_contract", f"failure case {case['id']} binding drifted")
        expected_error = resolve_expected_error(case, parsed)
        if error != expected_error:
            fail("invalid_contract", f"failure case {case['id']} diagnostic drifted")

    for case in contract["evaluation_failure_cases"]:
        require_fields(
            case,
            {
                "id",
                "source",
                "binding",
                "initial_binding",
                "segments",
                "rhs",
                "expected_effects",
                "expected_binding",
                "expected_error",
            },
            f"evaluation failure case {case.get('id')}",
        )
        state, result, error, effects = execute_write(case, reserved)
        if result is not None or error != case.get("expected_error"):
            fail("invalid_contract", f"evaluation failure case {case['id']} wrapped or changed its diagnostic")
        if effects != case.get("expected_effects"):
            fail("invalid_contract", f"evaluation failure case {case['id']} continuation drifted")
        if state != case.get("expected_binding"):
            fail("invalid_contract", f"evaluation failure case {case['id']} binding drifted")

    for case in contract["read_exclusion_cases"]:
        require_fields(
            case,
            {"id", "initial_binding", "segments", "expected_binding", "expected_result"},
            f"read exclusion case {case.get('id')}",
        )
        for index, segment in enumerate(case["segments"]):
            require_fields(segment, {"kind", "value"}, f"read case {case['id']} segment {index}")
            selector(segment)
        state, result = read_path(case["initial_binding"], case["segments"])
        if state != case.get("expected_binding") or result != case.get("expected_result"):
            fail("invalid_contract", f"read exclusion case {case['id']} created or changed state")

    detachment = contract["detachment_case"]
    require_fields(
        detachment,
        {
            "id",
            "source",
            "binding",
            "initial_binding",
            "segments",
            "rhs",
            "mutations",
            "expected",
        },
        "detachment case",
    )
    if detachment.get("id") != "binding_result_initial_and_rhs_are_detached":
        fail("invalid_contract", "detachment case id drifted")
    if set(detachment.get("expected", {})) != {"initial", "rhs", "binding", "result"}:
        fail("invalid_contract", "detachment expected fields drifted")
    for index, mutation in enumerate(detachment.get("mutations", [])):
        require_fields(mutation, {"target", "path", "value"}, f"detachment mutation {index}")
        if mutation["target"] not in {"initial", "rhs", "binding", "result"}:
            fail("invalid_contract", f"detachment mutation {index} target drifted")
        if not isinstance(mutation["path"], list) or not mutation["path"]:
            fail("invalid_contract", f"detachment mutation {index} path drifted")
    initial = cloned(detachment["initial_binding"]["value"])
    rhs = cloned(detachment["rhs"]["value"])
    executable = cloned(detachment)
    executable["initial_binding"]["value"] = initial
    executable["rhs"]["value"] = rhs
    state, result, error, _effects = execute_write(executable, reserved)
    if error is not None or not state["present"]:
        fail("invalid_contract", "detachment setup did not succeed")
    binding = state["value"]
    if binding is result or binding is initial or result is initial:
        fail("invalid_contract", "root values alias before detachment probes")
    for mutation in detachment["mutations"]:
        targets = {"initial": initial, "rhs": rhs, "binding": binding, "result": result}
        set_path(targets[mutation["target"]], mutation["path"], mutation["value"])
    observed = {"initial": initial, "rhs": rhs, "binding": binding, "result": result}
    if observed != detachment.get("expected"):
        fail("invalid_contract", "detachment probes observed host aliasing or expectation drift")


def mutated_contracts(contract: dict[str, Any]) -> list[tuple[str, dict[str, Any]]]:
    mutations: list[tuple[str, dict[str, Any]]] = []

    def add(name: str, edit: Any) -> None:
        candidate = cloned(contract)
        edit(candidate)
        mutations.append((name, candidate))

    add("format", lambda value: value.__setitem__("format", 2))
    add("contract_id", lambda value: value.__setitem__("contract_id", "drift"))
    add("status", lambda value: value.__setitem__("status", "admitted"))
    add("unknown_top", lambda value: value.__setitem__("unknown", True))
    for key in CANONICAL_POLICY:
        add(f"policy:{key}", lambda value, key=key: value["policy"].__setitem__(key, "drift"))
    for key in CANONICAL_SYNTAX:
        def mutate_syntax(value: dict[str, Any], key: str = key) -> None:
            current = value["syntax"][key]
            value["syntax"][key] = [*current, "drift"] if isinstance(current, list) else "drift"

        add(f"syntax:{key}", mutate_syntax)
    for key in CANONICAL_AST:
        def mutate_ast(value: dict[str, Any], key: str = key) -> None:
            current = value["ast"][key]
            value["ast"][key] = [*current, "drift"] if isinstance(current, list) else "drift"

        add(f"ast:{key}", mutate_ast)
    add(
        "diagnostic_code",
        lambda value: value["diagnostics"]["invalid_segment"].__setitem__("code", "drift"),
    )
    add(
        "diagnostic_fields",
        lambda value: value["diagnostics"]["kind_conflict"]["fields"].append("drift"),
    )
    add("diagnostic_precedence", lambda value: value["diagnostics"]["precedence"].reverse())

    for field in EXPECTED_IDS:
        for case_id in EXPECTED_IDS[field]:
            add(
                f"remove:{field}:{case_id}",
                lambda value, field=field, case_id=case_id: value[field].__setitem__(
                    slice(None), [case for case in value[field] if case["id"] != case_id]
                ),
            )

    add(
        "valid_ast",
        lambda value: value["valid_syntax_cases"][0]["expected_ast"].__setitem__("kind", "drift"),
    )
    add(
        "invalid_syntax_span",
        lambda value: value["invalid_syntax_cases"][0]["diagnostic"]["source_span"].__setitem__(
            "end", 0
        ),
    )
    add(
        "success_result",
        lambda value: value["success_cases"][0].__setitem__("expected_result", "drift"),
    )
    add(
        "success_order",
        lambda value: value["success_cases"][0]["expected_effects"].reverse(),
    )
    add(
        "failure_error",
        lambda value: value["failure_cases"][0]["expected_error"].__setitem__("actual_kind", "drift"),
    )
    add(
        "evaluation_error",
        lambda value: value["evaluation_failure_cases"][0]["expected_error"].__setitem__("code", "drift"),
    )
    add(
        "read_result",
        lambda value: value["read_exclusion_cases"][0].__setitem__("expected_result", "created"),
    )
    add(
        "detachment_result",
        lambda value: value["detachment_case"]["expected"].__setitem__("result", "drift"),
    )
    add(
        "duplicate_success_id",
        lambda value: value["success_cases"][1].__setitem__("id", value["success_cases"][0]["id"]),
    )
    add("success_unknown_field", lambda value: value["success_cases"][0].__setitem__("unknown", True))
    add(
        "segment_unknown_field",
        lambda value: value["success_cases"][0]["segments"][0].__setitem__("unknown", True),
    )
    add(
        "rhs_unknown_field",
        lambda value: value["success_cases"][0]["rhs"].__setitem__("unknown", True),
    )
    add(
        "detachment_unknown_field",
        lambda value: value["detachment_case"].__setitem__("unknown", True),
    )
    return mutations


def composition_source_holder(
    case: dict[str, Any], action: dict[str, Any]
) -> tuple[str, str]:
    container = action.get("container")
    if container == "callback":
        source_id = f"contract:{case['id']}"
        holder = case.get("source")
    elif container == "continuation:with":
        source_id = f"contract:{case['id']}"
        holder = case.get("source")
    elif isinstance(container, str) and container.startswith("helper:"):
        helper = container.removeprefix("helper:")
        helpers = case.get("helper_sources")
        if not isinstance(helpers, dict) or not all(
            isinstance(key, str) and isinstance(value, str)
            for key, value in helpers.items()
        ):
            fail("invalid_composition_contract", f"case {case.get('id')} helper sources drifted")
        if helper not in helpers:
            fail("invalid_composition_contract", f"case {case.get('id')} helper {helper!r} is missing")
        source_id = f"contract:{case['id']}:helper:{helper}"
        holder = helpers[helper]
    else:
        fail("invalid_composition_contract", f"case {case.get('id')} write container drifted")
    if not isinstance(holder, str) or not holder:
        fail("invalid_composition_contract", f"case {case.get('id')} source holder is invalid")
    source = action.get("source")
    if not isinstance(source, str) or not source or holder.count(source) != 1:
        fail(
            "invalid_composition_contract",
            f"case {case.get('id')} write source must occur exactly once in {container}",
        )
    return source_id, holder


def _validate_composed_write(
    case: dict[str, Any],
    action: dict[str, Any],
    reserved: set[str],
) -> None:
    if not isinstance(action, dict):
        fail("invalid_composition_contract", f"case {case.get('id')} write must be an object")
    source_id, holder = composition_source_holder(case, action)
    target = action.get("target")
    if not isinstance(target, dict):
        fail("invalid_composition_contract", f"case {case.get('id')} target must be an object")
    target_fields = {"storage", "name", "identity"}
    if "initialize_from" in target:
        target_fields.add("initialize_from")
    require_fields(target, target_fields, f"case {case.get('id')} target")
    if target["storage"] not in {"binding", "callback_value", "local"}:
        fail("invalid_composition_contract", f"case {case.get('id')} target storage drifted")
    if not isinstance(target["name"], str) or not IDENTIFIER.fullmatch(target["name"]):
        fail("invalid_composition_contract", f"case {case.get('id')} target name drifted")
    if not isinstance(target["identity"], str) or not target["identity"]:
        fail("invalid_composition_contract", f"case {case.get('id')} target identity drifted")
    if target.get("initialize_from") not in {None, "callback_value"}:
        fail("invalid_composition_contract", f"case {case.get('id')} local initializer drifted")

    guarded = action.get("execution") == "guarded_before_evaluation"
    expected_fields = {
        "container",
        "target",
        "source",
        "segments",
        "rhs",
        "expected_initial_binding",
    }
    if guarded:
        expected_fields |= {"execution", "attempt_span"}
    else:
        expected_fields |= {"expected_effects", "expected_binding"}
        expected_fields.add("expected_error" if "expected_error" in action else "expected_result")
    require_fields(action, expected_fields, f"case {case.get('id')} write")

    synthetic = {
        "id": f"{case['id']}:{action['container']}",
        "source": action["source"],
        "binding": target["name"],
        "initial_binding": action["expected_initial_binding"],
        "segments": action["segments"],
        "rhs": action["rhs"],
    }
    parsed = validate_case_source(synthetic, reserved)
    offset = holder.index(action["source"])
    if parsed["source_span"]["end"] + offset > len(holder):
        fail("invalid_composition_contract", f"case {case.get('id')} write span escapes holder")

    if guarded:
        attempt_span = action["attempt_span"]
        if not isinstance(attempt_span, dict) or set(attempt_span) != {
            "source_id",
            "start",
            "end",
            "unit",
            "provenance",
        }:
            fail("invalid_composition_contract", f"case {case.get('id')} attempt span drifted")
        if (
            attempt_span["source_id"] != source_id
            or attempt_span["unit"] != "unicode_scalar"
            or attempt_span["provenance"] != "authored"
            or holder[attempt_span["start"] : attempt_span["end"]] != target["name"]
        ):
            fail("invalid_composition_contract", f"case {case.get('id')} guarded target span drifted")
        return

    state, result, error, effects = execute_write(synthetic, reserved)
    if effects != action["expected_effects"]:
        fail("invalid_composition_contract", f"case {case.get('id')} write effects drifted")
    if state != action["expected_binding"]:
        fail("invalid_composition_contract", f"case {case.get('id')} write binding drifted")
    if "expected_result" in action:
        if error is not None or result != action["expected_result"]:
            fail("invalid_composition_contract", f"case {case.get('id')} write result drifted")
    else:
        synthetic["expected_error"] = action["expected_error"]
        expected_error = resolve_expected_error(synthetic, parsed)
        if result is not None or error != expected_error:
            fail("invalid_composition_contract", f"case {case.get('id')} write diagnostic drifted")


def validate_composition_write_surfaces(
    composition: dict[str, Any], write_contract: dict[str, Any]
) -> int:
    if not isinstance(composition, dict):
        fail("invalid_composition_contract", "composition root must be an object")
    required = composition.get("requires", {}).get("write_vivification")
    if required != {
        "contract_id": "linkedspec-write-vivification-v1",
        "path": "capability_conformance/write_vivification_contract.json",
        "canonical_json_sha256": canonical_json_sha256(write_contract),
    }:
        fail("invalid_composition_contract", "write-vivification reference drifted")
    callback_cases = composition.get("callback_cases")
    continuation_cases = composition.get("continuation_cases")
    if not isinstance(callback_cases, list) or not isinstance(continuation_cases, list):
        fail("invalid_composition_contract", "composition cases must be arrays")
    case_ids = [case.get("id") for case in [*callback_cases, *continuation_cases] if isinstance(case, dict)]
    if len(case_ids) != len(callback_cases) + len(continuation_cases) or len(case_ids) != len(set(case_ids)):
        fail("invalid_composition_contract", "composition case ids must be present and unique")

    reserved = set(write_contract["syntax"]["reserved_root_names"])
    count = 0
    for case in callback_cases:
        if not isinstance(case.get("callback_steps"), list):
            fail("invalid_composition_contract", f"case {case.get('id')} callback steps drifted")
        for step in case["callback_steps"]:
            if not isinstance(step, dict):
                fail("invalid_composition_contract", f"case {case.get('id')} callback step drifted")
            if "write" in step:
                _validate_composed_write(case, step["write"], reserved)
                count += 1
    for case in continuation_cases:
        continuation = case.get("continuation")
        if not isinstance(continuation, dict) or "write" not in continuation:
            fail("invalid_composition_contract", f"case {case.get('id')} continuation write drifted")
        _validate_composed_write(case, continuation["write"], reserved)
        count += 1
    if count != 8:
        fail("invalid_composition_contract", f"expected 8 composed writes, got {count}")
    return count


def load_composition_contract() -> dict[str, Any]:
    with COMPOSITION_PATH.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        fail("invalid_composition_contract", "composition root must be an object")
    return value


def load_contract() -> dict[str, Any]:
    with CONTRACT_PATH.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        fail("invalid_contract", "contract root must be an object")
    return value


def main() -> None:
    contract = load_contract()
    validate_contract(contract)
    composition = load_composition_contract()
    composed_writes = validate_composition_write_surfaces(composition, contract)
    mutations = mutated_contracts(contract)
    for name, candidate in mutations:
        try:
            validate_contract(candidate)
        except ContractError:
            continue
        fail("mutation_survived", f"contract mutation survived: {name}")
    print(
        "write-vivification contract: "
        f"{len(contract['valid_syntax_cases'])} valid syntax, "
        f"{len(contract['invalid_syntax_cases'])} invalid syntax, "
        f"{len(contract['success_cases'])} success, "
        f"{len(contract['failure_cases'])} structural failures, "
        f"{len(contract['evaluation_failure_cases'])} evaluation failures, "
        f"{len(contract['read_exclusion_cases'])} read exclusions, "
        f"{composed_writes} composed writes, "
        f"{len(mutations)} rejected mutations; neutral authority remains frozen; capability admission is external"
    )


if __name__ == "__main__":
    main()

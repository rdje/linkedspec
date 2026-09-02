#!/usr/bin/env python3
"""Validate the future neutral ``map_leaves!`` receiver-mutation contract.

The checker is deliberately backend-independent.  It parses only the owned
bang-method surface, executes frozen callback observations over detached value
trees, and enforces the receiver guard/commit/continuation state machine.  It
does not claim that any current LinkedSpec backend admits the syntax.
"""

from __future__ import annotations

import copy
import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable

import check_write_vivification_contract as write_vivification


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "map_leaves_mutation_contract.json"
WRITE_CONTRACT_PATH = ROOT / "capability_conformance" / "write_vivification_contract.json"
COMPOSITION_PATH = (
    ROOT / "capability_conformance" / "write_map_leaves_composition_contract.json"
)
IDENTIFIER_SOURCE = r"[A-Za-z_][A-Za-z0-9_]*"
IDENTIFIER = re.compile(rf"{IDENTIFIER_SOURCE}\Z")
OPERATION = "map_leaves_mutation"
METHOD = "map_leaves"
RESERVED_RECEIVER_NAMES = frozenset(
    {
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
    }
)


EXPECTED_TOP_LEVEL_KEYS = {
    "ast",
    "continuation_failure_case",
    "contract_id",
    "detachment_case",
    "diagnostics",
    "excluded_syntax_cases",
    "failure_cases",
    "format",
    "guard_release_case",
    "invalid_syntax_cases",
    "nonbang_isolation_case",
    "policy",
    "shadow_binding_case",
    "status",
    "success_cases",
    "syntax",
    "valid_syntax_cases",
}

# This digest freezes every policy/syntax/AST/diagnostic byte as canonical JSON.
# Runtime behavior is checked independently below rather than trusted from it.
EXPECTED_SEMANTIC_DIGEST = "3b2f4b30b1fb8777f32a3df0ee16f56e860cb49c36bfae4d9d3012aa51b260f5"
EXPECTED_COMPOSITION_DIGEST = "a7d20c825cb3d8362d6f278586b6bb65c215e4a84ba64f5bb15bd10b1b82ba2f"

EXPECTED_IDS = {
    "valid_syntax_cases": {
        "bare_receiver_no_continuation",
        "array_count_continuation",
        "insignificant_whitespace",
        "nested_callback_braces",
    },
    "invalid_syntax_cases": {
        "function_form",
        "literal_receiver",
        "helper_result_receiver",
        "nested_receiver",
        "property_receiver",
        "reserved_receiver",
        "walk_bang",
        "reduce_bang",
        "arbitrary_bang",
        "separated_suffix",
        "double_bang",
        "arguments_not_empty",
        "callback_missing",
        "bang_continuation",
    },
    "excluded_syntax_cases": {
        "nonbang_twin",
        "walk_nonbang",
        "reduce_nonbang",
        "bang_word_alias",
        "bang_variable",
    },
    "success_cases": {
        "hash_sorted_frames_and_cross_kind_leaf",
        "array_index_frames_and_cross_kind_leaf",
        "replacement_root_kind_not_revisited",
        "callback_path_and_value_are_copied",
        "unrelated_side_effects_persist",
        "unrelated_receiver_mutation_allowed",
        "empty_hash_commits_without_callback",
        "empty_array_commits_without_callback",
        "hash_continuation_runs_after_commit",
        "array_continuation_runs_after_commit",
    },
    "failure_cases": {
        "receiver_absent",
        "receiver_null",
        "receiver_scalar",
        "callback_failure_is_atomic",
        "direct_assignment_reentrant",
        "nested_bang_reentrant",
        "nested_write_reentrant",
        "helper_mediated_reentrant",
    },
}

EXPECTED_SPECIAL_IDS = {
    "continuation_failure_case": "continuation_failure_preserves_commit",
    "shadow_binding_case": "same_spelling_shadow_is_distinct_identity",
    "guard_release_case": "guard_releases_after_failure",
    "nonbang_isolation_case": "nonbang_callback_cannot_mutate_receiver_by_alias",
    "detachment_case": "all_aggregate_boundaries_are_detached",
}

EXPECTED_EXCLUDED_CLASSIFICATIONS = {
    "nonbang_twin": "ordinary_nonmutating_fluent_chain",
    "walk_nonbang": "ordinary_nonmutating_fluent_chain",
    "reduce_nonbang": "ordinary_nonmutating_fluent_chain",
    "bang_word_alias": "ordinary_unknown_method",
    "bang_variable": "invalid_identifier_not_receiver_mutation",
}

EXPECTED_COMPOSITION_CALLBACK_IDS = {
    "callback_value_vivifies_and_replaces_without_revisit",
    "unrelated_vivification_commits_before_receiver_commit",
    "unrelated_writes_persist_when_later_callback_fails",
    "failed_unrelated_write_preserves_rhs_effect_only",
    "same_receiver_guard_precedes_write_evaluation",
    "same_spelling_shadow_vivifies_independently",
}
EXPECTED_COMPOSITION_CONTINUATION_IDS = {
    "post_commit_write_failure_preserves_map_commit",
}
EXPECTED_CURRENT_BOUNDARY_ROUTES = [
    ("perl", 0, "bang_chain_raw_fallback_returns_null"),
    ("rust", 0, "identifier_stops_before_bang_warning_then_null"),
    ("dart", 1, "generic_parser_invocation_failure"),
    ("julia", 1, "generic_parser_invocation_failure"),
    ("puc_lua", 1, "generic_parser_invocation_failure"),
    ("luajit", 1, "generic_parser_invocation_failure"),
]


class ContractError(ValueError):
    """A stable contract-validation or syntax failure."""

    def __init__(
        self,
        code: str,
        detail: str,
        *,
        source_span: dict[str, Any] | None = None,
    ) -> None:
        super().__init__(detail)
        self.code = code
        self.source_span = source_span


@dataclass
class RuntimeFailure(Exception):
    diagnostic: dict[str, Any]


@dataclass
class RunResult:
    bindings: dict[str, Any]
    result: Any
    effects: list[str]
    diagnostic: dict[str, Any] | None
    artifacts: dict[str, Any]


@dataclass(frozen=True)
class HookResult:
    value: Any


@dataclass(frozen=True)
class _BangCandidate:
    dot: int
    name_start: int
    name_end: int
    bang_start: int
    bang_end: int
    spaced: bool
    bang_count: int


def fail(
    code: str,
    detail: str,
    *,
    source_span: dict[str, Any] | None = None,
) -> None:
    raise ContractError(code, detail, source_span=source_span)


def cloned(value: Any) -> Any:
    return copy.deepcopy(value)


def canonical_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def semantic_digest(contract: dict[str, Any]) -> str:
    sections = {
        name: contract[name] for name in ("policy", "syntax", "ast", "diagnostics")
    }
    return hashlib.sha256(canonical_json(sections).encode("utf-8")).hexdigest()


def require_fields(value: dict[str, Any], expected: set[str], label: str) -> None:
    actual = set(value)
    if actual != expected:
        fail(
            "contract_schema_invalid",
            f"{label} fields differ: expected {sorted(expected)}, got {sorted(actual)}",
        )


def validate_plain_span(value: Any, label: str) -> None:
    if not isinstance(value, dict):
        fail("contract_schema_invalid", f"{label} must be an object")
    require_fields(value, {"start", "end"}, label)
    start = value["start"]
    end = value["end"]
    if not isinstance(start, int) or isinstance(start, bool) or start < 0:
        fail("contract_schema_invalid", f"{label}.start must be a nonnegative integer")
    if not isinstance(end, int) or isinstance(end, bool) or end < start:
        fail("contract_schema_invalid", f"{label}.end must be an integer >= start")


def validate_typed_span(value: Any, label: str) -> None:
    if not isinstance(value, dict):
        fail("contract_schema_invalid", f"{label} must be an object")
    require_fields(
        value,
        {"source_id", "start", "end", "unit", "provenance"},
        label,
    )
    if not isinstance(value["source_id"], str) or not value["source_id"]:
        fail("contract_schema_invalid", f"{label}.source_id must be nonempty")
    validate_plain_span({"start": value["start"], "end": value["end"]}, label)
    if value["unit"] != "unicode_scalar" or value["provenance"] != "authored":
        fail("contract_schema_invalid", f"{label} must be an authored Unicode-scalar span")


def typed_span(source_id: str, span: dict[str, int]) -> dict[str, Any]:
    return {
        "source_id": source_id,
        "start": span["start"],
        "end": span["end"],
        "unit": "unicode_scalar",
        "provenance": "authored",
    }


def _trim_span(source: str, start: int, end: int) -> tuple[str, int, int]:
    while start < end and source[start].isspace():
        start += 1
    while end > start and source[end - 1].isspace():
        end -= 1
    return source[start:end], start, end


def _advance_quoted(source: str, index: int) -> int:
    quote = source[index]
    index += 1
    while index < len(source):
        if source[index] == "\\":
            index += 2
            continue
        if source[index] == quote:
            return index + 1
        index += 1
    return len(source)


def _matching_delimiter(source: str, opening: int, left: str, right: str) -> int | None:
    depth = 0
    index = opening
    while index < len(source):
        char = source[index]
        if char in {'"', "'"}:
            index = _advance_quoted(source, index)
            continue
        if char == left:
            depth += 1
        elif char == right:
            depth -= 1
            if depth == 0:
                return index
        index += 1
    return None


def _top_level_dots(source: str) -> list[int]:
    dots: list[int] = []
    paren = bracket = brace = 0
    index = 0
    while index < len(source):
        char = source[index]
        if char in {'"', "'"}:
            index = _advance_quoted(source, index)
            continue
        if char == "(":
            paren += 1
        elif char == ")":
            paren = max(paren - 1, 0)
        elif char == "[":
            bracket += 1
        elif char == "]":
            bracket = max(bracket - 1, 0)
        elif char == "{":
            brace += 1
        elif char == "}":
            brace = max(brace - 1, 0)
        elif char == "." and paren == 0 and bracket == 0 and brace == 0:
            dots.append(index)
        index += 1
    return dots


def _candidate_at(source: str, dot: int) -> _BangCandidate | None:
    index = dot + 1
    while index < len(source) and source[index].isspace():
        index += 1
    name_start = index
    if index >= len(source) or not (source[index].isalpha() or source[index] == "_"):
        return None
    index += 1
    while index < len(source) and (source[index].isalnum() or source[index] == "_"):
        index += 1
    name_end = index
    bang_start = index
    while bang_start < len(source) and source[bang_start].isspace():
        bang_start += 1
    if bang_start >= len(source) or source[bang_start] != "!":
        return None
    bang_end = bang_start
    while bang_end < len(source) and source[bang_end] == "!":
        bang_end += 1
    return _BangCandidate(
        dot=dot,
        name_start=name_start,
        name_end=name_end,
        bang_start=bang_start,
        bang_end=bang_end,
        spaced=bang_start != name_end,
        bang_count=bang_end - bang_start,
    )


def _first_bang_candidate(source: str) -> _BangCandidate | None:
    for dot in _top_level_dots(source):
        candidate = _candidate_at(source, dot)
        if candidate is not None:
            return candidate
    return None


def _syntax_diagnostic(
    case_id: str,
    code: str,
    span: dict[str, int],
    message: str,
) -> dict[str, Any]:
    return {
        "code": code,
        "stage": "action_parse",
        "source_span": typed_span(f"contract:{case_id}", span),
        "message": message,
    }


def _raise_syntax(case_id: str, code: str, start: int, end: int, message: str) -> None:
    diagnostic = _syntax_diagnostic(case_id, code, {"start": start, "end": end}, message)
    raise ContractError(code, message, source_span=diagnostic["source_span"])


def parse_mutation(source: str, case_id: str) -> dict[str, Any]:
    trimmed, expression_start, expression_end = _trim_span(source, 0, len(source))
    function_match = re.match(rf"map_leaves!", trimmed)
    if function_match is not None:
        start = expression_start
        _raise_syntax(
            case_id,
            "bang_method_function_form_invalid",
            start,
            start + len("map_leaves!"),
            "map_leaves! is receiver-only; use binding.map_leaves!() { ... }",
        )

    candidate = _first_bang_candidate(source)
    if candidate is None:
        fail("not_receiver_mutation", "source does not contain a top-level bang receiver method")

    method_name = source[candidate.name_start : candidate.name_end]
    source_method = source[candidate.name_start : candidate.bang_end]
    if candidate.spaced:
        _raise_syntax(
            case_id,
            "bang_method_suffix_invalid",
            candidate.name_start,
            candidate.bang_end,
            "the bang suffix must immediately follow map_leaves",
        )
    if candidate.bang_count != 1:
        _raise_syntax(
            case_id,
            "bang_method_suffix_invalid",
            candidate.name_start,
            candidate.bang_end,
            "map_leaves! accepts exactly one bang suffix",
        )
    if method_name != METHOD:
        _raise_syntax(
            case_id,
            "bang_method_unknown",
            candidate.name_start,
            candidate.bang_end,
            f"unsupported bang method '{source_method}'",
        )

    receiver_source, receiver_start, receiver_end = _trim_span(
        source, expression_start, candidate.dot
    )
    if not IDENTIFIER.fullmatch(receiver_source):
        _raise_syntax(
            case_id,
            "receiver_mutation_receiver_not_addressable",
            receiver_start,
            receiver_end,
            "receiver mutation requires one bare uniform-binding identifier",
        )

    if receiver_source in RESERVED_RECEIVER_NAMES:
        _raise_syntax(
            case_id,
            "receiver_mutation_receiver_reserved",
            receiver_start,
            receiver_end,
            f"receiver mutation cannot target reserved binding '{receiver_source}'",
        )

    index = candidate.bang_end
    while index < expression_end and source[index].isspace():
        index += 1
    if index >= expression_end or source[index] != "(":
        _raise_syntax(
            case_id,
            "map_leaves_mutation_arguments_invalid",
            candidate.name_start,
            index,
            "map_leaves! expects empty parentheses before its callback",
        )
    close_paren = _matching_delimiter(source, index, "(", ")")
    if close_paren is None or close_paren >= expression_end:
        _raise_syntax(
            case_id,
            "map_leaves_mutation_arguments_invalid",
            index,
            expression_end,
            "map_leaves! expects empty parentheses before its callback",
        )
    if source[index + 1 : close_paren].strip():
        _raise_syntax(
            case_id,
            "map_leaves_mutation_arguments_invalid",
            index,
            close_paren + 1,
            "map_leaves! expects empty parentheses before its callback",
        )

    callback_open = close_paren + 1
    while callback_open < expression_end and source[callback_open].isspace():
        callback_open += 1
    if callback_open >= expression_end or source[callback_open] != "{":
        _raise_syntax(
            case_id,
            "map_leaves_mutation_callback_missing",
            candidate.name_start,
            close_paren + 1,
            "map_leaves! requires one immediate trailing callback block",
        )
    callback_close = _matching_delimiter(source, callback_open, "{", "}")
    if callback_close is None:
        _raise_syntax(
            case_id,
            "map_leaves_mutation_callback_missing",
            callback_open,
            expression_end,
            "map_leaves! requires one immediate trailing callback block",
        )

    continuation: list[dict[str, Any]] = []
    cursor = callback_close + 1
    while True:
        while cursor < expression_end and source[cursor].isspace():
            cursor += 1
        if cursor >= expression_end:
            break
        if source[cursor] != ".":
            fail("receiver_mutation_continuation_invalid", "continuation must begin with a dot")
        cursor += 1
        while cursor < expression_end and source[cursor].isspace():
            cursor += 1
        call_start = cursor
        name_start = cursor
        if cursor >= expression_end or not (source[cursor].isalpha() or source[cursor] == "_"):
            fail("receiver_mutation_continuation_invalid", "continuation method is missing")
        cursor += 1
        while cursor < expression_end and (source[cursor].isalnum() or source[cursor] == "_"):
            cursor += 1
        name_end = cursor
        while cursor < expression_end and source[cursor].isspace():
            cursor += 1
        if cursor < expression_end and source[cursor] == "!":
            bang_end = cursor + 1
            while bang_end < expression_end and source[bang_end] == "!":
                bang_end += 1
            _raise_syntax(
                case_id,
                "receiver_mutation_continuation_bang_invalid",
                name_start,
                bang_end,
                "a receiver-mutation chain continuation must use an existing non-bang fluent call",
            )
        if cursor >= expression_end or source[cursor] != "(":
            fail("receiver_mutation_continuation_invalid", "continuation requires parentheses")
        continuation_open = cursor
        continuation_close = _matching_delimiter(source, cursor, "(", ")")
        if continuation_close is None:
            fail("receiver_mutation_continuation_invalid", "continuation parentheses are unclosed")
        args_source = source[continuation_open + 1 : continuation_close]
        call_end = continuation_close + 1
        block_open = call_end
        while block_open < expression_end and source[block_open].isspace():
            block_open += 1
        if block_open < expression_end and source[block_open] == "{":
            block_close = _matching_delimiter(source, block_open, "{", "}")
            if block_close is None:
                fail("receiver_mutation_continuation_invalid", "continuation block is unclosed")
            call_end = block_close + 1
        call_source = source[call_start:call_end]
        method = source[name_start:name_end]
        continuation.append(
            {
                "kind": "fluent_call",
                "method": method,
                "source_method": method,
                "source": call_source,
                "source_span": {"start": call_start, "end": call_end},
                "args_source": args_source,
                "args_span": {
                    "start": continuation_open + 1,
                    "end": continuation_close,
                },
            }
        )
        cursor = call_end

    mutation_end = callback_close + 1
    return {
        "kind": "receiver_mutation_chain",
        "source": trimmed,
        "source_span": {"start": expression_start, "end": expression_end},
        "receiver": {
            "kind": "binding_reference",
            "name": receiver_source,
            "source": receiver_source,
            "source_span": {"start": receiver_start, "end": receiver_end},
        },
        "mutation": {
            "kind": "receiver_mutation_call",
            "method": METHOD,
            "source_method": "map_leaves!",
            "source": source[candidate.name_start:mutation_end],
            "source_span": {"start": candidate.name_start, "end": mutation_end},
            "method_span": {
                "start": candidate.name_start,
                "end": candidate.bang_end,
            },
            "args_span": {"start": index, "end": close_paren + 1},
            "callback": {
                "kind": "block_value",
                "source": source[callback_open : callback_close + 1],
                "source_span": {"start": callback_open, "end": callback_close + 1},
                "body": {
                    "kind": "action_block",
                    "source": source[callback_open + 1 : callback_close],
                    "source_span": {"start": callback_open + 1, "end": callback_close},
                },
            },
        },
        "continuation": continuation,
    }


def syntax_diagnostic(case_id: str, error: ContractError) -> dict[str, Any]:
    return {
        "code": error.code,
        "stage": "action_parse",
        "source_span": cloned(error.source_span),
        "message": str(error),
    }


def runtime_kind(value: Any) -> str:
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, str):
        return "string"
    if isinstance(value, (int, float)):
        return "number"
    if isinstance(value, list):
        return "array"
    if isinstance(value, dict):
        return "harray"
    return "codeblock"


def _path_label(path: list[Any]) -> str:
    return "/".join(str(part) for part in path)


def _receiver_missing_diagnostic(
    binding: str, source_id: str, receiver_span: dict[str, int]
) -> dict[str, Any]:
    return {
        "code": "map_leaves_mutation_receiver_missing",
        "operation": OPERATION,
        "binding": binding,
        "method": METHOD,
        "source_span": typed_span(source_id, receiver_span),
        "message": f"map_leaves! receiver binding '{binding}' does not exist",
    }


def _receiver_kind_diagnostic(
    binding: str,
    actual: str,
    source_id: str,
    receiver_span: dict[str, int],
) -> dict[str, Any]:
    return {
        "code": "map_leaves_mutation_receiver_kind_mismatch",
        "operation": OPERATION,
        "binding": binding,
        "method": METHOD,
        "expected_kinds": ["harray", "array"],
        "actual_kind": actual,
        "source_span": typed_span(source_id, receiver_span),
        "message": f"map_leaves! receiver '{binding}' must hold an harray or array, got {actual}",
    }


def _reentrant_diagnostic(binding: str, attempt: dict[str, Any]) -> dict[str, Any]:
    return {
        "code": "receiver_mutation_reentrant",
        "operation": OPERATION,
        "binding": binding,
        "method": METHOD,
        "attempt": attempt["attempt"],
        "source_span": cloned(attempt["source_span"]),
        "message": f"cannot write active map_leaves! receiver binding '{binding}' from its callback",
    }


def _apply_effect(
    bindings: dict[str, Any], effect: dict[str, Any], active_binding: str
) -> None:
    binding = effect["binding"]
    if binding == active_binding:
        fail("checker_invalid_fixture", "ordinary effect may not bypass active receiver guard")
    if effect["operation"] == "set":
        bindings[binding] = cloned(effect["value"])
        return
    if effect["operation"] == "append":
        current = bindings.get(binding)
        if not isinstance(current, list):
            fail("checker_invalid_fixture", f"append effect target '{binding}' is not an array")
        current.append(cloned(effect["value"]))
        return
    fail("checker_invalid_fixture", f"unknown callback effect {effect['operation']!r}")


def run_invocation(
    *,
    source: str,
    case_id: str,
    binding: str,
    bindings: dict[str, Any],
    callback_steps: list[dict[str, Any]],
    continuation: list[dict[str, Any]] | None = None,
    callback_hook: Callable[
        [dict[str, Any], dict[str, Any], dict[str, Any], list[str]],
        HookResult | None,
    ]
    | None = None,
    continuation_hook: Callable[
        [dict[str, Any], Any, dict[str, Any], list[str]],
        HookResult | None,
    ]
    | None = None,
) -> RunResult:
    parsed = parse_mutation(source, case_id)
    if parsed["receiver"]["name"] != binding:
        fail("checker_invalid_fixture", f"{case_id} binding does not match parsed receiver")

    working_bindings = cloned(bindings)
    effects: list[str] = []
    artifacts: dict[str, Any] = {
        "authored_initial": cloned(bindings),
        "callback_frames": [],
        "mutated_callback_frames": [],
        "callback_results": [],
        "shadow_values": [],
    }
    source_id = f"contract:{case_id}"
    receiver_span = parsed["receiver"]["source_span"]
    if binding not in working_bindings:
        return RunResult(
            working_bindings,
            None,
            effects,
            _receiver_missing_diagnostic(binding, source_id, receiver_span),
            artifacts,
        )
    root = working_bindings[binding]
    root_kind = runtime_kind(root)
    if root_kind not in {"harray", "array"}:
        return RunResult(
            working_bindings,
            None,
            effects,
            _receiver_kind_diagnostic(binding, root_kind, source_id, receiver_span),
            artifacts,
        )

    snapshot = cloned(root)
    artifacts["snapshot"] = snapshot
    step_index = 0

    def callback(value: Any, selector: Any, path: list[Any]) -> Any:
        nonlocal step_index
        if step_index >= len(callback_steps):
            fail("checker_invalid_fixture", f"{case_id} has fewer callback steps than leaves")
        step = callback_steps[step_index]
        step_index += 1
        selector_name = "key" if root_kind == "harray" else "index"
        frame = {
            "value": cloned(value),
            selector_name: cloned(selector),
            "path": cloned(path),
            "depth": len(path),
        }
        if frame != step["frame"]:
            fail(
                "callback_frame_mismatch",
                f"{case_id} callback {step_index - 1}: expected {step['frame']!r}, got {frame!r}",
            )
        artifacts["callback_frames"].append(cloned(frame))

        local_frame = cloned(frame)
        for name, replacement in step.get("mutate_frame", {}).items():
            if name not in {"value", "path"}:
                fail("checker_invalid_fixture", f"unsupported local frame mutation {name!r}")
            local_frame[name] = cloned(replacement)
        if "mutate_frame" in step:
            if frame != step["frame"]:
                fail("callback_frame_alias_detected", "local frame mutation escaped its copy")
            artifacts["mutated_callback_frames"].append(local_frame)

        hook_result = (
            callback_hook(step, local_frame, working_bindings, effects)
            if callback_hook is not None
            else None
        )

        for effect in step.get("effects", []):
            _apply_effect(working_bindings, effect, binding)
            effects.append(f"effect:{effect['binding']}")

        if "shadow_mutation" in step:
            shadow = step["shadow_mutation"]
            if shadow["spelling"] != binding or shadow["identity"] == binding:
                fail("checker_invalid_fixture", "shadow case must retain spelling but use a distinct identity")
            artifacts["shadow_values"].append(cloned(shadow["value"]))
            effects.append(f"shadow:{shadow['identity']}")

        if "mutation_attempt" in step:
            attempt = step["mutation_attempt"]
            validate_typed_span(attempt["source_span"], f"{case_id}.mutation_attempt.source_span")
            if attempt["binding"] != binding:
                fail("checker_invalid_fixture", "mutation attempt must target the active binding")
            raise RuntimeFailure(_reentrant_diagnostic(binding, attempt))

        if "error" in step:
            validate_runtime_diagnostic(step["error"], f"{case_id}.callback_error")
            raise RuntimeFailure(cloned(step["error"]))
        if hook_result is not None:
            result = cloned(hook_result.value)
        elif "result" not in step:
            fail("checker_invalid_fixture", f"{case_id} successful callback step lacks result")
        else:
            result = cloned(step["result"])
        artifacts["callback_results"].append(cloned(result))
        effects.append(f"callback:{_path_label(path)}")
        return result

    def map_node(node: Any, path: list[Any]) -> Any:
        if root_kind == "harray":
            if not isinstance(node, dict):
                fail("checker_internal_error", "harray traversal reached non-harray interior")
            mapped: dict[str, Any] = {}
            for key in sorted(node):
                value = node[key]
                next_path = [*path, key]
                mapped[key] = (
                    map_node(value, next_path)
                    if isinstance(value, dict)
                    else callback(value, key, next_path)
                )
            return mapped
        if not isinstance(node, list):
            fail("checker_internal_error", "array traversal reached non-array interior")
        mapped_items: list[Any] = []
        for index, value in enumerate(node):
            next_path = [*path, index]
            mapped_items.append(
                map_node(value, next_path)
                if isinstance(value, list)
                else callback(value, index, next_path)
            )
        return mapped_items

    try:
        mapped = map_node(snapshot, [])
    except RuntimeFailure as error:
        return RunResult(
            working_bindings,
            None,
            effects,
            cloned(error.diagnostic),
            artifacts,
        )
    if step_index != len(callback_steps):
        fail("checker_invalid_fixture", f"{case_id} has unused callback steps")

    committed = cloned(mapped)
    working_bindings[binding] = committed
    returned = cloned(mapped)
    artifacts["committed_binding"] = committed
    artifacts["returned_root"] = returned
    effects.append(f"commit:{binding}")

    current = returned
    for call in continuation or []:
        if current != call["expected_input"]:
            fail(
                "continuation_input_mismatch",
                f"{case_id} continuation {call['method']} received {current!r}",
            )
        try:
            hook_result = (
                continuation_hook(call, current, working_bindings, effects)
                if continuation_hook is not None
                else None
            )
        except RuntimeFailure as error:
            return RunResult(
                working_bindings,
                None,
                effects,
                cloned(error.diagnostic),
                artifacts,
            )
        if "error" in call:
            validate_runtime_diagnostic(call["error"], f"{case_id}.continuation_error")
            return RunResult(
                working_bindings,
                None,
                effects,
                cloned(call["error"]),
                artifacts,
            )
        current = cloned(hook_result.value if hook_result is not None else call["result"])
        effects.append(f"continuation:{call['method']}")
    return RunResult(working_bindings, cloned(current), effects, None, artifacts)


def validate_runtime_diagnostic(value: Any, label: str) -> None:
    if not isinstance(value, dict):
        fail("contract_schema_invalid", f"{label} must be an object")
    if not isinstance(value.get("code"), str) or not value["code"]:
        fail("contract_schema_invalid", f"{label}.code must be nonempty")
    if not isinstance(value.get("message"), str) or not value["message"]:
        fail("contract_schema_invalid", f"{label}.message must be nonempty")
    validate_typed_span(value.get("source_span"), f"{label}.source_span")


def validate_expected_diagnostic(value: Any, label: str) -> None:
    validate_runtime_diagnostic(value, label)
    code = value["code"]
    expected_fields = {
        "map_leaves_mutation_receiver_missing": {
            "code",
            "operation",
            "binding",
            "method",
            "source_span",
            "message",
        },
        "map_leaves_mutation_receiver_kind_mismatch": {
            "code",
            "operation",
            "binding",
            "method",
            "expected_kinds",
            "actual_kind",
            "source_span",
            "message",
        },
        "receiver_mutation_reentrant": {
            "code",
            "operation",
            "binding",
            "method",
            "attempt",
            "source_span",
            "message",
        },
        "callback_failed": {"code", "stage", "source_span", "message"},
        "continuation_failed": {"code", "stage", "source_span", "message"},
    }.get(code)
    if expected_fields is None:
        fail("contract_schema_invalid", f"{label} has unsupported code {code!r}")
    require_fields(value, expected_fields, label)
    if "operation" in value and value["operation"] != OPERATION:
        fail("contract_schema_invalid", f"{label}.operation drifted")
    if "method" in value and value["method"] != METHOD:
        fail("contract_schema_invalid", f"{label}.method drifted")


def validate_callback_steps(steps: Any, label: str) -> None:
    if not isinstance(steps, list):
        fail("contract_schema_invalid", f"{label} must be an array")
    for index, step in enumerate(steps):
        step_label = f"{label}[{index}]"
        if not isinstance(step, dict):
            fail("contract_schema_invalid", f"{step_label} must be an object")
        allowed = {
            "frame",
            "result",
            "effects",
            "mutate_frame",
            "mutation_attempt",
            "error",
            "shadow_mutation",
        }
        unknown = set(step) - allowed
        if unknown or "frame" not in step:
            fail(
                "contract_schema_invalid",
                f"{step_label} has invalid fields {sorted(unknown)} or lacks frame",
            )
        terminals = [name for name in ("result", "mutation_attempt", "error") if name in step]
        if len(terminals) != 1:
            fail("contract_schema_invalid", f"{step_label} needs exactly one terminal outcome")

        frame = step["frame"]
        if not isinstance(frame, dict):
            fail("contract_schema_invalid", f"{step_label}.frame must be an object")
        common = {"value", "path", "depth"}
        selectors = set(frame) - common
        if common - set(frame) or selectors not in ({"key"}, {"index"}):
            fail("contract_schema_invalid", f"{step_label}.frame fields are invalid")
        if not isinstance(frame["path"], list) or frame["depth"] != len(frame["path"]):
            fail("contract_schema_invalid", f"{step_label}.frame path/depth differ")

        for effect_index, effect in enumerate(step.get("effects", [])):
            if not isinstance(effect, dict):
                fail("contract_schema_invalid", f"{step_label}.effects[{effect_index}] must be an object")
            require_fields(
                effect,
                {"operation", "binding", "value"},
                f"{step_label}.effects[{effect_index}]",
            )
            if effect["operation"] not in {"set", "append"}:
                fail("contract_schema_invalid", f"{step_label} effect operation is invalid")

        if "mutate_frame" in step:
            mutation = step["mutate_frame"]
            if not isinstance(mutation, dict) or not mutation or set(mutation) - {"value", "path"}:
                fail("contract_schema_invalid", f"{step_label}.mutate_frame is invalid")
        if "mutation_attempt" in step:
            attempt = step["mutation_attempt"]
            if not isinstance(attempt, dict):
                fail("contract_schema_invalid", f"{step_label}.mutation_attempt must be an object")
            require_fields(
                attempt,
                {"binding", "attempt", "source_span"},
                f"{step_label}.mutation_attempt",
            )
            validate_typed_span(attempt["source_span"], f"{step_label}.mutation_attempt.source_span")
        if "error" in step:
            validate_expected_diagnostic(step["error"], f"{step_label}.error")
        if "shadow_mutation" in step:
            shadow = step["shadow_mutation"]
            if not isinstance(shadow, dict):
                fail("contract_schema_invalid", f"{step_label}.shadow_mutation must be an object")
            require_fields(
                shadow,
                {"spelling", "identity", "value"},
                f"{step_label}.shadow_mutation",
            )


def validate_continuation(calls: Any, label: str) -> None:
    if not isinstance(calls, list):
        fail("contract_schema_invalid", f"{label} must be an array")
    for index, call in enumerate(calls):
        call_label = f"{label}[{index}]"
        if not isinstance(call, dict):
            fail("contract_schema_invalid", f"{call_label} must be an object")
        terminal = "error" if "error" in call else "result"
        require_fields(call, {"method", "expected_input", terminal}, call_label)
        if not isinstance(call["method"], str) or not IDENTIFIER.fullmatch(call["method"]):
            fail("contract_schema_invalid", f"{call_label}.method must be an identifier")
        if terminal == "error":
            validate_expected_diagnostic(call["error"], f"{call_label}.error")


def validate_case_result(case: dict[str, Any], result: RunResult) -> None:
    if result.bindings != case["expected_bindings"]:
        fail(
            "binding_result_mismatch",
            f"{case['id']}: expected bindings {case['expected_bindings']!r}, got {result.bindings!r}",
        )
    if result.effects != case["expected_effects"]:
        fail(
            "effect_order_mismatch",
            f"{case['id']}: expected effects {case['expected_effects']!r}, got {result.effects!r}",
        )
    if "expected_diagnostic" in case:
        validate_runtime_diagnostic(case["expected_diagnostic"], f"{case['id']}.expected_diagnostic")
        if result.diagnostic != case["expected_diagnostic"]:
            fail(
                "diagnostic_mismatch",
                f"{case['id']}: expected {case['expected_diagnostic']!r}, got {result.diagnostic!r}",
            )
        if result.result is not None:
            fail("result_mismatch", f"{case['id']}: failed invocation returned a value")
        return
    if result.diagnostic is not None:
        fail("unexpected_diagnostic", f"{case['id']}: {result.diagnostic!r}")
    if result.result != case["expected_result"]:
        fail(
            "result_mismatch",
            f"{case['id']}: expected result {case['expected_result']!r}, got {result.result!r}",
        )


def _mutable_ids(value: Any) -> set[int]:
    ids: set[int] = set()

    def visit(node: Any) -> None:
        if isinstance(node, dict):
            ids.add(id(node))
            for key, child in node.items():
                visit(key)
                visit(child)
        elif isinstance(node, list):
            ids.add(id(node))
            for child in node:
                visit(child)

    visit(value)
    return ids


def validate_detachment(case: dict[str, Any]) -> None:
    result = run_invocation(
        source=case["source"],
        case_id=case["id"],
        binding=case["binding"],
        bindings=case["initial_bindings"],
        callback_steps=case["callback_steps"],
    )
    if result.diagnostic is not None:
        fail("unexpected_diagnostic", f"detachment case failed: {result.diagnostic!r}")
    if result.bindings[case["binding"]] != case["expected_binding"]:
        fail("binding_result_mismatch", "detachment committed value differs")
    if result.result != case["expected_result"]:
        fail("result_mismatch", "detachment returned value differs")
    if case["mutations"] != [
        "initial",
        "callback_value",
        "callback_path",
        "callback_result",
        "returned_result",
        "committed_binding",
    ] or case["expected_each_other_boundary_unchanged"] is not True:
        fail("contract_schema_invalid", "detachment mutation matrix drifted")

    boundaries = {
        "initial": case["initial_bindings"],
        "snapshot": result.artifacts["snapshot"],
        "callback_frame": result.artifacts["callback_frames"],
        "callback_result": result.artifacts["callback_results"],
        "returned_result": result.artifacts["returned_root"],
        "committed_binding": result.artifacts["committed_binding"],
    }
    names = list(boundaries)
    for index, left_name in enumerate(names):
        left_ids = _mutable_ids(boundaries[left_name])
        for right_name in names[index + 1 :]:
            overlap = left_ids & _mutable_ids(boundaries[right_name])
            if overlap:
                fail(
                    "detachment_alias_detected",
                    f"{left_name} and {right_name} share mutable identities",
                )


def validate_ids(contract: dict[str, Any], field: str) -> None:
    cases = contract[field]
    if not isinstance(cases, list):
        fail("contract_schema_invalid", f"{field} must be an array")
    ids = [case.get("id") for case in cases if isinstance(case, dict)]
    if len(ids) != len(cases) or len(set(ids)) != len(ids):
        fail("contract_schema_invalid", f"{field} ids must be present and unique")
    if set(ids) != EXPECTED_IDS[field]:
        fail("contract_case_ids_invalid", f"{field} ids differ: {sorted(ids)}")


def validate_contract(contract: dict[str, Any]) -> None:
    if not isinstance(contract, dict):
        fail("contract_schema_invalid", "contract root must be an object")
    require_fields(contract, EXPECTED_TOP_LEVEL_KEYS, "contract")
    if contract["format"] != 1:
        fail("contract_format_invalid", "format must remain 1")
    if contract["contract_id"] != "linkedspec-map-leaves-mutation-v1":
        fail("contract_id_invalid", "contract id drifted")
    if contract["status"] != "future-neutral-contract; no backend behavior admitted":
        fail("contract_status_invalid", "future-only status drifted")
    if semantic_digest(contract) != EXPECTED_SEMANTIC_DIGEST:
        fail("contract_semantics_drifted", "policy/syntax/AST/diagnostics digest changed")

    for field in EXPECTED_IDS:
        validate_ids(contract, field)
    for field, expected_id in EXPECTED_SPECIAL_IDS.items():
        case = contract[field]
        if not isinstance(case, dict) or case.get("id") != expected_id:
            fail("contract_case_ids_invalid", f"{field} id drifted")

    for case in contract["valid_syntax_cases"]:
        require_fields(
            case,
            {"id", "source", "expected_ast"}
            if "expected_ast" in case
            else {"id", "source", "expected_receiver", "expected_continuation"},
            f"valid syntax {case['id']}",
        )
        parsed = parse_mutation(case["source"], case["id"])
        if "expected_ast" in case:
            if parsed != case["expected_ast"]:
                fail(
                    "ast_mismatch",
                    f"{case['id']}: expected {case['expected_ast']!r}, got {parsed!r}",
                )
        else:
            methods = [call["method"] for call in parsed["continuation"]]
            if parsed["receiver"]["name"] != case["expected_receiver"]:
                fail("ast_mismatch", f"{case['id']} receiver drifted")
            if methods != case["expected_continuation"]:
                fail("ast_mismatch", f"{case['id']} continuation drifted")

    for case in contract["invalid_syntax_cases"]:
        require_fields(case, {"id", "source", "diagnostic"}, f"invalid syntax {case['id']}")
        require_fields(
            case["diagnostic"],
            {"code", "stage", "source_span", "message"},
            f"{case['id']}.diagnostic",
        )
        validate_runtime_diagnostic(case["diagnostic"], f"{case['id']}.diagnostic")
        if case["diagnostic"].get("stage") != "action_parse":
            fail("contract_schema_invalid", f"{case['id']} syntax stage drifted")
        try:
            parse_mutation(case["source"], case["id"])
        except ContractError as error:
            actual = syntax_diagnostic(case["id"], error)
        else:
            fail("syntax_case_accepted", f"{case['id']} unexpectedly parsed")
        if actual != case["diagnostic"]:
            fail(
                "diagnostic_mismatch",
                f"{case['id']}: expected {case['diagnostic']!r}, got {actual!r}",
            )

    for case in contract["excluded_syntax_cases"]:
        require_fields(case, {"id", "source", "classification"}, f"excluded syntax {case['id']}")
        if case["classification"] != EXPECTED_EXCLUDED_CLASSIFICATIONS[case["id"]]:
            fail("classification_mismatch", f"{case['id']} classification drifted")
        try:
            parse_mutation(case["source"], case["id"])
        except ContractError:
            pass
        else:
            fail("excluded_case_accepted", f"{case['id']} became a receiver mutation")

    common_execution_fields = {
        "id",
        "source",
        "binding",
        "initial_bindings",
        "callback_steps",
        "expected_bindings",
        "expected_effects",
    }
    for field in ("success_cases", "failure_cases"):
        for case in contract[field]:
            expected_fields = set(common_execution_fields)
            if field == "success_cases":
                expected_fields.add("expected_result")
                if "continuation" in case:
                    expected_fields.add("continuation")
            else:
                expected_fields.add("expected_diagnostic")
            require_fields(case, expected_fields, f"{field}.{case['id']}")
            if not isinstance(case["binding"], str) or not IDENTIFIER.fullmatch(case["binding"]):
                fail("contract_schema_invalid", f"{case['id']}.binding is invalid")
            if not isinstance(case["initial_bindings"], dict) or not isinstance(case["expected_bindings"], dict):
                fail("contract_schema_invalid", f"{case['id']} bindings must be objects")
            if not isinstance(case["expected_effects"], list):
                fail("contract_schema_invalid", f"{case['id']}.expected_effects must be an array")
            validate_callback_steps(case["callback_steps"], f"{case['id']}.callback_steps")
            validate_continuation(case.get("continuation", []), f"{case['id']}.continuation")
            if "expected_diagnostic" in case:
                validate_expected_diagnostic(
                    case["expected_diagnostic"], f"{case['id']}.expected_diagnostic"
                )
            result = run_invocation(
                source=case["source"],
                case_id=case["id"],
                binding=case["binding"],
                bindings=case["initial_bindings"],
                callback_steps=case["callback_steps"],
                continuation=case.get("continuation"),
            )
            validate_case_result(case, result)

    continuation_failure = contract["continuation_failure_case"]
    require_fields(
        continuation_failure,
        common_execution_fields | {"continuation", "expected_diagnostic"},
        "continuation_failure_case",
    )
    validate_callback_steps(
        continuation_failure["callback_steps"], "continuation_failure_case.callback_steps"
    )
    validate_continuation(
        continuation_failure["continuation"], "continuation_failure_case.continuation"
    )
    validate_expected_diagnostic(
        continuation_failure["expected_diagnostic"],
        "continuation_failure_case.expected_diagnostic",
    )
    continuation_result = run_invocation(
        source=continuation_failure["source"],
        case_id=continuation_failure["id"],
        binding=continuation_failure["binding"],
        bindings=continuation_failure["initial_bindings"],
        callback_steps=continuation_failure["callback_steps"],
        continuation=continuation_failure["continuation"],
    )
    validate_case_result(continuation_failure, continuation_result)

    shadow = contract["shadow_binding_case"]
    require_fields(
        shadow,
        common_execution_fields | {"expected_result"},
        "shadow_binding_case",
    )
    validate_callback_steps(shadow["callback_steps"], "shadow_binding_case.callback_steps")
    shadow_result = run_invocation(
        source=shadow["source"],
        case_id=shadow["id"],
        binding=shadow["binding"],
        bindings=shadow["initial_bindings"],
        callback_steps=shadow["callback_steps"],
    )
    validate_case_result(shadow, shadow_result)

    guard = contract["guard_release_case"]
    require_fields(
        guard,
        {
            "id",
            "binding",
            "initial_bindings",
            "first_invocation",
            "second_invocation",
            "expected_bindings",
            "expected_result",
            "expected_effects",
        },
        "guard_release_case",
    )
    first = guard["first_invocation"]
    require_fields(
        first,
        {"source", "callback_steps", "expected_diagnostic"},
        "guard_release_case.first_invocation",
    )
    validate_callback_steps(first["callback_steps"], "guard_release_case.first_invocation.callback_steps")
    validate_expected_diagnostic(
        first["expected_diagnostic"], "guard_release_case.first_invocation.expected_diagnostic"
    )
    first_result = run_invocation(
        source=first["source"],
        case_id=f"{guard['id']}:first",
        binding=guard["binding"],
        bindings=guard["initial_bindings"],
        callback_steps=first["callback_steps"],
    )
    if first_result.diagnostic != first["expected_diagnostic"]:
        fail("diagnostic_mismatch", "guard-release first invocation diagnostic drifted")
    if first_result.bindings != guard["initial_bindings"]:
        fail("binding_result_mismatch", "guard-release failure changed receiver")
    second = guard["second_invocation"]
    require_fields(
        second,
        {"source", "callback_steps"},
        "guard_release_case.second_invocation",
    )
    validate_callback_steps(second["callback_steps"], "guard_release_case.second_invocation.callback_steps")
    second_result = run_invocation(
        source=second["source"],
        case_id=f"{guard['id']}:second",
        binding=guard["binding"],
        bindings=first_result.bindings,
        callback_steps=second["callback_steps"],
    )
    if second_result.diagnostic is not None:
        fail("guard_not_released", "second invocation remained guarded")
    if second_result.bindings != guard["expected_bindings"]:
        fail("binding_result_mismatch", "guard-release second binding drifted")
    if second_result.result != guard["expected_result"]:
        fail("result_mismatch", "guard-release second result drifted")
    if second_result.effects != guard["expected_effects"]:
        fail("effect_order_mismatch", "guard-release second effects drifted")

    nonbang = contract["nonbang_isolation_case"]
    require_fields(
        nonbang,
        {
            "id",
            "source",
            "binding",
            "initial_bindings",
            "callback_value_after_local_mutation",
            "expected_binding",
            "expected_result",
        },
        "nonbang_isolation_case",
    )
    if "map_leaves!" in nonbang["source"]:
        fail("contract_schema_invalid", "nonbang isolation accidentally uses bang syntax")
    initial = cloned(nonbang["initial_bindings"])
    callback_value = cloned(initial[nonbang["binding"]]["leaf"])
    callback_value.clear()
    callback_value.update(cloned(nonbang["callback_value_after_local_mutation"]))
    nonbang_result = {"leaf": cloned(callback_value)}
    if initial[nonbang["binding"]] != nonbang["expected_binding"]:
        fail("nonbang_alias_mutation", "nonbang callback mutated its receiver")
    if nonbang_result != nonbang["expected_result"]:
        fail("result_mismatch", "nonbang isolation result drifted")

    detachment = contract["detachment_case"]
    require_fields(
        detachment,
        {
            "id",
            "source",
            "binding",
            "initial_bindings",
            "callback_steps",
            "expected_binding",
            "expected_result",
            "mutations",
            "expected_each_other_boundary_unchanged",
        },
        "detachment_case",
    )
    validate_callback_steps(detachment["callback_steps"], "detachment_case.callback_steps")
    validate_detachment(detachment)


def _composition_binding_state(
    target: dict[str, Any],
    bindings: dict[str, Any],
    local_bindings: dict[str, Any],
    callback_frame: dict[str, Any] | None,
) -> dict[str, Any]:
    storage = target["storage"]
    if storage == "binding":
        name = target["name"]
        return (
            {"present": True, "value": cloned(bindings[name])}
            if name in bindings
            else {"present": False}
        )
    if storage == "callback_value":
        if callback_frame is None or target["name"] != "value":
            fail("composition_fixture_invalid", "callback-value write lacks a callback frame")
        return {"present": True, "value": cloned(callback_frame["value"])}
    identity = target["identity"]
    if identity not in local_bindings and target.get("initialize_from") == "callback_value":
        if callback_frame is None:
            fail("composition_fixture_invalid", "local callback initializer lacks a frame")
        local_bindings[identity] = cloned(callback_frame["value"])
    return (
        {"present": True, "value": cloned(local_bindings[identity])}
        if identity in local_bindings
        else {"present": False}
    )


def _store_composition_binding_state(
    target: dict[str, Any],
    state: dict[str, Any],
    bindings: dict[str, Any],
    local_bindings: dict[str, Any],
    callback_frame: dict[str, Any] | None,
) -> None:
    storage = target["storage"]
    if storage == "binding":
        if state["present"]:
            bindings[target["name"]] = cloned(state["value"])
        else:
            bindings.pop(target["name"], None)
        return
    if storage == "callback_value":
        if callback_frame is None or not state["present"]:
            fail("composition_fixture_invalid", "callback-value write produced absent state")
        callback_frame["value"] = cloned(state["value"])
        return
    identity = target["identity"]
    if state["present"]:
        local_bindings[identity] = cloned(state["value"])
    else:
        local_bindings.pop(identity, None)


def _shift_composed_write_diagnostic(
    case: dict[str, Any], action: dict[str, Any], diagnostic: dict[str, Any]
) -> dict[str, Any]:
    shifted = cloned(diagnostic)
    span = shifted.get("source_span")
    if span is None:
        return shifted
    source_id, holder = write_vivification.composition_source_holder(case, action)
    offset = holder.index(action["source"])
    span["source_id"] = source_id
    span["start"] += offset
    span["end"] += offset
    if holder[span["start"] : span["end"]] != action["segments"][shifted["segment_index"]]["source"]:
        fail("composition_fixture_invalid", f"case {case['id']} shifted write span drifted")
    return shifted


def _execute_composed_write(
    *,
    case: dict[str, Any],
    action: dict[str, Any],
    bindings: dict[str, Any],
    local_bindings: dict[str, Any],
    callback_frame: dict[str, Any] | None,
    effects: list[str],
    guard_active: bool,
    reserved: set[str],
) -> HookResult | None:
    target = action["target"]
    actual_initial = _composition_binding_state(
        target, bindings, local_bindings, callback_frame
    )
    if actual_initial != action["expected_initial_binding"]:
        fail(
            "composition_initial_state_mismatch",
            f"case {case['id']} expected {action['expected_initial_binding']!r}, got {actual_initial!r}",
        )

    active_identity = f"global:{case['binding']}"
    if guard_active and target["identity"] == active_identity:
        if action.get("execution") != "guarded_before_evaluation":
            fail("composition_fixture_invalid", f"case {case['id']} bypasses the active guard")
        attempt = {
            "attempt": "nested_write",
            "source_span": cloned(action["attempt_span"]),
        }
        raise RuntimeFailure(_reentrant_diagnostic(case["binding"], attempt))
    if action.get("execution") == "guarded_before_evaluation":
        fail("composition_fixture_invalid", f"case {case['id']} expected a guard on another identity")

    synthetic = {
        "id": f"{case['id']}:{action['container']}",
        "source": action["source"],
        "binding": target["name"],
        "initial_binding": actual_initial,
        "segments": action["segments"],
        "rhs": action["rhs"],
    }
    state, result, diagnostic, write_effects = write_vivification.execute_write(
        synthetic, reserved
    )
    if write_effects != action["expected_effects"] or state != action["expected_binding"]:
        fail("composition_write_mismatch", f"case {case['id']} nested write outcome drifted")
    _store_composition_binding_state(
        target, state, bindings, local_bindings, callback_frame
    )
    effects.extend(f"write:{target['name']}:{effect}" for effect in write_effects)

    if diagnostic is not None:
        if "expected_error" not in action or result is not None:
            fail("composition_write_mismatch", f"case {case['id']} unexpected write failure")
        parsed = write_vivification.validate_case_source(synthetic, reserved)
        expected_case = {**synthetic, "expected_error": action["expected_error"]}
        expected = write_vivification.resolve_expected_error(expected_case, parsed)
        if diagnostic != expected:
            fail("composition_write_mismatch", f"case {case['id']} write diagnostic drifted")
        raise RuntimeFailure(_shift_composed_write_diagnostic(case, action, diagnostic))

    if result != action.get("expected_result"):
        fail("composition_write_mismatch", f"case {case['id']} write result drifted")
    if isinstance(result, (dict, list)) and state.get("value") is result:
        fail("composition_alias_detected", f"case {case['id']} write result aliases binding")
    return HookResult(cloned(result))


def _validate_composition_frame(frame: Any, label: str) -> None:
    if not isinstance(frame, dict):
        fail("composition_fixture_invalid", f"{label} must be an object")
    common = {"value", "path", "depth"}
    selector = set(frame) - common
    if common - set(frame) or selector not in ({"key"}, {"index"}):
        fail("composition_fixture_invalid", f"{label} fields drifted")
    if not isinstance(frame["path"], list) or frame["depth"] != len(frame["path"]):
        fail("composition_fixture_invalid", f"{label} path/depth drifted")


def _expected_composed_write_diagnostic(
    case: dict[str, Any], action: dict[str, Any], reserved: set[str]
) -> dict[str, Any]:
    synthetic = {
        "id": f"{case['id']}:{action['container']}",
        "source": action["source"],
        "binding": action["target"]["name"],
        "initial_binding": action["expected_initial_binding"],
        "segments": action["segments"],
        "rhs": action["rhs"],
    }
    parsed = write_vivification.validate_case_source(synthetic, reserved)
    expected_case = {**synthetic, "expected_error": action["expected_error"]}
    diagnostic = write_vivification.resolve_expected_error(expected_case, parsed)
    return _shift_composed_write_diagnostic(case, action, diagnostic)


def _validate_composition_case(
    case: dict[str, Any],
    *,
    continuation_case: bool,
    reserved: set[str],
) -> None:
    parsed = parse_mutation(case["source"], case["id"])
    if parsed["receiver"]["name"] != case["binding"]:
        fail("composition_fixture_invalid", f"case {case['id']} receiver drifted")
    helper_sources = case["helper_sources"]
    if not isinstance(helper_sources, dict) or not all(
        isinstance(name, str) and isinstance(source, str)
        for name, source in helper_sources.items()
    ):
        fail("composition_fixture_invalid", f"case {case['id']} helper sources drifted")
    if not isinstance(case["initial_locals"], dict) or not isinstance(
        case["expected_locals"], dict
    ):
        fail("composition_fixture_invalid", f"case {case['id']} local stores drifted")

    for index, step in enumerate(case["callback_steps"]):
        if not isinstance(step, dict):
            fail("composition_fixture_invalid", f"case {case['id']} callback {index} drifted")
        _validate_composition_frame(step.get("frame"), f"case {case['id']} callback {index}.frame")
        if step.get("result_source") not in {None, "write_result", "literal"}:
            fail("composition_fixture_invalid", f"case {case['id']} callback result source drifted")
        if step.get("result_source") == "write_result" and "write" not in step:
            fail("composition_fixture_invalid", f"case {case['id']} callback lacks result write")
        if step.get("result_source") == "literal" and "result" not in step:
            fail("composition_fixture_invalid", f"case {case['id']} callback lacks literal result")
        if "error" in step:
            validate_runtime_diagnostic(step["error"], f"case {case['id']} callback {index}.error")

    local_bindings = cloned(case["initial_locals"])

    def callback_hook(
        step: dict[str, Any],
        frame: dict[str, Any],
        bindings: dict[str, Any],
        effects: list[str],
    ) -> HookResult | None:
        if "write" not in step:
            return None
        outcome = _execute_composed_write(
            case=case,
            action=step["write"],
            bindings=bindings,
            local_bindings=local_bindings,
            callback_frame=frame,
            effects=effects,
            guard_active=True,
            reserved=reserved,
        )
        return outcome if step.get("result_source") == "write_result" else None

    continuation_calls: list[dict[str, Any]] = []
    continuation_hook = None
    if continuation_case:
        continuation = case["continuation"]
        methods = [call["method"] for call in parsed["continuation"]]
        if methods != [continuation["method"]]:
            fail("composition_fixture_invalid", f"case {case['id']} continuation source drifted")
        continuation_calls = [
            {
                "method": continuation["method"],
                "expected_input": continuation["expected_input"],
                "result": None,
            }
        ]

        def run_continuation(
            call: dict[str, Any],
            _current: Any,
            bindings: dict[str, Any],
            effects: list[str],
        ) -> HookResult | None:
            if call["method"] != continuation["method"]:
                fail("composition_fixture_invalid", f"case {case['id']} continuation method drifted")
            return _execute_composed_write(
                case=case,
                action=continuation["write"],
                bindings=bindings,
                local_bindings=local_bindings,
                callback_frame=None,
                effects=effects,
                guard_active=False,
                reserved=reserved,
            )

        continuation_hook = run_continuation
    elif parsed["continuation"]:
        fail("composition_fixture_invalid", f"case {case['id']} has unowned continuation")

    result = run_invocation(
        source=case["source"],
        case_id=case["id"],
        binding=case["binding"],
        bindings=case["initial_bindings"],
        callback_steps=case["callback_steps"],
        continuation=continuation_calls,
        callback_hook=callback_hook,
        continuation_hook=continuation_hook,
    )
    if result.bindings != case["expected_bindings"]:
        fail("composition_binding_mismatch", f"case {case['id']} bindings drifted")
    if local_bindings != case["expected_locals"]:
        fail("composition_binding_mismatch", f"case {case['id']} locals drifted")
    if result.effects != case["expected_effects"]:
        fail("composition_effect_mismatch", f"case {case['id']} effects drifted")

    if "expected_diagnostic" in case:
        validate_expected_diagnostic(case["expected_diagnostic"], f"case {case['id']}.diagnostic")
        expected_diagnostic = case["expected_diagnostic"]
    elif case.get("expected_diagnostic_source") == "write":
        action = (
            case["continuation"]["write"]
            if continuation_case
            else next(step["write"] for step in case["callback_steps"] if "expected_error" in step.get("write", {}))
        )
        expected_diagnostic = _expected_composed_write_diagnostic(case, action, reserved)
    else:
        expected_diagnostic = None

    if result.diagnostic != expected_diagnostic:
        fail("composition_diagnostic_mismatch", f"case {case['id']} diagnostic drifted")
    if expected_diagnostic is None:
        if result.result != case["expected_result"]:
            fail("composition_result_mismatch", f"case {case['id']} result drifted")
    elif result.result is not None:
        fail("composition_result_mismatch", f"case {case['id']} failure returned a result")


def validate_composition_contract(
    composition: dict[str, Any],
    map_contract: dict[str, Any],
    write_contract: dict[str, Any],
) -> None:
    if not isinstance(composition, dict):
        fail("composition_schema_invalid", "composition root must be an object")
    if hashlib.sha256(canonical_json(composition).encode("utf-8")).hexdigest() != EXPECTED_COMPOSITION_DIGEST:
        fail("composition_semantics_drifted", "composition contract digest changed")
    require_fields(
        composition,
        {
            "format",
            "contract_id",
            "status",
            "requires",
            "policy",
            "callback_cases",
            "continuation_cases",
            "current_boundary",
        },
        "composition",
    )
    if (
        composition["format"] != 1
        or composition["contract_id"] != "linkedspec-write-map-leaves-composition-v1"
        or composition["status"] != "future-neutral-composition; no backend behavior admitted"
    ):
        fail("composition_schema_invalid", "composition identity/status drifted")
    expected_requires = {
        "write_vivification": {
            "contract_id": "linkedspec-write-vivification-v1",
            "path": "capability_conformance/write_vivification_contract.json",
            "canonical_json_sha256": write_vivification.canonical_json_sha256(write_contract),
        },
        "map_leaves_mutation": {
            "contract_id": "linkedspec-map-leaves-mutation-v1",
            "path": "capability_conformance/map_leaves_mutation_contract.json",
            "canonical_json_sha256": hashlib.sha256(
                canonical_json(map_contract).encode("utf-8")
            ).hexdigest(),
        },
    }
    if composition["requires"] != expected_requires:
        fail("composition_reference_drifted", "composition prerequisite references drifted")
    if set(case["id"] for case in composition["callback_cases"]) != EXPECTED_COMPOSITION_CALLBACK_IDS:
        fail("composition_case_ids_invalid", "callback composition ids drifted")
    if set(case["id"] for case in composition["continuation_cases"]) != EXPECTED_COMPOSITION_CONTINUATION_IDS:
        fail("composition_case_ids_invalid", "continuation composition ids drifted")

    write_vivification.validate_composition_write_surfaces(composition, write_contract)
    reserved = set(write_contract["syntax"]["reserved_root_names"])
    for case in composition["callback_cases"]:
        _validate_composition_case(case, continuation_case=False, reserved=reserved)
    for case in composition["continuation_cases"]:
        _validate_composition_case(case, continuation_case=True, reserved=reserved)

    boundary = composition["current_boundary"]
    require_fields(
        boundary,
        {
            "id",
            "source",
            "nonbang_control_source",
            "expected_nonbang_result",
            "failure_stage",
            "routes",
        },
        "composition.current_boundary",
    )
    if (
        boundary["id"] != "composed_source_stops_at_bang_token"
        or boundary["failure_stage"] != "action_parse_before_callback_nested_write_lowering"
        or "tree.map_leaves!()" not in boundary["source"]
        or 'value[0]["path"] = path' not in boundary["source"]
        or "Top::\n -> Done" not in boundary["source"]
        or "Top::\n /x/ -> Done" in boundary["source"]
        or "tree.map_leaves!()" in boundary["nonbang_control_source"]
        or "tree.map_leaves()" not in boundary["nonbang_control_source"]
        or "Top::\n -> Done" not in boundary["nonbang_control_source"]
        or "Top::\n /x/ -> Done" in boundary["nonbang_control_source"]
        or boundary["expected_nonbang_result"] != {"leaf": []}
    ):
        fail("composition_current_boundary_drifted", "current boundary fixture drifted")
    routes = [
        (route["route"], route["expected_exit"], route["expected_classification"])
        for route in boundary["routes"]
    ]
    if routes != EXPECTED_CURRENT_BOUNDARY_ROUTES:
        fail("composition_current_boundary_drifted", "six-runtime boundary matrix drifted")


def mutated_composition_contracts(
    composition: dict[str, Any]
) -> list[tuple[str, dict[str, Any]]]:
    mutations: list[tuple[str, dict[str, Any]]] = []

    def visit(node: Any, path: tuple[Any, ...]) -> None:
        if isinstance(node, (dict, list)):
            changed = cloned(composition)
            changed_node: Any = changed
            for segment in path:
                changed_node = changed_node[segment]
            if isinstance(changed_node, dict):
                changed_node["__mutation"] = True
            else:
                changed_node.append("__mutation")
            label = "/".join(str(segment) for segment in path) or "root"
            mutations.append((f"{label}:shape", changed))
        if isinstance(node, dict):
            for key, child in node.items():
                visit(child, (*path, key))
            return
        if isinstance(node, list):
            for index, child in enumerate(node):
                visit(child, (*path, index))
            return
        changed = cloned(composition)
        cursor: Any = changed
        for segment in path[:-1]:
            cursor = cursor[segment]
        cursor[path[-1]] = _mutate_scalar(node)
        mutations.append(("/".join(str(segment) for segment in path), changed))

    visit(composition, ())
    return mutations


def _mutate_scalar(value: Any) -> Any:
    if isinstance(value, bool):
        return not value
    if isinstance(value, int):
        return value + 1
    if isinstance(value, str):
        return value + "__mutation"
    if isinstance(value, list):
        return [*value, "__mutation"]
    if isinstance(value, dict):
        changed = cloned(value)
        changed["__mutation"] = True
        return changed
    return "__mutation"


def mutated_contracts(contract: dict[str, Any]) -> list[tuple[str, dict[str, Any]]]:
    mutations: list[tuple[str, dict[str, Any]]] = []

    for section in ("policy", "syntax", "ast", "diagnostics"):
        for key in contract[section]:
            changed = cloned(contract)
            changed[section][key] = _mutate_scalar(changed[section][key])
            mutations.append((f"{section}.{key}", changed))

    changed = cloned(contract)
    changed["format"] = 2
    mutations.append(("format", changed))
    changed = cloned(contract)
    changed["contract_id"] += "-changed"
    mutations.append(("contract_id", changed))
    changed = cloned(contract)
    changed["status"] = "admitted"
    mutations.append(("status", changed))

    for field in EXPECTED_IDS:
        for index, case in enumerate(contract[field]):
            changed = cloned(contract)
            changed[field][index]["id"] = case["id"] + "__mutation"
            mutations.append((f"{field}.{case['id']}.id", changed))

    for field in EXPECTED_SPECIAL_IDS:
        changed = cloned(contract)
        changed[field]["id"] += "__mutation"
        mutations.append((f"{field}.id", changed))

    for index, case in enumerate(contract["valid_syntax_cases"]):
        changed = cloned(contract)
        if "expected_ast" in case:
            changed["valid_syntax_cases"][index]["expected_ast"]["kind"] = "fluent_chain"
        else:
            changed["valid_syntax_cases"][index]["expected_receiver"] += "x"
        mutations.append((f"valid.{case['id']}.expected", changed))

    for index, case in enumerate(contract["invalid_syntax_cases"]):
        changed = cloned(contract)
        changed["invalid_syntax_cases"][index]["diagnostic"]["code"] += "__mutation"
        mutations.append((f"invalid.{case['id']}.diagnostic", changed))

    for index, case in enumerate(contract["excluded_syntax_cases"]):
        changed = cloned(contract)
        changed["excluded_syntax_cases"][index]["classification"] += "__mutation"
        mutations.append((f"excluded.{case['id']}.classification", changed))

    for field in ("success_cases", "failure_cases"):
        for index, case in enumerate(contract[field]):
            changed = cloned(contract)
            changed[field][index]["expected_effects"] = [
                *changed[field][index]["expected_effects"],
                "__mutation",
            ]
            mutations.append((f"{field}.{case['id']}.effects", changed))

            changed = cloned(contract)
            changed[field][index]["expected_bindings"]["__mutation"] = True
            mutations.append((f"{field}.{case['id']}.bindings", changed))

    for field in (
        "continuation_failure_case",
        "shadow_binding_case",
        "guard_release_case",
    ):
        changed = cloned(contract)
        changed[field]["expected_effects"] = [*changed[field]["expected_effects"], "__mutation"]
        mutations.append((f"{field}.effects", changed))

    changed = cloned(contract)
    changed["nonbang_isolation_case"]["expected_binding"] = {}
    mutations.append(("nonbang_isolation_case.expected_binding", changed))
    changed = cloned(contract)
    changed["detachment_case"]["expected_each_other_boundary_unchanged"] = False
    mutations.append(("detachment_case.boundary", changed))
    return mutations


def load_contract() -> dict[str, Any]:
    try:
        loaded = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail("contract_load_failed", str(error))
    if not isinstance(loaded, dict):
        fail("contract_schema_invalid", "contract root must be an object")
    return loaded


def load_json_object(path: Path, label: str) -> dict[str, Any]:
    try:
        loaded = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail("contract_load_failed", f"{label}: {error}")
    if not isinstance(loaded, dict):
        fail("contract_schema_invalid", f"{label} root must be an object")
    return loaded


def main() -> None:
    contract = load_contract()
    validate_contract(contract)
    write_contract = load_json_object(WRITE_CONTRACT_PATH, "write contract")
    write_vivification.validate_contract(write_contract)
    composition = load_json_object(COMPOSITION_PATH, "composition contract")
    validate_composition_contract(composition, contract, write_contract)
    mutations = mutated_contracts(contract)
    rejected = 0
    for label, changed in mutations:
        try:
            validate_contract(changed)
        except (ContractError, KeyError, TypeError, IndexError):
            rejected += 1
        else:
            fail("mutation_survived", f"mutation {label!r} unexpectedly passed")
    composition_mutations = mutated_composition_contracts(composition)
    composition_rejected = 0
    for label, changed in composition_mutations:
        try:
            validate_composition_contract(changed, contract, write_contract)
        except (ContractError, write_vivification.ContractError, KeyError, TypeError, IndexError):
            composition_rejected += 1
        else:
            fail("mutation_survived", f"composition mutation {label!r} unexpectedly passed")
    print(
        "map_leaves! mutation contract: "
        f"{len(contract['valid_syntax_cases'])} valid syntax, "
        f"{len(contract['invalid_syntax_cases'])} invalid syntax, "
        f"{len(contract['excluded_syntax_cases'])} exclusions, "
        f"{len(contract['success_cases'])} success, "
        f"{len(contract['failure_cases'])} pre-commit failures, "
        "continuation/shadow/guard/nonbang/detachment proof, "
        f"{len(composition['callback_cases'])} callback compositions, "
        f"{len(composition['continuation_cases'])} continuation composition, "
        f"{rejected} base + {composition_rejected} composition mutations rejected; "
        "future behavior remains unadmitted"
    )


if __name__ == "__main__":
    main()

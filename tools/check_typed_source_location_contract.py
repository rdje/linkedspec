#!/usr/bin/env python3
"""Validate the backend-neutral typed source-location algebra contract."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "typed_source_location_contract.json"
CHECKER_PATH = ROOT / "tools" / "check_typed_source_location_contract.py"
LUA_CONTRACTS_PATH = ROOT / "lua" / "src" / "linkedspec" / "action_contracts.lua"
PERL_CONTRACTS_PATH = ROOT / "perl" / "LinkedSpec" / "ActionIR" / "Contracts.pm"
PERL_LEGACY_SCANNER_PATH = (
    ROOT / "perl" / "LinkedSpec" / "ActionIR" / "Scanner" / "LegacyRules.pm"
)
CI_PATH = ROOT / "tools" / "run_ci_local.sh"
PERL_VALUE_CONSUMER_PATH = ROOT / "t" / "typed_source_location_values.t"
PERL_PROJECTION_CONSUMER_PATH = ROOT / "t" / "typed_source_location_perl_contract.t"
RUST_CONSUMER_PATH = (
    ROOT / "rust" / "linkedspec-runtime" / "tests" / "typed_source_location_contract.rs"
)
DART_CONSUMER_PATH = (
    ROOT / "dart" / "test" / "typed_source_location_contract_test.dart"
)
DART_DORMANT_CONSUMER_PATH = (
    ROOT / "dart" / "test_dormant" / "typed_source_location_contract_test.dart"
)
JULIA_CONSUMER_PATH = ROOT / "julia" / "test" / "typed_source_location_contract_test.jl"
JULIA_RUNTESTS_PATH = ROOT / "julia" / "test" / "runtests.jl"
LUA_CONSUMER_PATH = ROOT / "lua" / "test" / "typed_source_location_contract_test.lua"
LUA_ORDINARY_DRIVER_PATH = ROOT / "tools" / "run_lua_local.sh"
RECURRING_DRIVER_PATH = ROOT / "tools" / "check_typed_source_location_six_runtime.sh"

EXPECTED_COUNTS = {
    "sources": 3,
    "position_conversions": 7,
    "direct_spans": 6,
    "derived_text_cases": 3,
    "invocation_transitions": 8,
    "transaction_transitions": 8,
    "recursive_observations": 6,
    "structural_authoring_cases": 4,
    "helper_projections": 92,
    "compatibility_aliases": 7,
    "internal_contract_ids": 2,
    "diagnostics": 31,
    "rollout_legs": 14,
    "recurring_source_groups": 5,
    "recurring_runtime_routes": 6,
    "mutations": 53,
}

POLICY = {
    "source_identity": "caller-authorized decoded input identity; never a path, backend object, or implicit read authority",
    "position": "immutable source identity plus a zero-based Unicode-scalar offset in the closed input interval",
    "span": "immutable same-source half-open interval with start not greater than end; empty spans are valid",
    "coordinates": "Unicode-scalar offset is authoritative; one-based line and column plus UTF-8 byte offset are derived evidence",
    "direct_text": "materialize text on demand from one direct span; a span never embeds copied text or host state",
    "derived_text": "concatenate an ordered provenance sequence explicitly; never pretend derived text is one contiguous interval",
    "invocation_state": "cursor, anonymous boundary, and marks are mutable only inside one invocation; public projections are immutable",
    "transactions": "one bounded recognition-only attempt snapshots cursor, boundary, and marks; commit or rollback invalidates its token",
    "transaction_effects": "rollback never restores user variables, AST mutation, diagnostics, output, external calls, registry effects, or host state",
    "recursion": "entry, selected-match, and accepted-exit observations are read-only; absence is explicit and parent links are bounded",
    "progress": "repetition, recursion, and staged queues must advance the cursor or prove a well-founded decreasing measure",
    "dispatch_authority": "a span conveys data and provenance only; source, registry, capability, and policy authority remain independently required",
    "source_spelling": "not selected; Position, Span, checkpoint, try, commit, and rollback are architectural names only",
    "implementation_boundary": "no backend runtime value, helper spelling, descriptor/schema version, semantic/MCP projection, or parser behavior is admitted by this contract",
}

CANONICAL_EXECUTION = {
    "contract_path": "capability_conformance/typed_source_location_contract.json",
    "checker_path": "tools/check_typed_source_location_contract.py",
    "project_data_runner": "tools/run_python_project_data.sh",
    "canonical_driver": "tools/run_ci_local.sh",
    "invocation": "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py",
    "tracked_required": True,
}

RECURRING_GATE = {
    "driver": "tools/check_typed_source_location_six_runtime.sh",
    "source_schema": {
        "fields": ["backend", "paths"],
        "policy": "five backend source groups are immutable; Perl owns its separate value and projection tests and Lua owns one source shared by both ABIs",
    },
    "consumer_sources": [
        {
            "backend": "perl",
            "paths": [
                "t/typed_source_location_values.t",
                "t/typed_source_location_perl_contract.t",
            ],
        },
        {
            "backend": "rust",
            "paths": [
                "rust/linkedspec-runtime/tests/typed_source_location_contract.rs"
            ],
        },
        {
            "backend": "dart",
            "paths": ["dart/test/typed_source_location_contract_test.dart"],
        },
        {
            "backend": "julia",
            "paths": ["julia/test/typed_source_location_contract_test.jl"],
        },
        {
            "backend": "lua",
            "paths": ["lua/test/typed_source_location_contract_test.lua"],
        },
    ],
    "route_schema": {
        "fields": ["runtime", "source_backend", "command"],
        "policy": "neutral runs first; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT then run exactly once in order",
    },
    "runtime_routes": [
        {
            "runtime": "perl",
            "source_backend": "perl",
            "command": "PERL5LIB= prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t",
        },
        {
            "runtime": "rust",
            "source_backend": "rust",
            "command": '"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract',
        },
        {
            "runtime": "dart",
            "source_backend": "dart",
            "command": "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart",
        },
        {
            "runtime": "julia",
            "source_backend": "julia",
            "command": "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/typed_source_location_contract_test.jl\")'",
        },
        {
            "runtime": "puc_lua",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua",
        },
        {
            "runtime": "luajit",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua",
        },
    ],
    "support_checks": [
        "perl tools/check_generated_source_contract.pl",
        "perl tools/check_capability_conformance.pl",
        "perl tools/check_language_capability_coverage.pl",
    ],
    "local_ci": {
        "driver": "tools/run_ci_local.sh",
        "switch": "LINKEDSPEC_RUN_TYPED_SOURCE_MATRIX",
    },
}

HELPER_GROUPS = {
    "capture_mark": "CAPTURE_MARK_HELPERS",
    "entry_match": "ENTRY_MATCH_HELPERS",
    "input_cursor": "INPUT_HELPERS",
    "cursor_control": "RUNTIME_HELPERS",
}

PROJECTION_VOCABULARY = [
    "capture_boundary_write_position",
    "capture_group_exists",
    "capture_group_list",
    "capture_group_map",
    "capture_group_text",
    "cursor_checkpoint_compatibility",
    "cursor_position",
    "cursor_state_write_compatibility",
    "mark_delete",
    "mark_exists",
    "mark_read_column",
    "mark_read_line",
    "mark_read_offset",
    "mark_write_position",
    "position_column",
    "position_line",
    "position_offset",
    "source_length",
    "source_slice_text",
    "source_text",
    "span_length",
    "span_start_column",
    "span_start_line",
    "span_start_offset",
    "span_text",
]

ALIASES = [
    ("capture_from_rule_start", "capture_slice"),
    ("capture_len_from_rule_start", "capture_slice_len"),
    ("capture_rest_length", "capture_rest_len"),
    ("capture_slice_here", "start_capture_slice"),
    ("capture_slice_length", "capture_slice_len"),
    ("entry_named_map", "entry_map"),
    ("match_named_map", "match_map"),
]


def extract_perl_contract_record(source: str, helper: str) -> str:
    record = re.search(
        rf"\n  \{{\n\s*id\s*=>\s*'{re.escape(helper)}',(?P<body>.*?)\n  \}},",
        source,
        re.DOTALL,
    )
    if record is None:
        fail(f"Perl contract authority is missing helper record {helper!r}")
    return record.group(0)


def extract_perl_record_field(record: str, helper: str, field: str) -> str:
    value = re.search(rf"\b{re.escape(field)}\s*=>\s*'([^']+)'", record)
    if value is None:
        fail(f"Perl helper record {helper!r} is missing field {field!r}")
    return value.group(1)


def extract_perl_runtime_calls(record: str) -> list[str]:
    return re.findall(r"LinkedSpec::SourceLocation::Runtime::([a-z_]+)\s*\(", record)

INTERNAL_CONTRACT_IDS = [
    ("capture_take_slice", "capture_take"),
    ("capture_take_slice_len", "capture_take_len"),
]

RECURSIVE_OBSERVATIONS = [
    ("ordinary_leaf", "leaf-1", "root-1", "unicode", 2, "unicode_emoji_tail", 4, "accepted", None),
    ("zero_regex_coordinator", "root-2", None, "unicode", 0, None, 4, "accepted", None),
    ("failed_selection", "leaf-2", "root-3", "unicode", 0, None, None, "failed", None),
    ("abnormal_exit", "leaf-3", "root-4", "unicode", 2, "unicode_emoji_tail", None, "aborted", None),
    (
        "direct_nonprogress",
        "recursive-1",
        "recursive-1",
        "unicode",
        1,
        None,
        None,
        "rejected",
        "source_location_nonprogress_direct_recursion",
    ),
    (
        "mutual_nonprogress",
        "recursive-a",
        "recursive-b",
        "unicode",
        1,
        None,
        None,
        "rejected",
        "source_location_nonprogress_mutual_recursion",
    ),
]

STRUCTURAL_CASES = [
    (
        "zero_regex_coordinator",
        0,
        "coordinator",
        True,
        "linked_rule_graph",
        "coordinate child rules without embedding a boundary regex",
    ),
    (
        "one_regex_leaf",
        1,
        "leaf",
        True,
        "linked_rule_graph",
        "recognize one small boundary or token",
    ),
    (
        "two_regex_recursive_node",
        2,
        "start_end_node",
        True,
        "linked_rule_graph",
        "recognize start and end boundaries while recursion stays in graph edges",
    ),
    (
        "regex_bearing_entry",
        1,
        "selected_entry",
        True,
        "linked_rule_graph",
        "a selected top rule may itself own an ordinary regex",
    ),
]

INVOCATION_ARG_FIELDS = {
    "enter": [
        "invocation_id",
        "rule_label",
        "source_id",
        "parent_invocation_id",
        "cursor",
    ],
    "set_cursor": ["invocation_id", "offset"],
    "set_boundary": ["invocation_id", "offset"],
    "set_mark": ["invocation_id", "name", "offset", "generation"],
    "accept": ["invocation_id"],
}

TRANSACTION_ARG_FIELDS = {
    "checkpoint": ["token"],
    "try_cursor": ["token", "offset"],
    "try_boundary": ["token", "offset"],
    "try_mark": ["token", "name", "offset"],
    "try_state": ["token", "cursor", "anonymous_boundary", "marks"],
    "commit": ["token"],
    "rollback": ["token"],
}

VALUE_CONTEXT = ["rule_role", "invocation_role", "source_id"]
PROGRESS_CONTEXT = [
    "rule_role",
    "invocation_role",
    "source_id",
    "start_offset",
    "end_offset",
    "originating_edge_or_job",
]
DIAGNOSTICS = [
    ("source_mismatch", "validate_value", "runtime", VALUE_CONTEXT + ["other_source_id"]),
    (
        "position_out_of_range",
        "validate_value",
        "runtime",
        VALUE_CONTEXT + ["position_offset", "source_length"],
    ),
    ("reversed_span", "validate_value", "runtime", VALUE_CONTEXT + ["start_offset", "end_offset"]),
    (
        "invalid_derived_provenance",
        "validate_value",
        "runtime",
        ["rule_role", "invocation_role", "provenance_index", "source_id"],
    ),
    ("unknown_mark", "read_mark", "runtime", VALUE_CONTEXT + ["mark_name"]),
    ("stale_mark", "read_mark", "runtime", VALUE_CONTEXT + ["mark_name", "mark_generation"]),
    (
        "cross_invocation_mark",
        "read_mark",
        "runtime",
        VALUE_CONTEXT + ["mark_name", "owner_invocation_id"],
    ),
    (
        "invalidated_mark",
        "read_mark",
        "runtime",
        VALUE_CONTEXT + ["mark_name", "mark_generation"],
    ),
    (
        "unknown_transaction_token",
        "transaction",
        "runtime",
        VALUE_CONTEXT + ["transaction_token"],
    ),
    (
        "stale_transaction_token",
        "transaction",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "transaction_generation"],
    ),
    (
        "cross_invocation_transaction_token",
        "transaction",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "owner_invocation_id"],
    ),
    (
        "invalidated_transaction_token",
        "transaction",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "transaction_generation"],
    ),
    (
        "transaction_nesting",
        "transaction",
        "static_or_runtime",
        VALUE_CONTEXT + ["transaction_token"],
    ),
    (
        "transaction_escape",
        "transaction",
        "static_or_runtime",
        VALUE_CONTEXT + ["transaction_token", "originating_edge_or_job"],
    ),
    ("transaction_double_commit", "commit", "runtime", VALUE_CONTEXT + ["transaction_token"]),
    ("transaction_double_rollback", "rollback", "runtime", VALUE_CONTEXT + ["transaction_token"]),
    (
        "effect_before_commit",
        "try",
        "static_or_runtime",
        VALUE_CONTEXT + ["transaction_token", "effect_family"],
    ),
    (
        "cross_rule_restore",
        "rollback",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "owner_rule_role"],
    ),
    (
        "cross_source_restore",
        "rollback",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "owner_source_id"],
    ),
    ("cursor_regression", "advance", "static_or_runtime", PROGRESS_CONTEXT),
    ("nullable_repetition", "progress", "static_or_runtime", PROGRESS_CONTEXT),
    ("nonprogress_direct_recursion", "progress", "static_or_runtime", PROGRESS_CONTEXT),
    ("nonprogress_mutual_recursion", "progress", "static_or_runtime", PROGRESS_CONTEXT),
    ("staged_dispatch_cycle", "progress", "static_or_runtime", PROGRESS_CONTEXT),
    (
        "recursive_boundary_unavailable",
        "observe_recursion",
        "runtime",
        VALUE_CONTEXT + ["boundary_role", "originating_edge_or_job"],
    ),
    (
        "ambiguous_regex_slot",
        "resolve_slot",
        "static",
        ["rule_role", "source_id", "slot_reference", "originating_edge_or_job"],
    ),
    (
        "stale_regex_slot",
        "resolve_slot",
        "static",
        ["rule_role", "source_id", "slot_reference", "originating_edge_or_job"],
    ),
    (
        "span_dispatch_source_denied",
        "dispatch",
        "runtime",
        VALUE_CONTEXT + ["span_start", "span_end", "originating_edge_or_job"],
    ),
    (
        "span_dispatch_registry_denied",
        "dispatch",
        "runtime",
        VALUE_CONTEXT + ["parser_identity", "originating_edge_or_job"],
    ),
    (
        "span_dispatch_capability_denied",
        "dispatch",
        "runtime",
        VALUE_CONTEXT + ["parser_identity", "capability", "originating_edge_or_job"],
    ),
    (
        "span_dispatch_policy_denied",
        "dispatch",
        "runtime",
        VALUE_CONTEXT + ["parser_identity", "policy", "originating_edge_or_job"],
    ),
]

ROLLOUT = [
    ("neutral_contract", "complete", "FUTURE-PARITY-BACKLOG.14.1.1", []),
    ("public_structure", "complete", "FUTURE-PARITY-BACKLOG.14.1.2", []),
    ("neutral_public_recomposition", "complete", "FUTURE-PARITY-BACKLOG.14.1.3", []),
    ("perl_runtime", "complete", "FUTURE-PARITY-BACKLOG.14.2.1.3", ["perl"]),
    ("rust_runtime", "complete", "FUTURE-PARITY-BACKLOG.14.2.2.3", ["rust"]),
    ("dart_runtime", "complete", "FUTURE-PARITY-BACKLOG.14.2.3.3", ["dart"]),
    ("julia_runtime", "complete", "FUTURE-PARITY-BACKLOG.14.2.4.3", ["julia"]),
    ("lua_dual_abi", "complete", "FUTURE-PARITY-BACKLOG.14.2.5.3", ["puc_lua", "luajit"]),
    ("transaction_safety", "pending", "FUTURE-PARITY-BACKLOG.14.3", []),
    ("recursive_observation", "pending", "FUTURE-PARITY-BACKLOG.14.4", []),
    ("lossless_gap_composition", "pending", "FUTURE-PARITY-BACKLOG.14.5", []),
    ("progressive_span_dispatch", "pending", "FUTURE-PARITY-BACKLOG.14.6", []),
    ("staged_span_dispatch", "pending", "FUTURE-PARITY-BACKLOG.14.7", []),
    (
        "recurring_public_no_drift",
        "pending",
        "FUTURE-PARITY-BACKLOG.14.8",
        ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    ),
]


class ContractError(ValueError):
    """Stable neutral-contract validation failure."""


def fail(detail: str) -> None:
    raise ContractError(detail)


def require_fields(value: Any, fields: list[str] | set[str], context: str) -> dict[str, Any]:
    if not isinstance(value, dict) or list(value) != list(fields):
        fail(f"{context} fields or order drifted")
    return value


def require_list(value: Any, context: str, length: int | None = None) -> list[Any]:
    if not isinstance(value, list):
        fail(f"{context} must be a list")
    if length is not None and len(value) != length:
        fail(f"{context} count drifted")
    return value


def position_coordinates(text: str, offset: int) -> tuple[int, int, int]:
    if not isinstance(offset, int) or isinstance(offset, bool) or offset < 0 or offset > len(text):
        fail(f"position offset is outside decoded source: {offset!r}")
    prefix = text[:offset]
    return prefix.count("\n") + 1, len(prefix.rsplit("\n", 1)[-1]) + 1, len(prefix.encode("utf-8"))


def extract_lua_helper_names(source: str, constant_name: str) -> list[str]:
    match = re.search(
        rf"local {re.escape(constant_name)} = make_set\(\{{(.*?)\n\}}\)",
        source,
        re.DOTALL,
    )
    if match is None:
        fail(f"current Lua helper authority is missing {constant_name}")
    return re.findall(r'"([a-z0-9_]+)"', match.group(1))


def expected_projection(name: str, family: str) -> str:
    if family == "capture_mark":
        exact = {
            "capture_slice_col": "span_start_column",
            "capture_slice_line": "span_start_line",
            "capture_slice_pos": "span_start_offset",
            "mark_capture_slice": "capture_boundary_write_position",
            "start_capture_slice": "capture_boundary_write_position",
            "start_capture_slice_from": "capture_boundary_write_position",
            "mark_copy": "mark_write_position",
            "mark_here": "mark_write_position",
            "mark_input_end": "mark_write_position",
            "mark_input_start": "mark_write_position",
            "mark_entry_end": "mark_write_position",
            "mark_entry_start": "mark_write_position",
            "mark_match_end": "mark_write_position",
            "mark_match_start": "mark_write_position",
            "mark_exists": "mark_exists",
            "mark_pos": "mark_read_offset",
            "mark_line": "mark_read_line",
            "mark_col": "mark_read_column",
            "clear_mark": "mark_delete",
        }
        if name in exact:
            return exact[name]
        if name.startswith("capture_"):
            return "span_length" if "_len" in name else "span_text"
    elif family == "entry_match":
        suffix = name.split("_", 1)[1]
        exact_suffix = {
            "group": "capture_group_text",
            "groups": "capture_group_list",
            "has": "capture_group_exists",
            "map": "capture_group_map",
            "named": "capture_group_text",
            "len": "span_length",
            "text": "span_text",
            "col": "span_start_column",
            "line": "span_start_line",
            "start_col": "span_start_column",
            "start_line": "span_start_line",
            "start_pos": "span_start_offset",
            "end_col": "position_column",
            "end_line": "position_line",
            "end_pos": "position_offset",
        }
        if suffix in exact_suffix:
            return exact_suffix[suffix]
    elif family == "input_cursor":
        exact = {
            "cursor_col": "position_column",
            "cursor_line": "position_line",
            "cursor_pos": "cursor_position",
            "cursor_rest": "span_text",
            "cursor_rest_len": "span_length",
            "input_end_col": "position_column",
            "input_end_line": "position_line",
            "input_end_pos": "position_offset",
            "input_len": "source_length",
            "input_slice": "source_slice_text",
            "input_text": "source_text",
        }
        if name in exact:
            return exact[name]
    elif family == "cursor_control":
        exact = {
            "restore_cursor": "cursor_state_write_compatibility",
            "rewind_entry_start": "cursor_state_write_compatibility",
            "rewind_match_start": "cursor_state_write_compatibility",
            "save_cursor": "cursor_checkpoint_compatibility",
        }
        if name in exact:
            return exact[name]
    fail(f"no typed-algebra projection is defined for current helper {name!r}")


def invocation_snapshot(state: dict[str, Any]) -> dict[str, Any]:
    stack = state["stack"]
    if not stack:
        return {
            "active_invocation_id": None,
            "cursor": None,
            "anonymous_boundary": None,
            "mark_names": [],
            "stack_depth": 0,
            "completed_count": state["completed_count"],
        }
    active = stack[-1]
    return {
        "active_invocation_id": active["invocation_id"],
        "cursor": active["cursor"],
        "anonymous_boundary": active["anonymous_boundary"],
        "mark_names": sorted(active["marks"]),
        "stack_depth": len(stack),
        "completed_count": state["completed_count"],
    }


def apply_invocation_transition(state: dict[str, Any], transition: dict[str, Any]) -> None:
    operation = transition["operation"]
    args = transition["args"]
    stack = state["stack"]
    if operation == "enter":
        parent = stack[-1]["invocation_id"] if stack else None
        if args["parent_invocation_id"] != parent:
            fail("invocation parent identity drifted")
        stack.append(
            {
                "invocation_id": args["invocation_id"],
                "rule_label": args["rule_label"],
                "source_id": args["source_id"],
                "parent_invocation_id": args["parent_invocation_id"],
                "cursor": args["cursor"],
                "anonymous_boundary": args["cursor"],
                "marks": {},
            }
        )
        return
    if not stack or stack[-1]["invocation_id"] != args["invocation_id"]:
        fail("invocation transition does not target the active frame")
    active = stack[-1]
    if operation == "set_cursor":
        active["cursor"] = args["offset"]
    elif operation == "set_boundary":
        active["anonymous_boundary"] = args["offset"]
    elif operation == "set_mark":
        active["marks"][args["name"]] = {
            "offset": args["offset"],
            "generation": args["generation"],
        }
    elif operation == "accept":
        accepted = stack.pop()
        state["completed_count"] += 1
        if stack:
            if stack[-1]["source_id"] != accepted["source_id"]:
                fail("accepted child source identity drifted")
            stack[-1]["cursor"] = accepted["cursor"]
    else:
        fail(f"unknown invocation transition operation: {operation!r}")


def transaction_snapshot(state: dict[str, Any], token: str) -> dict[str, Any]:
    token_data = state["tokens"].get(token)
    return {
        "cursor": state["cursor"],
        "anonymous_boundary": state["anonymous_boundary"],
        "marks": [[name, offset] for name, offset in sorted(state["marks"].items())],
        "token": token,
        "token_state": token_data["state"] if token_data else None,
    }


def require_active_token(state: dict[str, Any], token: str) -> dict[str, Any]:
    token_data = state["tokens"].get(token)
    if token_data is None or token_data["state"] != "active":
        fail(f"transaction operation requires active token {token!r}")
    return token_data


def apply_transaction_transition(state: dict[str, Any], transition: dict[str, Any]) -> None:
    operation = transition["operation"]
    args = transition["args"]
    token = args["token"]
    if operation == "checkpoint":
        if any(value["state"] == "active" for value in state["tokens"].values()):
            fail("nested transaction appeared in positive fixture")
        if token in state["tokens"]:
            fail("transaction token was reused")
        state["tokens"][token] = {
            "state": "active",
            "snapshot": {
                "cursor": state["cursor"],
                "anonymous_boundary": state["anonymous_boundary"],
                "marks": copy.deepcopy(state["marks"]),
            },
        }
        return
    token_data = require_active_token(state, token)
    if operation == "try_cursor":
        state["cursor"] = args["offset"]
    elif operation == "try_boundary":
        state["anonymous_boundary"] = args["offset"]
    elif operation == "try_mark":
        state["marks"][args["name"]] = args["offset"]
    elif operation == "try_state":
        state["cursor"] = args["cursor"]
        state["anonymous_boundary"] = args["anonymous_boundary"]
        state["marks"] = dict(args["marks"])
    elif operation == "commit":
        token_data["state"] = "invalidated"
    elif operation == "rollback":
        snapshot = token_data["snapshot"]
        state["cursor"] = snapshot["cursor"]
        state["anonymous_boundary"] = snapshot["anonymous_boundary"]
        state["marks"] = copy.deepcopy(snapshot["marks"])
        token_data["state"] = "invalidated"
    else:
        fail(f"unknown transaction transition operation: {operation!r}")


def validate_contract(contract: dict[str, Any], *, check_registration: bool = True) -> None:
    top_fields = [
        "format",
        "contract_id",
        "task_owner",
        "status",
        "expected_counts",
        "policy",
        "canonical_execution",
        "sources",
        "position_conversions",
        "direct_spans",
        "derived_text_cases",
        "invocation_state_machine",
        "transaction_state_machine",
        "recursive_observations",
        "structural_authoring_cases",
        "helper_projection_schema",
        "helper_projections",
        "compatibility_aliases",
        "internal_contract_ids",
        "diagnostic_schema",
        "diagnostics",
        "recurring_gate",
        "rollout",
    ]
    require_fields(contract, top_fields, "contract")
    if contract["format"] != 1:
        fail("format drifted")
    if contract["contract_id"] != "linkedspec-typed-source-location-v1":
        fail("contract id drifted")
    if contract["task_owner"] != "FUTURE-PARITY-BACKLOG.14.1.1":
        fail("task owner drifted")
    if contract["status"] != "neutral_contract_only":
        fail("neutral-only status drifted")
    if contract["expected_counts"] != EXPECTED_COUNTS:
        fail("expected counts drifted")
    if contract["policy"] != POLICY:
        fail("typed source-location policy drifted")
    if contract["canonical_execution"] != CANONICAL_EXECUTION:
        fail("canonical execution contract drifted")

    sources = require_list(contract["sources"], "sources", EXPECTED_COUNTS["sources"])
    source_by_id: dict[str, dict[str, Any]] = {}
    for source in sources:
        require_fields(
            source,
            ["id", "decoded_text", "unicode_scalar_length", "utf8_byte_length"],
            "source",
        )
        source_id = source["id"]
        if not isinstance(source_id, str) or not source_id or source_id in source_by_id:
            fail("source identity is missing or duplicated")
        text = source["decoded_text"]
        if not isinstance(text, str):
            fail(f"decoded source {source_id!r} is not text")
        if source["unicode_scalar_length"] != len(text):
            fail(f"Unicode-scalar length drifted for source {source_id!r}")
        if source["utf8_byte_length"] != len(text.encode("utf-8")):
            fail(f"UTF-8 byte length drifted for source {source_id!r}")
        source_by_id[source_id] = source
    if list(source_by_id) != ["unicode", "ascii", "parts"]:
        fail("source identity order drifted")

    positions = require_list(
        contract["position_conversions"],
        "position conversions",
        EXPECTED_COUNTS["position_conversions"],
    )
    expected_position_ids = [
        "unicode_start",
        "unicode_after_e_acute",
        "unicode_line_two",
        "unicode_after_emoji",
        "unicode_end",
        "ascii_middle",
        "parts_line_two",
    ]
    for expected_id, position in zip(expected_position_ids, positions, strict=True):
        require_fields(
            position,
            ["id", "source_id", "offset", "line", "column", "utf8_byte_offset"],
            "position conversion",
        )
        if position["id"] != expected_id:
            fail("position conversion order drifted")
        source = source_by_id.get(position["source_id"])
        if source is None:
            fail(f"position references unknown source: {position['source_id']!r}")
        coordinates = position_coordinates(source["decoded_text"], position["offset"])
        if coordinates != (position["line"], position["column"], position["utf8_byte_offset"]):
            fail(f"derived coordinates drifted for position {position['id']!r}")

    spans = require_list(contract["direct_spans"], "direct spans", EXPECTED_COUNTS["direct_spans"])
    expected_span_ids = [
        "unicode_empty",
        "unicode_prefix",
        "unicode_newline",
        "unicode_emoji_tail",
        "ascii_tail",
        "parts_beta_newline",
    ]
    expected_provenance = ["input", "entry", "match", "capture", "mark", "gap"]
    span_by_id: dict[str, dict[str, Any]] = {}
    for expected_id, provenance, span in zip(expected_span_ids, expected_provenance, spans, strict=True):
        require_fields(
            span,
            ["id", "source_id", "start", "end", "provenance", "expected_text"],
            "direct span",
        )
        if span["id"] != expected_id or span["provenance"] != provenance:
            fail("direct span identity, order, or provenance drifted")
        source = source_by_id.get(span["source_id"])
        if source is None:
            fail("direct span references unknown source")
        start, end = span["start"], span["end"]
        position_coordinates(source["decoded_text"], start)
        position_coordinates(source["decoded_text"], end)
        if start > end:
            fail(f"direct span is reversed: {span['id']!r}")
        if source["decoded_text"][start:end] != span["expected_text"]:
            fail(f"direct span materialization drifted: {span['id']!r}")
        span_by_id[span["id"]] = span

    derived_cases = require_list(
        contract["derived_text_cases"],
        "derived text cases",
        EXPECTED_COUNTS["derived_text_cases"],
    )
    expected_derived_ids = ["same_source_noncontiguous", "multi_source", "empty_then_gap"]
    for expected_id, case in zip(expected_derived_ids, derived_cases, strict=True):
        require_fields(
            case,
            ["id", "policy", "span_ids", "contiguous_source_interval", "expected_text"],
            "derived text case",
        )
        if case["id"] != expected_id or case["policy"] != "concatenate_in_order":
            fail("derived text identity, order, or policy drifted")
        if case["contiguous_source_interval"] is not None:
            fail("derived text pretends to have one contiguous source interval")
        segment_ids = require_list(case["span_ids"], "derived provenance sequence")
        if not segment_ids or any(span_id not in span_by_id for span_id in segment_ids):
            fail("derived provenance is empty or references an unknown span")
        materialized = "".join(span_by_id[span_id]["expected_text"] for span_id in segment_ids)
        if materialized != case["expected_text"]:
            fail(f"derived text materialization drifted: {case['id']!r}")

    invocation = require_fields(
        contract["invocation_state_machine"],
        ["initial", "transitions"],
        "invocation state machine",
    )
    if invocation["initial"] != {"stack": [], "completed_count": 0}:
        fail("invocation initial state drifted")
    invocation_state = copy.deepcopy(invocation["initial"])
    invocation_transitions = require_list(
        invocation["transitions"],
        "invocation transitions",
        EXPECTED_COUNTS["invocation_transitions"],
    )
    expected_invocation_ids = [
        "enter_root",
        "seek_root",
        "set_root_boundary",
        "write_root_mark",
        "enter_child",
        "advance_child",
        "accept_child",
        "accept_root",
    ]
    for expected_id, transition in zip(expected_invocation_ids, invocation_transitions, strict=True):
        require_fields(transition, ["id", "operation", "args", "expected"], "invocation transition")
        if transition["id"] != expected_id:
            fail("invocation transition identity or order drifted")
        operation = transition["operation"]
        if operation not in INVOCATION_ARG_FIELDS:
            fail(f"unknown invocation transition operation: {operation!r}")
        args = require_fields(
            transition["args"],
            INVOCATION_ARG_FIELDS[operation],
            f"invocation transition {expected_id!r} args",
        )
        require_fields(
            transition["expected"],
            [
                "active_invocation_id",
                "cursor",
                "anonymous_boundary",
                "mark_names",
                "stack_depth",
                "completed_count",
            ],
            f"invocation transition {expected_id!r} expected state",
        )
        if operation == "enter":
            source = source_by_id.get(args["source_id"])
            if source is None:
                fail("invocation transition references unknown source")
            position_coordinates(source["decoded_text"], args["cursor"])
        elif operation in {"set_cursor", "set_boundary", "set_mark"}:
            if not invocation_state["stack"]:
                fail("invocation position transition has no active frame")
            active_source_id = invocation_state["stack"][-1]["source_id"]
            position_coordinates(source_by_id[active_source_id]["decoded_text"], args["offset"])
        if operation == "set_mark":
            if not isinstance(args["name"], str) or not args["name"]:
                fail("invocation mark name must be non-empty text")
            if (
                not isinstance(args["generation"], int)
                or isinstance(args["generation"], bool)
                or args["generation"] < 1
            ):
                fail("invocation mark generation must be a positive integer")
        apply_invocation_transition(invocation_state, transition)
        if invocation_snapshot(invocation_state) != transition["expected"]:
            fail(f"invocation transition result drifted: {transition['id']!r}")

    transaction = require_fields(
        contract["transaction_state_machine"],
        ["initial", "transitions"],
        "transaction state machine",
    )
    transaction_initial = require_fields(
        transaction["initial"],
        ["invocation_id", "rule_label", "source_id", "cursor", "anonymous_boundary", "marks"],
        "transaction initial state",
    )
    transaction_source = source_by_id.get(transaction_initial["source_id"])
    if transaction_source is None:
        fail("transaction initial state references unknown source")
    transaction_text = transaction_source["decoded_text"]
    position_coordinates(transaction_text, transaction_initial["cursor"])
    position_coordinates(transaction_text, transaction_initial["anonymous_boundary"])
    initial_marks = require_list(transaction_initial["marks"], "transaction initial marks")
    seen_initial_marks: set[str] = set()
    for mark in initial_marks:
        if (
            not isinstance(mark, list)
            or len(mark) != 2
            or not isinstance(mark[0], str)
            or not mark[0]
            or mark[0] in seen_initial_marks
        ):
            fail("transaction initial mark row is invalid or duplicated")
        seen_initial_marks.add(mark[0])
        position_coordinates(transaction_text, mark[1])
    transaction_state = {
        **copy.deepcopy(transaction_initial),
        "marks": dict(transaction_initial["marks"]),
        "tokens": {},
    }
    transaction_transitions = require_list(
        transaction["transitions"],
        "transaction transitions",
        EXPECTED_COUNTS["transaction_transitions"],
    )
    expected_transaction_ids = [
        "checkpoint_commit_path",
        "try_advance_commit_path",
        "try_boundary_commit_path",
        "try_mark_commit_path",
        "commit_path",
        "checkpoint_rollback_path",
        "try_mutate_rollback_path",
        "rollback_path",
    ]
    for expected_id, transition in zip(expected_transaction_ids, transaction_transitions, strict=True):
        require_fields(transition, ["id", "operation", "args", "expected"], "transaction transition")
        if transition["id"] != expected_id:
            fail("transaction transition identity or order drifted")
        operation = transition["operation"]
        if operation not in TRANSACTION_ARG_FIELDS:
            fail(f"unknown transaction transition operation: {operation!r}")
        args = require_fields(
            transition["args"],
            TRANSACTION_ARG_FIELDS[operation],
            f"transaction transition {expected_id!r} args",
        )
        require_fields(
            transition["expected"],
            ["cursor", "anonymous_boundary", "marks", "token", "token_state"],
            f"transaction transition {expected_id!r} expected state",
        )
        if not isinstance(args["token"], str) or not args["token"]:
            fail("transaction token must be non-empty text")
        if operation in {"try_cursor", "try_boundary", "try_mark"}:
            position_coordinates(transaction_text, args["offset"])
        if operation == "try_mark" and (not isinstance(args["name"], str) or not args["name"]):
            fail("transaction mark name must be non-empty text")
        if operation == "try_state":
            position_coordinates(transaction_text, args["cursor"])
            position_coordinates(transaction_text, args["anonymous_boundary"])
            marks = require_list(args["marks"], "transaction replacement marks")
            seen_marks: set[str] = set()
            for mark in marks:
                if (
                    not isinstance(mark, list)
                    or len(mark) != 2
                    or not isinstance(mark[0], str)
                    or not mark[0]
                    or mark[0] in seen_marks
                ):
                    fail("transaction replacement mark row is invalid or duplicated")
                seen_marks.add(mark[0])
                position_coordinates(transaction_text, mark[1])
        apply_transaction_transition(transaction_state, transition)
        token = transition["args"]["token"]
        if transaction_snapshot(transaction_state, token) != transition["expected"]:
            fail(f"transaction transition result drifted: {transition['id']!r}")

    observations = require_list(
        contract["recursive_observations"],
        "recursive observations",
        EXPECTED_COUNTS["recursive_observations"],
    )
    observed_recursive: list[tuple[Any, ...]] = []
    for observation in observations:
        require_fields(
            observation,
            [
                "id",
                "invocation_id",
                "parent_invocation_id",
                "source_id",
                "entry_offset",
                "selected_match_span_id",
                "accepted_exit_offset",
                "outcome",
                "diagnostic",
            ],
            "recursive observation",
        )
        source = source_by_id.get(observation["source_id"])
        if source is None:
            fail("recursive observation references unknown source")
        position_coordinates(source["decoded_text"], observation["entry_offset"])
        if observation["accepted_exit_offset"] is not None:
            position_coordinates(source["decoded_text"], observation["accepted_exit_offset"])
        if observation["selected_match_span_id"] is not None:
            span = span_by_id.get(observation["selected_match_span_id"])
            if span is None or span["source_id"] != observation["source_id"]:
                fail("recursive selected-match span identity drifted")
        observed_recursive.append(tuple(observation.values()))
    if observed_recursive != RECURSIVE_OBSERVATIONS:
        fail("recursive observation semantics or order drifted")

    structural = require_list(
        contract["structural_authoring_cases"],
        "structural authoring cases",
        EXPECTED_COUNTS["structural_authoring_cases"],
    )
    for case in structural:
        require_fields(
            case,
            ["id", "regex_count", "role", "entry_rule_valid", "recursion_owner", "guidance"],
            "structural authoring case",
        )
    if [tuple(case.values()) for case in structural] != STRUCTURAL_CASES:
        fail("zero/one/two-regex structural authoring contract drifted")

    helper_schema = require_fields(
        contract["helper_projection_schema"],
        ["row", "families", "projection_vocabulary"],
        "helper projection schema",
    )
    if helper_schema != {
        "row": ["name", "projection"],
        "families": list(HELPER_GROUPS),
        "projection_vocabulary": PROJECTION_VOCABULARY,
    }:
        fail("helper projection schema drifted")
    projections = require_fields(contract["helper_projections"], list(HELPER_GROUPS), "helper projections")
    lua_source = LUA_CONTRACTS_PATH.read_text(encoding="utf-8")
    all_names: list[str] = []
    for family, lua_constant in HELPER_GROUPS.items():
        rows = require_list(projections[family], f"{family} helper projections")
        source_names = extract_lua_helper_names(lua_source, lua_constant)
        row_names: list[str] = []
        for row in rows:
            if not isinstance(row, list) or len(row) != 2 or not all(isinstance(item, str) for item in row):
                fail(f"{family} helper projection row drifted")
            name, projection = row
            row_names.append(name)
            if projection not in PROJECTION_VOCABULARY:
                fail(f"unknown projection vocabulary item: {projection!r}")
            if projection != expected_projection(name, family):
                fail(f"typed projection drifted for helper {name!r}")
        if row_names != source_names:
            fail(f"{family} helper membership or order drifted from current authority")
        all_names.extend(row_names)
    if len(all_names) != EXPECTED_COUNTS["helper_projections"] or len(set(all_names)) != len(all_names):
        fail("helper projection count or uniqueness drifted")

    aliases = require_list(
        contract["compatibility_aliases"],
        "compatibility aliases",
        EXPECTED_COUNTS["compatibility_aliases"],
    )
    if [tuple(alias) for alias in aliases] != ALIASES:
        fail("compatibility alias membership, order, or target drifted")
    perl_source = PERL_CONTRACTS_PATH.read_text(encoding="utf-8")
    legacy_scanner_source = PERL_LEGACY_SCANNER_PATH.read_text(encoding="utf-8")
    scanner_owned_aliases = {"entry_named_map", "match_named_map"}
    for alias, canonical in ALIASES:
        alias_record = extract_perl_contract_record(perl_source, alias)
        if alias in scanner_owned_aliases:
            scanner_pattern = f"\\b{alias}\\s*\\(\\s*\\)"
            if scanner_pattern not in legacy_scanner_source:
                fail(f"Perl legacy scanner authority is missing alias {alias!r}")
        else:
            canonical_record = extract_perl_contract_record(perl_source, canonical)
            if re.search(r"\bcompatibility_surface\s*=>\s*1", alias_record) is None:
                fail(f"Perl compatibility flag is missing for alias {alias!r}")
            if extract_perl_record_field(alias_record, alias, "diag_name") != canonical:
                fail(f"Perl alias diagnostic identity drifted for {alias!r}")
            if extract_perl_record_field(alias_record, alias, "ir_node") != extract_perl_record_field(
                canonical_record,
                canonical,
                "ir_node",
            ):
                fail(f"Perl alias IR identity drifted for {alias!r}")
            if extract_perl_runtime_calls(alias_record) != extract_perl_runtime_calls(canonical_record):
                fail(f"Perl alias runtime lowering drifted for {alias!r}")

    internal_ids = require_list(
        contract["internal_contract_ids"],
        "internal contract ids",
        EXPECTED_COUNTS["internal_contract_ids"],
    )
    if [tuple(item) for item in internal_ids] != INTERNAL_CONTRACT_IDS:
        fail("internal contract id membership, order, or canonical spelling drifted")
    for internal_id, canonical in INTERNAL_CONTRACT_IDS:
        contract_record = re.search(
            rf"id\s*=>\s*'{re.escape(internal_id)}'.{{0,300}}?diag_name\s*=>\s*'{re.escape(canonical)}'",
            perl_source,
            re.DOTALL,
        )
        scanner_record = re.search(
            rf"sub _scan_contract_{re.escape(internal_id)}\b(.*?)(?=\nsub |\Z)",
            legacy_scanner_source,
            re.DOTALL,
        )
        canonical_pattern = f"\\b{canonical}\\s*\\(\\s*\\)"
        if (
            contract_record is None
            or scanner_record is None
            or canonical_pattern not in scanner_record.group(1)
        ):
            fail(f"internal contract/scanner authority drifted for {internal_id!r}")

    diagnostic_schema = require_fields(
        contract["diagnostic_schema"],
        ["fields", "detection_values", "privacy"],
        "diagnostic schema",
    )
    if diagnostic_schema != {
        "fields": ["id", "code", "phase", "detection", "required_context"],
        "detection_values": ["static", "runtime", "static_or_runtime"],
        "privacy": "carry identities and relevant coordinates without leaking source text above the active source-detail ceiling",
    }:
        fail("diagnostic schema drifted")
    diagnostics = require_list(
        contract["diagnostics"],
        "diagnostics",
        EXPECTED_COUNTS["diagnostics"],
    )
    observed_diagnostics: list[tuple[Any, ...]] = []
    for diagnostic in diagnostics:
        require_fields(diagnostic, diagnostic_schema["fields"], "diagnostic")
        if diagnostic["code"] != f"source_location_{diagnostic['id']}":
            fail(f"diagnostic code does not derive from id: {diagnostic['id']!r}")
        if diagnostic["detection"] not in diagnostic_schema["detection_values"]:
            fail(f"diagnostic detection class drifted: {diagnostic['id']!r}")
        observed_diagnostics.append(
            (
                diagnostic["id"],
                diagnostic["phase"],
                diagnostic["detection"],
                diagnostic["required_context"],
            )
        )
    if observed_diagnostics != DIAGNOSTICS:
        fail("diagnostic membership, order, phase, detection, or context drifted")

    recurring = require_fields(
        contract["recurring_gate"],
        [
            "driver",
            "source_schema",
            "consumer_sources",
            "route_schema",
            "runtime_routes",
            "support_checks",
            "local_ci",
        ],
        "recurring gate",
    )
    if recurring != RECURRING_GATE:
        fail("recurring gate source, route, command, support, or canonical topology drifted")

    rollout = require_list(contract["rollout"], "rollout", EXPECTED_COUNTS["rollout_legs"])
    observed_rollout: list[tuple[Any, ...]] = []
    for leg in rollout:
        require_fields(leg, ["leg", "status", "owner", "runtimes"], "rollout leg")
        if leg["status"] not in {"complete", "pending"}:
            fail("rollout status drifted")
        observed_rollout.append((leg["leg"], leg["status"], leg["owner"], leg["runtimes"]))
    if observed_rollout != ROLLOUT:
        fail("rollout membership, order, status, owner, or runtime coverage drifted")

    actual_counts = {
        "sources": len(sources),
        "position_conversions": len(positions),
        "direct_spans": len(spans),
        "derived_text_cases": len(derived_cases),
        "invocation_transitions": len(invocation_transitions),
        "transaction_transitions": len(transaction_transitions),
        "recursive_observations": len(observations),
        "structural_authoring_cases": len(structural),
        "helper_projections": len(all_names),
        "compatibility_aliases": len(aliases),
        "internal_contract_ids": len(internal_ids),
        "diagnostics": len(diagnostics),
        "rollout_legs": len(rollout),
        "recurring_source_groups": len(recurring["consumer_sources"]),
        "recurring_runtime_routes": len(recurring["runtime_routes"]),
        "mutations": EXPECTED_COUNTS["mutations"],
    }
    if actual_counts != EXPECTED_COUNTS:
        fail("derived contract counts drifted")

    if check_registration:
        for path in (
            CONTRACT_PATH,
            CHECKER_PATH,
            ROOT / CANONICAL_EXECUTION["project_data_runner"],
            CI_PATH,
            PERL_VALUE_CONSUMER_PATH,
            PERL_PROJECTION_CONSUMER_PATH,
            RUST_CONSUMER_PATH,
            DART_CONSUMER_PATH,
            JULIA_CONSUMER_PATH,
            JULIA_RUNTESTS_PATH,
            LUA_CONSUMER_PATH,
            LUA_ORDINARY_DRIVER_PATH,
            RECURRING_DRIVER_PATH,
        ):
            if not path.is_file():
                fail(f"canonical contract/checker/runner input is missing: {path.relative_to(ROOT)}")
        ci_text = CI_PATH.read_text(encoding="utf-8")
        required_markers = [
            f"require_tracked_file {CANONICAL_EXECUTION['contract_path']}",
            f"require_tracked_file {CANONICAL_EXECUTION['checker_path']}",
            CANONICAL_EXECUTION["invocation"],
            "require_tracked_file t/typed_source_location_values.t",
            "require_tracked_file t/typed_source_location_perl_contract.t",
            "perl -c -Iperl t/typed_source_location_values.t",
            "perl -c -Iperl t/typed_source_location_perl_contract.t",
            "PERL5LIB= prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t",
            "require_tracked_file rust/linkedspec-runtime/tests/typed_source_location_contract.rs",
            "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract",
            "require_tracked_file dart/test/typed_source_location_contract_test.dart",
            "bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart",
            "require_tracked_file julia/test/typed_source_location_contract_test.jl",
            "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/typed_source_location_contract_test.jl\")'",
            "require_tracked_file lua/test/typed_source_location_contract_test.lua",
            "bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua",
            "bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua",
        ]
        for marker in required_markers:
            if ci_text.count(marker) != 1:
                fail(f"canonical registration marker must appear exactly once: {marker}")
        if CI_PATH.name != Path(CANONICAL_EXECUTION["canonical_driver"]).name:
            fail("canonical driver identity drifted")
        recurring_driver_text = RECURRING_DRIVER_PATH.read_text(encoding="utf-8")
        recurring_markers = [
            CANONICAL_EXECUTION["invocation"],
            *[route["command"] for route in RECURRING_GATE["runtime_routes"]],
            *RECURRING_GATE["support_checks"],
        ]
        recurring_positions: list[int] = []
        for marker in recurring_markers:
            if recurring_driver_text.count(marker) != 1:
                fail(f"recurring driver marker must appear exactly once: {marker}")
            recurring_positions.append(recurring_driver_text.index(marker))
        if recurring_positions != sorted(recurring_positions):
            fail("recurring driver neutral/runtime/support order drifted")
        for source in RECURRING_GATE["consumer_sources"]:
            for relative_path in source["paths"]:
                if not (ROOT / relative_path).is_file():
                    fail(f"recurring consumer source is missing: {relative_path}")
        recurring_ci = RECURRING_GATE["local_ci"]
        if recurring_ci["driver"] != CI_PATH.relative_to(ROOT).as_posix():
            fail("recurring canonical driver identity drifted")
        recurring_ci_markers = (
            f"require_tracked_file {RECURRING_GATE['driver']}",
            f'if [[ "${{{recurring_ci["switch"]}:-0}}" == "1" ]]; then',
            f'bash "$REPO_ROOT/{RECURRING_GATE["driver"]}"',
        )
        expected_ci_counts = (2, 1, 1)
        for marker, expected_count in zip(recurring_ci_markers, expected_ci_counts, strict=True):
            if ci_text.count(marker) != expected_count:
                fail(
                    "recurring canonical registration marker count drifted: "
                    f"{marker} expected {expected_count}"
                )
        rust_consumer_text = RUST_CONSUMER_PATH.read_text(encoding="utf-8")
        for dormant_marker in (
            "linkedspec_typed_source_red",
            "linkedspec_typed_source_projection_red",
        ):
            if dormant_marker in rust_consumer_text:
                fail(f"Rust consumer remains dormant behind {dormant_marker}")
        if DART_DORMANT_CONSUMER_PATH.exists():
            fail("Dart consumer remains outside ordinary test discovery")
        dart_consumer_text = DART_CONSUMER_PATH.read_text(encoding="utf-8")
        for stale_marker in (
            "test_dormant/typed_source_location_contract_test.dart",
            "pre-admission directory",
        ):
            if stale_marker in dart_consumer_text:
                fail(f"Dart consumer retains stale dormancy marker: {stale_marker}")
        julia_runtests_text = JULIA_RUNTESTS_PATH.read_text(encoding="utf-8")
        julia_include = 'include("typed_source_location_contract_test.jl")'
        if julia_runtests_text.count(julia_include) != 1:
            fail("Julia typed-source consumer must appear exactly once in ordinary discovery")
        julia_consumer_text = JULIA_CONSUMER_PATH.read_text(encoding="utf-8")
        for stale_marker in (
            "JULIA_TYPED_SOURCE_RED_MODE",
            "dormant Julia typed source-location RED",
            "pre-admission consumer",
        ):
            if stale_marker in julia_consumer_text:
                fail(f"Julia consumer retains stale dormancy marker: {stale_marker}")
        lua_ordinary_text = LUA_ORDINARY_DRIVER_PATH.read_text(encoding="utf-8")
        lua_ordinary_markers = (
            'LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" '
            "lua/test/typed_source_location_contract_test.lua",
            'LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \\\n'
            '  "$LUAJIT_CMD" lua/test/typed_source_location_contract_test.lua',
        )
        for marker in lua_ordinary_markers:
            if lua_ordinary_text.count(marker) != 1:
                fail(f"Lua ordinary typed-source registration must appear exactly once: {marker}")
        lua_consumer_text = LUA_CONSUMER_PATH.read_text(encoding="utf-8")
        for stale_marker in (
            "LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE",
            "dormant shared Lua typed source-location RED",
            "pre-admission consumer",
            'mode == "projection"',
        ):
            if stale_marker in lua_consumer_text:
                fail(f"Lua consumer retains stale dormancy marker: {stale_marker}")


def expect_mutation_failure(
    contract: dict[str, Any], name: str, mutate: Callable[[dict[str, Any]], None]
) -> None:
    candidate = copy.deepcopy(contract)
    mutate(candidate)
    try:
        validate_contract(candidate, check_registration=False)
    except ContractError:
        return
    fail(f"mutation {name!r} was not rejected")


def mutation_checks(contract: dict[str, Any]) -> int:
    def transaction_out_of_range(candidate: dict[str, Any]) -> None:
        transition = candidate["transaction_state_machine"]["transitions"][6]
        transition["args"].update(
            {"cursor": 5, "anonymous_boundary": 5, "marks": [["m", 5]]}
        )
        transition["expected"].update(
            {"cursor": 5, "anonymous_boundary": 5, "marks": [["m", 5]]}
        )

    def swap_recurring_routes(candidate: dict[str, Any]) -> None:
        routes = candidate["recurring_gate"]["runtime_routes"]
        routes[0], routes[1] = routes[1], routes[0]

    mutations: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
        ("format", lambda c: c.__setitem__("format", 2)),
        ("contract id", lambda c: c.__setitem__("contract_id", "drift")),
        ("task owner", lambda c: c.__setitem__("task_owner", "FUTURE-PARITY-BACKLOG.14.2")),
        ("neutral status", lambda c: c.__setitem__("status", "implemented")),
        ("coordinate policy", lambda c: c["policy"].__setitem__("coordinates", "bytes are authoritative")),
        ("source spelling", lambda c: c["policy"].__setitem__("source_spelling", "span()")),
        ("source removed", lambda c: c["sources"].pop()),
        ("source scalar length", lambda c: c["sources"][0].__setitem__("unicode_scalar_length", 8)),
        ("position removed", lambda c: c["position_conversions"].pop()),
        ("position byte coordinate", lambda c: c["position_conversions"][1].__setitem__("utf8_byte_offset", 1)),
        ("span reversed", lambda c: c["direct_spans"][1].__setitem__("start", 2)),
        ("span text", lambda c: c["direct_spans"][3].__setitem__("expected_text", "x")),
        ("derived segment order", lambda c: c["derived_text_cases"][0]["span_ids"].reverse()),
        ("derived contiguous lie", lambda c: c["derived_text_cases"][1].__setitem__("contiguous_source_interval", [0, 3])),
        ("invocation transition removed", lambda c: c["invocation_state_machine"]["transitions"].pop()),
        ("invocation operation", lambda c: c["invocation_state_machine"]["transitions"][1].__setitem__("operation", "accept")),
        ("invocation mark generation", lambda c: c["invocation_state_machine"]["transitions"][3]["args"].__setitem__("generation", 0)),
        ("transaction transition removed", lambda c: c["transaction_state_machine"]["transitions"].pop()),
        ("transaction operation", lambda c: c["transaction_state_machine"]["transitions"][4].__setitem__("operation", "rollback")),
        ("transaction offset bounds", transaction_out_of_range),
        ("recursive observation removed", lambda c: c["recursive_observations"].pop()),
        ("recursive diagnostic", lambda c: c["recursive_observations"][4].__setitem__("diagnostic", None)),
        ("structural case removed", lambda c: c["structural_authoring_cases"].pop()),
        ("structural regex count", lambda c: c["structural_authoring_cases"][2].__setitem__("regex_count", 3)),
        ("helper projection removed", lambda c: c["helper_projections"]["capture_mark"].pop()),
        ("helper projection semantic", lambda c: c["helper_projections"]["entry_match"][0].__setitem__(1, "span_text")),
        ("alias removed", lambda c: c["compatibility_aliases"].pop()),
        ("alias anonymous/named target", lambda c: c["compatibility_aliases"][0].__setitem__(1, "capture_from")),
        ("internal contract id", lambda c: c["internal_contract_ids"][0].__setitem__(1, "capture_take_len")),
        ("diagnostic removed", lambda c: c["diagnostics"].pop()),
        ("diagnostic code", lambda c: c["diagnostics"][0].__setitem__("code", "wrong")),
        ("diagnostic context", lambda c: c["diagnostics"][19]["required_context"].pop()),
        (
            "recurring source group omitted",
            lambda c: c["recurring_gate"]["consumer_sources"].pop(),
        ),
        (
            "recurring source path omitted",
            lambda c: c["recurring_gate"]["consumer_sources"][0]["paths"].pop(),
        ),
        (
            "recurring runtime route omitted",
            lambda c: c["recurring_gate"]["runtime_routes"].pop(),
        ),
        ("recurring runtime route order", swap_recurring_routes),
        (
            "recurring runtime route duplicated",
            lambda c: c["recurring_gate"]["runtime_routes"].append(
                copy.deepcopy(c["recurring_gate"]["runtime_routes"][0])
            ),
        ),
        (
            "recurring runtime command",
            lambda c: c["recurring_gate"]["runtime_routes"][1].__setitem__(
                "command", "cargo test --wrong"
            ),
        ),
        (
            "recurring runtime source binding",
            lambda c: c["recurring_gate"]["runtime_routes"][5].__setitem__(
                "source_backend", "rust"
            ),
        ),
        (
            "recurring support check omitted",
            lambda c: c["recurring_gate"]["support_checks"].pop(),
        ),
        (
            "recurring driver",
            lambda c: c["recurring_gate"].__setitem__("driver", "tools/missing.sh"),
        ),
        (
            "recurring canonical switch",
            lambda c: c["recurring_gate"]["local_ci"].__setitem__(
                "switch", "LINKEDSPEC_RUN_WRONG_MATRIX"
            ),
        ),
        (
            "combined public no-drift promoted prematurely",
            lambda c: c["rollout"][13].__setitem__("status", "complete"),
        ),
        ("rollout removed", lambda c: c["rollout"].pop()),
        ("canonical checker", lambda c: c["canonical_execution"].__setitem__("checker_path", "tools/wrong.py")),
        ("mutation count", lambda c: c["expected_counts"].__setitem__("mutations", 52)),
    ]
    rollout_regressions = [
        (
            "public structure regressed to pending",
            lambda c: c["rollout"][1].__setitem__("status", "pending"),
        ),
        (
            "neutral public recomposition regressed to pending",
            lambda c: c["rollout"][2].__setitem__("status", "pending"),
        ),
        (
            "Perl runtime admission regressed to pending",
            lambda c: c["rollout"][3].__setitem__("status", "pending"),
        ),
        (
            "Rust runtime admission regressed to pending",
            lambda c: c["rollout"][4].__setitem__("status", "pending"),
        ),
        (
            "Dart runtime admission regressed to pending",
            lambda c: c["rollout"][5].__setitem__("status", "pending"),
        ),
        (
            "Julia runtime admission regressed to pending",
            lambda c: c["rollout"][6].__setitem__("status", "pending"),
        ),
        (
            "Lua dual-ABI runtime admission regressed to pending",
            lambda c: c["rollout"][7].__setitem__("status", "pending"),
        ),
    ]
    if len(mutations) + len(rollout_regressions) != EXPECTED_COUNTS["mutations"]:
        fail("checker mutation inventory count drifted")
    for name, mutate in mutations:
        expect_mutation_failure(contract, name, mutate)
    for name, mutate in rollout_regressions:
        candidate = copy.deepcopy(contract)
        mutate(candidate)
        try:
            validate_contract(candidate, check_registration=False)
        except ContractError as error:
            if "rollout membership, order, status, owner, or runtime coverage drifted" not in str(error):
                fail(f"mutation {name!r} failed for the wrong reason: {error}")
        else:
            fail(f"mutation {name!r} was not rejected")
    return len(mutations) + len(rollout_regressions)


def main() -> int:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(contract)
    mutation_count = mutation_checks(contract)
    complete = sum(leg["status"] == "complete" for leg in contract["rollout"])
    pending = len(contract["rollout"]) - complete
    print(
        "typed-source-location-contract: OK "
        f"({len(contract['sources'])} sources; {len(contract['position_conversions'])} positions; "
        f"{len(contract['direct_spans'])} direct spans; {len(contract['derived_text_cases'])} derived texts; "
        f"{len(contract['invocation_state_machine']['transitions'])}+"
        f"{len(contract['transaction_state_machine']['transitions'])} state transitions; "
        f"{len(contract['recursive_observations'])} recursive observations; "
        f"{len(contract['structural_authoring_cases'])} structural cases; "
        f"{EXPECTED_COUNTS['helper_projections']} helper projections + "
        f"{len(contract['compatibility_aliases'])} aliases + "
        f"{len(contract['internal_contract_ids'])} internal ids; "
        f"{len(contract['diagnostics'])} diagnostics; "
        f"{complete} complete / {pending} pending rollout; {mutation_count} drift mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

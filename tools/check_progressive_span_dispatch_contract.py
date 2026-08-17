#!/usr/bin/env python3
"""Independently validate the neutral progressive span-dispatch v1 contract."""

from __future__ import annotations

import copy
import json
import re
import subprocess
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "progressive_span_dispatch_contract.json"
CHECKER_PATH = ROOT / "tools" / "check_progressive_span_dispatch_contract.py"
CI_PATH = ROOT / "tools" / "run_ci_local.sh"

PARSER_ID_PATTERN = r"^[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*$"
TOP_RULE_PATTERN = r"^[A-Za-z_][A-Za-z0-9_]*$"
SOURCE_DETAIL_ORDER = ["none", "identity", "span", "text"]

AUTHORED_SURFACE = {
    "example": 'value = dispatch_span("expr-v1", "Expr", span)',
    "callee": "dispatch_span",
    "node_kind": "PROGRESSIVE_DISPATCH_SPAN",
    "effect": "parser_registry_or_staged_dispatch",
    "operands": [
        "one nonempty normalized logical parser identity string literal",
        "one nonempty allowed top-rule string literal",
        "one bare rule-local harray binding with exact source_id/start/end/provenance fields",
    ],
    "result": "one detached child payload returned as the expression value",
    "failure_policy": "fail_only; every dispatch or child failure propagates unchanged and no null, fallback, retry, or alternate parser is implied",
    "availability": "neutral authority only; no backend admits the spelling until its independent rollout row completes",
}

POLICY = {
    "registry": "the host seeds immutable logical entries containing already compiled parser authority; authored execution may look up an identity but cannot resolve, load, compile, mutate, or enumerate",
    "identity": "parser identity and top rule are static normalized literals; neither is a path, URI, module name, import request, or provider query",
    "span": "one exact four-field direct same-source half-open Unicode-scalar span is data and provenance only; copied text, derived multi-span text, paths, and authority handles reject",
    "source_view": "child registers are zero-based within the bounded view while every typed position, span, and diagnostic rebases to the original source identity and global scalar offsets",
    "state": "parent cursor, anonymous boundary, marks, variables, transactions, captures, and invocation state remain unchanged; shared cancellation and budget authority may only become more restrictive",
    "result": "the child result is deeply detached and contains no parser, registry, source, frame, transaction, cancellation, host, path, or live authority handle",
    "capabilities": "effective capabilities and policy modes are sorted intersections; all required capabilities must remain present and an empty required policy intersection rejects",
    "ceilings": "source detail and every numeric resource ceiling take the stricter minimum; a child cannot request or observe detail above the effective ceiling",
    "cancellation": "the same cancellation token and absolute deadline propagate; entry and child safe points observe cancellation, deadline, and remaining budget without reset or extension",
    "cycles": "repeating parser identity, top rule, and source requires a contained strictly smaller global span; exact, shifted equal-length, larger, or non-contained repeats reject",
    "bounds": "depth and total dispatch calls remain bounded across all parser identities; successful child work spends the shared remaining budget",
    "progress": "dispatch never advances the parent cursor and never satisfies parent repetition or recursion progress",
    "transactions": "dispatch is non-rollbackable and statically rejected anywhere inside an uncommitted recognition effect graph",
    "loading": "no operand or registry entry grants filesystem, import, search-root, provider, compilation, network, environment, or host-module authority",
}

REGISTRY_SCHEMA = {
    "fields": [
        "parser_id",
        "compiled_authority",
        "fingerprint",
        "allowed_top_rules",
        "capabilities",
        "ceilings",
    ],
    "identity_pattern": PARSER_ID_PATTERN,
    "top_rule_pattern": TOP_RULE_PATTERN,
    "fingerprint_pattern": r"^sha256:[0-9a-f]{64}$",
    "immutable_during_execution": True,
    "forbidden_fields": [
        "path",
        "spec_path",
        "search_roots",
        "provider_query",
        "source_text",
        "compile_request",
    ],
}

REGISTRY_ENTRIES = [
    {
        "parser_id": "expr-v1",
        "compiled_authority": "opaque:compiled-expr-v1",
        "fingerprint": "sha256:1111111111111111111111111111111111111111111111111111111111111111",
        "allowed_top_rules": ["Expr", "Value"],
        "capabilities": ["actionir-v1", "typed-source-location-v1"],
        "ceilings": {
            "source_detail": "span",
            "policy_modes": ["deterministic", "fail-only"],
            "max_steps": 100,
            "max_result_nodes": 64,
            "max_diagnostic_bytes": 4096,
        },
    },
    {
        "parser_id": "json-v1",
        "compiled_authority": "opaque:compiled-json-v1",
        "fingerprint": "sha256:2222222222222222222222222222222222222222222222222222222222222222",
        "allowed_top_rules": ["Document"],
        "capabilities": ["structured-result-v1", "typed-source-location-v1"],
        "ceilings": {
            "source_detail": "identity",
            "policy_modes": ["deterministic", "fail-only", "strict-json"],
            "max_steps": 80,
            "max_result_nodes": 32,
            "max_diagnostic_bytes": 1024,
        },
    },
]

SOURCES = [
    {
        "id": "unicode",
        "text": "Aé🙂BC",
        "scalar_length": 5,
        "utf8_offsets": [0, 1, 3, 7, 8, 9],
    },
    {
        "id": "ascii",
        "text": "abcdef",
        "scalar_length": 6,
        "utf8_offsets": [0, 1, 2, 3, 4, 5, 6],
    },
]

VIEW_CASES = [
    {
        "id": "unicode_middle",
        "authority_source_id": "unicode",
        "span": {"source_id": "unicode", "start": 1, "end": 4, "provenance": "gap"},
        "accepted": True,
        "view_text": "é🙂B",
        "local_to_global": [1, 2, 3, 4],
        "diagnostic": None,
    },
    {
        "id": "empty_direct_span",
        "authority_source_id": "unicode",
        "span": {"source_id": "unicode", "start": 2, "end": 2, "provenance": "match"},
        "accepted": True,
        "view_text": "",
        "local_to_global": [2],
        "diagnostic": None,
    },
    {
        "id": "ascii_full",
        "authority_source_id": "ascii",
        "span": {"source_id": "ascii", "start": 0, "end": 6, "provenance": "capture"},
        "accepted": True,
        "view_text": "abcdef",
        "local_to_global": [0, 1, 2, 3, 4, 5, 6],
        "diagnostic": None,
    },
    {
        "id": "source_mismatch",
        "authority_source_id": "unicode",
        "span": {"source_id": "ascii", "start": 0, "end": 1, "provenance": "capture"},
        "accepted": False,
        "view_text": None,
        "local_to_global": None,
        "diagnostic": "progressive_span_source_mismatch",
    },
    {
        "id": "reversed",
        "authority_source_id": "unicode",
        "span": {"source_id": "unicode", "start": 4, "end": 2, "provenance": "capture"},
        "accepted": False,
        "view_text": None,
        "local_to_global": None,
        "diagnostic": "progressive_span_reversed",
    },
    {
        "id": "outside_source",
        "authority_source_id": "unicode",
        "span": {"source_id": "unicode", "start": 0, "end": 6, "provenance": "capture"},
        "accepted": False,
        "view_text": None,
        "local_to_global": None,
        "diagnostic": "progressive_span_out_of_bounds",
    },
    {
        "id": "copied_text_smuggling",
        "authority_source_id": "unicode",
        "span": {"source_id": "unicode", "start": 1, "end": 2, "provenance": "capture", "text": "é"},
        "accepted": False,
        "view_text": None,
        "local_to_global": None,
        "diagnostic": "progressive_span_shape_invalid",
    },
    {
        "id": "noninteger_offset",
        "authority_source_id": "unicode",
        "span": {"source_id": "unicode", "start": "1", "end": 2, "provenance": "capture"},
        "accepted": False,
        "view_text": None,
        "local_to_global": None,
        "diagnostic": "progressive_span_shape_invalid",
    },
]

AUTHORITY_CASES = [
    {
        "id": "intersection_and_minima",
        "entry_id": "expr-v1",
        "caller_capabilities": ["actionir-v1", "caller-only", "typed-source-location-v1"],
        "required_capabilities": ["actionir-v1", "typed-source-location-v1"],
        "caller_ceilings": {"source_detail": "text", "policy_modes": ["deterministic", "fail-only", "trace"], "max_steps": 60, "max_result_nodes": 128, "max_diagnostic_bytes": 2048},
        "required_source_detail": "span",
        "accepted": True,
        "effective": {"capabilities": ["actionir-v1", "typed-source-location-v1"], "source_detail": "span", "policy_modes": ["deterministic", "fail-only"], "max_steps": 60, "max_result_nodes": 64, "max_diagnostic_bytes": 2048},
        "diagnostic": None,
    },
    {
        "id": "entry_cannot_elevate_caller",
        "entry_id": "json-v1",
        "caller_capabilities": ["typed-source-location-v1"],
        "required_capabilities": ["typed-source-location-v1"],
        "caller_ceilings": {"source_detail": "identity", "policy_modes": ["deterministic", "fail-only"], "max_steps": 200, "max_result_nodes": 16, "max_diagnostic_bytes": 2048},
        "required_source_detail": "identity",
        "accepted": True,
        "effective": {"capabilities": ["typed-source-location-v1"], "source_detail": "identity", "policy_modes": ["deterministic", "fail-only"], "max_steps": 80, "max_result_nodes": 16, "max_diagnostic_bytes": 1024},
        "diagnostic": None,
    },
    {
        "id": "required_capability_missing",
        "entry_id": "expr-v1",
        "caller_capabilities": ["typed-source-location-v1"],
        "required_capabilities": ["actionir-v1"],
        "caller_ceilings": {"source_detail": "span", "policy_modes": ["deterministic", "fail-only"], "max_steps": 100, "max_result_nodes": 64, "max_diagnostic_bytes": 4096},
        "required_source_detail": "identity",
        "accepted": False,
        "effective": None,
        "diagnostic": "progressive_capability_denied",
    },
    {
        "id": "policy_intersection_empty",
        "entry_id": "expr-v1",
        "caller_capabilities": ["actionir-v1", "typed-source-location-v1"],
        "required_capabilities": [],
        "caller_ceilings": {"source_detail": "span", "policy_modes": ["trace"], "max_steps": 100, "max_result_nodes": 64, "max_diagnostic_bytes": 4096},
        "required_source_detail": "identity",
        "accepted": False,
        "effective": None,
        "diagnostic": "progressive_policy_denied",
    },
    {
        "id": "source_detail_cannot_elevate",
        "entry_id": "json-v1",
        "caller_capabilities": ["structured-result-v1", "typed-source-location-v1"],
        "required_capabilities": ["structured-result-v1"],
        "caller_ceilings": {"source_detail": "span", "policy_modes": ["deterministic", "fail-only", "strict-json"], "max_steps": 80, "max_result_nodes": 32, "max_diagnostic_bytes": 1024},
        "required_source_detail": "span",
        "accepted": False,
        "effective": None,
        "diagnostic": "progressive_source_detail_denied",
    },
    {
        "id": "caller_numeric_minimum",
        "entry_id": "expr-v1",
        "caller_capabilities": ["actionir-v1", "typed-source-location-v1"],
        "required_capabilities": [],
        "caller_ceilings": {"source_detail": "identity", "policy_modes": ["deterministic", "fail-only"], "max_steps": 3, "max_result_nodes": 2, "max_diagnostic_bytes": 128},
        "required_source_detail": "none",
        "accepted": True,
        "effective": {"capabilities": ["actionir-v1", "typed-source-location-v1"], "source_detail": "identity", "policy_modes": ["deterministic", "fail-only"], "max_steps": 3, "max_result_nodes": 2, "max_diagnostic_bytes": 128},
        "diagnostic": None,
    },
]

CANCELLATION_CASES = [
    {"id": "fresh_budget", "token": "cancel-1", "child_token": "cancel-1", "cancelled": False, "now_tick": 10, "deadline_tick": 20, "remaining_steps": 12, "cost": 5, "accepted": True, "remaining_after": 7, "diagnostic": None},
    {"id": "already_cancelled", "token": "cancel-2", "child_token": "cancel-2", "cancelled": True, "now_tick": 10, "deadline_tick": 20, "remaining_steps": 12, "cost": 1, "accepted": False, "remaining_after": 12, "diagnostic": "progressive_cancelled"},
    {"id": "deadline_reached", "token": "cancel-3", "child_token": "cancel-3", "cancelled": False, "now_tick": 20, "deadline_tick": 20, "remaining_steps": 12, "cost": 1, "accepted": False, "remaining_after": 12, "diagnostic": "progressive_deadline_exceeded"},
    {"id": "budget_empty", "token": "cancel-4", "child_token": "cancel-4", "cancelled": False, "now_tick": 1, "deadline_tick": 20, "remaining_steps": 0, "cost": 0, "accepted": False, "remaining_after": 0, "diagnostic": "progressive_budget_exhausted"},
    {"id": "cost_exceeds_remaining", "token": "cancel-5", "child_token": "cancel-5", "cancelled": False, "now_tick": 1, "deadline_tick": 20, "remaining_steps": 4, "cost": 5, "accepted": False, "remaining_after": 4, "diagnostic": "progressive_budget_exhausted"},
    {"id": "token_replacement", "token": "cancel-6", "child_token": "renewed-6", "cancelled": False, "now_tick": 1, "deadline_tick": 20, "remaining_steps": 10, "cost": 1, "accepted": False, "remaining_after": 10, "diagnostic": "progressive_cancellation_authority_mismatch"},
]

CHAIN_CASES = [
    {"id": "root", "active": [], "candidate": ["expr-v1", "Expr", "unicode", 0, 5], "max_depth": 4, "total_calls": 0, "max_calls": 8, "accepted": True, "diagnostic": None},
    {"id": "strictly_smaller", "active": [["expr-v1", "Expr", "unicode", 0, 5]], "candidate": ["expr-v1", "Expr", "unicode", 1, 4], "max_depth": 4, "total_calls": 1, "max_calls": 8, "accepted": True, "diagnostic": None},
    {"id": "exact_repeat", "active": [["expr-v1", "Expr", "unicode", 1, 4]], "candidate": ["expr-v1", "Expr", "unicode", 1, 4], "max_depth": 4, "total_calls": 1, "max_calls": 8, "accepted": False, "diagnostic": "progressive_cycle_non_decreasing"},
    {"id": "shifted_equal_length", "active": [["expr-v1", "Expr", "unicode", 0, 3]], "candidate": ["expr-v1", "Expr", "unicode", 1, 4], "max_depth": 4, "total_calls": 1, "max_calls": 8, "accepted": False, "diagnostic": "progressive_cycle_non_decreasing"},
    {"id": "larger_repeat", "active": [["expr-v1", "Expr", "unicode", 1, 3]], "candidate": ["expr-v1", "Expr", "unicode", 0, 5], "max_depth": 4, "total_calls": 1, "max_calls": 8, "accepted": False, "diagnostic": "progressive_cycle_non_decreasing"},
    {"id": "different_identity", "active": [["expr-v1", "Expr", "unicode", 0, 5]], "candidate": ["json-v1", "Document", "unicode", 0, 5], "max_depth": 4, "total_calls": 1, "max_calls": 8, "accepted": True, "diagnostic": None},
    {"id": "depth_limit", "active": [["expr-v1", "Expr", "unicode", 0, 5], ["json-v1", "Document", "unicode", 0, 5]], "candidate": ["expr-v1", "Value", "unicode", 1, 4], "max_depth": 2, "total_calls": 2, "max_calls": 8, "accepted": False, "diagnostic": "progressive_depth_exceeded"},
    {"id": "call_limit", "active": [], "candidate": ["expr-v1", "Expr", "unicode", 0, 5], "max_depth": 4, "total_calls": 8, "max_calls": 8, "accepted": False, "diagnostic": "progressive_call_limit_exceeded"},
]

EXECUTION_CASES = [
    {
        "id": "detached_success",
        "parent_before": {"cursor": 4, "boundary": 2, "marks": [["m", 3]], "variables": {"x": 1}, "transactions": [], "captures": ["a"]},
        "parent_after": {"cursor": 4, "boundary": 2, "marks": [["m", 3]], "variables": {"x": 1}, "transactions": [], "captures": ["a"]},
        "budget_before": 20,
        "child_cost": 5,
        "budget_after": 15,
        "child_result": {"kind": "expr", "span": {"source_id": "unicode", "start": 1, "end": 4, "provenance": "child-match"}},
        "accepted": True,
        "diagnostic": None,
        "parent_progress": False,
    },
    {
        "id": "false_payload",
        "parent_before": {"cursor": 0, "boundary": 0, "marks": [], "variables": {}, "transactions": [], "captures": []},
        "parent_after": {"cursor": 0, "boundary": 0, "marks": [], "variables": {}, "transactions": [], "captures": []},
        "budget_before": 4,
        "child_cost": 1,
        "budget_after": 3,
        "child_result": False,
        "accepted": True,
        "diagnostic": None,
        "parent_progress": False,
    },
    {
        "id": "child_failure_propagates",
        "parent_before": {"cursor": 2, "boundary": 1, "marks": [], "variables": {}, "transactions": [], "captures": []},
        "parent_after": {"cursor": 2, "boundary": 1, "marks": [], "variables": {}, "transactions": [], "captures": []},
        "budget_before": 7,
        "child_cost": 2,
        "budget_after": 5,
        "child_result": None,
        "accepted": False,
        "diagnostic": "progressive_child_failed",
        "parent_progress": False,
    },
    {
        "id": "live_handle_rejected",
        "parent_before": {"cursor": 1, "boundary": 1, "marks": [], "variables": {}, "transactions": [], "captures": []},
        "parent_after": {"cursor": 1, "boundary": 1, "marks": [], "variables": {}, "transactions": [], "captures": []},
        "budget_before": 5,
        "child_cost": 1,
        "budget_after": 4,
        "child_result": {"parser_handle": "opaque:live"},
        "accepted": False,
        "diagnostic": "progressive_result_not_detached",
        "parent_progress": False,
    },
]

CURRENT_BOUNDARY = {
    "status": "all_backend_rows_pending_and_unavailable",
    "typed_rollout": {
        "path": "capability_conformance/typed_source_location_contract.json",
        "leg": "progressive_span_dispatch",
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.14.6",
    },
    "recognition_effect": {
        "path": "capability_conformance/recognition_transaction_contract.json",
        "effect": "parser_registry_or_staged_dispatch",
        "classification": "rejected",
        "action_ir_rows": [],
        "canonical_call_rows": [],
    },
    "perl_lowering_probe": {
        "source": 'return(dispatch_span("expr-v1", "Expr", span));',
        "callee_marker": "dispatch_span",
        "unsupported_marker": "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER",
        "expected_occurrences": 1,
    },
    "backend_guard_groups": [
        {
            "backend": "perl",
            "paths": [
                "perl/LinkedSpec/ActionIR/Contracts.pm",
                "perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm",
                "perl/LinkedSpec/ActionIR/ValueExpr.pm",
            ],
            "forbidden_tokens": ["dispatch_span", "PROGRESSIVE_DISPATCH_SPAN"],
        },
        {
            "backend": "rust",
            "paths": [
                "rust/linkedspec-core/src/callable_contract.rs",
                "rust/linkedspec-core/src/expr.rs",
                "rust/linkedspec-runtime/src/engine.rs",
            ],
            "forbidden_tokens": ["dispatch_span", "PROGRESSIVE_DISPATCH_SPAN"],
        },
        {
            "backend": "dart",
            "paths": [
                "dart/lib/src/action/action_contracts.dart",
                "dart/lib/src/action/action_parser.dart",
                "dart/lib/src/runtime/interpreter.dart",
            ],
            "forbidden_tokens": ["dispatch_span", "PROGRESSIVE_DISPATCH_SPAN"],
        },
        {
            "backend": "julia",
            "paths": [
                "julia/src/action/ActionContracts.jl",
                "julia/src/action/ActionParser.jl",
                "julia/src/runtime/Interpreter.jl",
            ],
            "forbidden_tokens": ["dispatch_span", "PROGRESSIVE_DISPATCH_SPAN"],
        },
        {
            "backend": "lua",
            "paths": [
                "lua/src/linkedspec/action_ast.lua",
                "lua/src/linkedspec/action_call_names.lua",
                "lua/src/linkedspec/action_contracts.lua",
                "lua/src/linkedspec/action_parser.lua",
                "lua/src/linkedspec/interpreter.lua",
            ],
            "forbidden_tokens": ["dispatch_span", "PROGRESSIVE_DISPATCH_SPAN"],
        },
    ],
    "outward_guard": {
        "paths": [
            "perl/LinkedSpec.pm",
            "rust/linkedspec-runtime/src/lib.rs",
            "dart/lib/linkedspec_dart.dart",
            "julia/src/LinkedSpecJulia.jl",
            "lua/src/linkedspec/init.lua",
            "capability_conformance/outward_descriptor_contract.json",
            "capability_conformance/semantic_introspection_model.json",
            "capability_conformance/mcp_semantic_transport/schema.json",
            "cli_conformance/manifest.json",
            "README.md",
        ],
        "forbidden_tokens": ["dispatch_span", "PROGRESSIVE_DISPATCH_SPAN", "progressive_span_dispatch"],
    },
}

DIAGNOSTICS = [
    ("progressive_parser_identity_literal_required", ["code", "origin", "operand"]),
    ("progressive_parser_identity_invalid", ["code", "origin", "parser_id"]),
    ("progressive_top_rule_literal_required", ["code", "origin", "operand"]),
    ("progressive_top_rule_invalid", ["code", "origin", "top_rule"]),
    ("progressive_span_binding_required", ["code", "origin", "operand"]),
    ("progressive_span_shape_invalid", ["code", "origin", "fields"]),
    ("progressive_span_source_mismatch", ["code", "origin", "expected_source_id", "actual_source_id"]),
    ("progressive_span_out_of_bounds", ["code", "origin", "source_id", "start", "end", "source_length"]),
    ("progressive_span_reversed", ["code", "origin", "source_id", "start", "end"]),
    ("progressive_registry_missing", ["code", "origin", "parser_id"]),
    ("progressive_registry_mutation_forbidden", ["code", "origin", "parser_id"]),
    ("progressive_implicit_load_forbidden", ["code", "origin", "parser_id"]),
    ("progressive_top_rule_forbidden", ["code", "origin", "parser_id", "top_rule"]),
    ("progressive_capability_denied", ["code", "origin", "parser_id", "capability"]),
    ("progressive_policy_denied", ["code", "origin", "parser_id", "policy"]),
    ("progressive_source_detail_denied", ["code", "origin", "required", "effective"]),
    ("progressive_cancelled", ["code", "origin", "parser_id"]),
    ("progressive_deadline_exceeded", ["code", "origin", "parser_id", "deadline"]),
    ("progressive_budget_exhausted", ["code", "origin", "parser_id", "remaining"]),
    ("progressive_cancellation_authority_mismatch", ["code", "origin", "parser_id"]),
    ("progressive_cycle_non_decreasing", ["code", "origin", "parser_id", "top_rule", "source_id", "span", "active_span"]),
    ("progressive_depth_exceeded", ["code", "origin", "depth", "maximum"]),
    ("progressive_call_limit_exceeded", ["code", "origin", "calls", "maximum"]),
    ("progressive_child_failed", ["code", "origin", "parser_id", "top_rule", "source_id", "span", "child_diagnostic"]),
    ("progressive_transaction_forbidden", ["code", "origin", "effect"]),
    ("progressive_result_not_detached", ["code", "origin", "parser_id", "field"]),
]

ROLLOUT = [
    (1, "FUTURE-PARITY-BACKLOG.14.6.1", "neutral", "complete", ["capability_conformance/progressive_span_dispatch_contract.json", "tools/check_progressive_span_dispatch_contract.py"]),
    (2, "FUTURE-PARITY-BACKLOG.14.6.2", "perl", "pending", []),
    (3, "FUTURE-PARITY-BACKLOG.14.6.3", "rust", "pending", []),
    (4, "FUTURE-PARITY-BACKLOG.14.6.4", "dart", "pending", []),
    (5, "FUTURE-PARITY-BACKLOG.14.6.5", "julia", "pending", []),
    (6, "FUTURE-PARITY-BACKLOG.14.6.6", "puc_lua", "pending", []),
    (7, "FUTURE-PARITY-BACKLOG.14.6.6", "luajit", "pending", []),
    (8, "FUTURE-PARITY-BACKLOG.14.6.7", "recurring", "pending", []),
    (9, "FUTURE-PARITY-BACKLOG.14.6.8", "public_no_drift", "pending", []),
]

CANONICAL_EXECUTION = {
    "contract_path": "capability_conformance/progressive_span_dispatch_contract.json",
    "checker_path": "tools/check_progressive_span_dispatch_contract.py",
    "project_data_runner": "tools/run_python_project_data.sh",
    "canonical_driver": "tools/run_ci_local.sh",
    "registration_marker": "checking backend-neutral progressive span-dispatch contract",
    "invocation": "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py",
    "storage_policy": "all Python cache, temporary, and process data stays under repository-derived project storage",
    "tracked_required": True,
}


class ContractError(RuntimeError):
    """One progressive span-dispatch invariant failed."""


def fail(message: str) -> None:
    raise ContractError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def require_fields(value: Any, fields: list[str], context: str) -> dict[str, Any]:
    require(isinstance(value, dict) and list(value) == fields, f"{context} fields/order drifted")
    return value


def source_by_id(document: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {row["id"]: row for row in document["sources"]}


def evaluate_view(case: dict[str, Any], sources: dict[str, dict[str, Any]]) -> tuple[bool, str | None, str | None, list[int] | None]:
    span = case["span"]
    expected_fields = ["source_id", "start", "end", "provenance"]
    if not isinstance(span, dict) or list(span) != expected_fields:
        return False, "progressive_span_shape_invalid", None, None
    if not all(isinstance(span[key], str) and span[key] for key in ("source_id", "provenance")):
        return False, "progressive_span_shape_invalid", None, None
    if not all(isinstance(span[key], int) and not isinstance(span[key], bool) for key in ("start", "end")):
        return False, "progressive_span_shape_invalid", None, None
    if span["source_id"] != case["authority_source_id"]:
        return False, "progressive_span_source_mismatch", None, None
    source = sources.get(span["source_id"])
    if source is None or span["start"] < 0 or span["end"] > source["scalar_length"]:
        return False, "progressive_span_out_of_bounds", None, None
    if span["start"] > span["end"]:
        return False, "progressive_span_reversed", None, None
    return (
        True,
        None,
        source["text"][span["start"] : span["end"]],
        list(range(span["start"], span["end"] + 1)),
    )


def effective_authority(case: dict[str, Any], entries: dict[str, dict[str, Any]]) -> tuple[bool, str | None, dict[str, Any] | None]:
    entry = entries[case["entry_id"]]
    capabilities = sorted(set(case["caller_capabilities"]) & set(entry["capabilities"]))
    if not set(case["required_capabilities"]).issubset(capabilities):
        return False, "progressive_capability_denied", None
    caller = case["caller_ceilings"]
    registered = entry["ceilings"]
    policy_modes = sorted(set(caller["policy_modes"]) & set(registered["policy_modes"]))
    if not policy_modes:
        return False, "progressive_policy_denied", None
    source_detail = SOURCE_DETAIL_ORDER[
        min(
            SOURCE_DETAIL_ORDER.index(caller["source_detail"]),
            SOURCE_DETAIL_ORDER.index(registered["source_detail"]),
        )
    ]
    if SOURCE_DETAIL_ORDER.index(source_detail) < SOURCE_DETAIL_ORDER.index(case["required_source_detail"]):
        return False, "progressive_source_detail_denied", None
    return True, None, {
        "capabilities": capabilities,
        "source_detail": source_detail,
        "policy_modes": policy_modes,
        "max_steps": min(caller["max_steps"], registered["max_steps"]),
        "max_result_nodes": min(caller["max_result_nodes"], registered["max_result_nodes"]),
        "max_diagnostic_bytes": min(caller["max_diagnostic_bytes"], registered["max_diagnostic_bytes"]),
    }


def evaluate_cancellation(case: dict[str, Any]) -> tuple[bool, str | None, int]:
    if case["child_token"] != case["token"]:
        return False, "progressive_cancellation_authority_mismatch", case["remaining_steps"]
    if case["cancelled"]:
        return False, "progressive_cancelled", case["remaining_steps"]
    if case["now_tick"] >= case["deadline_tick"]:
        return False, "progressive_deadline_exceeded", case["remaining_steps"]
    if case["remaining_steps"] <= 0 or case["cost"] > case["remaining_steps"]:
        return False, "progressive_budget_exhausted", case["remaining_steps"]
    return True, None, case["remaining_steps"] - case["cost"]


def evaluate_chain(case: dict[str, Any]) -> tuple[bool, str | None]:
    if len(case["active"]) >= case["max_depth"]:
        return False, "progressive_depth_exceeded"
    if case["total_calls"] >= case["max_calls"]:
        return False, "progressive_call_limit_exceeded"
    parser_id, top_rule, source_id, start, end = case["candidate"]
    for active in case["active"]:
        if active[:3] != [parser_id, top_rule, source_id]:
            continue
        active_start, active_end = active[3], active[4]
        contained = active_start <= start <= end <= active_end
        smaller = end - start < active_end - active_start
        if not contained or not smaller:
            return False, "progressive_cycle_non_decreasing"
    return True, None


def contains_live_authority(value: Any) -> bool:
    forbidden = ("authority", "handle", "parser", "registry", "transaction", "cancellation", "path", "source_text", "host")
    if isinstance(value, dict):
        return any(any(token in key.lower() for token in forbidden) or contains_live_authority(item) for key, item in value.items())
    if isinstance(value, list):
        return any(contains_live_authority(item) for item in value)
    return False


def validate_contract(document: dict[str, Any], *, check_environment: bool = True) -> None:
    require_fields(
        document,
        [
            "format",
            "contract_id",
            "task_owner",
            "status",
            "expected_counts",
            "authored_surface",
            "policy",
            "registry_schema",
            "registry_entries",
            "sources",
            "view_cases",
            "authority_cases",
            "cancellation_cases",
            "chain_cases",
            "execution_cases",
            "current_boundary",
            "diagnostics",
            "rollout",
            "canonical_execution",
            "mutation_ids",
        ],
        "contract",
    )
    require(document["format"] == 1, "format drifted")
    require(document["contract_id"] == "linkedspec-progressive-span-dispatch-v1", "contract id drifted")
    require(document["task_owner"] == "FUTURE-PARITY-BACKLOG.14.6.1", "task owner drifted")
    require(document["status"] == "neutral_complete_backends_pending", "status drifted")
    expected_counts = {
        "registry_entries": len(REGISTRY_ENTRIES),
        "sources": len(SOURCES),
        "view_cases": len(VIEW_CASES),
        "authority_cases": len(AUTHORITY_CASES),
        "cancellation_cases": len(CANCELLATION_CASES),
        "chain_cases": len(CHAIN_CASES),
        "execution_cases": len(EXECUTION_CASES),
        "backend_guard_groups": len(CURRENT_BOUNDARY["backend_guard_groups"]),
        "backend_guard_paths": sum(len(group["paths"]) for group in CURRENT_BOUNDARY["backend_guard_groups"]),
        "outward_guard_paths": len(CURRENT_BOUNDARY["outward_guard"]["paths"]),
        "diagnostics": len(DIAGNOSTICS),
        "rollout_legs": len(ROLLOUT),
        "mutations": len(MUTATIONS),
    }
    require(document["expected_counts"] == expected_counts, "expected counts drifted")
    require(document["authored_surface"] == AUTHORED_SURFACE, "authored surface drifted")
    require(document["policy"] == POLICY, "policy drifted")
    require(document["registry_schema"] == REGISTRY_SCHEMA, "registry schema drifted")
    require(document["registry_entries"] == REGISTRY_ENTRIES, "registry entries drifted")
    require(document["sources"] == SOURCES, "source fixtures drifted")
    require(document["view_cases"] == VIEW_CASES, "source-view fixtures drifted")
    require(document["authority_cases"] == AUTHORITY_CASES, "authority fixtures drifted")
    require(document["cancellation_cases"] == CANCELLATION_CASES, "cancellation fixtures drifted")
    require(document["chain_cases"] == CHAIN_CASES, "chain fixtures drifted")
    require(document["execution_cases"] == EXECUTION_CASES, "execution fixtures drifted")
    require(document["current_boundary"] == CURRENT_BOUNDARY, "current boundary drifted")

    for entry in document["registry_entries"]:
        require_fields(entry, REGISTRY_SCHEMA["fields"], "registry entry")
        require(re.fullmatch(PARSER_ID_PATTERN, entry["parser_id"]) is not None, "registry parser identity invalid")
        require(entry["compiled_authority"].startswith("opaque:compiled-"), "compiled parser authority is not opaque")
        require(re.fullmatch(REGISTRY_SCHEMA["fingerprint_pattern"], entry["fingerprint"]) is not None, "registry fingerprint invalid")
        require(entry["allowed_top_rules"] == sorted(set(entry["allowed_top_rules"])), "allowed top rules drifted")
        require(all(re.fullmatch(TOP_RULE_PATTERN, rule) for rule in entry["allowed_top_rules"]), "allowed top rule invalid")
        require(entry["capabilities"] == sorted(set(entry["capabilities"])), "registry capabilities drifted")
        require(entry["ceilings"]["source_detail"] in SOURCE_DETAIL_ORDER, "source-detail ceiling invalid")
        require(all(isinstance(entry["ceilings"][key], int) and entry["ceilings"][key] > 0 for key in ("max_steps", "max_result_nodes", "max_diagnostic_bytes")), "numeric registry ceiling invalid")
        require(not any(field in entry for field in REGISTRY_SCHEMA["forbidden_fields"]), "registry entry contains loading authority")

    sources = source_by_id(document)
    require(list(sources) == ["unicode", "ascii"], "source identity/order drifted")
    for source in sources.values():
        require(len(source["text"]) == source["scalar_length"], "source scalar length drifted")
        offsets = [len(source["text"][:index].encode("utf-8")) for index in range(len(source["text"]) + 1)]
        require(offsets == source["utf8_offsets"], "source UTF-8 mapping drifted")
    for case in document["view_cases"]:
        accepted, diagnostic, view_text, local_to_global = evaluate_view(case, sources)
        require((accepted, diagnostic, view_text, local_to_global) == (case["accepted"], case["diagnostic"], case["view_text"], case["local_to_global"]), f"source-view result drifted: {case['id']}")

    entries = {entry["parser_id"]: entry for entry in document["registry_entries"]}
    for case in document["authority_cases"]:
        accepted, diagnostic, effective = effective_authority(case, entries)
        require((accepted, diagnostic, effective) == (case["accepted"], case["diagnostic"], case["effective"]), f"authority result drifted: {case['id']}")
    for case in document["cancellation_cases"]:
        accepted, diagnostic, remaining_after = evaluate_cancellation(case)
        require((accepted, diagnostic, remaining_after) == (case["accepted"], case["diagnostic"], case["remaining_after"]), f"cancellation result drifted: {case['id']}")
    for case in document["chain_cases"]:
        accepted, diagnostic = evaluate_chain(case)
        require((accepted, diagnostic) == (case["accepted"], case["diagnostic"]), f"chain result drifted: {case['id']}")
    for case in document["execution_cases"]:
        require(case["parent_before"] == case["parent_after"], f"parent state leaked: {case['id']}")
        require(case["budget_after"] == case["budget_before"] - case["child_cost"], f"shared budget accounting drifted: {case['id']}")
        require(case["parent_progress"] is False, f"dispatch claimed parent progress: {case['id']}")
        detached = not contains_live_authority(case["child_result"])
        if case["diagnostic"] == "progressive_result_not_detached":
            require(not detached and not case["accepted"], "live child authority was accepted")
        elif case["accepted"]:
            require(detached, "accepted child result is not detached")
        else:
            require(case["diagnostic"] == "progressive_child_failed", "child failure policy drifted")

    observed_diagnostics = [(row["code"], row["required_context"]) for row in document["diagnostics"]]
    require(observed_diagnostics == DIAGNOSTICS, "diagnostic membership/order/context drifted")
    require(len({code for code, _context in observed_diagnostics}) == len(DIAGNOSTICS), "diagnostic codes duplicated")
    observed_rollout = [(row["order"], row["owner"], row["leg"], row["status"], row["paths"]) for row in document["rollout"]]
    require(observed_rollout == ROLLOUT, "rollout order/owner/status/path drifted")
    require(document["canonical_execution"] == CANONICAL_EXECUTION, "canonical execution drifted")
    require(document["mutation_ids"] == [name for name, _mutate in MUTATIONS], "mutation identity/order drifted")

    if check_environment:
        typed_assertion = CURRENT_BOUNDARY["typed_rollout"]
        typed_path = ROOT / typed_assertion["path"]
        require(typed_path.is_file(), "typed source-location contract is missing")
        typed = json.loads(typed_path.read_text(encoding="utf-8"))
        typed_rows = [row for row in typed["rollout"] if row["leg"] == typed_assertion["leg"]]
        require(len(typed_rows) == 1, "typed progressive rollout row missing or duplicated")
        typed_row = typed_rows[0]
        require(
            typed_row["status"] == typed_assertion["status"]
            and typed_row["owner"] == typed_assertion["owner"]
            and typed_row["runtimes"] == [],
            "typed progressive rollout boundary drifted",
        )

        effect_assertion = CURRENT_BOUNDARY["recognition_effect"]
        recognition_path = ROOT / effect_assertion["path"]
        require(recognition_path.is_file(), "recognition transaction contract is missing")
        recognition = json.loads(recognition_path.read_text(encoding="utf-8"))
        effect = effect_assertion["effect"]
        require(effect in recognition["effect_model"][effect_assertion["classification"]], "dispatch effect is not rejected")
        require(recognition["action_ir_effect_rows"][effect] == effect_assertion["action_ir_rows"], "current ActionIR dispatch rows drifted")
        require(recognition["canonical_call_effect_rows"][effect] == effect_assertion["canonical_call_rows"], "current callable dispatch rows drifted")

        for group in CURRENT_BOUNDARY["backend_guard_groups"]:
            for relative_path in group["paths"]:
                guarded_path = ROOT / relative_path
                require(guarded_path.is_file(), f"current-boundary guard path is missing: {relative_path}")
                content = guarded_path.read_text(encoding="utf-8")
                for token in group["forbidden_tokens"]:
                    require(token not in content, f"pending {group['backend']} backend contains {token}: {relative_path}")

        outward_guard = CURRENT_BOUNDARY["outward_guard"]
        for relative_path in outward_guard["paths"]:
            guarded_path = ROOT / relative_path
            require(guarded_path.is_file(), f"outward guard path is missing: {relative_path}")
            content = guarded_path.read_text(encoding="utf-8")
            for token in outward_guard["forbidden_tokens"]:
                require(token not in content, f"premature outward progressive surface in {relative_path}: {token}")

        probe_assertion = CURRENT_BOUNDARY["perl_lowering_probe"]
        probe = subprocess.run(
            [
                "perl",
                "-Iperl",
                "-MLinkedSpec",
                "-e",
                f'print LinkedSpec::call_spec_handler_subst("Top", q{{{probe_assertion["source"]}}})',
            ],
            cwd=ROOT,
            check=False,
            capture_output=True,
            text=True,
        )
        probe_output = probe.stdout + probe.stderr
        require(probe.returncode == 0, "current Perl lowering probe failed to execute")
        require(probe_output.count(probe_assertion["callee_marker"]) == probe_assertion["expected_occurrences"], "current Perl lowering probe callee evidence drifted")
        require(probe_output.count(probe_assertion["unsupported_marker"]) == probe_assertion["expected_occurrences"], "current Perl lowering no-support evidence drifted")

        require(CI_PATH.is_file(), "canonical CI driver is missing")
        ci = CI_PATH.read_text(encoding="utf-8")
        require(ci.count(f"require_tracked_file {CANONICAL_EXECUTION['contract_path']}") == 1, "canonical CI must require the progressive contract exactly once")
        require(ci.count(f"require_tracked_file {CANONICAL_EXECUTION['checker_path']}") == 1, "canonical CI must require the progressive checker exactly once")
        require(ci.count(f'log "{CANONICAL_EXECUTION["registration_marker"]}"') == 1, "canonical registration marker missing or duplicated")
        require(ci.count(CANONICAL_EXECUTION["invocation"]) == 1, "canonical invocation missing or duplicated")
        require(ci.count("tools/check_progressive_span_dispatch_contract.py") == 4, "progressive checker inventory/require/invocation topology drifted")


def set_value(path: list[Any], value: Any) -> Callable[[dict[str, Any]], None]:
    def mutate(document: dict[str, Any]) -> None:
        target: Any = document
        for key in path[:-1]:
            target = target[key]
        target[path[-1]] = value
    return mutate


def pop_value(path: list[Any]) -> Callable[[dict[str, Any]], None]:
    def mutate(document: dict[str, Any]) -> None:
        target: Any = document
        for key in path[:-1]:
            target = target[key]
        target[path[-1]].pop()
    return mutate


MUTATIONS: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
    ("format", set_value(["format"], 2)),
    ("contract_id", set_value(["contract_id"], "wrong")),
    ("task_owner", set_value(["task_owner"], "FUTURE-PARITY-BACKLOG.14.6")),
    ("status", set_value(["status"], "implemented")),
    ("count_registry", set_value(["expected_counts", "registry_entries"], 1)),
    ("count_mutations", set_value(["expected_counts", "mutations"], 1)),
    ("authored_example", set_value(["authored_surface", "example"], "dispatch_span(span)")),
    ("authored_callee", set_value(["authored_surface", "callee"], "parse_job")),
    ("authored_node", set_value(["authored_surface", "node_kind"], "CALL")),
    ("authored_effect", set_value(["authored_surface", "effect"], "source_read")),
    ("authored_operand", set_value(["authored_surface", "operands", 0], "dynamic parser")),
    ("authored_result", set_value(["authored_surface", "result"], "live parser result")),
    ("authored_failure", set_value(["authored_surface", "failure_policy"], "fallback")),
    ("authored_availability", set_value(["authored_surface", "availability"], "current")),
    ("policy_registry", set_value(["policy", "registry"], "load paths dynamically")),
    ("policy_identity", set_value(["policy", "identity"], "dynamic strings")),
    ("policy_span", set_value(["policy", "span"], "copied text")),
    ("policy_source_view", set_value(["policy", "source_view"], "new source identity")),
    ("policy_state", set_value(["policy", "state"], "share parent state")),
    ("policy_result", set_value(["policy", "result"], "return handles")),
    ("policy_capabilities", set_value(["policy", "capabilities"], "union")),
    ("policy_ceilings", set_value(["policy", "ceilings"], "child maximum")),
    ("policy_cancellation", set_value(["policy", "cancellation"], "new deadline")),
    ("policy_cycles", set_value(["policy", "cycles"], "allow exact repeats")),
    ("policy_bounds", set_value(["policy", "bounds"], "unbounded")),
    ("policy_progress", set_value(["policy", "progress"], "child success advances parent")),
    ("policy_transactions", set_value(["policy", "transactions"], "rollback dispatch")),
    ("policy_loading", set_value(["policy", "loading"], "filesystem allowed")),
    ("registry_schema_field", pop_value(["registry_schema", "fields"])),
    ("registry_identity_pattern", set_value(["registry_schema", "identity_pattern"], ".*")),
    ("registry_mutable", set_value(["registry_schema", "immutable_during_execution"], False)),
    ("registry_forbidden_fields", pop_value(["registry_schema", "forbidden_fields"])),
    ("registry_entry_removed", pop_value(["registry_entries"])),
    ("registry_parser_id", set_value(["registry_entries", 0, "parser_id"], "../expr.spec")),
    ("registry_compiled_authority", set_value(["registry_entries", 0, "compiled_authority"], "/tmp/expr")),
    ("registry_fingerprint", set_value(["registry_entries", 0, "fingerprint"], "sha256:bad")),
    ("registry_top_rule", set_value(["registry_entries", 0, "allowed_top_rules", 0], "Expr/Path")),
    ("registry_capability_order", set_value(["registry_entries", 0, "capabilities"], ["typed-source-location-v1", "actionir-v1"])),
    ("registry_source_ceiling", set_value(["registry_entries", 0, "ceilings", "source_detail"], "host")),
    ("registry_numeric_ceiling", set_value(["registry_entries", 0, "ceilings", "max_steps"], 0)),
    ("source_removed", pop_value(["sources"])),
    ("source_scalar_length", set_value(["sources", 0, "scalar_length"], 6)),
    ("source_utf8_map", set_value(["sources", 0, "utf8_offsets", 2], 2)),
    ("view_removed", pop_value(["view_cases"])),
    ("view_text", set_value(["view_cases", 0, "view_text"], "copied")),
    ("view_global_map", set_value(["view_cases", 0, "local_to_global"], [0, 1, 2, 3])),
    ("view_reversed_accepted", set_value(["view_cases", 4, "accepted"], True)),
    ("authority_removed", pop_value(["authority_cases"])),
    ("authority_intersection", set_value(["authority_cases", 0, "effective", "capabilities"], ["caller-only"])),
    ("authority_source_minimum", set_value(["authority_cases", 0, "effective", "source_detail"], "text")),
    ("authority_resource_minimum", set_value(["authority_cases", 0, "effective", "max_steps"], 100)),
    ("authority_missing_capability", set_value(["authority_cases", 2, "accepted"], True)),
    ("cancellation_removed", pop_value(["cancellation_cases"])),
    ("cancellation_token_reset", set_value(["cancellation_cases", 0, "child_token"], "new")),
    ("cancellation_deadline", set_value(["cancellation_cases", 2, "accepted"], True)),
    ("cancellation_budget", set_value(["cancellation_cases", 4, "remaining_after"], -1)),
    ("chain_removed", pop_value(["chain_cases"])),
    ("chain_exact_repeat", set_value(["chain_cases", 2, "accepted"], True)),
    ("chain_depth", set_value(["chain_cases", 6, "diagnostic"], None)),
    ("chain_call_limit", set_value(["chain_cases", 7, "accepted"], True)),
    ("execution_removed", pop_value(["execution_cases"])),
    ("execution_parent_cursor", set_value(["execution_cases", 0, "parent_after", "cursor"], 5)),
    ("execution_budget", set_value(["execution_cases", 0, "budget_after"], 20)),
    ("execution_progress", set_value(["execution_cases", 0, "parent_progress"], True)),
    ("execution_live_result", set_value(["execution_cases", 0, "child_result"], {"registry_handle": "live"})),
    ("current_status", set_value(["current_boundary", "status"], "current")),
    ("current_typed_path", set_value(["current_boundary", "typed_rollout", "path"], "wrong.json")),
    ("current_typed_leg", set_value(["current_boundary", "typed_rollout", "leg"], "staged_span_dispatch")),
    ("current_typed_status", set_value(["current_boundary", "typed_rollout", "status"], "complete")),
    ("current_typed_owner", set_value(["current_boundary", "typed_rollout", "owner"], "FUTURE-PARITY-BACKLOG.14.6.1")),
    ("current_recognition_path", set_value(["current_boundary", "recognition_effect", "path"], "wrong.json")),
    ("current_recognition_effect", set_value(["current_boundary", "recognition_effect", "effect"], "pure_value")),
    ("current_recognition_classification", set_value(["current_boundary", "recognition_effect", "classification"], "allowed")),
    ("current_perl_probe_marker", set_value(["current_boundary", "perl_lowering_probe", "unsupported_marker"], "supported")),
    ("current_perl_probe_callee", set_value(["current_boundary", "perl_lowering_probe", "callee_marker"], "parse_job")),
    ("current_backend_guard_path", set_value(["current_boundary", "backend_guard_groups", 0, "paths", 0], "wrong.pm")),
    ("current_backend_guard_token", set_value(["current_boundary", "backend_guard_groups", 0, "forbidden_tokens", 0], "parse_job")),
    ("current_outward_guard_path", set_value(["current_boundary", "outward_guard", "paths", 0], "wrong.pm")),
    ("current_outward_guard_dispatch", set_value(["current_boundary", "outward_guard", "forbidden_tokens", 0], "parse_job")),
    ("current_outward_guard_rollout", set_value(["current_boundary", "outward_guard", "forbidden_tokens", 2], "staged_span_dispatch")),
    ("diagnostic_removed", pop_value(["diagnostics"])),
    ("diagnostic_context", pop_value(["diagnostics", 0, "required_context"])),
    ("rollout_removed", pop_value(["rollout"])),
    ("rollout_perl_promoted", set_value(["rollout", 1, "status"], "complete")),
    ("canonical_checker", set_value(["canonical_execution", "checker_path"], "tools/wrong.py")),
    ("canonical_storage", set_value(["canonical_execution", "storage_policy"], "/tmp")),
]


def mutation_checks(document: dict[str, Any]) -> int:
    for name, mutate in MUTATIONS:
        candidate = copy.deepcopy(document)
        mutate(candidate)
        try:
            validate_contract(candidate, check_environment=False)
        except ContractError:
            continue
        fail(f"mutation was not rejected: {name}")
    return len(MUTATIONS)


def main() -> int:
    if not CONTRACT_PATH.is_file():
        fail("progressive span-dispatch contract is missing")
    document = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(document)
    mutations = mutation_checks(document)
    complete = sum(row["status"] == "complete" for row in document["rollout"])
    pending = len(document["rollout"]) - complete
    print(
        "progressive-span-dispatch-contract: OK "
        f"({len(document['registry_entries'])} registry entries; "
        f"{len(document['sources'])} sources/{len(document['view_cases'])} views; "
        f"{len(document['authority_cases'])} authority + "
        f"{len(document['cancellation_cases'])} cancellation + "
        f"{len(document['chain_cases'])} chain + "
        f"{len(document['execution_cases'])} execution cases; "
        f"{len(document['current_boundary']['backend_guard_groups'])} backend guards/"
        f"{sum(len(group['paths']) for group in document['current_boundary']['backend_guard_groups'])} paths; "
        f"{len(document['current_boundary']['outward_guard']['paths'])} outward guards; "
        f"{len(document['diagnostics'])} diagnostics; "
        f"rollout {complete}/{len(document['rollout'])} complete, {pending} pending; "
        f"{mutations} rejected mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

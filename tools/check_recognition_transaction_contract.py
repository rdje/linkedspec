#!/usr/bin/env python3
"""Independently validate the neutral recognition-transaction v1 contract."""

from __future__ import annotations

import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "recognition_transaction_contract.json"
PERL_CONTRACTS_PATH = ROOT / "perl" / "LinkedSpec" / "ActionIR" / "Contracts.pm"
DART_CONTRACTS_PATH = ROOT / "dart" / "lib" / "src" / "action" / "action_contracts.dart"
JULIA_CONTRACTS_PATH = ROOT / "julia" / "src" / "action" / "ActionContracts.jl"
LUA_CALL_NAMES_PATH = ROOT / "lua" / "src" / "linkedspec" / "action_call_names.lua"
CI_PATH = ROOT / "tools" / "run_ci_local.sh"
PERL_CONSUMER_PATH = "t/recognition_transaction_perl_contract.t"
RUST_CONSUMER_PATH = "rust/linkedspec-runtime/tests/recognition_transaction_contract.rs"
DART_CONSUMER_PATH = "dart/test/recognition_transaction_contract_test.dart"
DART_DORMANT_CONSUMER_PATH = (
    "dart/test_dormant/recognition_transaction_contract_test.dart"
)
DART_FACADE_PATH = "dart/lib/linkedspec_dart.dart"
DART_PRIVATE_IMPORT = (
    "package:linkedspec_dart/src/runtime/recognition_transaction.dart"
)
JULIA_CONSUMER_PATH = "julia/test/recognition_transaction_contract_test.jl"
JULIA_RUNTESTS_PATH = "julia/test/runtests.jl"
JULIA_FACADE_PATH = "julia/src/LinkedSpecJulia.jl"
JULIA_ORDINARY_INCLUDE = 'include("recognition_transaction_contract_test.jl")'
JULIA_PRIVATE_AUTHORITY_ACCESS = """const JuliaRecognitionTransaction = getproperty(
    LinkedSpecJulia,
    :RecognitionTransaction,
)"""
LUA_CONSUMER_PATH = "lua/test/recognition_transaction_contract_test.lua"
LUA_ORDINARY_PATH = "tools/run_lua_local.sh"
LUA_FACADE_PATH = "lua/src/linkedspec/init.lua"
LUA_AUTHORITY_PATH = "lua/src/linkedspec/recognition_transaction.lua"
LUA_RED_SELECTOR = (
    'local mode = os.getenv("LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE") '
    'or "authority"'
)
LUA_PRIVATE_REQUIRE = (
    'local loaded, transaction = pcall(require, '
    '"linkedspec.recognition_transaction")'
)
LUA_RED_DIAGNOSTIC = (
    "Lua recognition transaction RED: missing linkedspec.recognition_transaction"
)
LUA_INTEGRATION_RED_DIAGNOSTIC = (
    "Lua recognition transaction integration RED: missing dedicated ActionIR nodes"
)
LUA_AUTHORITY_MARKERS = (
    ('local source_location = require("linkedspec.source_location")', "source authority"),
    ('local private_state = setmetatable({}, { __mode = "k" })', "weak private state"),
    ("function M.node_type(value)", "opaque type query"),
    ("function M.is_error(value)", "typed error query"),
    ("function M.frame_state(first, second)", "detached frame state"),
    ("function M.authority(options)", "private authority"),
    ("function M.enter_invocation(authority_value, options)", "invocation entry"),
    ("function M.frame_snapshot(authority_value, frame_value)", "frame snapshot"),
    ("function M.set_frame_state(authority_value, frame_value, state_value)", "state sync"),
    ("function M.write_mark(authority_value, frame_value, name, offset)", "mark write"),
    ("function M.read_mark(authority_value, frame_value, name)", "mark read"),
    ("function M.checkpoint(authority_value, frame_value, origin)", "checkpoint"),
    ("function M.attempt(authority_value, frame_value, token_value, options)", "attempt"),
    ("function M.commit(authority_value, frame_value, token_value)", "commit"),
    ("function M.rollback(authority_value, frame_value, token_value)", "rollback"),
    ("function M.reject_escape(authority_value, frame_value, token_value, escape)", "escape rejection"),
    ("function M.discard_token(authority_value, frame_value, token_value)", "discard"),
    ("function M.leave_invocation(authority_value, frame_value)", "invocation exit"),
    ("function M.to_json(value)", "detached projection"),
    ("token.payload = json.null", "explicit miss sentinel"),
    ("local payload = token.payload", "falsey commit payload"),
)
RUST_ADMISSION_SOURCE_PATHS = [
    "rust/linkedspec-core/src/lib.rs",
    "rust/linkedspec-core/src/callable_contract.rs",
    "rust/linkedspec-core/src/expr.rs",
    "rust/linkedspec-runtime/src/lib.rs",
    "rust/linkedspec-runtime/src/engine.rs",
    "rust/linkedspec-runtime/src/recognition_transaction.rs",
    "rust/linkedspec-runtime/src/runtime.rs",
    "rust/linkedspec-runtime/src/source_emitter.rs",
    RUST_CONSUMER_PATH,
]

ALLOWED_EFFECTS = [
    "pure_value",
    "source_read",
    "structured_control",
    "rule_recognition",
    "transaction_state",
    "cursor_advance",
    "capture_boundary_write",
    "invocation_mark_write",
    "staged_return",
]
REJECTED_EFFECTS = [
    "binding_write",
    "aggregate_write",
    "ast_or_object_write",
    "compatibility_cursor_control",
    "output",
    "authored_diagnostic",
    "exit_or_unbounded_control",
    "dynamic_callable",
    "parser_registry_or_staged_dispatch",
    "external_or_host",
    "unknown_or_raw",
]
DEDICATED_NODES = [
    "RECOGNITION_COMMIT",
    "RECOGNITION_CHECKPOINT",
    "RECOGNITION_ROLLBACK",
    "RECOGNIZE_ONCE",
]
EXPECTED_COUNTS = {
    "current_action_ir_nodes": 128,
    "dedicated_action_ir_nodes": 4,
    "all_action_ir_nodes": 132,
    "canonical_call_contracts": 246,
    "allowed_effects": 9,
    "rejected_effects": 11,
    "token_positive_cases": 8,
    "token_negative_cases": 17,
    "effect_graph_cases": 6,
    "mark_cases": 6,
    "progress_cases": 8,
    "diagnostics": 15,
    "rollout_legs": 9,
    "mutations": 44,
}
EXPECTED_EFFECT_ROW_HASHES = {
    "action_ir_effect_rows": "560de8fc586cee7adf66e1b6eeab7d931f441ebda6ca9cb0498ecc9d4392f775",
    "canonical_call_effect_rows": "b0e25c4ab45ed53f83e5eaa8a1b2d66ec3ddc5a9cc4764ff031b3903efb64929",
}
EXPECTED_SURFACE = {
    "checkpoint": "tx = recognition_checkpoint()",
    "attempt": "matched = recognize_once(tx, call(Child))",
    "commit": "payload = recognition_commit(tx)",
    "rollback": "recognition_rollback(tx)",
    "operand": "recognize_once accepts exactly one unevaluated static call(Rule) operand",
    "result_separation": (
        "recognize_once returns a strict match boolean; the recognized payload "
        "remains staged until commit"
    ),
    "availability": (
        "available only in an admitted backend; currently Perl, Rust, Dart, and Julia, with "
        "all later runtime legs future and unavailable"
    ),
}
EXPECTED_TOKEN_STATES = [
    "uninitialized",
    "active_unattempted",
    "active_staged_match",
    "active_staged_miss",
    "invalidated",
]
EXPECTED_TOKEN_OPERATIONS = [
    "checkpoint",
    "attempt_match",
    "attempt_miss",
    "commit",
    "rollback",
]
EXPECTED_TRANSITIONS = [
    ["uninitialized", "checkpoint", "active_unattempted"],
    ["active_unattempted", "attempt_match", "active_staged_match"],
    ["active_unattempted", "attempt_miss", "active_staged_miss"],
    ["active_staged_match", "commit", "invalidated"],
    ["active_staged_miss", "commit", "invalidated"],
    ["active_staged_match", "rollback", "invalidated"],
    ["active_staged_miss", "rollback", "invalidated"],
]
EXPECTED_DIAGNOSTICS = [
    ("recognition_token_expected", ["code", "rule", "origin"]),
    ("recognition_token_escape", ["code", "rule", "origin", "escape"]),
    ("recognition_token_reused", ["code", "rule", "origin", "operation"]),
    ("recognition_nesting_forbidden", ["code", "rule", "origin"]),
    ("recognition_cross_invocation", ["code", "rule", "origin", "expected_invocation", "actual_invocation"]),
    ("recognition_cross_source", ["code", "rule", "origin", "expected_source", "actual_source"]),
    ("recognition_attempt_count", ["code", "rule", "origin", "count"]),
    ("recognition_terminal_required", ["code", "rule", "origin"]),
    ("recognition_effect_forbidden", ["code", "rule", "origin", "effect"]),
    ("recognition_unknown_effect", ["code", "rule", "origin", "effect"]),
    ("recognition_zero_progress_repetition", ["code", "rule", "origin", "start_offset", "end_offset"]),
    ("recognition_zero_progress_recursive_cycle", ["code", "rule", "origin", "cycle", "start_offset", "end_offset"]),
    ("recognition_static_rule_required", ["code", "rule", "origin", "operand"]),
    ("recognition_match_boolean_required", ["code", "rule", "origin"]),
    ("recognition_mark_generation_invalid", ["code", "rule", "origin", "generation"]),
]
EXPECTED_ROLLOUT = [
    (1, "FUTURE-PARITY-BACKLOG.14.3.1.1", "neutral", "complete"),
    (2, "FUTURE-PARITY-BACKLOG.14.3.2", "perl", "complete"),
    (3, "FUTURE-PARITY-BACKLOG.14.3.3", "rust", "complete"),
    (4, "FUTURE-PARITY-BACKLOG.14.3.4", "dart", "complete"),
    (5, "FUTURE-PARITY-BACKLOG.14.3.5", "julia", "complete"),
    (6, "FUTURE-PARITY-BACKLOG.14.3.6", "puc_lua", "red"),
    (7, "FUTURE-PARITY-BACKLOG.14.3.6", "luajit", "red"),
    (8, "FUTURE-PARITY-BACKLOG.14.3.7", "recurring", "red"),
    (9, "FUTURE-PARITY-BACKLOG.14.3.8", "public_no_drift", "red"),
]
EXPECTED_EXECUTION = {
    "contract_path": "capability_conformance/recognition_transaction_contract.json",
    "checker_path": "tools/check_recognition_transaction_contract.py",
    "project_data_runner": "tools/run_python_project_data.sh",
    "canonical_driver": "tools/run_ci_local.sh",
    "invocation": "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py",
    "registration_marker": "checking backend-neutral recognition transaction and progress contract",
    "tracked_required": True,
    "freshness_sources": [
        "perl/LinkedSpec/ActionIR/Contracts.pm",
        "dart/lib/src/action/action_contracts.dart",
        "julia/src/action/ActionContracts.jl",
        "lua/src/linkedspec/action_call_names.lua",
    ],
}
EXPECTED_PERL_ADMISSION = {
    "consumer_path": PERL_CONSUMER_PATH,
    "syntax_invocation": f"perl -c -Iperl {PERL_CONSUMER_PATH}",
    "registration_marker": "running exact Perl recognition transaction admission consumer",
    "invocation": f"PERL5LIB= prove -Iperl {PERL_CONSUMER_PATH}",
}
EXPECTED_RUST_ADMISSION = {
    "consumer_path": RUST_CONSUMER_PATH,
    "registration_marker": "running exact Rust recognition transaction admission consumer",
    "invocation": (
        "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime "
        "--test recognition_transaction_contract"
    ),
}
EXPECTED_DART_ADMISSION = {
    "consumer_path": DART_CONSUMER_PATH,
    "registration_marker": "running exact Dart recognition transaction admission consumer",
    "invocation": (
        "(cd dart && bash ../tools/run_dart_project_data.sh test --reporter "
        "failures-only test/recognition_transaction_contract_test.dart)"
    ),
}
EXPECTED_JULIA_ADMISSION = {
    "consumer_path": JULIA_CONSUMER_PATH,
    "registration_marker": "running exact Julia recognition transaction admission consumer",
    "invocation": (
        "bash tools/run_julia_project_data.sh --project=julia --startup-file=no "
        "--history-file=no -e 'using LinkedSpecJulia, JSON3, Test; "
        "include(\"julia/test/recognition_transaction_contract_test.jl\")'"
    ),
}
PUBLIC_SEQUENCE_CONTRACT = {
    "documents": [
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "required_markers": [
                "The shared contract now has an executable backend-neutral authority",
                "The Perl, Rust, Dart, and Julia lanes now recognize and admit the four forms as a current capability",
                "This section describes current Perl, Rust, Dart, and Julia features and an accepted future portable contract",
                "fails closed over three public transaction pages, seventeen forbidden claims, and thirty-three sequence mutations",
                (
                    "executable, and Perl, Rust, Dart, and Julia are admitted; PUC Lua "
                    "and LuaJIT must each be admitted independently"
                ),
            ],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "required_markers": [
                "The neutral authority is now executable",
                "Perl, Rust, Dart, and Julia transaction support is current and canonically admitted",
                "Neutral proof alone is not backend support",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "required_markers": [
                (
                    "Their neutral artifact/checker is executable at 128 current + 4 "
                    "dedicated ActionIR rows"
                ),
                "recognition rollout 5/9 complete",
                "PUC Lua, LuaJIT, recurring, and public-no-drift legs remain RED",
            ],
        },
    ],
    "forbidden_claims": [
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "The neutral artifact/checker is next",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "neutral artifact/checker is next",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "This section describes a current feature",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "all six runtimes are admitted",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "text": "neutral proof is backend support",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "text": "all-backend transaction support is current",
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "text": "all six runtime, recurring, and public legs are complete",
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "text": "neutral rollout 9/9 complete",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "current on Perl and future on the other runtimes",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "Rust, Dart, Julia, PUC Lua, and LuaJIT do not yet admit the forms",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "the other runtimes do not yet implement that route",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "current on Perl and Rust, future on later runtimes",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "Dart, Julia, PUC Lua, and LuaJIT do not yet admit the forms",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "later runtimes do not yet implement that route",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "current on Perl, Rust, and Dart, future on later runtimes",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "Julia, PUC Lua, and LuaJIT do not yet admit the forms",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "Julia and Lua do not yet implement it",
        },
    ],
}
PUBLIC_SEQUENCE_MUTATION_COUNT = 33
CAPABILITY_GUIDE_CONTRACT = {
    "path": "capability_conformance/README.md",
    "required_markers": [
        "neutral + Perl + Rust + Dart + Julia 5/9 complete",
        (
            "current on Perl, Rust, Dart, and Julia and remain future on PUC Lua and LuaJIT"
        ),
    ],
    "forbidden_claims": [
        "Rollout is neutral 1/9 complete",
        "forms remain future and unavailable in every backend",
        "neutral + Perl 2/9 complete",
        "current on Perl and remain future on every other runtime",
        "neutral + Perl + Rust 3/9 complete",
        "current on Perl and Rust and remain future on Dart, Julia, PUC Lua, and LuaJIT",
        "neutral + Perl + Rust + Dart 4/9 complete",
        "current on Perl, Rust, and Dart and remain future on Julia, PUC Lua, and LuaJIT",
    ],
}
CAPABILITY_GUIDE_MUTATION_COUNT = 12
RUST_ADMISSION_MUTATION_COUNT = 8
DART_ADMISSION_MUTATION_COUNT = 13
JULIA_ADMISSION_MUTATION_COUNT = 14
LUA_DORMANT_RED_MUTATION_COUNT = 12
LUA_AUTHORITY_MUTATION_COUNT = 22
EXPECTED_TOP_LEVEL = {
    "format",
    "contract_id",
    "task_owner",
    "status",
    "expected_counts",
    "authored_surface",
    "policy",
    "effect_model",
    "action_ir_effect_rows",
    "canonical_call_effect_rows",
    "token_model",
    "fixtures",
    "diagnostics",
    "rollout",
    "canonical_execution",
    "mutation_ids",
}


class ContractError(RuntimeError):
    """One neutral contract invariant failed."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def _english_join(values: list[str]) -> str:
    require(values, "current-boundary rollout group must not be empty")
    if len(values) == 1:
        return values[0]
    if len(values) == 2:
        return f"{values[0]} and {values[1]}"
    return f"{', '.join(values[:-1])}, and {values[-1]}"


def expected_current_boundary() -> str:
    labels = {
        "perl": "Perl",
        "rust": "Rust",
        "dart": "Dart",
        "julia": "Julia",
        "puc_lua": "PUC Lua",
        "luajit": "LuaJIT",
        "recurring": "recurring",
        "public_no_drift": "public-no-drift",
    }
    runtime_rows = [row for row in EXPECTED_ROLLOUT if row[2] != "neutral"]
    admitted = [labels[leg] for _, _, leg, status in runtime_rows if status == "complete"]
    unavailable = [labels[leg] for _, _, leg, status in runtime_rows if status == "red"]
    return (
        "this artifact admits the neutral contract and current "
        f"{_english_join(admitted)} runtime behavior; "
        f"{_english_join(unavailable)} legs remain unavailable, and no schema, "
        "semantic, MCP, capability, CLI, or unrelated helper behavior changes"
    )


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as exc:
        raise ContractError(f"cannot read {path.relative_to(ROOT)}: {exc}") from exc


def rust_admission_sources() -> dict[str, str]:
    return {path: read_text(ROOT / path) for path in RUST_ADMISSION_SOURCE_PATHS}


def validate_rust_admission(ci: str, sources: dict[str, str]) -> None:
    require(
        set(sources) == set(RUST_ADMISSION_SOURCE_PATHS),
        "Rust admission source inventory drifted",
    )
    markers = [
        f"require_tracked_file {EXPECTED_RUST_ADMISSION['consumer_path']}",
        f"log \"{EXPECTED_RUST_ADMISSION['registration_marker']}\"",
        EXPECTED_RUST_ADMISSION["invocation"],
    ]
    for marker in markers:
        require(
            ci.count(marker) == 1,
            f"canonical Rust admission marker missing or duplicated: {marker}",
        )
    for relative_path, source in sources.items():
        require(
            "linkedspec_recognition_transaction" not in source,
            f"Rust recognition transaction source remains dormant: {relative_path}",
        )


def dart_admission_sources() -> dict[str, str]:
    return {
        DART_CONSUMER_PATH: read_text(ROOT / DART_CONSUMER_PATH),
        DART_FACADE_PATH: read_text(ROOT / DART_FACADE_PATH),
    }


def validate_dart_admission(ci: str, sources: dict[str, str]) -> None:
    require(
        set(sources) == {DART_CONSUMER_PATH, DART_FACADE_PATH},
        "Dart admission source inventory drifted",
    )
    markers = [
        f"require_tracked_file {EXPECTED_DART_ADMISSION['consumer_path']}",
        f"log \"{EXPECTED_DART_ADMISSION['registration_marker']}\"",
        EXPECTED_DART_ADMISSION["invocation"],
    ]
    for marker in markers:
        require(
            ci.count(marker) == 1,
            f"canonical Dart admission marker missing or duplicated: {marker}",
        )
    require(
        DART_DORMANT_CONSUMER_PATH not in ci,
        "canonical CI retains the dormant Dart consumer path",
    )

    consumer = sources[DART_CONSUMER_PATH]
    require(
        consumer.count(DART_PRIVATE_IMPORT) == 1,
        "Dart admission consumer must import the private authority exactly once",
    )
    for stale in (
        "LINKEDSPEC_DART_RECOGNITION_TRANSACTION_INTEGRATION_RED",
        "_integrationRedSkip",
        DART_DORMANT_CONSUMER_PATH,
        "skip:",
    ):
        require(stale not in consumer, f"Dart admission consumer remains dormant: {stale}")
    require(
        "src/runtime/recognition_transaction.dart" not in sources[DART_FACADE_PATH],
        "Dart recognition transaction authority became publicly exported",
    )


def julia_admission_sources() -> dict[str, str]:
    return {
        JULIA_CONSUMER_PATH: read_text(ROOT / JULIA_CONSUMER_PATH),
        JULIA_RUNTESTS_PATH: read_text(ROOT / JULIA_RUNTESTS_PATH),
        JULIA_FACADE_PATH: read_text(ROOT / JULIA_FACADE_PATH),
    }


def validate_julia_admission(ci: str, sources: dict[str, str]) -> None:
    require(
        set(sources) == {JULIA_CONSUMER_PATH, JULIA_RUNTESTS_PATH, JULIA_FACADE_PATH},
        "Julia admission source inventory drifted",
    )
    markers = [
        f"require_tracked_file {EXPECTED_JULIA_ADMISSION['consumer_path']}",
        f"log \"{EXPECTED_JULIA_ADMISSION['registration_marker']}\"",
        EXPECTED_JULIA_ADMISSION["invocation"],
    ]
    for marker in markers:
        require(
            ci.count(marker) == 1,
            f"canonical Julia admission marker missing or duplicated: {marker}",
        )

    runtests = sources[JULIA_RUNTESTS_PATH]
    require(
        runtests.count(JULIA_ORDINARY_INCLUDE) == 1,
        "ordinary Julia admission include is missing or duplicated",
    )
    consumer = sources[JULIA_CONSUMER_PATH]
    require(
        consumer.count(JULIA_PRIVATE_AUTHORITY_ACCESS) == 1,
        "Julia admission consumer must access the private authority exactly once",
    )
    for stale in (
        "LINKEDSPEC_JULIA_RECOGNITION_TRANSACTION_RED_MODE",
        "JULIA_RECOGNITION_TRANSACTION_RED_MODE",
        'if JULIA_RECOGNITION_TRANSACTION_RED_MODE == "integration"',
        "Julia dormant recognition-transaction contract",
    ):
        require(stale not in consumer, f"Julia admission consumer remains dormant: {stale}")
    require(
        "\n    RecognitionTransaction," not in sources[JULIA_FACADE_PATH],
        "Julia recognition transaction authority became publicly exported",
    )


def lua_dormant_red_sources() -> dict[str, str]:
    return {
        LUA_CONSUMER_PATH: read_text(ROOT / LUA_CONSUMER_PATH),
        LUA_FACADE_PATH: read_text(ROOT / LUA_FACADE_PATH),
        LUA_AUTHORITY_PATH: read_text(ROOT / LUA_AUTHORITY_PATH),
    }


def validate_lua_dormant_red(
    ci: str,
    ordinary: str,
    sources: dict[str, str],
) -> None:
    require(
        set(sources) == {LUA_CONSUMER_PATH, LUA_FACADE_PATH, LUA_AUTHORITY_PATH},
        "Lua dormant RED source inventory drifted",
    )
    consumer = sources[LUA_CONSUMER_PATH]
    for marker, label in (
        (LUA_RED_SELECTOR, "selector"),
        (LUA_PRIVATE_REQUIRE, "private authority lookup"),
        (LUA_RED_DIAGNOSTIC, "stable missing-authority diagnostic"),
        ('if mode == "integration" then', "integration boundary"),
        (
            "neutral_perl_rust_dart_and_julia_complete_other_legs_red",
            "current neutral status",
        ),
    ):
        require(
            consumer.count(marker) == 1,
            f"Lua dormant RED {label} missing or duplicated",
        )
    require(
        consumer.count("bash tools/run_lua_project_data.sh puc " + LUA_CONSUMER_PATH)
        == 2,
        "Lua dormant RED must document authority/integration PUC Lua commands",
    )
    require(
        consumer.count("bash tools/run_lua_project_data.sh luajit " + LUA_CONSUMER_PATH)
        == 2,
        "Lua dormant RED must document authority/integration LuaJIT commands",
    )
    require(
        LUA_CONSUMER_PATH not in ordinary,
        "ordinary Lua discovery prematurely registers recognition transactions",
    )
    require(
        LUA_CONSUMER_PATH not in ci,
        "canonical CI prematurely registers Lua recognition transactions",
    )
    require(
        "recognition_transaction =" not in sources[LUA_FACADE_PATH]
        and "M.recognition_transaction" not in sources[LUA_FACADE_PATH],
        "Lua recognition transaction authority became publicly exported",
    )
    authority = sources[LUA_AUTHORITY_PATH]
    for marker, label in LUA_AUTHORITY_MARKERS:
        require(
            authority.count(marker) == 1,
            f"Lua private transaction authority {label} missing or duplicated",
        )
    require(
        consumer.count(LUA_INTEGRATION_RED_DIAGNOSTIC) == 1,
        "Lua private authority must stop integration at dedicated ActionIR nodes",
    )


def public_sequence_texts() -> dict[str, str]:
    paths = [row["path"] for row in PUBLIC_SEQUENCE_CONTRACT["documents"]]
    return {path: read_text(ROOT / path) for path in paths}


def validate_capability_guide(
    guide_contract: dict[str, Any],
    text: str,
    *,
    check_tracked: bool,
) -> None:
    require(
        guide_contract == CAPABILITY_GUIDE_CONTRACT,
        "recognition capability-guide contract drifted",
    )
    path = guide_contract.get("path")
    markers = guide_contract.get("required_markers")
    forbidden = guide_contract.get("forbidden_claims")
    require(isinstance(path, str) and path, "capability-guide path drifted")
    require(
        isinstance(markers, list) and len(markers) == 2 == len(set(markers)),
        "capability-guide marker inventory drifted",
    )
    require(
        isinstance(forbidden, list)
        and len(forbidden) == 8 == len(set(forbidden)),
        "capability-guide forbidden-claim inventory drifted",
    )
    for marker in markers:
        require(
            isinstance(marker, str) and text.count(marker) == 1,
            f"capability-guide marker missing or duplicated: {marker}",
        )
    for claim in forbidden:
        require(
            isinstance(claim, str) and claim not in text,
            f"stale capability-guide claim remains: {claim}",
        )
    if check_tracked:
        tracked = subprocess.run(
            ["git", "ls-files", "--error-unmatch", "--", path],
            cwd=ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        require(tracked.returncode == 0, f"capability guide is not tracked: {path}")


def validate_public_sequence(
    document: dict[str, Any],
    public_contract: dict[str, Any],
    texts: dict[str, str],
    *,
    check_tracked: bool,
) -> None:
    require(
        public_contract == PUBLIC_SEQUENCE_CONTRACT,
        "public milestone-sequence contract drifted",
    )
    documents = public_contract.get("documents")
    forbidden = public_contract.get("forbidden_claims")
    require(isinstance(documents, list), "public documents must be an array")
    require(isinstance(forbidden, list), "public forbidden claims must be an array")
    paths = [row.get("path") for row in documents]
    require(len(paths) == len(set(paths)) == 3, "public document inventory drifted")
    require(set(texts) == set(paths), "public text inventory drifted")

    rollout = document.get("rollout")
    require(isinstance(rollout, list), "public sequence needs rollout rows")
    rollout_status = {row.get("leg"): row.get("status") for row in rollout}
    require(rollout_status.get("neutral") == "complete", "public sequence requires neutral complete")
    require(
        rollout_status.get("perl") == "complete"
        and rollout_status.get("rust") == "complete"
        and rollout_status.get("dart") == "complete"
        and rollout_status.get("julia") == "complete"
        and set(rollout_status.values()) == {"complete", "red"}
        and all(
            status == "red"
            for leg, status in rollout_status.items()
            if leg not in {"neutral", "perl", "rust", "dart", "julia"}
        ),
        "public sequence requires neutral, Perl, Rust, Dart, and Julia complete with every later leg RED",
    )

    for row in documents:
        path = row.get("path")
        markers = row.get("required_markers")
        require(isinstance(path, str) and path in texts, "public document path drifted")
        require(isinstance(markers, list) and markers, f"public markers missing for {path}")
        require(len(markers) == len(set(markers)), f"public markers duplicate in {path}")
        for marker in markers:
            require(isinstance(marker, str) and marker, f"public marker invalid in {path}")
            require(
                texts[path].count(marker) == 1,
                f"public marker missing or duplicated in {path}: {marker}",
            )
        if check_tracked:
            tracked = subprocess.run(
                ["git", "ls-files", "--error-unmatch", "--", path],
                cwd=ROOT,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
            require(tracked.returncode == 0, f"public document is not tracked: {path}")

    require(len(forbidden) == 17, "public forbidden-claim inventory drifted")
    for row in forbidden:
        path = row.get("path")
        claim = row.get("text")
        require(isinstance(path, str) and path in texts, "forbidden public path drifted")
        require(isinstance(claim, str) and claim, f"forbidden public claim invalid in {path}")
        require(claim not in texts[path], f"forbidden public claim remains in {path}: {claim}")


def load_contract() -> dict[str, Any]:
    try:
        value = json.loads(read_text(CONTRACT_PATH))
    except json.JSONDecodeError as exc:
        raise ContractError(f"invalid JSON: {exc}") from exc
    require(isinstance(value, dict), "contract root must be an object")
    return value


def current_action_ir_nodes() -> list[str]:
    discovered = set(
        re.findall(r"ir_node\s*=>\s*'([^']+)'", read_text(PERL_CONTRACTS_PATH))
    )
    require(
        set(DEDICATED_NODES).issubset(discovered),
        "Perl dedicated recognition-transaction ActionIR inventory is incomplete",
    )
    nodes = sorted(discovered - set(DEDICATED_NODES))
    require(nodes, "cannot derive current Perl ActionIR node inventory")
    return nodes


def _extract_named_set(text: str, pattern: str, label: str, item_pattern: str) -> list[str]:
    match = re.search(pattern, text, re.DOTALL)
    require(match is not None, f"cannot derive {label}")
    return re.findall(item_pattern, match.group(1))


def current_call_names() -> list[str]:
    dart_text = read_text(DART_CONTRACTS_PATH)
    dart: list[str] = []
    for constant in (
        "supportedActionIrCallNames",
        "numericAliasActionIrCallNames",
        "currentAliasActionIrCallNames",
    ):
        dart.extend(
            _extract_named_set(
                dart_text,
                rf"const {constant} = <String>\{{(.*?)\n\}};",
                f"Dart {constant}",
                r"'([^']+)'",
            )
        )

    julia_text = read_text(JULIA_CONTRACTS_PATH)
    julia: list[str] = []
    for constant in (
        "_SUPPORTED_ACTION_IR_CALL_NAMES",
        "_NUMERIC_ALIAS_ACTION_IR_CALL_NAMES",
        "_CURRENT_ALIAS_ACTION_IR_CALL_NAMES",
    ):
        julia.extend(
            _extract_named_set(
                julia_text,
                rf"const {constant} = Set\{{String\}}\(\[(.*?)\n\]\)",
                f"Julia {constant}",
                r'"([^"]+)"',
            )
        )

    lua = _extract_named_set(
        read_text(LUA_CALL_NAMES_PATH),
        r"local CURRENT_CALL_NAMES = \{(.*?)\n\}",
        "Lua current call names",
        r'\["([^"]+)"\]\s*=\s*true',
    )
    inventories = {"Dart": sorted(dart), "Julia": sorted(julia), "Lua": sorted(lua)}
    for language, names in inventories.items():
        require(len(names) == len(set(names)), f"{language} current call inventory contains a duplicate")
    require(inventories["Dart"] == inventories["Julia"], "Dart and Julia current call inventories differ")
    require(inventories["Dart"] == inventories["Lua"], "Dart and Lua current call inventories differ")
    return inventories["Dart"]


def flatten_effect_rows(rows: Any, label: str) -> tuple[list[str], dict[str, str]]:
    effects = ALLOWED_EFFECTS + REJECTED_EFFECTS
    require(isinstance(rows, dict), f"{label} must be an object")
    require(list(rows) == effects, f"{label} effect keys/order drifted")
    flattened: list[str] = []
    assignments: dict[str, str] = {}
    for effect in effects:
        names = rows[effect]
        require(isinstance(names, list), f"{label}.{effect} must be an array")
        require(all(isinstance(name, str) and name for name in names), f"{label}.{effect} contains an invalid name")
        for name in names:
            require(name not in assignments, f"{label} assigns {name!r} more than once")
            assignments[name] = effect
            flattened.append(name)
    return flattened, assignments


def effect_row_hash(assignments: dict[str, str]) -> str:
    pairs = sorted(assignments.items())
    encoded = json.dumps(pairs, separators=(",", ":"), ensure_ascii=True).encode("ascii")
    return hashlib.sha256(encoded).hexdigest()


def json_equal(left: Any, right: Any) -> bool:
    return type(left) is type(right) and left == right


def decode_payload(text: str) -> Any:
    if text == "false":
        return False
    if text == "0":
        return 0
    if text == "null":
        return None
    return text


def simulate_token(ops: Any) -> tuple[bool, Any]:
    require(isinstance(ops, list) and ops, "token ops must be a non-empty array")
    state = "uninitialized"
    attempts = 0
    matched = False
    payload: Any = None
    result: Any = None
    for raw in ops:
        require(isinstance(raw, str), "token operation must be a string")
        operation, separator, argument = raw.partition(":")
        if operation == "checkpoint":
            if state != "uninitialized":
                raise ContractError("recognition_nesting_forbidden")
            state = "active_unattempted"
        elif operation in {"attempt_match", "attempt_miss"}:
            if state != "active_unattempted":
                raise ContractError("recognition_attempt_count")
            attempts += 1
            matched = operation == "attempt_match"
            payload = decode_payload(argument) if matched and separator else None
            state = "active_staged_match" if matched else "active_staged_miss"
        elif operation in {"commit", "rollback"}:
            if state == "invalidated":
                raise ContractError("recognition_token_reused")
            if state != "active_staged_match" and state != "active_staged_miss":
                raise ContractError("recognition_attempt_count")
            result = payload if operation == "commit" and matched else None
            if operation == "rollback":
                result = "no_authored_value"
            state = "invalidated"
        else:
            raise ContractError("recognition_token_expected")
    if attempts != 1:
        raise ContractError("recognition_attempt_count")
    if state != "invalidated":
        raise ContractError("recognition_terminal_required")
    return matched, result


def validate_token_fixtures(fixtures: dict[str, Any]) -> None:
    positives = fixtures.get("token_positive")
    negatives = fixtures.get("token_negative")
    require(isinstance(positives, list), "token_positive fixtures must be an array")
    require(isinstance(negatives, list), "token_negative fixtures must be an array")
    require(len(positives) == EXPECTED_COUNTS["token_positive_cases"], "token positive count drifted")
    require(len(negatives) == EXPECTED_COUNTS["token_negative_cases"], "token negative count drifted")
    require(len({case.get("id") for case in positives}) == len(positives), "token positive ids must be unique")
    require(len({case.get("id") for case in negatives}) == len(negatives), "token negative ids must be unique")
    for case in positives:
        matched, result = simulate_token(case.get("ops"))
        require(type(case.get("matched")) is bool, f"{case.get('id')} expected match must be strict boolean")
        require(matched is case["matched"], f"{case.get('id')} match result drifted")
        require(json_equal(result, case.get("result")), f"{case.get('id')} staged result drifted")

    violation_diagnostics = {
        "copy": "recognition_token_escape",
        "comparison": "recognition_token_escape",
        "aggregate_storage": "recognition_token_escape",
        "function_storage": "recognition_token_escape",
        "codeblock_storage": "recognition_token_escape",
        "return": "recognition_token_escape",
        "capture": "recognition_token_escape",
        "serialization": "recognition_token_escape",
        "cross_invocation": "recognition_cross_invocation",
        "cross_source": "recognition_cross_source",
        "dynamic_rule_operand": "recognition_static_rule_required",
        "payload_as_match_boolean": "recognition_match_boolean_required",
    }
    for case in negatives:
        expected = case.get("diagnostic")
        require(isinstance(expected, str), f"{case.get('id')} lacks a diagnostic")
        if "violation" in case:
            actual = violation_diagnostics.get(case["violation"], "recognition_token_expected")
        else:
            try:
                simulate_token(case.get("ops"))
            except ContractError as exc:
                actual = str(exc)
            else:
                raise ContractError(f"{case.get('id')} token negative was accepted")
        require(actual == expected, f"{case.get('id')} diagnostic drifted: {actual} != {expected}")


def rule_effects(graph: dict[str, Any], allowed: set[str], rejected: set[str]) -> tuple[bool, str | None]:
    rules = graph.get("rules")
    entry = graph.get("entry")
    require(isinstance(rules, dict) and rules, f"{graph.get('id')} rules must be a non-empty object")
    require(entry in rules, f"{graph.get('id')} entry is not declared")
    computed: dict[str, set[str]] = {}
    for name, rule in rules.items():
        require(isinstance(rule, dict), f"{graph.get('id')}.{name} must be an object")
        base = rule.get("base")
        calls = rule.get("calls")
        require(isinstance(base, list) and isinstance(calls, list), f"{graph.get('id')}.{name} shape drifted")
        require(all(isinstance(effect, str) for effect in base), f"{graph.get('id')}.{name} effect is invalid")
        if any(effect not in allowed | rejected for effect in base):
            return False, "recognition_unknown_effect"
        require(all(call in rules for call in calls), f"{graph.get('id')}.{name} references an unknown rule")
        computed[name] = set(base)
    changed = True
    while changed:
        changed = False
        for name, rule in rules.items():
            union = set(computed[name])
            for callee in rule["calls"]:
                union.update(computed[callee])
            if union != computed[name]:
                computed[name] = union
                changed = True
    if computed[entry] & rejected:
        return False, "recognition_effect_forbidden"
    return True, None


def validate_effect_graphs(fixtures: dict[str, Any], allowed: set[str], rejected: set[str]) -> None:
    graphs = fixtures.get("effect_graphs")
    require(isinstance(graphs, list), "effect_graphs must be an array")
    require(len(graphs) == EXPECTED_COUNTS["effect_graph_cases"], "effect graph count drifted")
    require(len({case.get("id") for case in graphs}) == len(graphs), "effect graph ids must be unique")
    for case in graphs:
        accepted, diagnostic = rule_effects(case, allowed, rejected)
        require(type(case.get("accepted")) is bool, f"{case.get('id')} accepted must be boolean")
        require(accepted is case["accepted"], f"{case.get('id')} effect acceptance drifted")
        require(diagnostic == case.get("diagnostic"), f"{case.get('id')} effect diagnostic drifted")


def validate_mark_fixtures(fixtures: dict[str, Any]) -> None:
    cases = fixtures.get("marks")
    require(isinstance(cases, list), "mark fixtures must be an array")
    require(len(cases) == EXPECTED_COUNTS["mark_cases"], "mark fixture count drifted")
    require(
        len({case.get("id") for case in cases}) == len(cases),
        "mark fixture ids must be unique",
    )
    for case in cases:
        case_id = case.get("id")
        if case_id in {"rollback_restores", "commit_retains"}:
            actual = case["before"] if case["terminal"] == "rollback" else case["staged"]
            require(actual == case.get("expected"), f"{case_id} snapshot behavior drifted")
        elif case_id == "recursive_same_label_isolated":
            parent, child = case["parent"], case["child"]
            actual = (
                parent["invocation"] != child["invocation"]
                and parent["generation"] != child["generation"]
                and child["marks"] == {}
            )
            require(actual is case.get("accepted"), "recursive mark isolation drifted")
        elif case_id == "stale_generation":
            actual = case["parent"]["generation"] == case["token"]["generation"]
            require(
                actual is case.get("accepted")
                and case.get("diagnostic") == "recognition_mark_generation_invalid",
                "stale generation fixture drifted",
            )
        elif case_id == "mark_cross_invocation":
            actual = case["parent"]["invocation"] == case["token"]["invocation"]
            require(
                actual is case.get("accepted")
                and case.get("diagnostic") == "recognition_cross_invocation",
                "cross-invocation mark fixture drifted",
            )
        elif case_id == "mark_cross_source":
            actual = case["parent"]["source"] == case["token"]["source"]
            require(
                actual is case.get("accepted")
                and case.get("diagnostic") == "recognition_cross_source",
                "cross-source mark fixture drifted",
            )
        else:
            raise ContractError(f"unknown mark fixture {case_id!r}")


def validate_progress_fixtures(fixtures: dict[str, Any]) -> None:
    cases = fixtures.get("progress")
    require(isinstance(cases, list), "progress fixtures must be an array")
    require(len(cases) == EXPECTED_COUNTS["progress_cases"], "progress fixture count drifted")
    require(
        len({case.get("id") for case in cases}) == len(cases),
        "progress fixture ids must be unique",
    )
    recursive = {"accepted_direct_recursive_cycle_edge", "accepted_mutual_recursive_cycle_edge"}
    for case in cases:
        context = case.get("context")
        require(
            context in recursive | {"accepted_repetition_iteration", "one_shot"},
            f"{case.get('id')} context is unknown",
        )
        actual = True if context == "one_shot" else case.get("end") > case.get("start")
        require(actual is case.get("accepted"), f"{case.get('id')} progress acceptance drifted")
        expected_diagnostic = None
        if not actual:
            expected_diagnostic = (
                "recognition_zero_progress_recursive_cycle"
                if context in recursive
                else "recognition_zero_progress_repetition"
            )
        require(
            expected_diagnostic == case.get("diagnostic"),
            f"{case.get('id')} progress diagnostic drifted",
        )


def validate_contract(document: dict[str, Any], *, check_environment: bool) -> None:
    require(set(document) == EXPECTED_TOP_LEVEL, "top-level schema drifted")
    require(document.get("format") == 1, "format must remain 1")
    require(
        document.get("contract_id") == "linkedspec-recognition-transaction-v1",
        "contract_id drifted",
    )
    require(
        document.get("task_owner") == "FUTURE-PARITY-BACKLOG.14.3.1.1",
        "task_owner drifted",
    )
    require(
        document.get("status")
        == "neutral_perl_rust_dart_and_julia_complete_other_legs_red",
        "neutral/backend status drifted",
    )
    require(document.get("expected_counts") == EXPECTED_COUNTS, "expected_counts drifted")
    require(document.get("authored_surface") == EXPECTED_SURFACE, "authored surface drifted")

    policy = document.get("policy")
    require(isinstance(policy, dict), "policy must be an object")
    require(len(policy) == 13, "policy field count drifted")
    require(
        policy.get("fail_closed")
        == (
            "unknown nodes, calls, effects, graph references, token states, or "
            "fixture operations reject before recognition"
        ),
        "fail-closed policy drifted",
    )
    require(
        policy.get("current_boundary") == expected_current_boundary(),
        "current behavior boundary drifted",
    )

    effect_model = document.get("effect_model")
    require(
        effect_model == {"allowed": ALLOWED_EFFECTS, "rejected": REJECTED_EFFECTS},
        "effect vocabulary/order drifted",
    )
    allowed, rejected = set(ALLOWED_EFFECTS), set(REJECTED_EFFECTS)

    current_nodes = current_action_ir_nodes()
    action_names, action_assignments = flatten_effect_rows(
        document.get("action_ir_effect_rows"), "action_ir_effect_rows"
    )
    require(
        len(current_nodes) == EXPECTED_COUNTS["current_action_ir_nodes"],
        "current ActionIR node census drifted",
    )
    require(
        set(action_names) == set(current_nodes) | set(DEDICATED_NODES),
        "ActionIR effect rows are not fresh and complete",
    )
    require(
        len(action_names) == EXPECTED_COUNTS["all_action_ir_nodes"],
        "ActionIR effect row count drifted",
    )
    require(
        effect_row_hash(action_assignments)
        == EXPECTED_EFFECT_ROW_HASHES["action_ir_effect_rows"],
        "ActionIR base-effect classification drifted",
    )
    require(
        [name for name in action_names if name in DEDICATED_NODES]
        == DEDICATED_NODES,
        "dedicated transaction node order drifted",
    )
    require(
        all(
            action_assignments[name] == "transaction_state"
            for name in DEDICATED_NODES
        ),
        "dedicated nodes must have transaction_state effect",
    )

    calls = current_call_names()
    call_names, call_assignments = flatten_effect_rows(
        document.get("canonical_call_effect_rows"), "canonical_call_effect_rows"
    )
    require(
        len(calls) == EXPECTED_COUNTS["canonical_call_contracts"],
        "canonical call census drifted",
    )
    require(
        set(call_names) == set(calls),
        "canonical call effect rows are not fresh and complete",
    )
    require(
        len(call_names) == EXPECTED_COUNTS["canonical_call_contracts"],
        "canonical call effect row count drifted",
    )
    require(
        effect_row_hash(call_assignments)
        == EXPECTED_EFFECT_ROW_HASHES["canonical_call_effect_rows"],
        "canonical call base-effect classification drifted",
    )

    token = document.get("token_model")
    require(
        isinstance(token, dict)
        and set(token)
        == {"states", "operations", "transitions", "matched_payloads", "terminal_results"},
        "token model schema drifted",
    )
    require(token["states"] == EXPECTED_TOKEN_STATES, "token states drifted")
    require(token["operations"] == EXPECTED_TOKEN_OPERATIONS, "token operations drifted")
    require(token["transitions"] == EXPECTED_TRANSITIONS, "token transitions drifted")
    require(
        len(token["matched_payloads"]) == 5
        and all(
            json_equal(actual, expected)
            for actual, expected in zip(
                token["matched_payloads"], [False, 0, "", None, "value"]
            )
        ),
        "falsey staged-payload authority drifted",
    )
    require(
        token["terminal_results"]
        == {
            "commit_match": "staged_payload",
            "commit_miss": None,
            "rollback": "no_authored_value",
        },
        "terminal result contract drifted",
    )

    fixtures = document.get("fixtures")
    require(
        isinstance(fixtures, dict)
        and set(fixtures)
        == {"token_positive", "token_negative", "effect_graphs", "marks", "progress"},
        "fixture topology drifted",
    )
    validate_token_fixtures(fixtures)
    validate_effect_graphs(fixtures, allowed, rejected)
    validate_mark_fixtures(fixtures)
    validate_progress_fixtures(fixtures)

    diagnostics = document.get("diagnostics")
    require(isinstance(diagnostics, list), "diagnostics must be an array")
    require(
        [(row.get("code"), row.get("fields")) for row in diagnostics]
        == EXPECTED_DIAGNOSTICS,
        "diagnostic codes/fields/order drifted",
    )

    rollout = document.get("rollout")
    require(isinstance(rollout, list), "rollout must be an array")
    require(
        [
            (row.get("order"), row.get("owner"), row.get("leg"), row.get("status"))
            for row in rollout
        ]
        == EXPECTED_ROLLOUT,
        "rollout order/owner/status drifted",
    )
    require(
        rollout[0].get("paths")
        == [EXPECTED_EXECUTION["contract_path"], EXPECTED_EXECUTION["checker_path"]],
        "neutral rollout paths drifted",
    )
    require(
        rollout[1].get("paths") == [EXPECTED_PERL_ADMISSION["consumer_path"]],
        "Perl rollout consumer path drifted",
    )
    require(
        rollout[2].get("paths") == [EXPECTED_RUST_ADMISSION["consumer_path"]],
        "Rust rollout consumer path drifted",
    )
    require(
        rollout[3].get("paths") == [EXPECTED_DART_ADMISSION["consumer_path"]],
        "Dart rollout consumer path drifted",
    )
    require(
        rollout[4].get("paths") == [EXPECTED_JULIA_ADMISSION["consumer_path"]],
        "Julia rollout consumer path drifted",
    )
    require(
        all(row.get("paths") == [] for row in rollout[5:]),
        "RED rollout legs must not claim implementation paths",
    )

    execution = document.get("canonical_execution")
    require(execution == EXPECTED_EXECUTION, "canonical execution/freshness topology drifted")

    mutations = document.get("mutation_ids")
    require(
        isinstance(mutations, list)
        and len(mutations) == EXPECTED_COUNTS["mutations"],
        "mutation count drifted",
    )
    require(len(mutations) == len(set(mutations)), "mutation ids must be unique")
    require(mutations == list(MUTATIONS), "mutation identity/order drifted")

    if check_environment:
        ci = read_text(CI_PATH)
        require(
            ci.count(
                f"require_tracked_file {EXPECTED_EXECUTION['contract_path']}"
            )
            == 1,
            "canonical CI must require the neutral artifact exactly once",
        )
        require(
            ci.count(f"require_tracked_file {EXPECTED_EXECUTION['checker_path']}")
            == 1,
            "canonical CI must require the neutral checker exactly once",
        )
        require(
            ci.count(f"log \"{EXPECTED_EXECUTION['registration_marker']}\"") == 1,
            "canonical CI registration marker missing or duplicated",
        )
        require(
            ci.count(EXPECTED_EXECUTION["invocation"]) == 1,
            "canonical CI invocation missing or duplicated",
        )
        require(
            ci.count(
                f"require_tracked_file {EXPECTED_PERL_ADMISSION['consumer_path']}"
            )
            == 1,
            "canonical CI must require the Perl consumer exactly once",
        )
        require(
            ci.count(EXPECTED_PERL_ADMISSION["syntax_invocation"]) == 1,
            "canonical CI must syntax-check the Perl consumer exactly once",
        )
        require(
            ci.count(f"log \"{EXPECTED_PERL_ADMISSION['registration_marker']}\"")
            == 1,
            "canonical Perl admission marker missing or duplicated",
        )
        require(
            ci.count(EXPECTED_PERL_ADMISSION["invocation"]) == 1,
            "canonical Perl admission invocation missing or duplicated",
        )
        validate_rust_admission(ci, rust_admission_sources())
        validate_dart_admission(ci, dart_admission_sources())
        validate_julia_admission(ci, julia_admission_sources())
        validate_lua_dormant_red(
            ci,
            read_text(ROOT / LUA_ORDINARY_PATH),
            lua_dormant_red_sources(),
        )
        validate_public_sequence(
            document,
            PUBLIC_SEQUENCE_CONTRACT,
            public_sequence_texts(),
            check_tracked=True,
        )
        validate_capability_guide(
            CAPABILITY_GUIDE_CONTRACT,
            read_text(ROOT / CAPABILITY_GUIDE_CONTRACT["path"]),
            check_tracked=True,
        )


def _set(path: list[Any], value: Any) -> Callable[[dict[str, Any]], None]:
    def mutate(document: dict[str, Any]) -> None:
        target: Any = document
        for key in path[:-1]:
            target = target[key]
        target[path[-1]] = value
    return mutate


def _delete_effect_row(surface: str, effect: str) -> Callable[[dict[str, Any]], None]:
    def mutate(document: dict[str, Any]) -> None:
        document[surface][effect].pop()
    return mutate


def _duplicate_effect_row(surface: str, source_effect: str, target_effect: str) -> Callable[[dict[str, Any]], None]:
    def mutate(document: dict[str, Any]) -> None:
        document[surface][target_effect].append(document[surface][source_effect][0])
        document[surface][target_effect].sort()
    return mutate


def _unknown_effect_row(surface: str, effect: str) -> Callable[[dict[str, Any]], None]:
    def mutate(document: dict[str, Any]) -> None:
        document[surface][effect][0] += "_UNKNOWN"
        document[surface][effect].sort()
    return mutate


MUTATIONS: dict[str, Callable[[dict[str, Any]], None]] = {
    "format": _set(["format"], 2),
    "contract_id": _set(["contract_id"], "changed"),
    "task_owner": _set(["task_owner"], "FUTURE-PARITY-BACKLOG.14.3.2"),
    "status": _set(["status"], "complete"),
    "count_current_nodes": _set(["expected_counts", "current_action_ir_nodes"], 127),
    "count_dedicated_nodes": _set(["expected_counts", "dedicated_action_ir_nodes"], 3),
    "count_calls": _set(["expected_counts", "canonical_call_contracts"], 245),
    "syntax_checkpoint": _set(["authored_surface", "checkpoint"], "tx = save_cursor()"),
    "syntax_attempt": _set(["authored_surface", "attempt"], "matched = call(Child)"),
    "syntax_commit": _set(["authored_surface", "commit"], "payload = restore_cursor(tx)"),
    "syntax_rollback": _set(["authored_surface", "rollback"], "restore_cursor(tx)"),
    "result_separation": _set(["authored_surface", "result_separation"], "payload truthiness is match presence"),
    "token_state": _set(["token_model", "states", 1], "active"),
    "token_transition": _set(["token_model", "transitions", 1, 2], "invalidated"),
    "token_payload": _set(["token_model", "matched_payloads"], ["value"]),
    "token_positive": _set(["fixtures", "token_positive", 0, "result"], True),
    "token_negative": _set(["fixtures", "token_negative", 0, "diagnostic"], "recognition_token_expected"),
    "effect_allowed": _set(["effect_model", "allowed", 0], "binding_write"),
    "effect_rejected": _set(["effect_model", "rejected", 0], "pure_value"),
    "action_row_missing": _delete_effect_row("action_ir_effect_rows", "source_read"),
    "action_row_duplicate": _duplicate_effect_row("action_ir_effect_rows", "pure_value", "source_read"),
    "action_row_unknown": _unknown_effect_row("action_ir_effect_rows", "pure_value"),
    "call_row_missing": _delete_effect_row("canonical_call_effect_rows", "pure_value"),
    "call_row_duplicate": _duplicate_effect_row("canonical_call_effect_rows", "source_read", "pure_value"),
    "call_row_unknown": _unknown_effect_row("canonical_call_effect_rows", "pure_value"),
    "effect_graph": _set(["fixtures", "effect_graphs", 0, "accepted"], False),
    "mark_fixture": _set(["fixtures", "marks", 0, "expected", "cursor"], 5),
    "progress_fixture": _set(["fixtures", "progress", 0, "end"], 1),
    "diagnostic": _set(["diagnostics", 0, "code"], "changed"),
    "rollout_order": _set(["rollout", 0, "order"], 2),
    "rollout_owner": _set(["rollout", 1, "owner"], "FUTURE-PARITY-BACKLOG.14.3.1.1"),
    "rollout_status": _set(["rollout", 2, "status"], "red"),
    "rollout_perl_regression": _set(["rollout", 1, "status"], "red"),
    "rollout_dart_regression": _set(["rollout", 3, "status"], "red"),
    "rollout_julia_regression": _set(["rollout", 4, "status"], "red"),
    "rollout_next_backend": _set(["rollout", 5, "status"], "complete"),
    "canonical_contract_path": _set(["canonical_execution", "contract_path"], "changed.json"),
    "canonical_checker_path": _set(["canonical_execution", "checker_path"], "changed.py"),
    "canonical_invocation": _set(
        ["canonical_execution", "invocation"],
        "python3 tools/check_recognition_transaction_contract.py",
    ),
    "canonical_registration": _set(["canonical_execution", "registration_marker"], "changed"),
    "tracked_required": _set(["canonical_execution", "tracked_required"], False),
    "freshness_source": _set(["canonical_execution", "freshness_sources", 0], "changed"),
    "policy_fail_closed": _set(["policy", "fail_closed"], "unknown nodes are allowed"),
    "current_boundary": _set(["policy", "current_boundary"], "public and current"),
}


def validate_mutations(document: dict[str, Any]) -> None:
    for mutation_id, mutate in MUTATIONS.items():
        candidate = copy.deepcopy(document)
        mutate(candidate)
        try:
            validate_contract(candidate, check_environment=False)
        except ContractError:
            continue
        raise ContractError(f"mutation {mutation_id!r} was accepted")


def public_claim_mutation(
    path: str,
    claim: str,
) -> Callable[[dict[str, Any], dict[str, Any], dict[str, str]], None]:
    def mutate(
        _document: dict[str, Any],
        _contract: dict[str, Any],
        candidate_texts: dict[str, str],
    ) -> None:
        candidate_texts[path] += "\n" + claim

    return mutate


def validate_public_sequence_mutations(document: dict[str, Any]) -> int:
    texts = public_sequence_texts()
    capture_path = PUBLIC_SEQUENCE_CONTRACT["documents"][0]["path"]
    capture_marker = PUBLIC_SEQUENCE_CONTRACT["documents"][0]["required_markers"][0]
    mutations: list[
        tuple[
            str,
            Callable[[dict[str, Any], dict[str, Any], dict[str, str]], None],
        ]
    ] = [
        (
            "public document omission",
            lambda _document, contract, _texts: contract["documents"].pop(),
        ),
        (
            "public document duplication",
            lambda _document, contract, _texts: contract["documents"].append(
                copy.deepcopy(contract["documents"][0])
            ),
        ),
        (
            "public document path drift",
            lambda _document, contract, _texts: contract["documents"][0].__setitem__(
                "path", "docs/linkedspec-book/src/missing.md"
            ),
        ),
        (
            "public marker omission",
            lambda _document, contract, _texts: contract["documents"][0][
                "required_markers"
            ].pop(),
        ),
        (
            "public marker drift",
            lambda _document, contract, _texts: contract["documents"][0][
                "required_markers"
            ].__setitem__(0, "changed marker"),
        ),
        (
            "forbidden public claim omission",
            lambda _document, contract, _texts: contract["forbidden_claims"].pop(),
        ),
        (
            "forbidden public path drift",
            lambda _document, contract, _texts: contract["forbidden_claims"][0].__setitem__(
                "path", "docs/linkedspec-book/src/missing.md"
            ),
        ),
        (
            "forbidden public text drift",
            lambda _document, contract, _texts: contract["forbidden_claims"][0].__setitem__(
                "text", "changed stale claim"
            ),
        ),
        (
            "required public marker deletion",
            lambda _document, _contract, candidate_texts: candidate_texts.__setitem__(
                capture_path,
                candidate_texts[capture_path].replace(capture_marker, "", 1),
            ),
        ),
        (
            "required public marker duplication",
            lambda _document, _contract, candidate_texts: candidate_texts.__setitem__(
                capture_path,
                candidate_texts[capture_path] + "\n" + capture_marker,
            ),
        ),
        (
            "neutral rollout regression",
            lambda candidate, _contract, _texts: candidate["rollout"][0].__setitem__(
                "status", "red"
            ),
        ),
        (
            "Perl rollout regression",
            lambda candidate, _contract, _texts: candidate["rollout"][1].__setitem__(
                "status", "red"
            ),
        ),
        (
            "Rust rollout regression",
            lambda candidate, _contract, _texts: candidate["rollout"][2].__setitem__(
                "status", "red"
            ),
        ),
        (
            "Dart rollout regression",
            lambda candidate, _contract, _texts: candidate["rollout"][3].__setitem__(
                "status", "red"
            ),
        ),
        (
            "Julia rollout regression",
            lambda candidate, _contract, _texts: candidate["rollout"][4].__setitem__(
                "status", "red"
            ),
        ),
        (
            "backend rollout promotion",
            lambda candidate, _contract, _texts: candidate["rollout"][5].__setitem__(
                "status", "complete"
            ),
        ),
    ]
    for index, forbidden_row in enumerate(PUBLIC_SEQUENCE_CONTRACT["forbidden_claims"], 1):
        forbidden_path = forbidden_row["path"]
        forbidden_text = forbidden_row["text"]
        mutations.append(
            (
                f"forbidden public claim {index}",
                public_claim_mutation(forbidden_path, forbidden_text),
            )
        )
    require(
        len(mutations) == PUBLIC_SEQUENCE_MUTATION_COUNT,
        "public sequence mutation count drifted",
    )
    for name, mutate in mutations:
        candidate_document = copy.deepcopy(document)
        candidate_contract = copy.deepcopy(PUBLIC_SEQUENCE_CONTRACT)
        candidate_texts = dict(texts)
        mutate(candidate_document, candidate_contract, candidate_texts)
        try:
            validate_public_sequence(
                candidate_document,
                candidate_contract,
                candidate_texts,
                check_tracked=False,
            )
        except ContractError:
            continue
        raise ContractError(f"public sequence mutation {name!r} was accepted")
    return len(mutations)


def validate_capability_guide_mutations() -> int:
    text = read_text(ROOT / CAPABILITY_GUIDE_CONTRACT["path"])
    marker = CAPABILITY_GUIDE_CONTRACT["required_markers"][0]
    mutations: list[tuple[str, Callable[[dict[str, Any], str], tuple[dict[str, Any], str]]]] = [
        (
            "guide path drift",
            lambda contract, candidate: (
                {**contract, "path": "capability_conformance/missing.md"},
                candidate,
            ),
        ),
        (
            "guide marker contract drift",
            lambda contract, candidate: (
                {
                    **contract,
                    "required_markers": ["changed marker", *contract["required_markers"][1:]],
                },
                candidate,
            ),
        ),
        (
            "guide marker deletion",
            lambda contract, candidate: (contract, candidate.replace(marker, "", 1)),
        ),
        (
            "guide marker duplication",
            lambda contract, candidate: (contract, candidate + "\n" + marker),
        ),
    ]
    for index, stale_claim in enumerate(CAPABILITY_GUIDE_CONTRACT["forbidden_claims"], 1):
        mutations.append(
            (
                f"stale guide claim {index}",
                lambda contract, candidate, claim=stale_claim: (
                    contract,
                    candidate + "\n" + claim,
                ),
            )
        )
    require(
        len(mutations) == CAPABILITY_GUIDE_MUTATION_COUNT,
        "capability-guide mutation count drifted",
    )
    for name, mutate in mutations:
        candidate_contract, candidate_text = mutate(
            copy.deepcopy(CAPABILITY_GUIDE_CONTRACT), text
        )
        try:
            validate_capability_guide(
                candidate_contract,
                candidate_text,
                check_tracked=False,
            )
        except ContractError:
            continue
        raise ContractError(f"capability-guide mutation {name!r} was accepted")
    return len(mutations)


def validate_rust_admission_mutations() -> int:
    ci = read_text(CI_PATH)
    sources = rust_admission_sources()
    markers = [
        f"require_tracked_file {EXPECTED_RUST_ADMISSION['consumer_path']}",
        f"log \"{EXPECTED_RUST_ADMISSION['registration_marker']}\"",
        EXPECTED_RUST_ADMISSION["invocation"],
    ]
    mutations: list[tuple[str, str, str | None]] = []
    for label, marker in zip(("require", "log", "invocation"), markers, strict=True):
        mutations.extend(
            [
                (f"Rust {label} omission", ci.replace(marker, "", 1), None),
                (f"Rust {label} duplication", ci + "\n" + marker, None),
            ]
        )
    mutations.extend(
        [
            (
                "Rust outer cfg retained",
                ci,
                "#![cfg(linkedspec_recognition_transaction_red)]",
            ),
            (
                "Rust integration cfg retained",
                ci,
                "#[cfg(linkedspec_recognition_transaction_integration_red)]",
            ),
        ]
    )
    require(
        len(mutations) == RUST_ADMISSION_MUTATION_COUNT,
        "Rust admission mutation count drifted",
    )
    for name, candidate_ci, stale_source in mutations:
        candidate_sources = dict(sources)
        if stale_source is not None:
            candidate_sources[RUST_CONSUMER_PATH] += "\n" + stale_source
        try:
            validate_rust_admission(candidate_ci, candidate_sources)
        except ContractError:
            continue
        raise ContractError(f"Rust admission mutation {name!r} was accepted")
    return len(mutations)


def validate_dart_admission_mutations() -> int:
    ci = read_text(CI_PATH)
    sources = dart_admission_sources()
    markers = [
        f"require_tracked_file {EXPECTED_DART_ADMISSION['consumer_path']}",
        f"log \"{EXPECTED_DART_ADMISSION['registration_marker']}\"",
        EXPECTED_DART_ADMISSION["invocation"],
    ]
    mutations: list[tuple[str, str, str | None, str | None]] = []
    for label, marker in zip(("require", "log", "invocation"), markers, strict=True):
        mutations.extend(
            [
                (f"Dart {label} omission", ci.replace(marker, "", 1), None, None),
                (f"Dart {label} duplication", ci + "\n" + marker, None, None),
            ]
        )
    mutations.extend(
        [
            (
                "Dart dormant canonical path retained",
                ci + "\n" + DART_DORMANT_CONSUMER_PATH,
                None,
                None,
            ),
            (
                "Dart environment switch retained",
                ci,
                "LINKEDSPEC_DART_RECOGNITION_TRANSACTION_INTEGRATION_RED",
                None,
            ),
            ("Dart skip authority retained", ci, "_integrationRedSkip", None),
            ("Dart dormant source path retained", ci, DART_DORMANT_CONSUMER_PATH, None),
            ("Dart skipped test retained", ci, "skip:", None),
            (
                "Dart private import removed",
                ci,
                None,
                DART_PRIVATE_IMPORT,
            ),
            (
                "Dart private authority publicly exported",
                ci,
                None,
                "export 'src/runtime/recognition_transaction.dart';",
            ),
        ]
    )
    require(
        len(mutations) == DART_ADMISSION_MUTATION_COUNT,
        "Dart admission mutation count drifted",
    )
    for name, candidate_ci, stale_consumer, source_change in mutations:
        candidate_sources = dict(sources)
        if stale_consumer is not None:
            candidate_sources[DART_CONSUMER_PATH] += "\n" + stale_consumer
        if source_change == DART_PRIVATE_IMPORT:
            candidate_sources[DART_CONSUMER_PATH] = candidate_sources[
                DART_CONSUMER_PATH
            ].replace(DART_PRIVATE_IMPORT, "changed/private/import.dart", 1)
        elif source_change is not None:
            candidate_sources[DART_FACADE_PATH] += "\n" + source_change
        try:
            validate_dart_admission(candidate_ci, candidate_sources)
        except ContractError:
            continue
        raise ContractError(f"Dart admission mutation {name!r} was accepted")
    return len(mutations)


def validate_julia_admission_mutations() -> int:
    ci = read_text(CI_PATH)
    sources = julia_admission_sources()
    markers = [
        f"require_tracked_file {EXPECTED_JULIA_ADMISSION['consumer_path']}",
        f"log \"{EXPECTED_JULIA_ADMISSION['registration_marker']}\"",
        EXPECTED_JULIA_ADMISSION["invocation"],
    ]
    mutations: list[tuple[str, str, dict[str, str]]] = []
    for label, marker in zip(("require", "log", "invocation"), markers, strict=True):
        mutations.extend(
            [
                (f"Julia {label} omission", ci.replace(marker, "", 1), dict(sources)),
                (f"Julia {label} duplication", ci + "\n" + marker, dict(sources)),
            ]
        )

    omitted_include = dict(sources)
    omitted_include[JULIA_RUNTESTS_PATH] = omitted_include[JULIA_RUNTESTS_PATH].replace(
        JULIA_ORDINARY_INCLUDE, "", 1
    )
    mutations.append(("Julia ordinary include omission", ci, omitted_include))
    duplicated_include = dict(sources)
    duplicated_include[JULIA_RUNTESTS_PATH] += "\n" + JULIA_ORDINARY_INCLUDE
    mutations.append(("Julia ordinary include duplication", ci, duplicated_include))

    for label, stale in (
        ("environment switch retained", "LINKEDSPEC_JULIA_RECOGNITION_TRANSACTION_RED_MODE"),
        ("selector constant retained", "JULIA_RECOGNITION_TRANSACTION_RED_MODE"),
        ("integration conditional retained", 'if JULIA_RECOGNITION_TRANSACTION_RED_MODE == "integration"'),
        ("dormant testset retained", "Julia dormant recognition-transaction contract"),
    ):
        candidate = dict(sources)
        candidate[JULIA_CONSUMER_PATH] += "\n" + stale
        mutations.append((f"Julia {label}", ci, candidate))

    private_removed = dict(sources)
    private_removed[JULIA_CONSUMER_PATH] = private_removed[JULIA_CONSUMER_PATH].replace(
        JULIA_PRIVATE_AUTHORITY_ACCESS, "", 1
    )
    mutations.append(("Julia private authority access removed", ci, private_removed))
    facade_export = dict(sources)
    facade_export[JULIA_FACADE_PATH] += "\n    RecognitionTransaction,"
    mutations.append(("Julia private authority publicly exported", ci, facade_export))

    require(
        len(mutations) == JULIA_ADMISSION_MUTATION_COUNT,
        "Julia admission mutation count drifted",
    )
    for name, candidate_ci, candidate_sources in mutations:
        try:
            validate_julia_admission(candidate_ci, candidate_sources)
        except ContractError:
            continue
        raise ContractError(f"Julia admission mutation {name!r} was accepted")
    return len(mutations)


def validate_lua_dormant_red_mutations() -> int:
    ci = read_text(CI_PATH)
    ordinary = read_text(ROOT / LUA_ORDINARY_PATH)
    sources = lua_dormant_red_sources()
    mutations: list[tuple[str, str, str, dict[str, str]]] = []

    for label, marker in (
        ("selector", LUA_RED_SELECTOR),
        ("private lookup", LUA_PRIVATE_REQUIRE),
        ("stable diagnostic", LUA_RED_DIAGNOSTIC),
        ("integration boundary", 'if mode == "integration" then'),
        (
            "current neutral status",
            "neutral_perl_rust_dart_and_julia_complete_other_legs_red",
        ),
    ):
        candidate = dict(sources)
        candidate[LUA_CONSUMER_PATH] = candidate[LUA_CONSUMER_PATH].replace(
            marker, "", 1
        )
        mutations.append((f"Lua RED {label} omission", ci, ordinary, candidate))

    omitted = dict(sources)
    omitted[LUA_CONSUMER_PATH] = ""
    mutations.append(("Lua RED consumer omission", ci, ordinary, omitted))
    mutations.extend(
        [
            (
                "Lua RED ordinary PUC registration",
                ci,
                ordinary + "\n" + LUA_CONSUMER_PATH + " puc",
                dict(sources),
            ),
            (
                "Lua RED ordinary LuaJIT registration",
                ci,
                ordinary + "\n" + LUA_CONSUMER_PATH + " luajit",
                dict(sources),
            ),
            (
                "Lua RED canonical PUC registration",
                ci + "\n" + LUA_CONSUMER_PATH + " puc",
                ordinary,
                dict(sources),
            ),
            (
                "Lua RED canonical LuaJIT registration",
                ci + "\n" + LUA_CONSUMER_PATH + " luajit",
                ordinary,
                dict(sources),
            ),
        ]
    )
    facade_export = dict(sources)
    facade_export[LUA_FACADE_PATH] += "\nM.recognition_transaction = require('x')"
    mutations.append(("Lua RED facade export", ci, ordinary, facade_export))
    wrong_commands = dict(sources)
    wrong_commands[LUA_CONSUMER_PATH] = wrong_commands[LUA_CONSUMER_PATH].replace(
        "bash tools/run_lua_project_data.sh luajit " + LUA_CONSUMER_PATH,
        "bash tools/run_lua_project_data.sh puc " + LUA_CONSUMER_PATH,
        1,
    )
    mutations.append(("Lua RED ABI command collapse", ci, ordinary, wrong_commands))

    require(
        len(mutations) == LUA_DORMANT_RED_MUTATION_COUNT,
        "Lua dormant RED mutation count drifted",
    )
    for name, candidate_ci, candidate_ordinary, candidate_sources in mutations:
        try:
            validate_lua_dormant_red(
                candidate_ci,
                candidate_ordinary,
                candidate_sources,
            )
        except ContractError:
            continue
        raise ContractError(f"Lua dormant RED mutation {name!r} was accepted")
    return len(mutations)


def validate_lua_authority_mutations() -> int:
    ci = read_text(CI_PATH)
    ordinary = read_text(ROOT / LUA_ORDINARY_PATH)
    sources = lua_dormant_red_sources()
    mutations: list[tuple[str, dict[str, str]]] = []
    for marker, label in LUA_AUTHORITY_MARKERS:
        candidate = dict(sources)
        candidate[LUA_AUTHORITY_PATH] = candidate[LUA_AUTHORITY_PATH].replace(
            marker, "", 1
        )
        mutations.append((f"Lua authority {label} omission", candidate))

    missing_integration_red = dict(sources)
    missing_integration_red[LUA_CONSUMER_PATH] = missing_integration_red[
        LUA_CONSUMER_PATH
    ].replace(LUA_INTEGRATION_RED_DIAGNOSTIC, "", 1)
    mutations.append(("Lua authority next-RED omission", missing_integration_red))

    require(
        len(mutations) == LUA_AUTHORITY_MUTATION_COUNT,
        "Lua private authority mutation count drifted",
    )
    for name, candidate_sources in mutations:
        try:
            validate_lua_dormant_red(ci, ordinary, candidate_sources)
        except ContractError:
            continue
        raise ContractError(f"Lua private authority mutation {name!r} was accepted")
    return len(mutations)


def main() -> int:
    try:
        document = load_contract()
        validate_contract(document, check_environment=True)
        validate_mutations(document)
        public_mutations = validate_public_sequence_mutations(document)
        guide_mutations = validate_capability_guide_mutations()
        rust_admission_mutations = validate_rust_admission_mutations()
        dart_admission_mutations = validate_dart_admission_mutations()
        julia_admission_mutations = validate_julia_admission_mutations()
        lua_red_mutations = validate_lua_dormant_red_mutations()
        lua_authority_mutations = validate_lua_authority_mutations()
    except ContractError as exc:
        print(f"recognition-transaction-contract: ERROR: {exc}", file=sys.stderr)
        return 1
    print(
        "recognition-transaction-contract: OK "
        "(132 ActionIR rows = 128 current + 4 dedicated; 246 call rows; "
        "token 8 positive/17 negative; effects 6 graphs; marks 6; progress 8; "
        "44 rejected mutations; rollout neutral + Perl + Rust + Dart + Julia 5/9 complete; "
        f"public sequence 3 documents/17 forbidden/{public_mutations} mutations; "
        f"capability guide 1 document/8 forbidden/{guide_mutations} mutations; "
        f"Rust admission {rust_admission_mutations} mutations; "
        f"Dart admission {dart_admission_mutations} mutations; "
        f"Julia admission {julia_admission_mutations} mutations; "
        f"Lua dormant RED {lua_red_mutations} mutations; "
        f"Lua private authority {lua_authority_mutations} mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Validate the neutral root-rule selection contract and its drift mutations."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "root_rule_selection_contract.json"
CONTRACT_ID = "linkedspec-root-rule-selection-v1"
TASK_OWNER = "FUTURE-PARITY-BACKLOG.9.1.1.2"
TOP_LEVEL_FIELDS = {
    "format",
    "contract_id",
    "task_owner",
    "terminology",
    "precedence",
    "validation",
    "selector",
    "source_identity",
    "strict_unused",
    "selection_cases",
    "failure_cases",
    "strict_cases",
    "projections",
    "required_execution_routes",
    "rust_admission",
    "dart_admission",
    "julia_admission",
    "lua_admission",
    "implementation_inventory",
    "recurring_gate",
    "public_contract",
    "rollout",
}
PRECEDENCE = ["explicit_selector", "first_authored_marker", "first_authored_rule"]
SELECTION_CASE_IDS = [
    "explicit_ordinary_beats_markers",
    "explicit_later_marker_beats_first_marker",
    "marker_beats_earlier_ordinary",
    "first_marker_beats_later_marker",
    "first_ordinary_without_marker",
    "explicit_later_ordinary_without_marker",
    "single_ordinary_fallback",
    "single_marker_default",
]
FAILURE_CASE_IDS = [
    "unknown_explicit_selector",
    "zero_rules_without_selector",
    "zero_rules_with_selector",
]
STRICT_CASE_IDS = [
    "explicit_selection_is_not_reference",
    "marker_selection_is_not_reference",
    "closed_reference_cycle_has_no_unused_rules",
]
PROJECTIONS = {
    "native",
    "loaded_and_reconstructed",
    "descriptor",
    "generated_source",
    "trace",
    "primary_cli",
    "strict_unused",
}
ROUTES = [
    "native",
    "loaded",
    "reconstructed",
    "generated_direct",
    "generated_traced",
    "emitted_source_direct",
    "emitted_source_traced",
    "primary_cli",
]
INVENTORY = [
    (
        "perl",
        "marker_optional_one_or_more_rules",
        "first_authored_marker_then_first_authored_rule",
        "supported_and_wins",
        "implemented",
        "ordered_authored_state_and_explicit_execution",
        "present",
        "FUTURE-PARITY-BACKLOG.9.1.1.2.1",
    ),
    (
        "rust",
        "marker_optional_one_or_more_rules",
        "first_authored_marker_then_first_authored_rule",
        "supported_and_wins",
        "implemented",
        "ordered_authored_state_and_explicit_execution",
        "present",
        "FUTURE-PARITY-BACKLOG.9.1.1.2.2",
    ),
    (
        "dart",
        "marker_optional_one_or_more_rules",
        "first_authored_marker_then_first_authored_rule",
        "supported_and_wins",
        "implemented",
        "shares_runtime_fallback",
        "present",
        "FUTURE-PARITY-BACKLOG.9.1.1.2.3",
    ),
    (
        "julia",
        "marker_optional_one_or_more_rules",
        "first_authored_marker_then_first_authored_rule",
        "supported_and_wins",
        "implemented",
        "shares_runtime_fallback",
        "present",
        "FUTURE-PARITY-BACKLOG.9.1.1.2.4",
    ),
    (
        "lua",
        "marker_optional_one_or_more_rules",
        "first_authored_marker_then_first_authored_rule",
        "supported_and_wins",
        "implemented",
        "shares_runtime_fallback",
        "present",
        "FUTURE-PARITY-BACKLOG.9.1.1.2.5",
    ),
]
ROLLOUT = [
    ("neutral_contract", "complete", "FUTURE-PARITY-BACKLOG.9.1.1.2.0"),
    ("perl_reference", "complete", "FUTURE-PARITY-BACKLOG.9.1.1.2.1"),
    ("rust", "complete", "FUTURE-PARITY-BACKLOG.9.1.1.2.2"),
    ("dart", "complete", "FUTURE-PARITY-BACKLOG.9.1.1.2.3"),
    ("julia", "complete", "FUTURE-PARITY-BACKLOG.9.1.1.2.4"),
    ("lua", "complete", "FUTURE-PARITY-BACKLOG.9.1.1.2.5"),
    (
        "admission_and_public_no_drift",
        "complete",
        "FUTURE-PARITY-BACKLOG.9.1.1.2.6",
    ),
]
RUST_ADMISSION = {
    "consumer_path": "rust/linkedspec-runtime/tests/root_rule_selection_admission.rs",
    "canonical_driver": "tools/run_ci_local.sh",
    "backend_driver": "tools/run_rust_local.sh",
    "roles": [
        "neutral_selection",
        "neutral_failures",
        "neutral_strict",
        "native",
        "loaded",
        "reconstructed",
        "generated_direct",
        "generated_traced",
        "emitted_source_direct",
        "emitted_source_traced",
        "descriptor",
        "diagnostic",
        "runtime_trace",
        "primary_cli",
        "primary_request_trace",
    ],
    "primary_case_ids": [
        "success_default_first_authored_marker",
        "success_markerless_first_authored_rule",
        "success_explicit_top_rule",
        "failure_invocation_missing_top_rule",
        "trace_stdout_medium",
        "trace_failure_invoke_escaped_field",
    ],
}
DART_ADMISSION = {
    "consumer_path": "dart/test/root_rule_selection_admission_test.dart",
    "canonical_driver": "tools/run_ci_local.sh",
    "backend_driver": "tools/run_dart_local.sh",
    "roles": [
        "neutral_selection",
        "neutral_failures",
        "neutral_strict",
        "native",
        "loaded",
        "reconstructed",
        "generated_direct",
        "generated_traced",
        "emitted_source_direct",
        "emitted_source_traced",
        "descriptor",
        "diagnostic",
        "runtime_trace",
        "primary_cli",
        "primary_request_trace",
    ],
    "primary_case_ids": [
        "success_default_first_authored_marker",
        "success_markerless_first_authored_rule",
        "success_explicit_top_rule",
        "failure_invocation_missing_top_rule",
        "trace_stdout_medium",
        "trace_failure_invoke_escaped_field",
    ],
}
JULIA_ADMISSION = {
    "consumer_path": "julia/test/root_rule_selection_admission_test.jl",
    "canonical_driver": "tools/run_ci_local.sh",
    "backend_driver": "tools/run_julia_local.sh",
    "roles": [
        "neutral_selection",
        "neutral_failures",
        "neutral_strict",
        "native",
        "loaded",
        "reconstructed",
        "generated_direct",
        "generated_traced",
        "emitted_source_direct",
        "emitted_source_traced",
        "descriptor",
        "diagnostic",
        "runtime_trace",
        "primary_cli",
        "primary_request_trace",
    ],
    "primary_case_ids": [
        "success_default_first_authored_marker",
        "success_markerless_first_authored_rule",
        "success_explicit_top_rule",
        "failure_invocation_missing_top_rule",
        "trace_stdout_medium",
        "trace_failure_invoke_escaped_field",
    ],
}
LUA_ADMISSION = {
    "consumer_path": "lua/test/root_rule_selection_admission_test.lua",
    "canonical_driver": "tools/run_ci_local.sh",
    "backend_driver": "tools/run_lua_local.sh",
    "roles": [
        "neutral_selection",
        "neutral_failures",
        "neutral_strict",
        "native",
        "loaded",
        "reconstructed",
        "generated_direct",
        "generated_traced",
        "emitted_source_direct",
        "emitted_source_traced",
        "descriptor",
        "diagnostic",
        "runtime_trace",
        "primary_cli",
        "primary_request_trace",
    ],
    "primary_case_ids": [
        "success_default_first_authored_marker",
        "success_markerless_first_authored_rule",
        "success_explicit_top_rule",
        "failure_invocation_missing_top_rule",
        "trace_stdout_medium",
        "trace_failure_invoke_escaped_field",
    ],
}
RECURRING_GATE = {
    "driver": "tools/check_root_rule_selection_five_backend.sh",
    "consumer_schema": {
        "fields": ["backend", "runtime", "test_paths", "roles"],
        "role_policy": "the Perl core/route pair and every ordered backend admission role are required",
    },
    "consumers": [
        {
            "backend": "perl",
            "runtime": "perl",
            "test_paths": [
                "t/root_rule_selection_perl_core.t",
                "t/root_rule_selection_perl_routes.t",
            ],
            "roles": ["core", "routes"],
        },
        {
            "backend": "rust",
            "runtime": "rust",
            "test_paths": [RUST_ADMISSION["consumer_path"]],
            "roles": RUST_ADMISSION["roles"],
        },
        {
            "backend": "dart",
            "runtime": "dart",
            "test_paths": [DART_ADMISSION["consumer_path"]],
            "roles": DART_ADMISSION["roles"],
        },
        {
            "backend": "julia",
            "runtime": "julia",
            "test_paths": [JULIA_ADMISSION["consumer_path"]],
            "roles": JULIA_ADMISSION["roles"],
        },
        {
            "backend": "lua",
            "runtime": "puc_lua",
            "test_paths": [LUA_ADMISSION["consumer_path"]],
            "roles": LUA_ADMISSION["roles"],
        },
        {
            "backend": "lua",
            "runtime": "luajit",
            "test_paths": [LUA_ADMISSION["consumer_path"]],
            "roles": LUA_ADMISSION["roles"],
        },
    ],
    "primary_cli": {
        "matrix_driver": "tools/run_primary_cli_matrix.sh",
        "case_ids": RUST_ADMISSION["primary_case_ids"],
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
        "switch": "LINKEDSPEC_RUN_ROOT_RULE_MATRIX",
    },
}
PUBLIC_CONTRACT = {
    "documents": [
        {
            "path": "USER_GUIDE.md",
            "required_markers": [
                "explicit `top_rule` wins",
                "first authored `Rule::`",
                "first authored ordinary `Rule:`",
            ],
        },
        {
            "path": "rust/README.md",
            "required_markers": ["Root-selection parity is closed", "7 complete / 0 pending"],
        },
        {
            "path": "dart/README.md",
            "required_markers": [
                "Root-selection parity is closed",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "julia/README.md",
            "required_markers": ["Root-selection parity is closed", "7 complete / 0 pending"],
        },
        {
            "path": "lua/README.md",
            "required_markers": [
                "Root-selection parity is closed",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "capability_conformance/README.md",
            "required_markers": [
                "54 semantic, topology, recurring, public, and rollout drift mutations",
                "7 complete / 0 pending",
            ],
        },
        {
            "path": "cli_conformance/README.md",
            "required_markers": [
                "5x2x6 selected root-rule matrix",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "ROADMAP.md",
            "required_markers": [
                "Root-selection rollout is closed at 7 complete / 0 pending",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "ROADMAP_V2.md",
            "required_markers": [
                "Root-selection rollout is closed at 7 complete / 0 pending",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "ARCHITECTURE_STATE.md",
            "required_markers": ["root-selection public no-drift", "7 complete / 0 pending"],
        },
        {
            "path": "docs/decisions/0067-live-achievement-status-history.md",
            "required_markers": [
                "FUTURE-PARITY-BACKLOG.9.1.1.2.6 — close root-selection public no-drift",
                "7 complete / 0 pending",
            ],
        },
        {
            "path": "docs/TASK_TREE.md",
            "required_markers": ["final five-backend recurring/public no-drift"],
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "required_markers": [
                "7 complete / 0 pending",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/formal-grammar.md",
            "required_markers": [
                "7 complete / 0 pending",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/public-api/get-and-get-parser.md",
            "required_markers": ["explicit `top_rule` wins", "7 complete / 0 pending"],
        },
        {
            "path": "docs/linkedspec-book/src/public-api/descriptor-introspection.md",
            "required_markers": ["root-selection parity is closed", "7 complete / 0 pending"],
        },
        {
            "path": "docs/linkedspec-book/src/compiler/generated-handlers-and-dispatch.md",
            "required_markers": [
                "root-selection parity is closed",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/user-model/spec-files-and-rule-paragraphs.md",
            "required_markers": [
                "7 complete / 0 pending",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md",
            "required_markers": ["root-selection parity is closed", "7 complete / 0 pending"],
        },
        {
            "path": "docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md",
            "required_markers": [
                "root-selection parity is closed",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "docs/linkedspec-book/src/development/local-ci-and-regression.md",
            "required_markers": [
                "LINKEDSPEC_RUN_ROOT_RULE_MATRIX=1",
                "5x2x6 selected root-rule matrix",
            ],
        },
        {
            "path": "docs/knowledge/root-rule-selection-precedence.md",
            "required_markers": [
                "7 complete / 0 pending",
                "tools/check_root_rule_selection_five_backend.sh",
            ],
        },
        {
            "path": "docs/knowledge/root-rule-selection-five-backend-admission.md",
            "required_markers": [
                "7 complete / 0 pending",
                "LINKEDSPEC_RUN_ROOT_RULE_MATRIX=1",
            ],
        },
        {
            "path": "docs/knowledge/root-rule-rollout-roadmap-projection.md",
            "required_markers": [
                "gap_status: resolved",
                "ROADMAP.md and ROADMAP_V2.md are required current-state checker inputs",
            ],
        },
    ],
    "forbidden_current_claims": [
        {
            "path": "USER_GUIDE.md",
            "text": "If `top_rule` is omitted, LinkedSpec now uses the first parsed rule paragraph as the default top-level entry.",
        },
        {
            "path": "dart/README.md",
            "text": "Dart is now admitted while Julia, Lua, and final no-drift remain.",
        },
        {
            "path": "julia/README.md",
            "text": "Exact root\nadmission `.4.3` is next, while root rollout stays 4/7.",
        },
        {
            "path": "lua/README.md",
            "text": "final topology admission remain separately owned by `.5.2-.3`.",
        },
        {"path": "capability_conformance/README.md", "text": "6 complete / 1 pending"},
        {
            "path": "capability_conformance/README.md",
            "text": "Lua/LuaJIT and cross-backend no-drift leg `.6` remain pending.",
        },
        {
            "path": "ROADMAP.md",
            "text": "only composed public\nadmission `.6` remains pending",
        },
        {
            "path": "ROADMAP.md",
            "text": "active; neutral + all five backends complete at 6/7; final public no-drift pending",
        },
        {
            "path": "ROADMAP_V2.md",
            "text": "complete at 6/7 with 44 rejected mutations",
        },
        {
            "path": "ROADMAP_V2.md",
            "text": "root 6/1/44; final root no-drift `.6` follows",
        },
        {
            "path": "ARCHITECTURE_STATE.md",
            "text": "root governance 6 complete + 1 pending / 44 mutations pass",
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "text": "Root governance is 6/7 plus 44 rejected mutations. Only final recurring/public\nno-drift remains.",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/formal-grammar.md",
            "text": "At rollout 6 complete / 1 pending",
        },
        {
            "path": "docs/linkedspec-book/src/public-api/get-and-get-parser.md",
            "text": "That contract is at 6 complete / 1 pending.",
        },
        {
            "path": "docs/linkedspec-book/src/user-model/spec-files-and-rule-paragraphs.md",
            "text": "backend-admitted at rollout 6/7; final recurring/public no-drift",
        },
        {
            "path": "docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md",
            "text": "Lua implements the selection core and composed routes, while its topology admission\nand final no-drift remain staged.",
        },
        {
            "path": "docs/linkedspec-book/src/development/local-ci-and-regression.md",
            "text": "A green 5x2x65 run is the\nfinal rollout target rather than a current cross-backend claim.",
        },
    ],
}


class ContractError(ValueError):
    """A deterministic neutral-contract validation failure."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def require_fields(value: Any, fields: set[str], context: str) -> dict[str, Any]:
    require(isinstance(value, dict), f"{context} must be an object")
    require(set(value) == fields, f"{context} fields drifted")
    return value


def require_unique_strings(value: Any, context: str) -> list[str]:
    require(isinstance(value, list), f"{context} must be a list")
    require(all(isinstance(item, str) and item for item in value), f"{context} has an invalid value")
    require(len(value) == len(set(value)), f"{context} contains duplicates")
    return value


def validate_rules(value: Any, context: str) -> list[dict[str, Any]]:
    require(isinstance(value, list), f"{context} must be a list")
    labels: list[str] = []
    for index, rule in enumerate(value):
        require_fields(rule, {"label", "authored_is_top"}, f"{context}[{index}]")
        require(isinstance(rule["label"], str) and rule["label"], f"{context}[{index}] label is invalid")
        require(isinstance(rule["authored_is_top"], bool), f"{context}[{index}] marker is invalid")
        labels.append(rule["label"])
    require(len(labels) == len(set(labels)), f"{context} contains duplicate labels")
    return value


def select_entry(
    rules: list[dict[str, Any]], explicit_selector: str | None
) -> tuple[str, str]:
    if not rules:
        raise ContractError("no_rules_defined:validate_spec")
    labels = [rule["label"] for rule in rules]
    if explicit_selector is not None:
        require(isinstance(explicit_selector, str) and explicit_selector, "explicit selector is invalid")
        if explicit_selector not in labels:
            raise ContractError("entry_rule_not_found:select_entry_rule")
        return explicit_selector, "explicit_selector"
    for rule in rules:
        if rule["authored_is_top"]:
            return rule["label"], "first_authored_marker"
    return rules[0]["label"], "first_authored_rule"


def validate_selection_cases(contract: dict[str, Any]) -> None:
    cases = contract["selection_cases"]
    require(isinstance(cases, list), "selection_cases must be a list")
    require([case.get("id") for case in cases] == SELECTION_CASE_IDS, "selection case order drifted")
    for case in cases:
        require_fields(
            case,
            {"id", "rules", "explicit_selector", "expected_label", "expected_basis"},
            f"selection case {case.get('id')!r}",
        )
        rules = validate_rules(case["rules"], f"selection case {case['id']} rules")
        actual = select_entry(rules, case["explicit_selector"])
        require(
            actual == (case["expected_label"], case["expected_basis"]),
            f"selection case {case['id']} drifted",
        )


def validate_failure_cases(contract: dict[str, Any]) -> None:
    cases = contract["failure_cases"]
    require(isinstance(cases, list), "failure_cases must be a list")
    require([case.get("id") for case in cases] == FAILURE_CASE_IDS, "failure case order drifted")
    for case in cases:
        require_fields(
            case,
            {"id", "rules", "explicit_selector", "expected_code", "expected_stage"},
            f"failure case {case.get('id')!r}",
        )
        rules = validate_rules(case["rules"], f"failure case {case['id']} rules")
        try:
            select_entry(rules, case["explicit_selector"])
        except ContractError as error:
            actual = str(error).split(":", 1)
            require(
                actual == [case["expected_code"], case["expected_stage"]],
                f"failure case {case['id']} drifted",
            )
        else:
            raise ContractError(f"failure case {case['id']} unexpectedly selected a rule")


def validate_strict_cases(contract: dict[str, Any]) -> None:
    cases = contract["strict_cases"]
    require(isinstance(cases, list), "strict_cases must be a list")
    require([case.get("id") for case in cases] == STRICT_CASE_IDS, "strict case order drifted")
    for case in cases:
        require_fields(
            case,
            {"id", "rules", "referenced_rules", "explicit_selector", "expected_unused"},
            f"strict case {case.get('id')!r}",
        )
        rules = require_unique_strings(case["rules"], f"strict case {case['id']} rules")
        referenced = require_unique_strings(
            case["referenced_rules"], f"strict case {case['id']} referenced rules"
        )
        require(set(referenced) <= set(rules), f"strict case {case['id']} has an unknown reference")
        if case["explicit_selector"] is not None:
            require(case["explicit_selector"] in rules, f"strict case {case['id']} selector is unknown")
        actual_unused = [label for label in rules if label not in set(referenced)]
        require(actual_unused == case["expected_unused"], f"strict case {case['id']} drifted")


def validate_filesystem_contract() -> None:
    markers = {
        "docs/decisions/0046-root-rule-selection-precedence.md": [CONTRACT_ID, TASK_OWNER],
        "docs/decisions/0010-top-rule-is-ordinary-rule-entered-first.md": ["ADR `0046`"],
        "docs/decisions/INDEX.md": ["0046-root-rule-selection-precedence.md"],
        "docs/tasks/FUTURE-PARITY-BACKLOG.09.md": ["FUTURE-PARITY-BACKLOG.9.1.1.2.0"],
        "capability_conformance/README.md": [CONTRACT_ID, "7 complete / 0 pending"],
        "ROADMAP.md": [
            CONTRACT_ID,
            "Root-selection rollout is closed at 7 complete / 0 pending",
            "tools/check_root_rule_selection_five_backend.sh",
        ],
        "ROADMAP_V2.md": [
            "Root-selection rollout is closed at 7 complete / 0 pending",
            "tools/check_root_rule_selection_five_backend.sh",
        ],
        "docs/linkedspec-book/src/appendix/formal-grammar.md": ["ADR `0046`", CONTRACT_ID],
        "t/root_rule_selection_perl_core.t": [
            "selection_cases",
            "failure_cases",
            "strict_cases",
            "native execution applies explicit marker fallback precedence",
        ],
        "t/root_rule_selection_perl_routes.t": [
            "LinkedSpec::get_parser",
            "LinkedSpec::SpecLoader::load_and_compile_spec",
            "generated_role_cases",
            "entry_rule_contract",
            "configured-missing.spec",
            "generated_entry_selection",
        ],
        "cli_conformance/cases/trace/medium_stdout.txt": ["top_rule=<default>"],
        "cli_conformance/cases/trace/failure_invoke_escaped_medium.txt": [
            "top_rule=Top%0AInjected"
        ],
        "tools/run_ci_local.sh": [
            "require_tracked_file tools/check_root_rule_selection_contract.py",
            "require_tracked_file capability_conformance/root_rule_selection_contract.json",
            "require_tracked_file t/root_rule_selection_perl_core.t",
            "require_tracked_file t/root_rule_selection_perl_routes.t",
            "bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py",
            "prove -Iperl t/root_rule_selection_perl_core.t",
            "prove -Iperl t/root_rule_selection_perl_routes.t",
            "require_tracked_file rust/linkedspec-runtime/tests/root_rule_selection_admission.rs",
            "require_tracked_file dart/test/root_rule_selection_admission_test.dart",
            "require_tracked_file julia/test/root_rule_selection_admission_test.jl",
            "require_tracked_file lua/test/root_rule_selection_admission_test.lua",
            "require_tracked_file tools/check_root_rule_selection_five_backend.sh",
            "LINKEDSPEC_RUN_ROOT_RULE_MATRIX",
        ],
    }
    for relative, required in markers.items():
        path = ROOT / relative
        require(path.is_file(), f"required contract path is missing: {relative}")
        text = path.read_text(encoding="utf-8")
        for marker in required:
            require(marker in text, f"{relative} is missing marker {marker!r}")

    cli_manifest = json.loads((ROOT / "cli_conformance" / "manifest.json").read_text(encoding="utf-8"))
    cases = {case["id"]: case for case in cli_manifest["cases"]}
    explicit = cases.get("success_explicit_top_rule")
    require(isinstance(explicit, dict), "shared CLI explicit top-rule case is missing")
    require(
        "--top-rule" in explicit["args"] and "Alternate" in explicit["args"],
        "shared CLI explicit selector drifted",
    )
    require(explicit["expect"]["exit"] == 0, "shared CLI explicit selector exit drifted")
    require(
        explicit["expect"]["stdout"] == {"text": '"alternate"\n'},
        "shared CLI explicit selector output drifted",
    )

    default_marker = cases.get("success_default_first_authored_marker")
    require(isinstance(default_marker, dict), "shared CLI first-marker default case is missing")
    require("--top-rule" not in default_marker["args"], "first-marker case became explicit")
    default_marker_source = default_marker["args"][1]
    require(
        "Earlier:\n" in default_marker_source
        and "Marked::\n" in default_marker_source
        and "Later::\n" in default_marker_source,
        "shared CLI first-marker topology drifted",
    )
    require(default_marker["expect"]["exit"] == 0, "shared CLI first-marker exit drifted")
    require(
        default_marker["expect"]["stdout"] == {"text": '"marked"\n'},
        "shared CLI first-marker output drifted",
    )
    require(
        default_marker["expect"]["stderr"] == {"text": ""},
        "shared CLI first-marker stderr drifted",
    )

    markerless = cases.get("success_markerless_first_authored_rule")
    require(isinstance(markerless, dict), "shared CLI markerless default case is missing")
    require("--top-rule" not in markerless["args"], "markerless default case became explicit")
    markerless_source = markerless["args"][1]
    require(
        "First:\n" in markerless_source
        and "Second:\n" in markerless_source
        and "::" not in markerless_source,
        "shared CLI markerless topology drifted",
    )
    require(markerless["expect"]["exit"] == 0, "shared CLI markerless exit drifted")
    require(
        markerless["expect"]["stdout"] == {"text": '"first"\n'},
        "shared CLI markerless output drifted",
    )
    require(
        markerless["expect"]["stderr"] == {"text": ""},
        "shared CLI markerless stderr drifted",
    )

    unknown = cases.get("failure_invocation_missing_top_rule")
    require(isinstance(unknown, dict), "shared CLI unknown-selector case is missing")
    require(
        "--top-rule" in unknown["args"] and "Missing" in unknown["args"],
        "shared CLI unknown selector drifted",
    )
    require(unknown["expect"]["exit"] == 1, "shared CLI unknown-selector exit drifted")
    require(
        unknown["expect"]["stderr"]
        == {
            "file": "cases/failure/stderr.txt",
            "variables": {"ERROR": "parser invocation failed"},
        },
        "shared CLI unknown-selector stderr drifted",
    )

    default_trace = cases.get("trace_stdout_medium")
    require(isinstance(default_trace, dict), "shared CLI default request-trace case is missing")
    require("--top-rule" not in default_trace["args"], "default request trace became explicit")
    require(
        default_trace["expect"]["stdout"] == {"file": "cases/trace/medium_stdout.txt"},
        "shared CLI default request trace drifted",
    )

    explicit_trace = cases.get("trace_failure_invoke_escaped_field")
    require(isinstance(explicit_trace, dict), "shared CLI explicit request-trace case is missing")
    require(
        "--top-rule" in explicit_trace["args"] and "Top\nInjected" in explicit_trace["args"],
        "shared CLI explicit request trace drifted",
    )
    require(explicit_trace["expect"]["exit"] == 1, "shared CLI explicit request-trace exit drifted")
    require(
        explicit_trace["expect"]["files"]
        == [
            {
                "path": "trace.log",
                "content": {"file": "cases/trace/failure_invoke_escaped_medium.txt"},
            }
        ],
        "shared CLI explicit request-trace file drifted",
    )


def validate_rust_admission(contract: dict[str, Any], *, check_filesystem: bool) -> None:
    admission = require_fields(
        contract["rust_admission"],
        {"consumer_path", "canonical_driver", "backend_driver", "roles", "primary_case_ids"},
        "Rust admission",
    )
    require(admission == RUST_ADMISSION, "Rust admission topology drifted")
    if not check_filesystem:
        return

    consumer_path = ROOT / admission["consumer_path"]
    canonical_path = ROOT / admission["canonical_driver"]
    backend_path = ROOT / admission["backend_driver"]
    require(
        all(path.is_file() for path in (consumer_path, canonical_path, backend_path)),
        "Rust admission consumer or driver is missing",
    )

    consumer_text = consumer_path.read_text(encoding="utf-8")
    for role in admission["roles"]:
        marker = re.compile(rf"^fn role_{re.escape(role)}\(", re.MULTILINE)
        require(
            len(marker.findall(consumer_text)) == 1,
            f"Rust admission role marker drifted: {role}",
        )

    canonical_text = canonical_path.read_text(encoding="utf-8")
    require(
        f"require_tracked_file {admission['consumer_path']}" in canonical_text,
        "canonical driver omits the Rust admission consumer",
    )
    require(
        f'bash "$REPO_ROOT/{admission["backend_driver"]}"' in canonical_text,
        "canonical driver omits the registered Rust backend driver",
    )
    backend_text = backend_path.read_text(encoding="utf-8")
    require(
        'test --manifest-path rust/Cargo.toml -p linkedspec-runtime' in backend_text,
        "Rust backend driver omits the runtime package containing admission",
    )

    manifest = json.loads((ROOT / "cli_conformance" / "manifest.json").read_text(encoding="utf-8"))
    manifest_ids = {case["id"] for case in manifest["cases"]}
    require(
        set(admission["primary_case_ids"]) <= manifest_ids,
        "Rust admission primary case identity is missing from the shared manifest",
    )


def validate_dart_admission(
    contract: dict[str, Any], *, check_filesystem: bool
) -> None:
    admission = require_fields(
        contract["dart_admission"],
        {
            "consumer_path",
            "canonical_driver",
            "backend_driver",
            "roles",
            "primary_case_ids",
        },
        "Dart admission",
    )
    require(admission == DART_ADMISSION, "Dart admission topology drifted")
    if not check_filesystem:
        return

    consumer_path = ROOT / admission["consumer_path"]
    canonical_path = ROOT / admission["canonical_driver"]
    backend_path = ROOT / admission["backend_driver"]
    require(
        all(path.is_file() for path in (consumer_path, canonical_path, backend_path)),
        "Dart admission consumer or driver is missing",
    )

    consumer_text = consumer_path.read_text(encoding="utf-8")
    source_roles = re.findall(
        r"^void role_([A-Za-z0-9_]+)\(", consumer_text, re.MULTILINE
    )
    require(
        source_roles == admission["roles"],
        "Dart admission source role order or inventory drifted",
    )
    for role in admission["roles"]:
        marker = re.compile(rf"^void role_{re.escape(role)}\(", re.MULTILINE)
        require(
            len(marker.findall(consumer_text)) == 1,
            f"Dart admission role marker drifted: {role}",
        )

    canonical_text = canonical_path.read_text(encoding="utf-8")
    require(
        f"require_tracked_file {admission['consumer_path']}" in canonical_text,
        "canonical driver omits the Dart admission consumer",
    )
    require(
        f'bash "$REPO_ROOT/{admission["backend_driver"]}"' in canonical_text,
        "canonical driver omits the registered Dart backend driver",
    )
    backend_text = backend_path.read_text(encoding="utf-8")
    require(
        '"${DART_RUN[@]}" test' in backend_text,
        "Dart backend driver omits the package containing admission",
    )

    manifest_path = ROOT / "cli_conformance" / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest_ids = {case["id"] for case in manifest["cases"]}
    require(
        set(admission["primary_case_ids"]) <= manifest_ids,
        "Dart admission primary case identity is missing from the shared manifest",
    )


def validate_julia_admission(
    contract: dict[str, Any], *, check_filesystem: bool
) -> None:
    admission = require_fields(
        contract["julia_admission"],
        {
            "consumer_path",
            "canonical_driver",
            "backend_driver",
            "roles",
            "primary_case_ids",
        },
        "Julia admission",
    )
    require(admission == JULIA_ADMISSION, "Julia admission topology drifted")
    if not check_filesystem:
        return

    consumer_path = ROOT / admission["consumer_path"]
    canonical_path = ROOT / admission["canonical_driver"]
    backend_path = ROOT / admission["backend_driver"]
    test_driver_path = ROOT / "julia/test/runtests.jl"
    require(
        all(
            path.is_file()
            for path in (consumer_path, canonical_path, backend_path, test_driver_path)
        ),
        "Julia admission consumer or driver is missing",
    )

    consumer_text = consumer_path.read_text(encoding="utf-8")
    source_roles = re.findall(
        r"^function role_([A-Za-z0-9_]+)\(", consumer_text, re.MULTILINE
    )
    require(
        source_roles == admission["roles"],
        "Julia admission source role order or inventory drifted",
    )
    for role in admission["roles"]:
        marker = re.compile(rf"^function role_{re.escape(role)}\(", re.MULTILINE)
        require(
            len(marker.findall(consumer_text)) == 1,
            f"Julia admission role marker drifted: {role}",
        )

    canonical_text = canonical_path.read_text(encoding="utf-8")
    require(
        f"require_tracked_file {admission['consumer_path']}" in canonical_text,
        "canonical driver omits the Julia admission consumer",
    )
    require(
        f'bash "$REPO_ROOT/{admission["backend_driver"]}"' in canonical_text,
        "canonical driver omits the registered Julia backend driver",
    )
    backend_text = backend_path.read_text(encoding="utf-8")
    require(
        "Pkg.test()" in backend_text,
        "Julia backend driver omits the package containing admission",
    )
    test_driver_text = test_driver_path.read_text(encoding="utf-8")
    require(
        'include("root_rule_selection_admission_test.jl")' in test_driver_text,
        "Julia package test driver omits the admission consumer",
    )

    manifest_path = ROOT / "cli_conformance" / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest_ids = {case["id"] for case in manifest["cases"]}
    require(
        set(admission["primary_case_ids"]) <= manifest_ids,
        "Julia admission primary case identity is missing from the shared manifest",
    )


def validate_lua_admission(
    contract: dict[str, Any], *, check_filesystem: bool
) -> None:
    admission = require_fields(
        contract["lua_admission"],
        {
            "consumer_path",
            "canonical_driver",
            "backend_driver",
            "roles",
            "primary_case_ids",
        },
        "Lua admission",
    )
    require(admission == LUA_ADMISSION, "Lua admission topology drifted")
    if not check_filesystem:
        return

    consumer_path = ROOT / admission["consumer_path"]
    canonical_path = ROOT / admission["canonical_driver"]
    backend_path = ROOT / admission["backend_driver"]
    require(
        all(path.is_file() for path in (consumer_path, canonical_path, backend_path)),
        "Lua admission consumer or driver is missing",
    )

    consumer_text = consumer_path.read_text(encoding="utf-8")
    source_roles = re.findall(
        r"^local function role_([A-Za-z0-9_]+)\(", consumer_text, re.MULTILINE
    )
    require(
        source_roles == admission["roles"],
        "Lua admission source role order or inventory drifted",
    )
    for role in admission["roles"]:
        marker = re.compile(rf"^local function role_{re.escape(role)}\(", re.MULTILINE)
        require(
            len(marker.findall(consumer_text)) == 1,
            f"Lua admission role marker drifted: {role}",
        )

    canonical_text = canonical_path.read_text(encoding="utf-8")
    require(
        f"require_tracked_file {admission['consumer_path']}" in canonical_text,
        "canonical driver omits the Lua admission consumer",
    )
    require(
        f'bash "$REPO_ROOT/{admission["backend_driver"]}"' in canonical_text,
        "canonical driver omits the registered Lua backend driver",
    )
    backend_text = backend_path.read_text(encoding="utf-8")
    require(
        backend_text.count('"$LUA_CMD" lua/test/root_rule_selection_admission_test.lua') == 1,
        "Lua backend driver omits the PUC Lua admission consumer",
    )
    require(
        backend_text.count('"$LUAJIT_CMD" lua/test/root_rule_selection_admission_test.lua') == 1,
        "Lua backend driver omits the LuaJIT admission consumer",
    )

    manifest_path = ROOT / "cli_conformance" / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest_ids = {case["id"] for case in manifest["cases"]}
    require(
        set(admission["primary_case_ids"]) <= manifest_ids,
        "Lua admission primary case identity is missing from the shared manifest",
    )


def validate_recurring_and_public_contract(
    contract: dict[str, Any], *, check_filesystem: bool
) -> None:
    require(contract["recurring_gate"] == RECURRING_GATE, "recurring gate topology drifted")
    require(contract["public_contract"] == PUBLIC_CONTRACT, "public root-selection contract drifted")
    if not check_filesystem:
        return

    gate_path = ROOT / RECURRING_GATE["driver"]
    require(gate_path.is_file(), "recurring root-selection gate driver is missing")
    require(gate_path.stat().st_mode & 0o111, "recurring root-selection gate is not executable")
    gate_text = gate_path.read_text(encoding="utf-8")
    consumer_markers = {
        "perl": "prove -Iperl t/root_rule_selection_perl_core.t t/root_rule_selection_perl_routes.t",
        "rust": "--test root_rule_selection_admission",
        "dart": "test test/root_rule_selection_admission_test.dart",
        "julia": 'include("julia/test/root_rule_selection_admission_test.jl")',
        "puc_lua": '"$LUA_CMD" lua/test/root_rule_selection_admission_test.lua',
        "luajit": '"$LUAJIT_CMD" lua/test/root_rule_selection_admission_test.lua',
    }
    for consumer in RECURRING_GATE["consumers"]:
        for test_path in consumer["test_paths"]:
            require(
                (ROOT / test_path).is_file(),
                f"recurring root-selection consumer is missing: {test_path}",
            )
        require(
            consumer_markers[consumer["runtime"]] in gate_text,
            f"recurring root-selection gate omits consumer: {consumer['runtime']}",
        )

    primary = RECURRING_GATE["primary_cli"]
    require(
        (ROOT / primary["matrix_driver"]).is_file()
        and primary["matrix_driver"] in gate_text,
        "recurring root-selection gate omits the primary matrix driver",
    )
    for case_id in primary["case_ids"]:
        require(
            gate_text.count(f"--case {case_id}") == 1,
            f"recurring root-selection primary case drifted: {case_id}",
        )
    manifest = json.loads((ROOT / "cli_conformance" / "manifest.json").read_text(encoding="utf-8"))
    manifest_ids = [case["id"] for case in manifest["cases"]]
    for case_id in primary["case_ids"]:
        require(
            manifest_ids.count(case_id) == 1,
            f"recurring root-selection primary manifest identity drifted: {case_id}",
        )

    for support_path in RECURRING_GATE["support_checks"]:
        require(
            (ROOT / support_path).is_file() and support_path in gate_text,
            f"recurring root-selection gate omits support check: {support_path}",
        )

    local_ci = RECURRING_GATE["local_ci"]
    local_ci_text = (ROOT / local_ci["driver"]).read_text(encoding="utf-8")
    require(
        RECURRING_GATE["driver"] in local_ci_text
        and local_ci["switch"] in local_ci_text,
        "recurring root-selection local-CI registration drifted",
    )

    for document in PUBLIC_CONTRACT["documents"]:
        public_path = ROOT / document["path"]
        require(public_path.is_file(), f"public root-selection document is missing: {document['path']}")
        public_text = public_path.read_text(encoding="utf-8")
        for marker in document["required_markers"]:
            require(
                marker in public_text,
                f"public root-selection marker is missing from {document['path']}: {marker}",
            )
    for forbidden in PUBLIC_CONTRACT["forbidden_current_claims"]:
        public_text = (ROOT / forbidden["path"]).read_text(encoding="utf-8")
        require(
            forbidden["text"] not in public_text,
            f"stale public root-selection claim remains in {forbidden['path']}: {forbidden['text']}",
        )


def validate_contract(contract: dict[str, Any], *, check_filesystem: bool = True) -> None:
    require_fields(contract, TOP_LEVEL_FIELDS, "contract")
    require(contract["format"] == 1, "format drifted")
    require(contract["contract_id"] == CONTRACT_ID, "contract_id drifted")
    require(contract["task_owner"] == TASK_OWNER, "task_owner drifted")

    terminology = require_fields(
        contract["terminology"],
        {"entry_rule", "authored_marker", "explicit_selector", "top_level"},
        "terminology",
    )
    require(
        all(isinstance(value, str) and value for value in terminology.values()),
        "terminology is incomplete",
    )

    precedence = contract["precedence"]
    require(isinstance(precedence, list) and len(precedence) == 3, "precedence must have three entries")
    require([item.get("id") for item in precedence] == PRECEDENCE, "precedence order drifted")
    for rank, item in enumerate(precedence, start=1):
        require_fields(item, {"rank", "id", "rule"}, f"precedence rank {rank}")
        require(
            item["rank"] == rank
            and isinstance(item["rule"], str)
            and item["rule"],
            f"precedence rank {rank} drifted",
        )

    validation = require_fields(
        contract["validation"],
        {
            "minimum_rule_count",
            "authored_marker_required",
            "definition_order_is_semantic",
            "selection_occurs_after_structural_validation",
            "duplicate_rule_labels",
        },
        "validation",
    )
    require(validation["minimum_rule_count"] == 1, "minimum rule count drifted")
    require(validation["authored_marker_required"] is False, "marker became required")
    require(validation["definition_order_is_semantic"] is True, "definition order became non-semantic")
    require(validation["selection_occurs_after_structural_validation"] is True, "selection order drifted")

    selector = require_fields(
        contract["selector"],
        {
            "native_name",
            "primary_cli_flag",
            "label_matching",
            "may_select_ordinary_rule",
            "may_select_later_marker",
            "unknown_selector",
        },
        "selector",
    )
    require(selector["native_name"] == "top_rule", "native selector name drifted")
    require(selector["primary_cli_flag"] == "--top-rule", "CLI selector drifted")
    require(selector["label_matching"] == "exact declared label", "selector matching drifted")
    require(selector["may_select_ordinary_rule"] is True, "ordinary-rule selection was disabled")
    require(selector["may_select_later_marker"] is True, "later-marker selection was disabled")
    unknown = require_fields(
        selector["unknown_selector"],
        {"code", "stage", "fields", "user_code_evaluated", "primary_cli"},
        "unknown selector",
    )
    require(
        (unknown["code"], unknown["stage"])
        == ("entry_rule_not_found", "select_entry_rule"),
        "unknown-selector diagnostic drifted",
    )
    require(unknown["fields"] == ["entry_rule"], "unknown-selector fields drifted")
    require(unknown["user_code_evaluated"] is False, "unknown selector may evaluate user code")
    require(
        unknown["primary_cli"]
        == {"exit": 1, "stderr_error": "parser invocation failed"},
        "unknown-selector CLI projection drifted",
    )

    identity = require_fields(
        contract["source_identity"],
        {
            "authored_is_top_meaning",
            "selection_rewrites_authored_is_top",
            "multiple_authored_markers_allowed",
            "definition_order_preserved",
            "selected_entry_rule_is_execution_state",
        },
        "source identity",
    )
    require(identity["selection_rewrites_authored_is_top"] is False, "selection rewrites source identity")
    require(identity["multiple_authored_markers_allowed"] is True, "multiple markers became invalid")
    require(identity["definition_order_preserved"] is True, "definition order is not preserved")
    require(
        identity["selected_entry_rule_is_execution_state"] is True,
        "selection ceased to be execution state",
    )

    strict = require_fields(
        contract["strict_unused"],
        {
            "definition",
            "entry_selection_counts_as_reference",
            "selected_entry_rule_is_exempt",
            "authored_marker_counts_as_reference",
            "purpose",
        },
        "strict unused",
    )
    require(
        strict["entry_selection_counts_as_reference"] is False,
        "entry selection became a strict reference",
    )
    require(strict["selected_entry_rule_is_exempt"] is False, "selected entry became strict-exempt")
    require(strict["authored_marker_counts_as_reference"] is False, "marker became a strict reference")

    validate_selection_cases(contract)
    validate_failure_cases(contract)
    validate_strict_cases(contract)

    projections = require_fields(contract["projections"], PROJECTIONS, "projections")
    require(all(isinstance(value, str) and value for value in projections.values()), "projection is empty")
    require(contract["required_execution_routes"] == ROUTES, "execution route order drifted")
    validate_rust_admission(contract, check_filesystem=check_filesystem)
    validate_dart_admission(contract, check_filesystem=check_filesystem)
    validate_julia_admission(contract, check_filesystem=check_filesystem)
    validate_lua_admission(contract, check_filesystem=check_filesystem)
    validate_recurring_and_public_contract(contract, check_filesystem=check_filesystem)

    inventory = contract["implementation_inventory"]
    require(isinstance(inventory, list) and len(inventory) == 5, "implementation inventory count drifted")
    actual_inventory = []
    inventory_fields = {
        "backend",
        "validation",
        "default_selection",
        "explicit_selection",
        "markerless_fallback",
        "generated_selection",
        "descriptor_authored_is_top",
        "owner",
    }
    for item in inventory:
        require_fields(item, inventory_fields, "implementation inventory row")
        actual_inventory.append(
            (
                item["backend"],
                item["validation"],
                item["default_selection"],
                item["explicit_selection"],
                item["markerless_fallback"],
                item["generated_selection"],
                item["descriptor_authored_is_top"],
                item["owner"],
            )
        )
    require(actual_inventory == INVENTORY, "implementation inventory drifted")

    rollout = contract["rollout"]
    require(isinstance(rollout, list), "rollout must be a list")
    actual_rollout = []
    for item in rollout:
        require_fields(item, {"id", "status", "owner"}, "rollout row")
        actual_rollout.append((item["id"], item["status"], item["owner"]))
    require(actual_rollout == ROLLOUT, "rollout drifted")

    if check_filesystem:
        validate_filesystem_contract()


def expect_mutation_failure(
    contract: dict[str, Any], name: str, mutate: Callable[[dict[str, Any]], None]
) -> None:
    candidate = copy.deepcopy(contract)
    mutate(candidate)
    try:
        validate_contract(candidate, check_filesystem=False)
    except ContractError:
        return
    raise ContractError(f"mutation {name!r} was not rejected")


def mutation_checks(contract: dict[str, Any]) -> int:
    mutations: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
        ("format", lambda value: value.__setitem__("format", 2)),
        ("contract id", lambda value: value.__setitem__("contract_id", "drift")),
        ("task owner", lambda value: value.__setitem__("task_owner", "drift")),
        ("precedence order", lambda value: value["precedence"].reverse()),
        ("marker required", lambda value: value["validation"].__setitem__("authored_marker_required", True)),
        (
            "definition order",
            lambda value: value["validation"].__setitem__(
                "definition_order_is_semantic", False
            ),
        ),
        (
            "ordinary explicit selection",
            lambda value: value["selector"].__setitem__(
                "may_select_ordinary_rule", False
            ),
        ),
        (
            "unknown selector code",
            lambda value: value["selector"]["unknown_selector"].__setitem__(
                "code", "unknown"
            ),
        ),
        (
            "authored identity rewrite",
            lambda value: value["source_identity"].__setitem__(
                "selection_rewrites_authored_is_top", True
            ),
        ),
        (
            "multiple markers",
            lambda value: value["source_identity"].__setitem__(
                "multiple_authored_markers_allowed", False
            ),
        ),
        (
            "strict selection reference",
            lambda value: value["strict_unused"].__setitem__(
                "entry_selection_counts_as_reference", True
            ),
        ),
        (
            "strict selection exemption",
            lambda value: value["strict_unused"].__setitem__(
                "selected_entry_rule_is_exempt", True
            ),
        ),
        ("selection case removed", lambda value: value["selection_cases"].pop()),
        (
            "selection expected label",
            lambda value: value["selection_cases"][0].__setitem__(
                "expected_label", "FirstMarked"
            ),
        ),
        (
            "selection expected basis",
            lambda value: value["selection_cases"][2].__setitem__(
                "expected_basis", "first_authored_rule"
            ),
        ),
        ("failure case removed", lambda value: value["failure_cases"].pop()),
        (
            "failure precedence",
            lambda value: value["failure_cases"][2].__setitem__(
                "expected_code", "entry_rule_not_found"
            ),
        ),
        ("strict case expected", lambda value: value["strict_cases"][0]["expected_unused"].pop()),
        ("descriptor projection", lambda value: value["projections"].__setitem__("descriptor", "")),
        ("execution route", lambda value: value["required_execution_routes"].pop()),
        ("backend inventory", lambda value: value["implementation_inventory"].pop()),
        (
            "Perl inventory",
            lambda value: value["implementation_inventory"][0].__setitem__(
                "default_selection", "first_authored_marker"
            ),
        ),
        ("rollout removed", lambda value: value["rollout"].pop()),
        ("regressed Perl rollout", lambda value: value["rollout"][1].__setitem__("status", "pending")),
        ("Rust admission role", lambda value: value["rust_admission"]["roles"].pop()),
        (
            "Rust admission consumer",
            lambda value: value["rust_admission"].__setitem__("consumer_path", "missing"),
        ),
        (
            "Rust admission primary case",
            lambda value: value["rust_admission"]["primary_case_ids"].pop(),
        ),
        (
            "Rust admission canonical driver",
            lambda value: value["rust_admission"].__setitem__("canonical_driver", "missing"),
        ),
        ("regressed Rust rollout", lambda value: value["rollout"][2].__setitem__("status", "pending")),
        ("Dart admission role", lambda value: value["dart_admission"]["roles"].pop()),
        (
            "Dart admission consumer",
            lambda value: value["dart_admission"].__setitem__("consumer_path", "missing"),
        ),
        (
            "Dart admission primary case",
            lambda value: value["dart_admission"]["primary_case_ids"].pop(),
        ),
        (
            "Dart admission canonical driver",
            lambda value: value["dart_admission"].__setitem__("canonical_driver", "missing"),
        ),
        ("regressed Dart rollout", lambda value: value["rollout"][3].__setitem__("status", "pending")),
        ("Julia admission role", lambda value: value["julia_admission"]["roles"].pop()),
        (
            "Julia admission consumer",
            lambda value: value["julia_admission"].__setitem__("consumer_path", "missing"),
        ),
        (
            "Julia admission primary case",
            lambda value: value["julia_admission"]["primary_case_ids"].pop(),
        ),
        (
            "Julia admission canonical driver",
            lambda value: value["julia_admission"].__setitem__("canonical_driver", "missing"),
        ),
        ("regressed Julia rollout", lambda value: value["rollout"][4].__setitem__("status", "pending")),
        ("Lua admission role", lambda value: value["lua_admission"]["roles"].pop()),
        (
            "Lua admission consumer",
            lambda value: value["lua_admission"].__setitem__("consumer_path", "missing"),
        ),
        (
            "Lua admission primary case",
            lambda value: value["lua_admission"]["primary_case_ids"].pop(),
        ),
        (
            "Lua admission canonical driver",
            lambda value: value["lua_admission"].__setitem__("canonical_driver", "missing"),
        ),
        ("regressed Lua rollout", lambda value: value["rollout"][5].__setitem__("status", "pending")),
        ("recurring backend omission", lambda value: value["recurring_gate"]["consumers"].pop()),
        ("recurring role omission", lambda value: value["recurring_gate"]["consumers"][1]["roles"].pop()),
        ("root primary omission", lambda value: value["recurring_gate"]["primary_cli"]["case_ids"].pop()),
        ("support-ledger omission", lambda value: value["recurring_gate"]["support_checks"].pop()),
        (
            "CI registration omission",
            lambda value: value["recurring_gate"]["local_ci"].__setitem__("switch", "wrong_switch"),
        ),
        (
            "recurring driver omission",
            lambda value: value["recurring_gate"].__setitem__("driver", "tools/missing.sh"),
        ),
        ("public document omission", lambda value: value["public_contract"]["documents"].pop()),
        (
            "public marker omission",
            lambda value: value["public_contract"]["documents"][0]["required_markers"].pop(),
        ),
        (
            "forbidden claim omission",
            lambda value: value["public_contract"]["forbidden_current_claims"].pop(),
        ),
        (
            "regressed final rollout",
            lambda value: value["rollout"][6].__setitem__("status", "pending"),
        ),
    ]
    for name, mutate in mutations:
        expect_mutation_failure(contract, name, mutate)
    return len(mutations)


def main() -> int:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(contract)
    mutation_count = mutation_checks(contract)
    complete = sum(item["status"] == "complete" for item in contract["rollout"])
    pending = len(contract["rollout"]) - complete
    print(
        "root-rule-selection-contract: OK "
        f"({len(contract['selection_cases'])} selection cases; "
        f"{len(contract['failure_cases'])} failures; "
        f"{len(contract['strict_cases'])} strict cases; "
        f"{len(contract['implementation_inventory'])} backends; "
        f"{complete} complete / {pending} pending; "
        f"{len(contract['public_contract']['documents'])} public documents; "
        f"{len(contract['public_contract']['forbidden_current_claims'])} forbidden current claims; "
        f"{mutation_count} drift mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

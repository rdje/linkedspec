#!/usr/bin/env python3
"""Validate ADR 0044's backend-neutral rule-local cursor contract."""

from __future__ import annotations

import copy
import json
import os
import re
import subprocess
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "rule_local_cursor_contract.json"
LIFECYCLE_NAMES = ["I", "LS", "LE", "LX", "E", "EX", "IT"]
FAMILY_CURSOR = {"and": "consume", "or_default": "seek"}
GENERATED_SEEK = ["default", "or_acode", "or_bcode", "rep_acode", "rep_bcode"]
GENERATED_CONSUME = [
    "and_single_acode",
    "and_acode_seq",
    "and_bcode",
    "rep_and_acode",
    "rep_and_bcode",
]
DIAGNOSTICS = [
    ("parse_mode_override_removed", "prepare_options", ["option_name"]),
    ("bare_edge_target_undefined", "normalize_edges", ["rule_label", "target"]),
    (
        "bare_edge_index_requires_action",
        "normalize_edges",
        ["rule_label", "target", "regex_index"],
    ),
    ("bare_edge_group_requires_action", "normalize_edges", ["rule_label", "targets"]),
    ("mixed_edge_ownership", "validate_rule", ["rule_label", "ownerships"]),
    (
        "grouped_action_shared_block_required",
        "validate_rule",
        ["rule_label", "targets"],
    ),
    (
        "blind_call_index_forbidden",
        "validate_rule",
        ["rule_label", "target", "regex_index"],
    ),
    (
        "generated_source_contract_version_mismatch",
        "validate_generated_plan",
        ["expected_contract", "actual_contract"],
    ),
]
ROLLOUT = [
    ("neutral_contract_and_inventory", "complete", "FUTURE-PARITY-BACKLOG.9.1.2"),
    ("perl_reference", "complete", "FUTURE-PARITY-BACKLOG.9.1.3"),
    ("rust_parity", "complete", "FUTURE-PARITY-BACKLOG.9.1.4"),
    ("dart_backend", "complete", "FUTURE-PARITY-BACKLOG.9.1.5"),
    ("julia_backend", "complete", "FUTURE-PARITY-BACKLOG.9.1.6"),
    ("lua_dual_abi", "complete", "FUTURE-PARITY-BACKLOG.9.1.7"),
    ("recurring_five_backend_gate", "complete", "FUTURE-PARITY-BACKLOG.9.1.8"),
    ("public_no_drift", "complete", "FUTURE-PARITY-BACKLOG.9.1.9"),
]
PERL_REFERENCE_ADMISSION = {
    "consumer_path": "t/rule_local_cursor_perl_contract.t",
    "canonical_driver": "tools/run_ci_local.sh",
    "roles": [
        "live_default_family",
        "live_and_family",
        "descriptor_v1",
        "emitted_source_v2",
        "generated_direct",
        "generated_trace",
        "loaded_spec",
        "mixed_parent_child",
        "recursion",
        "structural_ordered_landmarks",
        "structural_anchored_choice",
        "dynamic_option_removal",
        "primary_command",
        "portable_diagnostics",
    ],
}
RUST_PARITY_ADMISSION = {
    "consumer_path": "rust/linkedspec-runtime/tests/rule_local_cursor_contract.rs",
    "canonical_driver": "tools/run_ci_local.sh",
    "backend_driver": "tools/run_rust_local.sh",
    "roles": [
        "native_default_family",
        "native_and_family",
        "ordinary_serialized",
        "loaded_spec",
        "descriptor_v1",
        "emitted_source_v2",
        "generated_direct",
        "generated_trace",
        "mixed_parent_child",
        "recursion",
        "structural_ordered_landmarks",
        "structural_anchored_choice",
        "static_option_removal",
        "primary_command",
        "portable_diagnostics",
    ],
}
DART_BACKEND_ADMISSION = {
    "consumer_path": "dart/test/rule_local_cursor_contract_test.dart",
    "canonical_driver": "tools/run_ci_local.sh",
    "backend_driver": "tools/run_dart_local.sh",
    "roles": [
        "native_default_family",
        "native_and_family",
        "ordinary_normalized",
        "loaded_spec",
        "descriptor_v1",
        "emitted_source_v2",
        "generated_direct",
        "generated_trace",
        "mixed_parent_child",
        "recursion",
        "structural_ordered_landmarks",
        "structural_anchored_choice",
        "static_option_removal",
        "primary_command",
        "portable_diagnostics",
    ],
}
JULIA_BACKEND_ADMISSION = {
    "consumer_path": "julia/test/rule_local_cursor_contract_test.jl",
    "canonical_driver": "tools/run_ci_local.sh",
    "backend_driver": "tools/run_julia_local.sh",
    "roles": [
        "native_default_family",
        "native_and_family",
        "ordinary_normalized",
        "loaded_spec",
        "descriptor_v1",
        "emitted_source_v2",
        "generated_direct",
        "generated_trace",
        "mixed_parent_child",
        "recursion",
        "structural_ordered_landmarks",
        "structural_anchored_choice",
        "static_option_removal",
        "primary_command",
        "portable_diagnostics",
    ],
}
LUA_DUAL_ABI_ADMISSION = {
    "consumer_path": "lua/test/rule_local_cursor_contract_test.lua",
    "canonical_driver": "tools/run_ci_local.sh",
    "backend_driver": "tools/run_lua_local.sh",
    "roles": [
        "native_default_family",
        "native_and_family",
        "ordinary_normalized",
        "loaded_spec",
        "descriptor_v1",
        "emitted_source_v2",
        "generated_direct",
        "generated_trace",
        "mixed_parent_child",
        "recursion",
        "structural_ordered_landmarks",
        "structural_anchored_choice",
        "static_option_removal",
        "primary_command",
        "portable_diagnostics",
    ],
}
RECURRING_GATE = {
    "driver": "tools/check_rule_local_cursor_five_backend.sh",
    "consumer_schema": {
        "fields": ["backend", "runtime", "test_path", "roles"],
        "role_policy": "the Perl 14-role consumer and every ordered 15-role backend consumer are required",
    },
    "consumers": [
        {
            "backend": "perl",
            "runtime": "perl",
            "test_path": PERL_REFERENCE_ADMISSION["consumer_path"],
            "roles": PERL_REFERENCE_ADMISSION["roles"],
        },
        {
            "backend": "rust",
            "runtime": "rust",
            "test_path": RUST_PARITY_ADMISSION["consumer_path"],
            "roles": RUST_PARITY_ADMISSION["roles"],
        },
        {
            "backend": "dart",
            "runtime": "dart",
            "test_path": DART_BACKEND_ADMISSION["consumer_path"],
            "roles": DART_BACKEND_ADMISSION["roles"],
        },
        {
            "backend": "julia",
            "runtime": "julia",
            "test_path": JULIA_BACKEND_ADMISSION["consumer_path"],
            "roles": JULIA_BACKEND_ADMISSION["roles"],
        },
        {
            "backend": "lua",
            "runtime": "puc_lua",
            "test_path": LUA_DUAL_ABI_ADMISSION["consumer_path"],
            "roles": LUA_DUAL_ABI_ADMISSION["roles"],
        },
        {
            "backend": "lua",
            "runtime": "luajit",
            "test_path": LUA_DUAL_ABI_ADMISSION["consumer_path"],
            "roles": LUA_DUAL_ABI_ADMISSION["roles"],
        },
    ],
    "primary_cli": {
        "matrix_driver": "tools/run_primary_cli_matrix.sh",
        "case_ids": [
            "help",
            "usage_removed_parse_mode",
            "success_default_rule_seeks",
            "success_and_rule_consumes",
            "trace_stdout_medium",
        ],
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
        "switch": "LINKEDSPEC_RUN_CURSOR_MATRIX",
    },
}
def public_document(path: str, *markers: str) -> dict[str, Any]:
    return {"path": path, "required_markers": list(markers)}


def forbidden_claim(path: str, text: str) -> dict[str, str]:
    return {"path": path, "text": text}


PUBLIC_CONTRACT = {
    "documents": [
        public_document(
            "TOOLBOX.md",
            "cursor policy comes from each authored rule family",
            "former `parse_mode` key is a removal-diagnostic probe only",
        ),
        public_document(
            "USER_GUIDE.md",
            "The former public `parse_mode` / `parseMode` option is removed from every backend",
            "rollout is 8 complete / 0 pending",
        ),
        public_document(
            "capability_conformance/README.md",
            "8 complete / 0 pending",
            "60 semantic, topology, recurring, public, and rollout drift mutations",
        ),
        public_document(
            "cli_conformance/README.md",
            "public no-drift is closed at 8 complete / 0 pending",
            "tools/check_rule_local_cursor_five_backend.sh",
        ),
        public_document(
            "ROADMAP.md",
            "Rule-local cursor rollout is closed at 76 files / 8 complete + 0 pending / 60 mutations",
            "tools/check_rule_local_cursor_five_backend.sh",
        ),
        public_document(
            "ROADMAP_V2.md",
            "Rule-local cursor rollout is closed at 76 files / 8 complete + 0 pending / 60 mutations",
            "selected 5x2x5 recurring and public proof",
        ),
        public_document(
            "ARCHITECTURE_STATE.md",
            "rule-local cursor public no-drift refresh",
            "76 migration files / 8 complete + 0 pending / 60 mutations",
        ),
        public_document(
            "docs/decisions/0067-live-achievement-status-history.md",
            "FUTURE-PARITY-BACKLOG.9.1.9 — close cursor public no-drift",
            "74 migration files / 8 complete + 0 pending / 60 mutations",
        ),
        public_document(
            "docs/TASK_TREE.md",
            "rule-local cursor recurring/public no-drift at 76 files / 8 complete + 0 pending / 60 mutations",
            "Explicit repeated-OR action-result shape `.9.1.10` remains",
        ),
        public_document(
            "docs/decisions/0044-rule-local-cursor-and-mode-sensitive-bare-edges.md",
            "accepted; implemented and public no-drift closed",
            "8 complete / 0 pending",
        ),
        public_document(
            "docs/knowledge/rule-local-cursor-and-bare-edge-contract.md",
            "accepted and public-admitted; rollout 8 complete / 0 pending",
            "60 mutations",
        ),
        public_document(
            "docs/knowledge/rule-local-cursor-five-backend-admission.md",
            "recurring and public admission complete; rollout 8 complete / 0 pending",
            "76 migration files / 8 complete + 0 pending / 60 mutations",
        ),
        public_document(
            "docs/knowledge/rule-local-cursor-neutral-contract.md",
            "backend, recurring, and public rollout admitted at 8 complete / 0 pending",
            "76 migration files / 8 complete + 0 pending / 60 mutations",
        ),
        public_document(
            "docs/knowledge/rule-local-cursor-public-no-drift.md",
            "public no-drift complete; rollout 8 complete / 0 pending",
            "leaves `.9.1`/`.9` active",
        ),
        public_document(
            "docs/linkedspec-book/src/SUMMARY.md",
            "Rule Modes and Cursor Policy",
        ),
        public_document(
            "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "76 migration",
            "8 complete / 0 pending, and 60 rejected mutations",
        ),
        public_document(
            "docs/linkedspec-book/src/appendix/runtime-semantics.md",
            "Public no-drift is closed at 8 complete / 0 pending",
            "## 1. Derived Cursor Policies",
        ),
        public_document(
            "docs/linkedspec-book/src/compiler/pipeline-overview.md",
            "Caller-global cursor options are removed from all engine",
            "Current generated-source v2 retains only ordered",
        ),
        public_document(
            "docs/linkedspec-book/src/development/local-ci-and-regression.md",
            "current cursor ledger is 8 complete / 0 pending",
            "60 rejected drift mutations",
        ),
        public_document(
            "docs/linkedspec-book/src/overview/project-status.md",
            "76 migration files / 8 complete + 0 pending / 60 rejected mutations",
            "tools/check_rule_local_cursor_five_backend.sh",
        ),
        public_document(
            "docs/linkedspec-book/src/public-api/descriptor-introspection.md",
            "cursor no-drift is closed at 8 complete / 0 pending",
            "admitted Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT",
        ),
        public_document(
            "docs/linkedspec-book/src/public-api/get-and-get-parser.md",
            "Public no-drift is closed at 8 complete / 0 pending",
            "Cursor discipline comes from each authored rule",
        ),
        public_document(
            "docs/linkedspec-book/src/public-api/native-spec-loading.md",
            "there is no caller-global cursor override",
            "complete:create_engine({ trace = emitter })",
        ),
        public_document(
            "docs/linkedspec-book/src/user-model/regex-in-spec.md",
            "Rule Modes and Cursor Policy",
            "Derived cursor policies",
        ),
        public_document(
            "docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md",
            "76 migration files, 8 complete / 0 pending",
            "60 rejected mutations",
        ),
        public_document(
            "docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md",
            "Cursor policy comes from each authored rule family",
            "All five backends reject the retired `--parse-mode` flag",
        ),
        public_document(
            "docs/linkedspec-book/src/user-model/spec-files-and-rule-paragraphs.md",
            "Cursor public no-drift is separately closed at 76 migration files, 8 complete / 0 pending",
            "authored family, not a caller option",
        ),
        public_document(
            "docs/linkedspec-book/src/user-model/worked-spec-walkthrough.md",
            "Rule Modes and Cursor Policy",
            "linkedspec-rule-local-cursor-v1",
        ),
        public_document(
            "docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md",
            "All five backends implement this line-level normalization",
            "rollout is closed at 8 complete / 0 pending",
        ),
        public_document(
            "docs/linkedspec-book/src/appendix/formal-grammar.md",
            "All five backends implement this family-derived cursor policy",
            "Bare-edge normalization is complete at 8 complete / 0 pending",
        ),
    ],
    "forbidden_current_claims": [
        forbidden_claim(
            "TOOLBOX.md",
            "(`return_descriptor`, `dump_parser_source`, `parse_mode`, `top_rule`, `runtime_ctx_ref`, …)",
        ),
        forbidden_claim("TOOLBOX.md", 'top_rule=>"Top", parse_mode=>"consume"'),
        forbidden_claim("USER_GUIDE.md", "- `parse_mode => 'seek' | 'consume'`"),
        forbidden_claim(
            "USER_GUIDE.md",
            "`parse_mode` now controls the runtime matching discipline for generated handlers",
        ),
        forbidden_claim("USER_GUIDE.md", "**Ratified target (not current behavior):**"),
        forbidden_claim(
            "USER_GUIDE.md",
            "If `parse_mode` is omitted, LinkedSpec keeps the old behavior and treats it as `seek`.",
        ),
        forbidden_claim(
            "USER_GUIDE.md",
            "File-oriented callers can use the same `parse_mode => 'seek' | 'consume'`",
        ),
        forbidden_claim("capability_conformance/README.md", "rollout is 7 complete / 1 pending"),
        forbidden_claim(
            "capability_conformance/README.md",
            "public no-drift remains dependency-ordered",
        ),
        forbidden_claim(
            "cli_conformance/README.md",
            "ADR `0044`'s future primary-command migration",
        ),
        forbidden_claim("ROADMAP.md", "Public cursor no-drift `.9.1.9` remains next"),
        forbidden_claim("ROADMAP_V2.md", "public cursor no-drift `.9.1.9` remains next"),
        forbidden_claim(
            "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "with top-rule, parse-mode,\nand trace controls",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/appendix/runtime-semantics.md",
            "public no-drift remain dependency-ordered",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/compiler/pipeline-overview.md",
            "An explicit outer `parse_mode` remains temporarily distinguishable",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/compiler/pipeline-overview.md",
            "Lua still retains that staged option until `.9.1.7.5`",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/development/local-ci-and-regression.md",
            "final public no-drift remains separately owned",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/overview/project-status.md",
            "at the current\n72/7+1/56 boundary",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/public-api/descriptor-introspection.md",
            "Lua generated/public\ncursor admission remains separately staged",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/public-api/get-and-get-parser.md",
            "Lua follows in its dependency-ordered rollout leaf",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/public-api/get-and-get-parser.md",
            "Lua is not yet topology-\nadmitted",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/public-api/get-and-get-parser.md",
            "Final recurring/public no-drift is the remaining\ncontract-program closeout",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/public-api/native-spec-loading.md",
            'complete:create_engine({ parse_mode = "seek"',
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md",
            "**Current staged implementation:**",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md",
            "75 migration files, 7 complete / 1 pending",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md",
            "Perl `.9.1.3.1` implements this line-level normalization before\nhandler emission; other backends remain in the dependency-ordered rollout.",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/appendix/formal-grammar.md",
            "Perl and Rust are current through public override\nremoval; remaining backend rollout does not change this authored contract.",
        ),
        forbidden_claim(
            "docs/linkedspec-book/src/appendix/formal-grammar.md",
            "implemented by the Perl\nreference in `.9.1.3.1` and pending in the later backends",
        ),
    ],
}
GROUPS = [
    ("FUTURE-PARITY-BACKLOG.9.1.2", "neutral_contract_and_shared_authority"),
    ("FUTURE-PARITY-BACKLOG.9.1.3", "perl_reference"),
    ("FUTURE-PARITY-BACKLOG.9.1.4", "rust_backend"),
    ("FUTURE-PARITY-BACKLOG.9.1.5", "dart_backend"),
    ("FUTURE-PARITY-BACKLOG.9.1.6", "julia_backend"),
    ("FUTURE-PARITY-BACKLOG.9.1.7", "lua_backend"),
    ("FUTURE-PARITY-BACKLOG.9.1.8", "shared_cli_and_admission"),
    ("FUTURE-PARITY-BACKLOG.9.1.9", "public_no_drift"),
]


class ContractError(ValueError):
    """Stable neutral-contract validation failure."""


def fail(detail: str) -> None:
    raise ContractError(detail)


def require_fields(value: Any, fields: set[str], context: str) -> dict[str, Any]:
    if not isinstance(value, dict) or set(value) != fields:
        fail(f"{context} fields drifted")
    return value


def require_unique_strings(values: Any, context: str) -> list[str]:
    if (
        not isinstance(values, list)
        or not values
        or any(not isinstance(value, str) or not value for value in values)
        or len(set(values)) != len(values)
    ):
        fail(f"{context} must be ordered unique nonempty strings")
    return values


def classify_header(header: str) -> tuple[str, str]:
    match = re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*(::|:)(.*)", header)
    if match is None:
        fail(f"invalid family header {header!r}")
    suffix = match.group(2)
    bounded = r"\{(?:\d+|\d+,\d*|,\d+)\}"
    if suffix == "&" or re.fullmatch(rf"AND(?:\+|{bounded})?", suffix):
        return "and", "consume"
    if suffix in {"", "|", "+", "*", "?"} or re.fullmatch(
        rf"OR(?:\+|{bounded})?", suffix
    ):
        return "or_default", "seek"
    fail(f"unknown family suffix in {header!r}")


def split_edge_block(source: str) -> tuple[str, bool]:
    stripped = source.strip()
    match = re.fullmatch(r"(.+?)\s+\{.*\}", stripped)
    if match is None:
        return stripped, False
    return match.group(1).strip(), True


def parse_target(source: str) -> dict[str, Any]:
    match = re.fullmatch(
        r"([A-Za-z_][A-Za-z0-9_]*)(?:\[(\d+)\])?(?:\.([A-Za-z_][A-Za-z0-9_]*\(.*\)))?",
        source.strip(),
    )
    if match is None:
        fail(f"invalid edge target {source!r}")
    return {
        "label": match.group(1),
        "index": int(match.group(2)) if match.group(2) is not None else None,
        "fluent": match.group(3),
    }


def resolve_edge(parent_family: str, source: str, declared_rules: list[str]) -> dict[str, Any]:
    if parent_family not in FAMILY_CURSOR:
        fail(f"unknown parent family {parent_family!r}")
    core, has_block = split_edge_block(source)
    marker: str | None = None
    if core.startswith("->"):
        marker = "action"
        core = core[2:].strip()
    elif core.startswith("=>"):
        marker = "blind"
        core = core[2:].strip()
    source_form = "explicit" if marker is not None else "bare"
    if marker is None and core in LIFECYCLE_NAMES:
        return {"kind": "lifecycle", "name": core}

    targets = [parse_target(part) for part in re.split(r"\s+\|\s+", core)]
    if source_form == "bare":
        missing = [target["label"] for target in targets if target["label"] not in declared_rules]
        if missing:
            fail("bare_edge_target_undefined")
        if parent_family == "and" and len(targets) > 1:
            fail("bare_edge_group_requires_action")
        if parent_family == "and" and any(target["index"] is not None for target in targets):
            fail("bare_edge_index_requires_action")
        ownership = "blind" if parent_family == "and" else "action"
    else:
        ownership = marker
    if ownership == "blind" and any(target["index"] is not None for target in targets):
        fail("blind_call_index_forbidden")
    if ownership == "blind" and len(targets) > 1:
        fail("bare_edge_group_requires_action")
    if ownership == "action" and len(targets) > 1 and not has_block:
        fail("grouped_action_shared_block_required")
    return {
        "kind": "edge",
        "ownership": ownership,
        "targets": targets,
        "has_block": has_block,
        "source_form": source_form,
    }


def resolve_edge_set(case: dict[str, Any]) -> str:
    ownerships = {
        edge["ownership"]
        for source in case["sources"]
        for edge in [resolve_edge(case["parent_family"], source, case["declared_rules"])]
        if edge["kind"] == "edge"
    }
    if len(ownerships) != 1:
        fail("mixed_edge_ownership")
    return next(iter(ownerships))


def path_in_scan_roots(path: str, roots: list[str]) -> bool:
    for root in roots:
        if path == root or path.startswith(f"{root}/"):
            return True
    return False


def observed_inventory(roots: list[str], patterns: list[str]) -> set[str]:
    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    observed: set[str] = set()
    for path in result.stdout.splitlines():
        if not path_in_scan_roots(path, roots):
            continue
        candidate = ROOT / path
        if not candidate.is_file():
            continue
        try:
            content = candidate.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if any(pattern in content for pattern in patterns):
            observed.add(path)
    return observed


def validate_contract(contract: dict[str, Any], *, check_inventory: bool = True) -> None:
    require_fields(
        contract,
        {
            "format",
            "contract_id",
            "task_owner",
            "policy",
            "family_cases",
            "edge_resolution_cases",
            "rule_edge_set_cases",
            "parent_child_cases",
            "structural_replacements",
            "option_retirement",
            "descriptor_contract",
            "generated_source_v2",
            "perl_reference_admission",
            "rust_parity_admission",
            "dart_backend_admission",
            "julia_backend_admission",
            "lua_dual_abi_admission",
            "recurring_gate",
            "public_contract",
            "diagnostics",
            "migration_inventory",
            "rollout",
        },
        "contract",
    )
    if contract["format"] != 1 or contract["contract_id"] != "linkedspec-rule-local-cursor-v1":
        fail("format or contract id drifted")
    if contract["task_owner"] != "FUTURE-PARITY-BACKLOG.9.1.2":
        fail("task owner drifted")

    policy = require_fields(
        contract["policy"],
        {
            "cursor_authority",
            "and_cursor",
            "or_default_cursor",
            "child_cursor",
            "bare_and",
            "bare_or_default",
            "explicit_edges",
            "normalization_order",
            "mixed_ownership",
            "global_override",
            "cross_combinations",
        },
        "policy",
    )
    if policy["and_cursor"] != "consume" or policy["or_default_cursor"] != "seek":
        fail("cursor policy drifted")
    if "never propagates" not in policy["child_cursor"]:
        fail("child cursor ownership drifted")
    if "removed" not in policy["global_override"]:
        fail("global override removal drifted")

    family_cases = contract["family_cases"]
    if not isinstance(family_cases, list) or len(family_cases) != 36:
        fail("family spelling count drifted")
    family_ids: set[str] = set()
    family_headers: set[str] = set()
    family_counts = {"and": 0, "or_default": 0}
    for case in family_cases:
        require_fields(case, {"id", "header", "family", "cursor_policy"}, "family case")
        if case["id"] in family_ids or case["header"] in family_headers:
            fail("family spelling is duplicated")
        family_ids.add(case["id"])
        family_headers.add(case["header"])
        family, cursor = classify_header(case["header"])
        if (family, cursor) != (case["family"], case["cursor_policy"]):
            fail(f"family derivation drifted for {case['id']}")
        family_counts[family] += 1
    if family_counts != {"and": 14, "or_default": 22}:
        fail("family coverage drifted")

    edge_cases = contract["edge_resolution_cases"]
    if not isinstance(edge_cases, list) or len(edge_cases) != 18:
        fail("edge case count drifted")
    edge_ids: set[str] = set()
    observed_errors: set[str] = set()
    for case in edge_cases:
        fields = {"id", "parent_family", "source", "declared_rules"}
        if set(case) not in (fields | {"expected"}, fields | {"expected_error"}):
            fail("edge case fields drifted")
        if case["id"] in edge_ids:
            fail("edge case id duplicated")
        edge_ids.add(case["id"])
        require_unique_strings(case["declared_rules"], f"{case['id']} declared rules")
        try:
            actual = resolve_edge(case["parent_family"], case["source"], case["declared_rules"])
        except ContractError as error:
            if case.get("expected_error") != str(error):
                fail(f"edge error drifted for {case['id']}: {error}")
            observed_errors.add(str(error))
        else:
            if case.get("expected") != actual:
                fail(f"edge normalization drifted for {case['id']}")
    required_edge_errors = {
        "bare_edge_target_undefined",
        "bare_edge_index_requires_action",
        "bare_edge_group_requires_action",
        "blind_call_index_forbidden",
        "grouped_action_shared_block_required",
    }
    if observed_errors != required_edge_errors:
        fail("edge diagnostic coverage drifted")

    edge_sets = contract["rule_edge_set_cases"]
    if not isinstance(edge_sets, list) or len(edge_sets) != 6:
        fail("rule edge-set coverage drifted")
    for case in edge_sets:
        fields = {"id", "parent_family", "sources", "declared_rules"}
        if set(case) not in (fields | {"expected_ownership"}, fields | {"expected_error"}):
            fail("rule edge-set fields drifted")
        try:
            actual = resolve_edge_set(case)
        except ContractError as error:
            if case.get("expected_error") != str(error):
                fail(f"edge-set error drifted for {case['id']}")
        else:
            if case.get("expected_ownership") != actual:
                fail(f"edge-set ownership drifted for {case['id']}")

    parent_child = contract["parent_child_cases"]
    if not isinstance(parent_child, list) or len(parent_child) != 8:
        fail("parent/child coverage drifted")
    mechanisms: dict[str, int] = {}
    for case in parent_child:
        require_fields(
            case,
            {"id", "parent_family", "child_family", "mechanism", "expected"},
            "parent/child case",
        )
        mechanisms[case["mechanism"]] = mechanisms.get(case["mechanism"], 0) + 1
        expected = {
            "parent_cursor": FAMILY_CURSOR[case["parent_family"]],
            "child_cursor": FAMILY_CURSOR[case["child_family"]],
            "propagates": False,
        }
        if case["expected"] != expected:
            fail(f"parent/child cursor derivation drifted for {case['id']}")
    if mechanisms != {"blind_call": 2, "action_edge": 2, "explicit_call": 2, "recursion": 2}:
        fail("parent/child mechanism coverage drifted")

    replacements = contract["structural_replacements"]
    if not isinstance(replacements, list) or len(replacements) != 2:
        fail("structural replacement count drifted")
    expected_replacements = {
        "ordered_landmarks": ("AND+seek", "and", "or_default", "consume", "seek"),
        "anchored_choice": ("OR+consume", "or_default", "and", "seek", "consume"),
    }
    for case in replacements:
        require_fields(
            case,
            {
                "id",
                "retired_combination",
                "parent_family",
                "child_family",
                "expected_parent_cursor",
                "expected_child_cursor",
            },
            "structural replacement",
        )
        actual = (
            case["retired_combination"],
            case["parent_family"],
            case["child_family"],
            FAMILY_CURSOR[case["parent_family"]],
            FAMILY_CURSOR[case["child_family"]],
        )
        if expected_replacements.get(case["id"]) != actual:
            fail(f"structural replacement drifted for {case['id']}")

    retirement = require_fields(
        contract["option_retirement"],
        {"dynamic_option_names", "error", "cli", "forbidden_compatibility"},
        "option retirement",
    )
    if retirement["dynamic_option_names"] != ["parse_mode", "parseMode"]:
        fail("dynamic option names drifted")
    if retirement["error"] != {
        "code": "parse_mode_override_removed",
        "stage": "prepare_options",
        "fields": {"option_name": "parse_mode"},
    }:
        fail("option removal error drifted")
    if retirement["cli"] != {
        "flag": "--parse-mode",
        "help_present": False,
        "exit": 2,
        "stderr": "--parse-mode has been removed; cursor policy is derived from each rule (OR/default=seek, AND=consume)",
    }:
        fail("CLI removal contract drifted")
    if retirement["forbidden_compatibility"] != [
        "ignored_option",
        "environment_variable",
        "hidden_cli_flag",
        "per_rule_cursor_suffix",
    ]:
        fail("forbidden compatibility policy drifted")

    descriptor = require_fields(
        contract["descriptor_contract"],
        {
            "meta",
            "removed_fields",
            "rule_meta_field",
            "allowed_values",
            "derivation",
            "resolved_edge_fields",
            "optional_provenance",
        },
        "descriptor contract",
    )
    if descriptor != {
        "meta": {"cursor_contract": "linkedspec-rule-local-cursor-v1"},
        "removed_fields": ["meta.parse_mode", "spec.*.meta.parse_mode"],
        "rule_meta_field": "cursor_policy",
        "allowed_values": ["seek", "consume"],
        "derivation": "authored_family_only",
        "resolved_edge_fields": ["ownership", "target", "regex_index", "block", "fluent"],
        "optional_provenance": {"source_form": ["bare", "explicit"], "semantic": False},
    }:
        fail("descriptor contract drifted")

    generated = require_fields(
        contract["generated_source_v2"],
        {
            "contract_id",
            "format_version",
            "plan_row_fields",
            "seek_families",
            "consume_families",
            "serialized_cursor_field",
            "v1_reconstruction_error",
            "legacy_v1_policy",
        },
        "generated source v2",
    )
    if generated != {
        "contract_id": "linkedspec-generated-source-v2",
        "format_version": 2,
        "plan_row_fields": ["label", "family"],
        "seek_families": GENERATED_SEEK,
        "consume_families": GENERATED_CONSUME,
        "serialized_cursor_field": False,
        "v1_reconstruction_error": "generated_source_contract_version_mismatch",
        "legacy_v1_policy": "regenerate_from_spec_source",
    }:
        fail("generated-source v2 contract drifted")

    admission = require_fields(
        contract["perl_reference_admission"],
        {"consumer_path", "canonical_driver", "roles"},
        "Perl reference admission",
    )
    if admission != PERL_REFERENCE_ADMISSION:
        fail("Perl reference admission topology drifted")
    consumer_path = ROOT / admission["consumer_path"]
    driver_path = ROOT / admission["canonical_driver"]
    if not consumer_path.is_file() or not driver_path.is_file():
        fail("Perl reference admission consumer or driver is missing")
    consumer_text = consumer_path.read_text(encoding="utf-8")
    for role in admission["roles"]:
        marker = re.compile(rf"^\s*{re.escape(role)}\s*=>\s*sub\s*\{{", re.MULTILINE)
        if len(marker.findall(consumer_text)) != 1:
            fail(f"Perl reference admission role marker drifted: {role}")
    driver_text = driver_path.read_text(encoding="utf-8")
    canonical_marker = f"prove -Iperl {admission['consumer_path']}"
    if canonical_marker not in driver_text:
        fail("canonical driver omits the Perl reference admission consumer")

    rust_admission = require_fields(
        contract["rust_parity_admission"],
        {"consumer_path", "canonical_driver", "backend_driver", "roles"},
        "Rust parity admission",
    )
    if rust_admission != RUST_PARITY_ADMISSION:
        fail("Rust parity admission topology drifted")
    rust_consumer_path = ROOT / rust_admission["consumer_path"]
    rust_canonical_path = ROOT / rust_admission["canonical_driver"]
    rust_backend_path = ROOT / rust_admission["backend_driver"]
    if not all(
        path.is_file()
        for path in (rust_consumer_path, rust_canonical_path, rust_backend_path)
    ):
        fail("Rust parity admission consumer or driver is missing")
    rust_consumer_text = rust_consumer_path.read_text(encoding="utf-8")
    for role in rust_admission["roles"]:
        marker = re.compile(rf"^fn role_{re.escape(role)}\(", re.MULTILINE)
        if len(marker.findall(rust_consumer_text)) != 1:
            fail(f"Rust parity admission role marker drifted: {role}")
    rust_canonical_text = rust_canonical_path.read_text(encoding="utf-8")
    if f"require_tracked_file {rust_admission['consumer_path']}" not in rust_canonical_text:
        fail("canonical driver omits the Rust parity admission consumer")
    rust_backend_text = rust_backend_path.read_text(encoding="utf-8")
    runtime_package_marker = 'test --manifest-path rust/Cargo.toml -p linkedspec-runtime'
    if runtime_package_marker not in rust_backend_text:
        fail("Rust backend driver omits the runtime package containing cursor admission")
    backend_invocation = f'bash "$REPO_ROOT/{rust_admission["backend_driver"]}"'
    if backend_invocation not in rust_canonical_text:
        fail("canonical driver omits the registered Rust backend driver")

    dart_admission = require_fields(
        contract["dart_backend_admission"],
        {"consumer_path", "canonical_driver", "backend_driver", "roles"},
        "Dart backend admission",
    )
    if dart_admission != DART_BACKEND_ADMISSION:
        fail("Dart backend admission topology drifted")
    dart_consumer_path = ROOT / dart_admission["consumer_path"]
    dart_canonical_path = ROOT / dart_admission["canonical_driver"]
    dart_backend_path = ROOT / dart_admission["backend_driver"]
    if not all(
        path.is_file()
        for path in (dart_consumer_path, dart_canonical_path, dart_backend_path)
    ):
        fail("Dart backend admission consumer or driver is missing")
    dart_consumer_text = dart_consumer_path.read_text(encoding="utf-8")
    for role in dart_admission["roles"]:
        marker = re.compile(rf"^void role_{re.escape(role)}\(", re.MULTILINE)
        if len(marker.findall(dart_consumer_text)) != 1:
            fail(f"Dart backend admission role marker drifted: {role}")
    dart_canonical_text = dart_canonical_path.read_text(encoding="utf-8")
    if f"require_tracked_file {dart_admission['consumer_path']}" not in dart_canonical_text:
        fail("canonical driver omits the Dart backend admission consumer")
    dart_backend_text = dart_backend_path.read_text(encoding="utf-8")
    if '"${DART_RUN[@]}" test' not in dart_backend_text:
        fail("Dart backend driver omits the test suite containing cursor admission")
    backend_invocation = f'bash "$REPO_ROOT/{dart_admission["backend_driver"]}"'
    if backend_invocation not in dart_canonical_text:
        fail("canonical driver omits the registered Dart backend driver")

    julia_admission = require_fields(
        contract["julia_backend_admission"],
        {"consumer_path", "canonical_driver", "backend_driver", "roles"},
        "Julia backend admission",
    )
    if julia_admission != JULIA_BACKEND_ADMISSION:
        fail("Julia backend admission topology drifted")
    julia_consumer_path = ROOT / julia_admission["consumer_path"]
    julia_canonical_path = ROOT / julia_admission["canonical_driver"]
    julia_backend_path = ROOT / julia_admission["backend_driver"]
    julia_test_driver_path = ROOT / "julia/test/runtests.jl"
    if not all(
        path.is_file()
        for path in (
            julia_consumer_path,
            julia_canonical_path,
            julia_backend_path,
            julia_test_driver_path,
        )
    ):
        fail("Julia backend admission consumer or driver is missing")
    julia_consumer_text = julia_consumer_path.read_text(encoding="utf-8")
    for role in julia_admission["roles"]:
        marker = re.compile(rf"^function role_{re.escape(role)}\(", re.MULTILINE)
        if len(marker.findall(julia_consumer_text)) != 1:
            fail(f"Julia backend admission role marker drifted: {role}")
    julia_canonical_text = julia_canonical_path.read_text(encoding="utf-8")
    if f"require_tracked_file {julia_admission['consumer_path']}" not in julia_canonical_text:
        fail("canonical driver omits the Julia backend admission consumer")
    julia_backend_text = julia_backend_path.read_text(encoding="utf-8")
    if "Pkg.test()" not in julia_backend_text:
        fail("Julia backend driver omits the package test suite containing cursor admission")
    julia_test_driver_text = julia_test_driver_path.read_text(encoding="utf-8")
    if 'include("rule_local_cursor_contract_test.jl")' not in julia_test_driver_text:
        fail("Julia package test driver omits the cursor admission consumer")
    backend_invocation = f'bash "$REPO_ROOT/{julia_admission["backend_driver"]}"'
    if backend_invocation not in julia_canonical_text:
        fail("canonical driver omits the registered Julia backend driver")

    lua_admission = require_fields(
        contract["lua_dual_abi_admission"],
        {"consumer_path", "canonical_driver", "backend_driver", "roles"},
        "Lua dual-ABI admission",
    )
    if lua_admission != LUA_DUAL_ABI_ADMISSION:
        fail("Lua dual-ABI admission topology drifted")
    lua_consumer_path = ROOT / lua_admission["consumer_path"]
    lua_canonical_path = ROOT / lua_admission["canonical_driver"]
    lua_backend_path = ROOT / lua_admission["backend_driver"]
    if not all(
        path.is_file()
        for path in (lua_consumer_path, lua_canonical_path, lua_backend_path)
    ):
        fail("Lua dual-ABI admission consumer or driver is missing")
    lua_consumer_text = lua_consumer_path.read_text(encoding="utf-8")
    for role in lua_admission["roles"]:
        marker = re.compile(rf"^local function role_{re.escape(role)}\(", re.MULTILINE)
        if len(marker.findall(lua_consumer_text)) != 1:
            fail(f"Lua dual-ABI admission role marker drifted: {role}")
    lua_canonical_text = lua_canonical_path.read_text(encoding="utf-8")
    if f"require_tracked_file {lua_admission['consumer_path']}" not in lua_canonical_text:
        fail("canonical driver omits the Lua dual-ABI admission consumer")
    lua_backend_text = lua_backend_path.read_text(encoding="utf-8")
    consumer_marker = '"$LUA_CMD" lua/test/rule_local_cursor_contract_test.lua'
    if lua_backend_text.count(consumer_marker) != 1:
        fail("Lua backend driver omits the PUC Lua cursor admission consumer")
    luajit_marker = '"$LUAJIT_CMD" lua/test/rule_local_cursor_contract_test.lua'
    if lua_backend_text.count(luajit_marker) != 1:
        fail("Lua backend driver omits the LuaJIT cursor admission consumer")
    backend_invocation = f'bash "$REPO_ROOT/{lua_admission["backend_driver"]}"'
    if backend_invocation not in lua_canonical_text:
        fail("canonical driver omits the registered Lua backend driver")

    recurring = require_fields(
        contract["recurring_gate"],
        {
            "driver",
            "consumer_schema",
            "consumers",
            "primary_cli",
            "support_checks",
            "local_ci",
        },
        "recurring gate",
    )
    if recurring != RECURRING_GATE:
        fail("recurring gate topology drifted")
    recurring_driver_path = ROOT / recurring["driver"]
    if not recurring_driver_path.is_file():
        fail("recurring gate driver is missing")
    if not os.access(recurring_driver_path, os.X_OK):
        fail("recurring gate driver is not executable")
    recurring_driver_text = recurring_driver_path.read_text(encoding="utf-8")
    required_driver_markers = [
        "bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py",
        "prove -Iperl t/rule_local_cursor_perl_contract.t",
        "--test rule_local_cursor_contract",
        "test test/rule_local_cursor_contract_test.dart",
        "julia/test/rule_local_cursor_contract_test.jl",
    ]
    for marker in required_driver_markers:
        if marker not in recurring_driver_text:
            fail(f"recurring gate driver omits required consumer command: {marker}")
    lua_consumer = LUA_DUAL_ABI_ADMISSION["consumer_path"]
    if recurring_driver_text.count(lua_consumer) != 2:
        fail("recurring gate driver must invoke the Lua cursor consumer exactly twice")
    for marker in ('LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD"', 'LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD"'):
        if marker not in recurring_driver_text:
            fail(f"recurring gate driver omits Lua ABI identity: {marker}")

    primary = recurring["primary_cli"]
    primary_manifest_path = ROOT / "cli_conformance" / "manifest.json"
    if not primary_manifest_path.is_file():
        fail("shared primary manifest is missing")
    primary_manifest = json.loads(primary_manifest_path.read_text(encoding="utf-8"))
    manifest_case_ids = {
        case["id"] for case in primary_manifest.get("cases", []) if isinstance(case, dict) and "id" in case
    }
    if not set(primary["case_ids"]).issubset(manifest_case_ids):
        fail("recurring cursor primary cases are absent from the shared manifest")
    if f'bash {primary["matrix_driver"]}' not in recurring_driver_text:
        fail("recurring gate driver omits the shared primary matrix")
    for case_id in primary["case_ids"]:
        if f"--case {case_id}" not in recurring_driver_text:
            fail(f"recurring gate driver omits primary case: {case_id}")

    for support_path in recurring["support_checks"]:
        if not (ROOT / support_path).is_file():
            fail(f"recurring support check is missing: {support_path}")
        if support_path not in recurring_driver_text:
            fail(f"recurring gate driver omits support check: {support_path}")

    local_ci = recurring["local_ci"]
    local_ci_path = ROOT / local_ci["driver"]
    if not local_ci_path.is_file():
        fail("recurring gate canonical driver is missing")
    local_ci_text = local_ci_path.read_text(encoding="utf-8")
    if f"require_tracked_file {recurring['driver']}" not in local_ci_text:
        fail("canonical driver does not require the recurring cursor gate")
    if local_ci["switch"] not in local_ci_text or f'bash "$REPO_ROOT/{recurring["driver"]}"' not in local_ci_text:
        fail("recurring cursor local-CI registration drifted")

    public = require_fields(
        contract["public_contract"],
        {"documents", "forbidden_current_claims"},
        "public contract",
    )
    if public != PUBLIC_CONTRACT:
        fail("public contract drifted")
    for document in public["documents"]:
        public_path = ROOT / document["path"]
        if not public_path.is_file():
            fail(f"public cursor document is missing: {document['path']}")
        public_text = public_path.read_text(encoding="utf-8")
        for marker in document["required_markers"]:
            if marker not in public_text:
                fail(f"public cursor marker is missing from {document['path']}: {marker}")
    for forbidden in public["forbidden_current_claims"]:
        public_path = ROOT / forbidden["path"]
        if not public_path.is_file():
            fail(f"forbidden-claim document is missing: {forbidden['path']}")
        if forbidden["text"] in public_path.read_text(encoding="utf-8"):
            fail(
                f"stale public cursor claim remains in {forbidden['path']}: "
                f"{forbidden['text']}"
            )

    diagnostics = contract["diagnostics"]
    if not isinstance(diagnostics, list):
        fail("diagnostics must be a list")
    actual_diagnostics = []
    for item in diagnostics:
        require_fields(item, {"code", "stage", "fields"}, "diagnostic")
        actual_diagnostics.append((item["code"], item["stage"], item["fields"]))
    if actual_diagnostics != DIAGNOSTICS:
        fail("diagnostic order or shape drifted")

    inventory = require_fields(
        contract["migration_inventory"],
        {"token_patterns", "scan_roots", "expected_file_count", "groups"},
        "migration inventory",
    )
    if inventory["token_patterns"] != ["parse_mode", "parseMode", "parse-mode"]:
        fail("migration token patterns drifted")
    require_unique_strings(inventory["scan_roots"], "migration scan roots")
    groups = inventory["groups"]
    if not isinstance(groups, list) or len(groups) != len(GROUPS):
        fail("migration group count drifted")
    expected_paths: list[str] = []
    for group, (owner, kind) in zip(groups, GROUPS, strict=True):
        require_fields(group, {"owner", "kind", "action", "paths"}, "migration group")
        if (group["owner"], group["kind"]) != (owner, kind):
            fail("migration dependency order drifted")
        if not isinstance(group["action"], str) or not group["action"]:
            fail("migration action is empty")
        expected_paths.extend(require_unique_strings(group["paths"], f"{kind} paths"))
    if len(set(expected_paths)) != len(expected_paths):
        fail("migration path appears in multiple groups")
    if inventory["expected_file_count"] != len(expected_paths):
        fail("migration inventory count drifted")
    if check_inventory:
        actual_paths = observed_inventory(inventory["scan_roots"], inventory["token_patterns"])
        if actual_paths != set(expected_paths):
            missing = sorted(set(expected_paths) - actual_paths)
            unowned = sorted(actual_paths - set(expected_paths))
            fail(f"migration inventory drifted; missing={missing!r}; unowned={unowned!r}")

    rollout = contract["rollout"]
    if not isinstance(rollout, list):
        fail("rollout must be a list")
    actual_rollout = []
    for item in rollout:
        require_fields(item, {"leg", "status", "owner"}, "rollout leg")
        actual_rollout.append((item["leg"], item["status"], item["owner"]))
    if actual_rollout != ROLLOUT:
        fail("rollout order or status drifted")


def expect_mutation_failure(
    contract: dict[str, Any], name: str, mutate: Callable[[dict[str, Any]], None]
) -> None:
    candidate = copy.deepcopy(contract)
    mutate(candidate)
    try:
        validate_contract(candidate, check_inventory=False)
    except ContractError:
        return
    fail(f"mutation {name!r} was not rejected")


def mutation_checks(contract: dict[str, Any]) -> int:
    mutations: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
        ("format", lambda c: c.__setitem__("format", 2)),
        ("contract_id", lambda c: c.__setitem__("contract_id", "drift")),
        ("task_owner", lambda c: c.__setitem__("task_owner", "drift")),
        ("and_cursor", lambda c: c["policy"].__setitem__("and_cursor", "seek")),
        ("child_propagation", lambda c: c["policy"].__setitem__("child_cursor", "propagates")),
        ("family_case_removed", lambda c: c["family_cases"].pop()),
        ("family_cursor", lambda c: c["family_cases"][0].__setitem__("cursor_policy", "consume")),
        ("edge_case_removed", lambda c: c["edge_resolution_cases"].pop()),
        ("bare_and_ownership", lambda c: c["edge_resolution_cases"][0]["expected"].__setitem__("ownership", "action")),
        ("edge_error", lambda c: c["edge_resolution_cases"][13].__setitem__("expected_error", "wrong")),
        ("mixed_ownership", lambda c: c["rule_edge_set_cases"][4].__setitem__("expected_error", "wrong")),
        ("parent_child", lambda c: c["parent_child_cases"][0]["expected"].__setitem__("child_cursor", "consume")),
        ("structural_replacement", lambda c: c["structural_replacements"][0].__setitem__("child_family", "and")),
        ("dynamic_option", lambda c: c["option_retirement"]["dynamic_option_names"].pop()),
        ("cli_message", lambda c: c["option_retirement"]["cli"].__setitem__("stderr", "removed")),
        ("descriptor_meta", lambda c: c["descriptor_contract"]["meta"].__setitem__("cursor_contract", "drift")),
        ("descriptor_removed", lambda c: c["descriptor_contract"]["removed_fields"].pop()),
        ("generated_id", lambda c: c["generated_source_v2"].__setitem__("contract_id", "linkedspec-generated-source-v1")),
        ("generated_family", lambda c: c["generated_source_v2"]["seek_families"].pop()),
        ("Perl admission role", lambda c: c["perl_reference_admission"]["roles"].pop()),
        ("Perl admission consumer", lambda c: c["perl_reference_admission"].__setitem__("consumer_path", "missing")),
        ("Rust admission role", lambda c: c["rust_parity_admission"]["roles"].pop()),
        ("Rust admission consumer", lambda c: c["rust_parity_admission"].__setitem__("consumer_path", "missing")),
        ("Rust admission canonical driver", lambda c: c["rust_parity_admission"].__setitem__("canonical_driver", "missing")),
        ("Rust admission driver", lambda c: c["rust_parity_admission"].__setitem__("backend_driver", "missing")),
        ("Dart admission role", lambda c: c["dart_backend_admission"]["roles"].pop()),
        ("Dart admission consumer", lambda c: c["dart_backend_admission"].__setitem__("consumer_path", "missing")),
        ("Dart admission canonical driver", lambda c: c["dart_backend_admission"].__setitem__("canonical_driver", "missing")),
        ("Dart admission driver", lambda c: c["dart_backend_admission"].__setitem__("backend_driver", "missing")),
        ("Julia admission role", lambda c: c["julia_backend_admission"]["roles"].pop()),
        ("Julia admission consumer", lambda c: c["julia_backend_admission"].__setitem__("consumer_path", "missing")),
        ("Julia admission canonical driver", lambda c: c["julia_backend_admission"].__setitem__("canonical_driver", "missing")),
        ("Julia admission driver", lambda c: c["julia_backend_admission"].__setitem__("backend_driver", "missing")),
        ("Lua admission role", lambda c: c["lua_dual_abi_admission"]["roles"].pop()),
        ("Lua admission consumer", lambda c: c["lua_dual_abi_admission"].__setitem__("consumer_path", "missing")),
        ("Lua admission canonical driver", lambda c: c["lua_dual_abi_admission"].__setitem__("canonical_driver", "missing")),
        ("Lua admission driver", lambda c: c["lua_dual_abi_admission"].__setitem__("backend_driver", "missing")),
        ("recurring backend omission", lambda c: c["recurring_gate"]["consumers"].pop()),
        ("recurring role omission", lambda c: c["recurring_gate"]["consumers"][0]["roles"].pop()),
        ("recurring primary omission", lambda c: c["recurring_gate"]["primary_cli"]["case_ids"].pop()),
        ("recurring support omission", lambda c: c["recurring_gate"]["support_checks"].pop()),
        ("recurring CI omission", lambda c: c["recurring_gate"]["local_ci"].__setitem__("switch", "wrong")),
        ("recurring driver omission", lambda c: c["recurring_gate"].__setitem__("driver", "missing")),
        ("recurring rollout admission", lambda c: c["rollout"][6].__setitem__("status", "pending")),
        ("public document omission", lambda c: c["public_contract"]["documents"].pop()),
        ("public marker omission", lambda c: c["public_contract"]["documents"][0]["required_markers"].pop()),
        ("forbidden current claim omission", lambda c: c["public_contract"]["forbidden_current_claims"].pop()),
        ("public rollout admission", lambda c: c["rollout"][7].__setitem__("status", "pending")),
        ("diagnostic_removed", lambda c: c["diagnostics"].pop()),
        ("diagnostic_stage", lambda c: c["diagnostics"][0].__setitem__("stage", "execute")),
        ("inventory_pattern", lambda c: c["migration_inventory"]["token_patterns"].pop()),
        ("inventory_count", lambda c: c["migration_inventory"].__setitem__("expected_file_count", 0)),
        ("inventory_path", lambda c: c["migration_inventory"]["groups"][0]["paths"].pop()),
        ("inventory_owner", lambda c: c["migration_inventory"]["groups"][1].__setitem__("owner", "wrong")),
        ("rollout_removed", lambda c: c["rollout"].pop()),
        ("rollout_admission", lambda c: c["rollout"][1].__setitem__("status", "pending")),
        ("Rust rollout admission", lambda c: c["rollout"][2].__setitem__("status", "pending")),
        ("Dart rollout admission", lambda c: c["rollout"][3].__setitem__("status", "pending")),
        ("Julia rollout admission", lambda c: c["rollout"][4].__setitem__("status", "pending")),
        ("Lua rollout admission", lambda c: c["rollout"][5].__setitem__("status", "pending")),
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
        "rule-local-cursor-contract: OK "
        f"({len(contract['family_cases'])} family spellings; "
        f"{len(contract['edge_resolution_cases'])} edge cases; "
        f"{len(contract['parent_child_cases'])} parent/child cases; "
        f"{len(contract['perl_reference_admission']['roles'])} Perl admission roles; "
        f"{len(contract['rust_parity_admission']['roles'])} Rust admission roles; "
        f"{len(contract['dart_backend_admission']['roles'])} Dart admission roles; "
        f"{len(contract['julia_backend_admission']['roles'])} Julia admission roles; "
        f"{len(contract['lua_dual_abi_admission']['roles'])} Lua admission roles; "
        f"{len(contract['recurring_gate']['consumers'])} recurring runtime legs; "
        f"{len(contract['public_contract']['documents'])} public documents; "
        f"{len(contract['public_contract']['forbidden_current_claims'])} forbidden current claims; "
        f"{contract['migration_inventory']['expected_file_count']} migration files; "
        f"{complete} complete / {pending} pending; {mutation_count} drift mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

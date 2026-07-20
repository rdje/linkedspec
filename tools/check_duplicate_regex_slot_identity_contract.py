#!/usr/bin/env python3
"""Validate ADR 0047's neutral duplicate-regex slot identity contract."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = (
    ROOT / "capability_conformance" / "duplicate_regex_slot_identity_contract.json"
)
CONTRACT_ID = "linkedspec-duplicate-regex-slot-identity-v1"
TASK_OWNER = "FUTURE-PARITY-BACKLOG.9.1.8.1"
TOP_LEVEL_FIELDS = {
    "format",
    "contract_id",
    "task_owner",
    "terminology",
    "identity",
    "selection",
    "fixtures",
    "diagnostics",
    "descriptor_contract",
    "generated_source_v2",
    "trace_contract",
    "perl_admission",
    "rust_admission",
    "dart_admission",
    "julia_admission",
    "implementation_inventory",
    "migration",
    "rollout",
    "canonical_ci",
}
FIXTURE_FIELDS = {
    "id",
    "role",
    "source",
    "input",
    "cursor_policy",
    "repeat_count",
    "slots",
    "required_sequence",
    "expected_match_identities",
    "expected_result",
}
FIXTURE_IDS = [
    "ordered_same_rule_duplicate",
    "choice_same_rule_duplicate",
    "repeated_ordered_duplicate",
    "repeated_non_duplicate_control",
    "ordered_cross_target_duplicate",
]
EXPECTED_RESULTS: dict[str, Any] = {
    "ordered_same_rule_duplicate": "ordered-ok",
    "choice_same_rule_duplicate": "first",
    "repeated_ordered_duplicate": [["a", "a"], ["a", "a"]],
    "repeated_non_duplicate_control": [["a", "b"], ["a", "b"]],
    "ordered_cross_target_duplicate": "cross-target-ok",
}
DIAGNOSTICS = [
    (
        "regex_slot_identity_invalid",
        "validate_compiled_rule",
        ["rule_label", "target_rule", "regex_index"],
    ),
    (
        "ordered_regex_slot_identity_lost",
        "execute_rule",
        [
            "rule_label",
            "target_rule",
            "expected_regex_index",
            "actual_regex_index",
        ],
    ),
]
INVENTORY = [
    (
        "perl",
        "perl",
        "match_required_slot_directly",
        "implemented",
        "first_authored",
        "preserved",
        "FUTURE-PARITY-BACKLOG.9.1.8.1.2",
    ),
    (
        "rust",
        "rust",
        "match_required_slot_directly",
        "implemented",
        "first_authored",
        "preserved",
        "FUTURE-PARITY-BACKLOG.9.1.8.1.3",
    ),
    (
        "dart",
        "dart",
        "match_required_slot_directly",
        "implemented",
        "first_authored",
        "preserved",
        "FUTURE-PARITY-BACKLOG.9.1.8.1.4",
    ),
    (
        "julia",
        "julia",
        "match_required_slot_directly",
        "implemented",
        "first_authored",
        "preserved",
        "FUTURE-PARITY-BACKLOG.9.1.8.1.5",
    ),
    (
        "lua",
        "puc_lua",
        "match_required_pattern_then_reindex",
        "behavior_matches",
        "first_authored",
        "preserved",
        "FUTURE-PARITY-BACKLOG.9.1.8.1.6",
    ),
    (
        "lua",
        "luajit",
        "match_required_pattern_then_reindex",
        "behavior_matches",
        "first_authored",
        "preserved",
        "FUTURE-PARITY-BACKLOG.9.1.8.1.6",
    ),
]
ROLLOUT = [
    ("neutral_contract", "complete", "FUTURE-PARITY-BACKLOG.9.1.8.1.1"),
    ("perl_reference", "complete", "FUTURE-PARITY-BACKLOG.9.1.8.1.2"),
    ("rust", "complete", "FUTURE-PARITY-BACKLOG.9.1.8.1.3"),
    ("dart", "complete", "FUTURE-PARITY-BACKLOG.9.1.8.1.4"),
    ("julia", "complete", "FUTURE-PARITY-BACKLOG.9.1.8.1.5"),
    ("lua_dual_abi", "pending", "FUTURE-PARITY-BACKLOG.9.1.8.1.6"),
    (
        "recurring_and_public_no_drift",
        "pending",
        "FUTURE-PARITY-BACKLOG.9.1.8.1.7",
    ),
]
MIGRATION = {
    "decision": "docs/decisions/0047-duplicate-regex-slot-identity.md",
    "checker": "tools/check_duplicate_regex_slot_identity_contract.py",
    "perl_consumer": "t/duplicate_regex_slot_identity_perl_contract.t",
    "rust_consumer": "rust/linkedspec-runtime/tests/duplicate_regex_slot_identity_contract.rs",
    "dart_consumer": "dart/test/duplicate_regex_slot_identity_contract_test.dart",
    "julia_consumer": "julia/test/duplicate_regex_slot_identity_contract_test.jl",
    "lua_consumer": "lua/test/duplicate_regex_slot_identity_contract_test.lua",
    "recurring_driver": "tools/check_duplicate_regex_slot_identity_five_backend.sh",
}
PERL_ADMISSION = {
    "consumer": MIGRATION["perl_consumer"],
    "canonical_driver": "tools/run_ci_local.sh",
    "ordered_mechanism": "match_required_slot_directly",
    "generated_slot_payload": "dependency_slot_map",
    "roles": [
        "neutral_fixtures",
        "live_ordered",
        "live_choice",
        "repeated_ordered",
        "repeated_control",
        "cross_target",
        "loaded",
        "descriptor",
        "emitted_source",
        "generated_direct",
        "generated_trace",
        "invalid_identity_diagnostics",
    ],
}
RUST_ADMISSION = {
    "consumer": MIGRATION["rust_consumer"],
    "canonical_driver": "tools/run_rust_local.sh",
    "ordered_mechanism": "match_required_slot_directly",
    "generated_slot_payload": "serialized_compiled_rule",
    "roles": [
        "neutral_fixtures",
        "native_ordered",
        "native_choice",
        "repeated_ordered",
        "repeated_control",
        "cross_target",
        "loaded",
        "reconstructed",
        "descriptor",
        "emitted_source",
        "generated_direct",
        "native_trace",
        "generated_trace",
        "primary_command",
        "invalid_identity_diagnostics",
    ],
}
DART_ADMISSION = {
    "consumer": MIGRATION["dart_consumer"],
    "canonical_driver": "tools/run_dart_local.sh",
    "ordered_mechanism": "match_required_slot_directly",
    "generated_slot_payload": "normalized_spec_file_json",
    "roles": [
        "neutral_fixtures",
        "native_ordered",
        "native_choice",
        "repeated_ordered",
        "repeated_control",
        "cross_target",
        "loaded",
        "reconstructed",
        "descriptor",
        "emitted_source",
        "generated_direct",
        "native_trace",
        "generated_trace",
        "primary_command",
        "invalid_identity_diagnostics",
    ],
}
JULIA_ADMISSION = {
    "consumer": MIGRATION["julia_consumer"],
    "canonical_driver": "tools/run_julia_local.sh",
    "ordered_mechanism": "match_required_slot_directly",
    "generated_slot_payload": "normalized_spec_file_json",
    "roles": [
        "neutral_fixtures",
        "native_ordered",
        "native_choice",
        "repeated_ordered",
        "repeated_control",
        "cross_target",
        "loaded",
        "reconstructed",
        "descriptor",
        "emitted_source",
        "generated_direct",
        "native_trace",
        "generated_trace",
        "primary_command",
        "invalid_identity_diagnostics",
    ],
}


class ContractError(ValueError):
    """Stable neutral-contract validation failure."""


def fail(detail: str) -> None:
    raise ContractError(detail)


def require(condition: bool, detail: str) -> None:
    if not condition:
        fail(detail)


def require_fields(value: Any, fields: set[str], context: str) -> dict[str, Any]:
    if not isinstance(value, dict) or set(value) != fields:
        fail(f"{context} fields drifted")
    return value


def slot_identity(slot: dict[str, Any]) -> str:
    return f"{slot['target_rule']}#{slot['regex_index']}"


def validate_slots(value: Any, context: str) -> list[dict[str, Any]]:
    require(isinstance(value, list) and value, f"{context} slots must be non-empty")
    slots: list[dict[str, Any]] = []
    identities: set[str] = set()
    orders: set[int] = set()
    for index, raw_slot in enumerate(value):
        slot = require_fields(
            raw_slot,
            {"target_rule", "regex_index", "authored_order", "pattern"},
            f"{context} slot {index}",
        )
        require(
            isinstance(slot["target_rule"], str) and slot["target_rule"],
            f"{context} target rule is invalid",
        )
        require(
            isinstance(slot["regex_index"], int) and slot["regex_index"] >= 0,
            f"{context} regex index is invalid",
        )
        require(
            isinstance(slot["authored_order"], int) and slot["authored_order"] >= 0,
            f"{context} authored order is invalid",
        )
        require(isinstance(slot["pattern"], str), f"{context} pattern is invalid")
        try:
            re.compile(slot["pattern"])
        except re.error as exc:
            fail(f"{context} pattern does not compile: {exc}")
        identity = slot_identity(slot)
        require(identity not in identities, f"{context} repeats structural identity")
        require(
            slot["authored_order"] not in orders,
            f"{context} repeats authored order",
        )
        identities.add(identity)
        orders.add(slot["authored_order"])
        slots.append(slot)
    require(orders == set(range(len(slots))), f"{context} authored order drifted")
    return slots


def match_slot(
    slot: dict[str, Any], text: str, cursor: int, cursor_policy: str
) -> re.Match[str] | None:
    pattern = re.compile(slot["pattern"])
    if cursor_policy == "consume":
        return pattern.match(text, cursor)
    if cursor_policy == "seek":
        return pattern.search(text, cursor)
    fail(f"unknown cursor policy: {cursor_policy}")


def evaluate_fixture(fixture: dict[str, Any], slots: list[dict[str, Any]]) -> list[str]:
    cursor = 0
    identities: list[str] = []
    by_identity = {slot_identity(slot): slot for slot in slots}
    if fixture["role"] == "ordered":
        sequence = fixture["required_sequence"]
        require(sequence, f"{fixture['id']} ordered sequence is empty")
        for _ in range(fixture["repeat_count"]):
            for required_identity in sequence:
                require(
                    required_identity in by_identity,
                    f"{fixture['id']} requires an unknown slot",
                )
                slot = by_identity[required_identity]
                match = match_slot(
                    slot, fixture["input"], cursor, fixture["cursor_policy"]
                )
                require(match is not None, f"{fixture['id']} required slot did not match")
                identities.append(slot_identity(slot))
                cursor = match.end()
    elif fixture["role"] == "choice":
        require(
            fixture["required_sequence"] == [],
            f"{fixture['id']} choice has a required sequence",
        )
        candidates: list[tuple[int, int, re.Match[str], dict[str, Any]]] = []
        for slot in slots:
            match = match_slot(
                slot, fixture["input"], cursor, fixture["cursor_policy"]
            )
            if match is not None:
                candidates.append(
                    (match.start(), slot["authored_order"], match, slot)
                )
        require(candidates, f"{fixture['id']} choice has no match")
        _, _, match, selected = min(candidates, key=lambda item: (item[0], item[1]))
        identities.append(slot_identity(selected))
        cursor = match.end()
    else:
        fail(f"{fixture['id']} role drifted")
    require(cursor <= len(fixture["input"]), f"{fixture['id']} cursor escaped input")
    return identities


def validate_fixtures(contract: dict[str, Any]) -> None:
    fixtures = contract["fixtures"]
    require(isinstance(fixtures, list), "fixtures must be an array")
    require(
        [fixture.get("id") for fixture in fixtures] == FIXTURE_IDS,
        "fixture identity or order drifted",
    )
    for fixture in fixtures:
        require_fields(fixture, FIXTURE_FIELDS, f"fixture {fixture.get('id')}")
        fixture_id = fixture["id"]
        require(
            fixture["role"] in {"ordered", "choice"},
            f"{fixture_id} role drifted",
        )
        require(
            fixture["cursor_policy"] in {"consume", "seek"},
            f"{fixture_id} cursor policy drifted",
        )
        require(
            isinstance(fixture["repeat_count"], int)
            and fixture["repeat_count"] >= 1,
            f"{fixture_id} repeat count drifted",
        )
        require(
            isinstance(fixture["source"], str)
            and fixture["source"].endswith("\n"),
            f"{fixture_id} source bytes drifted",
        )
        require(isinstance(fixture["input"], str), f"{fixture_id} input drifted")
        slots = validate_slots(fixture["slots"], fixture_id)
        actual_identities = evaluate_fixture(fixture, slots)
        require(
            actual_identities == fixture["expected_match_identities"],
            f"{fixture_id} model result drifted",
        )
        require(
            fixture["expected_result"] == EXPECTED_RESULTS[fixture_id],
            f"{fixture_id} expected runtime result drifted",
        )


def validate_contract(contract: dict[str, Any], *, check_filesystem: bool = True) -> None:
    require_fields(contract, TOP_LEVEL_FIELDS, "contract")
    require(contract["format"] == 1, "format drifted")
    require(contract["contract_id"] == CONTRACT_ID, "contract id drifted")
    require(contract["task_owner"] == TASK_OWNER, "task owner drifted")

    require_fields(
        contract["terminology"],
        {
            "structural_slot",
            "ordered_selection",
            "choice_selection",
            "duplicate_pattern",
        },
        "terminology",
    )
    identity = require_fields(
        contract["identity"],
        {
            "duplicate_pattern_text_is_legal",
            "required_fields",
            "future_optional_field",
            "numeric_and_named_selectors_resolve_to_same_identity",
            "identity_recovery_forbidden",
            "preserved_across",
        },
        "identity",
    )
    require(identity["duplicate_pattern_text_is_legal"] is True, "duplicates became illegal")
    require(
        identity["required_fields"] == ["target_rule", "regex_index"],
        "structural identity fields drifted",
    )
    require(identity["future_optional_field"] == "target_slot_id", "named slot seam drifted")
    require(
        identity["numeric_and_named_selectors_resolve_to_same_identity"] is True,
        "numeric/name identity convergence drifted",
    )
    require(
        identity["identity_recovery_forbidden"]
        == ["regex_text", "source_adjacency", "capture_text", "alternation_branch_guess"],
        "forbidden identity recovery drifted",
    )
    require(
        identity["preserved_across"]
        == ["compiled_rule", "descriptor", "loaded", "reconstructed", "generated_source_v2", "trace"],
        "identity projection inventory drifted",
    )

    selection = require_fields(contract["selection"], {"ordered", "choice"}, "selection")
    ordered = require_fields(
        selection["ordered"],
        {"algorithm", "cursor_policy", "mismatch_policy", "repetition"},
        "ordered selection",
    )
    require(
        ordered["algorithm"]
        == "match_only_the_required_structural_slot_and_report_that_same_identity",
        "ordered algorithm drifted",
    )
    require(
        ordered["repetition"]
        == "reset to the first required sequence slot for each accepted iteration",
        "ordered repetition drifted",
    )
    choice = require_fields(
        selection["choice"],
        {"algorithm", "primary_priority", "tie_break", "duplicate_tie_result"},
        "choice selection",
    )
    require(choice["algorithm"] == "evaluate_every_eligible_structural_slot", "choice algorithm drifted")
    require(choice["primary_priority"] == "earliest_match_start", "choice priority drifted")
    require(choice["tie_break"] == "lowest_authored_order", "choice tie break drifted")
    require(choice["duplicate_tie_result"] == "first_authored_slot", "duplicate choice drifted")

    validate_fixtures(contract)

    diagnostics = contract["diagnostics"]
    require(isinstance(diagnostics, list), "diagnostics must be an array")
    require(
        [(row.get("code"), row.get("stage"), row.get("fields")) for row in diagnostics]
        == DIAGNOSTICS,
        "diagnostic identity drifted",
    )
    for row in diagnostics:
        require_fields(row, {"code", "stage", "fields", "meaning"}, f"diagnostic {row.get('code')}")
        require(isinstance(row["meaning"], str) and row["meaning"], "diagnostic meaning is empty")

    require(
        contract["descriptor_contract"]
        == {
            "meta_field": "regex_slot_identity_contract",
            "meta_value": CONTRACT_ID,
            "edge_identity_fields": ["target", "regex_index"],
            "future_optional_edge_field": "target_slot_id",
            "duplicate_patterns_remain_distinct_rows": True,
        },
        "descriptor contract drifted",
    )
    require(
        contract["generated_source_v2"]
        == {
            "contract_id": "linkedspec-generated-source-v2",
            "format_version": 2,
            "plan_row_fields": ["label", "family"],
            "plan_format_bump_required": False,
            "identity_owner": "embedded_or_reconstructed_compiled_rule",
            "execution_requirement": "preserve structural slot identity through native and generated-plan matching",
        },
        "generated-source v2 contract drifted",
    )
    require(
        contract["trace_contract"]
        == {
            "event": "regex_slot_selected",
            "fields": ["rule_label", "selection_role", "target_rule", "regex_index"],
            "selection_role_values": ["ordered_required", "choice"],
            "identity_source": "compiled_structural_slot",
        },
        "trace contract drifted",
    )
    require(contract["perl_admission"] == PERL_ADMISSION, "Perl admission drifted")
    require(contract["rust_admission"] == RUST_ADMISSION, "Rust admission drifted")
    require(contract["dart_admission"] == DART_ADMISSION, "Dart admission drifted")
    require(contract["julia_admission"] == JULIA_ADMISSION, "Julia admission drifted")

    inventory = contract["implementation_inventory"]
    require(isinstance(inventory, list), "implementation inventory must be an array")
    require(
        [
            (
                row.get("backend"),
                row.get("runtime"),
                row.get("ordered_mechanism"),
                row.get("ordered_status"),
                row.get("choice_tie"),
                row.get("identity_artifacts"),
                row.get("owner"),
            )
            for row in inventory
        ]
        == INVENTORY,
        "implementation inventory drifted",
    )
    for row in inventory:
        require_fields(
            row,
            {
                "backend",
                "runtime",
                "ordered_mechanism",
                "ordered_status",
                "choice_tie",
                "identity_artifacts",
                "owner",
            },
            f"inventory {row.get('runtime')}",
        )

    require(contract["migration"] == MIGRATION, "migration inventory drifted")
    rollout = contract["rollout"]
    require(isinstance(rollout, list), "rollout must be an array")
    require(
        [(row.get("capability"), row.get("status"), row.get("owner")) for row in rollout]
        == ROLLOUT,
        "rollout drifted",
    )
    for row in rollout:
        require_fields(row, {"capability", "status", "owner"}, f"rollout {row.get('capability')}")
    require(
        contract["canonical_ci"]
        == {
            "driver": "tools/run_ci_local.sh",
            "mode": "unconditional_neutral_checker",
            "backend_execution": "dependency_ordered_by_rollout",
        },
        "canonical CI contract drifted",
    )

    if check_filesystem:
        validate_filesystem_contract()


def validate_filesystem_contract() -> None:
    required_paths = [
        CONTRACT_PATH,
        ROOT / MIGRATION["decision"],
        ROOT / MIGRATION["checker"],
        ROOT / "docs" / "knowledge" / "duplicate-regex-slot-identity-contract.md",
        ROOT / PERL_ADMISSION["consumer"],
        ROOT / RUST_ADMISSION["consumer"],
        ROOT / DART_ADMISSION["consumer"],
        ROOT / JULIA_ADMISSION["consumer"],
    ]
    require(all(path.is_file() for path in required_paths), "neutral contract file is missing")
    index_text = (ROOT / "docs" / "decisions" / "INDEX.md").read_text(encoding="utf-8")
    require(
        "[0047](0047-duplicate-regex-slot-identity.md)" in index_text,
        "decision index omits ADR 0047",
    )
    capability_text = (ROOT / "capability_conformance" / "README.md").read_text(encoding="utf-8")
    require(CONTRACT_ID in capability_text, "capability README omits duplicate-slot contract")
    task_text = (ROOT / "docs" / "tasks" / "FUTURE-PARITY-BACKLOG.md").read_text(encoding="utf-8")
    require(
        "FUTURE-PARITY-BACKLOG.9.1.8.1.1" in task_text
        and "RATIFY PORTABLE IDENTITY" in task_text,
        "task tree omits neutral duplicate-slot acceptance",
    )
    ci_text = (ROOT / "tools" / "run_ci_local.sh").read_text(encoding="utf-8")
    require(
        "require_tracked_file capability_conformance/duplicate_regex_slot_identity_contract.json" in ci_text,
        "canonical CI omits contract tracked input",
    )
    require(
        "require_tracked_file tools/check_duplicate_regex_slot_identity_contract.py" in ci_text,
        "canonical CI omits checker tracked input",
    )
    require(
        f"require_tracked_file {PERL_ADMISSION['consumer']}" in ci_text,
        "canonical CI omits Perl consumer tracked input",
    )
    require(
        f"require_tracked_file {RUST_ADMISSION['consumer']}" in ci_text,
        "canonical CI omits Rust consumer tracked input",
    )
    require(
        f"require_tracked_file {DART_ADMISSION['consumer']}" in ci_text,
        "canonical CI omits Dart consumer tracked input",
    )
    require(
        f"require_tracked_file {JULIA_ADMISSION['consumer']}" in ci_text,
        "canonical CI omits Julia consumer tracked input",
    )
    require(
        "python3 tools/check_duplicate_regex_slot_identity_contract.py" in ci_text,
        "canonical CI omits neutral checker execution",
    )
    require(
        f"perl -c -Iperl {PERL_ADMISSION['consumer']}" in ci_text
        and f"PERL5LIB= prove -Iperl {PERL_ADMISSION['consumer']}" in ci_text,
        "canonical CI omits Perl consumer syntax or execution",
    )
    perl_consumer_text = (ROOT / PERL_ADMISSION["consumer"]).read_text(encoding="utf-8")
    require(
        all(f"sub role_{role}" in perl_consumer_text for role in PERL_ADMISSION["roles"]),
        "Perl consumer role inventory drifted",
    )
    rust_consumer_text = (ROOT / RUST_ADMISSION["consumer"]).read_text(encoding="utf-8")
    require(
        all(f"fn role_{role}" in rust_consumer_text for role in RUST_ADMISSION["roles"]),
        "Rust consumer role inventory drifted",
    )
    rust_driver_text = (ROOT / RUST_ADMISSION["canonical_driver"]).read_text(encoding="utf-8")
    require(
        'test --manifest-path rust/Cargo.toml -p linkedspec-runtime' in rust_driver_text,
        "Rust canonical driver omits the runtime package consumer",
    )
    dart_consumer_text = (ROOT / DART_ADMISSION["consumer"]).read_text(encoding="utf-8")
    require(
        all(f"void role_{role}" in dart_consumer_text for role in DART_ADMISSION["roles"]),
        "Dart consumer role inventory drifted",
    )
    dart_driver_text = (ROOT / DART_ADMISSION["canonical_driver"]).read_text(encoding="utf-8")
    require(
        '"$DART_CMD" test' in dart_driver_text,
        "Dart canonical driver omits the Dart consumer suite",
    )
    julia_consumer_text = (ROOT / JULIA_ADMISSION["consumer"]).read_text(encoding="utf-8")
    require(
        all(
            f"function role_{role}" in julia_consumer_text
            or f"role_{role}(" in julia_consumer_text
            for role in JULIA_ADMISSION["roles"]
        ),
        "Julia consumer role inventory drifted",
    )
    julia_driver_text = (ROOT / JULIA_ADMISSION["canonical_driver"]).read_text(encoding="utf-8")
    require(
        'Pkg.test()' in julia_driver_text,
        "Julia canonical driver omits the Julia consumer suite",
    )
    linked_re_text = (ROOT / "perl" / "LinkedRE.pm").read_text(encoding="utf-8")
    emitter_text = (ROOT / "perl" / "LinkedSpec" / "HandlerVariantEmitter.pm").read_text(encoding="utf-8")
    compiler_text = (ROOT / "perl" / "LinkedSpec" / "Compiler.pm").read_text(encoding="utf-8")
    require("sub match_slot" in linked_re_text, "Perl required-slot matcher is missing")
    require(
        "LinkedRE::match_slot" in emitter_text and "regex_slot_selected" in emitter_text,
        "Perl emitted required-slot or trace seam is missing",
    )
    require(
        "dependency_slot_map" in compiler_text,
        "Perl generated compiled-slot payload is missing",
    )
    rust_helpers_text = (ROOT / "rust" / "linkedspec-runtime" / "src" / "helpers.rs").read_text(encoding="utf-8")
    rust_engine_text = (ROOT / "rust" / "linkedspec-runtime" / "src" / "engine.rs").read_text(encoding="utf-8")
    rust_descriptor_text = (ROOT / "rust" / "linkedspec-core" / "src" / "descriptor.rs").read_text(encoding="utf-8")
    rust_emitter_text = (ROOT / "rust" / "linkedspec-runtime" / "src" / "source_emitter.rs").read_text(encoding="utf-8")
    require(
        "consume_slot_match" in rust_helpers_text and "seek_slot_match" in rust_helpers_text,
        "Rust required-slot matchers are missing",
    )
    require(
        "rust_runtime:engine:regex_slot_selected" in rust_engine_text
        and "rust_runtime:generated_plan:regex_slot_selected" in rust_engine_text
        and "assert_ordered_regex_slot_identity" in rust_engine_text,
        "Rust native/generated slot trace or invariant seam is missing",
    )
    require(
        "regex_slot_identity_contract" in rust_descriptor_text,
        "Rust descriptor slot-contract projection is missing",
    )
    require(
        "LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT" in rust_emitter_text,
        "Rust generated-source slot-contract projection is missing",
    )
    dart_matching_text = (ROOT / "dart" / "lib" / "src" / "runtime" / "matching.dart").read_text(encoding="utf-8")
    dart_engine_text = (ROOT / "dart" / "lib" / "src" / "runtime" / "interpreter.dart").read_text(encoding="utf-8")
    dart_compiler_text = (ROOT / "dart" / "lib" / "src" / "compiler" / "compiled_spec.dart").read_text(encoding="utf-8")
    dart_emitter_text = (ROOT / "dart" / "lib" / "src" / "source_emitter.dart").read_text(encoding="utf-8")
    require(
        "matchAlternative" in dart_matching_text,
        "Dart required-slot matcher is missing",
    )
    require(
        "dart_runtime:regex_slot_selected" in dart_engine_text
        and "assertOrderedRegexSlotIdentity" in dart_engine_text,
        "Dart native/generated slot trace or invariant seam is missing",
    )
    require(
        "regex_slot_identity_contract" in dart_compiler_text,
        "Dart descriptor slot-contract projection is missing",
    )
    require(
        "linkedspecRegexSlotIdentityContract" in dart_emitter_text,
        "Dart generated-source slot-contract projection is missing",
    )
    julia_matching_text = (ROOT / "julia" / "src" / "runtime" / "Matching.jl").read_text(encoding="utf-8")
    julia_engine_text = (ROOT / "julia" / "src" / "runtime" / "Interpreter.jl").read_text(encoding="utf-8")
    julia_compiler_text = (ROOT / "julia" / "src" / "compiler" / "CompiledSpec.jl").read_text(encoding="utf-8")
    julia_emitter_text = (ROOT / "julia" / "src" / "source" / "SourceEmitter.jl").read_text(encoding="utf-8")
    require(
        "match_runtime_regex_slot" in julia_matching_text,
        "Julia required-slot matcher is missing",
    )
    require(
        "julia_runtime:regex_slot_selected" in julia_engine_text
        and "assert_ordered_regex_slot_identity" in julia_engine_text,
        "Julia native/generated slot trace or invariant seam is missing",
    )
    require(
        "regex_slot_identity_contract" in julia_compiler_text,
        "Julia descriptor slot-contract projection is missing",
    )
    require(
        "LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT" in julia_emitter_text,
        "Julia generated-source slot-contract projection is missing",
    )


def expect_mutation_failure(
    contract: dict[str, Any], name: str, mutate: Callable[[dict[str, Any]], None]
) -> None:
    mutated = copy.deepcopy(contract)
    mutate(mutated)
    try:
        validate_contract(mutated, check_filesystem=False)
    except ContractError:
        return
    fail(f"mutation {name!r} was not rejected")


def mutation_checks(contract: dict[str, Any]) -> int:
    def remove_fixture(value: dict[str, Any]) -> None:
        value["fixtures"].pop()

    def change_fixture_result(value: dict[str, Any]) -> None:
        value["fixtures"][0]["expected_result"] = None

    def change_fixture_identity(value: dict[str, Any]) -> None:
        value["fixtures"][0]["expected_match_identities"][1] = "Top#0"

    def remove_diagnostic(value: dict[str, Any]) -> None:
        value["diagnostics"].pop()

    def remove_inventory(value: dict[str, Any]) -> None:
        value["implementation_inventory"].pop()

    def regress_perl(value: dict[str, Any]) -> None:
        value["rollout"][1]["status"] = "pending"

    def regress_rust(value: dict[str, Any]) -> None:
        value["rollout"][2]["status"] = "pending"

    def regress_dart(value: dict[str, Any]) -> None:
        value["rollout"][3]["status"] = "pending"

    def regress_julia(value: dict[str, Any]) -> None:
        value["rollout"][4]["status"] = "pending"

    mutations: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
        ("contract id", lambda value: value.__setitem__("contract_id", "stale")),
        ("duplicate legality", lambda value: value["identity"].__setitem__("duplicate_pattern_text_is_legal", False)),
        ("identity fields", lambda value: value["identity"].__setitem__("required_fields", ["regex_text"])),
        ("forbidden recovery", lambda value: value["identity"]["identity_recovery_forbidden"].pop()),
        ("ordered algorithm", lambda value: value["selection"]["ordered"].__setitem__("algorithm", "combined_alternation")),
        ("repeated reset", lambda value: value["selection"]["ordered"].__setitem__("repetition", "continue_last_slot")),
        ("choice tie", lambda value: value["selection"]["choice"].__setitem__("tie_break", "regex_text")),
        ("fixture omitted", remove_fixture),
        ("fixture result", change_fixture_result),
        ("fixture identity", change_fixture_identity),
        ("diagnostic omitted", remove_diagnostic),
        ("diagnostic fields", lambda value: value["diagnostics"][1]["fields"].pop()),
        ("descriptor metadata", lambda value: value["descriptor_contract"].__setitem__("meta_value", "stale")),
        ("generated format bump", lambda value: value["generated_source_v2"].__setitem__("plan_format_bump_required", True)),
        ("generated plan fields", lambda value: value["generated_source_v2"]["plan_row_fields"].append("regex_index")),
        ("trace identity", lambda value: value["trace_contract"]["fields"].remove("regex_index")),
        ("Perl admission consumer", lambda value: value["perl_admission"].__setitem__("consumer", "t/other.t")),
        ("Perl admission role", lambda value: value["perl_admission"]["roles"].pop()),
        ("Perl ordered mechanism", lambda value: value["perl_admission"].__setitem__("ordered_mechanism", "combined_alternation")),
        ("Rust admission consumer", lambda value: value["rust_admission"].__setitem__("consumer", "rust/other.rs")),
        ("Rust admission role", lambda value: value["rust_admission"]["roles"].pop()),
        ("Rust ordered mechanism", lambda value: value["rust_admission"].__setitem__("ordered_mechanism", "combined_alternation")),
        ("Dart admission consumer", lambda value: value["dart_admission"].__setitem__("consumer", "dart/test/other.dart")),
        ("Dart admission role", lambda value: value["dart_admission"]["roles"].pop()),
        ("Dart ordered mechanism", lambda value: value["dart_admission"].__setitem__("ordered_mechanism", "match_required_pattern_then_reindex")),
        ("Julia admission consumer", lambda value: value["julia_admission"].__setitem__("consumer", "julia/test/other.jl")),
        ("Julia admission role", lambda value: value["julia_admission"]["roles"].pop()),
        ("Julia ordered mechanism", lambda value: value["julia_admission"].__setitem__("ordered_mechanism", "match_required_pattern_then_reindex")),
        ("inventory omission", remove_inventory),
        ("Perl inventory regression", lambda value: value["implementation_inventory"][0].__setitem__("ordered_status", "drift")),
        ("Rust inventory regression", lambda value: value["implementation_inventory"][1].__setitem__("ordered_status", "drift")),
        ("Dart inventory regression", lambda value: value["implementation_inventory"][2].__setitem__("ordered_status", "drift")),
        ("Julia inventory regression", lambda value: value["implementation_inventory"][3].__setitem__("ordered_status", "drift")),
        ("Lua ABI identity", lambda value: value["implementation_inventory"][5].__setitem__("runtime", "lua")),
        ("migration checker", lambda value: value["migration"].__setitem__("checker", "tools/other.py")),
        ("Perl rollout regression", regress_perl),
        ("Rust rollout regression", regress_rust),
        ("Dart rollout regression", regress_dart),
        ("Julia rollout regression", regress_julia),
        ("neutral rollout regression", lambda value: value["rollout"][0].__setitem__("status", "pending")),
        ("canonical CI mode", lambda value: value["canonical_ci"].__setitem__("mode", "optional")),
    ]
    for name, mutate in mutations:
        expect_mutation_failure(contract, name, mutate)
    return len(mutations)


def main() -> int:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(contract)
    mutation_count = mutation_checks(contract)
    complete = sum(row["status"] == "complete" for row in contract["rollout"])
    pending = sum(row["status"] == "pending" for row in contract["rollout"])
    print(
        "duplicate-regex-slot identity contract: OK "
        f"({len(contract['fixtures'])} fixtures, {len(contract['diagnostics'])} diagnostics, "
        f"{len(contract['implementation_inventory'])} runtime rows, "
        f"{complete} complete + {pending} pending rollout, {mutation_count} drift mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

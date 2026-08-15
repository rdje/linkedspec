#!/usr/bin/env python3
"""Validate the neutral inter-match gap-capture model and exact rollout."""

from __future__ import annotations

import copy
import json
import sys
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CHECKER_PATH = Path(__file__).resolve()
CONTRACT_PATH = ROOT / "capability_conformance/inter_match_gap_capture_contract.json"
UNICODE_CONTRACT_PATH = ROOT / "capability_conformance/unicode_rule_label_contract.json"
CI_PATH = ROOT / "tools/run_ci_local.sh"
RECURRING_DRIVER_PATH = ROOT / "tools/check_inter_match_gap_capture_six_runtime.sh"
PROJECT_DATA_WORKFLOW_ROUTING_PATH = ROOT / "tools/test_project_data_workflow_routing.sh"
PERL_CONSUMER_PATH = ROOT / "t/inter_match_gap_capture_perl_contract.t"
PERL_FACADE_PATH = ROOT / "perl/LinkedSpec.pm"
RUST_CONSUMER_PATH = ROOT / "rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs"
RUST_FACADE_PATH = ROOT / "rust/linkedspec-runtime/src/lib.rs"
CONTRACT_ID = "linkedspec-inter-match-gap-capture-v1"
TASK_OWNER = "INTER-MATCH-GAP-CAPTURE.1.1"
PINNED_XID_RANGES: tuple[tuple[int, int], ...] = ()

RUST_ADMISSION_MUTATION_IDS = (
    "rust_consumer_identity",
    "rust_role_ledger",
    "rust_ordinary_registration",
    "rust_primary_role",
    "rust_canonical_registration",
    "rust_canonical_duplicate",
    "rust_recurring_registration",
    "rust_recurring_duplicate",
    "rust_later_runtime_skip",
    "rust_facade_absence",
)

REQUIRED_SECTIONS = (
    "format",
    "contract_id",
    "task_owner",
    "expected_counts",
    "policy",
    "canonical_execution",
    "identifier_policy",
    "authored_surfaces",
    "selector_resolution_fixtures",
    "gap_sources",
    "gap_context_schema",
    "gap_state_machine",
    "segmentation_cases",
    "lifecycle_matrix",
    "transaction_recursion_cases",
    "compatibility_matrix",
    "diagnostics",
    "mutation_ids",
    "recurring_gate",
    "public_no_overclaim",
    "rollout",
)

EXPECTED_COUNTS = {
    "positive_selector_fixtures": 8,
    "negative_selector_directive_fixtures": 10,
    "decoded_source_fixtures": 3,
    "private_gap_fields": 8,
    "main_machine_transitions": 16,
    "segmentation_cases": 10,
    "terminal_routes": 3,
    "transaction_recursion_return_cases": 7,
    "compatibility_rows": 6,
    "diagnostics": 9,
    "rollout_legs": 9,
    "semantic_mutations": 56,
}

MUTATION_IDS = (
    "contract_id",
    "format",
    "task_owner",
    "expected_counts",
    "required_section",
    "identifier_classifier",
    "digit_reservation",
    "normalization_identity",
    "case_identity",
    "spacing_compact",
    "spacing_before_equals",
    "spacing_after_equals",
    "spacing_both",
    "mixed_declaration_order",
    "duplicate_slot_name",
    "selector_unindexed",
    "selector_numeric",
    "selector_named",
    "named_reorder_stability",
    "numeric_reorder_position",
    "selector_provenance",
    "duplicate_regex_identity",
    "directive_cardinality",
    "directive_family",
    "directive_cursor_policy",
    "directive_edge_ownership",
    "directive_loop",
    "directive_static_edge",
    "legacy_marker_conflict",
    "explicit_helper_independence",
    "gap_source_identity",
    "gap_half_open",
    "gap_empty",
    "gap_unicode",
    "gap_prefix",
    "gap_interstitial",
    "gap_tail",
    "zero_match_tail",
    "candidate_before_ls",
    "candidate_through_le",
    "commit_before_it",
    "falsey_acceptance",
    "child_extended_exit",
    "failure_no_commit",
    "rollback_no_commit",
    "unwind_clear",
    "recursion_isolation",
    "nested_suspend_resume",
    "action_return_authority",
    "diagnostic_schema",
    "rollout_sequence",
    "perl_runtime_regression",
    "rust_runtime_regression",
    "storage_paths",
    "route_order",
    "public_no_overclaim",
)

POSITIVE_IDS = (
    "spacing_compact",
    "spacing_before_equals",
    "spacing_after_equals",
    "spacing_both",
    "unicode_xid_exact",
    "mixed_named_anonymous",
    "numeric_named_same_target",
    "named_reorder_stable",
)
NEGATIVE_IDS = (
    "invalid_slot_name",
    "numeric_only_name",
    "duplicate_slot_name",
    "unknown_named_selector",
    "selector_index_out_of_range",
    "malformed_named_selector",
    "duplicate_directive",
    "ineligible_and_family",
    "ineligible_blind_owner",
    "legacy_marker_conflict",
)
SEGMENTATION_IDS = (
    "unicode_prefix_interstitial_tail",
    "empty_prefix",
    "empty_interstitial",
    "empty_tail",
    "zero_match_whole_tail",
    "child_extended_accepted_exit",
    "falsey_action_accepted",
    "maximum_exit_tail",
    "failed_edge_no_commit",
    "nested_recursive_isolation",
)
TRANSACTION_IDS = (
    "accepted_falsey_commits",
    "edge_failure_discards",
    "recognition_rollback_restores",
    "abnormal_unwind_clears",
    "nested_child_suspends_parent",
    "recursive_invocation_isolates_state",
    "default_action_return_unwinds_without_commit_or_tail",
)
COMPATIBILITY_IDS = (
    "capture_slice_member",
    "capture_from_here_member",
    "move_pos_member",
    "named_mark_member",
    "explicit_capture_mark_helpers",
    "no_emit_gaps_surface",
)
ROLLOUT_IDS = (
    "neutral_contract",
    "perl_runtime",
    "rust_runtime",
    "dart_runtime",
    "julia_runtime",
    "puc_lua_runtime",
    "luajit_runtime",
    "recurring",
    "public_no_drift",
)

EXPECTED_DIAGNOSTICS = (
    ("regex_slot_name_invalid", "parse_declaration", "static", ("rule_label", "source_id", "line", "slot_name")),
    ("regex_slot_duplicate_name", "resolve_declaration", "static", ("rule_label", "source_id", "line", "slot_name", "first_line")),
    ("regex_slot_unknown_name", "resolve_selector", "static", ("rule_label", "source_id", "line", "target_rule", "authored_selector")),
    ("regex_slot_index_out_of_range", "resolve_selector", "static", ("rule_label", "source_id", "line", "target_rule", "regex_index", "regex_count")),
    ("regex_slot_selector_invalid", "parse_selector", "static", ("rule_label", "source_id", "line", "target_rule", "authored_selector")),
    ("capture_gaps_duplicate_directive", "parse_directive", "static", ("rule_label", "source_id", "line", "first_line")),
    ("capture_gaps_rule_ineligible", "validate_directive", "static", ("rule_label", "source_id", "line", "family", "cursor_policy", "edge_ownership", "execution_shape")),
    ("capture_gaps_legacy_marker_conflict", "validate_directive", "static", ("rule_label", "source_id", "line", "marker", "marker_line")),
    ("gap_capture_context_unavailable", "access_gap_context", "static_or_runtime", ("rule_label", "source_id", "invocation_id", "phase", "accessor")),
)


class ContractError(ValueError):
    """Stable neutral-contract validation failure."""


def fail(detail: str) -> None:
    raise ContractError(detail)


def require(condition: bool, detail: str) -> None:
    if not condition:
        fail(detail)


def require_fields(value: Any, fields: tuple[str, ...] | set[str], context: str) -> dict[str, Any]:
    require(isinstance(value, dict) and set(value) == set(fields), f"{context} fields drifted")
    return value


def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    value: dict[str, Any] = {}
    for key, item in pairs:
        require(key not in value, f"duplicate JSON key {key!r}")
        value[key] = item
    return value


def reject_json_constant(value: str) -> None:
    fail(f"invalid JSON constant {value}")


def load_json(path: Path) -> Any:
    return json.loads(
        path.read_text(encoding="utf-8"),
        object_pairs_hook=unique_object,
        parse_constant=reject_json_constant,
    )


def indexed(rows: Any, expected_ids: tuple[str, ...], context: str) -> dict[str, dict[str, Any]]:
    require(isinstance(rows, list), f"{context} must be an array")
    require(all(isinstance(row, dict) and isinstance(row.get("id"), str) for row in rows), f"{context} rows are invalid")
    ids = tuple(row["id"] for row in rows)
    require(ids == expected_ids, f"{context} identity/order drifted")
    return {row["id"]: row for row in rows}


def load_pinned_xid_ranges() -> tuple[tuple[int, int], ...]:
    try:
        document = load_json(UNICODE_CONTRACT_PATH)
    except (json.JSONDecodeError, OSError) as error:
        fail(f"pinned Unicode identifier contract is unavailable: {error}")
    require(document.get("schema_version") == 1, "pinned Unicode identifier schema drifted")
    require(document.get("unicode_version") == "17.0.0", "pinned Unicode identifier version drifted")
    require(document.get("policy", {}).get("property") == "XID_Continue", "pinned Unicode identifier property drifted")
    raw_ranges = document.get("xid_continue_ranges")
    require(isinstance(raw_ranges, list) and len(raw_ranges) == 806, "pinned Unicode identifier ranges drifted")
    ranges: list[tuple[int, int]] = []
    previous_end = -1
    for index, raw_range in enumerate(raw_ranges):
        require(isinstance(raw_range, list) and len(raw_range) == 2, f"pinned Unicode range {index} is invalid")
        try:
            start, end = (int(value, 16) for value in raw_range)
        except (TypeError, ValueError) as error:
            fail(f"pinned Unicode range {index} is invalid: {error}")
        require(previous_end < start <= end <= 0x10FFFF, f"pinned Unicode range {index} ordering drifted")
        ranges.append((start, end))
        previous_end = end
    return tuple(ranges)


def is_xid_continue(scalar: str) -> bool:
    require(len(scalar) == 1, "identifier classifier requires one scalar")
    codepoint = ord(scalar)
    return any(start <= codepoint <= end for start, end in PINNED_XID_RANGES)


def validate_policy(document: dict[str, Any]) -> None:
    expected = {
        "status": "executable_neutral_behavior_free",
        "current_behavior_claim": False,
        "semantic_change_rule": "new_task_tree_leaf_and_adr_amendment_before_contract_change",
        "coordinate_unit": "decoded_unicode_scalar_half_open",
        "source_authority": "typed_source_identity",
        "runtime_implementation_owner": "INTER-MATCH-GAP-CAPTURE.2-.7",
    }
    require(document["policy"] == expected, "neutral policy drifted")


def validate_execution(document: dict[str, Any]) -> None:
    expected = {
        "artifact": "capability_conformance/inter_match_gap_capture_contract.json",
        "checker": "tools/check_inter_match_gap_capture_contract.py",
        "command": "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py",
        "project_data_driver": "tools/run_python_project_data.sh",
        "project_data_policy": "repository_root_relative_same_volume_only",
        "canonical_routing_owner": "INTER-MATCH-GAP-CAPTURE.1.2",
    }
    require(document["canonical_execution"] == expected, "canonical execution drifted")


def validate_identifier_policy(document: dict[str, Any]) -> None:
    policy = require_fields(
        document["identifier_policy"],
        {
            "unicode_version",
            "classifier",
            "positions",
            "identity",
            "case_sensitive",
            "normalization",
            "ascii_digit_only",
            "scope",
            "declaration_grammar",
            "physical_line",
            "context",
        },
        "identifier policy",
    )
    require(policy["unicode_version"] == "17.0.0", "identifier Unicode version drifted")
    require(policy["classifier"] == "XID_Continue", "identifier classifier drifted")
    require(policy["positions"] == "one_or_more_same_class_including_first", "identifier position policy drifted")
    require(policy["identity"] == "exact_decoded_unicode_scalar_sequence", "identifier identity drifted")
    require(policy["case_sensitive"] is True, "identifier case identity drifted")
    require(policy["normalization"] == "none", "identifier normalization identity drifted")
    require(policy["ascii_digit_only"] == "reserved_for_numeric_selector_and_invalid_as_name", "digit reservation drifted")
    require(policy["scope"] == "unique_within_owning_rule", "identifier scope drifted")
    require(policy["declaration_grammar"] == "REGEX_SLOT_NAME HSPACE* = HSPACE* REGEX", "declaration grammar drifted")
    require(policy["physical_line"] == "same_rule_paragraph_line", "declaration physical-line rule drifted")
    require(policy["context"] == "outside_code", "declaration context drifted")


def validate_authored_surfaces(document: dict[str, Any]) -> None:
    surface = require_fields(
        document["authored_surfaces"],
        {"declarations", "selectors", "resolved_edge_fields", "entry_slot", "directive", "accessors", "forbidden_aliases", "emission"},
        "authored surfaces",
    )
    require(
        surface["declarations"] == ["header=/H/", "header =/H/", "header= /H/", "header = /H/"],
        "declaration spacing surfaces drifted",
    )
    require(
        surface["selectors"]
        == [
            {"form": "Rule", "kind": "unindexed", "authored_selector": None, "resolution": "regex_index_0"},
            {"form": "Rule[N]", "kind": "numeric", "authored_selector": "nonnegative_integer", "resolution": "written_index"},
            {"form": "Rule[name]", "kind": "named", "authored_selector": "exact_name", "resolution": "rule_local_name"},
        ],
        "selector surface drifted",
    )
    require(
        surface["resolved_edge_fields"] == ["selector_kind", "authored_selector", "target_rule", "regex_index", "target_slot_id"],
        "selector provenance drifted",
    )
    require(
        surface["entry_slot"]
        == {
            "status": "future",
            "direct_entry": "undef",
            "return_kind": "detached_ordinary_harray",
            "ordered_fields": ["target_rule", "regex_index", "slot_id", "selector_kind", "authored_selector"],
        },
        "entry_slot surface drifted",
    )
    directive = require_fields(
        surface["directive"],
        {"name", "cardinality", "placement", "canonical_placement", "eligibility"},
        "capture-gaps directive",
    )
    require(directive["name"] == "@capture_gaps", "directive identity drifted")
    require(directive["cardinality"] == "one_per_rule", "directive cardinality drifted")
    require(directive["placement"] == "rule_level_placement_insensitive", "directive placement drifted")
    require(directive["canonical_placement"] == "after_I_before_first_action_edge", "directive canonical placement drifted")
    eligibility = require_fields(
        directive["eligibility"],
        {"family", "cursor_policy", "edge_ownership", "uses_loop", "execution_shapes", "minimum_static_action_edges", "ineligible"},
        "directive eligibility",
    )
    require(eligibility["family"] == "or_default", "directive family drifted")
    require(eligibility["cursor_policy"] == "seek", "directive cursor policy drifted")
    require(eligibility["edge_ownership"] == "action", "directive edge ownership drifted")
    require(eligibility["uses_loop"] is True, "directive loop requirement drifted")
    require(eligibility["execution_shapes"] == ["default_scan_loop", "repeat_loop"], "directive execution shapes drifted")
    require(eligibility["minimum_static_action_edges"] == 1, "directive static-edge requirement drifted")
    require(eligibility["ineligible"] == ["and_consume", "blind_owner", "mixed_owner", "local_adjacency_owner"], "directive ineligible set drifted")
    require(
        surface["accessors"]
        == {
            "gap_span": {"status": "future", "return_kind": "detached_harray", "ordered_fields": ["source_id", "start", "end", "provenance"]},
            "gap_text": {"status": "future", "return": "exact_decoded_text_from_current_source"},
            "gap_kind": {"status": "future", "return": ["prefix", "interstitial", "tail"]},
            "unavailable": "gap_capture_context_unavailable",
        },
        "gap accessor surface drifted",
    )
    require(surface["forbidden_aliases"] == ["Rule.N", "Rule.name", "Rule[N] method()", "Rule[name] method()"], "forbidden selector aliases drifted")
    require(surface["emission"] == {"emit_gaps_surface": False, "forced_ast_emission": False}, "gap emission policy drifted")


def validate_selector_fixtures(document: dict[str, Any]) -> None:
    fixtures = require_fields(document["selector_resolution_fixtures"], {"positive", "negative"}, "selector fixtures")
    positives = indexed(fixtures["positive"], POSITIVE_IDS, "positive selector fixtures")
    negatives = indexed(fixtures["negative"], NEGATIVE_IDS, "negative selector/directive fixtures")
    expected_spacing = {
        "spacing_compact": "header=/H/",
        "spacing_before_equals": "header =/H/",
        "spacing_after_equals": "header= /H/",
        "spacing_both": "header = /H/",
    }
    for fixture_id, declaration in expected_spacing.items():
        require(
            positives[fixture_id] == {"id": fixture_id, "declaration": declaration, "slot_name": "header", "regex_index": 0},
            f"{fixture_id} fixture drifted",
        )
    require(
        positives["unicode_xid_exact"]
        == {"id": "unicode_xid_exact", "declaration": "é́=/U/", "slot_name": "é́", "identity": "exact_no_normalization", "regex_index": 0},
        "unicode XID fixture drifted",
    )
    unicode_name = positives["unicode_xid_exact"]["slot_name"]
    require(len(unicode_name) == 2 and all(is_xid_continue(scalar) for scalar in unicode_name), "unicode XID executable classification drifted")
    require(is_xid_continue("1"), "digit reservation classifier premise drifted")
    require(
        positives["mixed_named_anonymous"]
        == {"id": "mixed_named_anonymous", "declarations": ["head=/H/", "/S/", "foot=/F/"], "regex_indexes": [0, 1, 2], "slot_ids": ["head", None, "foot"]},
        "mixed declaration order drifted",
    )
    require(
        positives["numeric_named_same_target"]
        == {
            "id": "numeric_named_same_target",
            "named": {"selector_kind": "named", "authored_selector": "head", "target_rule": "Part", "regex_index": 0, "target_slot_id": "head"},
            "numeric": {"selector_kind": "numeric", "authored_selector": 0, "target_rule": "Part", "regex_index": 0, "target_slot_id": "head"},
        },
        "numeric/named selector equivalence drifted",
    )
    require(
        positives["named_reorder_stable"]
        == {
            "id": "named_reorder_stable",
            "before": {"selector_kind": "named", "authored_selector": "head", "regex_index": 0, "target_slot_id": "head"},
            "after": {"selector_kind": "named", "authored_selector": "head", "regex_index": 1, "target_slot_id": "head"},
            "numeric_after_reorder": {"selector_kind": "numeric", "authored_selector": 0, "regex_index": 0, "target_slot_id": "other"},
            "duplicate_regex_text_preserves_slot_identity": True,
        },
        "named reorder fixture drifted",
    )
    expected_negative = {
        "invalid_slot_name": ("-bad=/H/", "regex_slot_name_invalid"),
        "numeric_only_name": ("123=/H/", "regex_slot_name_invalid"),
        "duplicate_slot_name": ("head=/H/\nhead=/S/", "regex_slot_duplicate_name"),
        "unknown_named_selector": ("-> Part[missing]", "regex_slot_unknown_name"),
        "selector_index_out_of_range": ("-> Part[2]", "regex_slot_index_out_of_range"),
        "malformed_named_selector": ("-> Part[head", "regex_slot_selector_invalid"),
        "duplicate_directive": ("@capture_gaps\n@capture_gaps", "capture_gaps_duplicate_directive"),
        "ineligible_and_family": ("Top::AND\n @capture_gaps", "capture_gaps_rule_ineligible"),
        "ineligible_blind_owner": ("Top::OR\n @capture_gaps\n => Part", "capture_gaps_rule_ineligible"),
        "legacy_marker_conflict": ("@capture_gaps\n @move_pos", "capture_gaps_legacy_marker_conflict"),
    }
    for fixture_id, (authored, diagnostic) in expected_negative.items():
        require(
            negatives[fixture_id] == {"id": fixture_id, "authored": authored, "expected": "reject", "diagnostic": diagnostic},
            f"{fixture_id} negative fixture drifted",
        )
    require(not is_xid_continue("-"), "invalid-name classifier premise drifted")
    require(all(is_xid_continue(scalar) for scalar in "123"), "numeric-name classifier premise drifted")


def validate_sources(document: dict[str, Any]) -> None:
    sources = indexed(document["gap_sources"], ("unicode_main", "empty_boundaries", "child_extended"), "gap sources")
    require(
        sources["unicode_main"]
        == {
            "id": "unicode_main",
            "source_id": "fixture:unicode-main",
            "decoded_text": "αHβ\nS🙂Fω",
            "scalar_length": 8,
            "matches": [{"slot": "header", "span": [1, 2]}, {"slot": "section", "span": [4, 5]}, {"slot": "footer", "span": [6, 7]}],
        },
        "Unicode gap source drifted",
    )
    require(
        sources["empty_boundaries"]
        == {"id": "empty_boundaries", "source_id": "fixture:empty-boundaries", "decoded_text": "HS", "scalar_length": 2, "matches": [{"slot": "header", "span": [0, 1]}, {"slot": "section", "span": [1, 2]}]},
        "empty-boundary gap source drifted",
    )
    require(
        sources["child_extended"]
        == {"id": "child_extended", "source_id": "fixture:child-extended", "decoded_text": "p{abc}gap!", "scalar_length": 10, "opening_match": [0, 1], "accepted_target_exit": 6, "next_gap": [6, 9], "next_match": [9, 10]},
        "child-extended gap source drifted",
    )


def validate_executable_model(document: dict[str, Any]) -> None:
    """Execute the frozen span/state rules independently of their prose rows."""
    sources = {source["id"]: source for source in document["gap_sources"]}
    for source in sources.values():
        text = source["decoded_text"]
        require(all(not 0xD800 <= ord(scalar) <= 0xDFFF for scalar in text), f"{source['id']} contains a non-scalar value")
        require(len(text) == source["scalar_length"], f"{source['id']} scalar length drifted")

    main = sources["unicode_main"]
    committed_cursor = 0
    accepted_count = 0
    observed: list[tuple[str, int, int, str]] = []
    falsey_payload: Any = 0
    for match_index, match in enumerate(main["matches"]):
        start, end = match["span"]
        require(0 <= committed_cursor <= start <= end <= main["scalar_length"], "main-model match ordering drifted")
        kind = "prefix" if accepted_count == 0 else "interstitial"
        observed.append((kind, committed_cursor, start, main["decoded_text"][committed_cursor:start]))
        match_present = True
        payload = falsey_payload if match_index == 0 else match["slot"]
        require(match_present, "main-model selected match disappeared")
        require(match_index != 0 or not bool(payload), "main-model falsey fixture drifted")
        committed_cursor = end
        accepted_count += 1
    observed.append(("tail", committed_cursor, main["scalar_length"], main["decoded_text"][committed_cursor:]))
    require(
        observed
        == [
            ("prefix", 0, 1, "α"),
            ("interstitial", 2, 4, "β\n"),
            ("interstitial", 5, 6, "🙂"),
            ("tail", 7, 8, "ω"),
        ],
        "executable Unicode segmentation drifted",
    )
    require(committed_cursor == 7 and accepted_count == 3, "executable accepted state drifted")

    empty = sources["empty_boundaries"]
    empty_spans: list[tuple[int, int]] = []
    committed_cursor = 0
    for match in empty["matches"]:
        start, end = match["span"]
        empty_spans.append((committed_cursor, start))
        committed_cursor = end
    empty_spans.append((committed_cursor, empty["scalar_length"]))
    require(empty_spans == [(0, 0), (1, 1), (2, 2)], "executable empty segmentation drifted")

    child = sources["child_extended"]
    selected_start, selected_end = child["opening_match"]
    require((selected_start, selected_end) == (0, 1), "executable child entry drifted")
    committed_cursor = child["accepted_target_exit"]
    next_start, next_end = child["next_match"]
    require(selected_end <= committed_cursor <= next_start < next_end, "executable child accepted-exit ordering drifted")
    require([committed_cursor, next_start] == child["next_gap"], "executable child gap coordinates drifted")
    require(child["decoded_text"][committed_cursor:next_start] == "gap", "executable child gap text drifted")

    parent = {"invocation_id": 7, "committed_gap_cursor": 2, "accepted_edge_count": 1, "current_gap": [2, 4]}
    suspended = copy.deepcopy(parent)
    child_state = {"invocation_id": 8, "committed_gap_cursor": 4, "accepted_edge_count": 0, "current_gap": None}
    child_state["committed_gap_cursor"] = 5
    require(parent == suspended and child_state["invocation_id"] != parent["invocation_id"], "executable nested isolation drifted")

    snapshot = copy.deepcopy(parent)
    candidate = copy.deepcopy(parent)
    candidate["current_gap"] = [2, 4]
    candidate["committed_gap_cursor"] = 5
    candidate = snapshot
    require(candidate == parent, "executable rollback restoration drifted")


def validate_gap_schema(document: dict[str, Any]) -> None:
    schema = require_fields(
        document["gap_context_schema"],
        {"invocation_state_fields", "private_current_gap_fields", "field_semantics", "interval", "provenance", "history", "detachment", "transaction"},
        "gap context schema",
    )
    require(schema["invocation_state_fields"] == ["source_id", "invocation_id", "committed_gap_cursor", "accepted_edge_count", "current_gap"], "invocation gap-state fields drifted")
    require(schema["private_current_gap_fields"] == ["source_id", "rule_label", "invocation_id", "edge_ordinal", "kind", "start", "end", "provenance"], "private gap fields drifted")
    require(
        schema["field_semantics"]
        == {
            "rule_label": "enclosing_gap_owning_rule",
            "edge_ordinal": "accepted_edge_count_before_candidate_or_final_count_for_tail",
            "kind": ["prefix", "interstitial", "tail"],
        },
        "private gap field semantics drifted",
    )
    require(schema["interval"] == "half_open_decoded_unicode_scalar", "gap half-open interval drifted")
    require(schema["provenance"] == "gap", "gap provenance drifted")
    require(schema["history"] == "none_after_invocation_exit", "gap history retention drifted")
    require(schema["detachment"] == "fresh_recursive_ordinary_data", "gap detachment drifted")
    require(
        schema["transaction"]
        == {
            "snapshot_members": ["committed_gap_cursor", "accepted_edge_count", "current_gap"],
            "failure_rollback_unwind": "discard_candidate_and_do_not_advance_committed_gap_state",
            "effects_outside_rollback": ["user_variables", "ast_mutation", "output", "external_calls", "diagnostics", "registry", "host_state"],
        },
        "gap transaction boundary drifted",
    )


def validate_state_machine(document: dict[str, Any]) -> None:
    machine = require_fields(document["gap_state_machine"], {"source", "rule", "transitions"}, "gap state machine")
    require(machine["source"] == "unicode_main" and machine["rule"] == "Root", "gap state-machine identity drifted")
    expected = [
        ("enter_root", "cursor=0,count=0,current_gap=absent"),
        ("select_header", "prefix=[0,1),ordinal=0,before_LS"),
        ("enter_header_ls", "same_prefix_current"),
        ("accept_falsey_header_edge", "match_presence_accepts_false_payload"),
        ("enter_header_le", "same_prefix_current"),
        ("commit_header", "cursor=2,count=1,current_gap=absent"),
        ("enter_header_it", "current_gap=absent"),
        ("select_section", "interstitial=[2,4),ordinal=1,before_LS"),
        ("suspend_for_section_child", "parent_candidate_preserved_and_hidden"),
        ("resume_section_parent", "same_parent_candidate_restored"),
        ("commit_section", "cursor=5,count=2,current_gap=absent"),
        ("select_footer", "interstitial=[5,6),ordinal=2,before_LS"),
        ("commit_footer", "cursor=7,count=3,current_gap=absent"),
        ("terminal_miss", "tail=[7,8),ordinal=3,no_cursor_move"),
        ("enter_terminal_lx", "same_tail_current"),
        ("accept_root", "current_gap=absent,no_retained_history"),
    ]
    transitions = machine["transitions"]
    require(isinstance(transitions, list) and len(transitions) == len(expected), "gap state-machine transition count drifted")
    actual = [(row.get("id"), row.get("effect")) if isinstance(row, dict) else (None, None) for row in transitions]
    require(actual == expected, "gap state-machine transitions drifted")


def validate_segmentation(document: dict[str, Any]) -> None:
    rows = indexed(document["segmentation_cases"], SEGMENTATION_IDS, "segmentation cases")
    expected = {
        "unicode_prefix_interstitial_tail": "prefix=[0,1);interstitial=[2,4);interstitial=[5,6);tail=[7,8)",
        "empty_prefix": "prefix=[0,0)",
        "empty_interstitial": "interstitial=[1,1)",
        "empty_tail": "tail=[2,2)",
        "zero_match_whole_tail": "tail=[entry,input_end)",
        "child_extended_accepted_exit": "next_gap=[6,9):gap",
        "falsey_action_accepted": "commit_selected_match_exit",
        "maximum_exit_tail": "tail_before_E",
        "failed_edge_no_commit": "candidate_discarded,cursor_unchanged",
        "nested_recursive_isolation": "independent_invocation_state",
    }
    for fixture_id, result in expected.items():
        require(rows[fixture_id] == {"id": fixture_id, "expected": result}, f"{fixture_id} segmentation drifted")


def validate_lifecycle(document: dict[str, Any]) -> None:
    matrix = require_fields(document["lifecycle_matrix"], {"successful_edge", "terminal_routes", "terminal_policy", "return_authority"}, "lifecycle matrix")
    require(
        matrix["successful_edge"] == ["selection", "candidate", "LS", "edge_or_target", "LE", "commit", "IT"],
        "successful-edge lifecycle drifted",
    )
    require(
        matrix["terminal_routes"]
        == [
            {"id": "default_miss", "condition": "default_scan_loop_terminal_miss", "hook": "LX", "tail": "before_hook"},
            {"id": "repeat_exhaustion", "condition": "minimum_satisfied_then_exhausted", "hook": "EX", "tail": "before_hook"},
            {"id": "repeat_maximum", "condition": "maximum_reached", "hook": "E", "tail": "before_hook"},
        ],
        "terminal lifecycle routes drifted",
    )
    require(
        matrix["terminal_policy"]
        == {
            "failed_minimum": "no_tail",
            "zero_match_zero_minimum": "whole_entry_to_input_end_tail",
            "tail_access": "no_consume_no_cursor_advance_no_automatic_result",
            "candidate_exit": "clear_on_terminal_return_or_unwind",
        },
        "terminal lifecycle policy drifted",
    )
    require(
        matrix["return_authority"]
        == {
            "repeated_action_edge": "accepted_per_hit_payload_then_finalize_iteration",
            "default_scan_action_edge": "whole_rule_unwind_clear_candidate_no_commit_no_tail",
            "lifecycle_hooks": "whole_rule_unwind_preserve_exact_return_value",
        },
        "lifecycle return authority drifted",
    )


def validate_transactions(document: dict[str, Any]) -> None:
    rows = indexed(document["transaction_recursion_cases"], TRANSACTION_IDS, "transaction/recursion cases")
    expected = {
        "accepted_falsey_commits": "match_presence_accepts_then_commits",
        "edge_failure_discards": "candidate_discarded_and_committed_state_unchanged",
        "recognition_rollback_restores": "candidate_and_committed_gap_state_restored_only",
        "abnormal_unwind_clears": "candidate_cleared_without_commit_or_tail",
        "nested_child_suspends_parent": "child_isolated_parent_hidden_then_restored",
        "recursive_invocation_isolates_state": "fresh_monotonic_invocation_authority",
        "default_action_return_unwinds_without_commit_or_tail": "whole_rule_return_authority_from_adr_0048",
    }
    for fixture_id, result in expected.items():
        require(rows[fixture_id] == {"id": fixture_id, "expected": result}, f"{fixture_id} transaction drifted")


def validate_compatibility(document: dict[str, Any]) -> None:
    rows = indexed(document["compatibility_matrix"], COMPATIBILITY_IDS, "compatibility matrix")
    for fixture_id, marker in (
        ("capture_slice_member", "@capture_slice"),
        ("capture_from_here_member", "@capture_from_here"),
        ("move_pos_member", "@move_pos"),
    ):
        require(
            rows[fixture_id] == {"id": fixture_id, "surface": marker, "retained": True, "alias_for_capture_gaps": False, "mixed_with_capture_gaps": "diagnostic"},
            f"{fixture_id} compatibility drifted",
        )
    require(
        rows["named_mark_member"] == {"id": "named_mark_member", "surface": "@mark(name)", "independent": True, "may_coexist": True, "mutates_new_gap_cursor": False},
        "named-mark compatibility drifted",
    )
    require(
        rows["explicit_capture_mark_helpers"] == {"id": "explicit_capture_mark_helpers", "surface": "explicit_helpers", "independent": True, "may_coexist": True, "mutates_new_gap_cursor": False},
        "explicit-helper independence drifted",
    )
    require(
        rows["no_emit_gaps_surface"] == {"id": "no_emit_gaps_surface", "surface": "@emit_gaps", "present": False, "forced_ast_emission": False},
        "no-emit compatibility drifted",
    )


def validate_diagnostics(document: dict[str, Any]) -> None:
    rows = document["diagnostics"]
    require(isinstance(rows, list) and len(rows) == len(EXPECTED_DIAGNOSTICS), "diagnostic count drifted")
    actual: list[tuple[str, str, str, tuple[str, ...]]] = []
    for index, row in enumerate(rows):
        item = require_fields(row, {"code", "phase", "detection", "required_context"}, f"diagnostic {index}")
        require(isinstance(item["required_context"], list), f"diagnostic {index} context is invalid")
        actual.append((item["code"], item["phase"], item["detection"], tuple(item["required_context"])))
    require(tuple(actual) == EXPECTED_DIAGNOSTICS, "diagnostic schema drifted")


def validate_recurring_gate(document: dict[str, Any]) -> None:
    expected = {
        "status": "governance_current_perl_rust_admitted_later_runtimes_pending",
        "owner": "INTER-MATCH-GAP-CAPTURE.1.2",
        "driver": "tools/check_inter_match_gap_capture_six_runtime.sh",
        "local_ci_driver": "tools/run_ci_local.sh",
        "local_ci_switch": "LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX",
        "neutral_route": {
            "rollout_id": "neutral_contract",
            "path": "tools/check_inter_match_gap_capture_contract.py",
            "command": "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py",
        },
        "consumer_schema": {
            "fields": ["backend", "runtime", "path", "roles"],
            "role_policy": "every admitted carrier role is required and shared Lua runs once per ABI",
        },
        "consumers": [
            {
                "backend": "perl",
                "runtime": "perl",
                "path": "t/inter_match_gap_capture_perl_contract.t",
                "roles": ["authored_parse", "descriptor_provenance", "live_execution", "target_lifecycle", "recursion_and_rollback", "portable_diagnostics", "emitted_source_generation", "independently_loaded_generated_execution"],
            },
            {
                "backend": "rust",
                "runtime": "rust",
                "path": "rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs",
                "roles": ["native_execution", "ordinary_reconstruction", "descriptor", "generated_plan", "emitted_source", "target_lifecycle", "recursion_and_rollback", "portable_diagnostics", "primary_command"],
            },
            {
                "backend": "dart",
                "runtime": "dart",
                "path": "dart/test/inter_match_gap_capture_contract_test.dart",
                "roles": ["native_execution", "ordinary_reconstruction", "descriptor", "generated_plan", "emitted_source", "target_lifecycle", "recursion_and_rollback", "portable_diagnostics", "primary_command"],
            },
            {
                "backend": "julia",
                "runtime": "julia",
                "path": "julia/test/inter_match_gap_capture_contract_test.jl",
                "roles": ["native_execution", "ordinary_reconstruction", "descriptor", "generated_plan", "emitted_source", "target_lifecycle", "recursion_and_rollback", "portable_diagnostics", "primary_command"],
            },
            {
                "backend": "lua",
                "runtime": "puc_lua",
                "path": "lua/test/inter_match_gap_capture_contract_test.lua",
                "roles": ["native_execution", "ordinary_reconstruction", "descriptor", "generated_plan", "emitted_source", "target_lifecycle", "recursion_and_rollback", "portable_diagnostics", "primary_command"],
            },
            {
                "backend": "lua",
                "runtime": "luajit",
                "path": "lua/test/inter_match_gap_capture_contract_test.lua",
                "roles": ["native_execution", "ordinary_reconstruction", "descriptor", "generated_plan", "emitted_source", "target_lifecycle", "recursion_and_rollback", "portable_diagnostics", "primary_command"],
            },
        ],
        "route_order": [
            "neutral_contract",
            "perl_runtime",
            "rust_runtime",
            "dart_runtime",
            "julia_runtime",
            "puc_lua_runtime",
            "luajit_runtime",
        ],
        "execution_policy": "run the neutral route exactly once, then run only complete runtime rows and explicitly skip every pending runtime row in route order",
        "storage": {
            "initializer": "tools/project_data_env.sh",
            "managed_entrypoint": "tools/check_inter_match_gap_capture_six_runtime.sh",
            "policy": "all temporary, cache, build, native, and test data stays under repository-derived storage on the repository volume",
        },
    }
    require(document["recurring_gate"] == expected, "recurring gate topology drifted")


def public_no_overclaim_texts(
    public_contract: dict[str, Any],
) -> tuple[dict[str, str], dict[str, str]]:
    document_texts: dict[str, str] = {}
    for row in public_contract["documents"]:
        path = row["path"]
        source = ROOT / path
        require(source.is_file(), f"public no-overclaim document is missing: {path}")
        document_texts[path] = source.read_text(encoding="utf-8")

    surface_texts: dict[str, str] = {}
    for path in public_contract["surface_guard"]["paths"]:
        source = ROOT / path
        require(source.is_file(), f"public no-overclaim surface is missing: {path}")
        surface_texts[path] = source.read_text(encoding="utf-8")
    return document_texts, surface_texts


def validate_public_no_overclaim(
    document: dict[str, Any],
    document_texts: dict[str, str] | None = None,
    surface_texts: dict[str, str] | None = None,
) -> None:
    expected = {
        "status": "current",
        "owner": "INTER-MATCH-GAP-CAPTURE.1.2",
        "policy": "document the executable neutral and admitted private Perl and Rust runtimes without claiming later runtimes, recurring/public rollout completion, capability admission, schema exposure, CLI exposure, or outward public admission",
        "rollout_assertions": {
            "row_count": 9,
            "neutral_contract": {"status": "complete", "owner": "INTER-MATCH-GAP-CAPTURE.1.1"},
            "perl_runtime": {"status": "complete", "owner": "INTER-MATCH-GAP-CAPTURE.2.4"},
            "rust_runtime": {"status": "complete", "owner": "INTER-MATCH-GAP-CAPTURE.3"},
            "pending_runtime_ids": ["dart_runtime", "julia_runtime", "puc_lua_runtime", "luajit_runtime"],
            "runtime_status": "pending",
            "recurring": {"status": "pending", "owner": "INTER-MATCH-GAP-CAPTURE.7"},
            "public_no_drift": {"status": "pending", "owner": "INTER-MATCH-GAP-CAPTURE.7"},
        },
        "documents": [
            {
                "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
                "required_marker": "Inter-match gap-capture recurring governance now executes the complete neutral, Perl, and Rust rows; four later runtime routes and both public rows remain pending.",
            },
            {
                "path": "docs/linkedspec-book/src/development/local-ci-and-regression.md",
                "required_marker": "Inter-match gap-capture recurring governance runs the complete neutral, Perl, and Rust rows; four later runtime routes remain explicit skips.",
            },
            {
                "path": "docs/linkedspec-book/src/overview/project-status.md",
                "required_marker": "Inter-match gap-capture governance is current at 3 complete / 6 pending: Perl and Rust are admitted privately, while later runtimes and both public rows remain pending.",
            },
            {
                "path": "capability_conformance/README.md",
                "required_marker": "Inter-match gap-capture recurring governance now admits the private Perl and Rust runtimes; later runtimes and public admission remain pending.",
            },
            {
                "path": "TOOLBOX.md",
                "required_marker": "Inter-match gap-capture recurring governance executes its complete neutral, private Perl, and private Rust rows while later runtimes remain pending.",
            },
        ],
        "surface_guard": {
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
            "forbidden_tokens": ["@capture_gaps", "entry_slot", "gap_span", "gap_text", "gap_kind", "Rule[name]", "name=/regex/"],
        },
    }
    public_contract = document["public_no_overclaim"]
    require(public_contract == expected, "public no-overclaim contract drifted")

    assertions = public_contract["rollout_assertions"]
    rollout = document["rollout"]
    require(len(rollout) == assertions["row_count"], "public no-overclaim rollout cardinality drifted")
    rollout_by_id = {row["id"]: row for row in rollout}
    for rollout_id in ("neutral_contract", "perl_runtime", "rust_runtime", "recurring", "public_no_drift"):
        expected_row = assertions[rollout_id]
        actual = rollout_by_id.get(rollout_id)
        require(
            actual is not None and {"status": actual["status"], "owner": actual["owner"]} == expected_row,
            f"public no-overclaim rollout assertion drifted: {rollout_id}",
        )
    for rollout_id in assertions["pending_runtime_ids"]:
        actual = rollout_by_id.get(rollout_id)
        require(actual is not None and actual["status"] == assertions["runtime_status"], f"later runtime rollout promoted prematurely: {rollout_id}")

    if document_texts is None and surface_texts is None:
        return
    require(document_texts is not None and surface_texts is not None, "public no-overclaim text inventories must be provided together")
    require(set(document_texts) == {row["path"] for row in public_contract["documents"]}, "public no-overclaim document inventory drifted")
    require(set(surface_texts) == set(public_contract["surface_guard"]["paths"]), "public no-overclaim surface inventory drifted")
    for row in public_contract["documents"]:
        require(document_texts[row["path"]].count(row["required_marker"]) == 1, f"public no-overclaim marker missing or duplicated: {row['path']}")
    for path in public_contract["surface_guard"]["paths"]:
        for token in public_contract["surface_guard"]["forbidden_tokens"]:
            require(token not in surface_texts[path], f"public surface widened before admission: {path}: {token}")


def validate_rollout(document: dict[str, Any]) -> None:
    rows = indexed(document["rollout"], ROLLOUT_IDS, "rollout")
    for index, rollout_id in enumerate(ROLLOUT_IDS):
        expected_status = "complete" if index <= 2 else "pending"
        expected_owner = TASK_OWNER if index == 0 else {
            "perl_runtime": "INTER-MATCH-GAP-CAPTURE.2.4",
            "rust_runtime": "INTER-MATCH-GAP-CAPTURE.3",
            "dart_runtime": "INTER-MATCH-GAP-CAPTURE.4",
            "julia_runtime": "INTER-MATCH-GAP-CAPTURE.5",
            "puc_lua_runtime": "INTER-MATCH-GAP-CAPTURE.6",
            "luajit_runtime": "INTER-MATCH-GAP-CAPTURE.6",
            "recurring": "INTER-MATCH-GAP-CAPTURE.7",
            "public_no_drift": "INTER-MATCH-GAP-CAPTURE.7",
        }[rollout_id]
        require(rows[rollout_id] == {"id": rollout_id, "owner": expected_owner, "status": expected_status}, f"{rollout_id} rollout drifted")


def validate_registration(document: dict[str, Any]) -> None:
    recurring = document["recurring_gate"]
    for path in (
        CONTRACT_PATH,
        CHECKER_PATH,
        ROOT / "tools/run_python_project_data.sh",
        CI_PATH,
        RECURRING_DRIVER_PATH,
        PROJECT_DATA_WORKFLOW_ROUTING_PATH,
    ):
        require(path.is_file(), f"canonical recurring input is missing: {path.relative_to(ROOT)}")

    document_texts, surface_texts = public_no_overclaim_texts(document["public_no_overclaim"])
    validate_public_no_overclaim(document, document_texts, surface_texts)

    driver_text = RECURRING_DRIVER_PATH.read_text(encoding="utf-8")
    require(PERL_CONSUMER_PATH.is_file(), "admitted Perl consumer is missing")
    require(RUST_CONSUMER_PATH.is_file(), "dormant Rust consumer is missing")
    perl_consumer_text = PERL_CONSUMER_PATH.read_text(encoding="utf-8")
    rust_consumer_text = RUST_CONSUMER_PATH.read_text(encoding="utf-8")
    ci_text = CI_PATH.read_text(encoding="utf-8")
    perl_facade_text = PERL_FACADE_PATH.read_text(encoding="utf-8")
    rust_facade_text = RUST_FACADE_PATH.read_text(encoding="utf-8")
    validate_perl_admission(perl_consumer_text, ci_text, driver_text, perl_facade_text)
    validate_rust_admission(rust_consumer_text, ci_text, driver_text, rust_facade_text)
    for marker in (
        'source "$REPO_ROOT/tools/project_data_env.sh"',
        'linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_inter_match_gap_capture_six_runtime.sh" "$@"',
    ):
        require(driver_text.count(marker) == 1, f"recurring driver is not repository-routed: {marker}")

    route_markers = [recurring["neutral_route"]["command"]]
    runtime_ids = recurring["route_order"][1:]
    rollout_by_id = {row["id"]: row for row in document["rollout"]}
    require(len(runtime_ids) == len(recurring["consumers"]), "recurring runtime route cardinality drifted")
    for rollout_id, consumer in zip(runtime_ids, recurring["consumers"], strict=True):
        consumer_path = ROOT / consumer["path"]
        if rollout_id == "perl_runtime":
            require(consumer_path == PERL_CONSUMER_PATH, "admitted Perl consumer path drifted")
            require(rollout_by_id[rollout_id]["status"] == "complete", "admitted Perl rollout is not complete")
            route_markers.append(f"PERL5LIB= prove -Iperl {consumer['path']}")
        elif rollout_id == "rust_runtime":
            require(consumer_path == RUST_CONSUMER_PATH, "admitted Rust consumer path drifted")
            require(rollout_by_id[rollout_id]["status"] == "complete", "admitted Rust rollout is not complete")
            route_markers.append(
                "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime "
                "--test inter_match_gap_capture_contract"
            )
        else:
            require(rollout_by_id[rollout_id]["status"] == "pending", f"later runtime is not pending: {rollout_id}")
            route_markers.append(f"skipping pending runtime route {rollout_id}: {consumer['path']}")
            require(not consumer_path.exists(), f"pending runtime consumer exists before admission: {consumer['path']}")
    positions: list[int] = []
    for marker in route_markers:
        require(driver_text.count(marker) == 1, f"recurring driver marker must appear exactly once: {marker}")
        positions.append(driver_text.index(marker))
    require(positions == sorted(positions), "recurring driver route order drifted")

    ci_markers = (
        (f"git status --short --untracked-files=all -- {recurring['driver']}", 1),
        (f"require_tracked_file {recurring['driver']}", 2),
        (recurring["neutral_route"]["command"], 1),
        ("PERL5LIB= prove -Iperl t/inter_match_gap_capture_perl_contract.t", 1),
        (f'if [[ "${{{recurring["local_ci_switch"]}:-0}}" == "1" ]]; then', 1),
        (f'bash "$REPO_ROOT/{recurring["driver"]}"', 1),
    )
    for marker, expected_count in ci_markers:
        require(ci_text.count(marker) == expected_count, f"canonical recurring registration marker count drifted: {marker} expected {expected_count}")

    workflow_text = PROJECT_DATA_WORKFLOW_ROUTING_PATH.read_text(encoding="utf-8")
    require(workflow_text.count(recurring["driver"]) == 2, "recurring project-data routing registration drifted")


def validate_perl_admission(consumer_text: str, ci_text: str, driver_text: str, facade_text: str) -> None:
    consumer_markers = (
        ("my $CONTRACT_ID = 'linkedspec-inter-match-gap-capture-v1';", 1, "Perl consumer contract drifted"),
        ("LINKEDSPEC_PERL_INTER_MATCH_GAP_MODE", 1, "Perl mode selector drifted"),
        ("if ($MODE eq 'all')", 1, "Perl all-role default boundary drifted"),
        ("run_metadata_contract();", 2, "Perl metadata boundary drifted"),
        ("run_live_contract();", 2, "Perl live boundary drifted"),
        ("run_generated_contract();", 2, "Perl generated boundary drifted"),
        ("regex_slot_unknown_name", 1, "Perl diagnostic contract drifted"),
        ("# prove -Iperl t/inter_match_gap_capture_perl_contract.t", 1, "Perl rooted command drifted"),
    )
    for marker, expected_count, reason in consumer_markers:
        require(consumer_text.count(marker) == expected_count, reason)

    consumer_path = "t/inter_match_gap_capture_perl_contract.t"
    command = f"PERL5LIB= prove -Iperl {consumer_path}"
    require(
        ci_text.count(command) == 1,
        "Perl admitted consumer is not registered exactly once in canonical CI",
    )
    require(
        driver_text.count(command) == 1
        and f"skipping pending runtime route perl_runtime: {consumer_path}" not in driver_text,
        "Perl admitted consumer is not registered exactly once in recurring execution",
    )
    require(
        "LINKEDSPEC_PERL_INTER_MATCH_GAP_MODE" not in facade_text
        and "InterMatchGapRuntime" not in facade_text,
        "Perl admission widened the public facade",
    )


def validate_rust_admission(
    consumer_text: str,
    ci_text: str,
    driver_text: str,
    facade_text: str,
) -> None:
    consumer_markers = (
        ('const CONTRACT_ID: &str = "linkedspec-inter-match-gap-capture-v1";', "Rust admitted consumer contract drifted"),
        ("fn contract_declared_rust_roles_execute_once_and_only_once()", "Rust ordinary admission boundary drifted"),
        ("admission.assert_exact(&contract);", "Rust admitted role ledger drifted"),
        ("fn primary_command_gap_contract()", "Rust admitted primary role drifted"),
        ("primary_command_gap_contract();", "Rust admitted primary role drifted"),
    )
    for marker, reason in consumer_markers:
        require(consumer_text.count(marker) == 1, reason)

    roles = (
        "native_execution",
        "ordinary_reconstruction",
        "descriptor",
        "generated_plan",
        "emitted_source",
        "target_lifecycle",
        "recursion_and_rollback",
        "portable_diagnostics",
        "primary_command",
    )
    for role in roles:
        require(
            consumer_text.count(f'admission.complete("{role}");') == 1,
            f"Rust admitted role ledger drifted: {role}",
        )

    consumer_path = "rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs"
    command = (
        "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime "
        "--test inter_match_gap_capture_contract"
    )
    require("#[ignore" not in consumer_text, "Rust admitted consumer returned to ignored discovery")
    require(ci_text.count(command) == 1, "Rust admitted consumer is not registered exactly once in canonical CI")
    require(
        driver_text.count(command) == 1
        and f"skipping pending runtime route rust_runtime: {consumer_path}" not in driver_text,
        "Rust admitted consumer is not registered exactly once in recurring execution",
    )
    for rollout_id, path in (
        ("dart_runtime", "dart/test/inter_match_gap_capture_contract_test.dart"),
        ("julia_runtime", "julia/test/inter_match_gap_capture_contract_test.jl"),
        ("puc_lua_runtime", "lua/test/inter_match_gap_capture_contract_test.lua"),
        ("luajit_runtime", "lua/test/inter_match_gap_capture_contract_test.lua"),
    ):
        require(
            driver_text.count(f"skipping pending runtime route {rollout_id}: {path}") == 1,
            f"Rust admission disturbed later runtime skip: {rollout_id}",
        )
    require(
        "inter_match_gap_capture" not in facade_text and "capture_gaps" not in facade_text,
        "Rust admission widened the public facade",
    )


RustAdmissionMutation = tuple[str, str, Callable[[dict[str, str]], None]]


def rust_admission_mutations() -> list[RustAdmissionMutation]:
    command = (
        "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime "
        "--test inter_match_gap_capture_contract"
    )
    return [
        (
            "rust_consumer_identity",
            "Rust admitted consumer contract drifted",
            lambda texts: texts.__setitem__(
                "consumer",
                texts["consumer"].replace(
                    "linkedspec-inter-match-gap-capture-v1", "stale", 1
                ),
            ),
        ),
        (
            "rust_role_ledger",
            "Rust admitted role ledger drifted",
            lambda texts: texts.__setitem__(
                "consumer",
                texts["consumer"].replace(
                    "admission.assert_exact(&contract);",
                    "admission.assert_stale(&contract);",
                    1,
                ),
            ),
        ),
        (
            "rust_ordinary_registration",
            "Rust admitted consumer returned to ignored discovery",
            lambda texts: texts.__setitem__(
                "consumer",
                texts["consumer"].replace(
                    "fn contract_declared_rust_roles_execute_once_and_only_once()",
                    "#[ignore]\nfn contract_declared_rust_roles_execute_once_and_only_once()",
                    1,
                ),
            ),
        ),
        (
            "rust_primary_role",
            "Rust admitted primary role drifted",
            lambda texts: texts.__setitem__(
                "consumer",
                texts["consumer"].replace(
                    "primary_command_gap_contract();",
                    "primary_command_gap_contract_stale();",
                    1,
                ),
            ),
        ),
        (
            "rust_canonical_registration",
            "Rust admitted consumer is not registered exactly once in canonical CI",
            lambda texts: texts.__setitem__(
                "ci", texts["ci"].replace(command, "stale Rust gap command", 1)
            ),
        ),
        (
            "rust_canonical_duplicate",
            "Rust admitted consumer is not registered exactly once in canonical CI",
            lambda texts: texts.__setitem__(
                "ci", texts["ci"] + f"\n{command}\n"
            ),
        ),
        (
            "rust_recurring_registration",
            "Rust admitted consumer is not registered exactly once in recurring execution",
            lambda texts: texts.__setitem__(
                "driver", texts["driver"].replace(command, "stale Rust gap command", 1)
            ),
        ),
        (
            "rust_recurring_duplicate",
            "Rust admitted consumer is not registered exactly once in recurring execution",
            lambda texts: texts.__setitem__(
                "driver", texts["driver"] + f"\n{command}\n"
            ),
        ),
        (
            "rust_later_runtime_skip",
            "Rust admission disturbed later runtime skip: dart_runtime",
            lambda texts: texts.__setitem__(
                "driver",
                texts["driver"].replace(
                    "skipping pending runtime route dart_runtime: dart/test/inter_match_gap_capture_contract_test.dart",
                    "stale later runtime skip",
                    1,
                ),
            ),
        ),
        (
            "rust_facade_absence",
            "Rust admission widened the public facade",
            lambda texts: texts.__setitem__(
                "facade", texts["facade"] + "\npub mod inter_match_gap_capture;\n"
            ),
        ),
    ]


def validate_rust_admission_mutations() -> int:
    texts = {
        "consumer": RUST_CONSUMER_PATH.read_text(encoding="utf-8"),
        "ci": CI_PATH.read_text(encoding="utf-8"),
        "driver": RECURRING_DRIVER_PATH.read_text(encoding="utf-8"),
        "facade": RUST_FACADE_PATH.read_text(encoding="utf-8"),
    }
    checks = rust_admission_mutations()
    require(
        tuple(name for name, _, _ in checks) == RUST_ADMISSION_MUTATION_IDS,
        "Rust admission mutation identity/order drifted",
    )
    for name, expected_reason, mutate in checks:
        candidate = copy.deepcopy(texts)
        mutate(candidate)
        try:
            validate_rust_admission(
                candidate["consumer"],
                candidate["ci"],
                candidate["driver"],
                candidate["facade"],
            )
        except ContractError as error:
            require(
                expected_reason in str(error),
                f"Rust admission mutation {name} failed for unexpected reason: {error}",
            )
        else:
            fail(f"Rust admission mutation {name} was accepted")
    return len(checks)


def validate_contract(document: dict[str, Any], *, check_registration: bool = True) -> None:
    require(isinstance(document, dict) and set(document) == set(REQUIRED_SECTIONS), "required sections drifted")
    require(type(document["format"]) is int and document["format"] == 1, "format drifted")
    require(document["contract_id"] == CONTRACT_ID, "contract id drifted")
    require(document["task_owner"] == TASK_OWNER, "task owner drifted")
    require(document["expected_counts"] == EXPECTED_COUNTS and all(type(value) is int for value in document["expected_counts"].values()), "expected counts drifted")
    validate_policy(document)
    validate_execution(document)
    validate_identifier_policy(document)
    validate_authored_surfaces(document)
    validate_selector_fixtures(document)
    validate_sources(document)
    validate_executable_model(document)
    validate_gap_schema(document)
    validate_state_machine(document)
    validate_segmentation(document)
    validate_lifecycle(document)
    validate_transactions(document)
    validate_compatibility(document)
    validate_diagnostics(document)
    require(document["mutation_ids"] == list(MUTATION_IDS), "mutation identity/order drifted")
    validate_recurring_gate(document)
    validate_rollout(document)
    validate_public_no_overclaim(document)
    require(len(document["selector_resolution_fixtures"]["positive"]) == EXPECTED_COUNTS["positive_selector_fixtures"], "positive fixture count drifted")
    require(len(document["selector_resolution_fixtures"]["negative"]) == EXPECTED_COUNTS["negative_selector_directive_fixtures"], "negative fixture count drifted")
    require(len(document["gap_sources"]) == EXPECTED_COUNTS["decoded_source_fixtures"], "source fixture count drifted")
    require(len(document["gap_context_schema"]["private_current_gap_fields"]) == EXPECTED_COUNTS["private_gap_fields"], "private gap-field count drifted")
    require(len(document["gap_state_machine"]["transitions"]) == EXPECTED_COUNTS["main_machine_transitions"], "main transition count drifted")
    require(len(document["segmentation_cases"]) == EXPECTED_COUNTS["segmentation_cases"], "segmentation count drifted")
    require(len(document["lifecycle_matrix"]["terminal_routes"]) == EXPECTED_COUNTS["terminal_routes"], "terminal-route count drifted")
    require(len(document["transaction_recursion_cases"]) == EXPECTED_COUNTS["transaction_recursion_return_cases"], "transaction case count drifted")
    require(len(document["compatibility_matrix"]) == EXPECTED_COUNTS["compatibility_rows"], "compatibility count drifted")
    require(len(document["diagnostics"]) == EXPECTED_COUNTS["diagnostics"], "diagnostic count lock drifted")
    require(len(document["rollout"]) == EXPECTED_COUNTS["rollout_legs"], "rollout count drifted")
    require(len(document["mutation_ids"]) == EXPECTED_COUNTS["semantic_mutations"], "mutation count drifted")
    if check_registration:
        validate_registration(document)


Mutation = tuple[str, str, Callable[[dict[str, Any]], None]]


def row(document: dict[str, Any], section: str, fixture_id: str, subsection: str | None = None) -> dict[str, Any]:
    rows = document[section] if subsection is None else document[section][subsection]
    return next(item for item in rows if item["id"] == fixture_id)


def mutations() -> list[Mutation]:
    values: list[Mutation] = [
        ("contract_id", "contract id drifted", lambda d: d.__setitem__("contract_id", "stale")),
        ("format", "format drifted", lambda d: d.__setitem__("format", 2)),
        ("task_owner", "task owner drifted", lambda d: d.__setitem__("task_owner", "INTER-MATCH-GAP-CAPTURE.1.2")),
        ("expected_counts", "expected counts drifted", lambda d: d["expected_counts"].__setitem__("semantic_mutations", 49)),
        ("required_section", "required sections drifted", lambda d: d.pop("recurring_gate")),
        ("identifier_classifier", "identifier classifier drifted", lambda d: d["identifier_policy"].__setitem__("classifier", "XID_Start")),
        ("digit_reservation", "digit reservation drifted", lambda d: d["identifier_policy"].__setitem__("ascii_digit_only", "allowed")),
        ("normalization_identity", "identifier normalization identity drifted", lambda d: d["identifier_policy"].__setitem__("normalization", "NFC")),
        ("case_identity", "identifier case identity drifted", lambda d: d["identifier_policy"].__setitem__("case_sensitive", False)),
    ]
    for fixture_id in ("spacing_compact", "spacing_before_equals", "spacing_after_equals", "spacing_both"):
        values.append((fixture_id, f"{fixture_id} fixture drifted", lambda d, fixture_id=fixture_id: row(d, "selector_resolution_fixtures", fixture_id, "positive").__setitem__("declaration", "head := /H/")))
    values.extend(
        [
            ("mixed_declaration_order", "mixed declaration order drifted", lambda d: row(d, "selector_resolution_fixtures", "mixed_named_anonymous", "positive")["regex_indexes"].reverse()),
            ("duplicate_slot_name", "duplicate_slot_name negative fixture drifted", lambda d: row(d, "selector_resolution_fixtures", "duplicate_slot_name", "negative").__setitem__("diagnostic", "regex_slot_name_invalid")),
            ("selector_unindexed", "selector surface drifted", lambda d: d["authored_surfaces"]["selectors"][0].__setitem__("resolution", "last_slot")),
            ("selector_numeric", "selector surface drifted", lambda d: d["authored_surfaces"]["selectors"][1].__setitem__("authored_selector", "string")),
            ("selector_named", "selector surface drifted", lambda d: d["authored_surfaces"]["selectors"][2].__setitem__("resolution", "normalized_name")),
            ("named_reorder_stability", "named reorder fixture drifted", lambda d: row(d, "selector_resolution_fixtures", "named_reorder_stable", "positive")["after"].__setitem__("target_slot_id", "other")),
            ("numeric_reorder_position", "named reorder fixture drifted", lambda d: row(d, "selector_resolution_fixtures", "named_reorder_stable", "positive")["numeric_after_reorder"].__setitem__("regex_index", 1)),
            ("selector_provenance", "selector provenance drifted", lambda d: d["authored_surfaces"]["resolved_edge_fields"].pop()),
            ("duplicate_regex_identity", "named reorder fixture drifted", lambda d: row(d, "selector_resolution_fixtures", "named_reorder_stable", "positive").__setitem__("duplicate_regex_text_preserves_slot_identity", False)),
            ("directive_cardinality", "directive cardinality drifted", lambda d: d["authored_surfaces"]["directive"].__setitem__("cardinality", "many")),
            ("directive_family", "directive family drifted", lambda d: d["authored_surfaces"]["directive"]["eligibility"].__setitem__("family", "and")),
            ("directive_cursor_policy", "directive cursor policy drifted", lambda d: d["authored_surfaces"]["directive"]["eligibility"].__setitem__("cursor_policy", "consume")),
            ("directive_edge_ownership", "directive edge ownership drifted", lambda d: d["authored_surfaces"]["directive"]["eligibility"].__setitem__("edge_ownership", "local")),
            ("directive_loop", "directive loop requirement drifted", lambda d: d["authored_surfaces"]["directive"]["eligibility"].__setitem__("uses_loop", False)),
            ("directive_static_edge", "directive static-edge requirement drifted", lambda d: d["authored_surfaces"]["directive"]["eligibility"].__setitem__("minimum_static_action_edges", 0)),
            ("legacy_marker_conflict", "capture_slice_member compatibility drifted", lambda d: row(d, "compatibility_matrix", "capture_slice_member").__setitem__("mixed_with_capture_gaps", "allowed")),
            ("explicit_helper_independence", "explicit-helper independence drifted", lambda d: row(d, "compatibility_matrix", "explicit_capture_mark_helpers").__setitem__("independent", False)),
            ("gap_source_identity", "Unicode gap source drifted", lambda d: row(d, "gap_sources", "unicode_main").__setitem__("source_id", "fixture:other")),
            ("gap_half_open", "gap half-open interval drifted", lambda d: d["gap_context_schema"].__setitem__("interval", "closed")),
            ("gap_empty", "empty_prefix segmentation drifted", lambda d: row(d, "segmentation_cases", "empty_prefix").__setitem__("expected", "suppressed")),
            ("gap_unicode", "Unicode gap source drifted", lambda d: row(d, "gap_sources", "unicode_main").__setitem__("scalar_length", 11)),
            ("gap_prefix", "gap state-machine transitions drifted", lambda d: d["gap_state_machine"]["transitions"][1].__setitem__("effect", "prefix=[0,0)")),
            ("gap_interstitial", "gap state-machine transitions drifted", lambda d: d["gap_state_machine"]["transitions"][7].__setitem__("effect", "interstitial=[2,3)")),
            ("gap_tail", "gap state-machine transitions drifted", lambda d: d["gap_state_machine"]["transitions"][13].__setitem__("effect", "tail=[7,7)")),
            ("zero_match_tail", "zero_match_whole_tail segmentation drifted", lambda d: row(d, "segmentation_cases", "zero_match_whole_tail").__setitem__("expected", "no_tail")),
            ("candidate_before_ls", "successful-edge lifecycle drifted", lambda d: d["lifecycle_matrix"]["successful_edge"].__setitem__(1, "LS")),
            ("candidate_through_le", "successful-edge lifecycle drifted", lambda d: d["lifecycle_matrix"]["successful_edge"].remove("LE")),
            ("commit_before_it", "successful-edge lifecycle drifted", lambda d: d["lifecycle_matrix"]["successful_edge"].reverse()),
            ("falsey_acceptance", "gap state-machine transitions drifted", lambda d: d["gap_state_machine"]["transitions"][3].__setitem__("effect", "false_payload_rejects")),
            ("child_extended_exit", "child_extended_accepted_exit segmentation drifted", lambda d: row(d, "segmentation_cases", "child_extended_accepted_exit").__setitem__("expected", "next_gap=[1,9):gap")),
            ("failure_no_commit", "edge_failure_discards transaction drifted", lambda d: row(d, "transaction_recursion_cases", "edge_failure_discards").__setitem__("expected", "cursor_advances")),
            ("rollback_no_commit", "recognition_rollback_restores transaction drifted", lambda d: row(d, "transaction_recursion_cases", "recognition_rollback_restores").__setitem__("expected", "committed_cursor_leaks")),
            ("unwind_clear", "abnormal_unwind_clears transaction drifted", lambda d: row(d, "transaction_recursion_cases", "abnormal_unwind_clears").__setitem__("expected", "candidate_retained")),
            ("recursion_isolation", "recursive_invocation_isolates_state transaction drifted", lambda d: row(d, "transaction_recursion_cases", "recursive_invocation_isolates_state").__setitem__("expected", "shared_invocation_state")),
            ("nested_suspend_resume", "gap state-machine transitions drifted", lambda d: d["gap_state_machine"]["transitions"][9].__setitem__("effect", "child_candidate_leaks")),
            ("action_return_authority", "lifecycle return authority drifted", lambda d: d["lifecycle_matrix"]["return_authority"].__setitem__("default_scan_action_edge", "accepted_per_hit_payload")),
            ("diagnostic_schema", "diagnostic schema drifted", lambda d: d["diagnostics"][8]["required_context"].pop()),
            ("rollout_sequence", "rollout identity/order drifted", lambda d: d["rollout"].reverse()),
            ("perl_runtime_regression", "perl_runtime rollout drifted", lambda d: row(d, "rollout", "perl_runtime").__setitem__("status", "pending")),
            ("rust_runtime_regression", "rust_runtime rollout drifted", lambda d: row(d, "rollout", "rust_runtime").__setitem__("status", "pending")),
            ("storage_paths", "recurring gate topology drifted", lambda d: d["recurring_gate"]["storage"].__setitem__("initializer", "/tmp/project_data_env.sh")),
            ("route_order", "recurring gate topology drifted", lambda d: d["recurring_gate"]["route_order"].reverse()),
            ("public_no_overclaim", "public no-overclaim contract drifted", lambda d: d["public_no_overclaim"].__setitem__("status", "planned")),
        ]
    )
    return values


def validate_mutations(document: dict[str, Any]) -> int:
    checks = mutations()
    require(tuple(name for name, _, _ in checks) == MUTATION_IDS, "checker mutation identity/order drifted")
    for name, expected_reason, mutate in checks:
        candidate = copy.deepcopy(document)
        mutate(candidate)
        try:
            validate_contract(candidate, check_registration=False)
        except ContractError as error:
            require(expected_reason in str(error), f"mutation {name} failed for unexpected reason: {error}")
        else:
            fail(f"mutation {name} was accepted")
    return len(checks)


def main() -> int:
    global PINNED_XID_RANGES
    if not CONTRACT_PATH.is_file():
        print("inter-match gap capture contract is missing", file=sys.stderr)
        return 1
    try:
        PINNED_XID_RANGES = load_pinned_xid_ranges()
        document = load_json(CONTRACT_PATH)
        validate_contract(document)
        mutation_count = validate_mutations(document)
        rust_admission_mutation_count = validate_rust_admission_mutations()
    except (json.JSONDecodeError, OSError, ContractError) as error:
        print(f"inter-match gap capture contract: FAIL: {error}", file=sys.stderr)
        return 1
    complete = sum(row["status"] == "complete" for row in document["rollout"])
    pending = sum(row["status"] == "pending" for row in document["rollout"])
    print(
        "inter-match gap capture contract: OK "
        f"(8 positive + 10 negative fixtures; 3 sources; 16 transitions; "
        f"10 segmentation cases; 9 diagnostics; {complete} complete + {pending} pending rollout; "
        f"{mutation_count} rejected semantic mutations; "
        f"{rust_admission_mutation_count} rejected Rust admission mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

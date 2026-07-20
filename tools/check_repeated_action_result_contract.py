#!/usr/bin/env python3
"""Validate ADR 0048's explicit-repetition action-result contract."""

from __future__ import annotations

import copy
import hashlib
import json
import re
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "repeated_action_result_contract.json"
CONTRACT_ID = "linkedspec-explicit-repetition-action-result-v1"
TASK_OWNER = "FUTURE-PARITY-BACKLOG.9.1.10"
TOP_LEVEL_FIELDS = {
    "format",
    "contract_id",
    "task_owner",
    "decision",
    "scope",
    "semantics",
    "mode_cases",
    "special_cases",
    "descriptor_contract",
    "generated_source_v2",
    "trace_contract",
    "required_routes",
    "corpus_bundle",
    "admissions",
    "implementation_inventory",
    "rollout",
    "migration",
    "canonical_ci",
}
CASE_FIELDS = {
    "id",
    "header",
    "source",
    "input",
    "edge_surface",
    "rep_min",
    "rep_max",
    "is_repetition",
    "generated_family",
    "alternatives",
    "result_policy",
    "lifecycle_override",
    "expected_result",
    "expected_position",
    "expected_selected_slots",
}
MODE_IDS = [
    "compact_star_two_hits",
    "compact_plus_two_hits",
    "compact_optional_one_hit",
    "explicit_or_two_hits",
    "explicit_or_plus_two_hits",
    "bounded_exact_two_hits",
    "bounded_up_to_two_hits",
    "pipe_distinct_scalar",
]
SPECIAL_IDS = [
    "duplicate_or_first_authored_each_hit",
    "nested_value_stays_nested",
    "null_value_stays_element",
    "fluent_return_collects",
    "zero_permitted_hits_empty",
    "below_minimum_is_null",
    "exit_lifecycle_overrides_collection",
    "loop_end_lifecycle_exits_rule",
    "pipe_duplicate_first_scalar",
    "blind_or_repeats",
]
SOURCE_DIGESTS = {
    "compact_star_two_hits": "42b7bb6b29e88774292f57bcf2278af6e315e16daf4076f98b9c0c8264176f86",
    "compact_plus_two_hits": "a456afcd7d80e86dfaf0f6ab3eebe0993079e5bb6f29dac71334b41094b0504c",
    "compact_optional_one_hit": "c35d0b46b610460486ea7ec94b2a9bfd2a85af7af4246872488cfb6e49cc2e95",
    "explicit_or_two_hits": "8dec8cfda7ca7266674a1a8da3c47611fbd34affef6e3a2044b0fa48468fe1d6",
    "explicit_or_plus_two_hits": "6d9e015b40f31510b14833dd006ae1f2e01f3569cb96627b84c38faff558bcea",
    "bounded_exact_two_hits": "e224b813a4a3c79bef65b33c8ac5c1eaeb75e231da5ec3844233b4a8d796351a",
    "bounded_up_to_two_hits": "4d9c835eeb19520f1b1b1851e5cb18ef5d252d43ea48a1f724007e5e0c6f5b6a",
    "pipe_distinct_scalar": "8ba383e529adf76ac1260d7b6e4ecfc37702ac18be04b60d1f0f356eb7df28de",
    "duplicate_or_first_authored_each_hit": "d0e33132dea6a7aeebb1b3339eb6e2d1a0b0267e8b42e2ef64ef30a7b6c6d602",
    "nested_value_stays_nested": "b4fc79fc2de5950e67fa76ba3181cd797e0627d1d3fa82d75edd6abad20a4e9c",
    "null_value_stays_element": "7236e54c6edaf4a816edce900e4aedec1abb60445bf867b062b086b83790899f",
    "fluent_return_collects": "56c4b167ca922609a4142d81eb9077905418afa2769bba5c91c6bf496380e29b",
    "zero_permitted_hits_empty": "5da81a9f5cb9528c357e69f2c842e5ac8d05120bdf6a8efac7b52b4f17215dae",
    "below_minimum_is_null": "fddd3138ef81fc6a2a80a80ab38ec919fcd73a7fd610d3496d1ae03636501333",
    "exit_lifecycle_overrides_collection": "172819c95d3cb8be188eb16d62198d5669d7bd2f947e85f5036873b46a59b679",
    "loop_end_lifecycle_exits_rule": "2701f6bfd3c4c26a1f39e7305baaf216c5cad04b500b5b95aba00c4f91172b28",
    "pipe_duplicate_first_scalar": "d03497cb088cb022132bd2119a4b48322406b420b1a6f2ab8e4a6400dfceafad",
    "blind_or_repeats": "148fdff28cc327ddee7cb9d420cb4a4ea678dd025962a892d03ea8e1366cf998",
}
MODE_EXPECTATIONS = {
    "compact_star_two_hits": ("Top::*", 0, None, "rep_acode"),
    "compact_plus_two_hits": ("Top::+", 1, None, "rep_acode"),
    "compact_optional_one_hit": ("Top::?", 0, 1, "rep_acode"),
    "explicit_or_two_hits": ("Top::OR", 1, None, "rep_acode"),
    "explicit_or_plus_two_hits": ("Top::OR+", 1, None, "rep_acode"),
    "bounded_exact_two_hits": ("Top::OR{2}", 2, 2, "rep_acode"),
    "bounded_up_to_two_hits": ("Top::OR{,2}", 0, 2, "rep_acode"),
    "pipe_distinct_scalar": ("Top::|", None, None, "or_acode"),
}
PERL_ROLES = [
    "neutral_contract",
    "live_mode_matrix",
    "live_special_cases",
    "loaded",
    "descriptor",
    "emitted_source",
    "generated_direct",
    "generated_trace",
    "primary_cli",
    "corpus_bundle",
]
ROLLOUT = [
    ("neutral_contract", "complete", "FUTURE-PARITY-BACKLOG.9.1.10.1"),
    ("perl_reference", "complete", "FUTURE-PARITY-BACKLOG.9.1.10.1"),
    ("rust", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.2"),
    ("dart", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.3"),
    ("julia", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.4"),
    ("lua_dual_abi", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.5"),
    ("recurring", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.6"),
    ("public_no_drift", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.7"),
]
INVENTORY = [
    ("perl", "perl", "rep_acode", "iteration_value", "implemented", "FUTURE-PARITY-BACKLOG.9.1.10.1"),
    ("rust", "rust", "or_acode", "whole_rule_exit", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.2"),
    ("dart", "dart", "or_acode", "whole_rule_exit", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.3"),
    ("julia", "julia", "or_acode", "whole_rule_exit", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.4"),
    ("lua", "puc_lua", "or_acode", "whole_rule_exit", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.5"),
    ("lua", "luajit", "or_acode", "whole_rule_exit", "pending", "FUTURE-PARITY-BACKLOG.9.1.10.5"),
]


class ContractError(ValueError):
    """Stable neutral-contract validation failure."""


def require(condition: bool, detail: str) -> None:
    if not condition:
        raise ContractError(detail)


def require_fields(value: Any, fields: set[str], context: str) -> dict[str, Any]:
    require(isinstance(value, dict) and set(value) == fields, f"{context} fields drifted")
    return value


def evaluate_case(case: dict[str, Any]) -> tuple[Any, int, list[str]]:
    cursor = 0
    values: list[Any] = []
    selected: list[str] = []
    iterations = 0
    maximum = case["rep_max"] if case["is_repetition"] else 1
    while maximum is None or iterations < maximum:
        candidates: list[tuple[int, int, re.Match[str], dict[str, Any]]] = []
        for order, alternative in enumerate(case["alternatives"]):
            match = re.compile(alternative["pattern"]).search(case["input"], cursor)
            if match is not None:
                candidates.append((match.start(), order, match, alternative))
        if not candidates:
            break
        _, _, match, alternative = min(candidates, key=lambda item: (item[0], item[1]))
        before = cursor
        cursor = match.end()
        iterations += 1
        values.append(copy.deepcopy(alternative["value"]))
        selected.append(alternative["identity"])
        override = case["lifecycle_override"]
        if override is not None and override["marker"] == "LE" and iterations == override["after_hits"]:
            return copy.deepcopy(override["value"]), cursor, selected
        if not case["is_repetition"] or cursor == before:
            break
    override = case["lifecycle_override"]
    if override is not None and override["marker"] == "E" and iterations == override["after_hits"]:
        return copy.deepcopy(override["value"]), cursor, selected
    minimum = case["rep_min"] or 0
    if iterations < minimum:
        return None, cursor, selected
    if case["result_policy"] == "scalar":
        return (copy.deepcopy(values[0]) if values else None), cursor, selected
    return values, cursor, selected


def validate_case(case: Any, context: str) -> None:
    case = require_fields(case, CASE_FIELDS, context)
    case_id = case["id"]
    require(isinstance(case_id, str) and case_id in SOURCE_DIGESTS, f"{context} id drifted")
    require(case["source"].endswith("\n") and case["source"].startswith(case["header"] + "\n"), f"{case_id} source/header drifted")
    digest = hashlib.sha256(case["source"].encode("utf-8")).hexdigest()
    require(digest == SOURCE_DIGESTS[case_id], f"{case_id} exact source bytes drifted")
    require(case["edge_surface"] in {"action_block", "action_fluent", "blind"}, f"{case_id} edge surface drifted")
    require(case["generated_family"] in {"rep_acode", "rep_bcode", "or_acode"}, f"{case_id} family drifted")
    require(case["result_policy"] in {"collect", "scalar", "lifecycle_override"}, f"{case_id} result policy drifted")
    require(isinstance(case["alternatives"], list) and case["alternatives"], f"{case_id} alternatives drifted")
    identities: set[str] = set()
    for index, alternative in enumerate(case["alternatives"]):
        alternative = require_fields(alternative, {"pattern", "value", "identity"}, f"{case_id} alternative {index}")
        require(isinstance(alternative["pattern"], str), f"{case_id} pattern drifted")
        re.compile(alternative["pattern"])
        require(isinstance(alternative["identity"], str) and alternative["identity"] not in identities, f"{case_id} identity drifted")
        identities.add(alternative["identity"])
    if case["is_repetition"]:
        require(isinstance(case["rep_min"], int) and case["rep_min"] >= 0, f"{case_id} repetition minimum drifted")
        require(case["generated_family"].startswith("rep_"), f"{case_id} repeated family drifted")
    else:
        require(case["rep_min"] is None and case["rep_max"] is None, f"{case_id} pipe bounds drifted")
        require(case["result_policy"] == "scalar" and case["generated_family"] == "or_acode", f"{case_id} pipe semantics drifted")
    if case["rep_max"] is not None:
        require(isinstance(case["rep_max"], int) and case["rep_max"] >= (case["rep_min"] or 0), f"{case_id} maximum drifted")
    override = case["lifecycle_override"]
    if case["result_policy"] == "lifecycle_override":
        override = require_fields(override, {"marker", "value", "after_hits"}, f"{case_id} lifecycle override")
        require(override["marker"] in {"LE", "E"} and override["after_hits"] >= 1, f"{case_id} lifecycle authority drifted")
    else:
        require(override is None, f"{case_id} unexpected lifecycle override")
    result, position, selected = evaluate_case(case)
    require(result == case["expected_result"], f"{case_id} neutral result model drifted")
    require(position == case["expected_position"], f"{case_id} neutral cursor model drifted")
    require(selected == case["expected_selected_slots"], f"{case_id} selected-slot model drifted")


def validate_contract(contract: dict[str, Any], *, check_filesystem: bool = True) -> None:
    require_fields(contract, TOP_LEVEL_FIELDS, "contract")
    require(contract["format"] == 1, "format drifted")
    require(contract["contract_id"] == CONTRACT_ID, "contract id drifted")
    require(contract["task_owner"] == TASK_OWNER, "task owner drifted")
    require(contract["decision"] == "docs/decisions/0048-explicit-repetition-action-result-collection.md", "decision path drifted")

    scope = require_fields(contract["scope"], {"explicit_repetition_modes", "single_choice_control", "unadorned_default_handler_in_scope", "action_surfaces", "edge_families"}, "scope")
    require(scope["explicit_repetition_modes"] == ["Star", "Plus", "Optional", "Or", "OrPlus", "OrBounded"], "explicit mode inventory drifted")
    require(scope["single_choice_control"] == "Pipe", "pipe control drifted")
    require(scope["unadorned_default_handler_in_scope"] is False, "default handler scope widened")
    require(scope["action_surfaces"] == ["block_return", "fluent_return"], "action surfaces drifted")
    require(scope["edge_families"] == ["action", "blind_classification_control"], "edge family scope drifted")

    semantics = require_fields(contract["semantics"], {"repeated_action_return", "default_repeated_result", "returned_array_policy", "returned_null_policy", "pipe_action_return", "lifecycle_return", "bare_or_bounds", "zero_permitted_hits", "below_minimum", "bounds_count", "zero_progress", "preserved_contracts"}, "semantics")
    require(semantics["repeated_action_return"] == "one_typed_iteration_value_per_successful_hit", "action return drifted")
    require(semantics["default_repeated_result"] == "flat_ordered_collection_of_iteration_values", "collection shape drifted")
    require(semantics["returned_array_policy"] == "one_nested_outer_element", "nested value drifted")
    require(semantics["returned_null_policy"] == "one_null_outer_element", "null value drifted")
    require(semantics["pipe_action_return"] == "direct_scalar_value", "pipe result drifted")
    require(semantics["lifecycle_return"] == "whole_rule_return", "lifecycle authority drifted")
    require(semantics["bare_or_bounds"] == {"min": 1, "max": None}, "bare OR bounds drifted")
    require(semantics["zero_permitted_hits"] == [] and semantics["below_minimum"] is None, "zero/minimum result drifted")
    require(semantics["bounds_count"] == "accepted_hits" and semantics["zero_progress"] == "accept_once_then_stop", "bounds/progress drifted")
    require(semantics["preserved_contracts"] == ["linkedspec-rule-local-cursor-v1", "linkedspec-duplicate-regex-slot-identity-v1", "linkedspec-generated-source-v2"], "preserved contract inventory drifted")

    require([case.get("id") for case in contract["mode_cases"]] == MODE_IDS, "mode case order drifted")
    require([case.get("id") for case in contract["special_cases"]] == SPECIAL_IDS, "special case order drifted")
    for case in contract["mode_cases"] + contract["special_cases"]:
        validate_case(case, f"case {case.get('id')}")
    for case in contract["mode_cases"]:
        expected = MODE_EXPECTATIONS[case["id"]]
        require((case["header"], case["rep_min"], case["rep_max"], case["generated_family"]) == expected, f"{case['id']} mode contract drifted")

    descriptor = require_fields(contract["descriptor_contract"], {"family", "cursor_policy", "bare_or", "pipe", "perl_unbounded_sentinel", "new_mutable_result_option"}, "descriptor")
    require(descriptor["family"] == "or_default" and descriptor["cursor_policy"] == "seek", "descriptor family/cursor drifted")
    require(descriptor["bare_or"] == {"execution_shape": "repeat_loop", "rep_min": 1, "rep_max": None, "handler_family": "rep_acode", "uses_loop": True}, "bare OR descriptor drifted")
    require(descriptor["pipe"] == {"execution_shape": "or_choice_dispatch", "rep_min": None, "rep_max": None, "handler_family": "or_acode", "uses_loop": False}, "pipe descriptor drifted")
    require(descriptor["perl_unbounded_sentinel"] == 1_000_000_000 and descriptor["new_mutable_result_option"] is False, "descriptor projection drifted")

    generated = require_fields(contract["generated_source_v2"], {"contract_id", "format_version", "plan_row_fields", "format_bump_required", "bare_or_action_family", "bare_or_blind_family", "pipe_action_family", "stale_bare_or_policy"}, "generated source")
    require(generated == {"contract_id": "linkedspec-generated-source-v2", "format_version": 2, "plan_row_fields": ["label", "family"], "format_bump_required": False, "bare_or_action_family": "rep_acode", "bare_or_blind_family": "rep_bcode", "pipe_action_family": "or_acode", "stale_bare_or_policy": "family_plan_validation_failure_then_regenerate_from_spec"}, "generated-v2 contract drifted")
    trace = require_fields(contract["trace_contract"], {"selected_event", "required_fields", "repeated_choice_role", "observation", "direct_traced_result_identity"}, "trace")
    require(trace == {"selected_event": "regex_slot_selected", "required_fields": ["rule_label", "selection_role", "target_rule", "regex_index"], "repeated_choice_role": "choice", "observation": "one_selected_event_per_accepted_hit", "direct_traced_result_identity": True}, "trace contract drifted")
    require(contract["required_routes"] == ["native", "loaded", "reconstructed", "descriptor", "generated_direct", "generated_traced", "emitted_source_direct", "emitted_source_traced", "primary_cli", "corpus_bundle"], "route inventory drifted")

    bundle = require_fields(contract["corpus_bundle"], {"source", "input", "expected", "fixture_id"}, "corpus bundle")
    require(bundle["fixture_id"] == "explicit_or_two_hits", "corpus fixture identity drifted")
    admissions = require_fields(contract["admissions"], {"perl_reference", "rust", "dart", "julia", "lua_dual_abi"}, "admissions")
    perl = require_fields(admissions["perl_reference"], {"status", "owner", "consumer", "canonical_driver", "roles"}, "Perl admission")
    require(perl == {"status": "complete", "owner": "FUTURE-PARITY-BACKLOG.9.1.10.1", "consumer": "t/repeated_action_result_perl_contract.t", "canonical_driver": "tools/run_ci_local.sh", "roles": PERL_ROLES}, "Perl admission drifted")
    for backend, owner, consumer, driver in [
        ("rust", "FUTURE-PARITY-BACKLOG.9.1.10.2", "rust/linkedspec-runtime/tests/repeated_action_result_contract.rs", "tools/run_rust_local.sh"),
        ("dart", "FUTURE-PARITY-BACKLOG.9.1.10.3", "dart/test/repeated_action_result_contract_test.dart", "tools/run_dart_local.sh"),
        ("julia", "FUTURE-PARITY-BACKLOG.9.1.10.4", "julia/test/repeated_action_result_contract_test.jl", "tools/run_julia_local.sh"),
        ("lua_dual_abi", "FUTURE-PARITY-BACKLOG.9.1.10.5", "lua/test/repeated_action_result_contract_test.lua", "tools/run_lua_local.sh"),
    ]:
        row = require_fields(admissions[backend], {"status", "owner", "consumer", "canonical_driver"}, f"{backend} admission")
        require(row == {"status": "pending", "owner": owner, "consumer": consumer, "canonical_driver": driver}, f"{backend} pending admission drifted")

    inventory = [(row["backend"], row["runtime"], row["bare_or_family"], row["action_return"], row["status"], row["owner"]) for row in contract["implementation_inventory"]]
    require(inventory == INVENTORY, "six-runtime mechanism inventory drifted")
    rollout = [(row["capability"], row["status"], row["owner"]) for row in contract["rollout"]]
    require(rollout == ROLLOUT, "rollout topology drifted")
    require(contract["migration"] == {"checker": "tools/check_repeated_action_result_contract.py", "perl_consumer": "t/repeated_action_result_perl_contract.t", "recurring_driver": "tools/check_repeated_action_result_five_backend.sh", "public_closeout": "FUTURE-PARITY-BACKLOG.9.1.10.7"}, "migration paths drifted")
    require(contract["canonical_ci"] == {"driver": "tools/run_ci_local.sh", "neutral_checker": "unconditional", "perl_consumer": "unconditional", "future_recurring_switch": "LINKEDSPEC_RUN_REPEATED_ACTION_RESULT_MATRIX"}, "canonical CI contract drifted")

    if check_filesystem:
        validate_filesystem(contract)


def validate_filesystem(contract: dict[str, Any]) -> None:
    decision_text = (ROOT / contract["decision"]).read_text(encoding="utf-8")
    require("Explicit repetition action returns are per-hit collection values" in decision_text, "ADR 0048 decision marker is missing")
    task_text = (ROOT / "docs/tasks/FUTURE-PARITY-BACKLOG.md").read_text(encoding="utf-8")
    task_status = re.search(
        r"- ID: `FUTURE-PARITY-BACKLOG\.9\.1\.10\.1`\n  Status: `(active|done)`",
        task_text,
    )
    require(task_status is not None, "neutral/reference task is neither active nor complete")
    require("**SCHEMA / MODEL**" in task_text and "**FIXTURES / PERL ROUTES**" in task_text, "neutral task acceptance checklist drifted")

    fixture = next(case for case in contract["mode_cases"] if case["id"] == contract["corpus_bundle"]["fixture_id"])
    source_path = ROOT / contract["corpus_bundle"]["source"]
    input_path = ROOT / contract["corpus_bundle"]["input"]
    expected_path = ROOT / contract["corpus_bundle"]["expected"]
    require(source_path.read_text(encoding="utf-8") == fixture["source"], "corpus bundle source drifted")
    require(input_path.read_text(encoding="utf-8") == "ab\n", "corpus bundle input drifted")
    require(json.loads(expected_path.read_text(encoding="utf-8")) == fixture["expected_result"], "corpus bundle result drifted")

    perl_admission = contract["admissions"]["perl_reference"]
    consumer_path = ROOT / perl_admission["consumer"]
    require(consumer_path.is_file(), "Perl admission consumer is missing")
    consumer_text = consumer_path.read_text(encoding="utf-8")
    require(all(f"sub role_{role}" in consumer_text for role in PERL_ROLES), "Perl admission role inventory drifted")
    ci_text = (ROOT / contract["canonical_ci"]["driver"]).read_text(encoding="utf-8")
    required_ci = [
        "require_tracked_file tools/check_repeated_action_result_contract.py",
        "require_tracked_file capability_conformance/repeated_action_result_contract.json",
        "require_tracked_file t/repeated_action_result_perl_contract.t",
        "python3 tools/check_repeated_action_result_contract.py",
        "perl -c -Iperl t/repeated_action_result_perl_contract.t",
        "PERL5LIB= prove -Iperl t/repeated_action_result_perl_contract.t",
    ]
    require(all(marker in ci_text for marker in required_ci), "canonical CI registration drifted")
    emitter_text = (ROOT / "perl/LinkedSpec/HandlerVariantEmitter.pm").read_text(encoding="utf-8")
    require("sub _emit_rep_acode_handler" in emitter_text and "REP: replace return with assignment so loop collects" in emitter_text and "_collect, $" in emitter_text, "Perl REP_ACODE collection seam drifted")


def expect_mutation_failure(contract: dict[str, Any], name: str, mutate: Callable[[dict[str, Any]], None]) -> None:
    mutated = copy.deepcopy(contract)
    mutate(mutated)
    try:
        validate_contract(mutated, check_filesystem=False)
    except ContractError:
        return
    raise ContractError(f"mutation {name!r} was not rejected")


def mutation_checks(contract: dict[str, Any]) -> int:
    mutations: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
        ("remove_mode", lambda value: value["mode_cases"].pop()),
        ("change_source", lambda value: value["mode_cases"][0].__setitem__("source", value["mode_cases"][0]["source"] + "\n")),
        ("change_result", lambda value: value["mode_cases"][0].__setitem__("expected_result", ["A"])),
        ("change_selected_slot", lambda value: value["mode_cases"][0]["expected_selected_slots"].__setitem__(1, "Top#0")),
        ("change_or_minimum", lambda value: value["mode_cases"][3].__setitem__("rep_min", 0)),
        ("change_or_family", lambda value: value["mode_cases"][3].__setitem__("generated_family", "or_acode")),
        ("make_pipe_repeated", lambda value: value["mode_cases"][7].__setitem__("is_repetition", True)),
        ("wrap_pipe_result", lambda value: value["mode_cases"][7].__setitem__("expected_result", ["A"])),
        ("flatten_nested", lambda value: value["special_cases"][1].__setitem__("expected_result", ["A", "A"])),
        ("drop_null_element", lambda value: value["special_cases"][2].__setitem__("expected_result", [])),
        ("zero_becomes_null", lambda value: value["special_cases"][4].__setitem__("expected_result", None)),
        ("below_minimum_becomes_partial", lambda value: value["special_cases"][5].__setitem__("expected_result", ["A"])),
        ("lifecycle_becomes_iteration", lambda value: value["semantics"].__setitem__("lifecycle_return", "iteration_value")),
        ("change_lifecycle_marker", lambda value: value["special_cases"][7]["lifecycle_override"].__setitem__("marker", "E")),
        ("change_blind_family", lambda value: value["special_cases"][9].__setitem__("generated_family", "or_bcode")),
        ("widen_default_scope", lambda value: value["scope"].__setitem__("unadorned_default_handler_in_scope", True)),
        ("bump_generated_format", lambda value: value["generated_source_v2"].__setitem__("format_version", 3)),
        ("serialize_result_option", lambda value: value["descriptor_contract"].__setitem__("new_mutable_result_option", True)),
        ("change_trace_observation", lambda value: value["trace_contract"].__setitem__("observation", "first_hit_only")),
        ("remove_route", lambda value: value["required_routes"].pop()),
        ("change_corpus_fixture", lambda value: value["corpus_bundle"].__setitem__("fixture_id", "pipe_distinct_scalar")),
        ("remove_perl_role", lambda value: value["admissions"]["perl_reference"]["roles"].pop()),
        ("premature_rust_rollout", lambda value: value["rollout"][2].__setitem__("status", "complete")),
        ("hide_rust_mechanism", lambda value: value["implementation_inventory"][1].__setitem__("action_return", "iteration_value")),
        ("remove_rollout", lambda value: value["rollout"].pop()),
    ]
    for name, mutate in mutations:
        expect_mutation_failure(contract, name, mutate)
    return len(mutations)


def main() -> int:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(contract)
    mutation_count = mutation_checks(contract)
    complete = sum(row["status"] == "complete" for row in contract["rollout"])
    pending = len(contract["rollout"]) - complete
    print(
        "repeated-action-result contract: PASS "
        f"({len(contract['mode_cases'])} mode cases, {len(contract['special_cases'])} special cases, "
        f"{complete} complete + {pending} pending, {mutation_count} drift mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

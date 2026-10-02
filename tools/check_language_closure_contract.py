#!/usr/bin/env python3
"""Check closure structure, scoped policies and source bindings, not DSL execution."""

from __future__ import annotations

import copy
import hashlib
import json
import re
from pathlib import Path
from typing import Any

from check_memory_handoff_state import task_statuses


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = "capability_conformance/language_closure_contract.json"
CI_CALL = "bash tools/run_python_project_data.sh tools/check_language_closure_contract.py"

# Independent schema from reviewed sources; never read the closure JSON to
# construct the expected authority register, scope rules or operation edges.
AUTHORITY_REGISTER = {
    "root_rule_selection": ("9.1.1.2", "/precedence /validation /selector"),
    "rule_local_cursor": (
        "9.1.9",
        "/policy/and_cursor /policy/or_default_cursor /policy/child_cursor "
        "/policy/global_override",
    ),
    "typed_source_location": (
        "14.8",
        "/policy/source_identity /policy/span /policy/transactions /policy/progress "
        "/recursive_observations /policy/transaction_effects /policy/dispatch_authority",
    ),
    "recognition_transaction": (
        "14.3",
        "/authored_surface/result_separation /policy/attempt_result /policy/commit "
        "/policy/rollback /policy/progress /effect_model /policy/non_progress "
        "/policy/fail_closed /policy/terminal",
    ),
    "inter_match_gap_capture": (
        "INTER-MATCH-GAP-CAPTURE.7",
        "/authored_surfaces /segmentation_cases /lifecycle_matrix",
    ),
    "uniform_binding": (
        "12.1",
        "/policy/binding /policy/host_storage /policy/wrong_kind /constructor_policy",
    ),
    "callable_signature": ("4", "/policy/arguments /policy/rest_binding /policy/overloads /policy/results"),
    "callable_codeblock": ("11.8", "/policy/context /policy/parameters /policy/results /policy/closures"),
    "logical_helper": ("5.2", "/policy/evaluation /policy/truthiness /policy/lazy_controls"),
    "scalar_numeric": (
        "LUA-BACKEND-PARITY.4.3.3.1.1",
        "/policy/accepted_number /policy/aggregate_reducers /policy/invalid_input /policy/round",
    ),
    "write_vivification": (
        "19.1.1",
        "/policy/evaluation_order /policy/post_evaluation_snapshot /policy/atomic_commit "
        "/policy/detachment",
    ),
    "map_leaves_mutation": (
        "19.1.2",
        "/policy/traversal /policy/reentrancy /policy/failure_effects /policy/continuation",
    ),
    "write_map_leaves_composition": (
        "19.1.3",
        "/requires /policy/identity_guard /policy/later_callback_failure /policy/post_commit",
    ),
    "progressive_span_dispatch": (
        "14.6",
        "/authored_surface/availability /policy/registry /policy/ceilings /policy/progress "
        "/policy/bounds /policy/capabilities /policy/cancellation /policy/cycles "
        "/policy/state /policy/result /policy/loading /policy/transactions "
        "/policy/identity /policy/source_view",
    ),
    "staged_ast_enrichment": (
        "14.7",
        "/policy/authority /policy/queue /policy/state /policy/failure /policy/detachment "
        "/policy/capabilities /policy/cycles /policy/bounds /policy/loading "
        "/policy/resolution /policy/result /policy/provenance /policy/cache",
    ),
    "diagnostic_output": (
        "5.1",
        "/policy/delivery /policy/result_neutrality /policy/sink_failure /policy/exit_now "
        "/policy/arity_validation /policy/evaluation",
    ),
}
GRAMMAR_LEDGER = {
    "root_rule_selection", "rule_local_cursor", "typed_source_location",
    "recognition_transaction", "inter_match_gap_capture",
    "progressive_span_dispatch", "staged_ast_enrichment",
}
OPERATION_REGISTER = {
    "compute": (
        "typed_scalar_and_aggregate_expressions positional_fixed_and_final_rest_functions "
        "deferred_blocks eager_helpers_and_selected_controls",
        "uniform_binding callable_signature callable_codeblock logical_helper scalar_numeric",
        "pure_function deferred_codeblock rule_invocation",
    ),
    "recognize": (
        "linked_rules intrinsic_cursor_families advancing_rule_recursion "
        "linear_recognition_attempts",
        "root_rule_selection rule_local_cursor recognition_transaction",
        "rule_invocation recognition_attempt",
    ),
    "observe": (
        "authorized_source_bound_capture cursor_boundaries_and_marks "
        "detached_recursive_observations",
        "typed_source_location inter_match_gap_capture",
        "rule_invocation recognition_attempt recursive_observation",
    ),
    "mutate": (
        "typed_working_bindings explicit_cursor_operations nested_write "
        "guarded_root_kind_leaf_mutation",
        "uniform_binding typed_source_location write_vivification map_leaves_mutation "
        "write_map_leaves_composition",
        "rule_invocation deferred_codeblock nested_write leaf_transformation",
    ),
    "return": (
        "owner_approved_typed_values ordinary_child_payloads "
        "detached_capture_mutation_and_staged_results",
        "uniform_binding callable_signature callable_codeblock recognition_transaction "
        "write_vivification map_leaves_mutation staged_ast_enrichment",
        "rule_invocation pure_function deferred_codeblock recognition_attempt nested_write "
        "leaf_transformation child_parse",
    ),
    "diagnose": (
        "ordered_typed_diagnostic_events",
        "diagnostic_output",
        "rule_invocation deferred_codeblock",
    ),
    "compose": (
        "private_progressive_dispatch public_staged_source_bound_text_assignment",
        "progressive_span_dispatch staged_ast_enrichment",
        "child_parse",
    ),
}
SCOPE_REGISTER = {
    "rule_invocation": (
        "source_cursor_capture_and_scoped_declared_state",
        "authored_recursive_state_restoration",
        "owner_specific_effects",
        "rule_local_cursor uniform_binding typed_source_location",
    ),
    "pure_function": (
        "eager_explicit_arguments_then_fresh_local_state",
        "caller_state_not_implicitly_captured",
        "ordinary_value_result",
        "callable_signature",
    ),
    "deferred_codeblock": (
        "live_invocation_caller_nonparameters",
        "copied_temporary_parameters",
        "block_local_return_nonparameter_effects_persist",
        "callable_codeblock",
    ),
    "recognition_attempt": (
        "one_source_rule_invocation_bound_linear_token",
        "cursor_boundary_marks_only_on_rollback",
        "strict_match_boolean_separate_from_payload",
        "recognition_transaction",
    ),
    "recursive_observation": (
        "existing_invocation_authority",
        "no_second_stack_or_retained_history",
        "immediately_detached_record",
        "typed_source_location",
    ),
    "nested_write": (
        "post_expression_root_snapshot",
        "structural_receiver_state_only_on_failure",
        "atomic_root_commit_detached_result",
        "write_vivification",
    ),
    "leaf_transformation": (
        "resolved_receiver_original_shape_root_kind",
        "receiver_only_unrelated_effects_persist",
        "atomic_commit_then_continuation",
        "map_leaves_mutation write_map_leaves_composition",
    ),
    "child_parse": (
        "fresh_child_state_caller_frozen_registry",
        "private_dispatch_leaves_parent_cursor_unchanged",
        "owner_specific_detached_child_results",
        "progressive_span_dispatch staged_ast_enrichment",
    ),
}
FIXED_SECTIONS = {
    "stage": {
        "operation_scope_reference": "frozen",
        "determinism_resource_failure": "frozen",
        "independent_reconciliation": "pending_SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4",
        "composed_objectives": "pending_SPEC-LANGUAGE-SELF-CONTAINMENT.1.3",
    },
    "claim_boundary": {
        "semantic_core": "shared_existing_core", "frontend": "not_implemented_here",
        "runtime_admission": "unchanged", "proof": "structural_governance_only",
        "evidence_extent": "finite_objectives_only", "partial_exceptions": "retained",
        "unassessed_objectives": "retained", "security": "no_sandbox_proof",
        "numeric_limits": "no_new_global_limit",
    },
    "determinism": {
        "inputs": [
            "canonical_program_and_contract_versions", "decoded_source_and_identity",
            "explicit_entry_options_and_typed_values", "initial_authorized_working_state",
            "frozen_registry_and_effective_grants", "observed_cancellation_deadline_budget_and_sink_behavior",
        ],
        "ordering": [
            "authored_rule_and_regex_alternative_order", "owner_specific_once_only_expression_order",
            "root_kind_original_shape_leaf_traversal", "staged_breadth_first_depth_typed_path_provenance_job_id",
        ],
        "repeatability": "bounded_semantic_claim_for_fixed_inputs_and_operational_observations",
        "portable_parity": "selected_authority_order_only_lexical_helper_Unicode_exception_retained",
        "regex": "governed_matching_contract_and_authorized_substrate_not_arbitrary_host_regex_equivalence",
        "clock": "host_deadline_observation_not_authored_clock_authority",
        "sink": "caller_delivery_outcome_is_an_operational_input",
        "unassessed": "timing_independent_outcome_unrestricted_depth_and_performance",
    },
    "progress": {
        "typed_source_target": "advance_cursor_or_prove_well_founded_decreasing_measure",
        "recognition_observation": "active_accepted_repetition_and_recursive_edges_require_strict_offset_advance",
        "one_shot_zero_width": "legal_success_not_proof_of_repetition_progress",
        "ordinary_rule": "dated_same_rule_position_cutoff_is_separate_from_scoped_progress_diagnostics",
        "ordinary_iteration": "selected_termination_evidence_not_one_universal_threshold_or_diagnostic",
        "child": "child_work_never_supplies_parent_cursor_progress",
        "non_progress": "rollback_or_binding_mark_AST_object_transaction_changes_are_not_cursor_advance",
        "proof_scope": "finite_controls_not_general_termination_or_left_recursion_admission",
    },
    "resources": {
        "effective_authority": "capability_and_policy_intersections_and_stricter_numeric_source_detail_minima",
        "non_extension": "shared_cancellation_absolute_deadline_work_and_call_authority_cannot_reset_or_expand",
        "private_progressive": "contained_strictly_smaller_repeated_spans_depth_calls_and_shared_remaining_work",
        "staged": "contained_lineage_depth_total_calls_steps_result_nodes_diagnostic_bytes_at_entry_and_safe_points",
        "computed_versus_enforced": "calculated_effective_metadata_is_not_complete_runtime_enforcement",
        "detail": "authorized_parser_input_versus_outward_detail_review_preserves_existing_policy_until_owner_resolution",
        "regex_substrate": "published_matching_behavior_no_host_regex_preemption_or_hard_wall_clock_guarantee",
        "global_limit": "no_universal_depth_step_call_or_repetition_number_selected",
        "performance": "unassessed_requires_representative_measurements_and_explicit_envelope",
        "partial_claim": "affected_runtime_repairs_and_recurrence_precede_dependent_guarantees",
    },
    "failure_publication": {
        "recognition": "strict_match_boolean_independent_of_payload_miss_commit_null_rollback_cursor_boundary_marks_only",
        "recognition_misuse": "typed_rejection_with_token_abort_and_kind_exceptions_retained",
        "nested_write": "post_expression_snapshot_structural_failure_preserves_expression_effects_evaluation_error_propagates",
        "leaf_callback": "no_receiver_publication_on_failure_completed_unrelated_effects_persist",
        "leaf_continuation": "runs_after_commit_failure_does_not_undo_receiver_commit",
        "private_progressive": "fail_only_no_retry_or_fallback_no_parent_cursor_progress",
        "staged_fail": "abort_composed_parse_no_settled_composed_result",
        "staged_keep_text": "materialize_original_exact_text_and_scheduler_sidecar_diagnostic",
        "staged_diagnostic_node": "selected_target_policy_with_detached_portable_diagnostic_node",
        "diagnostic_sink": "caller_failure_propagates_unchanged_and_stops_later_evaluation_or_delivery",
        "typed_exit": "preceding_events_delivered_then_typed_status_stops_later_actions",
        "public_channels": "owner_specific_last_error_typed_exception_or_diagnostic_aware_result_with_legacy_adapters",
        "display_probe": "Rust_native_text_projection_is_Display_only_not_a_universal_error_schema",
        "ordinary_cutoff": "ordinary_no_consume_recursion_can_return_null_with_null_last_error_and_separate_trace",
    },
    "ambient_authority": {
        "authored_default_policy": "filesystem_process_network_environment_clock_randomness_package_loading_and_FFI_excluded",
        "caller": "explicit_authorized_input_compilation_registry_transport_and_sink_remain_host_responsibilities",
        "identity": "source_identity_parser_selector_path_like_data_span_marker_and_result_do_not_grant_loading_authority",
        "compatibility": "raw_host_fallback_plugins_and_aliases_excluded_from_preferred_portable_claim",
        "enforcement_extent": "design_exclusion_and_finite_portable_proof_not_default_ambient_isolation_proof",
        "security": "no_execution_sandbox_or_confinement_guarantee",
    },
    "proof_requirements": {
        "invalid_authority": "deny_elevation_unknown_selector_mutable_registry_and_authored_loading_requests",
        "invalid_progress": "distinguish_one_shot_zero_width_active_nonprogress_rollback_and_child_parent_progress",
        "adversarial_resources": "joint_minima_actual_cost_nodes_diagnostic_bytes_detail_cycles_and_counter_extremes",
        "failure_effects": "separate_receiver_publication_unrelated_effects_continuation_and_staged_policies",
        "determinism": "fixed_inputs_order_and_operational_observations_with_independent_value_kind_effect_oracles",
        "source_detail": "independent_authorized_input_and_outward_projection_oracles_before_review_resolution",
        "runtime_admission": "selected_objectives_after_affected_repairs_then_exact_six_runtime_recurrence",
        "structural_mutations": "reason_sensitive_definition_and_source_drift_rejection_not_DSL_execution",
        "unassessed_cost": "measure_performance_regex_limits_and_unrestricted_resources_before_guarantees",
    },
    "relationships": {
        "entry_selection": "does_not_match_entry_regex",
        "cursor_restore": "cursor_only_not_recognition_rollback",
        "recognition_effects": "closed_graph_not_arbitrary_user_state_or_AST_rollback",
        "function_and_codeblock_scope": "distinct_no_lexical_environment_capture",
        "codeblock_construction": "inert", "child_work": "not_parent_cursor_progress",
        "progressive_surface": "private_no_outward_API",
        "staged_operand": "source_bound_text_assignment_only",
        "write_snapshot": "after_segments_then_RHS", "leaf_continuation": "after_commit",
        "leaf_traversal": "original_shape_root_kind",
    },
    "results": {
        "match_presence": "separate_from_payload_truthiness_and_kind",
        "source_coordinates": "same_source_half_open_Unicode_scalars",
        "private_values": "no_live_source_token_or_dispatch_handle_escape",
        "detachment": "owner_specific_not_inferred_for_every_value",
        "diagnostics": "events_separate_from_result_and_trace", "absent_sink": "quiet",
        "sink_destination": "caller_owned",
        "ordinary_data": "path_like_strings_do_not_grant_authority",
    },
    "host_boundary": {
        "inputs": "decoded_source_and_identity explicit_entry_and_supported_options explicit_typed_values precompiled_child_registry narrowing_operational_grants optional_typed_diagnostic_sink".split(),
        "caller_responsibilities": "authorize_source_transfer prepare_compile_and_freeze_registry install_and_route_sink enforce_host_transport_contracts".split(),
        "authored_data_grants_authority": False, "host_grammar_callback_proves_closure": False,
    },
    "excluded": {
        "portable_claim": "raw_host_fallback legacy_plugin_behavior compatibility_aliases".split(),
        "extensions_not_selected": "lexical_closures recursive_user_functions recursive_codeblock_invocation defaults named_fixed_arguments generic_user_defined_bang_methods arbitrary_AST_or_user_state_rollback expanded_staged_operands".split(),
        "parked_named_arguments_owner": "PARSER-AUTHORING-APIS.4",
    },
    "obligations": {
        "finite_ledger": "docs/language-readiness/finite-gap-list.md",
        "supplemental_partial_owners": [f"SESSION-STARTUP-READING.{n}" for n in (19, 21, 35, 39)],
        "preserve_repair_prerequisites": True,
        "resource_detail_review_owner": "SESSION-STARTUP-READING.37.2",
        "general_teaching_review_owner": "SESSION-STARTUP-READING.41.2",
        "unassessed_selection_owner": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3",
        "primitive_selection_owner": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.4",
        "mutation_admission_owners": [f"FUTURE-PARITY-BACKLOG.19.{n}" for n in (7, 8, 9)],
        "resource_repair_owners": [
            "SESSION-STARTUP-READING.37.1", "SESSION-STARTUP-READING.37.2",
            "SESSION-STARTUP-READING.37.3", "SESSION-STARTUP-READING.73",
            "SESSION-STARTUP-READING.74", "SESSION-STARTUP-READING.75",
            "DART-STARTUP-READING.2.17", "DART-STARTUP-READING.2.18",
            "JULIA-STARTUP-READING.2.14", "LUA-STARTUP-READING.2.26",
            "LUA-STARTUP-READING.2.8.15", "LUA-STARTUP-READING.2.8.16",
        ],
        "ordering_repair_owners": [f"DART-STARTUP-READING.2.13.{n}" for n in (1, 2, 3)],
    },
    "references": {
        "design": "docs/language-readiness/closure-contract-matrix.md",
        "pure_function_scope": "docs/knowledge/terse-user-defined-functions-mvp-contract.md",
        "direction": "docs/decisions/0064-expressive-self-containment-and-ebnf-profile.md",
        "policy_review": "docs/language-readiness/closure-policy-boundaries.md",
        "ordinary_progress": "docs/knowledge/top-rule-recursion-forward-progress-guard.md",
        "resource_exception": "docs/knowledge/perl-progressive-resource-ceiling-enforcement-gap.md",
        "native_failure_channels": "docs/knowledge/rust-runtime-error-boundary-string-result.md",
    },
    "governance": {
        "checker": "tools/check_language_closure_contract.py",
        "route": "tools/run_python_project_data.sh", "ci": "tools/run_ci_local.sh",
        "invocations": 1,
    },
}


class ContractError(ValueError):
    def __init__(self, path: str, reason: str):
        self.path = path
        super().__init__(f"{path}: {reason}")


def require(condition: bool, path: str, reason: str) -> None:
    if not condition:
        raise ContractError(path, reason)


def closed_object(value: Any, keys: Any, path: str) -> None:
    require(type(value) is dict, path, "expected object")
    require(set(value) == set(keys), path, "missing or unknown fields")


def exact(value: Any, expected: Any, path: str) -> None:
    # JSON booleans must not pass as integer 0/1 through Python equality.
    require(type(value) is type(expected), path, "wrong JSON kind")
    if type(expected) is list:
        require(len(value) == len(expected), path, "wrong ordered list length")
        for index, item in enumerate(expected):
            exact(value[index], item, f"{path}/{index}")
    else:
        require(value == expected, path, "frozen policy or reference drift")


def repo_path(name: str) -> Path:
    path = Path(name)
    require(not path.is_absolute() and all(p not in ("", ".", "..") for p in name.split("/")), name, "non-relative path")
    current = ROOT
    for part in path.parts:
        current /= part
        require(not current.is_symlink(), name, "symlink reference")
    require(current.is_file(), name, "missing reference")
    return current


def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        require(key not in result, "/json", f"duplicate key {key!r}")
        result[key] = value
    return result


def reject_constant(value: str) -> None:
    raise ContractError("/json", f"nonfinite number {value}")


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object, parse_constant=reject_constant)


def pointer_value(source: Any, pointer: str, path: str) -> Any:
    current = source
    for key in pointer[1:].split("/"):
        require(type(current) is dict and key in current, path, "missing semantic anchor")
        current = current[key]
    return current


def semantic_digest(value: Any) -> str:
    data = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"), allow_nan=False)
    return hashlib.sha256(data.encode("utf-8")).hexdigest()


def validate(contract: Any, sources: dict[str, Any], statuses: dict[str, Any], ci: str) -> None:
    keys = {"format", "contract_id", "definition_owner", "policy_owner", "authorities", "operations", "scopes"} | FIXED_SECTIONS.keys()
    closed_object(contract, keys, "/")
    exact(contract["format"], 1, "/format")
    exact(contract["contract_id"], "linkedspec-language-closure-v1", "/contract_id")
    exact(contract["definition_owner"], "SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2", "/definition_owner")
    exact(contract["policy_owner"], "SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3", "/policy_owner")
    for field in ("definition_owner", "policy_owner"):
        require(type(statuses.get(contract[field])) is str, "/" + field, "missing or ambiguous task owner")
    for section, expected in FIXED_SECTIONS.items():
        closed_object(contract[section], expected, f"/{section}")
        for key, value in expected.items():
            exact(contract[section][key], value, f"/{section}/{key}")

    closed_object(contract["authorities"], AUTHORITY_REGISTER, "/authorities")
    for name, (owner, pointers) in AUTHORITY_REGISTER.items():
        row = contract["authorities"][name]
        prefix = f"/authorities/{name}"
        closed_object(row, ("path", "format", "contract_id", "semantic_sha256", "proof_owner", "evidence_ledger"), prefix)
        exact(row["path"], f"capability_conformance/{name}_contract.json", prefix + "/path")
        exact(row["format"], 1, prefix + "/format")
        exact(row["contract_id"], "linkedspec-" + name.replace("_", "-") + "-v1", prefix + "/contract_id")
        owner = "FUTURE-PARITY-BACKLOG." + owner if owner[0].isdigit() else owner
        exact(row["proof_owner"], owner, prefix + "/proof_owner")
        require(type(statuses.get(owner)) is str and bool(statuses[owner]), prefix + "/proof_owner", "missing or ambiguous task owner")
        ledger = "grammar-cursor-capture" if name in GRAMMAR_LEDGER else "state-control-results"
        exact(row["evidence_ledger"], f"docs/language-readiness/{ledger}.md", prefix + "/evidence_ledger")
        source = sources[name]
        require(type(source) is dict, prefix + "/source", "expected source object")
        exact(source.get("format"), 1, prefix + "/source/format")
        exact(source.get("contract_id"), row["contract_id"], prefix + "/source/contract_id")
        closed_object(row["semantic_sha256"], pointers.split(), prefix + "/semantic_sha256")
        for pointer, digest in row["semantic_sha256"].items():
            location = prefix + "/semantic_sha256" + pointer
            require(type(digest) is str and re.fullmatch(r"[0-9a-f]{64}", digest) is not None, location, "invalid digest")
            exact(digest, semantic_digest(pointer_value(source, pointer, location)), location)

    for section, register, fields in (
        ("operations", OPERATION_REGISTER, ("included", "authorities", "scopes")),
        ("scopes", SCOPE_REGISTER, ("visible", "restored", "publication", "authorities")),
    ):
        closed_object(contract[section], register, f"/{section}")
        for name, meanings in register.items():
            row = contract[section][name]
            prefix = f"/{section}/{name}"
            keys = set(fields) | ({"claim"} if section == "operations" else set())
            closed_object(row, keys, prefix)
            for field, meaning in zip(fields, meanings, strict=True):
                expected = meaning.split() if field in ("included", "authorities", "scopes") else meaning
                exact(row[field], expected, prefix + "/" + field)
            if section == "operations":
                exact(row["claim"], "existing_mechanisms_with_partial_exceptions", prefix + "/claim")

    obligations = contract["obligations"]
    for name in ("resource_detail_review_owner", "general_teaching_review_owner", "unassessed_selection_owner", "primitive_selection_owner"):
        require(type(statuses.get(obligations[name])) is str, "/obligations/" + name, "missing or ambiguous task owner")
    for name in ("supplemental_partial_owners", "mutation_admission_owners", "resource_repair_owners", "ordering_repair_owners"):
        for index, owner in enumerate(obligations[name]):
            require(type(statuses.get(owner)) is str, f"/obligations/{name}/{index}", "missing or ambiguous task owner")
    require(type(statuses.get(contract["excluded"]["parked_named_arguments_owner"])) is str, "/excluded/parked_named_arguments_owner", "missing or ambiguous task owner")
    require(ci.splitlines().count(CI_CALL) == 1, "/governance/ci", "missing or duplicate invocation")
    for required in (CONTRACT, "tools/check_language_closure_contract.py"):
        require(ci.splitlines().count("require_tracked_file " + required) == 1, "/governance/ci", "missing or duplicate tracked input")


def expect_rejection(contract: Any, sources: dict[str, Any], statuses: dict[str, Any], ci: str, path: str) -> None:
    try:
        validate(contract, sources, statuses, ci)
    except ContractError as error:
        require(error.path == path or error.path.startswith(path.rstrip("/") + "/"), "/mutation", f"unrelated rejection at {error.path}; expected {path}")
        return
    raise ContractError("/mutation", f"accepted corrupt input at {path}")


def mutation_proof(contract: Any, sources: dict[str, Any], statuses: dict[str, Any], ci: str) -> tuple[int, int]:
    count = 0

    def corrupt(parts: list[str | int], value: Any, delete: bool = False, expected_path: str | None = None) -> None:
        nonlocal count
        mutant = copy.deepcopy(contract)
        current = mutant
        for part in parts[:-1]:
            current = current[part]
        if delete:
            del current[parts[-1]]
            path = "/" + "/".join(map(str, parts[:-1]))
        else:
            current[parts[-1]] = value
            path = "/" + "/".join(map(str, parts))
        expect_rejection(mutant, sources, statuses, ci, expected_path or path.replace("//", "/"))
        count += 1

    for key in contract:
        corrupt([key], None)
        corrupt([key], None, delete=True)
    corrupt(["policy_owner"], "unrelated")
    for section, expected in FIXED_SECTIONS.items():
        for key, value in expected.items():
            replacement = [] if type(value) is list else not value if type(value) is bool else True if type(value) is int else "weakened"
            corrupt([section, key], replacement)
            if type(value) is list:
                for index in range(len(value)):
                    corrupt([section, key, index], "unrelated")
        corrupt([section, "unknown"], True, expected_path="/" + section)
    for section in ("operations", "scopes"):
        for name, row in contract[section].items():
            corrupt([section, name], None, delete=True)
            for key, value in row.items():
                corrupt([section, name, key], value[:-1] if type(value) is list else "weakened")
    for name, row in contract["authorities"].items():
        corrupt(["authorities", name], None, delete=True)
        for key in ("path", "contract_id", "proof_owner", "evidence_ledger"):
            corrupt(["authorities", name, key], "unrelated")
        corrupt(["authorities", name, "format"], True)
        for pointer in row["semantic_sha256"]:
            corrupt(["authorities", name, "semantic_sha256", pointer], "0" * 64)
            changed = copy.deepcopy(sources)
            current = changed[name]
            parts = pointer[1:].split("/")
            for part in parts[:-1]:
                current = current[part]
            current[parts[-1]] = {"changed_semantic_anchor": True}
            expect_rejection(contract, changed, statuses, ci, f"/authorities/{name}/semantic_sha256{pointer}")
            count += 1
        changed = copy.deepcopy(sources)
        changed[name]["format"] = True
        expect_rejection(contract, changed, statuses, ci, f"/authorities/{name}/source/format")
        count += 1
        changed_statuses = dict(statuses)
        del changed_statuses[row["proof_owner"]]
        expect_rejection(contract, sources, changed_statuses, ci, f"/authorities/{name}/proof_owner")
        count += 1
    for altered in (ci.replace(CI_CALL, "# removed invocation"), ci + "\n" + CI_CALL):
        expect_rejection(contract, sources, statuses, altered, "/governance/ci")
        count += 1
    for path in (CONTRACT, "tools/check_language_closure_contract.py"):
        expect_rejection(contract, sources, statuses, ci.replace("require_tracked_file " + path, "# removed input"), "/governance/ci")
        count += 1
    detail_owner = contract["obligations"]["resource_detail_review_owner"]
    # The detail owner is shared: its earlier dedicated obligation is the
    # intended rejection path, rather than an unrelated-error substitute.
    for path, owner in [
        ("/definition_owner", contract["definition_owner"]),
        ("/policy_owner", contract["policy_owner"]),
        ("/obligations/resource_detail_review_owner", detail_owner),
    ] + [
        (f"/obligations/{field}/{index}", owner)
        for field in ("resource_repair_owners", "ordering_repair_owners")
        for index, owner in enumerate(contract["obligations"][field])
        if owner != detail_owner
    ]:
        changed_statuses = dict(statuses)
        del changed_statuses[owner]
        expect_rejection(contract, sources, changed_statuses, ci, path)
        count += 1

    # A wrong failure must not make a semantic mutation count as covered.
    unrelated = copy.deepcopy(contract)
    unrelated["format"] = True
    try:
        expect_rejection(unrelated, sources, statuses, ci, "/scopes/pure_function/visible")
    except ContractError as error:
        require(error.path == "/mutation", "/control", "wrong unrelated-error control")
    else:
        raise ContractError("/control", "unrelated error counted as semantic proof")

    # Unselected rollout metadata is deliberately outside the semantic digest.
    metadata = copy.deepcopy(sources)
    for source in metadata.values():
        source["unselected_historical_metadata"] = "unchanged semantics"
    validate(contract, metadata, statuses, ci)
    for source in ('{"format":1,"format":1}', '{"format":NaN}'):
        try:
            json.loads(source, object_pairs_hook=unique_object, parse_constant=reject_constant)
        except ContractError as error:
            require(error.path == "/json", "/control", "wrong JSON rejection")
        else:
            raise ContractError("/control", "ambiguous JSON accepted")
    return count, 4


def main() -> int:
    contract = read_json(repo_path(CONTRACT))
    sources = {name: read_json(repo_path(f"capability_conformance/{name}_contract.json")) for name in AUTHORITY_REGISTER}
    statuses = task_statuses(ROOT / "docs/tasks")
    ci = repo_path("tools/run_ci_local.sh").read_text(encoding="utf-8")
    references = set(FIXED_SECTIONS["references"].values()) | {
        FIXED_SECTIONS["obligations"]["finite_ledger"],
        "docs/language-readiness/grammar-cursor-capture.md",
        "docs/language-readiness/state-control-results.md",
    }
    for path in references:
        repo_path(path)
    validate(contract, sources, statuses, ci)
    mutations, controls = mutation_proof(contract, sources, statuses, ci)
    anchors = sum(len(row["semantic_sha256"]) for row in contract["authorities"].values())
    print(f"language closure structure/policy: 16 authorities / {anchors} anchors / 7 operations / 8 scopes; {mutations} reason-sensitive mutations / {controls} controls; structural governance only, runtime admission unchanged")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ContractError, OSError, ValueError, TypeError) as error:
        raise SystemExit(f"language closure structure: FAIL: {error}")

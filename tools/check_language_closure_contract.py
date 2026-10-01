#!/usr/bin/env python3
"""Check closure-definition structure and source bindings, not DSL execution."""

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
        "/recursive_observations",
    ),
    "recognition_transaction": (
        "14.3",
        "/authored_surface/result_separation /policy/attempt_result /policy/commit "
        "/policy/rollback /policy/progress /effect_model",
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
        "/policy/bounds",
    ),
    "staged_ast_enrichment": (
        "14.7",
        "/policy/authority /policy/queue /policy/state /policy/failure /policy/detachment",
    ),
    "diagnostic_output": (
        "5.1",
        "/policy/delivery /policy/result_neutrality /policy/sink_failure /policy/exit_now",
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
        "determinism_resource_failure": "pending_SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3",
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
    },
    "references": {
        "design": "docs/language-readiness/closure-contract-matrix.md",
        "pure_function_scope": "docs/knowledge/terse-user-defined-functions-mvp-contract.md",
        "direction": "docs/decisions/0064-expressive-self-containment-and-ebnf-profile.md",
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
    keys = {"format", "contract_id", "definition_owner", "authorities", "operations", "scopes"} | FIXED_SECTIONS.keys()
    closed_object(contract, keys, "/")
    exact(contract["format"], 1, "/format")
    exact(contract["contract_id"], "linkedspec-language-closure-v1", "/contract_id")
    exact(contract["definition_owner"], "SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2", "/definition_owner")
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
    for name in ("supplemental_partial_owners", "mutation_admission_owners"):
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

    def corrupt(parts: list[str], value: Any, delete: bool = False, expected_path: str | None = None) -> None:
        nonlocal count
        mutant = copy.deepcopy(contract)
        current = mutant
        for part in parts[:-1]:
            current = current[part]
        if delete:
            del current[parts[-1]]
            path = "/" + "/".join(parts[:-1])
        else:
            current[parts[-1]] = value
            path = "/" + "/".join(parts)
        expect_rejection(mutant, sources, statuses, ci, expected_path or path.replace("//", "/"))
        count += 1

    for key in contract:
        corrupt([key], None)
        corrupt([key], None, delete=True)
    for section, expected in FIXED_SECTIONS.items():
        for key, value in expected.items():
            replacement = [] if type(value) is list else not value if type(value) is bool else True if type(value) is int else "weakened"
            corrupt([section, key], replacement)
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
    print(f"language closure structure: 16 authorities / 66 anchors / 7 operations / 8 scopes; {mutations} reason-sensitive mutations / {controls} controls; structural governance only, runtime admission unchanged")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ContractError, OSError, ValueError, TypeError) as error:
        raise SystemExit(f"language closure structure: FAIL: {error}")

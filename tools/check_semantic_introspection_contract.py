#!/usr/bin/env python3
"""Validate the executable semantic introspection v1 model and query oracle."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
from pathlib import Path
from typing import Any, Callable
from urllib.parse import quote_from_bytes


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "semantic_introspection_contract.json"
MODEL_PATH = ROOT / "capability_conformance" / "semantic_introspection_model.json"
TOOLBOX_PATH = ROOT / "TOOLBOX.md"
CONTRACT_ID = "linkedspec-semantic-introspection-contract-v1"
MODEL_ID = "linkedspec-semantic-model-v1"
QUERY_ID = "linkedspec-semantic-query-v1"
TASK_OWNER = "FUTURE-PARITY-BACKLOG.10.2"
RULE_LOCAL_CONTRACT_ID = "linkedspec-rule-local-cursor-v1"
STATIC_RULE_AUTHORITY = {
    "contract_id": RULE_LOCAL_CONTRACT_ID,
    "path": "capability_conformance/rule_local_cursor_contract.json",
    "neutral_family_map": {"and": "and", "or_default": "or"},
    "neutral_cursor_map": {"consume": "contiguous", "seek": "seek"},
    "neutral_edge_ownership_values": ["none", "action", "blind"],
    "compiled_rule_without_edges": "none",
    "failed_bare_edge_ownership_by_family": {"and": "blind", "or_default": "action"},
}
GENERATED_PLAN_AUTHORITY = {
    "contract_id": RULE_LOCAL_CONTRACT_ID,
    "path": "capability_conformance/rule_local_cursor_contract.json",
    "generated_contract_key": "generated_source_v2",
    "snapshot": "calls",
    "fixture": "calls_and_staging",
    "artifact_record_id": "generated:handler_plan:0",
    "entry_rule_id": "rule:Top",
    "default_selected_variant_family": "default",
}

TOP_LEVEL_FIELDS = {
    "format", "contract_id", "model_id", "query_id", "task_owner", "decisions", "scope", "schema",
    "query_contract", "source_contract", "fixture_groups", "source_fixtures", "snapshots", "query_cases",
    "static_rule_authority", "generated_plan_authority", "target_admissions", "rollout", "canonical_ci",
    "mutations",
}
MODEL_FIELDS = {"format", "model", "query", "snapshots"}
MODEL_SNAPSHOT_FIELDS = {"id", "fixture", "snapshot", "source_refs", "records", "relations"}
RECORD_FIELDS = ["id", "kind", "name", "owner_id", "order", "source", "facts", "redactions"]
RELATION_FIELDS = ["id", "kind", "from_id", "to_id", "order", "source", "facts", "evidence_ids"]
RECORD_KINDS = [
    "capabilities", "spec", "source", "rule", "regex_slot", "edge", "lifecycle", "function", "helper",
    "binding", "call", "staged_artifact", "generated_artifact", "diagnostic", "decision", "execution", "event",
    "explanation_step",
]
RELATION_KINDS = [
    "declares", "contains", "depends_on", "dispatches_to", "selects_regex", "calls", "resolves_to", "reads",
    "writes", "consumes", "produces", "lowered_from", "staged_by", "generated_as", "diagnoses", "observed_as",
    "explained_by",
]
FACT_KEYS = {
    "capabilities": ["model_ids", "query_ids", "record_kinds", "relation_kinds", "source_detail_ceiling", "page_default", "page_max", "budget_defaults", "budget_maxima", "execution_observation", "features"],
    "spec": ["definition_order", "compiled_rule_order", "entry_rule_id", "entry_selection_basis"],
    "source": ["logical_kind", "origin_kind"],
    "rule": ["family", "cursor_policy", "is_entry_marker", "is_repetition", "rep_min", "rep_max", "edge_ownership", "value_shape"],
    "regex_slot": ["authored_index", "pattern", "flags", "combined_owner_ids", "target_shape"],
    "edge": ["ownership", "source_form", "has_block", "fluent_call_ids", "value_shape", "target_shape"],
    "lifecycle": ["marker", "whole_rule_return", "value_shape"],
    "function": ["signature", "parameter_kinds", "return_shape"],
    "helper": ["signature", "effects", "return_shape"],
    "binding": ["scope", "value_shape", "mutable"],
    "call": ["call_form", "resolution_kind", "argument_shapes", "return_shape", "target_shape"],
    "staged_artifact": ["artifact_kind", "payload_kind", "node_kind", "parent_path", "parser_spec_id", "top_rule", "result_policy", "failure_policy", "status", "value_shape"],
    "generated_artifact": ["artifact_kind", "contract_id", "format_version", "plan_family"],
    "diagnostic": ["code", "stage", "severity", "message", "fields"],
    "decision": ["decision_kind", "outcome"],
    "execution": ["input_identity", "status", "result_shape"],
    "event": ["event_kind", "position", "value_shape"],
    "explanation_step": ["rule_code", "summary", "input_ids", "output_fact"],
}
RELATION_FACT_KEYS = {kind: [] for kind in RELATION_KINDS}
SHAPE_FIELDS = ["kind", "element", "key", "value", "signature", "members"]
VALUE_SHAPE_KINDS = ["unknown", "null", "boolean", "number", "string", "array", "harray", "codeblock", "union"]
TARGET_SHAPE_KINDS = ["unknown", "rule", "regex_slot", "binding", "helper", "user_function", "codeblock", "staged_artifact", "generated_artifact", "diagnostic"]
SIGNATURE_FIELDS = ["parameters", "arity_min", "arity_max", "rest_parameter", "final_codeblock"]
SIGNATURE_PARAMETER_FIELDS = ["name", "kind", "required"]
OUTPUT_FACT_FIELDS = ["record_id", "path", "value"]
SOURCE_REF_FIELDS = ["source_id", "logical_name", "span", "excerpt", "content_digest", "provenance_ids"]
SPAN_FIELDS = ["start_byte", "end_byte", "start_line", "start_column", "end_line", "end_column"]
REQUEST_FIELDS = ["contract", "operation", "subjects", "record_kinds", "relation_kinds", "direction", "page", "budget", "source"]
RESPONSE_FIELDS = ["contract", "model", "ok", "snapshot", "records", "relations", "page", "cost", "diagnostics"]
SNAPSHOT_FIELDS = ["id", "state", "has_execution", "source_detail_ceiling", "content_digest_available"]
PAGE_FIELDS = ["after_id", "next_after_id", "complete"]
COST_FIELDS = ["records_examined", "relations_examined", "depth_reached"]
QUERY_DIAGNOSTIC_FIELDS = ["code", "severity", "message", "fields"]
QUERY_CASE_IDS = [
    "capabilities", "graph_list_rules", "graph_duplicate_regex_text", "graph_reverse_dispatch",
    "graph_explain_entry", "calls_symbols_and_shapes", "staged_chain", "generated_provenance",
    "failed_diagnostic", "runtime_events", "privacy_none", "privacy_text_and_digest", "pagination_after_id",
    "page_boundary", "budget_prefix", "relation_budget_prefix", "relation_depth_zero", "source_ceiling_forbidden",
    "unsupported_contract", "invalid_operation_combination",
]
FIXTURE_GROUP_IDS = [
    "rule_regex_edge_lifecycle_graph", "call_resolution_and_shapes", "staged_and_generated_provenance",
    "diagnostics_and_explanations", "runtime_observation", "privacy_pagination_budget_and_errors",
]
SNAPSHOT_IDS = ["graph", "calls", "failed", "runtime", "privacy", "privacy_limited"]
SOURCE_FIXTURES = [
    ("graph", "capability_conformance/semantic_introspection/graph.spec", "graph.spec", "28505ba8524900f55e11452988acc6b7d35dccbccc1c0cb6194c8cda80a0cbcf", 128),
    ("calls_and_staging", "capability_conformance/semantic_introspection/calls_and_staging.spec", "calls_and_staging.spec", "c44202083afb6c9c496ed44f8fbccd52adbeb21ca2ddff6648aa40f60056c3fd", 135),
    ("failed", "capability_conformance/semantic_introspection/failed.spec", "failed.spec", "c92b3383ee76254a355d6044cbc952c4aa364891ef9a9e803e53a43dc8b25916", 14),
    ("runtime", "capability_conformance/semantic_introspection/runtime.spec", "runtime.spec", "e224b813a4a3c79bef65b33c8ac5c1eaeb75e231da5ec3844233b4a8d796351a", 73),
    ("privacy", "capability_conformance/semantic_introspection/privacy.spec", "privacy.spec", "8fe5f40cc6e9f5ce438a605f4965e04a78c34f392e13761e66d042730469f8de", 13),
]
ROLLOUT = [
    ("neutral_contract_and_inventory", "complete", "FUTURE-PARITY-BACKLOG.10.2"),
    ("perl_reference", "complete", "FUTURE-PARITY-BACKLOG.10.3"),
    ("rust_parity", "complete", "FUTURE-PARITY-BACKLOG.10.4"),
    ("dart_parity", "pending", "FUTURE-PARITY-BACKLOG.10.5"),
    ("julia_parity", "pending", "FUTURE-PARITY-BACKLOG.10.6"),
    ("lua_dual_abi", "pending", "FUTURE-PARITY-BACKLOG.10.7"),
    ("recurring_six_runtime", "pending", "FUTURE-PARITY-BACKLOG.10.8"),
    ("thin_mcp_transport", "pending", "FUTURE-PARITY-BACKLOG.10.9"),
    ("public_no_drift", "pending", "FUTURE-PARITY-BACKLOG.10.10"),
]
ADMISSIONS = [
    ("perl", "perl", "complete", "FUTURE-PARITY-BACKLOG.10.3"),
    ("rust", "rust", "complete", "FUTURE-PARITY-BACKLOG.10.4"),
    ("dart", "dart", "pending", "FUTURE-PARITY-BACKLOG.10.5"),
    ("julia", "julia", "pending", "FUTURE-PARITY-BACKLOG.10.6"),
    ("lua", "puc_lua", "pending", "FUTURE-PARITY-BACKLOG.10.7"),
    ("lua", "luajit", "pending", "FUTURE-PARITY-BACKLOG.10.7"),
]
PERL_ADMISSION = {
    "path": "t/semantic_introspection_perl_admission.t",
    "canonical_driver": "tools/run_ci_local.sh",
    "roles": [
        "source_normalization",
        "compiled_snapshots",
        "failed_snapshot",
        "runtime_direct",
        "runtime_loaded",
        "runtime_generated",
        "runtime_traced",
        "native_and_neutral_json",
        "exact_twenty_queries",
        "privacy_page_budget_error_explain",
        "query_non_interference",
        "stale_host_leak_denial",
    ],
}
RUST_ADMISSION = {
    "path": "rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs",
    "canonical_driver": "tools/run_ci_local.sh",
    "roles": PERL_ADMISSION["roles"].copy(),
}
TOOLBOX_REQUIRED_CLAIMS = [
    "semantic introspection contract: 6 fixture groups, 20 exact queries, 73 rejected mutations, rollout 3 complete / 6 pending, admission 2 complete / 4 pending",
    "t/semantic_index_perl_runtime_observation.t",
    "Its 106 assertions match the twentieth response digest across eight execution roles",
    "t/semantic_introspection_perl_admission.t",
    "Its 12 exact-once roles cover strict byte/text source normalization",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_foundation",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_introspection_rust_admission",
    "Its 12 exact-once roles compose all 20 digests",
]
TOOLBOX_FORBIDDEN_CLAIMS = [
    "65 rejected mutations",
    "rollout 2 complete / 7 pending",
    "admission 1 complete / 5 pending",
    "57 rejected mutations",
    "rollout 1 complete / 8 pending",
    "runtime observation and backend admission remain later",
    "runtime observation, rollout, and admission remain later",
    "the runtime-events case remains `.10.3.5`",
]


class ContractError(ValueError):
    """Stable executable-contract validation failure."""


def require(condition: bool, detail: str) -> None:
    if not condition:
        raise ContractError(detail)


def require_fields(value: Any, fields: list[str] | set[str], context: str) -> dict[str, Any]:
    require(isinstance(value, dict) and set(value) == set(fields), f"{context} fields drifted")
    return value


def toolbox_claim_errors(text: str) -> list[str]:
    errors = [
        f"required claim count is {text.count(claim)}, expected 1: {claim}"
        for claim in TOOLBOX_REQUIRED_CLAIMS
        if text.count(claim) != 1
    ]
    errors.extend(
        f"stale claim remains: {claim}"
        for claim in TOOLBOX_FORBIDDEN_CLAIMS
        if claim in text
    )
    return errors


def validate_toolbox_claims(text: str) -> None:
    errors = toolbox_claim_errors(text)
    require(not errors, "semantic toolbox current-state drifted: " + "; ".join(errors))


def validate_toolbox_guard_probes(text: str) -> None:
    """Prove that both an omitted claim and a wrong current value are rejected."""
    omitted = text.replace(TOOLBOX_REQUIRED_CLAIMS[-1], "", 1)
    require(toolbox_claim_errors(omitted), "semantic toolbox omission guard is ineffective")
    wrong = text.replace("73 rejected mutations", "72 rejected mutations", 1)
    require(toolbox_claim_errors(wrong), "semantic toolbox wrong-value guard is ineffective")


def load_json(path: Path) -> dict[str, Any]:
    def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        value: dict[str, Any] = {}
        for key, item in pairs:
            require(key not in value, f"{path.relative_to(ROOT)} repeats JSON key {key}")
            value[key] = item
        return value

    value = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
    require(isinstance(value, dict), f"{path.relative_to(ROOT)} must contain one JSON object")
    return value


def canonical_digest(value: Any) -> str:
    encoded = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def escaped_id(value: str) -> str:
    return quote_from_bytes(value.encode("utf-8"), safe="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._~-")


def validate_shape(value: Any, context: str, *, target: bool = False) -> None:
    shape = require_fields(value, SHAPE_FIELDS, context)
    kinds = TARGET_SHAPE_KINDS if target else VALUE_SHAPE_KINDS
    kind = shape["kind"]
    require(kind in kinds, f"{context} kind drifted")
    require(isinstance(shape["members"], list), f"{context} members drifted")
    if target:
        require(all(shape[key] is None for key in ["element", "key", "value", "signature"]), f"{context} target payload drifted")
        require(shape["members"] == [], f"{context} target members drifted")
        return
    if kind == "array":
        validate_shape(shape["element"], f"{context}.element")
        require(all(shape[key] is None for key in ["key", "value", "signature"]), f"{context} array payload drifted")
        require(shape["members"] == [], f"{context} array members drifted")
    elif kind == "harray":
        validate_shape(shape["key"], f"{context}.key")
        validate_shape(shape["value"], f"{context}.value")
        require(shape["element"] is None and shape["signature"] is None and shape["members"] == [], f"{context} harray payload drifted")
    elif kind == "codeblock":
        validate_signature(shape["signature"], f"{context}.signature")
        require(all(shape[key] is None for key in ["element", "key", "value"]) and shape["members"] == [], f"{context} codeblock payload drifted")
    elif kind == "union":
        require(all(shape[key] is None for key in ["element", "key", "value", "signature"]), f"{context} union payload drifted")
        require(len(shape["members"]) >= 2, f"{context} union must have at least two members")
        for index, member in enumerate(shape["members"]):
            validate_shape(member, f"{context}.members[{index}]")
        member_keys = [(VALUE_SHAPE_KINDS.index(member["kind"]), json.dumps(member, ensure_ascii=False, sort_keys=True, separators=(",", ":"))) for member in shape["members"]]
        require(member_keys == sorted(member_keys) and len(member_keys) == len(set(member_keys)), f"{context} union order/dedup drifted")
    else:
        require(all(shape[key] is None for key in ["element", "key", "value", "signature"]), f"{context} scalar payload drifted")
        require(shape["members"] == [], f"{context} scalar members drifted")


def validate_signature(value: Any, context: str) -> None:
    signature = require_fields(value, SIGNATURE_FIELDS, context)
    require(isinstance(signature["parameters"], list), f"{context} parameters drifted")
    names: set[str] = set()
    for index, parameter in enumerate(signature["parameters"]):
        parameter = require_fields(parameter, SIGNATURE_PARAMETER_FIELDS, f"{context}.parameters[{index}]")
        require(isinstance(parameter["name"], str) and parameter["name"] not in names, f"{context} parameter name drifted")
        require(parameter["kind"] in {"value", "codeblock"}, f"{context} parameter kind drifted")
        require(isinstance(parameter["required"], bool), f"{context} parameter required flag drifted")
        names.add(parameter["name"])
    require(isinstance(signature["arity_min"], int) and signature["arity_min"] >= 0, f"{context} arity_min drifted")
    require(signature["arity_max"] is None or isinstance(signature["arity_max"], int) and signature["arity_max"] >= signature["arity_min"], f"{context} arity_max drifted")
    require(signature["rest_parameter"] is None or isinstance(signature["rest_parameter"], str), f"{context} rest parameter drifted")
    require((signature["rest_parameter"] is None) == (signature["arity_max"] is not None), f"{context} rest/unbounded arity drifted")
    require(signature["rest_parameter"] is None or signature["rest_parameter"] not in names, f"{context} rest parameter duplicates a fixed parameter")
    require(isinstance(signature["final_codeblock"], bool), f"{context} final-codeblock flag drifted")
    require(not signature["final_codeblock"] or signature["parameters"] and signature["parameters"][-1]["kind"] == "codeblock", f"{context} final-codeblock position drifted")


def validate_record_facts(record: dict[str, Any], context: str) -> None:
    kind = record["kind"]
    facts = require_fields(record["facts"], FACT_KEYS[kind], f"{context}.facts")
    shape_keys: list[tuple[str, bool]] = []
    if kind == "rule": shape_keys = [("value_shape", False)]
    elif kind == "regex_slot": shape_keys = [("target_shape", True)]
    elif kind == "edge": shape_keys = [("value_shape", False), ("target_shape", True)]
    elif kind == "lifecycle": shape_keys = [("value_shape", False)]
    elif kind in {"function", "helper"}: shape_keys = [("return_shape", False)]
    elif kind == "binding": shape_keys = [("value_shape", False)]
    elif kind == "call":
        shape_keys = [("return_shape", False), ("target_shape", True)]
        require(isinstance(facts["argument_shapes"], list), f"{context} argument shapes drifted")
        for index, shape in enumerate(facts["argument_shapes"]): validate_shape(shape, f"{context}.argument_shapes[{index}]")
    elif kind == "staged_artifact": shape_keys = [("value_shape", False)]
    elif kind == "execution": shape_keys = [("result_shape", False)]
    elif kind == "event": shape_keys = [("value_shape", False)]
    for key, target in shape_keys:
        validate_shape(facts[key], f"{context}.{key}", target=target)
    if kind in {"function", "helper"}: validate_signature(facts["signature"], f"{context}.signature")
    if kind == "staged_artifact":
        require(facts["artifact_kind"] in {"payload", "parse_job", "result"}, f"{context} staged kind drifted")
        require(facts["status"] in {"pending", "succeeded", "failed", "not_run"}, f"{context} staged status drifted")
        require(isinstance(facts["parent_path"], list) and all(isinstance(item, str) for item in facts["parent_path"]), f"{context} parent path drifted")
    if kind == "explanation_step":
        output = require_fields(facts["output_fact"], OUTPUT_FACT_FIELDS, f"{context}.output_fact")
        require(isinstance(output["record_id"], str) and isinstance(output["path"], str) and output["path"].startswith("/facts/"), f"{context} output fact drifted")
        require(isinstance(facts["input_ids"], list), f"{context} input ids drifted")


def validate_record_id(record: dict[str, Any], context: str) -> None:
    kind, record_id, order = record["kind"], record["id"], record["order"]
    if kind == "spec": require(record_id == "spec:0", f"{context} spec id drifted")
    elif kind == "source": require(record_id == f"source:{order}", f"{context} source id drifted")
    elif kind == "rule": require(record_id == f"rule:{escaped_id(record['name'])}", f"{context} rule id drifted")
    elif kind == "regex_slot": require(record_id == f"regex:{record['owner_id']}:{record['facts']['authored_index']}", f"{context} regex id drifted")
    elif kind == "edge": require(record_id == f"edge:{record['owner_id']}:{order}", f"{context} edge id drifted")
    elif kind == "lifecycle": require(record_id == f"lifecycle:{record['owner_id']}:{record['facts']['marker']}:{order}", f"{context} lifecycle id drifted")
    elif kind in {"function", "helper"}: require(record_id == f"{kind}:{escaped_id(record['name'])}", f"{context} callable id drifted")
    elif kind == "binding": require(record_id == f"binding:{record['owner_id']}:{escaped_id(record['name'])}:{order}", f"{context} binding id drifted")
    elif kind == "call": require(re.fullmatch(rf"call:{re.escape(record['owner_id'])}:\d+", record_id) is not None, f"{context} call id drifted")
    elif kind == "staged_artifact": require(record_id == f"staged:{record['facts']['artifact_kind']}:{record['owner_id']}:{order}", f"{context} staged id drifted")
    elif kind == "generated_artifact": require(record_id == f"generated:{record['facts']['artifact_kind']}:{order}", f"{context} generated id drifted")
    elif kind == "diagnostic": require(record_id == f"diagnostic:{record['facts']['stage']}:{order}", f"{context} diagnostic id drifted")
    elif kind == "decision": require(record_id.startswith("decision:") and record["owner_id"] in record_id, f"{context} decision id drifted")
    elif kind == "execution": require(record_id == f"execution:{order}", f"{context} execution id drifted")
    elif kind == "event": require(record_id == f"event:{record['owner_id']}:{order}", f"{context} event id drifted")
    elif kind == "explanation_step": require(record_id == f"explanation:{record['owner_id']}:{order}", f"{context} explanation id drifted")


def byte_line_column(data: bytes, offset: int) -> tuple[int, int]:
    require(0 <= offset <= len(data), "source span byte offset is outside source")
    prefix = data[:offset].decode("utf-8")
    return prefix.count("\n") + 1, len(prefix.rsplit("\n", 1)[-1]) + 1


def validate_source_ref(ref: Any, source_bytes: bytes, logical_name: str, context: str) -> None:
    ref = require_fields(ref, SOURCE_REF_FIELDS, context)
    require(ref["source_id"] == "source:0" and ref["logical_name"] == logical_name, f"{context} source identity drifted")
    require("/" not in logical_name and "\\" not in logical_name and ":" not in logical_name, f"{context} leaks a host path")
    span = require_fields(ref["span"], SPAN_FIELDS, f"{context}.span")
    start, end = span["start_byte"], span["end_byte"]
    require(isinstance(start, int) and isinstance(end, int) and 0 <= start <= end <= len(source_bytes), f"{context} byte span drifted")
    excerpt_bytes = source_bytes[start:end]
    require(excerpt_bytes.decode("utf-8") == ref["excerpt"], f"{context} excerpt does not match exact UTF-8 bytes")
    require(byte_line_column(source_bytes, start) == (span["start_line"], span["start_column"]), f"{context} start coordinates drifted")
    require(byte_line_column(source_bytes, end) == (span["end_line"], span["end_column"]), f"{context} end coordinates drifted")
    digest = "sha256:" + hashlib.sha256(source_bytes).hexdigest()
    require(ref["content_digest"] == digest, f"{context} content digest drifted")
    require(isinstance(ref["provenance_ids"], list) and all(isinstance(item, str) for item in ref["provenance_ids"]), f"{context} provenance ids drifted")


def validate_contract(contract: dict[str, Any]) -> None:
    require_fields(contract, TOP_LEVEL_FIELDS, "contract")
    require(contract["format"] == 1 and contract["contract_id"] == CONTRACT_ID, "contract identity drifted")
    require(contract["model_id"] == MODEL_ID and contract["query_id"] == QUERY_ID, "model/query identity drifted")
    require(contract["task_owner"] == TASK_OWNER, "task owner drifted")
    require(contract["decisions"] == ["docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md", "docs/decisions/0050-semantic-introspection-staged-artifact-records.md"], "decision inventory drifted")
    scope = require_fields(contract["scope"], {"behavior_change", "backend_admission", "neutral_model", "checker", "mcp_role"}, "scope")
    require(scope == {"behavior_change": False, "backend_admission": False, "neutral_model": "capability_conformance/semantic_introspection_model.json", "checker": "tools/check_semantic_introspection_contract.py", "mcp_role": "transport_only_after_native_admission"}, "neutral scope drifted")

    schema = require_fields(contract["schema"], {
        "record_fields", "relation_fields", "record_kinds", "relation_kinds", "fact_keys",
        "source_sensitive_fact_paths", "relation_fact_keys", "shape_fields", "value_shape_kinds",
        "target_shape_kinds", "signature_fields", "signature_parameter_fields", "signature_policy", "output_fact_fields", "id_families",
        "id_escape", "record_order", "relation_order", "nullable_fields_are_present", "arrays_are_order_sensitive",
        "object_key_order_is_semantic", "backend_private_fields_forbidden",
    }, "schema")
    require(schema["record_fields"] == RECORD_FIELDS and schema["relation_fields"] == RELATION_FIELDS, "record/relation fields drifted")
    require(schema["record_kinds"] == RECORD_KINDS and schema["relation_kinds"] == RELATION_KINDS, "record/relation kinds drifted")
    require(schema["fact_keys"] == FACT_KEYS and schema["relation_fact_keys"] == RELATION_FACT_KEYS, "fact vocabulary drifted")
    require(schema["source_sensitive_fact_paths"] == {"regex_slot": ["/facts/pattern"], "diagnostic": ["/facts/message"], "explanation_step": ["/facts/summary"]}, "source-sensitive fact policy drifted")
    require(schema["shape_fields"] == SHAPE_FIELDS and schema["value_shape_kinds"] == VALUE_SHAPE_KINDS and schema["target_shape_kinds"] == TARGET_SHAPE_KINDS, "shape vocabulary drifted")
    require(schema["signature_fields"] == SIGNATURE_FIELDS and schema["signature_parameter_fields"] == SIGNATURE_PARAMETER_FIELDS and schema["output_fact_fields"] == OUTPUT_FACT_FIELDS, "nested fact-object schema drifted")
    require(schema["signature_policy"] == {"parameter_kinds": ["value", "codeblock"], "unbounded_arity_max": None, "rest_parameter_requires_unbounded_max": True, "final_codeblock_position": "final_only"}, "signature policy drifted")
    require(schema["id_escape"] == "strict_utf8_bytes_percent_escape_uppercase_except_A-Za-z0-9._~-", "id escape drifted")
    require(schema["record_order"] == ["record_kind_rank", "source_order", "id"] and schema["relation_order"] == ["source_record_order", "relation_kind_rank", "target_order", "id"], "canonical ordering drifted")
    require(schema["nullable_fields_are_present"] is True and schema["arrays_are_order_sensitive"] is True and schema["object_key_order_is_semantic"] is False and schema["backend_private_fields_forbidden"] is True, "structural policy drifted")
    require(schema["id_families"]["staged_artifact"] == "staged:<artifact-kind>:<owner-id>:<zero-based-owner-order>", "staged id family drifted")
    require(schema["id_families"]["relation"] == "relation:<kind>:<from-id>:<to-id>:<order>", "relation id family drifted")

    query = require_fields(contract["query_contract"], {
        "request_fields", "page_request_fields", "budget_request_fields", "source_request_fields", "operations",
        "directions", "source_details", "page_default", "page_max", "budget_defaults", "budget_maxima",
        "response_fields", "snapshot_fields", "snapshot_states", "page_response_fields", "cost_fields",
        "query_diagnostic_fields", "query_diagnostic_codes", "operation_rules", "relation_traversal", "cost_policy",
        "page_cursor", "budget_result", "capabilities_features",
    }, "query contract")
    require(query["request_fields"] == REQUEST_FIELDS, "request fields drifted")
    require(query["page_request_fields"] == ["after_id", "limit"] and query["budget_request_fields"] == ["max_records", "max_relations", "max_depth"] and query["source_request_fields"] == ["detail", "include_content_digest"], "nested request fields drifted")
    require(query["operations"] == ["capabilities", "list", "get", "relations", "explain"] and query["directions"] == ["outgoing", "incoming", "both"], "operation/direction vocabulary drifted")
    require(query["source_details"] == ["none", "identity", "span", "text"], "source detail order drifted")
    require(query["page_default"] == 100 and query["page_max"] == 1000, "page limits drifted")
    require(query["budget_defaults"] == {"max_records": 1000, "max_relations": 2000, "max_depth": 4}, "budget defaults drifted")
    require(query["budget_maxima"] == {"max_records": 10000, "max_relations": 20000, "max_depth": 8}, "budget maxima drifted")
    require(query["response_fields"] == RESPONSE_FIELDS and query["snapshot_fields"] == SNAPSHOT_FIELDS and query["page_response_fields"] == PAGE_FIELDS and query["cost_fields"] == COST_FIELDS and query["query_diagnostic_fields"] == QUERY_DIAGNOSTIC_FIELDS, "response schema drifted")
    require(query["query_diagnostic_codes"] == ["semantic_query_budget_exceeded", "semantic_query_invalid", "semantic_query_source_detail_forbidden", "semantic_query_contract_unsupported"], "query diagnostic vocabulary drifted")
    require(query["snapshot_states"] == ["compiled", "failed_compilation"], "snapshot state vocabulary drifted")
    require(query["operation_rules"] == {
        "capabilities": {"subjects": "empty", "primary": "one_capabilities_record", "secondary": "no_relations"},
        "list": {"subjects": "empty", "primary": "filtered_records", "secondary": "no_relations"},
        "get": {"subjects": "one_or_more_record_ids", "primary": "subject_records", "secondary": "no_relations"},
        "relations": {"subjects": "one_or_more_record_ids", "primary": "filtered_directional_relations", "secondary": "no_records"},
        "explain": {"subjects": "exactly_one_decision_or_semantic_subject", "primary": "decision_then_explanation_steps", "secondary": "explained_by_only"},
    }, "operation rules drifted")
    require(query["relation_traversal"] == {"algorithm": "directional_breadth_first", "filters_constrain_traversal": True, "deduplicate": "relation_id_then_frontier_record_id", "result_order": "canonical_relation_order", "max_depth_zero": "empty_prefix_with_budget_diagnostic_when_a_matching_relation_exists"}, "relation traversal policy drifted")
    require(query["cost_policy"] == {"records_examined": "emitted_primary_records_including_explain_decision", "relations_examined": "emitted_primary_or_explanation_relations", "depth_reached": "deepest_emitted_relation_frontier", "cursor_lookup": "not_charged"}, "cost policy drifted")
    require(query["capabilities_features"] == [] and query["page_cursor"] == "last_returned_primary_canonical_id", "capability/page policy drifted")
    require(query["budget_result"] == "deterministic_prefix_complete_false_with_budget_diagnostic", "budget result policy drifted")

    source = require_fields(contract["source_contract"], {
        "source_reference_fields", "span_fields", "span_coordinates", "digest", "none", "identity", "span", "text",
        "forbidden_identity", "ceiling_is_applied_before_native_response", "mcp_cannot_raise_ceiling",
    }, "source contract")
    require(source["source_reference_fields"] == SOURCE_REF_FIELDS and source["span_fields"] == SPAN_FIELDS, "source/span fields drifted")
    require(source["span_coordinates"] == "zero_based_half_open_strict_utf8_bytes_one_based_lines_and_unicode_scalar_columns", "span coordinate policy drifted")
    require(source["digest"] == "sha256_lowercase_hex_over_exact_strict_utf8_source_bytes", "digest policy drifted")
    require(source["ceiling_is_applied_before_native_response"] is True and source["mcp_cannot_raise_ceiling"] is True, "source ceiling ownership drifted")
    require(source["forbidden_identity"] == ["implicit_host_path", "host_uri", "backend_type", "object_identity", "memory_address", "callable_value", "compiled_regex_object", "host_exception", "generated_implementation_source"], "privacy denylist drifted")
    require(source["none"] == "null_source_and_source_derived_facts_redacted" and source["identity"] == "source_id_and_registered_logical_name_only" and source["span"] == "identity_plus_span" and source["text"] == "span_plus_excerpt_and_optional_digest", "source projection policy drifted")
    require(contract["static_rule_authority"] == STATIC_RULE_AUTHORITY, "static rule authority drifted")
    require(contract["generated_plan_authority"] == GENERATED_PLAN_AUTHORITY, "generated plan authority drifted")

    require([row["id"] for row in contract["fixture_groups"]] == FIXTURE_GROUP_IDS, "six fixture groups drifted")
    require(contract["fixture_groups"] == [
        {"id": "rule_regex_edge_lifecycle_graph", "sources": ["graph"], "required_kinds": ["rule", "regex_slot", "edge", "lifecycle", "decision", "explanation_step"]},
        {"id": "call_resolution_and_shapes", "sources": ["calls_and_staging"], "required_kinds": ["function", "helper", "binding", "call", "decision", "explanation_step"]},
        {"id": "staged_and_generated_provenance", "sources": ["calls_and_staging"], "required_kinds": ["staged_artifact", "generated_artifact"], "required_relations": ["consumes", "produces", "lowered_from", "staged_by", "generated_as"]},
        {"id": "diagnostics_and_explanations", "sources": ["failed", "graph", "calls_and_staging"], "required_kinds": ["diagnostic", "decision", "explanation_step"]},
        {"id": "runtime_observation", "sources": ["runtime"], "required_kinds": ["execution", "event"], "required_relations": ["observed_as"]},
        {"id": "privacy_pagination_budget_and_errors", "sources": ["privacy", "graph"], "source_details": ["none", "identity", "span", "text"], "required_errors": ["semantic_query_budget_exceeded", "semantic_query_invalid", "semantic_query_source_detail_forbidden", "semantic_query_contract_unsupported"]},
    ], "fixture-group obligations drifted")
    for index, row in enumerate(contract["source_fixtures"]):
        fields = {"id", "path", "logical_name", "sha256", "bytes"}
        if index == 3: fields |= {"input_path", "input_sha256"}
        require_fields(row, fields, f"source fixture {index}")
    source_rows = [(row["id"], row["path"], row["logical_name"], row["sha256"], row["bytes"]) for row in contract["source_fixtures"]]
    require(source_rows == SOURCE_FIXTURES, "source fixture inventory/digests drifted")
    runtime_fixture = contract["source_fixtures"][3]
    require(runtime_fixture["input_path"] == "capability_conformance/semantic_introspection/runtime.input" and runtime_fixture["input_sha256"] == "a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece", "runtime input fixture drifted")
    require([row["id"] for row in contract["snapshots"]] == SNAPSHOT_IDS, "snapshot inventory drifted")
    for row in contract["snapshots"]: require_fields(row, {"id", "fixture", "model_snapshot", "state", "has_execution", "source_detail_ceiling"}, f"snapshot inventory {row.get('id')}")
    require([(row["id"], row["fixture"], row["model_snapshot"], row["state"], row["has_execution"], row["source_detail_ceiling"]) for row in contract["snapshots"]] == [
        ("graph", "graph", "graph", "compiled", False, "text"),
        ("calls", "calls_and_staging", "calls", "compiled", False, "text"),
        ("failed", "failed", "failed", "failed_compilation", False, "span"),
        ("runtime", "runtime", "runtime", "compiled", True, "text"),
        ("privacy", "privacy", "privacy", "compiled", False, "text"),
        ("privacy_limited", "privacy", "privacy_limited", "compiled", False, "identity"),
    ], "snapshot policy inventory drifted")
    require([row["id"] for row in contract["query_cases"]] == QUERY_CASE_IDS, "query case coverage/order drifted")
    for case in contract["query_cases"]:
        require_fields(case, {"id", "snapshot", "request", "expected"}, f"query case {case.get('id')}")
        expected = require_fields(case["expected"], {"ok", "record_ids", "relation_ids", "diagnostic_codes", "complete", "response_sha256"}, f"query case {case['id']} expected")
        require(re.fullmatch(r"[0-9a-f]{64}", expected["response_sha256"]) is not None and expected["response_sha256"] != "0" * 64, f"query case {case['id']} response digest is not frozen")
    for row in contract["target_admissions"]: require_fields(row, {"backend", "runtime", "status", "owner", "native_api", "consumer"}, f"target admission {row.get('runtime')}")
    admissions = [(row["backend"], row["runtime"], row["status"], row["owner"]) for row in contract["target_admissions"]]
    require(admissions == ADMISSIONS, "six-runtime admission inventory drifted")
    require(all(row["native_api"] == "capabilities_plus_query" for row in contract["target_admissions"]), "native API inventory drifted")
    require(contract["target_admissions"][0]["consumer"] == PERL_ADMISSION, "Perl admission consumer topology drifted")
    require(contract["target_admissions"][1]["consumer"] == RUST_ADMISSION, "Rust admission consumer topology drifted")
    require(all(row["consumer"] is None for row in contract["target_admissions"][2:]), "backend admitted before its owned leaf")
    for row in contract["rollout"]: require_fields(row, {"capability", "status", "owner"}, f"rollout {row.get('capability')}")
    rollout = [(row["capability"], row["status"], row["owner"]) for row in contract["rollout"]]
    require(rollout == ROLLOUT, "rollout inventory drifted")
    ci = require_fields(contract["canonical_ci"], {"driver", "neutral_checker", "required_tracked_files", "backend_consumers", "mcp_direct_identity"}, "canonical CI")
    require(ci == {"driver": "tools/run_ci_local.sh", "neutral_checker": "unconditional", "required_tracked_files": ["capability_conformance/semantic_introspection_contract.json", "capability_conformance/semantic_introspection_model.json", "capability_conformance/rule_local_cursor_contract.json", "tools/check_semantic_introspection_contract.py", "t/semantic_introspection_perl_admission.t", "rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs"], "backend_consumers": "not_admitted_before_owned_rollout_leaf", "mcp_direct_identity": "pending_FUTURE-PARITY-BACKLOG.10.9"}, "canonical CI topology drifted")
    require(len(contract["mutations"]) == 73 and len(set(contract["mutations"])) == 73, "mutation inventory drifted")


def neutral_repetition_from_header(header: str) -> tuple[bool, int | None, int | None]:
    suffix = header[3:]
    if suffix.startswith("::"):
        mode = suffix[2:]
    elif suffix.startswith(":"):
        mode = suffix[1:]
    else:
        raise ContractError(f"rule header {header!r} has no admitted colon form")
    if mode in {"", "AND", "&", "|"}:
        return False, None, None
    if mode in {"OR", "OR+", "+"}:
        return True, 1, None
    if mode == "*":
        return True, 0, None
    if mode == "?":
        return True, 0, 1
    bounds = re.fullmatch(r"(?:AND|OR)?\{(\d*),(\d*)\}|(?:AND|OR)?\{(\d+)\}", mode)
    require(bounds is not None, f"rule header {header!r} has no neutral repetition mapping")
    if bounds.group(3) is not None:
        exact = int(bounds.group(3))
        return True, exact, exact
    lower = int(bounds.group(1)) if bounds.group(1) else 0
    upper = int(bounds.group(2)) if bounds.group(2) else None
    return True, lower, upper


def validate_static_rule_authority(contract: dict[str, Any], model: dict[str, Any]) -> None:
    authority = contract["static_rule_authority"]
    rule_local = load_json(ROOT / authority["path"])
    require(rule_local.get("contract_id") == authority["contract_id"], "rule-local authority identity drifted")
    family_cases = {row["header"]: row for row in rule_local["family_cases"]}
    require(len(family_cases) == len(rule_local["family_cases"]), "rule-local family header inventory is ambiguous")

    for snapshot in model["snapshots"]:
        records = snapshot["records"]
        rules = [record for record in records if record["kind"] == "rule"]
        edges_by_owner: dict[str, list[dict[str, Any]]] = {}
        for edge in (record for record in records if record["kind"] == "edge"):
            edges_by_owner.setdefault(edge["owner_id"], []).append(edge)
        diagnostics = [record["facts"]["code"] for record in records if record["kind"] == "diagnostic"]

        for rule in rules:
            context = f"snapshot {snapshot['id']} static rule {rule['id']}"
            require(rule["source"] in snapshot["source_refs"], f"{context} has no header source authority")
            excerpt = snapshot["source_refs"][rule["source"]]["excerpt"]
            require(excerpt.startswith(rule["name"] + ":"), f"{context} header/name drifted")
            neutral_header = "Top" + excerpt[len(rule["name"]):]
            require(neutral_header in family_cases, f"{context} header is absent from the rule-local authority")
            family_case = family_cases[neutral_header]
            source_family = family_case["family"]
            expected_family = authority["neutral_family_map"][source_family]
            expected_cursor = authority["neutral_cursor_map"][family_case["cursor_policy"]]
            expected_repetition = neutral_repetition_from_header(neutral_header)
            is_entry_marker = excerpt.startswith(rule["name"] + "::")

            owned_edges = edges_by_owner.get(rule["id"], [])
            if owned_edges:
                ownerships = {edge["facts"]["ownership"] for edge in owned_edges}
                require(len(ownerships) == 1, f"{context} mixes normalized edge ownership")
                expected_ownership = next(iter(ownerships))
            elif snapshot["snapshot"]["state"] == "failed_compilation" and "unknown_rule_reference" in diagnostics:
                expected_ownership = authority["failed_bare_edge_ownership_by_family"][source_family]
            else:
                expected_ownership = authority["compiled_rule_without_edges"]

            facts = rule["facts"]
            require(facts["family"] == expected_family, f"{context} family contradicts rule-local authority")
            require(facts["cursor_policy"] == expected_cursor, f"{context} cursor contradicts rule-local authority")
            require(facts["is_entry_marker"] is is_entry_marker, f"{context} entry-marker fact contradicts its header")
            require(
                (facts["is_repetition"], facts["rep_min"], facts["rep_max"]) == expected_repetition,
                f"{context} repetition facts contradict its header",
            )
            require(facts["edge_ownership"] == expected_ownership, f"{context} edge ownership contradicts normalized edges")
            require(facts["edge_ownership"] in authority["neutral_edge_ownership_values"], f"{context} edge ownership is outside the neutral vocabulary")

        spec = next(record for record in records if record["kind"] == "spec")
        marked_rules = [rule["id"] for rule in rules if rule["facts"]["is_entry_marker"]]
        expected_entry = marked_rules[0] if marked_rules and snapshot["snapshot"]["state"] == "compiled" else None
        require(spec["facts"]["entry_rule_id"] == expected_entry, f"snapshot {snapshot['id']} entry selection contradicts rule headers")


def validate_generated_plan_authority(contract: dict[str, Any], model: dict[str, Any]) -> None:
    authority = contract["generated_plan_authority"]
    rule_local = load_json(ROOT / authority["path"])
    require(rule_local.get("contract_id") == authority["contract_id"], "generated-plan rule-local authority identity drifted")
    generated = rule_local.get(authority["generated_contract_key"])
    require(isinstance(generated, dict), "generated-source-v2 authority is missing")
    require(
        generated.get("contract_id") == "linkedspec-generated-source-v2" and generated.get("format_version") == 2,
        "generated-source-v2 identity drifted",
    )
    allowed_families = generated.get("seek_families", []) + generated.get("consume_families", [])
    require(len(allowed_families) == 10 and len(set(allowed_families)) == 10, "generated-source-v2 family inventory drifted")

    snapshot = next(row for row in model["snapshots"] if row["id"] == authority["snapshot"])
    require(snapshot["fixture"] == authority["fixture"], "generated-plan fixture authority drifted")
    records = {row["id"]: row for row in snapshot["records"]}
    artifact = records[authority["artifact_record_id"]]
    entry_rule = records[authority["entry_rule_id"]]
    require(artifact["kind"] == "generated_artifact", "generated-plan authority record kind drifted")
    require(entry_rule["kind"] == "rule" and entry_rule["source"] in snapshot["source_refs"], "generated-plan entry-rule authority drifted")
    header = snapshot["source_refs"][entry_rule["source"]]["excerpt"]
    require(header == entry_rule["name"] + "::", "calls generated-plan authority is not the exact default entry header")

    facts = artifact["facts"]
    require(facts["contract_id"] == generated["contract_id"], "generated artifact contract contradicts v2 authority")
    require(facts["format_version"] == generated["format_version"], "generated artifact format contradicts v2 authority")
    require(facts["plan_family"] in allowed_families, "generated artifact family is outside the v2 vocabulary")
    require(
        facts["plan_family"] == authority["default_selected_variant_family"],
        "generated artifact family contradicts the exact default selected-variant authority",
    )


def validate_model(contract: dict[str, Any], model: dict[str, Any]) -> None:
    require_fields(model, MODEL_FIELDS, "model")
    require(model["format"] == 1 and model["model"] == MODEL_ID and model["query"] == QUERY_ID, "model identity drifted")
    require([row["id"] for row in model["snapshots"]] == SNAPSHOT_IDS, "model snapshot inventory drifted")
    fixture_lookup = {row["id"]: row for row in contract["source_fixtures"]}
    snapshot_contract = {row["model_snapshot"]: row for row in contract["snapshots"]}
    for snapshot in model["snapshots"]:
        context = f"snapshot {snapshot.get('id')}"
        require_fields(snapshot, MODEL_SNAPSHOT_FIELDS, context)
        declared = snapshot_contract[snapshot["id"]]
        require(snapshot["fixture"] == declared["fixture"], f"{context} fixture drifted")
        require_fields(snapshot["snapshot"], SNAPSHOT_FIELDS, f"{context}.snapshot")
        require(snapshot["snapshot"]["id"] == "snapshot:0", f"{context} snapshot id drifted")
        for field in ["state", "has_execution", "source_detail_ceiling"]:
            require(snapshot["snapshot"][field] == declared[field], f"{context} {field} drifted")
        fixture = fixture_lookup[snapshot["fixture"]]
        source_bytes = (ROOT / fixture["path"]).read_bytes()
        require(isinstance(snapshot["source_refs"], dict), f"{context} source-ref map drifted")
        for key, ref in snapshot["source_refs"].items():
            validate_source_ref(ref, source_bytes, fixture["logical_name"], f"{context}.source_refs.{key}")

        records = snapshot["records"]
        relations = snapshot["relations"]
        require(isinstance(records, list) and isinstance(relations, list), f"{context} record/relation arrays drifted")
        ids: set[str] = set()
        for index, record in enumerate(records):
            record = require_fields(record, RECORD_FIELDS, f"{context}.records[{index}]")
            require(record["kind"] in RECORD_KINDS[1:], f"{context} contains invalid/synthetic record kind")
            require(isinstance(record["id"], str) and record["id"] not in ids, f"{context} duplicate record id")
            require(record["name"] is None or isinstance(record["name"], str), f"{context} record name drifted")
            require(record["owner_id"] is None or isinstance(record["owner_id"], str), f"{context} owner id drifted")
            require(isinstance(record["order"], int) and record["order"] >= 0, f"{context} record order drifted")
            require(record["source"] is None or record["source"] in snapshot["source_refs"], f"{context} record source ref drifted")
            require(record["redactions"] == [], f"{context} full neutral model must be unredacted")
            validate_record_facts(record, f"{context}.records[{index}]")
            validate_record_id(record, f"{context}.records[{index}]")
            ids.add(record["id"])
        expected_record_order = sorted(records, key=lambda row: (RECORD_KINDS.index(row["kind"]), row["order"], row["id"]))
        require(records == expected_record_order, f"{context} record canonical order drifted")
        for record in records:
            require(record["owner_id"] is None or record["owner_id"] in ids, f"{context} record owner is missing")
            if record["kind"] == "explanation_step":
                require(record["facts"]["output_fact"]["record_id"] in ids, f"{context} explanation output record is missing")
                require(all(item in ids for item in record["facts"]["input_ids"]), f"{context} explanation input record is missing")

        spec_record = next(record for record in records if record["kind"] == "spec")
        expected_spec_name = fixture["logical_name"][:-5] if fixture["logical_name"].endswith(".spec") else fixture["logical_name"]
        require(spec_record["name"] == expected_spec_name, f"{context} spec name contradicts caller logical identity")

        relation_ids: set[str] = set()
        record_rank = {record["id"]: index for index, record in enumerate(records)}
        for index, relation in enumerate(relations):
            relation = require_fields(relation, RELATION_FIELDS, f"{context}.relations[{index}]")
            require(relation["kind"] in RELATION_KINDS, f"{context} relation kind drifted")
            require(relation["from_id"] in ids and relation["to_id"] in ids, f"{context} relation endpoint is missing")
            require(isinstance(relation["order"], int) and relation["order"] >= 0, f"{context} relation order drifted")
            require(relation["id"] == f"relation:{relation['kind']}:{relation['from_id']}:{relation['to_id']}:{relation['order']}", f"{context} relation id drifted")
            require(relation["id"] not in relation_ids, f"{context} duplicate relation id")
            require(relation["source"] is None or relation["source"] in snapshot["source_refs"], f"{context} relation source ref drifted")
            require_fields(relation["facts"], RELATION_FACT_KEYS[relation["kind"]], f"{context}.relations[{index}].facts")
            require(isinstance(relation["evidence_ids"], list) and all(item in ids for item in relation["evidence_ids"]), f"{context} relation evidence drifted")
            relation_ids.add(relation["id"])
        expected_relation_order = sorted(relations, key=lambda row: (record_rank[row["from_id"]], RELATION_KINDS.index(row["kind"]), record_rank[row["to_id"]], row["id"]))
        require(relations == expected_relation_order, f"{context} relation canonical order drifted")
        validate_no_private_leaks(snapshot, context)
        validate_snapshot_semantics(snapshot)
    snapshots_by_fixture: dict[str, list[dict[str, Any]]] = {}
    for snapshot in model["snapshots"]: snapshots_by_fixture.setdefault(snapshot["fixture"], []).append(snapshot)
    for group in contract["fixture_groups"]:
        selected = [snapshot for fixture in group["sources"] for snapshot in snapshots_by_fixture.get(fixture, [])]
        record_kinds = {record["kind"] for snapshot in selected for record in snapshot["records"]}
        relation_kinds = {relation["kind"] for snapshot in selected for relation in snapshot["relations"]}
        require(all(kind in record_kinds for kind in group.get("required_kinds", [])), f"fixture group {group['id']} omits a required record kind")
        require(all(kind in relation_kinds for kind in group.get("required_relations", [])), f"fixture group {group['id']} omits a required relation kind")
    validate_static_rule_authority(contract, model)
    validate_generated_plan_authority(contract, model)


def validate_no_private_leaks(value: Any, context: str, path: str = "$") -> None:
    if isinstance(value, dict):
        for key, item in value.items(): validate_no_private_leaks(item, context, f"{path}.{key}")
    elif isinstance(value, list):
        for index, item in enumerate(value): validate_no_private_leaks(item, context, f"{path}[{index}]")
    elif isinstance(value, str):
        forbidden = [r"/(?:Users|home)/", r"[A-Za-z]:\\", r"(?:CODE|HASH|ARRAY|Regexp)\(0x[0-9A-Fa-f]+\)", r"\b0x[0-9A-Fa-f]{8,}\b"]
        require(not any(re.search(pattern, value) for pattern in forbidden), f"{context} leaks host-private identity at {path}")


def validate_snapshot_semantics(snapshot: dict[str, Any]) -> None:
    records = {record["id"]: record for record in snapshot["records"]}
    relations = {(row["kind"], row["from_id"], row["to_id"]) for row in snapshot["relations"]}
    if snapshot["id"] == "calls":
        staged = [record for record in snapshot["records"] if record["kind"] == "staged_artifact"]
        require([row["facts"]["artifact_kind"] for row in staged] == ["payload", "parse_job", "result"], "staged payload/job/result roles drifted")
        payload, job, result = [row["id"] for row in staged]
        owner = "function:normalize"
        for item in [payload, job, result]: require(("contains", owner, item) in relations, "staged owner containment drifted")
        require(("lowered_from", payload, "source:0") in relations, "staged payload source provenance drifted")
        require(("consumes", job, payload) in relations and ("produces", job, result) in relations, "staged job direction drifted")
        require(("staged_by", result, job) in relations and ("lowered_from", result, payload) in relations, "staged result provenance drifted")
        require(records[job]["kind"] != "generated_artifact" and "generated:handler_plan:0" in records, "staged/generated roles collapsed")
        require(("generated_as", "spec:0", "generated:handler_plan:0") in relations, "generated artifact provenance drifted")
    if snapshot["id"] == "runtime":
        require(snapshot["snapshot"]["has_execution"] is True and "execution:0" in records, "runtime observation drifted")
        require(sum(1 for kind, owner, _ in relations if kind == "observed_as" and owner == "execution:0") == 3, "runtime event topology drifted")
    if snapshot["id"] == "failed":
        require(snapshot["snapshot"]["state"] == "failed_compilation" and "diagnostic:compile:0" in records, "failed snapshot diagnostic drifted")


def projected_source(ref_key: str | None, snapshot: dict[str, Any], detail: str, include_digest: bool) -> Any:
    if ref_key is None or detail == "none": return None
    full = snapshot["source_refs"][ref_key]
    projected = {
        "source_id": full["source_id"],
        "logical_name": full["logical_name"],
        "span": copy.deepcopy(full["span"]) if detail in {"span", "text"} else None,
        "excerpt": full["excerpt"] if detail == "text" else None,
        "content_digest": full["content_digest"] if detail == "text" and include_digest else None,
        "provenance_ids": copy.deepcopy(full["provenance_ids"]),
    }
    return projected


def project_record(record: dict[str, Any], snapshot: dict[str, Any], contract: dict[str, Any], detail: str, include_digest: bool) -> dict[str, Any]:
    projected = copy.deepcopy(record)
    projected["source"] = projected_source(record["source"], snapshot, detail, include_digest)
    if detail != "text":
        paths = contract["schema"]["source_sensitive_fact_paths"].get(record["kind"], [])
        for path in paths:
            key = path.removeprefix("/facts/")
            projected["facts"][key] = None
        projected["redactions"] = copy.deepcopy(paths)
    return projected


def project_relation(relation: dict[str, Any], snapshot: dict[str, Any], detail: str, include_digest: bool) -> dict[str, Any]:
    projected = copy.deepcopy(relation)
    projected["source"] = projected_source(relation["source"], snapshot, detail, include_digest)
    return projected


def query_diagnostic(code: str, *, reason: str | None = None, requested: str | None = None) -> dict[str, Any]:
    if code == "semantic_query_budget_exceeded":
        return {"code": code, "severity": "warning", "message": "Semantic query budget was reached; returning the deterministic prefix.", "fields": {"limit": reason}}
    if code == "semantic_query_contract_unsupported":
        return {"code": code, "severity": "error", "message": "Unsupported semantic query contract.", "fields": {"requested": requested, "supported": [QUERY_ID]}}
    if code == "semantic_query_source_detail_forbidden":
        return {"code": code, "severity": "error", "message": "Requested source detail exceeds the index ceiling.", "fields": {"requested": requested, "ceiling": reason}}
    return {"code": "semantic_query_invalid", "severity": "error", "message": "Invalid semantic query request.", "fields": {"reason": reason}}


def empty_response(snapshot: dict[str, Any], request: dict[str, Any], diagnostic: dict[str, Any]) -> dict[str, Any]:
    return {
        "contract": QUERY_ID, "model": MODEL_ID, "ok": False, "snapshot": copy.deepcopy(snapshot["snapshot"]),
        "records": [], "relations": [], "page": {"after_id": request.get("page", {}).get("after_id"), "next_after_id": None, "complete": True},
        "cost": {"records_examined": 0, "relations_examined": 0, "depth_reached": 0}, "diagnostics": [diagnostic],
    }


def request_error(contract: dict[str, Any], snapshot: dict[str, Any], request: Any) -> dict[str, Any] | None:
    if not isinstance(request, dict):
        fake = {"page": {"after_id": None}}
        return empty_response(snapshot, fake, query_diagnostic("semantic_query_invalid", reason="request_not_object"))
    if request.get("contract") != QUERY_ID:
        return empty_response(snapshot, request, query_diagnostic("semantic_query_contract_unsupported", requested=request.get("contract")))
    if set(request) != set(REQUEST_FIELDS): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="request_fields"))
    if not isinstance(request["page"], dict) or set(request["page"]) != {"after_id", "limit"}: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="page_fields"))
    if not isinstance(request["budget"], dict) or set(request["budget"]) != {"max_records", "max_relations", "max_depth"}: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="budget_fields"))
    if not isinstance(request["source"], dict) or set(request["source"]) != {"detail", "include_content_digest"}: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="source_fields"))
    operation = request["operation"]
    if operation not in contract["query_contract"]["operations"]: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="operation"))
    for key in ["subjects", "record_kinds", "relation_kinds"]:
        if not isinstance(request[key], list) or not all(isinstance(item, str) for item in request[key]): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason=f"{key}_type"))
        if len(request[key]) != len(set(request[key])): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason=f"{key}_duplicate"))
    if any(kind not in RECORD_KINDS for kind in request["record_kinds"]): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="record_kind"))
    if any(kind not in RELATION_KINDS for kind in request["relation_kinds"]): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="relation_kind"))
    if request["record_kinds"] != sorted(request["record_kinds"], key=RECORD_KINDS.index): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="record_kind_order"))
    if request["relation_kinds"] != sorted(request["relation_kinds"], key=RELATION_KINDS.index): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="relation_kind_order"))
    if request["direction"] not in {"outgoing", "incoming", "both"}: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="direction"))
    if request["page"]["after_id"] is not None and not isinstance(request["page"]["after_id"], str): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="after_id"))
    if not isinstance(request["page"]["limit"], int) or not 1 <= request["page"]["limit"] <= 1000: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="page_limit"))
    maxima = contract["query_contract"]["budget_maxima"]
    for key in ["max_records", "max_relations", "max_depth"]:
        minimum = 0 if key == "max_depth" else 1
        if not isinstance(request["budget"][key], int) or not minimum <= request["budget"][key] <= maxima[key]: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason=key))
    detail = request["source"]["detail"]
    if detail not in contract["query_contract"]["source_details"] or not isinstance(request["source"]["include_content_digest"], bool): return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="source_policy"))
    if request["source"]["include_content_digest"] and detail != "text": return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="digest_requires_text"))
    levels = contract["query_contract"]["source_details"]
    ceiling = snapshot["snapshot"]["source_detail_ceiling"]
    if levels.index(detail) > levels.index(ceiling) or (request["source"]["include_content_digest"] and not snapshot["snapshot"]["content_digest_available"]):
        return empty_response(snapshot, request, query_diagnostic("semantic_query_source_detail_forbidden", requested=detail, reason=ceiling))
    unused_valid = (
        (operation in {"capabilities", "list"} and request["subjects"] == [] and request["relation_kinds"] == []) or
        (operation == "get" and len(request["subjects"]) >= 1 and request["record_kinds"] == [] and request["relation_kinds"] == []) or
        (operation == "relations" and len(request["subjects"]) >= 1 and request["record_kinds"] == []) or
        (operation == "explain" and len(request["subjects"]) == 1 and request["record_kinds"] == [] and request["relation_kinds"] == [])
    )
    if not unused_valid: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="operation_combination"))
    if operation == "capabilities" and request["record_kinds"] != []: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="capability_filter"))
    return None


def capabilities_record(contract: dict[str, Any], snapshot: dict[str, Any]) -> dict[str, Any]:
    query = contract["query_contract"]
    return {
        "id": "capabilities:0", "kind": "capabilities", "name": "semantic introspection v1", "owner_id": None,
        "order": 0, "source": None,
        "facts": {"model_ids": [MODEL_ID], "query_ids": [QUERY_ID], "record_kinds": RECORD_KINDS, "relation_kinds": RELATION_KINDS, "source_detail_ceiling": snapshot["snapshot"]["source_detail_ceiling"], "page_default": query["page_default"], "page_max": query["page_max"], "budget_defaults": copy.deepcopy(query["budget_defaults"]), "budget_maxima": copy.deepcopy(query["budget_maxima"]), "execution_observation": snapshot["snapshot"]["has_execution"], "features": []},
        "redactions": [],
    }


def page_stream(items: list[dict[str, Any]], request: dict[str, Any], budget_limit: int) -> tuple[list[dict[str, Any]], dict[str, Any], bool, str | None]:
    after_id = request["page"]["after_id"]
    if after_id is not None:
        ids = [item["id"] for item in items]
        if after_id not in ids: raise ContractError("invalid_after_id")
        items = items[ids.index(after_id) + 1:]
    limited_by_budget = len(items) > budget_limit
    selected = items[: min(request["page"]["limit"], budget_limit)]
    complete = len(selected) == len(items) and not limited_by_budget
    next_after = selected[-1]["id"] if selected and not complete else None
    reason = "budget" if limited_by_budget and len(selected) == budget_limit else None
    return selected, {"after_id": after_id, "next_after_id": next_after, "complete": complete}, limited_by_budget, reason


def traverse_relations(snapshot: dict[str, Any], request: dict[str, Any]) -> tuple[list[dict[str, Any]], dict[str, int], bool]:
    """Return canonical filtered relations reached by deterministic directional breadth-first traversal."""
    relation_kinds = set(request["relation_kinds"])
    direction = request["direction"]
    max_depth = request["budget"]["max_depth"]
    frontier = set(request["subjects"])
    visited_records = set(frontier)
    selected_depth: dict[str, int] = {}

    def layer_for(nodes: set[str]) -> list[dict[str, Any]]:
        return [
            relation for relation in snapshot["relations"]
            if (not relation_kinds or relation["kind"] in relation_kinds)
            and ((direction in {"outgoing", "both"} and relation["from_id"] in nodes)
                 or (direction in {"incoming", "both"} and relation["to_id"] in nodes))
            and relation["id"] not in selected_depth
        ]

    for depth in range(1, max_depth + 1):
        layer = layer_for(frontier)
        if not layer: break
        next_frontier: set[str] = set()
        for relation in layer:
            selected_depth[relation["id"]] = depth
            if direction in {"outgoing", "both"} and relation["from_id"] in frontier: next_frontier.add(relation["to_id"])
            if direction in {"incoming", "both"} and relation["to_id"] in frontier: next_frontier.add(relation["from_id"])
        next_frontier -= visited_records
        visited_records |= next_frontier
        frontier = next_frontier
        if not frontier: break
    depth_limited = bool(layer_for(frontier)) if frontier else False
    candidates = [relation for relation in snapshot["relations"] if relation["id"] in selected_depth]
    return candidates, selected_depth, depth_limited


def evaluate_query(contract: dict[str, Any], snapshot: dict[str, Any], request: dict[str, Any]) -> dict[str, Any]:
    error = request_error(contract, snapshot, request)
    if error is not None: return error
    operation = request["operation"]
    record_lookup = {row["id"]: row for row in snapshot["records"]}
    relation_lookup = snapshot["relations"]
    if operation in {"get", "relations"} and any(subject not in record_lookup for subject in request["subjects"]):
        return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="unknown_subject"))
    detail, digest = request["source"]["detail"], request["source"]["include_content_digest"]
    records: list[dict[str, Any]] = []
    relations: list[dict[str, Any]] = []
    diagnostics: list[dict[str, Any]] = []
    page = {"after_id": request["page"]["after_id"], "next_after_id": None, "complete": True}
    record_cost = relation_cost = depth = 0
    try:
        if operation == "capabilities":
            candidates = [capabilities_record(contract, snapshot)]
            records, page, budgeted, _ = page_stream(candidates, request, request["budget"]["max_records"])
            record_cost = len(records)
        elif operation in {"list", "get"}:
            candidates = snapshot["records"]
            if operation == "list" and request["record_kinds"]: candidates = [row for row in candidates if row["kind"] in request["record_kinds"]]
            if operation == "get": candidates = [row for row in candidates if row["id"] in request["subjects"]]
            selected, page, budgeted, _ = page_stream(candidates, request, request["budget"]["max_records"])
            records = [project_record(row, snapshot, contract, detail, digest) for row in selected]
            record_cost = len(selected)
        elif operation == "relations":
            candidates, relation_depths, depth_limited = traverse_relations(snapshot, request)
            selected, page, relation_limited, _ = page_stream(candidates, request, request["budget"]["max_relations"])
            budgeted = relation_limited or depth_limited
            relations = [project_relation(row, snapshot, detail, digest) for row in selected]
            relation_cost = len(selected)
            depth = max((relation_depths[row["id"]] for row in selected), default=0)
        else:
            subject = request["subjects"][0]
            decision = record_lookup.get(subject)
            if decision is None or decision["kind"] != "decision":
                owned = [row for row in snapshot["records"] if row["kind"] == "decision" and row["owner_id"] == subject]
                decision = owned[0] if len(owned) == 1 else None
            if decision is None: return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="not_explainable"))
            steps = [row for row in snapshot["records"] if row["kind"] == "explanation_step" and row["owner_id"] == decision["id"]]
            selected, page, budgeted, _ = page_stream(steps, request, max(0, request["budget"]["max_records"] - 1))
            records = [project_record(decision, snapshot, contract, detail, digest)] + [project_record(row, snapshot, contract, detail, digest) for row in selected]
            selected_ids = {row["id"] for row in selected}
            relations = [project_relation(row, snapshot, detail, digest) for row in relation_lookup if row["kind"] == "explained_by" and row["from_id"] == decision["id"] and row["to_id"] in selected_ids]
            record_cost, relation_cost, depth = len(records), len(relations), 1 if selected else 0
        if budgeted:
            page["complete"] = False
            if operation == "relations":
                budget_reason = "max_relations" if relation_limited else "max_depth"
            else:
                budget_reason = "max_records"
            diagnostics.append(query_diagnostic("semantic_query_budget_exceeded", reason=budget_reason))
    except ContractError as exc:
        require(str(exc) == "invalid_after_id", "unexpected query evaluation error")
        return empty_response(snapshot, request, query_diagnostic("semantic_query_invalid", reason="after_id_not_in_primary_stream"))
    return {"contract": QUERY_ID, "model": MODEL_ID, "ok": True, "snapshot": copy.deepcopy(snapshot["snapshot"]), "records": records, "relations": relations, "page": page, "cost": {"records_examined": record_cost, "relations_examined": relation_cost, "depth_reached": depth}, "diagnostics": diagnostics}


def validate_response(contract: dict[str, Any], response: dict[str, Any], context: str) -> None:
    require_fields(response, RESPONSE_FIELDS, context)
    require(response["contract"] == QUERY_ID and response["model"] == MODEL_ID and isinstance(response["ok"], bool), f"{context} identity/status drifted")
    require_fields(response["snapshot"], SNAPSHOT_FIELDS, f"{context}.snapshot")
    require_fields(response["page"], PAGE_FIELDS, f"{context}.page")
    require_fields(response["cost"], COST_FIELDS, f"{context}.cost")
    for index, record in enumerate(response["records"]):
        require_fields(record, RECORD_FIELDS, f"{context}.records[{index}]")
        validate_record_facts(record, f"{context}.records[{index}]")
        if record["source"] is not None: require_fields(record["source"], SOURCE_REF_FIELDS, f"{context}.records[{index}].source")
    for index, relation in enumerate(response["relations"]):
        require_fields(relation, RELATION_FIELDS, f"{context}.relations[{index}]")
        if relation["source"] is not None: require_fields(relation["source"], SOURCE_REF_FIELDS, f"{context}.relations[{index}].source")
    for index, diagnostic in enumerate(response["diagnostics"]):
        diagnostic = require_fields(diagnostic, QUERY_DIAGNOSTIC_FIELDS, f"{context}.diagnostics[{index}]")
        require(diagnostic["code"] in contract["query_contract"]["query_diagnostic_codes"], f"{context} diagnostic code drifted")


def validate_query_cases(contract: dict[str, Any], model: dict[str, Any]) -> dict[str, str]:
    snapshots = {row["id"]: row for row in model["snapshots"]}
    hashes: dict[str, str] = {}
    for case in contract["query_cases"]:
        require(case["snapshot"] in snapshots, f"query case {case['id']} snapshot is missing")
        response = evaluate_query(contract, snapshots[case["snapshot"]], case["request"])
        validate_response(contract, response, f"query case {case['id']} response")
        expected = case["expected"]
        require(response["ok"] == expected["ok"], f"query case {case['id']} ok status drifted")
        require([row["id"] for row in response["records"]] == expected["record_ids"], f"query case {case['id']} record answer drifted")
        require([row["id"] for row in response["relations"]] == expected["relation_ids"], f"query case {case['id']} relation answer drifted")
        require([row["code"] for row in response["diagnostics"]] == expected["diagnostic_codes"], f"query case {case['id']} diagnostics drifted")
        require(response["page"]["complete"] == expected["complete"], f"query case {case['id']} page completion drifted")
        digest = canonical_digest(response)
        hashes[case["id"]] = digest
        require(digest == expected["response_sha256"], f"query case {case['id']} exact response digest drifted")
    privacy_none = evaluate_query(contract, snapshots["privacy"], next(row["request"] for row in contract["query_cases"] if row["id"] == "privacy_none"))
    private_record = privacy_none["records"][0]
    require(private_record["source"] is None and private_record["facts"]["pattern"] is None and private_record["redactions"] == ["/facts/pattern"], "none-source redaction projection drifted")
    privacy_text = evaluate_query(contract, snapshots["privacy"], next(row["request"] for row in contract["query_cases"] if row["id"] == "privacy_text_and_digest"))
    public_record = privacy_text["records"][0]
    require(public_record["facts"]["pattern"] == "é" and public_record["source"]["excerpt"] == "/é/" and public_record["source"]["content_digest"].startswith("sha256:"), "text-source projection drifted")
    return hashes


def validate_filesystem(contract: dict[str, Any]) -> None:
    for fixture in contract["source_fixtures"]:
        path = ROOT / fixture["path"]
        require(path.is_file(), f"fixture {fixture['id']} is missing")
        data = path.read_bytes()
        require(len(data) == fixture["bytes"] and hashlib.sha256(data).hexdigest() == fixture["sha256"], f"fixture {fixture['id']} exact bytes drifted")
        data.decode("utf-8")
    runtime_input = ROOT / contract["source_fixtures"][3]["input_path"]
    require(hashlib.sha256(runtime_input.read_bytes()).hexdigest() == contract["source_fixtures"][3]["input_sha256"], "runtime input bytes drifted")
    for decision in contract["decisions"]: require((ROOT / decision).is_file(), f"decision {decision} is missing")
    adr_49 = (ROOT / contract["decisions"][0]).read_text(encoding="utf-8")
    adr_50 = (ROOT / contract["decisions"][1]).read_text(encoding="utf-8")
    require("linkedspec-semantic-model-v1" in adr_49 and "thin MCP" in adr_49, "ADR 0049 direction markers drifted")
    require("staged_artifact" in adr_50 and "consumes" in adr_50 and "produces" in adr_50, "ADR 0050 correction markers drifted")
    task_text = (ROOT / "docs/tasks/FUTURE-PARITY-BACKLOG.md").read_text(encoding="utf-8")
    require(re.search(r"- ID: `FUTURE-PARITY-BACKLOG\.10\.2`\n  Status: `(active|done)`", task_text) is not None, "task owner is neither active nor done")
    require("explicit staged payload/job/result records" in task_text, "task-tree staged correction marker drifted")
    ci_text = (ROOT / contract["canonical_ci"]["driver"]).read_text(encoding="utf-8")
    for path in contract["canonical_ci"]["required_tracked_files"]:
        require(f"require_tracked_file {path}" in ci_text, f"canonical CI does not require {path}")
    require("python3 tools/check_semantic_introspection_contract.py" in ci_text, "canonical CI does not run semantic introspection checker")
    perl_consumer = contract["target_admissions"][0]["consumer"]
    perl_consumer_path = ROOT / perl_consumer["path"]
    require(perl_consumer_path.is_file(), "Perl semantic admission consumer is missing")
    perl_consumer_text = perl_consumer_path.read_text(encoding="utf-8")
    for role in perl_consumer["roles"]:
        marker = re.compile(rf"^\s*{re.escape(role)}\s*=>\s*sub\s*\{{", re.MULTILINE)
        require(len(marker.findall(perl_consumer_text)) == 1, f"Perl semantic admission role marker drifted: {role}")
    require(f"require_tracked_file {perl_consumer['path']}" in ci_text, "canonical CI does not require the Perl semantic admission consumer")
    require(f"PERL5LIB= prove -Iperl {perl_consumer['path']}" in ci_text, "canonical CI does not run the Perl semantic admission consumer")

    rust_consumer = contract["target_admissions"][1]["consumer"]
    rust_consumer_path = ROOT / rust_consumer["path"]
    require(rust_consumer_path.is_file(), "Rust semantic admission consumer is missing")
    rust_consumer_text = rust_consumer_path.read_text(encoding="utf-8")
    for role in rust_consumer["roles"]:
        marker = re.compile(rf"^fn role_{re.escape(role)}\(\) \{{", re.MULTILINE)
        require(len(marker.findall(rust_consumer_text)) == 1, f"Rust semantic admission role marker drifted: {role}")
    require(f"require_tracked_file {rust_consumer['path']}" in ci_text, "canonical CI does not require the Rust semantic admission consumer")
    rust_command = "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_introspection_rust_admission"
    require(rust_command in ci_text, "canonical CI does not run the Rust semantic admission consumer")
    readme = (ROOT / "capability_conformance/README.md").read_text(encoding="utf-8")
    require(
        CONTRACT_ID in readme
        and "73 rejected mutations" in readme
        and "3 complete / 6 pending" in readme
        and "2 complete / 4 pending" in readme,
        "capability-conformance guide is not synchronized",
    )
    book = (ROOT / "docs/linkedspec-book/src/public-api/semantic-introspection.md").read_text(encoding="utf-8")
    require(
        MODEL_ID in book
        and "2 complete / 4 pending" in book
        and "t/semantic_introspection_perl_admission.t" in book
        and "semantic_introspection_rust_admission" in book,
        "mdBook semantic introspection page is not synchronized",
    )
    toolbox = TOOLBOX_PATH.read_text(encoding="utf-8")
    validate_toolbox_claims(toolbox)
    validate_toolbox_guard_probes(toolbox)


def validate_bundle(contract: dict[str, Any], model: dict[str, Any], *, check_filesystem: bool) -> dict[str, str]:
    validate_contract(contract)
    validate_model(contract, model)
    hashes = validate_query_cases(contract, model)
    if check_filesystem: validate_filesystem(contract)
    return hashes


def mutation_functions() -> dict[str, Callable[[dict[str, Any], dict[str, Any]], None]]:
    def contract_path(*keys: Any) -> Callable[[dict[str, Any], dict[str, Any]], None]:
        def mutate(contract: dict[str, Any], _model: dict[str, Any]) -> None:
            target: Any = contract
            for key in keys[:-1]: target = target[key]
            target.pop(keys[-1])
        return mutate

    def model_record(snapshot: str, record_id: str) -> Callable[[dict[str, Any], dict[str, Any]], dict[str, Any]]:
        def find(_contract: dict[str, Any], model: dict[str, Any]) -> dict[str, Any]:
            snap = next(row for row in model["snapshots"] if row["id"] == snapshot)
            return next(row for row in snap["records"] if row["id"] == record_id)
        return find

    def apply_to(finder: Callable[[dict[str, Any], dict[str, Any]], Any], action: Callable[[Any], None]) -> Callable[[dict[str, Any], dict[str, Any]], None]:
        return lambda contract, model: action(finder(contract, model))

    def remove_query(case_id: str) -> Callable[[dict[str, Any], dict[str, Any]], None]:
        return lambda contract, _model: contract["query_cases"].__setitem__(slice(None), [row for row in contract["query_cases"] if row["id"] != case_id])

    def mutate_and_refresh_hashes(
        finder: Callable[[dict[str, Any], dict[str, Any]], Any],
        action: Callable[[Any], None],
    ) -> Callable[[dict[str, Any], dict[str, Any]], None]:
        def mutate(contract: dict[str, Any], model: dict[str, Any]) -> None:
            action(finder(contract, model))
            snapshots = {row["id"]: row for row in model["snapshots"]}
            for case in contract["query_cases"]:
                response = evaluate_query(contract, snapshots[case["snapshot"]], case["request"])
                case["expected"]["response_sha256"] = canonical_digest(response)
        return mutate

    mutations: dict[str, Callable[[dict[str, Any], dict[str, Any]], None]] = {}
    mutations["remove_record_kind"] = lambda c, m: c["schema"]["record_kinds"].remove("event")
    mutations["rename_record_kind"] = lambda c, m: c["schema"]["record_kinds"].__setitem__(11, "staging")
    mutations["reorder_record_kinds"] = lambda c, m: c["schema"]["record_kinds"].reverse()
    mutations["remove_staged_fact"] = lambda c, m: c["schema"]["fact_keys"]["staged_artifact"].remove("status")
    mutations["rename_fact"] = lambda c, m: c["schema"]["fact_keys"]["rule"].__setitem__(0, "rule_family")
    mutations["extra_fact"] = lambda c, m: c["schema"]["fact_keys"]["call"].append("host_type")
    mutations["remove_relation_kind"] = lambda c, m: c["schema"]["relation_kinds"].remove("observed_as")
    mutations["reorder_relation_kinds"] = lambda c, m: c["schema"]["relation_kinds"].reverse()
    mutations["remove_consumes"] = lambda c, m: c["schema"]["relation_kinds"].remove("consumes")
    mutations["reverse_produces"] = lambda c, m: next(row for row in next(s for s in m["snapshots"] if s["id"] == "calls")["relations"] if row["kind"] == "produces").update({"from_id": "staged:result:function:normalize:2", "to_id": "staged:parse_job:function:normalize:1"})
    mutations["collapse_staged_roles"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "calls")["records"].pop(17)
    mutations["stage_job_as_generated"] = apply_to(model_record("calls", "staged:parse_job:function:normalize:1"), lambda row: row.update({"kind": "generated_artifact"}))
    mutations["remove_stage_provenance"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "calls")["relations"].__setitem__(slice(None), [row for row in next(s for s in m["snapshots"] if s["id"] == "calls")["relations"] if not (row["kind"] == "lowered_from" and row["from_id"].startswith("staged:payload:"))])
    mutations["alter_record_id"] = apply_to(model_record("graph", "rule:Top"), lambda row: row.update({"id": "rule:Other"}))
    mutations["lowercase_id_escape"] = apply_to(model_record("privacy", "rule:T%C3%B6p"), lambda row: row.update({"id": "rule:T%c3%b6p"}))
    mutations["alter_relation_id"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "graph")["relations"][0].update({"id": "relation:bad"})
    mutations["reorder_records"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "graph")["records"].reverse()
    mutations["reorder_relations"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "graph")["relations"].reverse()
    mutations["remove_nullable_field"] = apply_to(model_record("graph", "rule:Top"), lambda row: row.pop("name"))
    mutations["extra_backend_field"] = apply_to(model_record("graph", "rule:Top"), lambda row: row.update({"perl_coderef": "CODE(0x1)"}))
    mutations["invalid_value_shape"] = apply_to(model_record("graph", "rule:Top"), lambda row: row["facts"]["value_shape"].update({"kind": "tuple"}))
    mutations["strengthen_unknown_shape"] = apply_to(model_record("graph", "rule:Child"), lambda row: row["facts"]["value_shape"]["element"].update({"kind": "string"}))
    mutations["invalid_target_shape"] = apply_to(model_record("graph", "regex:rule:Child:0"), lambda row: row["facts"]["target_shape"].update({"kind": "perl_regex"}))
    mutations["coordinated_family_and_hash_drift"] = mutate_and_refresh_hashes(model_record("privacy", "rule:T%C3%B6p"), lambda row: row["facts"].update({"family": "and"}))
    mutations["coordinated_cursor_and_hash_drift"] = mutate_and_refresh_hashes(model_record("calls", "rule:Top"), lambda row: row["facts"].update({"cursor_policy": "contiguous"}))
    mutations["coordinated_edge_ownership_and_hash_drift"] = mutate_and_refresh_hashes(model_record("graph", "rule:Child"), lambda row: row["facts"].update({"edge_ownership": "blind"}))
    mutations["illegal_generated_plan_family"] = apply_to(model_record("calls", "generated:handler_plan:0"), lambda row: row["facts"].update({"plan_family": "and_acode"}))
    mutations["coordinated_generated_plan_family_and_hash_drift"] = mutate_and_refresh_hashes(model_record("calls", "generated:handler_plan:0"), lambda row: row["facts"].update({"plan_family": "or_acode"}))
    mutations["wrong_calls_spec_identity"] = apply_to(model_record("calls", "spec:0"), lambda row: row.update({"name": "calls"}))
    mutations["coordinated_calls_spec_identity_and_hash_drift"] = mutate_and_refresh_hashes(model_record("calls", "spec:0"), lambda row: row.update({"name": "calls"}))
    mutations["remove_request_field"] = lambda c, m: c["query_contract"]["request_fields"].remove("budget")
    mutations["remove_response_field"] = lambda c, m: c["query_contract"]["response_fields"].remove("cost")
    mutations["remove_snapshot_field"] = lambda c, m: c["query_contract"]["snapshot_fields"].remove("has_execution")
    mutations["remove_page_field"] = lambda c, m: c["query_contract"]["page_response_fields"].remove("complete")
    mutations["remove_cost_field"] = lambda c, m: c["query_contract"]["cost_fields"].remove("depth_reached")
    mutations["remove_query_diagnostic_field"] = lambda c, m: c["query_contract"]["query_diagnostic_fields"].remove("fields")
    mutations["raise_page_max"] = lambda c, m: c["query_contract"].update({"page_max": 1001})
    mutations["raise_depth_max"] = lambda c, m: c["query_contract"]["budget_maxima"].update({"max_depth": 9})
    mutations["omit_budget_case"] = remove_query("budget_prefix")
    mutations["change_budget_prefix"] = lambda c, m: next(row for row in c["query_cases"] if row["id"] == "budget_prefix")["expected"]["record_ids"].reverse()
    mutations["omit_reverse_relation_case"] = remove_query("graph_reverse_dispatch")
    mutations["omit_explanation"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "graph")["records"].pop()
    mutations["change_explanation_order"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "graph")["records"].__setitem__(slice(-2, None), reversed(next(s for s in m["snapshots"] if s["id"] == "graph")["records"][-2:]))
    mutations["omit_source_policy"] = lambda c, m: c["query_contract"]["source_details"].remove("none")
    mutations["leak_host_path"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "privacy")["source_refs"]["rule"].update({"logical_name": "/" + "Users/example/private.spec"})
    mutations["omit_redaction"] = lambda c, m: c["schema"]["source_sensitive_fact_paths"].pop("regex_slot")
    mutations["wrong_utf8_span"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "privacy")["source_refs"]["regex"]["span"].update({"start_byte": 9})
    mutations["wrong_content_digest"] = lambda c, m: next(s for s in m["snapshots"] if s["id"] == "privacy")["source_refs"]["regex"].update({"content_digest": "sha256:" + "0" * 64})
    mutations["unadmit_perl"] = lambda c, m: c["target_admissions"][0].update({"status": "pending"})
    mutations["omit_perl_consumer_path"] = lambda c, m: c["target_admissions"][0]["consumer"].pop("path")
    mutations["alter_perl_consumer_path"] = lambda c, m: c["target_admissions"][0]["consumer"].update({"path": "t/missing_semantic_consumer.t"})
    mutations["omit_perl_consumer_role"] = lambda c, m: c["target_admissions"][0]["consumer"]["roles"].pop()
    mutations["reorder_perl_consumer_roles"] = lambda c, m: c["target_admissions"][0]["consumer"]["roles"].reverse()
    mutations["alter_perl_consumer_driver"] = lambda c, m: c["target_admissions"][0]["consumer"].update({"canonical_driver": "tools/missing_ci.sh"})
    mutations["unpromote_perl_rollout"] = lambda c, m: c["rollout"][1].update({"status": "pending"})
    mutations["omit_perl_canonical_registration"] = lambda c, m: c["canonical_ci"]["required_tracked_files"].remove("t/semantic_introspection_perl_admission.t")
    mutations["unadmit_rust"] = lambda c, m: c["target_admissions"][1].update({"status": "pending"})
    mutations["omit_rust_consumer_path"] = lambda c, m: c["target_admissions"][1]["consumer"].pop("path")
    mutations["alter_rust_consumer_path"] = lambda c, m: c["target_admissions"][1]["consumer"].update({"path": "rust/linkedspec-runtime/tests/missing_semantic_consumer.rs"})
    mutations["omit_rust_consumer_role"] = lambda c, m: c["target_admissions"][1]["consumer"]["roles"].pop()
    mutations["reorder_rust_consumer_roles"] = lambda c, m: c["target_admissions"][1]["consumer"]["roles"].reverse()
    mutations["alter_rust_consumer_driver"] = lambda c, m: c["target_admissions"][1]["consumer"].update({"canonical_driver": "tools/missing_ci.sh"})
    mutations["unpromote_rust_rollout"] = lambda c, m: c["rollout"][2].update({"status": "pending"})
    mutations["omit_rust_canonical_registration"] = lambda c, m: c["canonical_ci"]["required_tracked_files"].remove("rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs")
    mutations["admit_backend_early"] = lambda c, m: c["target_admissions"][2].update({"status": "complete"})
    mutations["omit_runtime"] = lambda c, m: c["target_admissions"].pop(0)
    mutations["omit_luajit"] = lambda c, m: c["target_admissions"].pop()
    mutations["omit_mcp_rollout"] = lambda c, m: c["rollout"].pop(7)
    mutations["move_semantics_into_mcp"] = lambda c, m: c["scope"].update({"mcp_role": "semantic_owner"})
    mutations["remove_fixture_group"] = lambda c, m: c["fixture_groups"].pop()
    mutations["alter_fixture_bytes"] = lambda c, m: c["source_fixtures"][0].update({"bytes": 127})
    mutations["alter_expected_hash"] = lambda c, m: c["query_cases"][0]["expected"].update({"response_sha256": "f" * 64})
    mutations["omit_canonical_registration"] = lambda c, m: c["canonical_ci"]["required_tracked_files"].pop(0)
    return mutations


def validate_mutations(contract: dict[str, Any], model: dict[str, Any]) -> int:
    functions = mutation_functions()
    require(list(functions) == contract["mutations"], "mutation implementation/order drifted")
    rejected = 0
    for mutation_id, mutate in functions.items():
        changed_contract, changed_model = copy.deepcopy(contract), copy.deepcopy(model)
        mutate(changed_contract, changed_model)
        try:
            validate_bundle(changed_contract, changed_model, check_filesystem=False)
        except (ContractError, KeyError, TypeError, ValueError):
            rejected += 1
        else:
            raise ContractError(f"mutation {mutation_id} was not rejected")
    return rejected


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--print-hashes", action="store_true", help="derive response hashes without checking stored hashes")
    args = parser.parse_args()
    contract = load_json(CONTRACT_PATH)
    model = load_json(MODEL_PATH)
    if args.print_hashes:
        # Bootstrap mode still validates schema/model, but emits the evaluator's canonical answers before digests are frozen.
        validate_contract_without_frozen_hashes = copy.deepcopy(contract)
        for case in validate_contract_without_frozen_hashes["query_cases"]:
            case["expected"]["response_sha256"] = "1" * 64
        validate_contract(validate_contract_without_frozen_hashes)
        validate_model(validate_contract_without_frozen_hashes, model)
        snapshots = {row["id"]: row for row in model["snapshots"]}
        for case in contract["query_cases"]:
            response = evaluate_query(contract, snapshots[case["snapshot"]], case["request"])
            print(f"{case['id']} {canonical_digest(response)}")
        return 0
    hashes = validate_bundle(contract, model, check_filesystem=True)
    rejected = validate_mutations(contract, model)
    rollout_complete = sum(row["status"] == "complete" for row in contract["rollout"])
    admission_complete = sum(row["status"] == "complete" for row in contract["target_admissions"])
    print(
        f"semantic introspection contract: {len(contract['fixture_groups'])} fixture groups, "
        f"{len(hashes)} exact queries, {rejected} rejected mutations, "
        f"rollout {rollout_complete} complete / {len(contract['rollout']) - rollout_complete} pending, "
        f"admission {admission_complete} complete / {len(contract['target_admissions']) - admission_complete} pending"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

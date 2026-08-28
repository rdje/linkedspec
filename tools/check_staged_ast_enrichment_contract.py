#!/usr/bin/env python3
"""Independently validate the backend-neutral staged-AST enrichment v1 contract."""

from __future__ import annotations

import copy
import hashlib
import json
import math
import re
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "staged_ast_enrichment_contract.json"
CI_PATH = ROOT / "tools" / "run_ci_local.sh"

PARSER_ID_PATTERN = re.compile(r"^[a-z][a-z0-9]*(?:[._:/-][a-z0-9]+)*$")
TOP_RULE_PATTERN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
SHA256_PATTERN = re.compile(r"^sha256:[0-9a-f]{64}$")
JOB_ID_PATTERN = re.compile(r"^parse_job:v2:sha256:[0-9a-f]{64}$")
SOURCE_DETAIL_ORDER = ["none", "identity", "span", "text"]

AUTHORED_SURFACE = {
    "example": (
        'job_marker = parse_job(text_expr, hash("node_kind", "expression", '
        '"payload_kind", "embedded_expression", "spec", "expr-v1", '
        '"top", "Expr", "result_policy", "sibling_field", '
        '"into", "expression_ast", "on_error", "fail"))'
    ),
    "callee": "parse_job",
    "node_kind": "STAGED_PARSE_JOB_MARKER",
    "sidecar_kind": "staged_parse_job_v2",
    "effect": "staged_parse_job_declaration",
    "evaluation": (
        "construct one inert marker plus scheduler-owned sidecar during stage-N authored execution; "
        "select pre-resolved and precompiled authority, execute, and stitch only after the complete stage-N AST returns"
    ),
    "required_options": [
        "node_kind",
        "payload_kind",
        "spec",
        "result_policy",
        "on_error",
    ],
    "optional_options": ["top", "into", "required_capabilities"],
    "availability": (
        "private Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT staged-AST carriers admitted; recurring and "
        "public authoring remain pending under FUTURE-PARITY-BACKLOG.14.7.8-.10"
    ),
}

POLICY = {
    "authority": (
        "the caller freezes aliases, declaring-spec-relative candidates, ordered search-root candidates, "
        "ordered provider candidates, resolves every statically declared selector, and freezes immutable "
        "already-compiled registry entries before authored execution"
    ),
    "resolution": (
        "all alias, declaring-spec-relative, search-root, and provider discovery completes before authored execution; "
        "the post-AST resolve phase is a pure frozen-map selection in that priority order, with missing, "
        "same-priority ambiguity, and alias-relative collision as hard diagnostics"
    ),
    "loading": (
        "authored parser identity, text, provenance, marker, and sidecar grant no filesystem, path, URI, "
        "network, environment, import enumeration, provider query, compilation, or registry mutation authority"
    ),
    "provenance": (
        "direct text carries one same-source half-open Unicode-scalar span; derived text carries a nonempty "
        "ordered list of direct spans under concatenate_in_order and never claims one synthetic contiguous span"
    ),
    "job_id": (
        "parse_job:v2:sha256 over canonical UTF-8 JSON containing contract version, declaring spec identity, "
        "parent AST path, node kind, payload kind, parser identity, selected top rule, and typed provenance"
    ),
    "queue": (
        "validate and resolve the complete stage before executing any job; process breadth-first by stage depth, "
        "then typed parent AST path (field names by Unicode scalar value and nonnegative indices numerically), "
        "typed provenance order under the same component ordering, and job id; stitch each settled result in that "
        "order and collect newly stitched markers only for the next depth"
    ),
    "cache": (
        "cache identity includes normalized parser identity, content digest, import graph fingerprint, selected "
        "top rule, spec language version, helper/action contract version, staged contract version, and sorted "
        "effective backend capabilities"
    ),
    "state": (
        "each job receives a fresh parser runtime context and immutable stage-chain view; siblings share only "
        "the caller cancellation, absolute deadline, remaining work budget, total-call counter, and registry snapshot"
    ),
    "capabilities": (
        "effective capabilities and policy modes are intersections and every source-detail or numeric resource "
        "ceiling is the stricter minimum; no child may elevate caller authority"
    ),
    "cycles": (
        "an exact active-chain parser/top/payload-digest/provenance tuple is a cycle; repeated parser/top over "
        "the same provenance lineage must be strictly contained with smaller total scalar extent"
    ),
    "bounds": (
        "stage depth, total calls, shared steps, result nodes, diagnostic bytes, cancellation, and deadline are "
        "checked at dispatch entry and child safe points without reset or extension"
    ),
    "result": (
        "replace_marker, replace_field, sibling_field, and append_child stitch into a detached AST copy; "
        "non-marker policies materialize the original exact text where the marker stood"
    ),
    "failure": (
        "fail aborts the composed parse; keep_text materializes original text and records a scheduler-sidecar "
        "diagnostic; diagnostic_node applies the selected target policy with one detached portable diagnostic node"
    ),
    "detachment": (
        "results and diagnostics are finite acyclic node-bounded plain data with no parser, registry, source "
        "authority, frame, transaction, cancellation, callback, host, path, or live handle"
    ),
    "transactions": (
        "parse-job declaration and staged dispatch are forbidden in uncommitted recognition; staged execution "
        "never supplies cursor progress to the completed parent parse"
    ),
    "compatibility": (
        "the existing function-body v1 sidecar remains actionir-body.spec/action_block/replace_field/body_ast/fail "
        "with legacy copied-text spans; it is accepted by an explicit adapter and cannot be emitted by parse_job v2"
    ),
}

RESULT_POLICIES = ["replace_marker", "replace_field", "sibling_field", "append_child"]
FAILURE_POLICIES = ["fail", "keep_text", "diagnostic_node"]
CARRIER_KINDS = ["native", "normalized_reconstructed", "generated_plan", "independently_loaded_emitted"]

BACKEND_CONSUMERS = [
    {
        "backend": "perl",
        "owner": "FUTURE-PARITY-BACKLOG.14.7.3.0",
        "path": "t/staged_ast_enrichment_perl_contract.t",
        "status": "complete",
    },
    {
        "backend": "rust",
        "owner": "FUTURE-PARITY-BACKLOG.14.7.4.0",
        "path": "rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs",
        "status": "complete",
    },
    {
        "backend": "dart",
        "owner": "FUTURE-PARITY-BACKLOG.14.7.5.0",
        "path": "dart/test/staged_ast_enrichment_contract_test.dart",
        "dormant_path": "dart/test_dormant/staged_ast_enrichment_contract_test.dart",
        "status": "complete",
    },
    {
        "backend": "julia",
        "owner": "FUTURE-PARITY-BACKLOG.14.7.6.0",
        "path": "julia/test/staged_ast_enrichment_contract_test.jl",
        "status": "complete",
    },
    {
        "backend": "lua",
        "owner": "FUTURE-PARITY-BACKLOG.14.7.7.0",
        "path": "lua/test/staged_ast_enrichment_contract_test.lua",
        "status": "complete",
    },
]

RUNTIME_ROUTES = [
    {
        "order": 1,
        "runtime": "perl",
        "consumer_backend": "perl",
        "command": "PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t",
    },
    {
        "order": 2,
        "runtime": "rust",
        "consumer_backend": "rust",
        "command": (
            "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime "
            "--test staged_ast_enrichment_contract"
        ),
    },
    {
        "order": 3,
        "runtime": "dart",
        "consumer_backend": "dart",
        "command": (
            "(cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only "
            "test/staged_ast_enrichment_contract_test.dart)"
        ),
    },
    {
        "order": 4,
        "runtime": "julia",
        "consumer_backend": "julia",
        "command": (
            "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no "
            "julia/test/staged_ast_enrichment_contract_test.jl"
        ),
    },
    {
        "order": 5,
        "runtime": "puc_lua",
        "consumer_backend": "lua",
        "command": "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua",
    },
    {
        "order": 6,
        "runtime": "luajit",
        "consumer_backend": "lua",
        "command": "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua",
    },
]

OUTWARD_PATHS = [
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
]

DIAGNOSTIC_CONTEXTS = {
    "staged_parse_job_options_required": ["code", "phase", "origin", "operand"],
    "staged_parse_job_option_unknown": ["code", "phase", "origin", "option"],
    "staged_parser_identity_invalid": ["code", "phase", "origin", "parser_spec_id"],
    "staged_top_rule_invalid": ["code", "phase", "origin", "top_rule"],
    "staged_result_policy_invalid": ["code", "phase", "origin", "result_policy"],
    "staged_failure_policy_invalid": ["code", "phase", "origin", "failure_policy"],
    "staged_result_target_invalid": ["code", "phase", "origin", "result_policy", "into"],
    "staged_source_provenance_invalid": ["code", "phase", "origin", "source_id", "provenance"],
    "staged_job_id_mismatch": ["code", "phase", "job_id", "expected_job_id"],
    "staged_duplicate_job_id": ["code", "phase", "job_id", "parent_ast_path"],
    "staged_registry_missing": ["code", "phase", "job_id", "parser_spec_id", "declaring_spec_id"],
    "staged_registry_ambiguous": ["code", "phase", "job_id", "parser_spec_id", "priority", "candidates"],
    "staged_registry_collision": ["code", "phase", "job_id", "parser_spec_id", "aliases", "relative_candidates"],
    "staged_implicit_load_forbidden": ["code", "phase", "job_id", "parser_spec_id", "operation"],
    "staged_registry_mutation_forbidden": ["code", "phase", "job_id", "parser_spec_id", "operation"],
    "staged_top_rule_forbidden": ["code", "phase", "job_id", "resolved_spec_id", "top_rule"],
    "staged_capability_denied": ["code", "phase", "job_id", "resolved_spec_id", "capability"],
    "staged_policy_denied": ["code", "phase", "job_id", "resolved_spec_id", "policy"],
    "staged_source_detail_denied": ["code", "phase", "job_id", "resolved_spec_id", "required", "effective"],
    "staged_version_mismatch": ["code", "phase", "job_id", "resolved_spec_id", "version_kind", "required", "actual"],
    "staged_cache_identity_invalid": ["code", "phase", "job_id", "resolved_spec_id", "cache_component"],
    "staged_cancelled": ["code", "phase", "stage_chain", "job_id", "resolved_spec_id"],
    "staged_deadline_exceeded": ["code", "phase", "stage_chain", "job_id", "deadline"],
    "staged_budget_exhausted": ["code", "phase", "stage_chain", "job_id", "remaining"],
    "staged_cycle": ["code", "phase", "stage_chain", "job_id", "active_tuple"],
    "staged_chain_non_decreasing": ["code", "phase", "stage_chain", "job_id", "provenance", "active_provenance"],
    "staged_depth_exceeded": ["code", "phase", "stage_chain", "job_id", "depth", "maximum"],
    "staged_call_limit_exceeded": ["code", "phase", "stage_chain", "job_id", "calls", "maximum"],
    "staged_child_failed": ["code", "phase", "stage_chain", "job_id", "parent_ast_path", "node_kind", "payload_kind", "parser_spec_id", "resolved_spec_id", "top_rule", "cache_key", "source_provenance", "result_policy", "failure_policy", "child_diagnostic"],
    "staged_stitch_target_missing": ["code", "phase", "stage_chain", "job_id", "parent_ast_path", "into"],
    "staged_stitch_target_collision": ["code", "phase", "stage_chain", "job_id", "parent_ast_path", "into"],
    "staged_append_target_invalid": ["code", "phase", "stage_chain", "job_id", "parent_ast_path", "into"],
    "staged_marker_mismatch": ["code", "phase", "stage_chain", "job_id", "parent_ast_path", "actual_marker"],
    "staged_result_not_detached": ["code", "phase", "stage_chain", "job_id", "field"],
    "staged_result_node_limit_exceeded": ["code", "phase", "stage_chain", "job_id", "nodes", "maximum"],
    "staged_transaction_forbidden": ["code", "phase", "origin", "effect"],
    "staged_diagnostic_truncated": ["code", "phase", "stage_chain", "job_id", "maximum_bytes"],
}

OWNERSHIP = [
    {"owner": "FUTURE-PARITY-BACKLOG.14.7.2", "responsibility": "neutral_contract"},
    {"owner": "FUTURE-PARITY-BACKLOG.14.7.3", "responsibility": "perl_parent"},
    {"owner": "FUTURE-PARITY-BACKLOG.14.7.4", "responsibility": "rust_parent"},
    {"owner": "FUTURE-PARITY-BACKLOG.14.7.5", "responsibility": "dart_parent"},
    {"owner": "FUTURE-PARITY-BACKLOG.14.7.6", "responsibility": "julia_parent"},
    {"owner": "FUTURE-PARITY-BACKLOG.14.7.7", "responsibility": "lua_parent"},
]
for backend, parent, last in [
    ("perl", "3", 4),
    ("rust", "4", 4),
    ("dart", "5", 4),
    ("julia", "6", 4),
    ("lua", "7", 5),
]:
    responsibilities = [
        "dormant_red",
        "annotation_and_provenance",
        "resolution_cache_and_policies",
        "recursive_queue_bounds_diagnostics",
        "carriers_and_admission",
        "dual_abi_recomposition",
    ]
    for child in range(last + 1):
        OWNERSHIP.append(
            {
                "owner": f"FUTURE-PARITY-BACKLOG.14.7.{parent}.{child}",
                "responsibility": f"{backend}_{responsibilities[child]}",
            }
        )
OWNERSHIP.extend(
    [
        {"owner": "FUTURE-PARITY-BACKLOG.14.7.8", "responsibility": "six_runtime_recurrence"},
        {"owner": "FUTURE-PARITY-BACKLOG.14.7.9", "responsibility": "public_authoring_and_no_drift"},
        {"owner": "FUTURE-PARITY-BACKLOG.14.7.10", "responsibility": "independent_recomposition"},
    ]
)


class ContractError(RuntimeError):
    """A neutral contract invariant failed."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def exact_keys(value: Any, keys: list[str], context: str) -> None:
    require(isinstance(value, dict), f"{context} must be an object")
    actual = set(value)
    expected = set(keys)
    require(actual == expected, f"{context} keys differ: missing={sorted(expected - actual)} extra={sorted(actual - expected)}")


def canonical_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def digest(value: Any) -> str:
    return "sha256:" + hashlib.sha256(canonical_json(value).encode("utf-8")).hexdigest()


def safe_relative_path(value: Any) -> bool:
    if not isinstance(value, str) or not value or value.startswith("/") or "\\" in value:
        return False
    parts = Path(value).parts
    return all(part not in {"", ".", ".."} for part in parts)


def read_json(path: Path) -> dict[str, Any]:
    require(path.is_file() and not path.is_symlink(), f"contract artifact is missing or symbolic: {path.relative_to(ROOT)}")
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ContractError(f"contract artifact is not canonical JSON: {exc}") from exc
    require(isinstance(value, dict), "contract root must be an object")
    return value


def materialize_provenance(case: dict[str, Any], sources: dict[str, str]) -> tuple[bool, str | None, str | None]:
    provenance = case.get("provenance")
    if not isinstance(provenance, dict):
        return False, None, "staged_source_provenance_invalid"
    kind = provenance.get("kind")
    segments = [provenance] if kind == "direct_span" else provenance.get("segments")
    if kind == "derived_text" and provenance.get("policy") != "concatenate_in_order":
        return False, None, "staged_source_provenance_invalid"
    if kind not in {"direct_span", "derived_text"} or not isinstance(segments, list) or not segments:
        return False, None, "staged_source_provenance_invalid"
    pieces: list[str] = []
    for segment in segments:
        if not isinstance(segment, dict):
            return False, None, "staged_source_provenance_invalid"
        if set(segment) != {"kind", "source_id", "start", "end", "provenance"}:
            return False, None, "staged_source_provenance_invalid"
        if segment.get("kind") != "direct_span" or not isinstance(segment.get("source_id"), str):
            return False, None, "staged_source_provenance_invalid"
        start = segment.get("start")
        end = segment.get("end")
        source = sources.get(segment["source_id"])
        if (
            source is None
            or isinstance(start, bool)
            or isinstance(end, bool)
            or not isinstance(start, int)
            or not isinstance(end, int)
            or start < 0
            or end < start
            or end > len(source)
            or not isinstance(segment.get("provenance"), str)
            or not segment["provenance"]
        ):
            return False, None, "staged_source_provenance_invalid"
        pieces.append(source[start:end])
    return True, "".join(pieces), None


def compute_job_id(case: dict[str, Any]) -> str:
    identity = {
        "contract_version": 2,
        "declaring_spec_id": case["declaring_spec_id"],
        "parent_ast_path": case["parent_ast_path"],
        "node_kind": case["node_kind"],
        "payload_kind": case["payload_kind"],
        "parser_spec_id": case["parser_spec_id"],
        "top_rule": case["top_rule"],
        "provenance": case["provenance"],
    }
    return "parse_job:v2:" + digest(identity)


def resolve_identity(snapshot: dict[str, Any], case: dict[str, Any]) -> tuple[str | None, str | None]:
    declaring = case["declaring_spec_id"]
    authored = case["parser_spec_id"]
    if not PARSER_ID_PATTERN.fullmatch(authored) or ".." in authored or authored.startswith("/"):
        return None, "staged_parser_identity_invalid"
    aliases = [row["resolved_spec_id"] for row in snapshot["aliases"] if row["declaring_spec_id"] == declaring and row["authored_id"] == authored]
    relative = [row["resolved_spec_id"] for row in snapshot["declaring_relative"] if row["declaring_spec_id"] == declaring and row["authored_id"] == authored]
    if aliases and relative:
        return None, "staged_registry_collision"
    if len(aliases) > 1 or len(relative) > 1:
        return None, "staged_registry_ambiguous"
    if aliases:
        return aliases[0], None
    if relative:
        return relative[0], None
    for root in sorted(snapshot["search_roots"], key=lambda row: row["order"]):
        candidates = [row["resolved_spec_id"] for row in root["candidates"] if row["authored_id"] == authored]
        if len(candidates) > 1:
            return None, "staged_registry_ambiguous"
        if candidates:
            return candidates[0], None
    for provider in sorted(snapshot["providers"], key=lambda row: row["order"]):
        candidates = [row["resolved_spec_id"] for row in provider["candidates"] if row["authored_id"] == authored]
        if len(candidates) > 1:
            return None, "staged_registry_ambiguous"
        if candidates:
            return candidates[0], None
    return None, "staged_registry_missing"


def cache_key(fields: dict[str, Any]) -> str:
    normalized = copy.deepcopy(fields)
    normalized["backend_capabilities"] = sorted(set(normalized["backend_capabilities"]))
    return digest(normalized)


def typed_sequence_key(value: Any, context: str) -> tuple[tuple[int, str | int], ...]:
    require(isinstance(value, list) and value, f"{context} must be a nonempty typed sequence")
    components: list[tuple[int, str | int]] = []
    for component in value:
        if isinstance(component, str) and component:
            components.append((0, component))
        elif isinstance(component, int) and not isinstance(component, bool) and component >= 0:
            components.append((1, component))
        else:
            raise ContractError(f"{context} component is invalid")
    return tuple(components)


def queue_key(job: dict[str, Any]) -> tuple[int, tuple[tuple[int, str | int], ...], tuple[tuple[int, str | int], ...], str]:
    depth = job["stage_depth"]
    require(isinstance(depth, int) and not isinstance(depth, bool) and depth >= 0, "stage depth is invalid")
    require(isinstance(job["job_id"], str) and job["job_id"], "queue job id is invalid")
    return (
        depth,
        typed_sequence_key(job["parent_ast_path"], "parent AST path"),
        typed_sequence_key(job["provenance_order"], "provenance order"),
        job["job_id"],
    )


def marker(job_id: str, text: str) -> dict[str, Any]:
    return {"kind": "staged_parse_job_marker", "version": 2, "job_id": job_id, "text": text}


def stitch_success(case: dict[str, Any]) -> dict[str, Any]:
    parent = copy.deepcopy(case["parent"])
    policy = case["result_policy"]
    marker_field = case["marker_field"]
    into = case["into"]
    result = copy.deepcopy(case["result"])
    expected_marker = marker(case["job_id"], case["text"])
    require(parent.get(marker_field) == expected_marker, "staged marker mismatch")
    if policy == "replace_marker":
        require(into is None, "replace_marker target invalid")
        parent[marker_field] = result
    else:
        parent[marker_field] = case["text"]
        require(isinstance(into, str) and into, "staged result target invalid")
        if policy == "replace_field":
            require(into in parent, "staged stitch target missing")
            parent[into] = result
        elif policy == "sibling_field":
            require(into not in parent, "staged stitch target collision")
            parent[into] = result
        elif policy == "append_child":
            require(isinstance(parent.get(into), list), "staged append target invalid")
            parent[into].append(result)
        else:
            raise ContractError("staged result policy invalid")
    return parent


def provenance_extent(provenance: dict[str, Any]) -> tuple[set[str], list[tuple[str, int, int]], int]:
    segments = [provenance] if provenance.get("kind") == "direct_span" else provenance.get("segments", [])
    triples = [(row["source_id"], row["start"], row["end"]) for row in segments]
    return {row[0] for row in triples}, triples, sum(end - start for _, start, end in triples)


def strictly_decreases(parent: dict[str, Any], child: dict[str, Any]) -> bool:
    parent_sources, parent_segments, parent_extent = provenance_extent(parent)
    child_sources, child_segments, child_extent = provenance_extent(child)
    if not child_sources.issubset(parent_sources) or child_extent >= parent_extent:
        return False
    for source_id, start, end in child_segments:
        if not any(ps == source_id and pstart <= start and end <= pend for ps, pstart, pend in parent_segments):
            return False
    return True


def detached_result(value: Any, maximum: int) -> tuple[bool, str | None, int]:
    forbidden_keys = {"parser", "parser_handle", "registry", "source_authority", "frame", "transaction", "cancellation", "callback", "host", "path", "live_handle"}
    nodes = 0

    def walk(item: Any) -> bool:
        nonlocal nodes
        nodes += 1
        if nodes > maximum:
            return False
        if item is None or isinstance(item, (str, bool, int)):
            return True
        if isinstance(item, float):
            return math.isfinite(item)
        if isinstance(item, list):
            return all(walk(child) for child in item)
        if isinstance(item, dict):
            if any(key in forbidden_keys or key == "$ref" for key in item):
                return False
            return all(isinstance(key, str) and walk(child) for key, child in item.items())
        return False

    accepted = walk(value)
    if nodes > maximum:
        return False, "staged_result_node_limit_exceeded", nodes
    return accepted, None if accepted else "staged_result_not_detached", nodes


def evaluate_authority(case: dict[str, Any], entries: dict[str, dict[str, Any]]) -> tuple[bool, dict[str, Any] | None, str | None]:
    entry = entries.get(case["entry_id"])
    if entry is None:
        return False, None, "staged_registry_missing"
    required_versions = case["required_versions"]
    for key in ["spec_language_version", "helper_contract_version", "staged_contract_version"]:
        if entry[key] != required_versions[key]:
            return False, None, "staged_version_mismatch"
    if case["top_rule"] not in entry["allowed_top_rules"]:
        return False, None, "staged_top_rule_forbidden"
    capabilities = sorted(set(case["caller_capabilities"]) & set(entry["capabilities"]))
    if not set(case["required_capabilities"]).issubset(capabilities):
        return False, None, "staged_capability_denied"
    policy_modes = sorted(set(case["caller_policy_modes"]) & set(entry["policy_modes"]))
    if not set(case["required_policy_modes"]).issubset(policy_modes):
        return False, None, "staged_policy_denied"
    caller = case["caller_ceilings"]
    entry_ceilings = entry["ceilings"]
    source_detail = SOURCE_DETAIL_ORDER[min(
        SOURCE_DETAIL_ORDER.index(caller["source_detail"]),
        SOURCE_DETAIL_ORDER.index(entry_ceilings["source_detail"]),
    )]
    if SOURCE_DETAIL_ORDER.index(source_detail) < SOURCE_DETAIL_ORDER.index(case["required_source_detail"]):
        return False, None, "staged_source_detail_denied"
    effective = {
        "capabilities": capabilities,
        "policy_modes": policy_modes,
        "source_detail": source_detail,
        "max_steps": min(caller["max_steps"], entry_ceilings["max_steps"]),
        "max_result_nodes": min(caller["max_result_nodes"], entry_ceilings["max_result_nodes"]),
        "max_diagnostic_bytes": min(caller["max_diagnostic_bytes"], entry_ceilings["max_diagnostic_bytes"]),
    }
    return True, effective, None


def simulate_isolation(case: dict[str, Any]) -> dict[str, Any]:
    fresh = {"cursor": 0, "marks": {}, "variables": {}}
    child_initial_contexts = [copy.deepcopy(fresh) for _ in case["child_mutations"]]
    shared = case["shared_authority"]
    return {
        "parent_state": copy.deepcopy(case["parent_state"]),
        "child_initial_contexts": child_initial_contexts,
        "cancellation_tokens": [shared["cancellation_token"] for _ in case["child_mutations"]],
        "deadline_values": [shared["deadline"] for _ in case["child_mutations"]],
        "remaining_steps": shared["remaining_steps"] - sum(shared["child_costs"]),
        "registry_snapshot_id": shared["registry_snapshot_id"],
    }


def validate_registry(snapshot: dict[str, Any]) -> None:
    exact_keys(
        snapshot,
        [
            "immutable",
            "prepared_before_authored_execution",
            "filesystem_access_during_dispatch",
            "aliases",
            "declaring_relative",
            "search_roots",
            "providers",
            "entries",
        ],
        "resolution_snapshot",
    )
    require(snapshot["immutable"] is True, "registry snapshot must be immutable")
    require(snapshot["prepared_before_authored_execution"] is True, "registry snapshot must be prepared before authored execution")
    require(snapshot["filesystem_access_during_dispatch"] is False, "dispatch must not access the filesystem")
    orders = [row["order"] for row in snapshot["search_roots"]]
    require(orders == list(range(1, len(orders) + 1)), "search-root order must be contiguous")
    orders = [row["order"] for row in snapshot["providers"]]
    require(orders == list(range(1, len(orders) + 1)), "provider order must be contiguous")
    identities: set[str] = set()
    for entry in snapshot["entries"]:
        exact_keys(
            entry,
            [
                "resolved_spec_id",
                "compiled_authority",
                "content_digest",
                "import_graph_fingerprint",
                "default_top_rule",
                "allowed_top_rules",
                "spec_language_version",
                "helper_contract_version",
                "staged_contract_version",
                "capabilities",
                "policy_modes",
                "ceilings",
            ],
            "registry entry",
        )
        identity = entry["resolved_spec_id"]
        require(PARSER_ID_PATTERN.fullmatch(identity) is not None, "registry identity is invalid")
        require(identity not in identities, "registry identity is duplicated")
        identities.add(identity)
        require(entry["compiled_authority"].startswith("opaque:compiled:"), "compiled authority must be opaque and prebuilt")
        require(SHA256_PATTERN.fullmatch(entry["content_digest"]) is not None, "content digest is invalid")
        require(SHA256_PATTERN.fullmatch(entry["import_graph_fingerprint"]) is not None, "import graph fingerprint is invalid")
        require(entry["default_top_rule"] in entry["allowed_top_rules"], "default top rule must be allowed")
        require(all(TOP_RULE_PATTERN.fullmatch(top) for top in entry["allowed_top_rules"]), "allowed top rule is invalid")
        require(entry["staged_contract_version"] == 2, "registry staged contract version mismatch")


def validate_semantic_cases(contract: dict[str, Any]) -> None:
    sources = {row["source_id"]: row["text"] for row in contract["sources"]}
    require(len(sources) == len(contract["sources"]), "source identities must be unique")
    for row in contract["sources"]:
        require(row["scalar_length"] == len(row["text"]), f"source scalar length mismatch: {row['source_id']}")

    for case in contract["provenance_cases"]:
        accepted, text, diagnostic = materialize_provenance(case, sources)
        require(accepted is case["accepted"], f"provenance acceptance mismatch: {case['id']}")
        require(text == case["materialized_text"], f"provenance text mismatch: {case['id']}")
        require(diagnostic == case["diagnostic"], f"provenance diagnostic mismatch: {case['id']}")

    for case in contract["job_id_cases"]:
        actual = compute_job_id(case)
        require(JOB_ID_PATTERN.fullmatch(case["expected_job_id"]) is not None, f"job id shape mismatch: {case['id']}")
        require(actual == case["expected_job_id"], f"job id mismatch: {case['id']}")

    snapshot = contract["resolution_snapshot"]
    validate_registry(snapshot)
    for case in contract["resolution_cases"]:
        resolved, diagnostic = resolve_identity(snapshot, case)
        require(resolved == case["resolved_spec_id"], f"resolution result mismatch: {case['id']}")
        require(diagnostic == case["diagnostic"], f"resolution diagnostic mismatch: {case['id']}")

    entries = {row["resolved_spec_id"]: row for row in snapshot["entries"]}
    for case in contract["authority_cases"]:
        accepted, effective, diagnostic = evaluate_authority(case, entries)
        require(accepted is case["accepted"], f"authority acceptance mismatch: {case['id']}")
        require(effective == case["effective"], f"authority result mismatch: {case['id']}")
        require(diagnostic == case["diagnostic"], f"authority diagnostic mismatch: {case['id']}")

    base_key: str | None = None
    for case in contract["cache_cases"]:
        actual = cache_key(case["fields"])
        require(SHA256_PATTERN.fullmatch(actual) is not None, f"cache key shape mismatch: {case['id']}")
        if case["id"] == "base":
            base_key = actual
        require(base_key is not None, "base cache case must be first")
        require((actual == base_key) is case["same_as_base"], f"cache relation mismatch: {case['id']}")

    for case in contract["queue_cases"]:
        actual = [row["job_id"] for row in sorted(case["jobs"], key=queue_key)]
        require(actual == case["expected_order"], f"queue order mismatch: {case['id']}")

    for case in contract["isolation_cases"]:
        actual = simulate_isolation(case)
        require(actual == case["expected"], f"isolation result mismatch: {case['id']}")

    for case in contract["stitch_cases"]:
        actual = stitch_success(case)
        require(actual == case["expected_parent"], f"stitch result mismatch: {case['id']}")

    for case in contract["failure_cases"]:
        policy = case["failure_policy"]
        if policy == "fail":
            actual = {"outcome": "aborted", "parent": None, "sidecar_diagnostics": [case["diagnostic"]]}
        elif policy == "keep_text":
            parent = copy.deepcopy(case["parent"])
            parent[case["marker_field"]] = case["text"]
            actual = {"outcome": "continued", "parent": parent, "sidecar_diagnostics": [case["diagnostic"]]}
        elif policy == "diagnostic_node":
            promoted = copy.deepcopy(case)
            promoted["result"] = {"kind": "staged_parse_diagnostic", "diagnostic": case["diagnostic"]}
            parent = stitch_success(promoted)
            actual = {"outcome": "continued", "parent": parent, "sidecar_diagnostics": [case["diagnostic"]]}
        else:
            raise ContractError(f"failure policy invalid: {case['id']}")
        require(actual == case["expected"], f"failure result mismatch: {case['id']}")

    for case in contract["chain_cases"]:
        accepted = True
        diagnostic = None
        if case["cancelled"]:
            accepted, diagnostic = False, "staged_cancelled"
        elif case["now"] > case["deadline"]:
            accepted, diagnostic = False, "staged_deadline_exceeded"
        elif case["remaining_steps"] < case["required_steps"]:
            accepted, diagnostic = False, "staged_budget_exhausted"
        elif case["depth"] > case["max_depth"]:
            accepted, diagnostic = False, "staged_depth_exceeded"
        elif case["calls"] > case["max_calls"]:
            accepted, diagnostic = False, "staged_call_limit_exceeded"
        elif case["active_tuple"] == case["candidate_tuple"]:
            accepted, diagnostic = False, "staged_cycle"
        elif case["same_parser_top_lineage"] and not strictly_decreases(case["active_provenance"], case["candidate_provenance"]):
            accepted, diagnostic = False, "staged_chain_non_decreasing"
        require(accepted is case["accepted"], f"chain acceptance mismatch: {case['id']}")
        require(diagnostic == case["diagnostic"], f"chain diagnostic mismatch: {case['id']}")

    for case in contract["detachment_cases"]:
        accepted, diagnostic, nodes = detached_result(case["value"], case["max_nodes"])
        require(accepted is case["accepted"], f"detachment acceptance mismatch: {case['id']}")
        require(diagnostic == case["diagnostic"], f"detachment diagnostic mismatch: {case['id']}")
        require(nodes == case["visited_nodes"], f"detachment node count mismatch: {case['id']}")


def validate_environment(contract: dict[str, Any]) -> None:
    ci_text = CI_PATH.read_text(encoding="utf-8")
    perl_ordinary_text = (ROOT / "t/phase0_regression.t").read_text(encoding="utf-8")
    julia_ordinary_text = (ROOT / "julia/test/runtests.jl").read_text(encoding="utf-8")
    lua_ordinary_text = (ROOT / "tools/run_lua_local.sh").read_text(encoding="utf-8")
    lua_inline_text = (ROOT / "lua/test/run.lua").read_text(encoding="utf-8")
    for row in contract["backend_consumers"]:
        require(safe_relative_path(row["path"]), "backend consumer path is unsafe")
        consumer_path = ROOT / row["path"]
        if row["status"] == "pending_absent":
            require(not consumer_path.exists(), f"pending backend consumer unexpectedly exists: {row['path']}")
        elif row["status"] == "dormant_red":
            if row["backend"] == "dart":
                dormant_path_value = row.get("dormant_path")
                require(safe_relative_path(dormant_path_value), "dormant backend consumer path is unsafe")
                dormant_path = ROOT / dormant_path_value
                require(not consumer_path.exists(), f"dormant backend final consumer unexpectedly exists: {row['path']}")
                require(
                    dormant_path.is_file() and not dormant_path.is_symlink(),
                    f"dormant backend consumer is missing or symbolic: {dormant_path_value}",
                )
                require(ci_text.count(row["path"]) == 0, "dormant Dart final consumer entered canonical CI")
                require(ci_text.count(dormant_path_value) == 0, "dormant Dart consumer entered canonical CI")
            elif row["backend"] == "julia":
                require(
                    consumer_path.is_file() and not consumer_path.is_symlink(),
                    f"dormant Julia consumer is missing or symbolic: {row['path']}",
                )
                require(
                    julia_ordinary_text.count(consumer_path.name) == 0,
                    "dormant Julia consumer entered ordinary discovery",
                )
                require(ci_text.count(row["path"]) == 0, "dormant Julia consumer entered canonical CI")
            elif row["backend"] == "lua":
                require(
                    consumer_path.is_file() and not consumer_path.is_symlink(),
                    f"dormant Lua consumer is missing or symbolic: {row['path']}",
                )
                require(
                    lua_ordinary_text.count(row["path"]) == 0,
                    "dormant Lua consumer entered ordinary dual-ABI discovery",
                )
                require(
                    lua_inline_text.count(consumer_path.name) == 0,
                    "dormant Lua consumer entered the inline ordinary suite",
                )
                require(ci_text.count(row["path"]) == 0, "dormant Lua consumer entered canonical CI")
            else:
                raise ContractError(f"unsupported dormant staged backend: {row['backend']}")
        elif row["status"] == "complete":
            require(
                consumer_path.is_file() and not consumer_path.is_symlink(),
                f"complete backend consumer is missing or symbolic: {row['path']}",
            )
            if row["backend"] == "perl":
                admission = contract["canonical_execution"]["perl_admission"]
                require(admission["consumer_path"] == row["path"], "Perl admission consumer path drifted")
                require(perl_ordinary_text.count(row["path"]) == 1, "ordinary Perl discovery must register the staged consumer exactly once")
                require(ci_text.count(f"require_tracked_file {row['path']}") == 1, "canonical CI must require the Perl staged consumer exactly once")
                require(ci_text.count(admission["syntax_invocation"]) == 1, "canonical CI must syntax-check the Perl staged consumer exactly once")
                require(ci_text.count(f'log "{admission["registration_marker"]}"') == 1, "canonical Perl staged admission marker is missing or duplicated")
                require(ci_text.count(admission["invocation"]) == 1, "canonical Perl staged admission invocation is missing or duplicated")
            elif row["backend"] == "rust":
                admission = contract["canonical_execution"]["rust_admission"]
                require(admission["consumer_path"] == row["path"], "Rust admission consumer path drifted")
                require(admission["ordinary_invocation"] == RUNTIME_ROUTES[1]["command"], "ordinary Rust staged invocation drifted")
                require(ci_text.count(f"require_tracked_file {row['path']}") == 1, "canonical CI must require the Rust staged consumer exactly once")
                require(ci_text.count(f'log "{admission["registration_marker"]}"') == 1, "canonical Rust staged admission marker is missing or duplicated")
                require(ci_text.count(admission["invocation"]) == 1, "canonical Rust staged admission invocation is missing or duplicated")
            elif row["backend"] == "dart":
                admission = contract["canonical_execution"]["dart_admission"]
                dormant_path = ROOT / row["dormant_path"]
                require(not dormant_path.exists(), "admitted Dart staged consumer retains a dormant duplicate")
                require(admission["consumer_path"] == row["path"], "Dart admission consumer path drifted")
                require(admission["ordinary_invocation"] == RUNTIME_ROUTES[2]["command"], "ordinary Dart staged invocation drifted")
                require(ci_text.count(f"require_tracked_file {row['path']}") == 1, "canonical CI must require the Dart staged consumer exactly once")
                require(ci_text.count(f'log "{admission["registration_marker"]}"') == 1, "canonical Dart staged admission marker is missing or duplicated")
                require(ci_text.count(admission["invocation"]) == 1, "canonical Dart staged admission invocation is missing or duplicated")
            elif row["backend"] == "julia":
                admission = contract["canonical_execution"]["julia_admission"]
                require(admission["consumer_path"] == row["path"], "Julia admission consumer path drifted")
                require(admission["ordinary_invocation"] == RUNTIME_ROUTES[3]["command"], "ordinary Julia staged invocation drifted")
                require(julia_ordinary_text.count(consumer_path.name) == 1, "ordinary Julia discovery must register the staged consumer exactly once")
                require(ci_text.count(f"require_tracked_file {row['path']}") == 1, "canonical CI must require the Julia staged consumer exactly once")
                require(ci_text.count(f'log "{admission["registration_marker"]}"') == 1, "canonical Julia staged admission marker is missing or duplicated")
                require(ci_text.count(admission["invocation"]) == 1, "canonical Julia staged admission invocation is missing or duplicated")
            elif row["backend"] == "lua":
                admission = contract["canonical_execution"]["lua_admission"]
                require(admission["consumer_path"] == row["path"], "Lua admission consumer path drifted")
                require(admission["ordinary_driver"] == "tools/run_lua_local.sh", "ordinary Lua staged driver drifted")
                require(lua_ordinary_text.count(row["path"]) == 2, "ordinary Lua discovery must register the staged consumer exactly once per ABI")
                require(lua_ordinary_text.count(f'"$LUA_CMD" {row["path"]}') == 1, "ordinary Lua discovery must register the staged consumer once on PUC Lua")
                require(lua_ordinary_text.count(f'"$LUAJIT_CMD" {row["path"]}') == 1, "ordinary Lua discovery must register the staged consumer once on LuaJIT")
                require(lua_inline_text.count(consumer_path.name) == 0, "admitted Lua staged consumer must not duplicate through the inline suite")
                require(ci_text.count(f"require_tracked_file {row['path']}") == 1, "canonical CI must require the Lua staged consumer exactly once")
                for runtime in ("puc", "luajit"):
                    require(ci_text.count(f'log "{admission[f"{runtime}_registration_marker"]}"') == 1, f"canonical {runtime} Lua staged admission marker is missing or duplicated")
                    require(ci_text.count(admission[f"{runtime}_invocation"]) == 1, f"canonical {runtime} Lua staged admission invocation is missing or duplicated")
            else:
                raise ContractError(f"unsupported complete staged backend: {row['backend']}")
        else:
            raise ContractError(f"unsupported backend consumer status: {row['status']}")
    outward = contract["outward_guard"]
    for relative in outward["paths"]:
        require(safe_relative_path(relative), "outward guard path is unsafe")
        path = ROOT / relative
        require(path.is_file() and not path.is_symlink(), f"outward guard path is missing or symbolic: {relative}")
        text = path.read_text(encoding="utf-8")
        for token in outward["forbidden_tokens"]:
            require(token not in text, f"private staged-AST token leaked into outward path {relative}: {token}")
    canonical = contract["canonical_execution"]
    require(canonical["registration_marker"] in ci_text, "canonical registration marker is missing")
    require(canonical["invocation"] in ci_text, "canonical checker invocation is missing")
    require(f"require_tracked_file {canonical['checker_path']}" in ci_text, "canonical tracked-checker requirement is missing")


def validate_contract(contract: dict[str, Any], *, environment: bool = True) -> None:
    top_keys = [
        "format",
        "contract_id",
        "task_owner",
        "status",
        "expected_counts",
        "authored_surface",
        "policy",
        "result_policies",
        "failure_policies",
        "sources",
        "provenance_cases",
        "job_id_cases",
        "resolution_snapshot",
        "resolution_cases",
        "authority_cases",
        "cache_cases",
        "queue_cases",
        "isolation_cases",
        "stitch_cases",
        "failure_cases",
        "chain_cases",
        "detachment_cases",
        "compatibility_v1",
        "carrier_requirements",
        "backend_consumers",
        "runtime_routes",
        "outward_guard",
        "diagnostics",
        "rollout",
        "canonical_execution",
        "ownership",
        "mutation_ids",
    ]
    exact_keys(contract, top_keys, "contract")
    require(contract["format"] == 1, "format must be 1")
    require(contract["contract_id"] == "linkedspec-staged-ast-enrichment-v1", "contract id mismatch")
    require(contract["task_owner"] == "FUTURE-PARITY-BACKLOG.14.7.2", "task owner mismatch")
    require(
        contract["status"]
        == "all_private_backends_complete_recurring_and_public_pending",
        "contract status mismatch",
    )
    require(contract["authored_surface"] == AUTHORED_SURFACE, "authored surface mismatch")
    require(contract["policy"] == POLICY, "policy mismatch")
    require(contract["result_policies"] == RESULT_POLICIES, "result-policy inventory mismatch")
    require(contract["failure_policies"] == FAILURE_POLICIES, "failure-policy inventory mismatch")
    require(contract["backend_consumers"] == BACKEND_CONSUMERS, "backend consumer inventory mismatch")
    require(contract["runtime_routes"] == RUNTIME_ROUTES, "runtime route inventory mismatch")
    require(contract["ownership"] == OWNERSHIP, "ownership inventory mismatch")

    expected_counts = {
        "registry_entries": len(contract["resolution_snapshot"].get("entries", [])),
        "sources": len(contract["sources"]),
        "provenance_cases": len(contract["provenance_cases"]),
        "job_id_cases": len(contract["job_id_cases"]),
        "resolution_cases": len(contract["resolution_cases"]),
        "authority_cases": len(contract["authority_cases"]),
        "cache_cases": len(contract["cache_cases"]),
        "queue_cases": len(contract["queue_cases"]),
        "isolation_cases": len(contract["isolation_cases"]),
        "stitch_cases": len(contract["stitch_cases"]),
        "failure_cases": len(contract["failure_cases"]),
        "chain_cases": len(contract["chain_cases"]),
        "detachment_cases": len(contract["detachment_cases"]),
        "carrier_requirements": len(contract["carrier_requirements"]),
        "backend_consumers": len(contract["backend_consumers"]),
        "runtime_routes": len(contract["runtime_routes"]),
        "outward_guard_paths": len(contract["outward_guard"].get("paths", [])),
        "diagnostics": len(contract["diagnostics"]),
        "rollout_legs": len(contract["rollout"]),
        "ownership_rows": len(contract["ownership"]),
        "mutations": len(contract["mutation_ids"]),
    }
    require(contract["expected_counts"] == expected_counts, "expected counts mismatch")
    require(expected_counts["registry_entries"] == 4, "registry-entry count mismatch")
    require(expected_counts["sources"] == 2, "source count mismatch")
    require(expected_counts["provenance_cases"] == 8, "provenance-case count mismatch")
    require(expected_counts["job_id_cases"] == 3, "job-id case count mismatch")
    require(expected_counts["resolution_cases"] == 8, "resolution-case count mismatch")
    require(expected_counts["authority_cases"] == 6, "authority-case count mismatch")
    require(expected_counts["cache_cases"] == 10, "cache-case count mismatch")
    require(expected_counts["queue_cases"] == 4, "queue-case count mismatch")
    require(expected_counts["isolation_cases"] == 3, "isolation-case count mismatch")
    require(expected_counts["stitch_cases"] == 4, "stitch-case count mismatch")
    require(expected_counts["failure_cases"] == 3, "failure-case count mismatch")
    require(expected_counts["chain_cases"] == 10, "chain-case count mismatch")
    require(expected_counts["detachment_cases"] == 5, "detachment-case count mismatch")
    require(expected_counts["carrier_requirements"] == 4, "carrier-requirement count mismatch")
    require(expected_counts["backend_consumers"] == 5, "backend-consumer count mismatch")
    require(expected_counts["runtime_routes"] == 6, "runtime-route count mismatch")
    require(expected_counts["outward_guard_paths"] == 10, "outward-guard count mismatch")
    require(expected_counts["diagnostics"] == len(DIAGNOSTIC_CONTEXTS), "diagnostic count mismatch")
    require(expected_counts["rollout_legs"] == 9, "rollout count mismatch")
    require(expected_counts["ownership_rows"] == 35, "ownership count mismatch")

    validate_semantic_cases(contract)

    compatibility = contract["compatibility_v1"]
    require(compatibility["status"] == "current_unchanged", "function-body v1 compatibility status mismatch")
    require(compatibility["record_version"] == 1, "function-body v1 record version mismatch")
    require(compatibility["parser_spec_id"] == "actionir-body.spec", "function-body v1 parser mismatch")
    require(compatibility["resolved_spec_id"] == "builtin:actionir-body.spec", "function-body v1 resolution mismatch")
    require(compatibility["top_rule"] == "action_block", "function-body v1 top-rule mismatch")
    require(compatibility["result_policy"] == "replace_field" and compatibility["result_field"] == "body_ast", "function-body v1 stitch mismatch")
    require(compatibility["failure_policy"] == "fail", "function-body v1 failure mismatch")
    require(compatibility["general_authoring"] is False and compatibility["upgrade_to_v2"] == "explicit_only", "function-body v1 compatibility boundary mismatch")

    require(contract["carrier_requirements"] == [
        {
            "order": index,
            "carrier": carrier,
            "requirement": (
                "preserve the logical marker/sidecar, typed provenance, deterministic identity, and cache inputs; "
                "obtain a fresh caller-supplied registry/runtime authority per execution; serialize no callback, compiled parser, "
                "registry snapshot, source authority, cancellation token, deadline, budget, mutable queue, or host handle"
            ),
        }
        for index, carrier in enumerate(CARRIER_KINDS, 1)
    ], "carrier requirement inventory mismatch")

    diagnostic_rows = {row["code"]: row["required_context"] for row in contract["diagnostics"]}
    require(len(diagnostic_rows) == len(contract["diagnostics"]), "diagnostic codes must be unique")
    require(diagnostic_rows == DIAGNOSTIC_CONTEXTS, "diagnostic context inventory mismatch")

    outward = contract["outward_guard"]
    require(outward == {
        "paths": OUTWARD_PATHS,
        "forbidden_tokens": ["parse_job(text_expr", "STAGED_PARSE_JOB_MARKER", "linkedspec-staged-ast-enrichment-v1"],
        "status": "no_public_or_outward_admission",
        "owner": "FUTURE-PARITY-BACKLOG.14.7.9",
    }, "outward guard mismatch")

    expected_rollout = [
        {"order": 1, "leg": "neutral", "owner": "FUTURE-PARITY-BACKLOG.14.7.2", "status": "complete", "paths": ["capability_conformance/staged_ast_enrichment_contract.json", "tools/check_staged_ast_enrichment_contract.py"]},
        {"order": 2, "leg": "perl", "owner": "FUTURE-PARITY-BACKLOG.14.7.3", "status": "complete", "paths": [BACKEND_CONSUMERS[0]["path"]]},
        {"order": 3, "leg": "rust", "owner": "FUTURE-PARITY-BACKLOG.14.7.4", "status": "complete", "paths": [BACKEND_CONSUMERS[1]["path"]]},
        {"order": 4, "leg": "dart", "owner": "FUTURE-PARITY-BACKLOG.14.7.5", "status": "complete", "paths": [BACKEND_CONSUMERS[2]["path"]]},
        {"order": 5, "leg": "julia", "owner": "FUTURE-PARITY-BACKLOG.14.7.6", "status": "complete", "paths": [BACKEND_CONSUMERS[3]["path"]]},
        {"order": 6, "leg": "puc_lua", "owner": "FUTURE-PARITY-BACKLOG.14.7.7", "status": "complete", "paths": [BACKEND_CONSUMERS[4]["path"]]},
        {"order": 7, "leg": "luajit", "owner": "FUTURE-PARITY-BACKLOG.14.7.7", "status": "complete", "paths": [BACKEND_CONSUMERS[4]["path"]]},
        {"order": 8, "leg": "recurring", "owner": "FUTURE-PARITY-BACKLOG.14.7.8", "status": "pending", "paths": ["tools/check_staged_ast_enrichment_six_runtime.sh"]},
        {"order": 9, "leg": "public_no_drift", "owner": "FUTURE-PARITY-BACKLOG.14.7.9", "status": "pending", "paths": ["docs/linkedspec-book/src/dsl/staged-ast-enrichment.md", "docs/linkedspec-book/src/appendix/backend-handoff.md", "docs/linkedspec-book/src/overview/project-status.md", "capability_conformance/README.md", "TOOLBOX.md", "ROADMAP.md"]},
    ]
    require(contract["rollout"] == expected_rollout, "rollout inventory mismatch")

    canonical = contract["canonical_execution"]
    require(canonical == {
        "contract_path": "capability_conformance/staged_ast_enrichment_contract.json",
        "checker_path": "tools/check_staged_ast_enrichment_contract.py",
        "project_data_runner": "tools/run_python_project_data.sh",
        "canonical_driver": "tools/run_ci_local.sh",
        "registration_marker": "checking backend-neutral staged-AST enrichment contract",
        "invocation": "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py",
        "perl_admission": {
            "consumer_path": "t/staged_ast_enrichment_perl_contract.t",
            "ordinary_driver": "t/phase0_regression.t",
            "syntax_invocation": "perl -c -Iperl t/staged_ast_enrichment_perl_contract.t",
            "registration_marker": "running exact Perl staged-AST enrichment admission consumer",
            "invocation": "PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t",
        },
        "rust_admission": {
            "consumer_path": "rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs",
            "ordinary_invocation": "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract",
            "registration_marker": "running exact Rust staged-AST enrichment admission consumer",
            "invocation": "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract",
        },
        "dart_admission": {
            "consumer_path": "dart/test/staged_ast_enrichment_contract_test.dart",
            "ordinary_invocation": "(cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart)",
            "registration_marker": "running exact Dart staged-AST enrichment admission consumer",
            "invocation": "(cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart)",
        },
        "julia_admission": {
            "consumer_path": "julia/test/staged_ast_enrichment_contract_test.jl",
            "ordinary_invocation": "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl",
            "registration_marker": "running exact Julia staged-AST enrichment admission consumer",
            "invocation": "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl",
        },
        "lua_admission": {
            "consumer_path": "lua/test/staged_ast_enrichment_contract_test.lua",
            "ordinary_driver": "tools/run_lua_local.sh",
            "puc_registration_marker": "running exact Lua staged-AST enrichment admission consumer on PUC Lua",
            "puc_invocation": "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua",
            "luajit_registration_marker": "running exact Lua staged-AST enrichment admission consumer on LuaJIT",
            "luajit_invocation": "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua",
        },
        "storage_policy": "all Python cache, temporary, and process data stays under repository-derived project storage",
        "tracked_required": True,
    }, "canonical execution mismatch")

    if environment:
        validate_environment(contract)


Mutation = tuple[str, Callable[[dict[str, Any]], None], str]


def set_value(path: list[Any], value: Any) -> Callable[[dict[str, Any]], None]:
    def mutate(contract: dict[str, Any]) -> None:
        target: Any = contract
        for component in path[:-1]:
            target = target[component]
        target[path[-1]] = value
    return mutate


def mutation_inventory() -> list[Mutation]:
    mutations: list[Mutation] = [
        ("format", set_value(["format"], 2), "format must be 1"),
        ("contract_id", set_value(["contract_id"], "wrong"), "contract id mismatch"),
        ("task_owner", set_value(["task_owner"], "wrong"), "task owner mismatch"),
        ("status", set_value(["status"], "current"), "contract status mismatch"),
        ("topology_extra", set_value(["extra"], True), "contract keys differ"),
        ("counts", set_value(["expected_counts", "sources"], 99), "expected counts mismatch"),
        ("authored_example", set_value(["authored_surface", "example"], "parse_job()"), "authored surface mismatch"),
        ("authored_node", set_value(["authored_surface", "node_kind"], "CALL"), "authored surface mismatch"),
        ("authored_sidecar", set_value(["authored_surface", "sidecar_kind"], "host_callback"), "authored surface mismatch"),
        ("authored_effect", set_value(["authored_surface", "effect"], "pure_value"), "authored surface mismatch"),
        ("authored_timing", set_value(["authored_surface", "evaluation"], "execute immediately"), "authored surface mismatch"),
        ("authored_options", set_value(["authored_surface", "required_options"], []), "authored surface mismatch"),
        ("authored_availability", set_value(["authored_surface", "availability"], "stale"), "authored surface mismatch"),
        ("policy_authority", set_value(["policy", "authority"], "load during execution"), "policy mismatch"),
        ("policy_resolution", set_value(["policy", "resolution"], "host dependent"), "policy mismatch"),
        ("policy_loading", set_value(["policy", "loading"], "paths allowed"), "policy mismatch"),
        ("policy_provenance", set_value(["policy", "provenance"], "copied text"), "policy mismatch"),
        ("policy_job_id", set_value(["policy", "job_id"], "random"), "policy mismatch"),
        ("policy_queue", set_value(["policy", "queue"], "depth first"), "policy mismatch"),
        ("policy_cache", set_value(["policy", "cache"], "parser only"), "policy mismatch"),
        ("policy_state", set_value(["policy", "state"], "shared runtime"), "policy mismatch"),
        ("policy_capabilities", set_value(["policy", "capabilities"], "union"), "policy mismatch"),
        ("policy_cycles", set_value(["policy", "cycles"], "unbounded"), "policy mismatch"),
        ("policy_bounds", set_value(["policy", "bounds"], "backend defaults"), "policy mismatch"),
        ("policy_result", set_value(["policy", "result"], "host mutation"), "policy mismatch"),
        ("policy_failure", set_value(["policy", "failure"], "ignore"), "policy mismatch"),
        ("policy_detachment", set_value(["policy", "detachment"], "references allowed"), "policy mismatch"),
        ("policy_transactions", set_value(["policy", "transactions"], "rollbackable"), "policy mismatch"),
        ("policy_compatibility", set_value(["policy", "compatibility"], "upgrade silently"), "policy mismatch"),
        ("result_policy", set_value(["result_policies", 0], "replace"), "result-policy inventory mismatch"),
        ("failure_policy", set_value(["failure_policies", 0], "ignore"), "failure-policy inventory mismatch"),
        ("source_length", set_value(["sources", 0, "scalar_length"], 99), "source scalar length mismatch"),
        ("provenance_result", set_value(["provenance_cases", 0, "materialized_text"], "wrong"), "provenance text mismatch"),
        ("provenance_acceptance", set_value(["provenance_cases", 3, "accepted"], True), "provenance acceptance mismatch"),
        ("job_id", set_value(["job_id_cases", 0, "expected_job_id"], "parse_job:v2:sha256:" + "0" * 64), "job id mismatch"),
        ("registry_immutable", set_value(["resolution_snapshot", "immutable"], False), "registry snapshot must be immutable"),
        ("registry_prepared", set_value(["resolution_snapshot", "prepared_before_authored_execution"], False), "prepared before authored execution"),
        ("registry_filesystem", set_value(["resolution_snapshot", "filesystem_access_during_dispatch"], True), "must not access the filesystem"),
        ("registry_entry_shape", set_value(["resolution_snapshot", "entries", 0, "path"], "secret.spec"), "registry entry keys differ"),
        ("registry_compiled", set_value(["resolution_snapshot", "entries", 0, "compiled_authority"], "path:spec"), "compiled authority must be opaque"),
        ("registry_content", set_value(["resolution_snapshot", "entries", 0, "content_digest"], "bad"), "content digest is invalid"),
        ("registry_graph", set_value(["resolution_snapshot", "entries", 0, "import_graph_fingerprint"], "bad"), "import graph fingerprint is invalid"),
        ("registry_top", set_value(["resolution_snapshot", "entries", 0, "default_top_rule"], "Missing"), "default top rule must be allowed"),
        ("registry_version", set_value(["resolution_snapshot", "entries", 0, "staged_contract_version"], 1), "staged contract version mismatch"),
        ("resolution_result", set_value(["resolution_cases", 0, "resolved_spec_id"], "registry:wrong"), "resolution result mismatch"),
        ("resolution_diagnostic", set_value(["resolution_cases", 4, "diagnostic"], None), "resolution diagnostic mismatch"),
        ("authority_result", set_value(["authority_cases", 0, "effective"], {}), "authority result mismatch"),
        ("cache_relation", set_value(["cache_cases", 2, "same_as_base"], True), "cache relation mismatch"),
        ("queue_order", set_value(["queue_cases", 0, "expected_order"], []), "queue order mismatch"),
        ("isolation_result", set_value(["isolation_cases", 0, "expected"], {}), "isolation result mismatch"),
        ("stitch_result", set_value(["stitch_cases", 0, "expected_parent"], {}), "stitch result mismatch"),
        ("failure_result", set_value(["failure_cases", 0, "expected"], {}), "failure result mismatch"),
        ("chain_result", set_value(["chain_cases", 0, "accepted"], False), "chain acceptance mismatch"),
        ("detachment_result", set_value(["detachment_cases", 0, "accepted"], False), "detachment acceptance mismatch"),
        ("compatibility_status", set_value(["compatibility_v1", "status"], "removed"), "compatibility status mismatch"),
        ("compatibility_parser", set_value(["compatibility_v1", "parser_spec_id"], "expr-v1"), "v1 parser mismatch"),
        ("compatibility_policy", set_value(["compatibility_v1", "result_policy"], "replace_marker"), "v1 stitch mismatch"),
        ("compatibility_upgrade", set_value(["compatibility_v1", "upgrade_to_v2"], "implicit"), "compatibility boundary mismatch"),
        ("carrier_kind", set_value(["carrier_requirements", 0, "carrier"], "host_only"), "carrier requirement inventory mismatch"),
        ("consumer_path", set_value(["backend_consumers", 0, "path"], "/tmp/test.t"), "backend consumer inventory mismatch"),
        ("consumer_status", set_value(["backend_consumers", 0, "status"], "dormant_red"), "backend consumer inventory mismatch"),
        ("rust_consumer_status", set_value(["backend_consumers", 1, "status"], "dormant_red"), "backend consumer inventory mismatch"),
        ("dart_consumer_status", set_value(["backend_consumers", 2, "status"], "pending_absent"), "backend consumer inventory mismatch"),
        ("julia_consumer_status", set_value(["backend_consumers", 3, "status"], "pending_absent"), "backend consumer inventory mismatch"),
        ("lua_consumer_status", set_value(["backend_consumers", 4, "status"], "pending_absent"), "backend consumer inventory mismatch"),
        ("runtime_route", set_value(["runtime_routes", 5, "runtime"], "lua"), "runtime route inventory mismatch"),
        ("outward_path", set_value(["outward_guard", "paths", 0], "README2.md"), "outward guard mismatch"),
        ("outward_token", set_value(["outward_guard", "forbidden_tokens"], []), "outward guard mismatch"),
        ("diagnostic_code", set_value(["diagnostics", 0, "code"], "wrong"), "diagnostic context inventory mismatch"),
        ("diagnostic_context", set_value(["diagnostics", 0, "required_context"], ["code"]), "diagnostic context inventory mismatch"),
        ("rollout_neutral", set_value(["rollout", 0, "status"], "pending"), "rollout inventory mismatch"),
        ("rollout_backend", set_value(["rollout", 1, "status"], "pending"), "rollout inventory mismatch"),
        ("rollout_rust", set_value(["rollout", 2, "status"], "pending"), "rollout inventory mismatch"),
        ("rollout_dart", set_value(["rollout", 3, "status"], "pending"), "rollout inventory mismatch"),
        ("rollout_julia", set_value(["rollout", 4, "status"], "pending"), "rollout inventory mismatch"),
        ("rollout_puc_lua", set_value(["rollout", 5, "status"], "pending"), "rollout inventory mismatch"),
        ("rollout_luajit", set_value(["rollout", 6, "status"], "pending"), "rollout inventory mismatch"),
        ("rollout_public", set_value(["rollout", 8, "status"], "complete"), "rollout inventory mismatch"),
        ("canonical_contract", set_value(["canonical_execution", "contract_path"], "/tmp/contract.json"), "canonical execution mismatch"),
        ("canonical_checker", set_value(["canonical_execution", "checker_path"], "tools/wrong.py"), "canonical execution mismatch"),
        ("canonical_runner", set_value(["canonical_execution", "project_data_runner"], "python3"), "canonical execution mismatch"),
        ("canonical_invocation", set_value(["canonical_execution", "invocation"], "python3 checker.py"), "canonical execution mismatch"),
        ("perl_admission_consumer", set_value(["canonical_execution", "perl_admission", "consumer_path"], "t/wrong.t"), "canonical execution mismatch"),
        ("perl_admission_ordinary", set_value(["canonical_execution", "perl_admission", "ordinary_driver"], "t/wrong.t"), "canonical execution mismatch"),
        ("perl_admission_syntax", set_value(["canonical_execution", "perl_admission", "syntax_invocation"], "perl -c wrong.t"), "canonical execution mismatch"),
        ("perl_admission_marker", set_value(["canonical_execution", "perl_admission", "registration_marker"], "wrong marker"), "canonical execution mismatch"),
        ("perl_admission_invocation", set_value(["canonical_execution", "perl_admission", "invocation"], "prove wrong.t"), "canonical execution mismatch"),
        ("rust_admission_consumer", set_value(["canonical_execution", "rust_admission", "consumer_path"], "rust/wrong.rs"), "canonical execution mismatch"),
        ("rust_admission_ordinary", set_value(["canonical_execution", "rust_admission", "ordinary_invocation"], "cargo test wrong"), "canonical execution mismatch"),
        ("rust_admission_marker", set_value(["canonical_execution", "rust_admission", "registration_marker"], "wrong marker"), "canonical execution mismatch"),
        ("rust_admission_invocation", set_value(["canonical_execution", "rust_admission", "invocation"], "cargo test wrong"), "canonical execution mismatch"),
        ("dart_admission_consumer", set_value(["canonical_execution", "dart_admission", "consumer_path"], "dart/test/wrong.dart"), "canonical execution mismatch"),
        ("dart_admission_ordinary", set_value(["canonical_execution", "dart_admission", "ordinary_invocation"], "dart test wrong"), "canonical execution mismatch"),
        ("dart_admission_marker", set_value(["canonical_execution", "dart_admission", "registration_marker"], "wrong marker"), "canonical execution mismatch"),
        ("dart_admission_invocation", set_value(["canonical_execution", "dart_admission", "invocation"], "dart test wrong"), "canonical execution mismatch"),
        ("julia_admission_consumer", set_value(["canonical_execution", "julia_admission", "consumer_path"], "julia/test/wrong.jl"), "canonical execution mismatch"),
        ("julia_admission_ordinary", set_value(["canonical_execution", "julia_admission", "ordinary_invocation"], "julia wrong.jl"), "canonical execution mismatch"),
        ("julia_admission_marker", set_value(["canonical_execution", "julia_admission", "registration_marker"], "wrong marker"), "canonical execution mismatch"),
        ("julia_admission_invocation", set_value(["canonical_execution", "julia_admission", "invocation"], "julia wrong.jl"), "canonical execution mismatch"),
        ("lua_admission_consumer", set_value(["canonical_execution", "lua_admission", "consumer_path"], "lua/test/wrong.lua"), "canonical execution mismatch"),
        ("lua_admission_ordinary", set_value(["canonical_execution", "lua_admission", "ordinary_driver"], "lua/test/run.lua"), "canonical execution mismatch"),
        ("lua_admission_puc_marker", set_value(["canonical_execution", "lua_admission", "puc_registration_marker"], "wrong marker"), "canonical execution mismatch"),
        ("lua_admission_puc_invocation", set_value(["canonical_execution", "lua_admission", "puc_invocation"], "lua wrong.lua"), "canonical execution mismatch"),
        ("lua_admission_luajit_marker", set_value(["canonical_execution", "lua_admission", "luajit_registration_marker"], "wrong marker"), "canonical execution mismatch"),
        ("lua_admission_luajit_invocation", set_value(["canonical_execution", "lua_admission", "luajit_invocation"], "luajit wrong.lua"), "canonical execution mismatch"),
        ("ownership", set_value(["ownership", 0, "owner"], "wrong"), "ownership inventory mismatch"),
    ]
    return mutations


def validate_mutations(contract: dict[str, Any]) -> None:
    mutations = mutation_inventory()
    ids = [mutation_id for mutation_id, _, _ in mutations]
    require(len(ids) == len(set(ids)), "checker mutation ids must be unique")
    require(contract["mutation_ids"] == ids, "mutation id inventory mismatch")
    for mutation_id, mutate, expected_reason in mutations:
        candidate = copy.deepcopy(contract)
        mutate(candidate)
        try:
            validate_contract(candidate, environment=False)
        except ContractError as exc:
            require(expected_reason in str(exc), f"mutation {mutation_id} failed for the wrong reason: {exc}")
        else:
            raise ContractError(f"mutation unexpectedly passed: {mutation_id}")


def main() -> int:
    try:
        contract = read_json(CONTRACT_PATH)
        validate_contract(contract)
        validate_mutations(contract)
    except ContractError as exc:
        print(f"ContractError: {exc}")
        return 1
    counts = contract["expected_counts"]
    print(
        "staged-AST enrichment contract: "
        f"{counts['registry_entries']} registry entries, {counts['provenance_cases']} provenance, "
        f"{counts['resolution_cases']} resolution/{counts['authority_cases']} authority, "
        f"{counts['cache_cases']} cache, {counts['queue_cases']} queue/{counts['isolation_cases']} isolation, "
        f"{counts['stitch_cases']} result policies, "
        f"{counts['failure_cases']} failure policies, {counts['chain_cases']} chain, "
        f"{counts['detachment_cases']} detachment, {counts['backend_consumers']} backend consumers/"
        f"{counts['runtime_routes']} runtime routes, {counts['diagnostics']} diagnostics, "
        f"{counts['rollout_legs']} rollout legs, {counts['ownership_rows']} owners, "
        f"{counts['mutations']} mutations"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

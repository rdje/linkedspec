#!/usr/bin/env python3
"""Validate the closed standalone lifecycle-I shorthand contract."""

from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance/standalone_lifecycle_block_contract.json"
CONTRACT_ID = "linkedspec-standalone-lifecycle-block-v1"
BACKENDS = ["perl", "rust", "dart", "julia", "lua_dual_abi", "self_hosted"]
RUNTIME_ROUTES = ["perl", "rust", "dart", "julia", "puc_lua", "luajit"]
PLACEMENT_IDS = [
    "default_zero_regex",
    "or_one_regex_before",
    "or_one_regex_after",
    "or_two_regex_between",
    "and_zero_regex",
    "and_one_regex_after",
    "and_two_regex_between",
    "default_header_rest",
    "or_same_line_successor",
]
DUPLICATE_IDS = [
    "explicit_explicit",
    "explicit_shorthand",
    "shorthand_explicit",
    "shorthand_shorthand",
]
OWNERSHIP_IDS = [
    "action_edge_block",
    "blind_edge_block",
    "bare_edge_block",
    "callable_block",
    "nested_lifecycle_block",
    "function_body",
]
MALFORMED_IDS = ["missing_close", "unsupported_remainder", "unmatched_close"]


class ContractError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def require_file(path: str) -> None:
    require((ROOT / path).is_file(), f"required tracked surface is missing: {path}")


def ids(rows: Any, field: str) -> list[str]:
    require(isinstance(rows, list), f"{field} must be an array")
    values = [row.get("id") for row in rows if isinstance(row, dict)]
    require(len(values) == len(rows), f"{field} rows must be objects with ids")
    require(len(values) == len(set(values)), f"{field} ids must be unique")
    return values


def validate_contract(contract: dict[str, Any], *, check_files: bool) -> None:
    require(contract.get("contract_id") == CONTRACT_ID, "contract identity drifted")
    require(contract.get("task_owner") == "FUTURE-PARITY-BACKLOG.15.1", "contract owner drifted")
    require(
        contract.get("decision")
        == "docs/decisions/0094-standalone-rule-block-normalizes-to-lifecycle-i.md",
        "decision authority drifted",
    )
    normalization = contract.get("normalization", {})
    require(normalization.get("semantic_kind") == "code_block", "semantic kind must remain code_block")
    require(normalization.get("lifecycle") == "I", "standalone block must remain lifecycle I")
    require(normalization.get("source_parser_emits_plain_block") is False, "source parsing must not emit plain blocks")
    require(
        normalization.get("legacy_plain_block_policy") == "readable_inert_compatibility",
        "legacy plain carriers must remain readable and inert",
    )
    require(
        normalization.get("duplicate_policy") == "append_statements_in_authored_order",
        "duplicate lifecycle order drifted",
    )

    placements = contract.get("placement_twins")
    require(ids(placements, "placement_twins") == PLACEMENT_IDS, "placement inventory drifted")
    for row in placements:
        explicit = row["explicit"]
        shorthand = row["shorthand"]
        require("I {" in explicit, f"{row['id']} explicit twin lacks I marker")
        require("I {" not in shorthand, f"{row['id']} shorthand twin acquired I marker")
        require(row["opening_line"] >= 1, f"{row['id']} opening line must be positive")

    require(ids(contract.get("duplicate_cases"), "duplicate_cases") == DUPLICATE_IDS, "duplicate inventory drifted")
    require(contract.get("duplicate_expected") == "first-second", "duplicate result drifted")
    require(contract.get("generated_fixture_case") in DUPLICATE_IDS, "generated fixture must name a duplicate case")
    require(ids(contract.get("ownership_cases"), "ownership_cases") == OWNERSHIP_IDS, "ownership inventory drifted")
    require(ids(contract.get("malformed_twins"), "malformed_twins") == MALFORMED_IDS, "malformed inventory drifted")

    admissions = contract.get("admissions", {})
    require(list(admissions) == BACKENDS, "backend admission inventory or order drifted")
    for backend, admission in admissions.items():
        require(admission.get("status") == "complete", f"{backend} admission is not complete")
        require(isinstance(admission.get("roles"), list) and admission["roles"], f"{backend} roles are empty")
        require(len(admission["roles"]) == len(set(admission["roles"])), f"{backend} roles repeat")
        if check_files:
            require_file(admission["consumer"])
    require(admissions["lua_dual_abi"].get("runtimes") == ["puc_lua", "luajit"], "Lua ABI routes drifted")

    recurring = contract.get("recurring_gate", {})
    require(recurring.get("backend_count") == 5, "recurring backend count must remain five")
    require(recurring.get("runtime_routes") == RUNTIME_ROUTES, "recurring runtime routes drifted")
    require(
        recurring.get("local_ci_switch") == "LINKEDSPEC_RUN_STANDALONE_LIFECYCLE_BLOCK_MATRIX",
        "local-CI switch drifted",
    )
    if check_files:
        require_file(recurring["driver"])
        require_file(recurring["neutral_checker"])
        require_file(recurring["self_hosted_consumer"])
        for support_check in recurring["support_checks"]:
            require_file(support_check)

    rollout = contract.get("rollout")
    require(isinstance(rollout, list) and len(rollout) == 7, "rollout must retain seven closed lanes")
    require(all(row.get("status") == "complete" for row in rollout), "every rollout lane must be complete")

    if check_files:
        manifest = json.loads((ROOT / "capability_conformance/manifest.json").read_text())
        capability_id = contract["public_contract"]["capability_id"]
        matching = [row for row in manifest["capabilities"] if row["id"] == capability_id]
        require(len(matching) == 1, "capability ledger must contain one standalone lifecycle row")
        require(
            {name: row["status"] for name, row in matching[0]["backends"].items()}
            == {name: "pass" for name in ["perl", "rust", "dart", "julia", "lua"]},
            "standalone lifecycle capability must be five-backend pass",
        )
        for document in contract["public_contract"]["documents"]:
            require_file(document["path"])
            text = (ROOT / document["path"]).read_text()
            for marker in document["required_markers"]:
                require(marker in text, f"{document['path']} is missing public marker: {marker}")

        self_hosted = (ROOT / "specs/spec.spec").read_text()
        require("standalone_lifecycle_block:" in self_hosted, "self-hosted standalone production is missing")
        require("-> lifecycle_block_line" in self_hosted, "reserved lifecycle precedence route is missing")
        ci = (ROOT / "tools/run_ci_local.sh").read_text()
        require(recurring["local_ci_switch"] in ci, "canonical local CI does not expose the recurring switch")
        require(recurring["driver"] in ci, "canonical local CI does not invoke the recurring driver")


def expect_mutation_failure(contract: dict[str, Any], mutate: Any, label: str) -> None:
    candidate = copy.deepcopy(contract)
    mutate(candidate)
    try:
        validate_contract(candidate, check_files=False)
    except ContractError:
        return
    raise ContractError(f"drift mutation was not rejected: {label}")


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text())
    validate_contract(contract, check_files=True)
    mutations = [
        (lambda value: value["normalization"].update(lifecycle="E"), "lifecycle marker"),
        (lambda value: value["normalization"].update(source_parser_emits_plain_block=True), "plain source node"),
        (lambda value: value["placement_twins"].pop(), "placement removal"),
        (lambda value: value["duplicate_cases"].reverse(), "duplicate order"),
        (lambda value: value["ownership_cases"].pop(), "ownership removal"),
        (lambda value: value["malformed_twins"].pop(), "malformed removal"),
        (lambda value: value["admissions"]["dart"].update(status="partial"), "backend status"),
        (lambda value: value["admissions"]["lua_dual_abi"].update(runtimes=["puc_lua"]), "Lua ABI removal"),
        (lambda value: value["recurring_gate"].update(backend_count=4), "backend count"),
        (lambda value: value["recurring_gate"]["runtime_routes"].pop(), "runtime route removal"),
        (lambda value: value["rollout"][0].update(status="pending"), "rollout reopening"),
    ]
    for mutate, label in mutations:
        expect_mutation_failure(contract, mutate, label)
    print(
        "standalone lifecycle-block contract: "
        f"{len(PLACEMENT_IDS)} placements, {len(DUPLICATE_IDS)} duplicate forms, "
        f"{len(OWNERSHIP_IDS)} ownership cases, {len(MALFORMED_IDS)} malformed twins, "
        f"{len(RUNTIME_ROUTES)} runtime routes, {len(mutations)} drift mutations"
    )


if __name__ == "__main__":
    try:
        main()
    except (ContractError, KeyError, TypeError, json.JSONDecodeError) as error:
        raise SystemExit(f"standalone lifecycle-block contract: ERROR: {error}") from error

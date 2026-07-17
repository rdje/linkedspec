#!/usr/bin/env python3
"""Validate ADR 0044's backend-neutral rule-local cursor contract."""

from __future__ import annotations

import copy
import json
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
    ("rust_backend", "pending", "FUTURE-PARITY-BACKLOG.9.1.4"),
    ("dart_backend", "pending", "FUTURE-PARITY-BACKLOG.9.1.5"),
    ("julia_backend", "pending", "FUTURE-PARITY-BACKLOG.9.1.6"),
    ("lua_dual_abi", "pending", "FUTURE-PARITY-BACKLOG.9.1.7"),
    ("recurring_five_backend_gate", "pending", "FUTURE-PARITY-BACKLOG.9.1.8"),
    ("public_no_drift", "pending", "FUTURE-PARITY-BACKLOG.9.1.9"),
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
        ("diagnostic_removed", lambda c: c["diagnostics"].pop()),
        ("diagnostic_stage", lambda c: c["diagnostics"][0].__setitem__("stage", "execute")),
        ("inventory_pattern", lambda c: c["migration_inventory"]["token_patterns"].pop()),
        ("inventory_count", lambda c: c["migration_inventory"].__setitem__("expected_file_count", 0)),
        ("inventory_path", lambda c: c["migration_inventory"]["groups"][0]["paths"].pop()),
        ("inventory_owner", lambda c: c["migration_inventory"]["groups"][1].__setitem__("owner", "wrong")),
        ("rollout_removed", lambda c: c["rollout"].pop()),
        ("rollout_admission", lambda c: c["rollout"][1].__setitem__("status", "pending")),
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
        f"{contract['migration_inventory']['expected_file_count']} migration files; "
        f"{complete} complete / {pending} pending; {mutation_count} drift mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

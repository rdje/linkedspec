#!/usr/bin/env python3
"""Validate the neutral uniform-binding and aggregate-selector retirement contract."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "uniform_binding_contract.json"
IDENTIFIER_SOURCE = r"[A-Za-z_][A-Za-z0-9_]*"
IDENTIFIER = re.compile(IDENTIFIER_SOURCE + r"\Z")
SELECTOR = re.compile(
    rf"(?<![A-Za-z0-9_])(?P<surface>array|hash)\s*\(\s*(?P<identifier>{IDENTIFIER_SOURCE})\s*\)"
)
VALUE_KINDS = {"scalar", "array", "harray", "codeblock"}


class ContractError(ValueError):
    """A stable contract-validation failure."""

    def __init__(self, code: str, detail: str, fields: dict[str, Any] | None = None):
        super().__init__(detail)
        self.code = code
        self.fields = copy.deepcopy(fields or {})


def fail(code: str, detail: str, fields: dict[str, Any] | None = None) -> None:
    raise ContractError(code, detail, fields)


def cloned(value: Any) -> Any:
    return copy.deepcopy(value)


def value_kind(value: Any) -> str:
    if isinstance(value, list):
        return "array"
    if isinstance(value, dict) and value.get("kind") == "codeblock":
        return "codeblock"
    if isinstance(value, dict):
        return "harray"
    return "scalar"


def mismatch(identifier: str, expected: str, actual_value: Any) -> None:
    fail(
        "binding_kind_mismatch",
        f"{identifier} requires {expected}, got {value_kind(actual_value)}",
        {
            "identifier": identifier,
            "expected_kind": expected,
            "actual_kind": value_kind(actual_value),
        },
    )


def require_target(step: dict[str, Any]) -> str:
    target = step.get("target")
    if not isinstance(target, str) or not IDENTIFIER.fullmatch(target):
        fail("invalid_execution_case", "operation target must be an identifier")
    return target


def split_value(source: Any, delimiter: Any) -> list[str]:
    if not isinstance(source, str) or not isinstance(delimiter, str) or delimiter == "":
        fail("invalid_execution_case", "neutral split evaluator requires nonempty literal string delimiter")
    return source.split(delimiter)


def assign_result(step: dict[str, Any], value: Any, results: dict[str, Any]) -> None:
    save = step.get("save")
    if save is None:
        return
    if not isinstance(save, str) or not IDENTIFIER.fullmatch(save):
        fail("invalid_execution_case", "saved result name must be an identifier")
    results[save] = cloned(value)


def apply_step(
    step: dict[str, Any],
    bindings: dict[str, Any],
    results: dict[str, Any],
    static_rules: dict[str, Any],
) -> None:
    op = step.get("op")
    if op == "set":
        target = require_target(step)
        bindings[target] = cloned(step.get("value"))
        assign_result(step, bindings[target], results)
        return

    if op == "push":
        target = require_target(step)
        if target in static_rules:
            destination = step.get("value_binding")
            if not isinstance(destination, str) or not IDENTIFIER.fullmatch(destination):
                fail("invalid_execution_case", "static-rule push requires a bare destination binding")
            current = bindings.get(destination)
            if current is None:
                current = []
            elif not isinstance(current, list):
                mismatch(destination, "array", current)
            current = cloned(current)
            current.append(cloned(static_rules[target]))
            bindings[destination] = current
            assign_result(step, current, results)
            return
        current = bindings.get(target)
        if current is None:
            current = []
        elif not isinstance(current, list):
            mismatch(target, "array", current)
        current = cloned(current)
        current.append(cloned(step.get("value")))
        bindings[target] = current
        assign_result(step, current, results)
        return

    if op == "split":
        target = require_target(step)
        value = split_value(step.get("source"), step.get("delimiter"))
        bindings[target] = value
        assign_result(step, value, results)
        return

    if op == "pure_split":
        value = split_value(step.get("source"), step.get("delimiter"))
        assign_result(step, value, results)
        return

    if op == "hash_index_set":
        target = require_target(step)
        current = bindings.get(target)
        if current is None:
            current = {}
        elif not isinstance(current, dict) or value_kind(current) != "harray":
            mismatch(target, "harray", current)
        current = cloned(current)
        current[str(step.get("key"))] = cloned(step.get("value"))
        bindings[target] = current
        assign_result(step, current, results)
        return

    if op == "copy":
        target = require_target(step)
        assign_result(step, bindings.get(target), results)
        return

    if op == "read":
        target = require_target(step)
        assign_result(step, bindings.get(target), results)
        return

    if op == "sorted_first":
        source_result = step.get("source_result")
        value = results.get(source_result)
        if not isinstance(value, list):
            fail("invalid_execution_case", "sorted_first source result must be an array")
        answer = sorted(cloned(value), key=lambda item: str(item))[0] if value else None
        assign_result(step, answer, results)
        return

    fail("invalid_execution_case", f"unknown operation {op!r}")


def evaluate_case(case: dict[str, Any]) -> tuple[dict[str, Any], dict[str, Any]]:
    bindings = cloned(case["initial_bindings"])
    results: dict[str, Any] = {}
    static_rules = cloned(case["static_rules"])
    for step in case["steps"]:
        if not isinstance(step, dict):
            fail("invalid_execution_case", "execution step must be an object")
        apply_step(step, bindings, results, static_rules)
    return bindings, results


def selector_diagnostic(source: str) -> dict[str, str] | None:
    match = SELECTOR.search(source)
    if match is None:
        return None
    surface = match.group("surface")
    identifier = match.group("identifier")
    return {
        "code": "aggregate_selector_removed",
        "surface": surface,
        "identifier": identifier,
        "replacement": identifier,
    }


def evaluate_fixture_step(step: dict[str, Any], bindings: dict[str, Any]) -> None:
    op = step.get("op")
    target = require_target(step)
    if op == "set":
        bindings[target] = cloned(step.get("value"))
    elif op == "push":
        current = bindings.get(target, [])
        if not isinstance(current, list):
            mismatch(target, "array", current)
        bindings[target] = [*cloned(current), cloned(step.get("value"))]
    elif op == "pure_split_assign":
        bindings[target] = split_value(step.get("source_value"), step.get("delimiter"))
    elif op == "hash_index_set_count":
        current = bindings.get(target, {})
        source = bindings.get(step.get("source_binding"))
        if not isinstance(current, dict) or not isinstance(source, list):
            fail("invalid_fixture", "count assignment requires harray target and array source")
        current = cloned(current)
        current[str(step.get("key"))] = len(source)
        bindings[target] = current
    elif op == "set_sorted_first":
        source = bindings.get(step.get("source_binding"))
        if not isinstance(source, list):
            fail("invalid_fixture", "set_sorted_first source must be an array")
        bindings[target] = cloned(source)
        result_target = step.get("result_target")
        if not isinstance(result_target, str) or not IDENTIFIER.fullmatch(result_target):
            fail("invalid_fixture", "set_sorted_first result target must be an identifier")
        bindings[result_target] = sorted(cloned(bindings[target]), key=lambda item: str(item))[0] if source else None
    else:
        fail("invalid_fixture", f"unknown fixture operation {op!r}")


def render_fixture(fixture: dict[str, Any]) -> str:
    lines = "\n".join(f'   {step["source"]}' for step in fixture["steps"])
    fields = ", ".join(
        f'{json.dumps(field)} : {binding}' for field, binding in fixture["result_fields"].items()
    )
    return f"Top::\n /x/ -> Done {{\n{lines}\n   return({{ {fields} }})\n }}\n\nDone::\n /x/\n"


def validate_contract_shape(contract: dict[str, Any]) -> None:
    expected_top = {
        "format",
        "contract_id",
        "policy",
        "syntax",
        "constructor_policy",
        "diagnostics",
        "migration_cases",
        "execution_cases",
        "invalid_selector_cases",
        "valid_constructor_cases",
        "fixture",
    }
    if set(contract) != expected_top:
        fail("invalid_contract", "top-level fields drifted")
    if contract["format"] != 1 or contract["contract_id"] != "linkedspec-uniform-binding-v1":
        fail("invalid_contract", "format or contract id drifted")
    if set(contract["policy"]) != {
        "binding",
        "host_storage",
        "read",
        "set_result",
        "mutation_result",
        "unused_result",
        "absent_binding",
        "wrong_kind",
        "static_precedence",
        "selector_retirement",
    }:
        fail("invalid_contract", "policy fields drifted")
    if contract["syntax"].get("identifier_pattern") != IDENTIFIER_SOURCE:
        fail("invalid_contract", "identifier syntax drifted")
    if set(contract["diagnostics"]) != {"removed_selector", "wrong_kind"}:
        fail("invalid_contract", "diagnostic catalog drifted")
    removed = contract["diagnostics"]["removed_selector"]
    wrong_kind = contract["diagnostics"]["wrong_kind"]
    if removed.get("code") != "aggregate_selector_removed" or removed.get("fields") != [
        "code",
        "surface",
        "identifier",
        "replacement",
    ]:
        fail("invalid_contract", "removed-selector diagnostic drifted")
    if wrong_kind != {
        "code": "binding_kind_mismatch",
        "fields": ["code", "identifier", "expected_kind", "actual_kind"],
    }:
        fail("invalid_contract", "wrong-kind diagnostic drifted")
    if VALUE_KINDS != {"scalar", "array", "harray", "codeblock"}:
        fail("invalid_contract", "portable value kinds drifted")


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    if not isinstance(contract, dict):
        fail("invalid_contract", "contract root must be an object")
    validate_contract_shape(contract)

    constructor_policy = contract["constructor_policy"]
    if constructor_policy.get("canonical_single_array") != "[value]":
        fail("invalid_contract", "single-value array constructor migration drifted")
    if constructor_policy.get("forbidden_even_when_constructor_intended") != ["array(value)", "hash(value)"]:
        fail("invalid_contract", "forbidden selector-shaped constructors drifted")

    migration_ids: set[str] = set()
    for case in contract["migration_cases"]:
        if set(case) != {"id", "before", "after", "purpose"} or case["id"] in migration_ids:
            fail("invalid_migration_case", "migration case fields/id drifted")
        migration_ids.add(case["id"])
        if selector_diagnostic(case["before"]) is None:
            fail("invalid_migration_case", f'{case["id"]} before source has no removed selector')
        if selector_diagnostic(case["after"]) is not None:
            fail("invalid_migration_case", f'{case["id"]} after source retains a removed selector')

    invalid_ids: set[str] = set()
    for case in contract["invalid_selector_cases"]:
        if set(case) != {"id", "source", "surface", "identifier", "replacement"} or case["id"] in invalid_ids:
            fail("invalid_selector_case", "invalid selector case fields/id drifted")
        invalid_ids.add(case["id"])
        expected = {
            "code": "aggregate_selector_removed",
            "surface": case["surface"],
            "identifier": case["identifier"],
            "replacement": case["replacement"],
        }
        actual = selector_diagnostic(case["source"])
        if actual != expected:
            fail("invalid_selector_case", f'{case["id"]} expected {expected!r}, got {actual!r}')

    valid_ids: set[str] = set()
    for case in contract["valid_constructor_cases"]:
        if set(case) != {"id", "source"} or case["id"] in valid_ids:
            fail("invalid_constructor_case", "constructor case fields/id drifted")
        valid_ids.add(case["id"])
        if selector_diagnostic(case["source"]) is not None:
            fail("invalid_constructor_case", f'{case["id"]} was misclassified as a selector')

    execution_ids: set[str] = set()
    for case in contract["execution_cases"]:
        if case.get("id") in execution_ids:
            fail("invalid_execution_case", "duplicate execution case id")
        execution_ids.add(case["id"])
        expected_fields = {
            "id",
            "initial_bindings",
            "static_rules",
            "steps",
            "expected_bindings",
            "expected_results",
        }
        if "expected_error" in case:
            expected_fields = {"id", "initial_bindings", "static_rules", "steps", "expected_error"}
        if set(case) != expected_fields:
            fail("invalid_execution_case", f'{case["id"]} fields drifted')
        try:
            actual_bindings, actual_results = evaluate_case(case)
        except ContractError as error:
            if "expected_error" not in case:
                raise
            actual_error = {"code": error.code, **error.fields}
            if actual_error != case["expected_error"]:
                fail("invalid_execution_case", f'{case["id"]} expected {case["expected_error"]!r}, got {actual_error!r}')
        else:
            if "expected_error" in case:
                fail("invalid_execution_case", f'{case["id"]} unexpectedly succeeded')
            if actual_bindings != case["expected_bindings"] or actual_results != case["expected_results"]:
                fail(
                    "invalid_execution_case",
                    f'{case["id"]} expected {(case["expected_bindings"], case["expected_results"])!r}, '
                    f"got {(actual_bindings, actual_results)!r}",
                )

    fixture = contract["fixture"]
    if set(fixture) != {
        "input",
        "initial_bindings",
        "steps",
        "result_fields",
        "spec_source",
        "expected",
    }:
        fail("invalid_fixture", "fixture fields drifted")
    if fixture["input"] != "xx":
        fail("invalid_fixture", "fixture input drifted")
    if render_fixture(fixture) != fixture["spec_source"]:
        fail("invalid_fixture", "fixture source drifted from deterministic rendering")
    if selector_diagnostic(fixture["spec_source"]) is not None:
        fail("invalid_fixture", "future fixture contains a removed selector")
    fixture_bindings = cloned(fixture["initial_bindings"])
    for step in fixture["steps"]:
        evaluate_fixture_step(step, fixture_bindings)
    fixture_result = {
        field: cloned(fixture_bindings.get(binding))
        for field, binding in fixture["result_fields"].items()
    }
    if fixture_result != fixture["expected"]:
        fail("invalid_fixture", f"fixture expected {fixture['expected']!r}, got {fixture_result!r}")

    print(
        "uniform-binding-contract: OK "
        f"({len(migration_ids)} migrations; {len(execution_ids)} executions; "
        f"{len(invalid_ids)} invalid selectors; {len(valid_ids)} constructors)"
    )


if __name__ == "__main__":
    try:
        main()
    except ContractError as error:
        raise SystemExit(f"uniform-binding-contract: {error.code}: {error}") from error

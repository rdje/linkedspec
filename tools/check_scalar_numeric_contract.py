#!/usr/bin/env python3
"""Validate scalar numeric contract schema, values, and generated DSL fixture."""

from __future__ import annotations

import json
import math
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "scalar_numeric_contract.json"
DECIMAL = re.compile(r"-?(?:\d+(?:\.\d+)?|\.\d+)\Z")
UNARY = {"num_abs", "num_floor", "num_ceil", "num_round"}
VARIADIC = {"num_add", "num_mul", "num_min", "num_max"}
BINARY = {"num_sub", "num_div", "num_mod"}
COMPARISONS = {"num_eq", "num_ne", "num_gt", "num_ge", "num_lt", "num_le"}
HELPERS = UNARY | VARIADIC | BINARY | COMPARISONS | {"num_clamp"}


def number(value: Any) -> float | None:
    if isinstance(value, bool) or value is None or isinstance(value, (list, dict)):
        return None
    if isinstance(value, (int, float)):
        parsed = float(value)
    elif isinstance(value, str) and DECIMAL.fullmatch(value):
        try:
            parsed = float(value)
        except ValueError:
            return None
    else:
        return None
    return parsed if math.isfinite(parsed) else None


def normalized(value: float | int) -> int | float | None:
    value = float(value)
    if not math.isfinite(value):
        return None
    if value == 0:
        return 0
    return int(value) if value.is_integer() else value


def evaluate(helper: str, args: list[Any]) -> int | float | None:
    if helper in UNARY and len(args) != 1:
        return None
    if helper in VARIADIC and len(args) < 2:
        return None
    if helper in BINARY | COMPARISONS and len(args) != 2:
        return None
    if helper == "num_clamp" and len(args) != 3:
        return None
    values = [number(value) for value in args]
    if any(value is None for value in values):
        return None
    nums = [value for value in values if value is not None]
    if helper == "num_add":
        result = sum(nums)
    elif helper == "num_mul":
        result = math.prod(nums)
    elif helper == "num_sub":
        result = nums[0] - nums[1]
    elif helper == "num_div":
        if nums[1] == 0:
            return None
        result = nums[0] / nums[1]
    elif helper == "num_mod":
        if nums[1] == 0 or not nums[0].is_integer() or not nums[1].is_integer():
            return None
        result = nums[0] - math.floor(nums[0] / nums[1]) * nums[1]
    elif helper == "num_abs":
        result = abs(nums[0])
    elif helper == "num_floor":
        result = math.floor(nums[0])
    elif helper == "num_ceil":
        result = math.ceil(nums[0])
    elif helper == "num_round":
        result = math.floor(nums[0] + 0.5) if nums[0] >= 0 else math.ceil(nums[0] - 0.5)
    elif helper == "num_min":
        result = min(nums)
    elif helper == "num_max":
        result = max(nums)
    elif helper == "num_clamp":
        if nums[1] > nums[2]:
            return None
        result = min(max(nums[0], nums[1]), nums[2])
    else:
        comparison = {
            "num_eq": nums[0] == nums[1],
            "num_ne": nums[0] != nums[1],
            "num_gt": nums[0] > nums[1],
            "num_ge": nums[0] >= nums[1],
            "num_lt": nums[0] < nums[1],
            "num_le": nums[0] <= nums[1],
        }[helper]
        result = 1 if comparison else 0
    return normalized(result)


def render_value(value: Any) -> str:
    if value is None:
        return "undef"
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list):
        return "[" + ", ".join(render_value(item) for item in value) + "]"
    if isinstance(value, dict):
        return "{ " + ", ".join(
            f"{render_value(key)} : {render_value(item)}" for key, item in value.items()
        ) + " }"
    if isinstance(value, float) and value == 0 and math.copysign(1, value) < 0:
        return "-0.0"
    return json.dumps(value, ensure_ascii=False, allow_nan=False)


def render_spec(cases: list[dict[str, Any]]) -> str:
    rows = []
    for case in cases:
        args = ", ".join(render_value(value) for value in case["args"])
        rows.append(f'     {json.dumps(case["id"])} : {case["helper"]}({args})')
    return (
        "Top::\n /x/ -> Done {\n   return({\n"
        + ",\n".join(rows)
        + "\n   })\n }\n\nDone::\n /x/\n"
    )


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    if contract.get("format") != 1 or contract.get("contract_id") != "linkedspec-scalar-numeric-v1":
        raise SystemExit("scalar-numeric-contract: invalid format or contract id")
    cases = contract.get("cases")
    if not isinstance(cases, list) or not cases:
        raise SystemExit("scalar-numeric-contract: cases must be a non-empty array")
    ids: set[str] = set()
    expected: dict[str, Any] = {}
    for index, case in enumerate(cases):
        if not isinstance(case, dict) or set(case) != {"id", "helper", "args", "expected"}:
            raise SystemExit(f"scalar-numeric-contract: case {index} has invalid fields")
        case_id = case["id"]
        helper = case["helper"]
        if not isinstance(case_id, str) or not re.fullmatch(r"[a-z][a-z0-9_]*", case_id):
            raise SystemExit(f"scalar-numeric-contract: invalid case id at {index}")
        if case_id in ids:
            raise SystemExit(f"scalar-numeric-contract: duplicate case id {case_id}")
        ids.add(case_id)
        if helper not in HELPERS or not isinstance(case["args"], list):
            raise SystemExit(f"scalar-numeric-contract: invalid helper/args for {case_id}")
        actual = evaluate(helper, case["args"])
        if actual != case["expected"]:
            raise SystemExit(
                f"scalar-numeric-contract: {case_id} expected {case['expected']!r}, evaluator gave {actual!r}"
            )
        expected[case_id] = case["expected"]
    if contract.get("expected") != expected:
        raise SystemExit("scalar-numeric-contract: expected object does not match ordered cases")
    rendered = render_spec(cases)
    if contract.get("spec_source") != rendered:
        raise SystemExit("scalar-numeric-contract: spec_source does not match deterministic case rendering")
    policy = contract.get("policy")
    if not isinstance(policy, dict) or set(policy) != {
        "accepted_number", "aggregate_reducers", "arity", "comparison_result", "invalid_input", "modulo", "round"
    }:
        raise SystemExit("scalar-numeric-contract: policy fields drifted")
    print(f"scalar-numeric-contract: OK ({len(cases)} cases; {len(HELPERS)} canonical helpers)")


if __name__ == "__main__":
    main()

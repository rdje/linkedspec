#!/usr/bin/env python3
"""Enforce cross-variant aggregate-selector rejection and runtime deletion."""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"aggregate-selector-retirement: {message}")


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        fail(f"required file is missing: {relative}")
    return path.read_text(encoding="utf-8")


def require_markers(relative: str, markers: tuple[str, ...]) -> None:
    source = read(relative)
    missing = [marker for marker in markers if marker not in source]
    if missing:
        fail(f"{relative} is missing required marker(s): {', '.join(missing)}")


def forbid_markers(relative: str, markers: tuple[str, ...]) -> None:
    source = read(relative)
    present = [marker for marker in markers if marker in source]
    if present:
        fail(f"{relative} retains forbidden runtime marker(s): {', '.join(present)}")


def forbid_patterns(relative: str, patterns: tuple[str, ...]) -> None:
    source = read(relative)
    for pattern in patterns:
        if re.search(pattern, source, flags=re.DOTALL):
            fail(f"{relative} retains forbidden runtime pattern: {pattern}")


def check_contract() -> tuple[int, int]:
    contract = json.loads(read("capability_conformance/uniform_binding_contract.json"))
    removed = contract.get("diagnostics", {}).get("removed_selector", {})
    if removed.get("code") != "aggregate_selector_removed":
        fail("neutral removed-selector diagnostic code drifted")
    if removed.get("fields") != ["code", "surface", "identifier", "replacement"]:
        fail("neutral removed-selector diagnostic fields drifted")
    invalid = contract.get("invalid_selector_cases")
    retained = contract.get("valid_constructor_cases")
    if not isinstance(invalid, list) or len(invalid) != 6:
        fail("neutral contract must retain exactly six invalid selector cases")
    if not isinstance(retained, list) or len(retained) != 8:
        fail("neutral contract must retain exactly eight constructor/literal classes")
    return len(invalid), len(retained)


def check_backend_anchors() -> None:
    tests = (
        "t/uniform_binding_contract.t",
        "rust/linkedspec-runtime/tests/uniform_binding_contract.rs",
        "dart/test/uniform_binding_contract_test.dart",
        "julia/test/uniform_binding_contract_test.jl",
        "lua/test/run.lua",
    )
    for relative in tests:
        require_markers(
            relative,
            (
                "invalid_selector_cases",
                "aggregate_selector_removed",
                "retained",
                "surface",
                "identifier",
                "replacement",
            ),
        )

    required = {
        "perl/LinkedSpec/ActionIR/RewritePipeline.pm": (
            "_reject_removed_aggregate_selectors_in_action_code",
            "aggregate_selector_removed",
        ),
        "perl/LinkedSpec/UserFunctionRegistry.pm": (
            "_reject_removed_aggregate_selectors_in_action_code",
        ),
        "rust/linkedspec-core/src/expr.rs": (
            "RemovedAggregateSelector",
            "find_removed_aggregate_selector",
            "aggregate_selector_removed",
        ),
        "rust/linkedspec-core/src/compiler.rs": ("validate_no_removed_aggregate_selectors",),
        "rust/linkedspec-runtime/src/source_emitter.rs": (
            "validate_no_removed_aggregate_selectors",
        ),
        "dart/lib/src/action/action_ast.dart": (
            "RemovedAggregateSelector",
            "findRemovedAggregateSelectorInBlock",
            "aggregate_selector_removed",
        ),
        "dart/lib/src/compiler/compiled_spec.dart": ("validateNoRemovedAggregateSelectors",),
        "dart/lib/src/source_emitter.dart": ("validateNoRemovedAggregateSelectors",),
        "julia/src/action/ActionAst.jl": (
            "RemovedAggregateSelector",
            "find_removed_aggregate_selector",
            "aggregate_selector_removed",
        ),
        "julia/src/compiler/CompiledSpec.jl": ("validate_no_removed_aggregate_selectors",),
        "julia/src/source/SourceEmitter.jl": ("validate_no_removed_aggregate_selectors",),
        "lua/src/linkedspec/action_ast.lua": (
            "find_removed_aggregate_selector",
            "aggregate_selector_removed",
        ),
        "lua/src/linkedspec/compiled_spec.lua": ("validate_no_removed_aggregate_selectors",),
        "lua/src/linkedspec/interpreter.lua": (
            "compiled_spec.validate_no_removed_aggregate_selectors(compiled)",
        ),
    }
    for relative, markers in required.items():
        require_markers(relative, markers)


def check_runtime_deletions() -> None:
    forbid_markers(
        "perl/LinkedSpec/ActionIR/MethodLowering.pm",
        ("Temporary selector", "selector recognition remains below"),
    )
    forbid_markers(
        "rust/linkedspec-runtime/src/engine.rs",
        (
            "aggregate_wrapper_assignment_target",
            "store_aggregate_assignment",
        ),
    )
    forbid_patterns(
        "rust/linkedspec-runtime/src/engine.rs",
        (
            r'Expr::Call\s*\{\s*name,\s*args\s*\}\s*if\s+name\s*==\s*"array"\s*&&\s*args\.len\(\)\s*==\s*1',
            r'Expr::Call\s*\{\s*name,\s*args\s*\}\s*if\s+name\s*==\s*"hash"\s*&&\s*args\.len\(\)\s*==\s*1',
        ),
    )
    forbid_markers(
        "dart/lib/src/runtime/interpreter.dart",
        ("_arrayTargetName(", "_hashTargetName(", "_replaceArrayValue("),
    )
    forbid_markers(
        "julia/src/runtime/Interpreter.jl",
        ("_runtime_array_target_name", "_runtime_hash_target_name"),
    )
    forbid_markers(
        "lua/src/linkedspec/interpreter.lua",
        (
            'target.kind == "array" or',
            'target.kind == "harray" or',
        ),
    )
    forbid_patterns(
        "lua/src/linkedspec/interpreter.lua",
        (
            r'expr\.name\s*==\s*"array".{0,200}#expr\.args\s*==\s*1',
            r'expr\.name\s*==\s*"hash".{0,200}#expr\.args\s*==\s*1',
        ),
    )


def check_embedded_sources() -> str:
    result = subprocess.run(
        [sys.executable, "tools/check_executable_aggregate_selector_sources.py"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.stderr.write(result.stderr)
        sys.stdout.write(result.stdout)
        fail("embedded executable-source scan failed")
    return result.stdout.strip()


def main() -> int:
    invalid_count, retained_count = check_contract()
    check_backend_anchors()
    check_runtime_deletions()
    embedded = check_embedded_sources()
    if embedded:
        print(embedded)
    print(
        "aggregate-selector-retirement: OK "
        f"(5 backends; {invalid_count} invalid selectors; "
        f"{retained_count} retained classes; runtime compatibility 0)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Reject positive embedded one-identifier aggregate-selector spec sources."""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SELECTOR = re.compile(
    r"(?<![A-Za-z0-9_.])(?:array|hash)\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\s*\)"
)
EXCLUDED_SUFFIXES = {
    ".json",
    ".lock",
    ".md",
    ".spec",
    ".toml",
    ".txt",
    ".yaml",
    ".yml",
}


def candidate_files() -> list[str]:
    result = subprocess.run(
        [
            "git",
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "-z",
        ],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    return [item.decode("utf-8") for item in result.stdout.split(b"\0") if item]


def classified_compatibility(path: str, line: str) -> bool:
    stripped = line.lstrip()
    if stripped.startswith(("#", "//", "/*", "*")):
        return True
    if "must be" in line and path in {
        "dart/lib/src/runtime/interpreter.dart",
        "julia/src/runtime/Interpreter.jl",
    }:
        return True
    if path == "tools/check_uniform_binding_contract.py":
        return True
    if path == "t/trace_emit_context_bridge.t" and (
        "rewrite_action_code_for_compat" in line
    ):
        return True
    if path == "t/uniform_binding_contract.t" and (
        "retired_inside_unused" in line
    ):
        return True
    if path == "rust/linkedspec-runtime/tests/uniform_binding_contract.rs" and (
        "selector-rejection fixture" in line
    ):
        return True
    if path == "dart/test/uniform_binding_contract_test.dart" and (
        "selector-rejection fixture" in line
    ):
        return True
    if path == "julia/test/uniform_binding_contract_test.jl" and (
        "selector-rejection fixture" in line
    ):
        return True
    if path == "lua/test/run.lua" and "selector-rejection fixture" in line:
        return True
    return False


def scan_files(relative_paths: list[str]) -> tuple[list[str], int]:
    positive: list[str] = []
    classified = 0
    for relative in relative_paths:
        path = Path(relative)
        if path.suffix in EXCLUDED_SUFFIXES:
            continue
        try:
            lines = (ROOT / path).read_text(encoding="utf-8").splitlines()
        except (UnicodeDecodeError, OSError):
            continue
        for number, line in enumerate(lines, start=1):
            if not SELECTOR.search(line):
                continue
            if classified_compatibility(relative, line):
                classified += 1
            else:
                positive.append(f"{relative}:{number}:{line.strip()}")
    return positive, classified


def self_test_untracked_discovery() -> None:
    probe_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            prefix="aggregate_selector_untracked_probe_",
            suffix=".dart",
            dir=ROOT / "dart" / "test",
            delete=False,
        ) as probe:
            probe.write("void main() { " + "array(" + "items); }\n")
            probe_path = Path(probe.name)

        relative = probe_path.relative_to(ROOT).as_posix()
        discovered = candidate_files()
        if relative not in discovered:
            raise RuntimeError(
                "nonignored untracked executable-source probe was not discovered"
            )
        positive, _ = scan_files([relative])
        if not positive:
            raise RuntimeError(
                "untracked executable aggregate-selector probe was not rejected"
            )
    finally:
        if probe_path is not None:
            probe_path.unlink(missing_ok=True)


def main() -> int:
    try:
        self_test_untracked_discovery()
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        print(
            f"executable-aggregate-selector-scan: discovery self-test failed: {error}",
            file=sys.stderr,
        )
        return 1

    positive, classified = scan_files(candidate_files())

    if positive:
        print(
            "executable-aggregate-selector-scan: positive selector source remains",
            file=sys.stderr,
        )
        print("\n".join(positive), file=sys.stderr)
        return 1

    print(
        "executable-aggregate-selector-scan: OK "
        f"(0 positive; {classified} classified implementation/recognition occurrences; "
        "tracked+untracked discovery self-test passed)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

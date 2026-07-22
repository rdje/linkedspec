#!/usr/bin/env python3
"""Reject positive embedded one-identifier aggregate-selector spec sources."""

from __future__ import annotations

import fcntl
import os
import re
import subprocess
import sys
import tempfile
import time
from contextlib import contextmanager
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LOCK_DIRECTORY = ROOT / "dart" / ".dart_tool"
SCAN_LOCK_PATH = LOCK_DIRECTORY / "aggregate_selector_scan.lock"
CONCURRENCY_LOCK_PATH = LOCK_DIRECTORY / "aggregate_selector_concurrency.lock"
PROBE_DIRECTORY = ROOT
PROBE_PREFIX = "aggregate_selector_untracked_probe_"
TEST_HOLD_ENV = "_LINKEDSPEC_SELECTOR_PROBE_HOLD_SECONDS"
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


@contextmanager
def advisory_lock(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a+b") as lock:
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(lock.fileno(), fcntl.LOCK_UN)


@contextmanager
def serialized_scan():
    """Keep each probe alive through its owning final repository scan."""
    with advisory_lock(SCAN_LOCK_PATH):
        yield


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
            prefix=PROBE_PREFIX,
            suffix=".dart",
            dir=PROBE_DIRECTORY,
            delete=False,
        ) as probe:
            probe.write("void main() { " + "array(" + "items); }\n")
            probe_path = Path(probe.name)

        hold_seconds = os.environ.get(TEST_HOLD_ENV)
        if hold_seconds is not None:
            hold = float(hold_seconds)
            if not 0 <= hold <= 1:
                raise ValueError(f"invalid self-test probe hold: {hold_seconds!r}")
            time.sleep(hold)

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


def run_scan() -> int:
    with serialized_scan():
        try:
            self_test_untracked_discovery()
        except (OSError, RuntimeError, subprocess.SubprocessError, ValueError) as error:
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
            "serialized tracked+untracked discovery self-test passed)"
        )
        return 0


def self_test_concurrent_invocations() -> int:
    if PROBE_DIRECTORY != ROOT:
        print(
            "executable-aggregate-selector-concurrency: probe must remain outside backend packages",
            file=sys.stderr,
        )
        return 1

    with advisory_lock(CONCURRENCY_LOCK_PATH):
        processes: list[subprocess.Popen[str]] = []
        for hold_seconds in ("0.2", "0.4", "0.6"):
            environment = os.environ.copy()
            environment[TEST_HOLD_ENV] = hold_seconds
            processes.append(
                subprocess.Popen(
                    [sys.executable, __file__],
                    cwd=ROOT,
                    env=environment,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                )
            )

        failed = False
        for process in processes:
            stdout, stderr = process.communicate()
            if process.returncode != 0:
                failed = True
                sys.stdout.write(stdout)
                sys.stderr.write(stderr)

        with serialized_scan():
            leftovers = sorted(ROOT.glob(f"{PROBE_PREFIX}*.dart")) + sorted(
                (ROOT / "dart" / "test").glob(f"{PROBE_PREFIX}*.dart")
            )
        if leftovers:
            failed = True
            print(
                "executable-aggregate-selector-concurrency: leftover probe(s): "
                + ", ".join(
                    path.relative_to(ROOT).as_posix() for path in leftovers
                ),
                file=sys.stderr,
            )
        if failed:
            return 1

        print(
            "executable-aggregate-selector-concurrency: OK "
            "(3 staggered concurrent scans serialized; repository-root probes cleaned)"
        )
        return 0


def main() -> int:
    try:
        if sys.argv[1:] == ["--concurrency-self-test"]:
            return self_test_concurrent_invocations()
        if sys.argv[1:]:
            print(
                "usage: check_executable_aggregate_selector_sources.py "
                "[--concurrency-self-test]",
                file=sys.stderr,
            )
            return 2
        return run_scan()
    except OSError as error:
        print(
            f"executable-aggregate-selector-scan: operational failure: {error}",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

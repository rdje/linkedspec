#!/usr/bin/env python3
"""Reject positive embedded one-identifier aggregate-selector spec sources."""

from __future__ import annotations

import fcntl
import hashlib
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
# These immutable diagnostic inputs preserve an actual rejected experiment and
# its historical claim description. Classify only their exact path and bytes;
# a copied file, edited input or added selector remains a positive candidate.
HISTORICAL_DIAGNOSTIC_INPUTS = {
    # Exact retained private callback probes/assertions and public rejection controls.
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-fixture-first.t':
        '50bb888f666f12b1ac1b6afb1e223b12a2a6328fe8d338593e0b44d74adc8f15',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-native-review.py':
        'fc566e989e964e4d71889a62480fbe6c42682dd84c2cdfc66339c7b428da6226',
    't/actionir_small_kind_capture.t':
        '050ea5f3080c8e3a79eb8004304a947ab483ad9340a0b55abbb58f558f8d5b73',
    't/actionir_small_kind_probe.pl':
        'c68299cd8fb21b1ccf79124a7bbdc74d080ec0e3a24a8bd4ac606f4d66398aa4',
    't/actionir_small_kind_symbolic_probe.pl':
        '8a7fd07c525a028f5d691a9a2b934f18c3791de83a8ce3ed682e36d469998033',
    't/actionir_source_assignment_kind_capture.t':
        'cff593511e74933836c2dd0af2917e14a33bb3ab6421853a72d6de1182b1f872',
    't/actionir_source_assignment_kind_probe.pl':
        'fcc8cc26c86597dc40d64df459e2d61f12849c9d84d954b8efbcd5f85f6899fa',
    't/actionir_uniform_target_probe.pl':
        '874b0be404db0d8d5d55c58186ecc5eac1b9eb228d12b542b2ac36a07f08a536',
    # Private array-end parser injection controls, including the compile-failed
    # native draft. These do not exercise public authoring acceptance.
    't/actionir_array_end_required_probe.pl':
        'd7c252a466ecee426ed0a8e0ab264b66d550419fffa7dcdf55d17b22a65e1d80',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-native-draft-probe.pl':
        '3c342cb0dc647a573922305d3d2e94e697de4cf18c504ad29eef25a1cbf75d36',
    "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-claim.py":
        "52a83a6bb01129e7f0c96f594a6e85bb2f25cedfbd86d91853a3e620b92bb90e",
    "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-split-probe-initial.pl":
        "1f96bcb1dd60201a602282b576074b0ab3abfd77fcf006ab16417bc25d8627c3",
    # Exact negative/private synthetic fixtures; any byte edit or copied path rejects.
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-alias-draft.t':
        'a8df7205e161079dbe613cea241ca44d4ab41a394008d683aa40192b98edc9b8',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-draft-fixture.t':
        'd7bfd7224b3061469372af170a1ab173a74c9e009b2a9f666d82cc5058522d32',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-initial-fixture.t':
        'd33c8de6d0ba7ed1062dbb640d4ca59d6a4581c9ef8ef5a26b6448b5871ca328',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-loading-draft.t':
        'edfa5a28612fd070da0dfe6ad1977b599582c2568f8640ad1b71909acf2e5120',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-review.py':
        'e88b76a38bfe15eb3f47f769cd1c93700f3e6b9faae742bcb2414fd26a20885b',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2-review.py':
        '0fb2e4ab144a39abc5ba82b4653a9a4c4f5bfeaf6d6d3655d07f6f1eebf4c02e',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0-review.py':
        '5afef5f1bac33fcb965c1099d1c742d047d80c5b4ee1bb03b1a729b5f0173144',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1-initial-probe/actionir_method_push_required_capture.t':
        '06db7781a2b3e22164231234cc53c6cfeca3357d08050730cf243c5f67db0429',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1-review.py':
        '700ce617ca4b57dcb78bf50fd1cba31be80b55bef4bc742e432e150d40172ba8',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-book-repair/census/proof.py':
        '0ef00dd86ea82d2b9a3ed193aa4b8e7e772ec7f96a80c938fabf55532998db99',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-book-repair/selector-proof-draft.py':
        '4712a89a636b0f0348330d8c69176616c336170cb157ffd54bcf4866ef92cf35',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-book-repair/selector-proof.py':
        'ba8df149c3cee886eb2abdd90cdd34e3ddddd184eaf2eb77610ee98bc7bd0e20',
    't/actionir_method_assignment_required_capture.t':
        '46e2ea2edd6fe99255af1375725a10db4a90be291db8bcae07c6360d133d5505',
    't/actionir_method_general_return_capture.t':
        '79e1a62864441c368e76e393aac9a29907b82e1a28600e5429ec3c0ba99fb4bf',
    't/actionir_method_push_required_capture.t':
        '765c036df9bc0842d398221fc0a8f15aafc4398dfa81f5ad8b402c084e49c384',
    't/actionir_method_set_key_required_capture.t':
        'f065c51628152d04b137ac6bf5f66739653703f6b69d4d51cc0e194d5e1b6803',
    't/actionir_method_value_capture.t':
        '9e9e1d9ab525d387ae3d1689a1c1465dab08f39ecccb78868ad62cee6ed50269',
}
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
    historical_digest = HISTORICAL_DIAGNOSTIC_INPUTS.get(path)
    if historical_digest is not None:
        return hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == historical_digest
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
    if path == "lua/test/semantic_index_compilation_foundation_test.lua" and (
        "selector-rejection fixture" in line
    ):
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

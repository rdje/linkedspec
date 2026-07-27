#!/usr/bin/env python3
"""Validate and independently execute LinkedSpec's Unicode casing contract."""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "unicode_case_contract.json"
GENERATOR = ROOT / "unicode_case" / "generate_unicode_case_contract.py"
PERL_MODULE_PATH = ROOT / "perl" / "LinkedSpec" / "UnicodeCaseMapping.pm"
RUST_MODULE_PATH = ROOT / "rust" / "linkedspec-runtime" / "src" / "unicode_case_mapping.rs"
DART_MODULE_PATH = ROOT / "dart" / "lib" / "src" / "runtime" / "unicode_case_mapping.dart"
JULIA_MODULE_PATH = ROOT / "julia" / "src" / "runtime" / "UnicodeCaseMapping.jl"
LUA_MODULE_PATH = ROOT / "lua" / "src" / "linkedspec" / "unicode_case_mapping.lua"
TASK_PATH = ROOT / "docs" / "tasks" / "LUA-BACKEND-PARITY.md"


def fail(message: str) -> None:
    raise SystemExit(f"unicode-case-contract: ERROR: {message}")


def managed_temp_root() -> Path:
    default = ROOT / ".linkedspec-data" / "scratch" / "tmp"
    initialized_root = os.environ.get("LINKEDSPEC_REPO_ROOT")
    if initialized_root and Path(initialized_root).resolve() != ROOT:
        fail(f"project-data initializer belongs to another checkout: {initialized_root}")
    candidate = Path(os.environ.get("TMPDIR", str(default))) if initialized_root else default
    if not candidate.is_absolute():
        candidate = Path.cwd() / candidate
    component = Path(candidate.anchor)
    for part in candidate.parts[1:]:
        component /= part
        if component.is_symlink():
            fail(f"temporary root contains a symlink: {component}")
    ancestor = candidate
    while not ancestor.exists() and not ancestor.is_symlink():
        if ancestor.parent == ancestor:
            fail(f"cannot resolve temporary root {candidate}")
        ancestor = ancestor.parent
    if ancestor.is_symlink() or not ancestor.is_dir():
        fail(f"temporary root has a symlink or non-directory ancestor: {ancestor}")
    if ancestor.resolve().stat().st_dev != ROOT.stat().st_dev:
        fail(f"temporary root is outside the repository filesystem: {candidate}")
    candidate.mkdir(parents=True, exist_ok=True)
    if candidate.is_symlink() or candidate.resolve().stat().st_dev != ROOT.stat().st_dev:
        fail(f"temporary root is not safe repository-filesystem storage: {candidate}")
    return candidate.resolve()


def require_scalar(codepoint: int, where: str) -> None:
    if codepoint < 0 or codepoint > 0x10FFFF or 0xD800 <= codepoint <= 0xDFFF:
        fail(f"{where} is not a Unicode scalar value")


def parse_mapping(rows: object, label: str) -> dict[int, tuple[int, ...]]:
    if not isinstance(rows, list):
        fail(f"{label} must be an array")
    result: dict[int, tuple[int, ...]] = {}
    prior = -1
    for index, row in enumerate(rows):
        if not isinstance(row, list) or len(row) != 2 or not isinstance(row[0], str):
            fail(f"{label}[{index}] must be [hex, [hex...]]")
        codepoint = int(row[0], 16)
        require_scalar(codepoint, f"{label}[{index}] codepoint")
        if codepoint <= prior:
            fail(f"{label} must be strictly sorted and unique")
        if not isinstance(row[1], list) or not row[1] or not all(isinstance(value, str) for value in row[1]):
            fail(f"{label}[{index}] mapping must be a nonempty hex array")
        mapping = tuple(int(value, 16) for value in row[1])
        for mapped_index, value in enumerate(mapping):
            require_scalar(value, f"{label}[{index}] mapping[{mapped_index}]")
        result[codepoint] = mapping
        prior = codepoint
    return result


def parse_ranges(rows: object, label: str) -> list[tuple[int, int]]:
    if not isinstance(rows, list):
        fail(f"{label} must be an array")
    result: list[tuple[int, int]] = []
    prior_end = -2
    for index, row in enumerate(rows):
        if not isinstance(row, list) or len(row) != 2 or not all(isinstance(value, str) for value in row):
            fail(f"{label}[{index}] must be [start_hex, end_hex]")
        start, end = (int(value, 16) for value in row)
        require_scalar(start, f"{label}[{index}] start")
        require_scalar(end, f"{label}[{index}] end")
        if start > end or start <= prior_end + 1:
            fail(f"{label} must contain sorted, disjoint, maximally merged ranges")
        result.append((start, end))
        prior_end = end
    return result


def contains(ranges: list[tuple[int, int]], codepoint: int) -> bool:
    low = 0
    high = len(ranges)
    while low < high:
        middle = (low + high) // 2
        start, end = ranges[middle]
        if codepoint < start:
            high = middle
        elif codepoint > end:
            low = middle + 1
        else:
            return True
    return False


def final_sigma(text: str, index: int, cased: list[tuple[int, int]], ignorable: list[tuple[int, int]]) -> bool:
    before = index - 1
    while before >= 0 and contains(ignorable, ord(text[before])):
        before -= 1
    if before < 0 or not contains(cased, ord(text[before])):
        return False
    after = index + 1
    while after < len(text) and contains(ignorable, ord(text[after])):
        after += 1
    return after >= len(text) or not contains(cased, ord(text[after]))


def convert(
    text: str,
    mappings: dict[int, tuple[int, ...]],
    cased: list[tuple[int, int]],
    ignorable: list[tuple[int, int]],
    lowercase: bool,
) -> str:
    output: list[str] = []
    for index, character in enumerate(text):
        codepoint = ord(character)
        mapping = (0x03C2,) if lowercase and codepoint == 0x03A3 and final_sigma(
            text, index, cased, ignorable
        ) else mappings.get(codepoint, (codepoint,))
        output.extend(chr(value) for value in mapping)
    return "".join(output)


def main() -> None:
    if not CONTRACT_PATH.is_file():
        fail(f"missing {CONTRACT_PATH.relative_to(ROOT)}")
    with tempfile.TemporaryDirectory(
        prefix="linkedspec-unicode-case-", dir=managed_temp_root()
    ) as directory:
        regenerated = Path(directory) / "unicode_case_contract.json"
        regenerated_perl = Path(directory) / "UnicodeCaseMapping.pm"
        regenerated_rust = Path(directory) / "unicode_case_mapping.rs"
        regenerated_dart = Path(directory) / "unicode_case_mapping.dart"
        regenerated_julia = Path(directory) / "UnicodeCaseMapping.jl"
        regenerated_lua = Path(directory) / "unicode_case_mapping.lua"
        completed = subprocess.run(
            [
                sys.executable,
                str(GENERATOR),
                "--output",
                str(regenerated),
                "--perl-output",
                str(regenerated_perl),
                "--rust-output",
                str(regenerated_rust),
                "--dart-output",
                str(regenerated_dart),
                "--julia-output",
                str(regenerated_julia),
                "--lua-output",
                str(regenerated_lua),
            ],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if completed.returncode != 0:
            fail(f"generator failed: {completed.stderr.strip() or completed.stdout.strip()}")
        if regenerated.read_bytes() != CONTRACT_PATH.read_bytes():
            fail("checked contract is stale; run unicode_case/generate_unicode_case_contract.py")
        for label, generated, checked in (
            ("Perl", regenerated_perl, PERL_MODULE_PATH),
            ("Rust", regenerated_rust, RUST_MODULE_PATH),
            ("Dart", regenerated_dart, DART_MODULE_PATH),
            ("Julia", regenerated_julia, JULIA_MODULE_PATH),
            ("Lua", regenerated_lua, LUA_MODULE_PATH),
        ):
            if not checked.is_file():
                fail(f"missing generated {label} casing module: {checked.relative_to(ROOT)}")
            if generated.read_bytes() != checked.read_bytes():
                fail(f"checked {label} casing module is stale; run {GENERATOR.relative_to(ROOT)}")

    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    required = {
        "schema_version",
        "contract_id",
        "task_owner",
        "unicode_version",
        "algorithm",
        "sources",
        "data_sha256",
        "counts",
        "lower_mappings",
        "upper_mappings",
        "cased_ranges",
        "case_ignorable_ranges",
        "context_rules",
        "fixtures",
    }
    if set(contract) != required:
        fail(f"contract keys differ: expected {sorted(required)}, got {sorted(contract)}")
    if contract["schema_version"] != 1 or contract["contract_id"] != "linkedspec-unicode-case-v1":
        fail("schema/contract identity mismatch")
    if contract["unicode_version"] != "17.0.0":
        fail("Unicode version must be 17.0.0")
    if contract["task_owner"] not in TASK_PATH.read_text(encoding="utf-8"):
        fail("task owner is not tracked")
    expected_algorithm = {
        "name": "Unicode Default Case Conversion",
        "operations": ["toLowercase_R2", "toUppercase_R1"],
        "mapping_kind": "full",
        "locale_tailoring": False,
        "context_rules": ["Final_Sigma"],
        "normalization": "none",
        "logical_text_model": "unicode_scalar_values",
    }
    if contract["algorithm"] != expected_algorithm:
        fail("algorithm policy differs from ADR 0027")

    lower = parse_mapping(contract["lower_mappings"], "lower_mappings")
    upper = parse_mapping(contract["upper_mappings"], "upper_mappings")
    cased = parse_ranges(contract["cased_ranges"], "cased_ranges")
    ignorable = parse_ranges(contract["case_ignorable_ranges"], "case_ignorable_ranges")
    if contract["context_rules"] != [
        {"codepoint": "03A3", "condition": "Final_Sigma", "lower": ["03C2"]}
    ]:
        fail("default context-rule inventory differs")
    counts = contract["counts"]
    actual_counts = {
        "lower_mappings": len(lower),
        "upper_mappings": len(upper),
        "cased_ranges": len(cased),
        "case_ignorable_ranges": len(ignorable),
        "context_rules": len(contract["context_rules"]),
        "fixtures": len(contract["fixtures"]),
    }
    if counts != actual_counts:
        fail(f"count metadata differs: expected {actual_counts}, got {counts}")
    payload = {
        "lower_mappings": contract["lower_mappings"],
        "upper_mappings": contract["upper_mappings"],
        "cased_ranges": contract["cased_ranges"],
        "case_ignorable_ranges": contract["case_ignorable_ranges"],
        "context_rules": contract["context_rules"],
    }
    digest = hashlib.sha256(
        json.dumps(payload, ensure_ascii=True, separators=(",", ":"), sort_keys=True).encode()
    ).hexdigest()
    if digest != contract["data_sha256"]:
        fail("logical data SHA-256 differs")
    fixture_ids: set[str] = set()
    for fixture in contract["fixtures"]:
        if set(fixture) != {"id", "input", "lower", "upper"}:
            fail("fixture shape differs")
        if not all(isinstance(fixture[key], str) for key in fixture):
            fail("fixture fields must be strings")
        if not fixture["id"] or fixture["id"] in fixture_ids:
            fail("fixture ids must be nonempty and unique")
        fixture_ids.add(fixture["id"])
        actual_lower = convert(fixture["input"], lower, cased, ignorable, lowercase=True)
        actual_upper = convert(fixture["input"], upper, cased, ignorable, lowercase=False)
        if actual_lower != fixture["lower"] or actual_upper != fixture["upper"]:
            fail(f"fixture {fixture['id']} execution differs")
    print(
        "unicode-case-contract: OK "
        f"(Unicode {contract['unicode_version']}; {len(lower)} lower; {len(upper)} upper; "
        f"{len(cased)}/{len(ignorable)} property ranges; {len(contract['fixtures'])} fixtures)"
    )


if __name__ == "__main__":
    main()

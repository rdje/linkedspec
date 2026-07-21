#!/usr/bin/env python3
"""Validate the pinned Unicode rule-label contract and generated Rust table."""

from __future__ import annotations

import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "unicode_rule_label_contract.json"
RUST_PATH = ROOT / "rust" / "linkedspec-core" / "src" / "unicode_rule_label.rs"
SELF_HOSTED_REGEX_PATH = ROOT / "unicode_case" / "unicode_rule_label_regex_class.txt"
GENERATOR = ROOT / "unicode_case" / "generate_unicode_rule_label_contract.py"
FORMAL_GRAMMAR = ROOT / "docs" / "linkedspec-book" / "src" / "appendix" / "formal-grammar.md"
PARSER_PATH = ROOT / "rust" / "linkedspec-core" / "src" / "parser.rs"
VALIDATION_PATH = ROOT / "rust" / "linkedspec-core" / "src" / "validation.rs"
CORE_TEST_PATH = ROOT / "rust" / "linkedspec-core" / "tests" / "unicode_rule_label_contract.rs"
RUNTIME_TEST_PATH = (
    ROOT / "rust" / "linkedspec-runtime" / "tests" / "unicode_rule_label_routes.rs"
)
CI_PATH = ROOT / "tools" / "run_ci_local.sh"


def fail(message: str) -> None:
    raise SystemExit(f"unicode-rule-label-contract: ERROR: {message}")


def contains(ranges: list[tuple[int, int]], codepoint: int) -> bool:
    low, high = 0, len(ranges)
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


def valid_label(ranges: list[tuple[int, int]], label: str) -> bool:
    return bool(label) and all(contains(ranges, ord(character)) for character in label)


def render_self_hosted_regex_class(ranges: list[tuple[int, int]]) -> str:
    pieces: list[str] = []
    for start, end in ranges:
        pieces.append(chr(start))
        if start != end:
            pieces.extend(("-", chr(end)))
    return "[" + "".join(pieces) + "]+"


def main() -> None:
    for path in (
        CONTRACT_PATH,
        RUST_PATH,
        SELF_HOSTED_REGEX_PATH,
        GENERATOR,
        CORE_TEST_PATH,
        RUNTIME_TEST_PATH,
    ):
        if not path.is_file():
            fail(f"missing {path.relative_to(ROOT)}")
    with tempfile.TemporaryDirectory(prefix="linkedspec-unicode-label-") as temp:
        generated_contract = Path(temp) / "contract.json"
        generated_rust = Path(temp) / "unicode_rule_label.rs"
        generated_self_hosted_regex = Path(temp) / "unicode_rule_label_regex_class.txt"
        subprocess.run(
            [
                sys.executable,
                str(GENERATOR),
                "--contract-output",
                str(generated_contract),
                "--rust-output",
                str(generated_rust),
                "--self-hosted-regex-output",
                str(generated_self_hosted_regex),
            ],
            cwd=ROOT,
            check=True,
        )
        if generated_contract.read_bytes() != CONTRACT_PATH.read_bytes():
            fail("contract differs from deterministic regeneration")
        if generated_rust.read_bytes() != RUST_PATH.read_bytes():
            fail("Rust classifier differs from deterministic regeneration")
        if generated_self_hosted_regex.read_bytes() != SELF_HOSTED_REGEX_PATH.read_bytes():
            fail("self-hosted regex class differs from deterministic regeneration")

    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    expected_top = {
        "schema_version",
        "contract_id",
        "task_owner",
        "decision",
        "unicode_version",
        "policy",
        "sources",
        "data_sha256",
        "counts",
        "xid_continue_ranges",
        "positive_fixtures",
        "negative_fixtures",
        "distinct_fixtures",
    }
    if set(contract) != expected_top:
        fail("top-level fields drifted")
    if contract["contract_id"] != "linkedspec-unicode-rule-label-v1":
        fail("contract identity drifted")
    if contract["unicode_version"] != "17.0.0":
        fail("Unicode version drifted")
    if contract["policy"] != {
        "property": "XID_Continue",
        "positions": "one_or_more_same_class_including_first",
        "identity": "exact_unicode_scalar_sequence",
        "case_sensitive": True,
        "normalization": "none",
        "case_mapping": "none",
        "encoding_boundary": "strict_utf8",
    }:
        fail("label policy drifted")

    ranges: list[tuple[int, int]] = []
    prior_end = -2
    for index, row in enumerate(contract["xid_continue_ranges"]):
        if not isinstance(row, list) or len(row) != 2:
            fail(f"range {index} shape drifted")
        start, end = (int(value, 16) for value in row)
        if start > end or start <= prior_end + 1 or end > 0x10FFFF:
            fail(f"range {index} is not sorted, disjoint, and maximally merged")
        ranges.append((start, end))
        prior_end = end
    counts = contract["counts"]
    if counts["xid_continue_ranges"] != len(ranges):
        fail("range count drifted")
    for unsafe in ("\\", "/", "[", "]", "^", "-", "\n", "\r", "\0"):
        if contains(ranges, ord(unsafe)):
            fail(f"self-hosted literal regex class requires escaping for {unsafe!r}")

    expected_class = render_self_hosted_regex_class(ranges)
    expected_artifact = (
        "# Generated pinned Unicode rule-label regex class. Do not edit by hand.\n"
        f"# contract: {contract['contract_id']}\n"
        f"# unicode: {contract['unicode_version']}\n"
        f"# data-sha256: {contract['data_sha256']}\n"
        f"{expected_class}\n"
    )
    actual_artifact = SELF_HOSTED_REGEX_PATH.read_text(encoding="utf-8", errors="strict")
    if actual_artifact != expected_artifact:
        fail("self-hosted regex artifact does not independently encode the contract ranges")
    compiled_class = re.compile(rf"^(?:{expected_class})$")
    for row in contract["positive_fixtures"]:
        if not valid_label(ranges, row["label"]):
            fail(f"positive fixture rejected: {row['id']}")
        if compiled_class.fullmatch(row["label"]) is None:
            fail(f"self-hosted regex rejects positive fixture: {row['id']}")
    for row in contract["negative_fixtures"]:
        if valid_label(ranges, row["label"]):
            fail(f"negative fixture accepted: {row['id']}")
        if compiled_class.fullmatch(row["label"]) is not None:
            fail(f"self-hosted regex accepts negative fixture: {row['id']}")
    for row in contract["distinct_fixtures"]:
        if not valid_label(ranges, row["left"]) or not valid_label(ranges, row["right"]):
            fail(f"distinct fixture is not valid: {row['id']}")
        if row["left"] == row["right"]:
            fail(f"distinct fixture collapsed: {row['id']}")
        if compiled_class.fullmatch(row["left"]) is None or compiled_class.fullmatch(row["right"]) is None:
            fail(f"self-hosted regex rejects distinct fixture: {row['id']}")

    formal = FORMAL_GRAMMAR.read_text(encoding="utf-8")
    required_formal = [
        "Unicode 17.0.0 `XID_Continue`",
        "case-sensitive and normalization-sensitive",
        "No normalization or case folding is performed",
    ]
    if any(marker not in formal for marker in required_formal):
        fail("formal grammar is not synchronized")
    parser_text = PARSER_PATH.read_text(encoding="utf-8")
    validation_text = VALIDATION_PATH.read_text(encoding="utf-8")
    if "take_rule_label_prefix" not in parser_text or "is_rule_label" not in validation_text:
        fail("Rust parser/validator does not consume the generated label classifier")
    for stale in (
        'r"^(\\w+)[ \\t]*(::|:)"',
        'r"^->[ \\t]*(\\w+)',
        'r"^=>[ \\t]*(\\w+)"',
    ):
        if stale in parser_text:
            fail(f"stale Rust label regex remains: {stale}")
    core_test = CORE_TEST_PATH.read_text(encoding="utf-8")
    for marker in (
        "parser_uses_one_unicode_label_class_for_headers_and_all_edge_forms",
        "validator_rejects_invalid_labels_in_programmatic_asts",
        "exact_scalar_identity_survives_validation_and_compilation",
    ):
        if marker not in core_test:
            fail(f"core route proof missing: {marker}")
    runtime_test = RUNTIME_TEST_PATH.read_text(encoding="utf-8")
    for marker in (
        "native_selector_descriptor_and_trace_keep_exact_scalar_identity",
        "generated_plan_and_emitted_source_keep_unicode_labels_exact",
        "strict_file_loader_accepts_unicode_and_rejects_invalid_utf8_before_parsing",
    ):
        if marker not in runtime_test:
            fail(f"runtime route proof missing: {marker}")
    ci_text = CI_PATH.read_text(encoding="utf-8")
    for marker in (
        "require_tracked_file capability_conformance/unicode_rule_label_contract.json",
        "require_tracked_file tools/check_unicode_rule_label_contract.py",
        "require_tracked_file unicode_case/generate_unicode_rule_label_contract.py",
        "require_tracked_file unicode_case/unicode_rule_label_regex_class.txt",
        "require_tracked_file rust/linkedspec-core/src/unicode_rule_label.rs",
        "require_tracked_file rust/linkedspec-core/tests/unicode_rule_label_contract.rs",
        "require_tracked_file rust/linkedspec-runtime/tests/unicode_rule_label_routes.rs",
        "python3 tools/check_unicode_rule_label_contract.py",
    ):
        if marker not in ci_text:
            fail(f"canonical CI marker missing: {marker}")

    print(
        "unicode-rule-label-contract: OK "
        f"(Unicode {contract['unicode_version']}; {len(ranges)} XID_Continue ranges; "
        f"{len(contract['positive_fixtures'])} positive; "
        f"{len(contract['negative_fixtures'])} negative; "
        f"{len(contract['distinct_fixtures'])} distinct pairs)"
    )


if __name__ == "__main__":
    main()

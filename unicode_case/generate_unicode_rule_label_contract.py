#!/usr/bin/env python3
"""Generate the pinned Unicode rule-label contract and Rust classifier."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path
from typing import Iterable


UNICODE_VERSION = "17.0.0"
CONTRACT_ID = "linkedspec-unicode-rule-label-v1"
TASK_OWNER = "FUTURE-PARITY-BACKLOG.10.4.0.2"
DECISION = "docs/decisions/0051-unicode-17-xid-continue-rule-labels.md"
SOURCE_FILES = {
    "DerivedCoreProperties.txt": {
        "stored": "DerivedCoreProperties.txt.gz",
        "sha256": "24c7fed1195c482faaefd5c1e7eb821c5ee1fb6de07ecdbaa64b56a99da22c08",
        "url": "https://www.unicode.org/Public/17.0.0/ucd/DerivedCoreProperties.txt",
    },
    "LICENSE.txt": {
        "stored": "LICENSE.txt.gz",
        "sha256": "e7a93b009565cfce55919a381437ac4db883e9da2126fa28b91d12732bc53d96",
        "url": "https://www.unicode.org/license.txt",
    },
}
POSITIVE_FIXTURES = (
    ("ascii", "Top"),
    ("ascii_digit_start", "9_rule"),
    ("underscore_only", "_"),
    ("latin_precomposed", "Töp"),
    ("latin_decomposed", "To\u0308p"),
    ("greek", "Δοκιμή"),
    ("cjk", "規則"),
    ("middle_dot_continue", "A·B"),
    ("supplementary", "𐐀Rule"),
)
NEGATIVE_FIXTURES = (
    ("empty", ""),
    ("hyphen", "Top-Rule"),
    ("space", "Top Rule"),
    ("emoji", "Top😀"),
    ("colon", "Top:"),
    ("slash", "Top/Rule"),
    ("dollar", "$Top"),
    ("newline", "Top\nRule"),
)
DISTINCT_FIXTURES = (
    ("case_sensitive", "Töp", "töp"),
    ("normalization_sensitive", "Töp", "To\u0308p"),
)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def verified_sources(upstream: Path) -> tuple[dict[str, dict[str, object]], dict[str, bytes]]:
    metadata: dict[str, dict[str, object]] = {}
    contents: dict[str, bytes] = {}
    for name, expected in SOURCE_FILES.items():
        path = upstream / str(expected["stored"])
        compressed = path.read_bytes()
        try:
            data = gzip.decompress(compressed)
        except OSError as error:
            raise ValueError(f"{path.name} is not valid gzip: {error}") from error
        actual = sha256(data)
        if actual != expected["sha256"]:
            raise ValueError(f"{name} SHA-256 mismatch: expected {expected['sha256']}, got {actual}")
        if name == "DerivedCoreProperties.txt":
            header = data[:256].decode("utf-8", errors="strict")
            if f"-{UNICODE_VERSION}.txt" not in header:
                raise ValueError(f"{name} does not declare Unicode {UNICODE_VERSION}")
        metadata[name] = {
            "bytes": len(data),
            "compressed_bytes": len(compressed),
            "sha256": actual,
            "stored_file": path.name,
            "url": expected["url"],
        }
        contents[name] = data
    return metadata, contents


def merge_ranges(ranges: Iterable[tuple[int, int]]) -> list[tuple[int, int]]:
    merged: list[tuple[int, int]] = []
    for start, end in sorted(ranges):
        if merged and start <= merged[-1][1] + 1:
            merged[-1] = (merged[-1][0], max(merged[-1][1], end))
        else:
            merged.append((start, end))
    return merged


def parse_xid_continue(text: str) -> list[tuple[int, int]]:
    ranges: list[tuple[int, int]] = []
    for line_number, raw in enumerate(text.splitlines(), 1):
        data = raw.split("#", 1)[0].strip()
        if not data:
            continue
        fields = [field.strip() for field in data.split(";")]
        if len(fields) < 2 or fields[1] != "XID_Continue":
            continue
        if len(fields) != 2:
            raise ValueError(
                f"DerivedCoreProperties.txt:{line_number}: malformed XID_Continue record"
            )
        bounds = fields[0].split("..")
        ranges.append((int(bounds[0], 16), int(bounds[-1], 16)))
    merged = merge_ranges(ranges)
    if not merged:
        raise ValueError("DerivedCoreProperties.txt contains no XID_Continue ranges")
    return merged


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


def valid_label(ranges: list[tuple[int, int]], value: str) -> bool:
    return bool(value) and all(contains(ranges, ord(character)) for character in value)


def hex_ranges(ranges: list[tuple[int, int]]) -> list[list[str]]:
    return [[f"{start:04X}", f"{end:04X}"] for start, end in ranges]


def build_contract(upstream: Path) -> dict[str, object]:
    sources, contents = verified_sources(upstream)
    ranges = parse_xid_continue(contents["DerivedCoreProperties.txt"].decode("utf-8", errors="strict"))
    for fixture_id, value in POSITIVE_FIXTURES:
        if not valid_label(ranges, value):
            raise ValueError(f"positive fixture {fixture_id} is not XID_Continue: {value!r}")
    for fixture_id, value in NEGATIVE_FIXTURES:
        if valid_label(ranges, value):
            raise ValueError(f"negative fixture {fixture_id} is unexpectedly valid: {value!r}")
    for fixture_id, left, right in DISTINCT_FIXTURES:
        if not valid_label(ranges, left) or not valid_label(ranges, right) or left == right:
            raise ValueError(f"distinct fixture {fixture_id} is invalid")
    encoded_ranges = hex_ranges(ranges)
    data_sha256 = sha256(
        json.dumps(encoded_ranges, ensure_ascii=True, separators=(",", ":")).encode("ascii")
    )
    return {
        "schema_version": 1,
        "contract_id": CONTRACT_ID,
        "task_owner": TASK_OWNER,
        "decision": DECISION,
        "unicode_version": UNICODE_VERSION,
        "policy": {
            "property": "XID_Continue",
            "positions": "one_or_more_same_class_including_first",
            "identity": "exact_unicode_scalar_sequence",
            "case_sensitive": True,
            "normalization": "none",
            "case_mapping": "none",
            "encoding_boundary": "strict_utf8",
        },
        "sources": sources,
        "data_sha256": data_sha256,
        "counts": {
            "xid_continue_ranges": len(ranges),
            "positive_fixtures": len(POSITIVE_FIXTURES),
            "negative_fixtures": len(NEGATIVE_FIXTURES),
            "distinct_fixtures": len(DISTINCT_FIXTURES),
        },
        "xid_continue_ranges": encoded_ranges,
        "positive_fixtures": [
            {"id": fixture_id, "label": value} for fixture_id, value in POSITIVE_FIXTURES
        ],
        "negative_fixtures": [
            {"id": fixture_id, "label": value} for fixture_id, value in NEGATIVE_FIXTURES
        ],
        "distinct_fixtures": [
            {"id": fixture_id, "left": left, "right": right}
            for fixture_id, left, right in DISTINCT_FIXTURES
        ],
    }


def render_rust_module(ranges: list[tuple[int, int]], data_sha256: str) -> str:
    rows = "\n".join(f"    (0x{start:04X}, 0x{end:04X})," for start, end in ranges)
    return f'''//! Generated pinned Unicode rule-label classifier. Do not edit by hand.
//!
//! Contract: {CONTRACT_ID}; Unicode: {UNICODE_VERSION}; data: {data_sha256}

pub const UNICODE_RULE_LABEL_CONTRACT: &str = "{CONTRACT_ID}";
pub const UNICODE_RULE_LABEL_VERSION: &str = "{UNICODE_VERSION}";
pub const UNICODE_RULE_LABEL_DATA_SHA256: &str =
    "{data_sha256}";

const XID_CONTINUE_RANGES: &[(u32, u32)] = &[
{rows}
];

/// Return whether one scalar is a pinned Unicode 17 XID_Continue label character.
pub fn is_rule_label_char(character: char) -> bool {{
    let codepoint = character as u32;
    XID_CONTINUE_RANGES
        .binary_search_by(|(start, end)| {{
            if codepoint < *start {{
                std::cmp::Ordering::Greater
            }} else if codepoint > *end {{
                std::cmp::Ordering::Less
            }} else {{
                std::cmp::Ordering::Equal
            }}
        }})
        .is_ok()
}}

/// Validate one complete rule label without normalization or case folding.
pub fn is_rule_label(label: &str) -> bool {{
    !label.is_empty() && label.chars().all(is_rule_label_char)
}}

/// Split the longest valid rule-label prefix from a decoded UTF-8 string.
pub fn take_rule_label_prefix(input: &str) -> Option<(&str, &str)> {{
    let mut end = 0;
    for (offset, character) in input.char_indices() {{
        if !is_rule_label_char(character) {{
            break;
        }}
        end = offset + character.len_utf8();
    }}
    (end > 0).then(|| input.split_at(end))
}}
'''


def render_self_hosted_regex_artifact(
    ranges: list[tuple[int, int]], data_sha256: str
) -> str:
    unsafe = {"\\", "/", "[", "]", "^", "-", "\n", "\r", "\0"}
    for character in unsafe:
        if contains(ranges, ord(character)):
            raise ValueError(
                f"XID_Continue includes regex/delimiter character requiring escaping: {character!r}"
            )
    pieces: list[str] = []
    for start, end in ranges:
        pieces.append(chr(start))
        if start != end:
            pieces.extend(("-", chr(end)))
    regex_class = "[" + "".join(pieces) + "]+"
    return (
        "# Generated pinned Unicode rule-label regex class. Do not edit by hand.\n"
        f"# contract: {CONTRACT_ID}\n"
        f"# unicode: {UNICODE_VERSION}\n"
        f"# data-sha256: {data_sha256}\n"
        f"{regex_class}\n"
    )


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--upstream",
        type=Path,
        default=root / "unicode_case" / "upstream" / UNICODE_VERSION,
    )
    parser.add_argument(
        "--contract-output",
        type=Path,
        default=root / "capability_conformance" / "unicode_rule_label_contract.json",
    )
    parser.add_argument(
        "--rust-output",
        type=Path,
        default=root / "rust" / "linkedspec-core" / "src" / "unicode_rule_label.rs",
    )
    parser.add_argument(
        "--self-hosted-regex-output",
        type=Path,
        default=root / "unicode_case" / "unicode_rule_label_regex_class.txt",
    )
    args = parser.parse_args()
    contract = build_contract(args.upstream)
    ranges = [
        (int(start, 16), int(end, 16)) for start, end in contract["xid_continue_ranges"]
    ]
    contract_text = json.dumps(contract, ensure_ascii=True, indent=2, sort_keys=False) + "\n"
    rust_text = render_rust_module(ranges, str(contract["data_sha256"]))
    self_hosted_regex_text = render_self_hosted_regex_artifact(
        ranges, str(contract["data_sha256"])
    )
    args.contract_output.parent.mkdir(parents=True, exist_ok=True)
    args.rust_output.parent.mkdir(parents=True, exist_ok=True)
    args.self_hosted_regex_output.parent.mkdir(parents=True, exist_ok=True)
    args.contract_output.write_text(contract_text, encoding="utf-8")
    args.rust_output.write_text(rust_text, encoding="utf-8")
    args.self_hosted_regex_output.write_text(self_hosted_regex_text, encoding="utf-8")


if __name__ == "__main__":
    main()

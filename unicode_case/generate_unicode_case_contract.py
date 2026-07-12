#!/usr/bin/env python3
"""Generate LinkedSpec's pinned Unicode casing contract from verified UCD inputs."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path
from typing import Iterable


UNICODE_VERSION = "17.0.0"
CONTRACT_ID = "linkedspec-unicode-case-v1"
TASK_OWNER = "LUA-BACKEND-PARITY.4.3.2.1.2"
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
    "SpecialCasing.txt": {
        "stored": "SpecialCasing.txt.gz",
        "sha256": "efc25faf19de21b92c1194c111c932e03d2a5eaf18194e33f1156e96de4c9588",
        "url": "https://www.unicode.org/Public/17.0.0/ucd/SpecialCasing.txt",
    },
    "UnicodeData.txt": {
        "stored": "UnicodeData.txt.gz",
        "sha256": "2e1efc1dcb59c575eedf5ccae60f95229f706ee6d031835247d843c11d96470c",
        "url": "https://www.unicode.org/Public/17.0.0/ucd/UnicodeData.txt",
    },
}


FIXTURES = (
    ("ascii_and_identity", "Hello 123 😀", "hello 123 😀", "HELLO 123 😀"),
    ("sharp_s_expansion", "Straße", "straße", "STRASSE"),
    ("dotted_i_combining", "İ", "i\u0307", "İ"),
    ("ffi_ligature", "ﬃ", "ﬃ", "FFI"),
    ("deseret_supplementary", "𐐀𐐨", "𐐨𐐨", "𐐀𐐀"),
    ("final_sigma_terminal", "ΟΣ", "ος", "ΟΣ"),
    ("sigma_not_final", "ΟΣΑ", "οσα", "ΟΣΑ"),
    ("sigma_without_cased_before", "Σ", "σ", "Σ"),
    ("final_sigma_ignorable_after", "ΟΣ\u0301", "ος\u0301", "ΟΣ\u0301"),
    ("sigma_ignorable_before_cased", "ΟΣ\u0301Α", "οσ\u0301α", "ΟΣ\u0301Α"),
    ("final_sigma_ignorable_before", "A'Σ", "a'ς", "A'Σ"),
    ("no_implicit_normalization", "A\u030a", "a\u030a", "A\u030a"),
)


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _verified_sources(upstream: Path) -> dict[str, dict[str, object]]:
    result: dict[str, dict[str, object]] = {}
    for name, metadata in SOURCE_FILES.items():
        path = upstream / str(metadata["stored"])
        compressed = path.read_bytes()
        try:
            data = gzip.decompress(compressed)
        except OSError as error:
            raise ValueError(f"{path.name} is not valid gzip: {error}") from error
        actual = _sha256(data)
        if actual != metadata["sha256"]:
            raise ValueError(f"{name} SHA-256 mismatch: expected {metadata['sha256']}, got {actual}")
        if name in {"SpecialCasing.txt", "DerivedCoreProperties.txt"}:
            header = data[:256].decode("utf-8", errors="strict")
            if f"-{UNICODE_VERSION}.txt" not in header:
                raise ValueError(f"{name} does not declare Unicode {UNICODE_VERSION}")
        result[name] = {
            "bytes": len(data),
            "compressed_bytes": len(compressed),
            "sha256": actual,
            "stored_file": path.name,
            "url": metadata["url"],
        }
    return result


def _source_text(upstream: Path, name: str) -> str:
    metadata = SOURCE_FILES[name]
    return gzip.decompress((upstream / str(metadata["stored"])).read_bytes()).decode("utf-8", errors="strict")


def _mapping(codepoints: str) -> tuple[int, ...]:
    return tuple(int(value, 16) for value in codepoints.split()) if codepoints else ()


def _parse_unicode_data(text: str) -> tuple[dict[int, tuple[int, ...]], dict[int, tuple[int, ...]]]:
    lower: dict[int, tuple[int, ...]] = {}
    upper: dict[int, tuple[int, ...]] = {}
    for line_number, raw in enumerate(text.splitlines(), 1):
        fields = raw.split(";")
        if len(fields) != 15:
            raise ValueError(f"UnicodeData.txt:{line_number}: expected 15 fields, got {len(fields)}")
        codepoint = int(fields[0], 16)
        if fields[12]:
            upper[codepoint] = (int(fields[12], 16),)
        if fields[13]:
            lower[codepoint] = (int(fields[13], 16),)
    return lower, upper


def _parse_special_casing(
    text: str,
    lower: dict[int, tuple[int, ...]],
    upper: dict[int, tuple[int, ...]],
) -> list[dict[str, object]]:
    context_rules: list[dict[str, object]] = []
    ignored_conditions: set[str] = set()
    for line_number, raw in enumerate(text.splitlines(), 1):
        data = raw.split("#", 1)[0].strip()
        if not data:
            continue
        fields = [field.strip() for field in data.split(";")]
        if len(fields) not in {5, 6} or fields[-1] != "":
            raise ValueError(f"SpecialCasing.txt:{line_number}: malformed record")
        codepoint = int(fields[0], 16)
        lower_mapping = _mapping(fields[1])
        upper_mapping = _mapping(fields[3])
        condition = fields[4] if len(fields) == 6 else ""
        if not condition:
            lower[codepoint] = lower_mapping
            upper[codepoint] = upper_mapping
        elif condition == "Final_Sigma":
            context_rules.append(
                {
                    "codepoint": f"{codepoint:04X}",
                    "condition": condition,
                    "lower": [f"{value:04X}" for value in lower_mapping],
                }
            )
        else:
            ignored_conditions.add(condition)
    expected_ignored = {
        "az",
        "az After_I",
        "az Not_Before_Dot",
        "lt",
        "lt After_Soft_Dotted",
        "lt More_Above",
        "tr",
        "tr After_I",
        "tr Not_Before_Dot",
    }
    if ignored_conditions != expected_ignored:
        raise ValueError(
            "SpecialCasing locale/context inventory changed: "
            f"expected {sorted(expected_ignored)}, got {sorted(ignored_conditions)}"
        )
    if context_rules != [{"codepoint": "03A3", "condition": "Final_Sigma", "lower": ["03C2"]}]:
        raise ValueError(f"unexpected default context rules: {context_rules}")
    return context_rules


def _merge_ranges(ranges: Iterable[tuple[int, int]]) -> list[tuple[int, int]]:
    merged: list[tuple[int, int]] = []
    for start, end in sorted(ranges):
        if merged and start <= merged[-1][1] + 1:
            merged[-1] = (merged[-1][0], max(merged[-1][1], end))
        else:
            merged.append((start, end))
    return merged


def _parse_properties(text: str) -> dict[str, list[tuple[int, int]]]:
    wanted = {"Cased": [], "Case_Ignorable": []}
    for line_number, raw in enumerate(text.splitlines(), 1):
        data = raw.split("#", 1)[0].strip()
        if not data:
            continue
        fields = [field.strip() for field in data.split(";")]
        if len(fields) < 2:
            raise ValueError(f"DerivedCoreProperties.txt:{line_number}: malformed record")
        if fields[1] not in wanted:
            continue
        if len(fields) != 2:
            raise ValueError(f"DerivedCoreProperties.txt:{line_number}: malformed target-property record")
        bounds = fields[0].split("..")
        start = int(bounds[0], 16)
        end = int(bounds[-1], 16)
        wanted[fields[1]].append((start, end))
    return {name: _merge_ranges(ranges) for name, ranges in wanted.items()}


def _contains(ranges: list[tuple[int, int]], codepoint: int) -> bool:
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


def _is_final_sigma(text: str, index: int, properties: dict[str, list[tuple[int, int]]]) -> bool:
    before = index - 1
    while before >= 0 and _contains(properties["Case_Ignorable"], ord(text[before])):
        before -= 1
    if before < 0 or not _contains(properties["Cased"], ord(text[before])):
        return False
    after = index + 1
    while after < len(text) and _contains(properties["Case_Ignorable"], ord(text[after])):
        after += 1
    return after >= len(text) or not _contains(properties["Cased"], ord(text[after]))


def _convert(
    text: str,
    mappings: dict[int, tuple[int, ...]],
    properties: dict[str, list[tuple[int, int]]],
    lowercase: bool,
) -> str:
    output: list[str] = []
    for index, character in enumerate(text):
        codepoint = ord(character)
        if lowercase and codepoint == 0x03A3 and _is_final_sigma(text, index, properties):
            mapped = (0x03C2,)
        else:
            mapped = mappings.get(codepoint, (codepoint,))
        output.extend(chr(value) for value in mapped)
    return "".join(output)


def _hex_mappings(mappings: dict[int, tuple[int, ...]]) -> list[list[object]]:
    return [
        [f"{codepoint:04X}", [f"{value:04X}" for value in mapping]]
        for codepoint, mapping in sorted(mappings.items())
    ]


def _hex_ranges(ranges: list[tuple[int, int]]) -> list[list[str]]:
    return [[f"{start:04X}", f"{end:04X}"] for start, end in ranges]


def build_contract(upstream: Path) -> dict[str, object]:
    sources = _verified_sources(upstream)
    lower, upper = _parse_unicode_data(_source_text(upstream, "UnicodeData.txt"))
    context_rules = _parse_special_casing(_source_text(upstream, "SpecialCasing.txt"), lower, upper)
    properties = _parse_properties(_source_text(upstream, "DerivedCoreProperties.txt"))
    fixtures = []
    for name, text, expected_lower, expected_upper in FIXTURES:
        actual_lower = _convert(text, lower, properties, lowercase=True)
        actual_upper = _convert(text, upper, properties, lowercase=False)
        if (actual_lower, actual_upper) != (expected_lower, expected_upper):
            raise ValueError(
                f"fixture {name} mismatch: got lower={actual_lower!r} upper={actual_upper!r}, "
                f"expected lower={expected_lower!r} upper={expected_upper!r}"
            )
        fixtures.append(
            {"id": name, "input": text, "lower": expected_lower, "upper": expected_upper}
        )
    payload = {
        "lower_mappings": _hex_mappings(lower),
        "upper_mappings": _hex_mappings(upper),
        "cased_ranges": _hex_ranges(properties["Cased"]),
        "case_ignorable_ranges": _hex_ranges(properties["Case_Ignorable"]),
        "context_rules": context_rules,
    }
    canonical_payload = json.dumps(payload, ensure_ascii=True, separators=(",", ":"), sort_keys=True).encode()
    return {
        "schema_version": 1,
        "contract_id": CONTRACT_ID,
        "task_owner": TASK_OWNER,
        "unicode_version": UNICODE_VERSION,
        "algorithm": {
            "name": "Unicode Default Case Conversion",
            "operations": ["toLowercase_R2", "toUppercase_R1"],
            "mapping_kind": "full",
            "locale_tailoring": False,
            "context_rules": ["Final_Sigma"],
            "normalization": "none",
            "logical_text_model": "unicode_scalar_values",
        },
        "sources": sources,
        "data_sha256": _sha256(canonical_payload),
        "counts": {
            "lower_mappings": len(lower),
            "upper_mappings": len(upper),
            "cased_ranges": len(properties["Cased"]),
            "case_ignorable_ranges": len(properties["Case_Ignorable"]),
            "context_rules": len(context_rules),
            "fixtures": len(fixtures),
        },
        **payload,
        "fixtures": fixtures,
    }


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--upstream",
        type=Path,
        default=root / "unicode_case" / "upstream" / UNICODE_VERSION,
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=root / "capability_conformance" / "unicode_case_contract.json",
    )
    args = parser.parse_args()
    contract = build_contract(args.upstream)
    rendered = json.dumps(contract, ensure_ascii=False, indent=2, sort_keys=False) + "\n"
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(rendered, encoding="utf-8", newline="\n")
    print(
        "unicode-case-generator: wrote "
        f"{args.output} ({contract['counts']['lower_mappings']} lower, "
        f"{contract['counts']['upper_mappings']} upper, {contract['counts']['fixtures']} fixtures)"
    )


if __name__ == "__main__":
    main()

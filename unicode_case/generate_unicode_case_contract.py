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


def _perl_mapping_table(name: str, mappings: dict[int, tuple[int, ...]]) -> str:
    rows = []
    for codepoint, mapping in sorted(mappings.items()):
        rendered = ", ".join(f"0x{value:04X}" for value in mapping)
        rows.append(f" 0x{codepoint:04X} => [{rendered}],")
    return f"my %{name} = (\n" + "\n".join(rows) + "\n);\n"


def _perl_range_table(name: str, ranges: list[tuple[int, int]]) -> str:
    rows = [f" [0x{start:04X}, 0x{end:04X}]," for start, end in ranges]
    return f"my @{name} = (\n" + "\n".join(rows) + "\n);\n"


def render_perl_module(
    lower: dict[int, tuple[int, ...]],
    upper: dict[int, tuple[int, ...]],
    properties: dict[str, list[tuple[int, int]]],
    data_sha256: str,
) -> str:
    return f"""# AUTO-GENERATED by unicode_case/generate_unicode_case_contract.py. DO NOT EDIT.
package LinkedSpec::UnicodeCaseMapping;

use 5.010;
use strict;
use warnings;

our $CONTRACT_ID = '{CONTRACT_ID}';
our $UNICODE_VERSION = '{UNICODE_VERSION}';
our $DATA_SHA256 = '{data_sha256}';

{_perl_mapping_table("LOWER_MAPPINGS", lower)}
{_perl_mapping_table("UPPER_MAPPINGS", upper)}
{_perl_range_table("CASED_RANGES", properties["Cased"])}
{_perl_range_table("CASE_IGNORABLE_RANGES", properties["Case_Ignorable"])}
sub _contains {{
 my ($ranges, $codepoint) = @_;
 my ($low, $high) = (0, scalar(@$ranges));
 while ($low < $high) {{
  my $middle = int(($low + $high) / 2);
  my ($start, $end) = @{{$ranges->[$middle]}};
  if ($codepoint < $start) {{ $high = $middle }}
  elsif ($codepoint > $end) {{ $low = $middle + 1 }}
  else {{ return 1 }}
 }}
 return 0
}}

sub _is_final_sigma {{
 my ($input, $index) = @_;
 my $before = $index - 1;
 --$before while $before >= 0 && _contains(\\@CASE_IGNORABLE_RANGES, $input->[$before]);
 return 0 if $before < 0 || !_contains(\\@CASED_RANGES, $input->[$before]);
 my $after = $index + 1;
 ++$after while $after < @$input && _contains(\\@CASE_IGNORABLE_RANGES, $input->[$after]);
 return $after >= @$input || !_contains(\\@CASED_RANGES, $input->[$after])
}}

sub _convert {{
 my ($value, $lowercase) = @_;
 return undef unless defined($value);
 my @input = unpack('U*', $value);
 my @output;
 my $mappings = $lowercase ? \\%LOWER_MAPPINGS : \\%UPPER_MAPPINGS;
 for my $index (0 .. $#input) {{
  my $codepoint = $input[$index];
  if ($lowercase && $codepoint == 0x03A3 && _is_final_sigma(\\@input, $index)) {{
   push @output, 0x03C2;
  }} elsif (exists($mappings->{{$codepoint}})) {{
   push @output, @{{$mappings->{{$codepoint}}}};
  }} else {{
   push @output, $codepoint;
  }}
 }}
 return pack('U*', @output)
}}

sub lowercase {{ return _convert($_[0], 1) }}
sub uppercase {{ return _convert($_[0], 0) }}

1;
"""


def _rust_mapping_table(name: str, mappings: dict[int, tuple[int, ...]]) -> str:
    rows = []
    for codepoint, mapping in sorted(mappings.items()):
        rendered = ", ".join(f"0x{value:04X}" for value in mapping)
        rows.append(f"    (0x{codepoint:04X}, &[{rendered}]),")
    return f"const {name}: &[(u32, &[u32])] = &[\n" + "\n".join(rows) + "\n];\n"


def _rust_range_table(name: str, ranges: list[tuple[int, int]]) -> str:
    rows = [f"    (0x{start:04X}, 0x{end:04X})," for start, end in ranges]
    return f"const {name}: &[(u32, u32)] = &[\n" + "\n".join(rows) + "\n];\n"


def render_rust_module(
    lower: dict[int, tuple[int, ...]],
    upper: dict[int, tuple[int, ...]],
    properties: dict[str, list[tuple[int, int]]],
    data_sha256: str,
) -> str:
    return f"""// AUTO-GENERATED by unicode_case/generate_unicode_case_contract.py. DO NOT EDIT.

pub const CONTRACT_ID: &str = "{CONTRACT_ID}";
pub const UNICODE_VERSION: &str = "{UNICODE_VERSION}";
pub const DATA_SHA256: &str = "{data_sha256}";

{_rust_mapping_table("LOWER_MAPPINGS", lower)}
{_rust_mapping_table("UPPER_MAPPINGS", upper)}
{_rust_range_table("CASED_RANGES", properties["Cased"])}
{_rust_range_table("CASE_IGNORABLE_RANGES", properties["Case_Ignorable"])}
fn contains(ranges: &[(u32, u32)], codepoint: u32) -> bool {{
    ranges
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

fn is_final_sigma(input: &[char], index: usize) -> bool {{
    let mut before = index;
    let mut cased_before = false;
    while before > 0 {{
        before -= 1;
        let codepoint = input[before] as u32;
        if !contains(CASE_IGNORABLE_RANGES, codepoint) {{
            cased_before = contains(CASED_RANGES, codepoint);
            break;
        }}
    }}
    if !cased_before {{
        return false;
    }}

    let mut after = index + 1;
    while after < input.len() && contains(CASE_IGNORABLE_RANGES, input[after] as u32) {{
        after += 1;
    }}
    after >= input.len() || !contains(CASED_RANGES, input[after] as u32)
}}

fn mapping_for(table: &'static [(u32, &'static [u32])], codepoint: u32) -> Option<&'static [u32]> {{
    table
        .binary_search_by_key(&codepoint, |(source, _)| *source)
        .ok()
        .map(|index| table[index].1)
}}

fn convert(value: &str, lowercase: bool) -> String {{
    let input: Vec<char> = value.chars().collect();
    let table = if lowercase {{
        LOWER_MAPPINGS
    }} else {{
        UPPER_MAPPINGS
    }};
    let mut output = String::with_capacity(value.len());
    for (index, character) in input.iter().copied().enumerate() {{
        let codepoint = character as u32;
        if lowercase && codepoint == 0x03A3 && is_final_sigma(&input, index) {{
            output.push('\\u{{03C2}}');
        }} else if let Some(mapping) = mapping_for(table, codepoint) {{
            for mapped in mapping {{
                output.push(
                    char::from_u32(*mapped).expect("generated mapping must be a Unicode scalar"),
                );
            }}
        }} else {{
            output.push(character);
        }}
    }}
    output
}}

pub fn lowercase(value: &str) -> String {{
    convert(value, true)
}}

pub fn uppercase(value: &str) -> String {{
    convert(value, false)
}}
"""


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


def build_outputs(upstream: Path) -> tuple[dict[str, object], str, str]:
    contract = build_contract(upstream)
    lower = {int(row[0], 16): tuple(int(value, 16) for value in row[1]) for row in contract["lower_mappings"]}
    upper = {int(row[0], 16): tuple(int(value, 16) for value in row[1]) for row in contract["upper_mappings"]}
    properties = {
        "Cased": [(int(row[0], 16), int(row[1], 16)) for row in contract["cased_ranges"]],
        "Case_Ignorable": [
            (int(row[0], 16), int(row[1], 16)) for row in contract["case_ignorable_ranges"]
        ],
    }
    return (
        contract,
        render_perl_module(lower, upper, properties, str(contract["data_sha256"])),
        render_rust_module(lower, upper, properties, str(contract["data_sha256"])),
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
        "--output",
        type=Path,
        default=root / "capability_conformance" / "unicode_case_contract.json",
    )
    parser.add_argument(
        "--perl-output",
        type=Path,
        default=root / "perl" / "LinkedSpec" / "UnicodeCaseMapping.pm",
    )
    parser.add_argument(
        "--rust-output",
        type=Path,
        default=root / "rust" / "linkedspec-runtime" / "src" / "unicode_case_mapping.rs",
    )
    args = parser.parse_args()
    contract, perl_module, rust_module = build_outputs(args.upstream)
    rendered = json.dumps(contract, ensure_ascii=False, indent=2, sort_keys=False) + "\n"
    outputs = ((args.output, rendered), (args.perl_output, perl_module), (args.rust_output, rust_module))
    for path, content in outputs:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")
    print(
        "unicode-case-generator: wrote "
        f"{args.output}, {args.perl_output}, and {args.rust_output} "
        f"({contract['counts']['lower_mappings']} lower, "
        f"{contract['counts']['upper_mappings']} upper, {contract['counts']['fixtures']} fixtures)"
    )


if __name__ == "__main__":
    main()

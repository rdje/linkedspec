#!/usr/bin/env python3
"""Generate the pinned Unicode rule-label contract and backend classifiers."""

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


def render_perl_module(ranges: list[tuple[int, int]], data_sha256: str) -> str:
    rows = "\n".join(f" [0x{start:04X}, 0x{end:04X}]," for start, end in ranges)
    return f'''# Generated by unicode_case/generate_unicode_rule_label_contract.py.
# Do not edit by hand.
#
# Contract: {CONTRACT_ID}; Unicode: {UNICODE_VERSION}; data: {data_sha256}

package LinkedSpec::UnicodeXIDContinue;

use 5.010;
use strict;
use warnings;

our $CONTRACT_ID = '{CONTRACT_ID}';
our $UNICODE_VERSION = '{UNICODE_VERSION}';
our $DATA_SHA256 = '{data_sha256}';
our $RANGE_COUNT = {len(ranges)};

my @XID_CONTINUE_RANGES = (
{rows}
);

sub is_xid_continue_codepoint {{
 my ($codepoint) = @_;
 return 0 unless defined($codepoint) && !ref($codepoint);
 return 0 unless $codepoint =~ /\\A\\d+\\z/o && $codepoint <= 0x10FFFF;

 my ($low, $high) = (0, scalar @XID_CONTINUE_RANGES);
 while ($low < $high) {{
  my $middle = int(($low + $high) / 2);
  my ($start, $end) = @{{$XID_CONTINUE_RANGES[$middle]}};
  if ($codepoint < $start) {{
   $high = $middle;
  }} elsif ($codepoint > $end) {{
   $low = $middle + 1;
  }} else {{
   return 1
  }}
 }}
 return 0
}}

sub is_xid_continue_string {{
 my ($value) = @_;
 return 0 unless defined($value) && !ref($value) && length($value);
 for my $codepoint (unpack('U*', $value)) {{
  return 0 unless is_xid_continue_codepoint($codepoint);
 }}
 return 1
}}

1;
'''


def render_dart_module(ranges: list[tuple[int, int]], data_sha256: str) -> str:
    rows = "\n".join(
        f"  _RuleLabelRange(0x{start:04X}, 0x{end:04X})," for start, end in ranges
    )
    return f'''// Generated by unicode_case/generate_unicode_rule_label_contract.py.
// Do not edit by hand.
//
// Contract: {CONTRACT_ID}; Unicode: {UNICODE_VERSION}; data: {data_sha256}

const String unicodeRuleLabelContractId = '{CONTRACT_ID}';
const String unicodeRuleLabelVersion = '{UNICODE_VERSION}';
const String unicodeRuleLabelDataSha256 =
    '{data_sha256}';
const int unicodeRuleLabelRangeCount = {len(ranges)};

final class RuleLabelPrefix {{
  const RuleLabelPrefix({{required this.label, required this.remainder}});

  final String label;
  final String remainder;
}}

final class _RuleLabelRange {{
  const _RuleLabelRange(this.start, this.end);

  final int start;
  final int end;
}}

const List<_RuleLabelRange> _xidContinueRanges = <_RuleLabelRange>[
{rows}
];

/// Returns whether [codePoint] is a pinned Unicode 17 XID_Continue scalar.
bool isRuleLabelCodePoint(int codePoint) {{
  var low = 0;
  var high = _xidContinueRanges.length;
  while (low < high) {{
    final middle = (low + high) >> 1;
    final range = _xidContinueRanges[middle];
    if (codePoint < range.start) {{
      high = middle;
    }} else if (codePoint > range.end) {{
      low = middle + 1;
    }} else {{
      return true;
    }}
  }}
  return false;
}}

/// Validates one complete rule label without normalization or case folding.
bool isRuleLabel(String label) {{
  if (label.isEmpty) {{
    return false;
  }}
  for (final codePoint in label.runes) {{
    if (!isRuleLabelCodePoint(codePoint)) {{
      return false;
    }}
  }}
  return true;
}}

/// Splits the longest valid rule-label prefix from a Dart UTF-16 string.
RuleLabelPrefix? takeRuleLabelPrefix(String input) {{
  var endCodeUnit = 0;
  for (final codePoint in input.runes) {{
    if (!isRuleLabelCodePoint(codePoint)) {{
      break;
    }}
    endCodeUnit += codePoint > 0xFFFF ? 2 : 1;
  }}
  if (endCodeUnit == 0) {{
    return null;
  }}
  return RuleLabelPrefix(
    label: input.substring(0, endCodeUnit),
    remainder: input.substring(endCodeUnit),
  );
}}
'''


def render_julia_module(ranges: list[tuple[int, int]], data_sha256: str) -> str:
    rows = "\n".join(f"    (0x{start:04X}, 0x{end:04X})," for start, end in ranges)
    return f'''# Generated by unicode_case/generate_unicode_rule_label_contract.py.
# Do not edit by hand.
#
# Contract: {CONTRACT_ID}; Unicode: {UNICODE_VERSION}; data: {data_sha256}

const UNICODE_RULE_LABEL_CONTRACT_ID = "{CONTRACT_ID}"
const UNICODE_RULE_LABEL_VERSION = "{UNICODE_VERSION}"
const UNICODE_RULE_LABEL_DATA_SHA256 = "{data_sha256}"
const UNICODE_RULE_LABEL_RANGE_COUNT = {len(ranges)}

struct RuleLabelPrefix
    label::String
    remainder::String
end

const _UNICODE_RULE_LABEL_RANGES = Tuple{{Int,Int}}[
{rows}
]

"""Return whether one scalar value is a pinned Unicode 17 XID_Continue label character."""
function is_rule_label_codepoint(codepoint::Integer)
    if codepoint < 0 || codepoint > 0x10FFFF
        return false
    end

    scalar = Int(codepoint)
    low = 1
    high = length(_UNICODE_RULE_LABEL_RANGES) + 1
    while low < high
        middle = (low + high) >>> 1
        start, stop = _UNICODE_RULE_LABEL_RANGES[middle]
        if scalar < start
            high = middle
        elseif scalar > stop
            low = middle + 1
        else
            return true
        end
    end
    return false
end

is_rule_label_char(character::Char) = is_rule_label_codepoint(Int(character))

"""Validate one complete rule label without normalization or case folding."""
function is_rule_label(label::AbstractString)
    return !isempty(label) && all(is_rule_label_char, label)
end

"""Split the longest valid rule-label prefix without leaving Julia character boundaries."""
function take_rule_label_prefix(input::AbstractString)
    text = String(input)
    end_index = 0
    for index in eachindex(text)
        if !is_rule_label_char(text[index])
            break
        end
        end_index = nextind(text, index)
    end
    if end_index == 0
        return nothing
    end

    label = String(SubString(text, firstindex(text), prevind(text, end_index)))
    remainder = end_index > ncodeunits(text) ? "" : String(SubString(text, end_index))
    return RuleLabelPrefix(label, remainder)
end
'''


def render_lua_module(ranges: list[tuple[int, int]], data_sha256: str) -> str:
    rows = "\n".join(
        f"  {{ 0x{start:04X}, 0x{end:04X} }}," for start, end in ranges
    )
    return f'''-- Generated by unicode_case/generate_unicode_rule_label_contract.py.
-- Do not edit by hand.
--
-- Contract: {CONTRACT_ID}; Unicode: {UNICODE_VERSION}; data: {data_sha256}

local M = {{}}

M.CONTRACT_ID = "{CONTRACT_ID}"
M.UNICODE_VERSION = "{UNICODE_VERSION}"
M.DATA_SHA256 = "{data_sha256}"
M.RANGE_COUNT = {len(ranges)}

local floor = math.floor
local string_byte = string.byte

local XID_CONTINUE_RANGES = {{
{rows}
}}

local function is_continuation_byte(value)
  return value ~= nil and value >= 0x80 and value <= 0xBF
end

local function decode_utf8_scalar(text, position)
  local byte_1 = string_byte(text, position)
  if byte_1 == nil then
    return nil, position
  elseif byte_1 <= 0x7F then
    return byte_1, position + 1
  elseif byte_1 >= 0xC2 and byte_1 <= 0xDF then
    local byte_2 = string_byte(text, position + 1)
    if not is_continuation_byte(byte_2) then return nil, position end
    return (byte_1 - 0xC0) * 0x40 + (byte_2 - 0x80), position + 2
  elseif byte_1 >= 0xE0 and byte_1 <= 0xEF then
    local byte_2 = string_byte(text, position + 1)
    local byte_3 = string_byte(text, position + 2)
    if not is_continuation_byte(byte_2) or not is_continuation_byte(byte_3) then
      return nil, position
    end
    if (byte_1 == 0xE0 and byte_2 < 0xA0) or (byte_1 == 0xED and byte_2 > 0x9F) then
      return nil, position
    end
    return (byte_1 - 0xE0) * 0x1000 +
      (byte_2 - 0x80) * 0x40 +
      (byte_3 - 0x80), position + 3
  elseif byte_1 >= 0xF0 and byte_1 <= 0xF4 then
    local byte_2 = string_byte(text, position + 1)
    local byte_3 = string_byte(text, position + 2)
    local byte_4 = string_byte(text, position + 3)
    if not is_continuation_byte(byte_2) or not is_continuation_byte(byte_3) or
        not is_continuation_byte(byte_4) then
      return nil, position
    end
    if (byte_1 == 0xF0 and byte_2 < 0x90) or (byte_1 == 0xF4 and byte_2 > 0x8F) then
      return nil, position
    end
    return (byte_1 - 0xF0) * 0x40000 +
      (byte_2 - 0x80) * 0x1000 +
      (byte_3 - 0x80) * 0x40 +
      (byte_4 - 0x80), position + 4
  end
  return nil, position
end

function M.is_rule_label_codepoint(codepoint)
  if type(codepoint) ~= "number" or codepoint ~= floor(codepoint) or
      codepoint < 0 or codepoint > 0x10FFFF then
    return false
  end
  local low = 1
  local high = #XID_CONTINUE_RANGES
  while low <= high do
    local middle = floor((low + high) / 2)
    local range = XID_CONTINUE_RANGES[middle]
    if codepoint < range[1] then
      high = middle - 1
    elseif codepoint > range[2] then
      low = middle + 1
    else
      return true
    end
  end
  return false
end

function M.is_rule_label(label)
  if type(label) ~= "string" or label == "" then return false end
  local position = 1
  while position <= #label do
    local codepoint, next_position = decode_utf8_scalar(label, position)
    if codepoint == nil or not M.is_rule_label_codepoint(codepoint) then
      return false
    end
    position = next_position
  end
  return true
end

function M.take_rule_label_prefix(text, position)
  position = position or 1
  if type(text) ~= "string" or type(position) ~= "number" or
      position ~= floor(position) or position < 1 or position > #text then
    return nil, position
  end
  local start = position
  while position <= #text do
    local codepoint, next_position = decode_utf8_scalar(text, position)
    if codepoint == nil or not M.is_rule_label_codepoint(codepoint) then break end
    position = next_position
  end
  if position == start then return nil, start end
  return text:sub(start, position - 1), position
end

return M
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
        "--perl-output",
        type=Path,
        default=root / "perl" / "LinkedSpec" / "UnicodeXIDContinue.pm",
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
    parser.add_argument(
        "--dart-output",
        type=Path,
        default=root / "dart" / "lib" / "src" / "parser" / "unicode_rule_label.dart",
    )
    parser.add_argument(
        "--julia-output",
        type=Path,
        default=root / "julia" / "src" / "spec" / "UnicodeRuleLabel.jl",
    )
    parser.add_argument(
        "--lua-output",
        type=Path,
        default=root / "lua" / "src" / "linkedspec" / "unicode_rule_label.lua",
    )
    args = parser.parse_args()
    contract = build_contract(args.upstream)
    ranges = [
        (int(start, 16), int(end, 16)) for start, end in contract["xid_continue_ranges"]
    ]
    contract_text = json.dumps(contract, ensure_ascii=True, indent=2, sort_keys=False) + "\n"
    perl_text = render_perl_module(ranges, str(contract["data_sha256"]))
    rust_text = render_rust_module(ranges, str(contract["data_sha256"]))
    dart_text = render_dart_module(ranges, str(contract["data_sha256"]))
    julia_text = render_julia_module(ranges, str(contract["data_sha256"]))
    lua_text = render_lua_module(ranges, str(contract["data_sha256"]))
    self_hosted_regex_text = render_self_hosted_regex_artifact(
        ranges, str(contract["data_sha256"])
    )
    args.contract_output.parent.mkdir(parents=True, exist_ok=True)
    args.perl_output.parent.mkdir(parents=True, exist_ok=True)
    args.rust_output.parent.mkdir(parents=True, exist_ok=True)
    args.dart_output.parent.mkdir(parents=True, exist_ok=True)
    args.julia_output.parent.mkdir(parents=True, exist_ok=True)
    args.lua_output.parent.mkdir(parents=True, exist_ok=True)
    args.self_hosted_regex_output.parent.mkdir(parents=True, exist_ok=True)
    args.contract_output.write_text(contract_text, encoding="utf-8")
    args.perl_output.write_text(perl_text, encoding="utf-8")
    args.rust_output.write_text(rust_text, encoding="utf-8")
    args.dart_output.write_text(dart_text, encoding="utf-8")
    args.julia_output.write_text(julia_text, encoding="utf-8")
    args.lua_output.write_text(lua_text, encoding="utf-8")
    args.self_hosted_regex_output.write_text(self_hosted_regex_text, encoding="utf-8")


if __name__ == "__main__":
    main()

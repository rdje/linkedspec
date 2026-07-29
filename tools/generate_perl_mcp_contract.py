#!/usr/bin/env python3
"""Generate the filesystem-free Perl binding for the neutral MCP contract.

The neutral JSON artifacts remain normative.  This tool verifies every digest
named by their manifest, composes the runtime subset into one canonical JSON
value, and either checks or rewrites the committed data-only Perl module.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any, NoReturn


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "mcp_semantic_transport_contract.json"
OUTPUT_PATH = ROOT / "perl" / "LinkedSpec" / "MCPContract.pm"
EXPECTED_ARTIFACTS = {
    "canonical_frames",
    "corpus",
    "materializer",
    "schema",
    "semantic_payloads",
    "validator",
    "validator_cases",
}


class GenerationError(RuntimeError):
    """The neutral source bundle cannot produce a trustworthy Perl binding."""


def fail(message: str) -> NoReturn:
    raise GenerationError(message)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def canonical_text(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def load_object(path: Path) -> tuple[dict[str, Any], bytes]:
    raw = path.read_bytes()
    require(not raw.startswith(b"\xef\xbb\xbf"), f"{path.relative_to(ROOT)} has a BOM")

    def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        result: dict[str, Any] = {}
        for key, value in pairs:
            require(key not in result, f"{path.relative_to(ROOT)} repeats JSON key {key}")
            result[key] = value
        return result

    try:
        value = json.loads(
            raw.decode("utf-8", errors="strict"),
            object_pairs_hook=unique_object,
            parse_constant=lambda token: fail(f"{path.relative_to(ROOT)} contains {token}"),
        )
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        fail(f"cannot decode {path.relative_to(ROOT)}: {exc}")
    require(isinstance(value, dict), f"{path.relative_to(ROOT)} must contain one object")
    return value, raw


def artifact_paths(contract: dict[str, Any]) -> dict[str, Path]:
    artifacts = contract.get("artifacts")
    digests = contract.get("artifact_sha256")
    require(isinstance(artifacts, dict), "manifest artifacts must be an object")
    require(isinstance(digests, dict), "manifest artifact_sha256 must be an object")
    require(set(artifacts) == EXPECTED_ARTIFACTS, "manifest artifact inventory drifted")
    require(set(digests) == EXPECTED_ARTIFACTS, "manifest digest inventory drifted")
    result: dict[str, Path] = {}
    for name, relative in artifacts.items():
        require(isinstance(relative, str) and relative, f"manifest path for {name} is invalid")
        path = (ROOT / relative).resolve()
        try:
            path.relative_to(ROOT.resolve())
        except ValueError:
            fail(f"manifest path for {name} escapes the repository")
        result[name] = path
    return result


def verified_sources(contract: dict[str, Any]) -> tuple[dict[str, Path], dict[str, str]]:
    paths = artifact_paths(contract)
    expected = contract["artifact_sha256"]
    actual: dict[str, str] = {}
    for name in sorted(paths):
        raw = paths[name].read_bytes()
        digest = hashlib.sha256(raw).hexdigest()
        require(digest == expected[name], f"{name} digest drifted: {digest}")
        actual[name] = digest
    return paths, actual


def canonical_frames(path: Path, corpus: dict[str, Any]) -> dict[str, Any]:
    raw = path.read_bytes()
    require(raw.endswith(b"\n"), "canonical frame stream must end in LF")
    require(b"\r" not in raw, "canonical frame stream must use LF only")
    order = corpus.get("canonical_order")
    require(isinstance(order, list) and all(isinstance(v, str) for v in order), "canonical frame order is invalid")
    require(len(order) == len(set(order)), "canonical frame ids repeat")
    rows = raw.splitlines()
    require(len(rows) == len(order), "canonical frame count differs from corpus order")
    result: dict[str, Any] = {}
    for frame_id, row in zip(order, rows, strict=True):
        try:
            value = json.loads(row.decode("utf-8", errors="strict"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            fail(f"canonical frame {frame_id} cannot be decoded: {exc}")
        require(row.decode("utf-8") == canonical_text(value), f"canonical frame {frame_id} is not canonical JSON")
        result[frame_id] = value
    return result


def build_bundle() -> dict[str, Any]:
    contract, contract_raw = load_object(CONTRACT_PATH)
    require(contract.get("contract_id") == "linkedspec-mcp-transport-v1", "contract id drifted")
    paths, digests = verified_sources(contract)
    schema, _ = load_object(paths["schema"])
    payloads, _ = load_object(paths["semantic_payloads"])
    corpus, _ = load_object(paths["corpus"])
    return {
        "binding_format": 1,
        "contract": contract,
        "contract_sha256": hashlib.sha256(contract_raw).hexdigest(),
        "source_sha256": digests,
        "schema": schema,
        "semantic_payloads": payloads,
        "corpus": corpus,
        "canonical_frames": canonical_frames(paths["canonical_frames"], corpus),
    }


def render_module(bundle: dict[str, Any]) -> bytes:
    embedded = canonical_text(bundle)
    digest = hashlib.sha256(embedded.encode("utf-8")).hexdigest()
    source = f'''# This file is generated by tools/generate_perl_mcp_contract.py.
# The neutral MCP artifacts are normative; do not edit this module by hand.
package LinkedSpec::MCPContract;

use 5.010;
use strict;
use warnings;
use utf8;

our $BINDING_FORMAT = 1;
our $BUNDLE_SHA256 = '{digest}';

my $BUNDLE_JSON = <<'LINKEDSPEC_MCP_CONTRACT_JSON';
{embedded}
LINKEDSPEC_MCP_CONTRACT_JSON
chomp $BUNDLE_JSON;

sub bundle_json {{ return $BUNDLE_JSON }}
sub bundle_sha256 {{ return $BUNDLE_SHA256 }}

1;
'''
    return source.encode("utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="rewrite the committed generated module")
    args = parser.parse_args()
    expected = render_module(build_bundle())
    if args.write:
        OUTPUT_PATH.write_bytes(expected)
        print(f"generated {OUTPUT_PATH.relative_to(ROOT)} ({len(expected)} bytes)")
        return 0
    actual = OUTPUT_PATH.read_bytes() if OUTPUT_PATH.exists() else b""
    if actual != expected:
        fail(f"{OUTPUT_PATH.relative_to(ROOT)} is stale; run this tool with --write")
    print(f"Perl MCP contract binding is byte-fresh ({len(actual)} bytes)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except GenerationError as exc:
        raise SystemExit(f"Perl MCP contract generation failed: {exc}") from exc

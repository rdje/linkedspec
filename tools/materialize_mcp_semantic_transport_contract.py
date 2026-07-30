#!/usr/bin/env python3
"""Materialize and byte-check the neutral LinkedSpec MCP transport corpus.

This is deliberately a deterministic materializer, not the independent contract
validator owned by FUTURE-PARITY-BACKLOG.10.9.1.2.  It turns the normative
manifest/schema/payload/corpus data into the one checked-in canonical JSONL stream
and proves exact source and digest identity without implementing an MCP server.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "mcp_semantic_transport_contract.json"
ARTIFACT_ROOT = ROOT / "capability_conformance" / "mcp_semantic_transport"
SCHEMA_PATH = ARTIFACT_ROOT / "schema.json"
PAYLOADS_PATH = ARTIFACT_ROOT / "semantic_payloads.json"
CORPUS_PATH = ARTIFACT_ROOT / "corpus.json"
CANONICAL_PATH = ARTIFACT_ROOT / "canonical_frames.jsonl"
VALIDATION_PATH = ARTIFACT_ROOT / "validator_cases.json"
SEMANTIC_CONTRACT_PATH = ROOT / "capability_conformance" / "semantic_introspection_contract.json"
MATERIALIZER_PATH = ROOT / "tools" / "materialize_mcp_semantic_transport_contract.py"
VALIDATOR_PATH = ROOT / "tools" / "check_mcp_semantic_transport_contract.py"

CONTRACT_ID = "linkedspec-mcp-transport-v1"
PROTOCOL_VERSION = "2026-07-28"
TASK_OWNER = "FUTURE-PARITY-BACKLOG.10.9.1.1"
ZERO_SHA256 = "0" * 64
HANDLE_PATTERN = re.compile(r"^[A-Za-z0-9_-]{43}$")


class MaterializationError(RuntimeError):
    """A deterministic artifact invariant failed."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise MaterializationError(message)


def load_json(path: Path) -> dict[str, Any]:
    def unique_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        value: dict[str, Any] = {}
        for key, item in pairs:
            require(key not in value, f"{path.relative_to(ROOT)} repeats JSON key {key}")
            value[key] = item
        return value

    value = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
    require(isinstance(value, dict), f"{path.relative_to(ROOT)} must contain one object")
    return value


def canonical_bytes(value: Any) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def result_meta(contract: dict[str, Any], server_key: str) -> dict[str, Any]:
    identities = {row["id"]: row for row in contract["server_identities"]}
    require(server_key in identities, f"unknown server identity {server_key}")
    row = identities[server_key]
    return {
        "io.modelcontextprotocol/serverInfo": {
            "name": row["name"],
            "version": contract["server_version"],
        }
    }


def referenced_defs(value: Any) -> set[str]:
    names: set[str] = set()
    if isinstance(value, dict):
        ref = value.get("$ref")
        if isinstance(ref, str) and ref.startswith("#/$defs/"):
            names.add(ref.removeprefix("#/$defs/"))
        for item in value.values():
            names.update(referenced_defs(item))
    elif isinstance(value, list):
        for item in value:
            names.update(referenced_defs(item))
    return names


def standalone_schema(schema: dict[str, Any], def_name: str, *, object_root: bool) -> dict[str, Any]:
    definitions = schema["$defs"]
    require(def_name in definitions, f"schema definition {def_name} is missing")
    pending = [def_name]
    selected: dict[str, Any] = {}
    while pending:
        name = pending.pop()
        if name in selected:
            continue
        require(name in definitions, f"schema reference {name} is missing")
        selected[name] = definitions[name]
        pending.extend(sorted(referenced_defs(definitions[name]) - selected.keys()))
    value: dict[str, Any] = {
        "$schema": schema["$schema"],
        "$ref": f"#/$defs/{def_name}",
        "$defs": {name: selected[name] for name in sorted(selected)},
    }
    if object_root:
        value["type"] = "object"
    return value


def materialize_tools(contract: dict[str, Any], schema: dict[str, Any]) -> list[dict[str, Any]]:
    tools: list[dict[str, Any]] = []
    for row in contract["tools"]:
        tools.append(
            {
                "annotations": row["annotations"],
                "description": row["description"],
                "inputSchema": standalone_schema(schema, row["input_schema_def"], object_root=True),
                "name": row["name"],
                "outputSchema": standalone_schema(schema, row["output_schema_def"], object_root=False),
                "title": row["title"],
            }
        )
    return tools


def payload_index(payloads: dict[str, Any]) -> dict[str, dict[str, Any]]:
    rows = payloads["payloads"]
    require(len({row["id"] for row in rows}) == len(rows), "semantic payload ids repeat")
    return {row["id"]: row for row in rows}


def tool_error_payload(contract: dict[str, Any], error_id: str) -> dict[str, Any]:
    errors = {row["id"]: row for row in contract["tool_execution_errors"]}
    require(error_id in errors, f"unknown tool error {error_id}")
    row = errors[error_id]
    return {
        "contract": "linkedspec-mcp-tool-error-v1",
        "code": row["code"],
        "message": row["message"],
    }


def materialize_frame(
    fixture: dict[str, Any],
    contract: dict[str, Any],
    schema: dict[str, Any],
    payloads: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    kind = fixture["kind"]
    if kind == "literal":
        return fixture["frame"]
    server_key = fixture["server"]
    meta = result_meta(contract, server_key)
    request_id = fixture["id_value"]
    if kind == "discover_response":
        return {
            "jsonrpc": "2.0",
            "id": request_id,
            "result": {
                "_meta": meta,
                "cacheScope": "public",
                "capabilities": {"tools": {"listChanged": False}},
                "instructions": contract["instructions"],
                "resultType": "complete",
                "supportedVersions": [PROTOCOL_VERSION],
                "ttlMs": contract["cache_policy"]["ttl_ms"],
            },
        }
    if kind == "tools_list_response":
        return {
            "jsonrpc": "2.0",
            "id": request_id,
            "result": {
                "_meta": meta,
                "cacheScope": "public",
                "resultType": "complete",
                "tools": materialize_tools(contract, schema),
                "ttlMs": contract["cache_policy"]["ttl_ms"],
            },
        }
    if kind == "tool_success_response":
        payload_id = fixture["payload"]
        require(payload_id in payloads, f"unknown semantic payload {payload_id}")
        payload = payloads[payload_id]["response"]
        return {
            "jsonrpc": "2.0",
            "id": request_id,
            "result": {
                "_meta": meta,
                "content": [{"text": canonical_bytes(payload).decode("utf-8"), "type": "text"}],
                "isError": False,
                "resultType": "complete",
                "structuredContent": payload,
            },
        }
    if kind == "tool_error_response":
        payload = tool_error_payload(contract, fixture["error"])
        return {
            "jsonrpc": "2.0",
            "id": request_id,
            "result": {
                "_meta": meta,
                "content": [{"text": canonical_bytes(payload).decode("utf-8"), "type": "text"}],
                "isError": True,
                "resultType": "complete",
            },
        }
    raise MaterializationError(f"unsupported fixture kind {kind}")


def raw_fixture_bytes(row: dict[str, Any]) -> bytes:
    encoding = row["encoding"]
    if encoding == "utf8":
        return row["data"].encode("utf-8")
    if encoding == "hex":
        return bytes.fromhex(row["data"])
    if encoding == "repeat_hex":
        return bytes.fromhex(row["byte"]) * row["count"] + bytes.fromhex(row["suffix"])
    if encoding == "nested_json":
        depth = row["depth"]
        return ("[" * depth + "0" + "]" * depth + "\n").encode("utf-8")
    raise MaterializationError(f"unknown raw fixture encoding {encoding}")


def allow_bootstrap(expected: str, actual: str, context: str) -> None:
    require(expected == ZERO_SHA256 or expected == actual, f"{context} digest drifted: {actual}")


def validate_sources(
    contract: dict[str, Any],
    schema: dict[str, Any],
    payloads: dict[str, Any],
    corpus: dict[str, Any],
    semantic_contract: dict[str, Any],
) -> None:
    for value, context in (
        (contract, "contract"),
        (schema, "schema"),
        (payloads, "payloads"),
        (corpus, "corpus"),
    ):
        require(value["contract_id"] == CONTRACT_ID, f"{context} contract id drifted")
        require(value["task_owner"] == TASK_OWNER, f"{context} task owner drifted")
    require(contract["protocol_version"] == PROTOCOL_VERSION, "protocol version drifted")
    require(schema["$schema"] == "https://json-schema.org/draft/2020-12/schema", "schema dialect drifted")
    require(schema["$id"] == "https://linkedspec.dev/schema/mcp-semantic-transport-v1.json", "schema id drifted")
    definitions = schema["$defs"]
    require(
        definitions["requestId"]["oneOf"][0]["x-linkedspec-maxUtf8Bytes"]
        == contract["request_limits"]["string_id_utf8_bytes"],
        "request-id UTF-8 byte annotation drifted",
    )
    for name in referenced_defs(schema):
        require(name in definitions, f"schema reference {name} is missing")
    require(
        [row["$ref"].removeprefix("#/$defs/") for row in schema["oneOf"]]
        == [
            "discoverRequest",
            "discoverResponse",
            "toolsListRequest",
            "toolsListResponse",
            "capabilitiesCallRequest",
            "semanticQueryCallRequest",
            "toolSuccessResponse",
            "toolExecutionErrorResponse",
            "jsonRpcErrorResponse",
            "cancelledNotification",
        ],
        "top-level schema envelope inventory/order drifted",
    )
    require(contract["semantic_contract"]["contract_id"] == semantic_contract["contract_id"], "semantic contract id drifted")
    require(contract["semantic_contract"]["query_id"] == semantic_contract["query_id"], "semantic query id drifted")
    governed_fact_keys: list[str] = []
    for keys in semantic_contract["schema"]["fact_keys"].values():
        for key in keys:
            if key not in governed_fact_keys:
                governed_fact_keys.append(key)
    require(
        definitions["recordFacts"]["propertyNames"]["enum"] == governed_fact_keys,
        "MCP record fact keys drifted from the semantic contract union",
    )
    require(
        definitions["semanticQueryRequest"]["properties"]["contract"]
        == {
            "type": "string",
            "minLength": 1,
            "maxLength": 128,
            "x-linkedspec-maxUtf8Bytes": 128,
        },
        "semantic query contract-string boundary drifted",
    )
    policy = contract["deployment_policy"]
    require(
        policy["pre_dispatch_enforcement"] == "explicit_overlay_component_presence_only"
        and policy["unsupplied_component"] == "native_dispatch_and_native_portable_response"
        and policy["partial_overlay"] == "independent_per_component",
        "deployment policy component-presence boundary drifted",
    )
    require(len(contract["server_identities"]) == 5, "five native identities are required")
    require(len({row["name"] for row in contract["server_identities"]}) == 5, "server identities repeat")
    require([row["name"] for row in contract["tools"]] == [
        "linkedspec_semantic_capabilities",
        "linkedspec_semantic_query",
    ], "tool topology/order drifted")
    require(len({row["id"] for row in corpus["frames"]}) == len(corpus["frames"]), "frame ids repeat")
    require(corpus["canonical_order"] == [row["id"] for row in corpus["frames"]], "canonical frame order drifted")
    require(len({row["id"] for row in corpus["raw_inputs"]}) == len(corpus["raw_inputs"]), "raw input ids repeat")
    require(len(corpus["frames"]) == 35, "canonical frame inventory drifted")
    require(len(corpus["raw_inputs"]) == 10, "raw input inventory drifted")
    require(len(corpus["lifecycle_cases"]) == 10, "lifecycle inventory drifted")
    require(len(corpus["handle_cases"]) == 4, "handle-state inventory drifted")
    require(len(corpus["policy_cases"]) == 4, "policy-case inventory drifted")

    handle = corpus["illustrative_handle"]
    require(HANDLE_PATTERN.fullmatch(handle) is not None, "illustrative handle is not 32-byte unpadded base64url")
    unavailable_states = contract["handle_registry"]["indistinguishable_states"]
    require([row["state"] for row in corpus["handle_cases"]] == unavailable_states, "handle-state order drifted")
    require(
        all(row["expected_frame"] == "handle_unavailable_response" for row in corpus["handle_cases"]),
        "handle states no longer share one response",
    )
    require(
        all(row["native_dispatch_count"] == 0 for row in corpus["handle_cases"]),
        "unavailable handles must fail before native dispatch",
    )
    require(
        [row["native_dispatch_count"] for row in corpus["policy_cases"]] == [1, 1, 1, 0],
        "policy dispatch boundary drifted",
    )

    semantic_hashes = {row["id"]: row["expected"]["response_sha256"] for row in semantic_contract["query_cases"]}
    for row in payloads["payloads"]:
        actual = sha256_bytes(canonical_bytes(row["response"]))
        allow_bootstrap(row["response_sha256"], actual, f"payload {row['id']}")
        source_case = row["source_query_case"]
        if source_case is not None:
            require(source_case in semantic_hashes, f"payload {row['id']} source query is missing")
            require(actual == semantic_hashes[source_case], f"payload {row['id']} lost native response identity")
    for row in corpus["raw_inputs"]:
        allow_bootstrap(row["sha256"], sha256_bytes(raw_fixture_bytes(row)), f"raw input {row['id']}")


def validate_materialized(
    contract: dict[str, Any],
    schema: dict[str, Any],
    payloads: dict[str, Any],
    corpus: dict[str, Any],
    stream: bytes,
) -> None:
    indexed_payloads = payload_index(payloads)
    frames = [materialize_frame(row, contract, schema, indexed_payloads) for row in corpus["frames"]]
    frame_index = {row["id"]: frame for row, frame in zip(corpus["frames"], frames, strict=True)}

    discover_names = [
        frame_index[f"discover_response_{row['id']}"]["result"]["_meta"]
        ["io.modelcontextprotocol/serverInfo"]["name"]
        for row in contract["server_identities"]
    ]
    require(discover_names == [row["name"] for row in contract["server_identities"]], "discovery identity coverage drifted")

    for fixture, frame in zip(corpus["frames"], frames, strict=True):
        if fixture["kind"] == "tool_success_response":
            result = frame["result"]
            require(result["content"][0]["text"] == canonical_bytes(result["structuredContent"]).decode("utf-8"),
                    f"{fixture['id']} text/structured content identity drifted")
        elif fixture["kind"] == "tool_error_response":
            result = frame["result"]
            require("structuredContent" not in result, f"{fixture['id']} must omit structuredContent")
            require(
                json.loads(result["content"][0]["text"]) == tool_error_payload(contract, fixture["error"]),
                f"{fixture['id']} text error payload drifted",
            )

    require(stream.endswith(b"\n"), "canonical stream must end with LF")
    require(b"\r" not in stream, "canonical stream must use LF only")
    lines = stream.splitlines()
    require(len(lines) == len(frames), "canonical stream frame count drifted")
    line_limit = contract["request_limits"]["line_bytes_excluding_delimiter"]
    require(max(map(len, lines)) <= line_limit, "canonical stream exceeds the line limit")
    for fixture, line, frame in zip(corpus["frames"], lines, frames, strict=True):
        require(line == canonical_bytes(frame), f"{fixture['id']} is not canonical JSON")

    crlf_case = next(row for row in corpus["raw_inputs"] if row["id"] == "valid_crlf_discovery")
    require(raw_fixture_bytes(crlf_case).endswith(b"\r\n"), "CRLF admission fixture drifted")


def materialized_stream(
    contract: dict[str, Any],
    schema: dict[str, Any],
    payloads: dict[str, Any],
    corpus: dict[str, Any],
) -> bytes:
    indexed_payloads = payload_index(payloads)
    frames = [materialize_frame(row, contract, schema, indexed_payloads) for row in corpus["frames"]]
    return b"".join(canonical_bytes(frame) + b"\n" for frame in frames)


def artifact_digests(stream: bytes) -> dict[str, str]:
    return {
        "schema": sha256_file(SCHEMA_PATH),
        "semantic_payloads": sha256_file(PAYLOADS_PATH),
        "corpus": sha256_file(CORPUS_PATH),
        "canonical_frames": sha256_bytes(stream),
        "materializer": sha256_file(MATERIALIZER_PATH),
        "validator_cases": sha256_file(VALIDATION_PATH),
        "validator": sha256_file(VALIDATOR_PATH),
    }


def print_digests(
    contract: dict[str, Any], payloads: dict[str, Any], corpus: dict[str, Any], stream: bytes
) -> None:
    for row in payloads["payloads"]:
        print(f"payload {row['id']} {sha256_bytes(canonical_bytes(row['response']))}")
    for row in corpus["raw_inputs"]:
        print(f"raw {row['id']} {sha256_bytes(raw_fixture_bytes(row))}")
    for name, digest in artifact_digests(stream).items():
        print(f"artifact {name} {digest}")
    print(f"frames {len(corpus['frames'])}")
    print(f"raw_inputs {len(corpus['raw_inputs'])}")
    print(f"lifecycle {len(corpus['lifecycle_cases'])}")


def validate_artifact_digests(contract: dict[str, Any], stream: bytes) -> None:
    actual = artifact_digests(stream)
    expected = contract["artifact_sha256"]
    require(set(actual) == set(expected), "artifact digest inventory drifted")
    for name, digest in actual.items():
        allow_bootstrap(expected[name], digest, f"artifact {name}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="write the deterministic canonical JSONL stream")
    parser.add_argument("--print-digests", action="store_true", help="print bootstrap/update digests")
    args = parser.parse_args()

    contract = load_json(CONTRACT_PATH)
    schema = load_json(SCHEMA_PATH)
    payloads = load_json(PAYLOADS_PATH)
    corpus = load_json(CORPUS_PATH)
    semantic_contract = load_json(SEMANTIC_CONTRACT_PATH)
    validate_sources(contract, schema, payloads, corpus, semantic_contract)
    stream = materialized_stream(contract, schema, payloads, corpus)
    validate_materialized(contract, schema, payloads, corpus, stream)

    if args.print_digests:
        print_digests(contract, payloads, corpus, stream)
    if args.write:
        CANONICAL_PATH.write_bytes(stream)
    else:
        require(CANONICAL_PATH.is_file(), "canonical JSONL stream is missing; run with --write")
        require(CANONICAL_PATH.read_bytes() == stream, "canonical JSONL stream is stale; run with --write")
    validate_artifact_digests(contract, stream)

    print(
        "MCP semantic transport materialization: "
        f"{len(corpus['frames'])} canonical frames, {len(corpus['raw_inputs'])} raw inputs, "
        f"{len(corpus['lifecycle_cases'])} lifecycle cases, exact artifact digests"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

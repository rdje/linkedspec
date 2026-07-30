#!/usr/bin/env python3
"""Independently validate the neutral LinkedSpec MCP transport contract.

This checker intentionally shares no executable code with the deterministic
materializer.  It implements the exact JSON Schema 2020-12 keyword profile used
by the contract, validates canonical frames and stateful transport policy, and
executes every checked-in omission/mutation case in memory.
"""

from __future__ import annotations

import argparse
import ast
import copy
import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, NoReturn
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "mcp_semantic_transport_contract.json"
ARTIFACT_ROOT = ROOT / "capability_conformance" / "mcp_semantic_transport"
SCHEMA_PATH = ARTIFACT_ROOT / "schema.json"
PAYLOADS_PATH = ARTIFACT_ROOT / "semantic_payloads.json"
CORPUS_PATH = ARTIFACT_ROOT / "corpus.json"
FRAMES_PATH = ARTIFACT_ROOT / "canonical_frames.jsonl"
VALIDATION_PATH = ARTIFACT_ROOT / "validator_cases.json"
SEMANTIC_CONTRACT_PATH = ROOT / "capability_conformance" / "semantic_introspection_contract.json"
MATERIALIZER_PATH = ROOT / "tools" / "materialize_mcp_semantic_transport_contract.py"
CHECKER_PATH = ROOT / "tools" / "check_mcp_semantic_transport_contract.py"

CONTRACT_ID = "linkedspec-mcp-transport-v1"
PROTOCOL_VERSION = "2026-07-28"
SCHEMA_DIALECT = "https://json-schema.org/draft/2020-12/schema"
SCHEMA_ID = "https://linkedspec.dev/schema/mcp-semantic-transport-v1.json"
VALIDATION_OWNER = "FUTURE-PARITY-BACKLOG.10.9.1.2"
HANDLE_RE = re.compile(r"^[A-Za-z0-9_-]{43}$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")

JSON_TYPES = {"array", "boolean", "integer", "null", "number", "object", "string"}
SCHEMA_KEYWORDS = {
    "$defs", "$id", "$ref", "$schema", "additionalProperties", "allOf", "const",
    "description", "enum", "format", "items", "maximum", "maxItems", "maxLength",
    "minimum", "minItems", "minLength", "maxProperties", "oneOf", "pattern", "prefixItems",
    "properties", "propertyNames", "required", "title", "type", "x-linkedspec-maxUtf8Bytes",
}


class ContractError(RuntimeError):
    """One independently checked invariant failed."""

    def __init__(self, code: str, message: str):
        super().__init__(f"{code}: {message}")
        self.code = code


class InstanceError(RuntimeError):
    """A value failed the contract's JSON Schema profile."""


def fail(code: str, message: str) -> NoReturn:
    raise ContractError(code, message)


def require(condition: bool, code: str, message: str) -> None:
    if not condition:
        fail(code, message)


def canonical_bytes(value: Any) -> bytes:
    try:
        return json.dumps(
            value, ensure_ascii=False, sort_keys=True, separators=(",", ":"), allow_nan=False
        ).encode("utf-8")
    except (TypeError, ValueError) as exc:
        fail("canonical_json", str(exc))


def pretty_bytes(value: Any) -> bytes:
    return (json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n").encode("utf-8")


def sha256(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def same_json(left: Any, right: Any) -> bool:
    return canonical_bytes(left) == canonical_bytes(right)


def unique_object(path: Path):
    def hook(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        value: dict[str, Any] = {}
        for key, item in pairs:
            if key in value:
                fail("json_source", f"{path.relative_to(ROOT)} repeats key {key}")
            value[key] = item
        return value

    return hook


def load_json(path: Path) -> tuple[dict[str, Any], bytes]:
    raw = path.read_bytes()
    require(not raw.startswith(b"\xef\xbb\xbf"), "json_source", f"{path.relative_to(ROOT)} has a BOM")
    try:
        text = raw.decode("utf-8", errors="strict")
        value = json.loads(text, object_pairs_hook=unique_object(path), parse_constant=lambda v: fail("json_source", f"non-finite {v}"))
    except ContractError:
        raise
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        fail("json_source", f"{path.relative_to(ROOT)}: {exc}")
    require(isinstance(value, dict), "json_source", f"{path.relative_to(ROOT)} must contain one object")
    return value, raw


def load_frames(path: Path) -> tuple[list[Any], bytes]:
    raw = path.read_bytes()
    require(raw.endswith(b"\n"), "frame_canonical", "canonical stream must end in LF")
    require(b"\r" not in raw, "frame_canonical", "canonical stream must emit LF only")
    rows: list[Any] = []
    for index, line in enumerate(raw.splitlines(), start=1):
        try:
            text = line.decode("utf-8", errors="strict")
            value = json.loads(text, object_pairs_hook=unique_object(path), parse_constant=lambda v: fail("frame_canonical", f"non-finite {v}"))
        except ContractError:
            raise
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            fail("frame_canonical", f"line {index}: {exc}")
        require(line == canonical_bytes(value), "frame_canonical", f"line {index} is not compact canonical JSON")
        rows.append(value)
    return rows, raw


@dataclass
class Bundle:
    contract: dict[str, Any]
    schema: dict[str, Any]
    payloads: dict[str, Any]
    corpus: dict[str, Any]
    validation: dict[str, Any]
    semantic_contract: dict[str, Any]
    frames: list[Any]
    source_bytes: dict[str, bytes]
    mutated: set[str]


def load_bundle() -> Bundle:
    contract, contract_raw = load_json(CONTRACT_PATH)
    schema, schema_raw = load_json(SCHEMA_PATH)
    payloads, payloads_raw = load_json(PAYLOADS_PATH)
    corpus, corpus_raw = load_json(CORPUS_PATH)
    validation, validation_raw = load_json(VALIDATION_PATH)
    semantic, semantic_raw = load_json(SEMANTIC_CONTRACT_PATH)
    frames, frames_raw = load_frames(FRAMES_PATH)
    return Bundle(
        contract=contract,
        schema=schema,
        payloads=payloads,
        corpus=corpus,
        validation=validation,
        semantic_contract=semantic,
        frames=frames,
        source_bytes={
            "contract": contract_raw,
            "schema": schema_raw,
            "semantic_payloads": payloads_raw,
            "corpus": corpus_raw,
            "canonical_frames": frames_raw,
            "validator_cases": validation_raw,
            "semantic_contract": semantic_raw,
            "materializer": MATERIALIZER_PATH.read_bytes(),
            "validator": CHECKER_PATH.read_bytes(),
        },
        mutated=set(),
    )


def source_bytes(bundle: Bundle, target: str) -> bytes:
    if target not in bundle.mutated:
        return bundle.source_bytes[target]
    if target == "canonical_frames":
        return b"".join(canonical_bytes(row) + b"\n" for row in bundle.frames)
    mapping = {
        "contract": bundle.contract,
        "schema": bundle.schema,
        "semantic_payloads": bundle.payloads,
        "corpus": bundle.corpus,
        "validator_cases": bundle.validation,
    }
    if target in mapping:
        return pretty_bytes(mapping[target])
    return bundle.source_bytes[target]


def validate_schema_document(
    schema: dict[str, Any],
    validation: dict[str, Any],
    semantic_contract: dict[str, Any],
) -> None:
    require(schema.get("$schema") == SCHEMA_DIALECT, "schema_meta", "wrong JSON Schema dialect")
    require(schema.get("$id") == SCHEMA_ID, "schema_meta", "wrong schema id")
    require(schema.get("contract_id") == CONTRACT_ID, "schema_meta", "wrong contract id")
    require(schema.get("task_owner") == "FUTURE-PARITY-BACKLOG.10.9.1.1", "schema_meta", "wrong schema owner")
    definitions = schema.get("$defs")
    require(isinstance(definitions, dict), "schema_meta", "$defs must be an object")
    expected_defs = validation["schema_profile"]["definitions"]
    require(sorted(definitions) == expected_defs, "schema_topology", "definition inventory drifted")

    def visit(node: Any, path: str, *, root: bool = False) -> None:
        require(isinstance(node, (dict, bool)), "schema_meta", f"{path} is not a schema")
        if isinstance(node, bool):
            return
        allowed = SCHEMA_KEYWORDS | ({"contract_id", "task_owner"} if root else set())
        unknown = sorted(set(node) - allowed)
        require(not unknown, "schema_meta", f"{path} has unsupported keywords {unknown}")
        if "$ref" in node:
            ref = node["$ref"]
            require(isinstance(ref, str) and ref.startswith("#/$defs/"), "schema_meta", f"{path} has non-local $ref")
            require(ref.removeprefix("#/$defs/") in definitions, "schema_meta", f"{path} has unresolved $ref {ref}")
        if "type" in node:
            kinds = node["type"] if isinstance(node["type"], list) else [node["type"]]
            require(kinds and all(isinstance(v, str) and v in JSON_TYPES for v in kinds), "schema_meta", f"{path} has invalid type")
            require(len(kinds) == len(set(kinds)), "schema_meta", f"{path} repeats a type")
        if "required" in node:
            required = node["required"]
            require(isinstance(required, list) and all(isinstance(v, str) for v in required), "schema_meta", f"{path} required is invalid")
            require(len(required) == len(set(required)), "schema_meta", f"{path} repeats a required key")
        if "properties" in node:
            require(isinstance(node["properties"], dict), "schema_meta", f"{path} properties is invalid")
            for name, child in node["properties"].items():
                visit(child, f"{path}/properties/{name}")
        if "propertyNames" in node:
            visit(node["propertyNames"], f"{path}/propertyNames")
        if "additionalProperties" in node:
            child = node["additionalProperties"]
            require(isinstance(child, (dict, bool)), "schema_meta", f"{path} additionalProperties is invalid")
            if isinstance(child, dict):
                visit(child, f"{path}/additionalProperties")
        for keyword in ("oneOf", "allOf", "prefixItems"):
            if keyword in node:
                rows = node[keyword]
                require(isinstance(rows, list) and rows, "schema_meta", f"{path}/{keyword} is empty or invalid")
                for index, child in enumerate(rows):
                    visit(child, f"{path}/{keyword}/{index}")
        if "items" in node:
            visit(node["items"], f"{path}/items")
        if "enum" in node:
            values = node["enum"]
            require(isinstance(values, list) and values, "schema_meta", f"{path} enum is empty or invalid")
            require(len({canonical_bytes(v) for v in values}) == len(values), "schema_meta", f"{path} enum repeats values")
        for keyword in ("minimum", "maximum", "minItems", "maxItems", "minLength", "maxLength", "maxProperties", "x-linkedspec-maxUtf8Bytes"):
            if keyword in node:
                value = node[keyword]
                require(isinstance(value, int) and not isinstance(value, bool), "schema_meta", f"{path}/{keyword} is not an integer")
        for minimum, maximum in (("minimum", "maximum"), ("minItems", "maxItems"), ("minLength", "maxLength")):
            if minimum in node and maximum in node:
                require(node[minimum] <= node[maximum], "schema_meta", f"{path} has inverted {minimum}/{maximum}")
        if "pattern" in node:
            require(isinstance(node["pattern"], str), "schema_meta", f"{path}/pattern is not text")
            try:
                re.compile(node["pattern"])
            except re.error as exc:
                fail("schema_meta", f"{path}/pattern: {exc}")
        if "format" in node:
            require(node["format"] == "uri", "schema_meta", f"{path} uses unsupported format")

    visit(schema, "#", root=True)
    for name, node in definitions.items():
        visit(node, f"#/$defs/{name}")

    top_refs = [row.get("$ref") for row in schema.get("oneOf", [])]
    require(top_refs == validation["schema_profile"]["top_level_refs"], "schema_topology", "top-level envelope order drifted")
    require(
        schema["$defs"]["requestId"]["oneOf"][0].get("x-linkedspec-maxUtf8Bytes") == 128,
        "schema_profile",
        "request-id UTF-8 byte limit drifted",
    )
    require(
        schema["$defs"]["semanticQueryRequest"]["properties"].get("contract")
        == {
            "type": "string",
            "minLength": 1,
            "maxLength": 128,
            "x-linkedspec-maxUtf8Bytes": 128,
        },
        "schema_profile",
        "semantic query contract-string boundary drifted",
    )
    governed_fact_keys: list[str] = []
    for keys in semantic_contract["schema"]["fact_keys"].values():
        for key in keys:
            if key not in governed_fact_keys:
                governed_fact_keys.append(key)
    require(
        schema["$defs"]["recordFacts"]["propertyNames"].get("enum") == governed_fact_keys,
        "schema_profile",
        "MCP record fact keys drifted from the semantic contract union",
    )


class SchemaRuntime:
    def __init__(self, schema: dict[str, Any]):
        self.root = schema
        self.definitions = schema["$defs"]

    def validate(self, value: Any, schema: dict[str, Any] | bool | None = None, path: str = "$") -> None:
        node: dict[str, Any] | bool = self.root if schema is None else schema
        self._validate(value, node, path)

    def matches(self, value: Any, schema: dict[str, Any] | bool) -> bool:
        try:
            self._validate(value, schema, "$")
            return True
        except InstanceError:
            return False

    def _validate(self, value: Any, node: dict[str, Any] | bool, path: str) -> None:
        if node is True:
            return
        if node is False:
            raise InstanceError(f"{path}: false schema")
        if "$ref" in node:
            name = node["$ref"].removeprefix("#/$defs/")
            self._validate(value, self.definitions[name], path)
        if "type" in node:
            kinds = node["type"] if isinstance(node["type"], list) else [node["type"]]
            if not any(self._has_type(value, kind) for kind in kinds):
                raise InstanceError(f"{path}: expected {kinds}")
        if "const" in node and not same_json(value, node["const"]):
            raise InstanceError(f"{path}: const mismatch")
        if "enum" in node and not any(same_json(value, item) for item in node["enum"]):
            raise InstanceError(f"{path}: enum mismatch")
        if "oneOf" in node:
            matches = sum(self.matches(value, child) for child in node["oneOf"])
            if matches != 1:
                raise InstanceError(f"{path}: oneOf matched {matches}")
        if "allOf" in node:
            for child in node["allOf"]:
                self._validate(value, child, path)
        if isinstance(value, dict):
            properties = node.get("properties", {})
            if "maxProperties" in node and len(value) > node["maxProperties"]:
                raise InstanceError(f"{path}: too many properties")
            for name in node.get("required", []):
                if name not in value:
                    raise InstanceError(f"{path}: missing {name}")
            for name, item in value.items():
                if "propertyNames" in node:
                    self._validate(name, node["propertyNames"], f"{path}.<propertyName>")
                if name in properties:
                    self._validate(item, properties[name], f"{path}.{name}")
                elif node.get("additionalProperties", True) is False:
                    raise InstanceError(f"{path}: unexpected {name}")
                elif isinstance(node.get("additionalProperties"), dict):
                    self._validate(item, node["additionalProperties"], f"{path}.{name}")
        if isinstance(value, list):
            prefix = node.get("prefixItems", [])
            for index, child in enumerate(prefix[: len(value)]):
                self._validate(value[index], child, f"{path}[{index}]")
            if "items" in node:
                start = len(prefix) if prefix else 0
                for index in range(start, len(value)):
                    self._validate(value[index], node["items"], f"{path}[{index}]")
            if "minItems" in node and len(value) < node["minItems"]:
                raise InstanceError(f"{path}: too few items")
            if "maxItems" in node and len(value) > node["maxItems"]:
                raise InstanceError(f"{path}: too many items")
        if isinstance(value, str):
            if "minLength" in node and len(value) < node["minLength"]:
                raise InstanceError(f"{path}: too short")
            if "maxLength" in node and len(value) > node["maxLength"]:
                raise InstanceError(f"{path}: too long")
            if "x-linkedspec-maxUtf8Bytes" in node and len(value.encode("utf-8")) > node["x-linkedspec-maxUtf8Bytes"]:
                raise InstanceError(f"{path}: too many UTF-8 bytes")
            if "pattern" in node and re.fullmatch(node["pattern"], value) is None:
                raise InstanceError(f"{path}: pattern mismatch")
            if node.get("format") == "uri" and not urlsplit(value).scheme:
                raise InstanceError(f"{path}: invalid URI")
        if isinstance(value, (int, float)) and not isinstance(value, bool):
            if "minimum" in node and value < node["minimum"]:
                raise InstanceError(f"{path}: below minimum")
            if "maximum" in node and value > node["maximum"]:
                raise InstanceError(f"{path}: above maximum")

    @staticmethod
    def _has_type(value: Any, kind: str) -> bool:
        if kind == "null":
            return value is None
        if kind == "boolean":
            return isinstance(value, bool)
        if kind == "integer":
            return isinstance(value, int) and not isinstance(value, bool)
        if kind == "number":
            return isinstance(value, (int, float)) and not isinstance(value, bool)
        if kind == "string":
            return isinstance(value, str)
        if kind == "array":
            return isinstance(value, list)
        if kind == "object":
            return isinstance(value, dict)
        return False


def validate_contract_profile(bundle: Bundle) -> None:
    contract = bundle.contract
    require(contract.get("format") == 1, "contract_profile", "contract format drifted")
    require(contract.get("contract_id") == CONTRACT_ID, "contract_profile", "contract id drifted")
    require(contract.get("protocol_version") == PROTOCOL_VERSION, "contract_profile", "protocol version drifted")
    require(contract.get("transport") == "stdio", "contract_profile", "transport drifted")
    expected_artifacts = {
        "canonical_frames", "corpus", "materializer", "schema", "semantic_payloads", "validator", "validator_cases"
    }
    require(set(contract.get("artifacts", {})) == expected_artifacts, "artifact_topology", "artifact inventory drifted")
    require(set(contract.get("artifact_sha256", {})) == expected_artifacts, "artifact_topology", "artifact digest inventory drifted")
    require(all(SHA256_RE.fullmatch(v or "") for v in contract["artifact_sha256"].values()), "artifact_topology", "invalid artifact digest")
    identities = contract.get("server_identities")
    require(
        identities == [
            {"id": "perl", "name": "linkedspec-semantic-perl", "runtime_admissions": ["perl"]},
            {"id": "rust", "name": "linkedspec-semantic-rust", "runtime_admissions": ["rust"]},
            {"id": "dart", "name": "linkedspec-semantic-dart", "runtime_admissions": ["dart"]},
            {"id": "julia", "name": "linkedspec-semantic-julia", "runtime_admissions": ["julia"]},
            {"id": "lua", "name": "linkedspec-semantic-lua", "runtime_admissions": ["puc_lua", "luajit"]},
        ],
        "identity_profile",
        "five-implementation/six-runtime identity topology drifted",
    )
    require(contract.get("methods") == ["server/discover", "tools/list", "tools/call", "notifications/cancelled"], "method_profile", "method topology drifted")
    tool_names = [row.get("name") for row in contract.get("tools", [])]
    require(tool_names == ["linkedspec_semantic_capabilities", "linkedspec_semantic_query"], "tool_profile", "tool topology drifted")
    for row in contract["tools"]:
        require(
            row.get("annotations") == {
                "destructiveHint": False, "idempotentHint": True, "openWorldHint": False, "readOnlyHint": True
            },
            "tool_profile",
            f"{row.get('name')} annotations drifted",
        )
    require(
        contract.get("request_limits") == {
            "line_bytes_excluding_delimiter": 1048576,
            "json_nesting_depth": 64,
            "string_id_utf8_bytes": 128,
            "integer_id_min": -9007199254740991,
            "integer_id_max": 9007199254740991,
            "accepted_delimiters": ["LF", "CRLF"],
            "emitted_delimiter": "LF",
            "reject_bom": True,
            "reject_duplicate_keys": True,
            "reject_batches": True,
            "reject_non_object": True,
        },
        "request_profile",
        "request limits drifted",
    )
    require(
        contract["request_metadata"]["required"] == [
            "io.modelcontextprotocol/clientCapabilities", "io.modelcontextprotocol/protocolVersion"
        ] and contract["request_metadata"]["protocol_version"] == PROTOCOL_VERSION,
        "request_profile",
        "request metadata drifted",
    )
    registry = contract["handle_registry"]
    require(registry["entropy_bits"] == 256 and registry["encoding"] == "unpadded_base64url" and registry["encoded_characters"] == 43, "handle_profile", "handle entropy/encoding drifted")
    require(registry["indistinguishable_states"] == ["unknown", "expired", "revoked", "unauthorized"], "handle_profile", "handle-state equivalence drifted")
    require(registry["sliding_expiry"] is False and registry["clear_and_release_on_shutdown"] is True, "handle_profile", "handle lifecycle drifted")
    policy = contract["deployment_policy"]
    require(policy["mode"] == "lowering_only" and policy["silent_request_lowering"] is False and policy["semantic_response_synthesis"] is False, "policy_profile", "deployment policy drifted")
    require(policy["denied_query"] == "tool_execution_error_before_native_dispatch", "policy_profile", "policy denial dispatch drifted")
    require(
        policy.get("pre_dispatch_enforcement") == "explicit_overlay_component_presence_only"
        and policy.get("unsupplied_component") == "native_dispatch_and_native_portable_response"
        and policy.get("partial_overlay") == "independent_per_component",
        "policy_profile",
        "deployment policy component-presence boundary drifted",
    )
    tool_errors = [(row["id"], row["code"], row["message"]) for row in contract["tool_execution_errors"]]
    require(tool_errors == [
        ("handle_unavailable", "linkedspec_mcp_handle_unavailable", "No current authorized semantic index is available for this handle."),
        ("policy_denied", "linkedspec_mcp_policy_denied", "The semantic query exceeds the deployment policy for this handle."),
    ], "error_profile", "tool error inventory drifted")
    rpc_errors = [(row["code"], row["message"]) for row in contract["json_rpc_errors"]]
    require(rpc_errors == [(-32700, "Parse error"), (-32600, "Invalid Request"), (-32601, "Method not found"), (-32602, "Invalid params"), (-32603, "Internal error"), (-32022, "Unsupported protocol version")], "error_profile", "JSON-RPC error inventory drifted")
    require(contract["legacy_diagnostic"] == {
        "method": "initialize", "code": -32601,
        "message": "Method initialize is unavailable; use modern MCP 2026-07-28 server/discover.",
        "notifications_initialized": "ignore_without_response",
    }, "legacy_profile", "legacy diagnostic drifted")
    require(contract["authority_fence"]["stdout"] == "mcp_frames_only" and contract["authority_fence"]["stderr_default"] == "silent", "authority_profile", "output authority drifted")
    require(contract["shutdown"]["signal"] == "stdin_eof" and contract["shutdown"]["clear_registry"] is True and contract["shutdown"]["release_indexes"] is True and contract["shutdown"]["graceful_exit"] == 0, "lifecycle_profile", "shutdown policy drifted")


def payload_index(bundle: Bundle) -> dict[str, dict[str, Any]]:
    rows = bundle.payloads.get("payloads")
    require(isinstance(rows, list), "payload_profile", "payloads is not an array")
    result = {row.get("id"): row for row in rows}
    require(len(result) == len(rows), "payload_profile", "payload ids repeat")
    require(list(result) == ["capabilities_default", "capabilities_restricted", "graph_list_rules", "invalid_operation_combination"], "payload_profile", "payload inventory/order drifted")
    semantic_hashes = {row["id"]: row["expected"]["response_sha256"] for row in bundle.semantic_contract["query_cases"]}
    for row in rows:
        actual = sha256(canonical_bytes(row["response"]))
        require(row.get("response_sha256") == actual, "payload_digest", f"{row.get('id')} digest drifted")
        source = row.get("source_query_case")
        if source is not None:
            require(semantic_hashes.get(source) == actual, "native_identity", f"{row.get('id')} lost native identity")
    default = copy.deepcopy(result["capabilities_default"]["response"])
    restricted = result["capabilities_restricted"]["response"]
    facts = default["records"][0]["facts"]
    facts["budget_defaults"] = {"max_depth": 2, "max_records": 100, "max_relations": 200}
    facts["budget_maxima"] = {"max_depth": 2, "max_records": 100, "max_relations": 200}
    facts["page_default"] = 50
    facts["page_max"] = 50
    facts["source_detail_ceiling"] = "identity"
    default["snapshot"]["content_digest_available"] = False
    default["snapshot"]["source_detail_ceiling"] = "identity"
    require(same_json(default, restricted), "restricted_projection", "restricted capabilities are not the exact schema-preserving lowering")
    return result


def referenced_defs(value: Any) -> set[str]:
    result: set[str] = set()
    if isinstance(value, dict):
        if isinstance(value.get("$ref"), str) and value["$ref"].startswith("#/$defs/"):
            result.add(value["$ref"].removeprefix("#/$defs/"))
        for child in value.values():
            result.update(referenced_defs(child))
    elif isinstance(value, list):
        for child in value:
            result.update(referenced_defs(child))
    return result


def standalone_schema(schema: dict[str, Any], name: str, object_root: bool) -> dict[str, Any]:
    selected: dict[str, Any] = {}
    pending = [name]
    while pending:
        current = pending.pop()
        if current in selected:
            continue
        selected[current] = schema["$defs"][current]
        pending.extend(sorted(referenced_defs(selected[current]) - selected.keys()))
    result: dict[str, Any] = {
        "$schema": schema["$schema"], "$ref": f"#/$defs/{name}",
        "$defs": {key: selected[key] for key in sorted(selected)},
    }
    if object_root:
        result["type"] = "object"
    return result


def expected_frame(fixture: dict[str, Any], bundle: Bundle, payloads: dict[str, dict[str, Any]]) -> Any:
    if fixture["kind"] == "literal":
        return fixture["frame"]
    identity = next(row for row in bundle.contract["server_identities"] if row["id"] == fixture["server"])
    meta = {"io.modelcontextprotocol/serverInfo": {"name": identity["name"], "version": bundle.contract["server_version"]}}
    frame: dict[str, Any] = {"jsonrpc": "2.0", "id": fixture["id_value"]}
    if fixture["kind"] == "discover_response":
        frame["result"] = {
            "_meta": meta, "cacheScope": "public", "capabilities": {"tools": {"listChanged": False}},
            "instructions": bundle.contract["instructions"], "resultType": "complete",
            "supportedVersions": [PROTOCOL_VERSION], "ttlMs": 3600000,
        }
    elif fixture["kind"] == "tools_list_response":
        tools = []
        for row in bundle.contract["tools"]:
            tools.append({
                "annotations": row["annotations"], "description": row["description"],
                "inputSchema": standalone_schema(bundle.schema, row["input_schema_def"], True),
                "name": row["name"],
                "outputSchema": standalone_schema(bundle.schema, row["output_schema_def"], False),
                "title": row["title"],
            })
        frame["result"] = {"_meta": meta, "cacheScope": "public", "resultType": "complete", "tools": tools, "ttlMs": 3600000}
    elif fixture["kind"] == "tool_success_response":
        response = payloads[fixture["payload"]]["response"]
        frame["result"] = {
            "_meta": meta, "content": [{"text": canonical_bytes(response).decode("utf-8"), "type": "text"}],
            "isError": False, "resultType": "complete", "structuredContent": response,
        }
    elif fixture["kind"] == "tool_error_response":
        error = next(row for row in bundle.contract["tool_execution_errors"] if row["id"] == fixture["error"])
        payload = {"contract": "linkedspec-mcp-tool-error-v1", "code": error["code"], "message": error["message"]}
        frame["result"] = {
            "_meta": meta, "content": [{"text": canonical_bytes(payload).decode("utf-8"), "type": "text"}],
            "isError": True, "resultType": "complete",
        }
    else:
        fail("frame_provenance", f"unknown fixture kind {fixture['kind']}")
    return frame


def validate_frames(bundle: Bundle, runtime: SchemaRuntime, payloads: dict[str, dict[str, Any]]) -> None:
    corpus = bundle.corpus
    fixtures = corpus.get("frames")
    require(isinstance(fixtures, list), "corpus_topology", "frames is not an array")
    ids = [row.get("id") for row in fixtures]
    require(len(ids) == len(set(ids)) == 35, "corpus_topology", "frame ids/count drifted")
    require(corpus.get("canonical_order") == ids, "corpus_topology", "canonical order drifted")
    require(len(bundle.frames) == len(fixtures), "frame_topology", "canonical line count drifted")
    limit = bundle.contract["request_limits"]["line_bytes_excluding_delimiter"]
    require(max(len(canonical_bytes(row)) for row in bundle.frames) <= limit, "frame_canonical", "canonical frame exceeds line limit")
    accepted = bundle.validation["frame_schema"]["accepted"]
    rejected = [row["id"] for row in bundle.validation["frame_schema"]["rejected"]]
    require(set(accepted).isdisjoint(rejected) and accepted + rejected == bundle.validation["frame_schema"]["classification_order"], "validation_profile", "frame classification topology drifted")
    require(set(accepted) | set(rejected) == set(ids), "validation_profile", "frame classification is incomplete")
    for fixture, frame in zip(fixtures, bundle.frames, strict=True):
        expected = expected_frame(fixture, bundle, payloads)
        require(same_json(frame, expected), "frame_provenance", f"{fixture['id']} drifted from its independent provenance")
        valid = runtime.matches(frame, bundle.schema)
        if fixture["id"] in accepted:
            require(valid, "schema_instance", f"{fixture['id']} should satisfy the top-level schema")
        else:
            require(not valid, "schema_instance", f"{fixture['id']} should be rejected by the top-level schema")
        if fixture["kind"] == "tool_success_response":
            result = frame["result"]
            require(result["content"][0]["text"].encode("utf-8") == canonical_bytes(result["structuredContent"]), "content_identity", f"{fixture['id']} text/structured identity drifted")
        if fixture["kind"] == "tool_error_response":
            require("structuredContent" not in frame["result"], "content_identity", f"{fixture['id']} exposes structuredContent")
    discover = [bundle.frames[ids.index(f"discover_response_{row['id']}")]["result"]["_meta"]["io.modelcontextprotocol/serverInfo"]["name"] for row in bundle.contract["server_identities"]]
    require(discover == [row["name"] for row in bundle.contract["server_identities"]], "identity_profile", "discovery identity coverage drifted")


def raw_bytes(row: dict[str, Any]) -> bytes:
    encoding = row.get("encoding")
    if encoding == "hex":
        return bytes.fromhex(row["data"])
    if encoding == "utf8":
        return row["data"].encode("utf-8")
    if encoding == "repeat_hex":
        return bytes.fromhex(row["byte"]) * row["count"] + bytes.fromhex(row["suffix"])
    if encoding == "nested_json":
        return ("[" * row["depth"] + "0" + "]" * row["depth"] + "\n").encode("utf-8")
    fail("raw_profile", f"unknown raw encoding {encoding}")


def json_depth(value: Any) -> int:
    if isinstance(value, dict):
        return 1 + max((json_depth(v) for v in value.values()), default=0)
    if isinstance(value, list):
        return 1 + max((json_depth(v) for v in value), default=0)
    return 0


def classify_raw(raw: bytes, bundle: Bundle, runtime: SchemaRuntime) -> dict[str, Any]:
    limits = bundle.contract["request_limits"]
    delimiter = "LF"
    if raw.endswith(b"\r\n"):
        payload = raw[:-2]
        delimiter = "CRLF"
    elif raw.endswith(b"\n"):
        payload = raw[:-1]
    else:
        payload = raw
    if len(payload) > limits["line_bytes_excluding_delimiter"] or payload.startswith(b"\xef\xbb\xbf"):
        return {"code": -32700, "id": None, "message": "Parse error"}
    try:
        text = payload.decode("utf-8", errors="strict")
        def unique(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
            result: dict[str, Any] = {}
            for key, value in pairs:
                if key in result:
                    raise ValueError("duplicate key")
                result[key] = value
            return result
        value = json.loads(text, object_pairs_hook=unique, parse_constant=lambda _: (_ for _ in ()).throw(ValueError("non-finite")))
    except (UnicodeDecodeError, json.JSONDecodeError, ValueError):
        return {"code": -32700, "id": None, "message": "Parse error"}
    if json_depth(value) > limits["json_nesting_depth"]:
        return {"code": -32700, "id": None, "message": "Parse error"}
    if not isinstance(value, dict):
        return {"code": -32600, "id": None, "message": "Invalid Request"}
    request_id = value.get("id")
    request_schema = bundle.schema["$defs"]["requestId"]
    if "id" in value and not runtime.matches(request_id, request_schema):
        return {"code": -32600, "id": None, "message": "Invalid Request"}
    if runtime.matches(value, bundle.schema["$defs"]["discoverRequest"]):
        return {"dispatch": "server/discover", "response_delimiter": "LF", "accepted_delimiter": delimiter}
    return {"code": -32600, "id": request_id if runtime.matches(request_id, request_schema) else None, "message": "Invalid Request"}


def validate_raw_inputs(bundle: Bundle, runtime: SchemaRuntime) -> None:
    rows = bundle.corpus.get("raw_inputs")
    require(isinstance(rows, list), "raw_profile", "raw inputs is not an array")
    ids = [row.get("id") for row in rows]
    require(ids == bundle.validation["scenario_profile"]["raw_input_ids"], "raw_profile", "raw input inventory/order drifted")
    for row in rows:
        raw = raw_bytes(row)
        require(row.get("sha256") == sha256(raw), "raw_digest", f"{row.get('id')} digest drifted")
        actual = classify_raw(raw, bundle, runtime)
        expected = row["expected"]
        if row["id"] == "valid_crlf_discovery":
            actual.pop("accepted_delimiter", None)
        require(same_json(actual, expected), "raw_error_ownership", f"{row['id']} classification drifted")


class LifecycleOracle:
    def __init__(self) -> None:
        self.registry: dict[str, str] = {}
        self.active: set[str] = set()
        self.completed: set[str] = set()
        self.stdout = b""
        self.stderr = b""
        self.cleaned = False

    def execute(self, case: dict[str, Any]) -> str:
        name = case["id"]
        if name == "ready_at_stream_loop_start":
            return "dispatch_without_handshake"
        if name == "cancel_before_response_emission":
            self.active.add("r")
            self.active.remove("r")
            return "stop_and_suppress_response"
        if name == "cancel_unknown_request":
            return "ignore_without_response"
        if name == "cancel_after_sync_completion":
            self.completed.add("r")
            return "completed_response_remains_valid"
        if name == "legacy_initialized_notification":
            return "ignore_without_response"
        if name == "stdout_discipline":
            return "no_stdout_bytes" if self.stdout == b"" else "stdout_polluted"
        if name == "stderr_default":
            return "no_stderr_bytes" if self.stderr == b"" else "stderr_polluted"
        if name == "registry_capacity":
            self.registry = {"expired": "expired", "live": "live"}
            self.registry.pop("expired")
            return "prune_expired_then_refuse_if_still_full"
        if name == "graceful_eof":
            self.registry.clear()
            self.cleaned = True
            return "stop_clear_release_flush_exit_0"
        if name == "unexpected_io_failure":
            self.registry.clear()
            self.cleaned = True
            return "clear_release_sanitized_optional_stderr_exit_nonzero"
        fail("lifecycle_profile", f"unknown lifecycle case {name}")


def validate_stateful_cases(bundle: Bundle) -> None:
    corpus = bundle.corpus
    profile = bundle.validation["scenario_profile"]
    require(HANDLE_RE.fullmatch(corpus.get("illustrative_handle", "")) is not None, "handle_profile", "illustrative handle encoding drifted")
    handles = corpus.get("handle_cases")
    require([row.get("state") for row in handles] == profile["handle_states"], "handle_profile", "handle case inventory drifted")
    require(all(row.get("expected_frame") == "handle_unavailable_response" and row.get("native_dispatch_count") == 0 for row in handles), "handle_profile", "unavailable handles became distinguishable or dispatched")
    policies = corpus.get("policy_cases")
    require([row.get("id") for row in policies] == profile["policy_case_ids"], "policy_profile", "policy case inventory drifted")
    require([row.get("native_dispatch_count") for row in policies] == [1, 1, 1, 0], "policy_profile", "policy dispatch boundary drifted")
    require([row.get("expected_payload", row.get("expected_frame")) for row in policies] == ["capabilities_default", "capabilities_restricted", "graph_list_rules", "policy_denied_response"], "policy_profile", "policy outcome drifted")
    lifecycle = corpus.get("lifecycle_cases")
    require([row.get("id") for row in lifecycle] == profile["lifecycle_case_ids"], "lifecycle_profile", "lifecycle inventory drifted")
    oracle = LifecycleOracle()
    for row in lifecycle:
        require(oracle.execute(row) == row.get("expected"), "lifecycle_oracle", f"{row.get('id')} state transition drifted")


def validate_validation_profile(bundle: Bundle) -> None:
    value = bundle.validation
    require(value.get("format") == 1 and value.get("contract_id") == CONTRACT_ID and value.get("task_owner") == VALIDATION_OWNER, "validation_profile", "validator fixture identity drifted")
    mutations = value.get("mutations")
    require(isinstance(mutations, list), "validation_profile", "mutations is not an array")
    ids = [row.get("id") for row in mutations]
    require(ids == value.get("mutation_order"), "validation_profile", "mutation inventory/order drifted")
    require(len(ids) == len(set(ids)) and len(ids) >= 60, "validation_profile", "mutation corpus is too small or repeats ids")
    required_categories = {"artifact", "authority", "contract", "envelope", "error", "frame", "handle", "identity", "lifecycle", "payload", "policy", "raw", "schema", "validation"}
    require({row.get("category") for row in mutations} == required_categories, "validation_profile", "mutation category coverage drifted")
    for row in mutations:
        require(set(row) >= {"id", "category", "target", "operation", "path", "expected_code"}, "validation_profile", f"mutation {row.get('id')} is incomplete")


def validate_artifact_digests(bundle: Bundle) -> None:
    expected = bundle.contract["artifact_sha256"]
    for name in expected:
        require(sha256(source_bytes(bundle, name)) == expected[name], "artifact_digest", f"{name} digest drifted")
    independent = bundle.validation["normative_sha256"]
    for name, digest in independent.items():
        require(sha256(source_bytes(bundle, name)) == digest, "independent_digest", f"{name} independent digest drifted")


def validate_checker_independence(bundle: Bundle) -> None:
    tree = ast.parse(source_bytes(bundle, "validator").decode("utf-8"), filename=str(CHECKER_PATH))
    imports: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            imports.update(alias.name.split(".")[0] for alias in node.names)
        elif isinstance(node, ast.ImportFrom) and node.module:
            imports.add(node.module.split(".")[0])
    forbidden = {"materialize_mcp_semantic_transport_contract", "requests", "socket", "subprocess", "urllib3"}
    require(not (imports & forbidden), "checker_independence", f"checker imports forbidden modules {sorted(imports & forbidden)}")
    require("materialize_mcp_semantic_transport_contract" not in imports, "checker_independence", "checker imports materializer")


def validate_bundle(bundle: Bundle) -> None:
    validate_validation_profile(bundle)
    validate_contract_profile(bundle)
    validate_schema_document(bundle.schema, bundle.validation, bundle.semantic_contract)
    runtime = SchemaRuntime(bundle.schema)
    payloads = payload_index(bundle)
    validate_frames(bundle, runtime, payloads)
    validate_raw_inputs(bundle, runtime)
    validate_stateful_cases(bundle)
    validate_checker_independence(bundle)
    validate_artifact_digests(bundle)


def pointer_parent(root: Any, pointer: str) -> tuple[Any, str]:
    require(pointer.startswith("/"), "mutation_engine", f"invalid JSON pointer {pointer}")
    parts = [part.replace("~1", "/").replace("~0", "~") for part in pointer[1:].split("/")]
    current = root
    for part in parts[:-1]:
        current = current[int(part)] if isinstance(current, list) else current[part]
    return current, parts[-1]


def apply_mutation(bundle: Bundle, mutation: dict[str, Any]) -> None:
    targets: dict[str, Any] = {
        "contract": bundle.contract, "schema": bundle.schema, "semantic_payloads": bundle.payloads,
        "corpus": bundle.corpus, "canonical_frames": bundle.frames, "validator_cases": bundle.validation,
    }
    target = targets.get(mutation["target"])
    require(target is not None, "mutation_engine", f"unknown target {mutation['target']}")
    bundle.mutated.add(mutation["target"])
    parent, key = pointer_parent(target, mutation["path"])
    operation = mutation["operation"]
    if operation == "delete":
        if isinstance(parent, list):
            parent.pop(int(key))
        else:
            del parent[key]
    elif operation == "replace":
        if isinstance(parent, list):
            parent[int(key)] = mutation["value"]
        else:
            parent[key] = mutation["value"]
    elif operation == "add":
        require(isinstance(parent, dict) and key not in parent, "mutation_engine", f"{mutation['path']} already exists")
        parent[key] = mutation["value"]
    elif operation == "append":
        value = parent[int(key)] if isinstance(parent, list) else parent[key]
        require(isinstance(value, list), "mutation_engine", f"{mutation['path']} is not an array")
        value.append(mutation["value"])
    elif operation == "swap":
        value = parent[int(key)] if isinstance(parent, list) else parent[key]
        left, right = mutation["indices"]
        value[left], value[right] = value[right], value[left]
    else:
        fail("mutation_engine", f"unsupported operation {operation}")


def run_mutations(base: Bundle) -> None:
    for mutation in base.validation["mutations"]:
        changed = copy.deepcopy(base)
        apply_mutation(changed, mutation)
        try:
            validate_bundle(changed)
        except ContractError as exc:
            require(exc.code == mutation["expected_code"], "mutation_expectation", f"{mutation['id']} expected {mutation['expected_code']} but got {exc.code}: {exc}")
        else:
            fail("mutation_survived", mutation["id"])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--skip-mutations", action="store_true", help="run only the positive independent validation")
    args = parser.parse_args()
    bundle = load_bundle()
    validate_bundle(bundle)
    mutation_count = 0
    if not args.skip_mutations:
        run_mutations(bundle)
        mutation_count = len(bundle.validation["mutations"])
    print(
        "MCP semantic transport contract: "
        f"{len(bundle.frames)} frames, {len(bundle.corpus['raw_inputs'])} raw inputs, "
        f"{len(bundle.corpus['lifecycle_cases'])} lifecycle cases, "
        f"{mutation_count} rejected mutations"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

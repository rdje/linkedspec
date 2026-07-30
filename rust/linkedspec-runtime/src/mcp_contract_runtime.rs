//! Frozen runtime over the generated, filesystem-free MCP contract binding.

use crate::mcp_contract::{BINDING_FORMAT, BUNDLE_JSON, BUNDLE_SHA256};
use serde_json::{Map, Value, json};
use sha2::{Digest, Sha256};
use std::fmt::Write as _;
use std::sync::OnceLock;

#[derive(Debug, Clone)]
struct ContractError(&'static str);

struct Bundle {
    root: Value,
}

static BUNDLE: OnceLock<Result<Bundle, ContractError>> = OnceLock::new();

fn bundle() -> Result<&'static Bundle, ContractError> {
    BUNDLE
        .get_or_init(|| {
            let actual = Sha256::digest(BUNDLE_JSON.as_bytes());
            let mut actual_hex = String::with_capacity(64);
            for byte in actual {
                write!(&mut actual_hex, "{byte:02x}").expect("writing to String cannot fail");
            }
            if actual_hex != BUNDLE_SHA256 {
                return Err(ContractError("generated MCP contract digest mismatch"));
            }
            let root: Value = serde_json::from_str(BUNDLE_JSON)
                .map_err(|_| ContractError("generated MCP contract cannot be decoded"))?;
            if root.get("binding_format").and_then(Value::as_u64) != Some(u64::from(BINDING_FORMAT))
            {
                return Err(ContractError("unsupported generated MCP contract binding"));
            }
            if !root
                .get("semantic_payloads")
                .and_then(|value| value.get("payloads"))
                .is_some_and(Value::is_array)
            {
                return Err(ContractError(
                    "generated MCP semantic payload inventory is invalid",
                ));
            }
            Ok(Bundle { root })
        })
        .as_ref()
        .map_err(Clone::clone)
}

pub(crate) fn contract() -> Result<Value, &'static str> {
    member("contract")
}

pub(crate) fn protocol_version() -> Result<&'static str, &'static str> {
    bundle()
        .map_err(|error| error.0)?
        .root
        .get("contract")
        .and_then(|value| value.get("protocol_version"))
        .and_then(Value::as_str)
        .ok_or("generated MCP protocol version is invalid")
}

fn member(name: &str) -> Result<Value, &'static str> {
    bundle()
        .map_err(|error| error.0)?
        .root
        .get(name)
        .cloned()
        .ok_or("generated MCP contract member is missing")
}

pub(crate) fn frame(name: &str) -> Result<Option<Value>, &'static str> {
    let frames = bundle()
        .map_err(|error| error.0)?
        .root
        .get("canonical_frames")
        .and_then(Value::as_object)
        .ok_or("generated MCP frame inventory is invalid")?;
    Ok(frames.get(name).cloned())
}

pub(crate) fn canonical_json(value: &Value) -> Result<String, &'static str> {
    serde_json::to_string(value).map_err(|_| "value is not canonical JSON data")
}

pub(crate) fn validate_named(name: &str, value: &Value) -> bool {
    let Ok(bundle) = bundle() else {
        return false;
    };
    let Some(schema) = bundle
        .root
        .get("schema")
        .and_then(|value| value.get("$defs"))
        .and_then(|value| value.get(name))
    else {
        return false;
    };
    validate(value, schema, &bundle.root["schema"], 0).is_ok()
}

pub(crate) fn validate_frame(value: &Value) -> bool {
    let Ok(bundle) = bundle() else {
        return false;
    };
    validate(value, &bundle.root["schema"], &bundle.root["schema"], 0).is_ok()
}

fn validate(value: &Value, schema: &Value, root: &Value, depth: usize) -> Result<(), ()> {
    if depth > 256 {
        return Err(());
    }
    if let Some(accepted) = schema.as_bool() {
        return accepted.then_some(()).ok_or(());
    }
    let object = schema.as_object().ok_or(())?;

    if let Some(reference) = object.get("$ref").and_then(Value::as_str) {
        let name = reference.strip_prefix("#/$defs/").ok_or(())?;
        if name.contains('/') {
            return Err(());
        }
        let definition = root
            .get("$defs")
            .and_then(|value| value.get(name))
            .ok_or(())?;
        validate(value, definition, root, depth + 1)?;
    }

    if let Some(types) = object.get("type") {
        let matches = match types {
            Value::String(kind) => has_type(value, kind),
            Value::Array(kinds) => kinds
                .iter()
                .filter_map(Value::as_str)
                .any(|kind| has_type(value, kind)),
            _ => false,
        };
        if !matches {
            return Err(());
        }
    }
    if object
        .get("const")
        .is_some_and(|expected| expected != value)
    {
        return Err(());
    }
    if let Some(values) = object.get("enum").and_then(Value::as_array)
        && !values.iter().any(|expected| expected == value)
    {
        return Err(());
    }
    if let Some(branches) = object.get("oneOf").and_then(Value::as_array) {
        let matches = branches
            .iter()
            .filter(|branch| validate(value, branch, root, depth + 1).is_ok())
            .count();
        if matches != 1 {
            return Err(());
        }
    }
    if let Some(branches) = object.get("allOf").and_then(Value::as_array) {
        for branch in branches {
            validate(value, branch, root, depth + 1)?;
        }
    }

    if let Some(instance) = value.as_object() {
        validate_object(instance, object, root, depth)?;
    }
    if let Some(instance) = value.as_array() {
        validate_array(instance, object, root, depth)?;
    }
    if let Some(instance) = value.as_str() {
        validate_string(instance, object)?;
    }
    if is_integer(value) {
        validate_integer(value, object)?;
    }
    Ok(())
}

fn validate_object(
    instance: &Map<String, Value>,
    schema: &Map<String, Value>,
    root: &Value,
    depth: usize,
) -> Result<(), ()> {
    if schema
        .get("maxProperties")
        .and_then(Value::as_u64)
        .is_some_and(|maximum| instance.len() as u64 > maximum)
    {
        return Err(());
    }
    if let Some(required) = schema.get("required").and_then(Value::as_array) {
        for name in required.iter().filter_map(Value::as_str) {
            if !instance.contains_key(name) {
                return Err(());
            }
        }
    }
    let properties = schema.get("properties").and_then(Value::as_object);
    for (name, child) in instance {
        if let Some(property_names) = schema.get("propertyNames") {
            validate(
                &Value::String(name.clone()),
                property_names,
                root,
                depth + 1,
            )?;
        }
        if let Some(child_schema) = properties.and_then(|values| values.get(name)) {
            validate(child, child_schema, root, depth + 1)?;
            continue;
        }
        match schema.get("additionalProperties") {
            Some(Value::Bool(false)) => return Err(()),
            Some(child_schema @ Value::Object(_)) => {
                validate(child, child_schema, root, depth + 1)?;
            }
            _ => {}
        }
    }
    Ok(())
}

fn validate_array(
    instance: &[Value],
    schema: &Map<String, Value>,
    root: &Value,
    depth: usize,
) -> Result<(), ()> {
    let prefix = schema
        .get("prefixItems")
        .and_then(Value::as_array)
        .map_or(&[][..], Vec::as_slice);
    for (child, child_schema) in instance.iter().zip(prefix) {
        validate(child, child_schema, root, depth + 1)?;
    }
    if let Some(item_schema) = schema.get("items") {
        for child in instance.iter().skip(prefix.len()) {
            validate(child, item_schema, root, depth + 1)?;
        }
    }
    if schema
        .get("minItems")
        .and_then(Value::as_u64)
        .is_some_and(|minimum| (instance.len() as u64) < minimum)
        || schema
            .get("maxItems")
            .and_then(Value::as_u64)
            .is_some_and(|maximum| instance.len() as u64 > maximum)
    {
        return Err(());
    }
    Ok(())
}

fn validate_string(instance: &str, schema: &Map<String, Value>) -> Result<(), ()> {
    let characters = instance.chars().count() as u64;
    if schema
        .get("minLength")
        .and_then(Value::as_u64)
        .is_some_and(|minimum| characters < minimum)
        || schema
            .get("maxLength")
            .and_then(Value::as_u64)
            .is_some_and(|maximum| characters > maximum)
        || schema
            .get("x-linkedspec-maxUtf8Bytes")
            .and_then(Value::as_u64)
            .is_some_and(|maximum| instance.len() as u64 > maximum)
    {
        return Err(());
    }
    if let Some(pattern) = schema.get("pattern").and_then(Value::as_str) {
        let matches = match pattern {
            "^[A-Za-z0-9_-]{43}$" => {
                instance.len() == 43
                    && instance
                        .bytes()
                        .all(|byte| byte.is_ascii_alphanumeric() || byte == b'_' || byte == b'-')
            }
            "^sha256:[0-9a-f]{64}$" => {
                instance.len() == 71
                    && instance.starts_with("sha256:")
                    && instance[7..]
                        .bytes()
                        .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
            }
            _ => return Err(()),
        };
        if !matches {
            return Err(());
        }
    }
    if schema.get("format").and_then(Value::as_str) == Some("uri") && !is_uri(instance) {
        return Err(());
    }
    Ok(())
}

fn validate_integer(instance: &Value, schema: &Map<String, Value>) -> Result<(), ()> {
    let number = if let Some(value) = instance.as_i64() {
        i128::from(value)
    } else {
        i128::from(instance.as_u64().ok_or(())?)
    };
    if schema
        .get("minimum")
        .and_then(json_integer)
        .is_some_and(|minimum| number < minimum)
        || schema
            .get("maximum")
            .and_then(json_integer)
            .is_some_and(|maximum| number > maximum)
    {
        return Err(());
    }
    Ok(())
}

fn json_integer(value: &Value) -> Option<i128> {
    value
        .as_i64()
        .map(i128::from)
        .or_else(|| value.as_u64().map(i128::from))
}

fn has_type(value: &Value, kind: &str) -> bool {
    match kind {
        "null" => value.is_null(),
        "boolean" => value.is_boolean(),
        "array" => value.is_array(),
        "object" => value.is_object(),
        "string" => value.is_string(),
        "integer" => is_integer(value),
        _ => false,
    }
}

fn is_integer(value: &Value) -> bool {
    value.as_i64().is_some() || value.as_u64().is_some()
}

fn is_uri(value: &str) -> bool {
    let Some((scheme, _)) = value.split_once(':') else {
        return false;
    };
    let mut bytes = scheme.bytes();
    bytes.next().is_some_and(|byte| byte.is_ascii_alphabetic())
        && bytes.all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'+' | b'.' | b'-'))
}

fn set_server_name(response: &mut Value, name: &str) -> Result<(), &'static str> {
    let slot = response
        .pointer_mut("/result/_meta/io.modelcontextprotocol~1serverInfo/name")
        .ok_or("generated MCP response has no server identity")?;
    *slot = Value::String(name.to_string());
    Ok(())
}

fn set_id(response: &mut Value, id: &Value) -> Result<(), &'static str> {
    let slot = response
        .get_mut("id")
        .ok_or("generated MCP response has no request id")?;
    *slot = id.clone();
    Ok(())
}

pub(crate) fn discover_response(id: &Value) -> Result<Value, &'static str> {
    let mut response =
        frame("discover_response_rust")?.ok_or("generated Rust discover response is missing")?;
    set_id(&mut response, id)?;
    Ok(response)
}

pub(crate) fn tools_list_response(id: &Value) -> Result<Value, &'static str> {
    let mut response =
        frame("tools_list_response_perl")?.ok_or("generated tools-list response is missing")?;
    set_server_name(&mut response, "linkedspec-semantic-rust")?;
    set_id(&mut response, id)?;
    Ok(response)
}

pub(crate) fn tool_success_response(id: &Value, payload: &Value) -> Result<Value, &'static str> {
    if !validate_named("semanticQueryResponse", payload) {
        return Err("native semantic response violates the MCP schema");
    }
    let mut response =
        frame("capabilities_call_response")?.ok_or("generated tool-success response is missing")?;
    set_server_name(&mut response, "linkedspec-semantic-rust")?;
    set_id(&mut response, id)?;
    response["result"]["structuredContent"] = payload.clone();
    response["result"]["content"][0]["text"] = Value::String(canonical_json(payload)?);
    Ok(response)
}

pub(crate) fn tool_error_response(id: &Value, unavailable: bool) -> Result<Value, &'static str> {
    let mut response =
        frame("policy_denied_response")?.ok_or("generated tool-error response is missing")?;
    set_server_name(&mut response, "linkedspec-semantic-rust")?;
    if unavailable {
        let unavailable = frame("handle_unavailable_response")?
            .ok_or("generated unavailable-handle response is missing")?;
        response["result"]["content"] = unavailable["result"]["content"].clone();
    }
    set_id(&mut response, id)?;
    Ok(response)
}

pub(crate) fn json_rpc_error(
    id: Option<&Value>,
    kind: &str,
    requested: Option<&str>,
) -> Result<Value, &'static str> {
    let contract = contract()?;
    let (code, message) = if kind == "legacy_initialize" {
        let row = contract
            .get("legacy_diagnostic")
            .and_then(Value::as_object)
            .ok_or("generated legacy diagnostic is invalid")?;
        (
            row.get("code")
                .and_then(Value::as_i64)
                .ok_or("generated legacy code is invalid")?,
            row.get("message")
                .and_then(Value::as_str)
                .ok_or("generated legacy message is invalid")?,
        )
    } else {
        let owner = match kind {
            "parse_error" => "invalid_utf8",
            "invalid_request" => "invalid_envelope",
            "method_not_found" => "unknown_method",
            "invalid_params" => "method_params",
            "internal_error" => "sanitized_unexpected_failure",
            "unsupported_version" => "unsupported_protocol_version",
            _ => return Err("unknown MCP JSON-RPC error"),
        };
        let row = contract
            .get("json_rpc_errors")
            .and_then(Value::as_array)
            .and_then(|rows| {
                rows.iter().find(|row| {
                    row.get("owns")
                        .and_then(Value::as_array)
                        .is_some_and(|values| {
                            values.iter().any(|value| value.as_str() == Some(owner))
                        })
                })
            })
            .ok_or("generated MCP JSON-RPC error inventory is invalid")?;
        (
            row.get("code")
                .and_then(Value::as_i64)
                .ok_or("generated error code is invalid")?,
            row.get("message")
                .and_then(Value::as_str)
                .ok_or("generated error message is invalid")?,
        )
    };
    let mut error = json!({"code": code, "message": message});
    if kind == "unsupported_version" {
        error["data"] = json!({
            "requested": requested.unwrap_or(""),
            "supported": [protocol_version()?],
        });
    }
    Ok(json!({
        "jsonrpc": "2.0",
        "id": id.cloned().unwrap_or(Value::Null),
        "error": error,
    }))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_bundle_is_valid_and_clone_isolated() {
        assert_eq!(protocol_version().unwrap(), "2026-07-28");
        let mut first = contract().unwrap();
        first["protocol_version"] = Value::String("mutated".to_string());
        assert_eq!(contract().unwrap()["protocol_version"], "2026-07-28");
        assert!(validate_frame(&frame("discover_request").unwrap().unwrap()));
    }

    #[test]
    fn frozen_schema_profile_checks_patterns_and_object_closure() {
        let handle = Value::String("A".repeat(43));
        assert!(validate_named("handle", &handle));
        assert!(!validate_named("handle", &Value::String("A".repeat(42))));
        let request = frame("discover_request").unwrap().unwrap();
        assert!(validate_named("discoverRequest", &request));
        let mut extra = request;
        extra["extra"] = Value::Bool(true);
        assert!(!validate_named("discoverRequest", &extra));
        let mut query =
            frame("query_call_request").unwrap().unwrap()["params"]["arguments"]["request"].clone();
        query["contract"] = Value::String("linkedspec-semantic-query-v2".to_string());
        assert!(validate_named("semanticQueryRequest", &query));
        query["contract"] = Value::String("a".repeat(128));
        assert!(validate_named("semanticQueryRequest", &query));
        query["contract"] = Value::String(String::new());
        assert!(!validate_named("semanticQueryRequest", &query));
        query["contract"] = Value::String("a".repeat(129));
        assert!(!validate_named("semanticQueryRequest", &query));
        query["contract"] = Value::String("é".repeat(65));
        assert!(!validate_named("semanticQueryRequest", &query));
    }

    #[test]
    fn frozen_top_level_schema_classifies_the_canonical_corpus_exactly() {
        const ACCEPTED: &[&str] = &[
            "discover_request",
            "discover_response_perl",
            "discover_response_rust",
            "discover_response_dart",
            "discover_response_julia",
            "discover_response_lua",
            "tools_list_request",
            "tools_list_response_perl",
            "capabilities_call_request",
            "capabilities_call_response",
            "query_call_request",
            "query_call_response",
            "semantic_ok_false_request",
            "semantic_ok_false_response",
            "restricted_capabilities_request",
            "restricted_capabilities_response",
            "handle_unavailable_request",
            "handle_unavailable_response",
            "policy_denied_request",
            "policy_denied_response",
            "cancelled_notification",
            "unsupported_version_response",
            "missing_metadata_response",
            "legacy_initialize_response",
            "unknown_method_response",
            "unknown_tool_response",
            "malformed_arguments_response",
            "sanitized_internal_error_response",
        ];
        const REJECTED: &[&str] = &[
            "unsupported_version_request",
            "missing_metadata_request",
            "legacy_initialize_request",
            "legacy_initialized_notification",
            "unknown_method_request",
            "unknown_tool_request",
            "malformed_arguments_request",
        ];

        for name in ACCEPTED {
            let value = frame(name).unwrap().unwrap();
            assert!(validate_frame(&value), "{name} must be schema-accepted");
        }
        for name in REJECTED {
            let value = frame(name).unwrap().unwrap();
            assert!(!validate_frame(&value), "{name} must be schema-rejected");
        }
    }

    #[test]
    fn rust_response_shells_have_native_identity() {
        let id = Value::String("request".to_string());
        let discover = discover_response(&id).unwrap();
        let tools = tools_list_response(&id).unwrap();
        assert_eq!(
            discover.pointer("/result/_meta/io.modelcontextprotocol~1serverInfo/name"),
            Some(&Value::String("linkedspec-semantic-rust".to_string()))
        );
        assert_eq!(
            tools.pointer("/result/_meta/io.modelcontextprotocol~1serverInfo/name"),
            Some(&Value::String("linkedspec-semantic-rust".to_string()))
        );
    }
}

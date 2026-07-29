//! FUTURE-PARITY-BACKLOG.10.9.3.1 — public Rust decoded MCP dispatch proof.

use linkedspec_runtime::{
    McpBudgetLimits, McpDeploymentPolicy, McpRegistrationOptions, McpServer,
    semantic_index::{SemanticIndex, SemanticIndexOptions, SemanticSourceDetail},
};
use serde_json::Value;
use std::sync::Arc;

const CORPUS: &str =
    include_str!("../../../capability_conformance/mcp_semantic_transport/corpus.json");
const CANONICAL_FRAMES: &str =
    include_str!("../../../capability_conformance/mcp_semantic_transport/canonical_frames.jsonl");
const GRAPH: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/graph.spec");
const RUST_SERVER: &str = "linkedspec-semantic-rust";

fn frame(name: &str) -> Value {
    let corpus: Value = serde_json::from_str(CORPUS).expect("MCP corpus parses");
    let rows = corpus["frames"].as_array().expect("MCP corpus frames");
    let position = rows
        .iter()
        .position(|row| row["id"] == name)
        .unwrap_or_else(|| panic!("missing MCP corpus frame {name}"));
    let lines = CANONICAL_FRAMES.lines().collect::<Vec<_>>();
    assert_eq!(lines.len(), rows.len(), "canonical frame order is complete");
    serde_json::from_str(lines[position]).expect("canonical MCP frame parses")
}

fn rust_identity(mut response: Value) -> Value {
    let name = response
        .pointer_mut("/result/_meta/io.modelcontextprotocol~1serverInfo/name")
        .expect("tool response carries a server identity");
    *name = Value::String(RUST_SERVER.to_string());
    response
}

fn graph_index() -> Arc<SemanticIndex> {
    Arc::new(
        SemanticIndex::from_utf8(
            GRAPH,
            SemanticIndexOptions::new("graph.spec", SemanticSourceDetail::Text),
        )
        .expect("graph semantic index constructs"),
    )
}

fn with_handle(mut request: Value, handle: &str) -> Value {
    request["params"]["arguments"]["handle"] = Value::String(handle.to_string());
    request
}

fn response(server: &mut McpServer, request: &Value, authorization: &[u8]) -> Value {
    server
        .dispatch(request, authorization)
        .expect("decoded dispatch has no host failure")
        .expect("request produces a response")
}

#[test]
fn public_static_dispatch_matches_every_owned_canonical_classification() {
    let mut server = McpServer::new().expect("production MCP server constructs");
    for (request_name, response_name, native_identity) in [
        ("discover_request", "discover_response_rust", false),
        ("tools_list_request", "tools_list_response_perl", true),
        (
            "unsupported_version_request",
            "unsupported_version_response",
            false,
        ),
        (
            "missing_metadata_request",
            "missing_metadata_response",
            false,
        ),
        (
            "legacy_initialize_request",
            "legacy_initialize_response",
            false,
        ),
        ("unknown_method_request", "unknown_method_response", false),
        ("unknown_tool_request", "unknown_tool_response", false),
        (
            "malformed_arguments_request",
            "malformed_arguments_response",
            false,
        ),
    ] {
        let request = frame(request_name);
        let request_before = request.clone();
        let expected = if native_identity {
            rust_identity(frame(response_name))
        } else {
            frame(response_name)
        };
        assert_eq!(
            response(&mut server, &request, b"public-static-principal"),
            expected,
            "{request_name} exact response"
        );
        assert_eq!(request, request_before, "{request_name} clone isolation");
    }

    assert_eq!(
        server
            .dispatch(
                &frame("legacy_initialized_notification"),
                b"public-static-principal"
            )
            .expect("legacy notification dispatches"),
        None
    );
    assert_eq!(
        server
            .dispatch(
                &serde_json::json!({
                    "jsonrpc": "2.0",
                    "method": "notifications/host_private"
                }),
                b"public-static-principal"
            )
            .expect("unknown notification dispatches"),
        None
    );
}

#[test]
fn public_registration_preserves_exact_native_payloads_and_lowers_policy_only() {
    let index = graph_index();
    let mut server = McpServer::new().expect("production MCP server constructs");
    let handle = server
        .register_index(
            Arc::clone(&index),
            b"native-principal",
            McpRegistrationOptions::default(),
        )
        .expect("native graph index registers");
    assert_eq!(handle.len(), 43);
    assert!(
        handle
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'_' | b'-'))
    );

    let capabilities = with_handle(frame("capabilities_call_request"), &handle);
    let capabilities_before = capabilities.clone();
    assert_eq!(
        response(&mut server, &capabilities, b"native-principal"),
        rust_identity(frame("capabilities_call_response"))
    );
    assert_eq!(capabilities, capabilities_before);

    let query = with_handle(frame("query_call_request"), &handle);
    let query_before = query.clone();
    assert_eq!(
        response(&mut server, &query, b"native-principal"),
        frame("query_call_response")
    );
    assert_eq!(query, query_before);

    let restricted = server
        .register_index(
            Arc::clone(&index),
            b"restricted-principal",
            McpRegistrationOptions {
                lifetime_ms: None,
                policy: Some(McpDeploymentPolicy {
                    source_detail_ceiling: Some(SemanticSourceDetail::Identity),
                    page_max: Some(50),
                    budget_maxima: Some(McpBudgetLimits {
                        max_records: 100,
                        max_relations: 200,
                        max_depth: 2,
                    }),
                }),
            },
        )
        .expect("lowering-only policy registers");
    let restricted_capabilities =
        with_handle(frame("restricted_capabilities_request"), &restricted);
    assert_eq!(
        response(
            &mut server,
            &restricted_capabilities,
            b"restricted-principal"
        ),
        rust_identity(frame("restricted_capabilities_response"))
    );
    let denied = with_handle(frame("policy_denied_request"), &restricted);
    assert_eq!(
        response(&mut server, &denied, b"restricted-principal"),
        rust_identity(frame("policy_denied_response"))
    );

    for policy in [
        McpDeploymentPolicy {
            page_max: Some(1_001),
            ..McpDeploymentPolicy::default()
        },
        McpDeploymentPolicy {
            budget_maxima: Some(McpBudgetLimits {
                max_records: 10_001,
                max_relations: 2_000,
                max_depth: 4,
            }),
            ..McpDeploymentPolicy::default()
        },
    ] {
        let error = server
            .register_index(
                Arc::clone(&index),
                b"invalid-policy-principal",
                McpRegistrationOptions {
                    lifetime_ms: None,
                    policy: Some(policy),
                },
            )
            .expect_err("elevating policy fails closed");
        assert_eq!(error.code, "linkedspec_mcp_invalid_policy");
    }
}

#[test]
fn unavailable_states_validation_and_shutdown_are_publicly_safe() {
    let index = graph_index();
    let mut server = McpServer::new().expect("production MCP server constructs");
    let expected_unavailable = rust_identity(frame("handle_unavailable_response"));
    assert_eq!(
        response(
            &mut server,
            &frame("handle_unavailable_request"),
            b"state-principal"
        ),
        expected_unavailable
    );

    let unauthorized = server
        .register_index(
            Arc::clone(&index),
            b"state-principal",
            McpRegistrationOptions::default(),
        )
        .expect("unauthorized-state handle registers");
    assert_eq!(
        response(
            &mut server,
            &with_handle(frame("handle_unavailable_request"), &unauthorized),
            b"wrong-principal"
        ),
        expected_unavailable
    );

    server
        .revoke_handle(&unauthorized)
        .expect("host revocation succeeds");
    server
        .revoke_handle(&unauthorized)
        .expect("repeated host revocation is state-neutral");
    assert_eq!(
        response(
            &mut server,
            &with_handle(frame("handle_unavailable_request"), &unauthorized),
            b"state-principal"
        ),
        expected_unavailable
    );

    for authorization in [&[][..], &[b'x'; 4_097][..]] {
        assert_eq!(
            server
                .register_index(
                    Arc::clone(&index),
                    authorization,
                    McpRegistrationOptions::default()
                )
                .expect_err("invalid authorization fails closed")
                .code,
            "linkedspec_mcp_invalid_authorization"
        );
    }
    for lifetime_ms in [0, 86_400_001] {
        assert_eq!(
            server
                .register_index(
                    Arc::clone(&index),
                    b"state-principal",
                    McpRegistrationOptions {
                        lifetime_ms: Some(lifetime_ms),
                        policy: None,
                    }
                )
                .expect_err("invalid lifetime fails closed")
                .code,
            "linkedspec_mcp_invalid_registration"
        );
    }

    let retained = Arc::downgrade(&index);
    server
        .register_index(
            Arc::clone(&index),
            b"release-principal",
            McpRegistrationOptions::default(),
        )
        .expect("release-state handle registers");
    drop(index);
    assert!(retained.upgrade().is_some());
    server.shutdown();
    server.shutdown();
    assert!(retained.upgrade().is_none());
    assert_eq!(
        response(&mut server, &frame("discover_request"), b"state-principal")["error"]["code"],
        -32603
    );
    assert_eq!(
        server
            .register_index(
                graph_index(),
                b"state-principal",
                McpRegistrationOptions::default()
            )
            .expect_err("stopped server accepts no registrations")
            .code,
        "linkedspec_mcp_server_shutdown"
    );
}

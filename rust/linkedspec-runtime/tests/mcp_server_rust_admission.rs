//! FUTURE-PARITY-BACKLOG.10.9.3.3 — exact twelve-role Rust MCP admission.

use linkedspec_runtime::{
    McpBudgetLimits, McpDeploymentPolicy, McpRegistrationOptions, McpServer, McpServerError,
    semantic_index::{SemanticIndex, SemanticIndexOptions, SemanticSourceDetail},
};
use serde_json::Value;
use sha2::{Digest, Sha256};
use std::hint::spin_loop;
use std::io::{self, Cursor, Read, Write};
use std::sync::Arc;
use std::time::{Duration, Instant};

const ROLE_ORDER: [&str; 12] = [
    "contract_inventory",
    "canonical_static_dispatch",
    "native_capabilities_identity",
    "native_query_identity",
    "raw_input_outcomes",
    "lifecycle_outcomes",
    "handle_state_indistinguishability",
    "policy_overlay",
    "cancellation_emission",
    "shutdown_and_io",
    "hostile_output_and_log_privacy",
    "authority_surface_fences",
];

const CORPUS: &str =
    include_str!("../../../capability_conformance/mcp_semantic_transport/corpus.json");
const CANONICAL_FRAMES: &str =
    include_str!("../../../capability_conformance/mcp_semantic_transport/canonical_frames.jsonl");
const VALIDATOR_CASES: &[u8] =
    include_bytes!("../../../capability_conformance/mcp_semantic_transport/validator_cases.json");
const TRANSPORT: &str =
    include_str!("../../../capability_conformance/mcp_semantic_transport_contract.json");
const GRAPH: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/graph.spec");
const MCP_CONTRACT_SOURCE: &str = include_str!("../src/mcp_contract.rs");
const MCP_RUNTIME_SOURCE: &str = include_str!("../src/mcp_contract_runtime.rs");
const MCP_SERVER_SOURCE: &str = include_str!("../src/mcp_server.rs");
const MCP_WIRE_SOURCE: &str = include_str!("../src/mcp_wire.rs");
const PRIMARY_CLI_SOURCE: &str = include_str!("../../../bin/linkedspec");
const RUST_SERVER: &str = "linkedspec-semantic-rust";
const IO_LOG_RECORD: &[u8] = b"linkedspec_mcp_io_failure\n";

fn corpus() -> Value {
    serde_json::from_str(CORPUS).expect("MCP corpus parses")
}

fn frame(name: &str) -> Value {
    let corpus = corpus();
    let rows = corpus["frames"].as_array().expect("MCP corpus frames");
    let position = rows
        .iter()
        .position(|row| row["id"] == name)
        .unwrap_or_else(|| panic!("missing MCP corpus frame {name}"));
    let lines = CANONICAL_FRAMES.lines().collect::<Vec<_>>();
    assert_eq!(lines.len(), rows.len(), "canonical frame order is complete");
    serde_json::from_str(lines[position]).expect("canonical MCP frame parses")
}

fn canonical(value: &Value) -> String {
    serde_json::to_string(value).expect("JSON value serializes canonically")
}

fn frame_bytes(value: &Value) -> Vec<u8> {
    let mut bytes = canonical(value).into_bytes();
    bytes.push(b'\n');
    bytes
}

fn error_bytes(code: i64, message: &str) -> Vec<u8> {
    frame_bytes(&serde_json::json!({
        "error": {"code": code, "message": message},
        "id": null,
        "jsonrpc": "2.0",
    }))
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

fn run_stream(
    server: &mut McpServer,
    bytes: Vec<u8>,
    authorization: &[u8],
) -> Result<(Vec<u8>, Vec<u8>), McpServerError> {
    let mut input = Cursor::new(bytes);
    let mut output = Vec::new();
    let mut log = Vec::new();
    server
        .serve_stdio(&mut input, &mut output, authorization, Some(&mut log))
        .map(|()| (output, log))
}

fn raw_fixture(row: &Value) -> Vec<u8> {
    match row["encoding"].as_str().expect("raw encoding") {
        "hex" => decode_hex(row["data"].as_str().expect("hex data")),
        "utf8" => row["data"]
            .as_str()
            .expect("UTF-8 data")
            .as_bytes()
            .to_vec(),
        "repeat_hex" => {
            let byte = decode_hex(row["byte"].as_str().expect("repeat byte"))[0];
            let count = usize::try_from(row["count"].as_u64().expect("repeat count"))
                .expect("repeat count fits usize");
            let mut bytes = vec![byte; count];
            bytes.extend(decode_hex(row["suffix"].as_str().expect("repeat suffix")));
            bytes
        }
        "nested_json" => {
            let depth = usize::try_from(row["depth"].as_u64().expect("nesting depth"))
                .expect("nesting depth fits usize");
            let mut bytes = vec![b'['; depth];
            bytes.push(b'0');
            bytes.extend(std::iter::repeat_n(b']', depth));
            bytes.push(b'\n');
            bytes
        }
        encoding => panic!("unknown raw fixture encoding {encoding}"),
    }
}

fn decode_hex(hex: &str) -> Vec<u8> {
    assert_eq!(hex.len() % 2, 0, "hex fixture has whole bytes");
    hex.as_bytes()
        .chunks_exact(2)
        .map(|pair| {
            let pair = std::str::from_utf8(pair).expect("hex is ASCII");
            u8::from_str_radix(pair, 16).expect("hex byte parses")
        })
        .collect()
}

fn sha256_hex(bytes: &[u8]) -> String {
    Sha256::digest(bytes)
        .iter()
        .map(|byte| format!("{byte:02x}"))
        .collect()
}

fn wait_for_lifetime_tick() {
    let start = Instant::now();
    while start.elapsed() < Duration::from_millis(3) {
        spin_loop();
    }
}

fn admission_role(roles_seen: &mut Vec<&'static str>, role: &'static str, proof: impl FnOnce()) {
    roles_seen.push(role);
    proof();
}

struct FailingReader;

impl Read for FailingReader {
    fn read(&mut self, _buffer: &mut [u8]) -> io::Result<usize> {
        Err(io::Error::other(
            "private=/private/secret principal=admission response=hostile",
        ))
    }
}

struct ChunkThenFailReader {
    chunk: Option<Vec<u8>>,
}

impl Read for ChunkThenFailReader {
    fn read(&mut self, buffer: &mut [u8]) -> io::Result<usize> {
        let Some(chunk) = self.chunk.take() else {
            return Err(io::Error::other("private later input failure"));
        };
        assert!(chunk.len() <= buffer.len());
        buffer[..chunk.len()].copy_from_slice(&chunk);
        Ok(chunk.len())
    }
}

struct FailingWriter;

impl Write for FailingWriter {
    fn write(&mut self, _buffer: &[u8]) -> io::Result<usize> {
        Err(io::Error::other("private output path and response"))
    }

    fn flush(&mut self) -> io::Result<()> {
        Ok(())
    }
}

#[derive(Default)]
struct FlushFailingWriter {
    bytes: Vec<u8>,
}

impl Write for FlushFailingWriter {
    fn write(&mut self, buffer: &[u8]) -> io::Result<usize> {
        self.bytes.extend_from_slice(buffer);
        Ok(buffer.len())
    }

    fn flush(&mut self) -> io::Result<()> {
        Err(io::Error::other("private flush path and handle"))
    }
}

#[test]
fn exact_rust_mcp_admission_executes_every_role_once() {
    let mut roles_seen = Vec::new();

    admission_role(&mut roles_seen, "contract_inventory", || {
        let corpus = corpus();
        let frame_ids = corpus["frames"]
            .as_array()
            .expect("canonical frames")
            .iter()
            .map(|row| row["id"].as_str().expect("frame id"))
            .collect::<Vec<_>>();
        let canonical_order = corpus["canonical_order"]
            .as_array()
            .expect("canonical order")
            .iter()
            .map(|value| value.as_str().expect("canonical id"))
            .collect::<Vec<_>>();
        assert_eq!(frame_ids, canonical_order);
        assert_eq!(frame_ids.len(), 35);
        assert_eq!(CANONICAL_FRAMES.lines().count(), 35);
        for (id, line) in frame_ids.iter().zip(CANONICAL_FRAMES.lines()) {
            assert_eq!(canonical(&frame(id)), line, "{id} exact canonical bytes");
        }
        assert_eq!(
            corpus["raw_inputs"]
                .as_array()
                .expect("raw cases")
                .iter()
                .map(|row| row["id"].as_str().expect("raw id"))
                .collect::<Vec<_>>(),
            [
                "invalid_utf8",
                "utf8_bom",
                "malformed_json",
                "duplicate_key",
                "overlong_line",
                "json_batch",
                "non_object",
                "invalid_boolean_id",
                "nesting_depth_65",
                "valid_crlf_discovery",
            ]
        );
        assert_eq!(
            corpus["lifecycle_cases"]
                .as_array()
                .expect("lifecycle cases")
                .iter()
                .map(|row| row["id"].as_str().expect("lifecycle id"))
                .collect::<Vec<_>>(),
            [
                "ready_at_stream_loop_start",
                "cancel_before_response_emission",
                "cancel_unknown_request",
                "cancel_after_sync_completion",
                "legacy_initialized_notification",
                "stdout_discipline",
                "stderr_default",
                "registry_capacity",
                "graceful_eof",
                "unexpected_io_failure",
            ]
        );
        assert_eq!(
            corpus["handle_cases"]
                .as_array()
                .expect("handle cases")
                .iter()
                .map(|row| row["state"].as_str().expect("handle state"))
                .collect::<Vec<_>>(),
            ["unknown", "expired", "revoked", "unauthorized"]
        );
        assert_eq!(
            corpus["policy_cases"]
                .as_array()
                .expect("policy cases")
                .iter()
                .map(|row| row["id"].as_str().expect("policy id"))
                .collect::<Vec<_>>(),
            [
                "default_capabilities_identity",
                "restricted_capabilities_projection",
                "allowed_query_identity",
                "above_policy_pre_dispatch_denial",
            ]
        );

        let transport: Value = serde_json::from_str(TRANSPORT).expect("transport contract parses");
        let expected_digest = transport["artifact_sha256"]["canonical_frames"]
            .as_str()
            .expect("canonical digest");
        assert_eq!(sha256_hex(CANONICAL_FRAMES.as_bytes()), expected_digest);
        let validator: Value =
            serde_json::from_slice(VALIDATOR_CASES).expect("validator cases parse");
        assert_eq!(
            validator["mutation_order"]
                .as_array()
                .expect("mutation order")
                .len(),
            68
        );
    });

    admission_role(&mut roles_seen, "canonical_static_dispatch", || {
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
            let expected = if native_identity {
                rust_identity(frame(response_name))
            } else {
                frame(response_name)
            };
            assert_eq!(
                response(&mut server, &frame(request_name), b"static-principal"),
                expected,
                "{request_name} exact Rust response"
            );
        }
        assert_eq!(
            server
                .dispatch(
                    &frame("legacy_initialized_notification"),
                    b"static-principal"
                )
                .expect("legacy notification dispatches"),
            None
        );
        server.shutdown();
    });

    admission_role(&mut roles_seen, "native_capabilities_identity", || {
        let index = graph_index();
        let native =
            serde_json::to_value(index.capabilities()).expect("native capabilities serialize");
        let mut server = McpServer::new().expect("production MCP server constructs");
        let handle = server
            .register_index(
                Arc::clone(&index),
                b"capabilities-principal",
                McpRegistrationOptions::default(),
            )
            .expect("native index registers");
        let actual = response(
            &mut server,
            &with_handle(frame("capabilities_call_request"), &handle),
            b"capabilities-principal",
        );
        assert_eq!(actual, rust_identity(frame("capabilities_call_response")));
        assert_eq!(actual["result"]["structuredContent"], native);
        assert_eq!(
            actual["result"]["content"][0]["text"],
            Value::String(canonical(&native))
        );
        server.shutdown();
    });

    admission_role(&mut roles_seen, "native_query_identity", || {
        let index = graph_index();
        let mut server = McpServer::new().expect("production MCP server constructs");
        let handle = server
            .register_index(
                Arc::clone(&index),
                b"query-principal",
                McpRegistrationOptions::default(),
            )
            .expect("native index registers");
        let request = with_handle(frame("query_call_request"), &handle);
        let native =
            serde_json::to_value(index.query_neutral(&request["params"]["arguments"]["request"]))
                .expect("native query serializes");
        let actual = response(&mut server, &request, b"query-principal");
        assert_eq!(actual, frame("query_call_response"));
        assert_eq!(actual["result"]["structuredContent"], native);
        assert_eq!(
            actual["result"]["content"][0]["text"],
            Value::String(canonical(&native))
        );
        server.shutdown();
    });

    admission_role(&mut roles_seen, "raw_input_outcomes", || {
        let corpus = corpus();
        for row in corpus["raw_inputs"].as_array().expect("raw corpus") {
            let id = row["id"].as_str().expect("raw id");
            let mut server = McpServer::new().expect("production MCP server constructs");
            let (output, log) =
                run_stream(&mut server, raw_fixture(row), b"raw-admission-principal")
                    .unwrap_or_else(|error| panic!("{id} reaches graceful EOF: {error}"));
            assert!(log.is_empty(), "{id} remains silent");
            let expected = if id == "valid_crlf_discovery" {
                let mut response = frame("discover_response_rust");
                response["id"] = serde_json::json!(1);
                frame_bytes(&response)
            } else {
                error_bytes(
                    row["expected"]["code"].as_i64().expect("error code"),
                    row["expected"]["message"].as_str().expect("error message"),
                )
            };
            assert_eq!(output, expected, "{id} exact wire outcome");
        }
    });

    admission_role(&mut roles_seen, "lifecycle_outcomes", || {
        let corpus = corpus();
        let lifecycle = corpus["lifecycle_cases"]
            .as_array()
            .expect("lifecycle cases");
        assert_eq!(lifecycle.len(), 10);

        let mut server = McpServer::new().expect("production MCP server constructs");
        let (output, log) = run_stream(
            &mut server,
            frame_bytes(&frame("discover_request")),
            b"ready-principal",
        )
        .expect("ready stream reaches EOF");
        assert_eq!(output, frame_bytes(&frame("discover_response_rust")));
        assert!(log.is_empty(), "normal operation proves stderr_default");
        assert!(!output.contains(&b'\r'), "stdout uses canonical LF only");

        let cancel_unknown = frame("cancelled_notification");
        let mut server = McpServer::new().expect("production MCP server constructs");
        let (output, _) = run_stream(
            &mut server,
            frame_bytes(&cancel_unknown),
            b"cancel-principal",
        )
        .expect("unknown cancellation reaches EOF");
        assert!(output.is_empty());

        let request = frame("discover_request");
        let mut cancel_after = frame("cancelled_notification");
        cancel_after["params"]["requestId"] = request["id"].clone();
        let mut input = frame_bytes(&request);
        input.extend(frame_bytes(&cancel_after));
        let mut server = McpServer::new().expect("production MCP server constructs");
        let (output, _) = run_stream(&mut server, input, b"cancel-principal")
            .expect("post-flush cancellation reaches EOF");
        assert_eq!(output, frame_bytes(&frame("discover_response_rust")));

        let mut server = McpServer::new().expect("production MCP server constructs");
        let (output, _) = run_stream(
            &mut server,
            frame_bytes(&frame("legacy_initialized_notification")),
            b"legacy-principal",
        )
        .expect("legacy notification reaches EOF");
        assert!(output.is_empty());

        let transport: Value = serde_json::from_str(TRANSPORT).expect("transport contract parses");
        let maximum = usize::try_from(
            transport["handle_registry"]["default_maximum_live_handles"]
                .as_u64()
                .expect("maximum handles"),
        )
        .expect("maximum handles fit usize");
        let index = graph_index();
        let mut server = McpServer::new().expect("production MCP server constructs");
        server
            .register_index(
                Arc::clone(&index),
                b"capacity-principal",
                McpRegistrationOptions {
                    lifetime_ms: Some(1),
                    policy: None,
                },
            )
            .expect("short-lived index registers");
        wait_for_lifetime_tick();
        for _ in 0..maximum {
            server
                .register_index(
                    Arc::clone(&index),
                    b"capacity-principal",
                    McpRegistrationOptions::default(),
                )
                .expect("expired entry is pruned before capacity accounting");
        }
        assert_eq!(
            server
                .register_index(
                    Arc::clone(&index),
                    b"capacity-principal",
                    McpRegistrationOptions::default(),
                )
                .expect_err("live registry capacity fails closed")
                .code,
            "linkedspec_mcp_registry_full"
        );
        server.shutdown();

        let held = graph_index();
        let weak = Arc::downgrade(&held);
        let mut server = McpServer::new().expect("production MCP server constructs");
        server
            .register_index(
                Arc::clone(&held),
                b"eof-principal",
                McpRegistrationOptions::default(),
            )
            .expect("EOF-held index registers");
        drop(held);
        assert!(weak.upgrade().is_some());
        run_stream(&mut server, Vec::new(), b"eof-principal").expect("graceful EOF succeeds");
        assert!(weak.upgrade().is_none(), "graceful EOF releases index");

        let mut server = McpServer::new().expect("production MCP server constructs");
        let mut output = Vec::new();
        let mut log = Vec::new();
        let error = server
            .serve_stdio(
                &mut FailingReader,
                &mut output,
                b"failure-principal",
                Some(&mut log),
            )
            .expect_err("unexpected I/O failure is typed");
        assert_eq!(error.code, "linkedspec_mcp_io_failure");
        assert!(output.is_empty());
        assert_eq!(log, IO_LOG_RECORD);
    });

    admission_role(&mut roles_seen, "handle_state_indistinguishability", || {
        let expected = rust_identity(frame("handle_unavailable_response"));

        let mut server = McpServer::new().expect("production MCP server constructs");
        assert_eq!(
            response(
                &mut server,
                &frame("handle_unavailable_request"),
                b"state-principal"
            ),
            expected
        );
        server.shutdown();

        let index = graph_index();
        let mut server = McpServer::new().expect("production MCP server constructs");
        let expired = server
            .register_index(
                Arc::clone(&index),
                b"state-principal",
                McpRegistrationOptions {
                    lifetime_ms: Some(1),
                    policy: None,
                },
            )
            .expect("expiring handle registers");
        wait_for_lifetime_tick();
        assert_eq!(
            response(
                &mut server,
                &with_handle(frame("handle_unavailable_request"), &expired),
                b"state-principal"
            ),
            expected
        );
        server.shutdown();

        let mut server = McpServer::new().expect("production MCP server constructs");
        let revoked = server
            .register_index(
                Arc::clone(&index),
                b"state-principal",
                McpRegistrationOptions::default(),
            )
            .expect("revoked handle registers");
        server
            .revoke_handle(&revoked)
            .expect("host revocation succeeds");
        assert_eq!(
            response(
                &mut server,
                &with_handle(frame("handle_unavailable_request"), &revoked),
                b"state-principal"
            ),
            expected
        );
        server.shutdown();

        let mut server = McpServer::new().expect("production MCP server constructs");
        let unauthorized = server
            .register_index(
                Arc::clone(&index),
                b"state-principal",
                McpRegistrationOptions::default(),
            )
            .expect("unauthorized handle registers");
        assert_eq!(
            response(
                &mut server,
                &with_handle(frame("handle_unavailable_request"), &unauthorized),
                b"wrong-principal"
            ),
            expected
        );
        server.shutdown();
    });

    admission_role(&mut roles_seen, "policy_overlay", || {
        let index = graph_index();
        let mut server = McpServer::new().expect("production MCP server constructs");
        let default = server
            .register_index(
                Arc::clone(&index),
                b"default-policy-principal",
                McpRegistrationOptions::default(),
            )
            .expect("default policy registers");
        assert_eq!(
            response(
                &mut server,
                &with_handle(frame("capabilities_call_request"), &default),
                b"default-policy-principal"
            ),
            rust_identity(frame("capabilities_call_response"))
        );
        assert_eq!(
            response(
                &mut server,
                &with_handle(frame("query_call_request"), &default),
                b"default-policy-principal"
            ),
            frame("query_call_response")
        );

        let restricted = server
            .register_index(
                Arc::clone(&index),
                b"restricted-policy-principal",
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
            .expect("restricted policy registers");
        assert_eq!(
            response(
                &mut server,
                &with_handle(frame("restricted_capabilities_request"), &restricted),
                b"restricted-policy-principal"
            ),
            rust_identity(frame("restricted_capabilities_response"))
        );
        assert_eq!(
            response(
                &mut server,
                &with_handle(frame("policy_denied_request"), &restricted),
                b"restricted-policy-principal"
            ),
            rust_identity(frame("policy_denied_response"))
        );
        server.shutdown();
    });

    admission_role(&mut roles_seen, "cancellation_emission", || {
        let corpus = corpus();
        let before = corpus["lifecycle_cases"]
            .as_array()
            .expect("lifecycle cases")
            .iter()
            .find(|row| row["id"] == "cancel_before_response_emission")
            .expect("pre-emission cancellation case");
        assert_eq!(before["expected"], "stop_and_suppress_response");
        assert!(
            MCP_WIRE_SOURCE
                .contains("fn prepared_cancellation_is_suppressed_but_emitted_response_is_final()"),
            "the ordered private unit proof owns the otherwise unobservable preparation seam"
        );
        assert!(
            !MCP_WIRE_SOURCE.contains("#[ignore]"),
            "the focused private MCP proof is not ignored"
        );

        let request = frame("discover_request");
        let mut cancel = frame("cancelled_notification");
        cancel["params"]["requestId"] = request["id"].clone();
        let mut input = frame_bytes(&request);
        input.extend(frame_bytes(&cancel));
        let mut server = McpServer::new().expect("production MCP server constructs");
        let (output, log) = run_stream(&mut server, input, b"emission-principal")
            .expect("synchronous response and later cancellation reach EOF");
        assert_eq!(output, frame_bytes(&frame("discover_response_rust")));
        assert!(log.is_empty());
    });

    admission_role(&mut roles_seen, "shutdown_and_io", || {
        let complete = frame_bytes(&frame("discover_request"));
        let mut input = ChunkThenFailReader {
            chunk: Some(complete.clone()),
        };
        let mut output = Vec::new();
        let mut log = Vec::new();
        let mut server = McpServer::new().expect("production MCP server constructs");
        assert_eq!(
            server
                .serve_stdio(
                    &mut input,
                    &mut output,
                    b"later-failure-principal",
                    Some(&mut log),
                )
                .expect_err("later input failure is typed")
                .code,
            "linkedspec_mcp_io_failure"
        );
        assert_eq!(output, frame_bytes(&frame("discover_response_rust")));
        assert_eq!(log, IO_LOG_RECORD);

        let index = graph_index();
        let weak = Arc::downgrade(&index);
        let mut server = McpServer::new().expect("production MCP server constructs");
        server
            .register_index(
                Arc::clone(&index),
                b"write-failure-principal",
                McpRegistrationOptions::default(),
            )
            .expect("write-failure index registers");
        drop(index);
        let mut input = Cursor::new(complete.clone());
        let mut log = Vec::new();
        assert_eq!(
            server
                .serve_stdio(
                    &mut input,
                    &mut FailingWriter,
                    b"write-failure-principal",
                    Some(&mut log),
                )
                .expect_err("write failure is typed")
                .code,
            "linkedspec_mcp_io_failure"
        );
        assert_eq!(log, IO_LOG_RECORD);
        assert!(weak.upgrade().is_none(), "write failure releases index");

        let index = graph_index();
        let weak = Arc::downgrade(&index);
        let mut server = McpServer::new().expect("production MCP server constructs");
        server
            .register_index(
                Arc::clone(&index),
                b"flush-failure-principal",
                McpRegistrationOptions::default(),
            )
            .expect("flush-failure index registers");
        drop(index);
        let mut input = Cursor::new(complete);
        let mut output = FlushFailingWriter::default();
        let mut log = Vec::new();
        assert_eq!(
            server
                .serve_stdio(
                    &mut input,
                    &mut output,
                    b"flush-failure-principal",
                    Some(&mut log),
                )
                .expect_err("flush failure is typed")
                .code,
            "linkedspec_mcp_io_failure"
        );
        assert_eq!(output.bytes, frame_bytes(&frame("discover_response_rust")));
        assert_eq!(log, IO_LOG_RECORD);
        assert!(weak.upgrade().is_none(), "flush failure releases index");
    });

    admission_role(&mut roles_seen, "hostile_output_and_log_privacy", || {
        let mut server = McpServer::new().expect("production MCP server constructs");
        let mut output = Vec::new();
        let mut log = Vec::new();
        let error = server
            .serve_stdio(
                &mut FailingReader,
                &mut output,
                b"hostile-principal",
                Some(&mut log),
            )
            .expect_err("hostile read failure is typed");
        assert_eq!(error.code, "linkedspec_mcp_io_failure");
        assert_eq!(error.message, "The MCP stdio stream failed.");
        assert!(output.is_empty());
        assert_eq!(log, IO_LOG_RECORD);
        let exposed = format!("{error}{:?}", String::from_utf8_lossy(&log));
        for private in [
            "/private/secret",
            "admission",
            "hostile",
            "principal=",
            "response=",
        ] {
            assert!(!exposed.contains(private), "host output hides {private}");
        }
        assert!(
            MCP_SERVER_SOURCE.contains("fn entropy_clock_and_panic_failures_are_sanitized()"),
            "the ordered private unit proof owns injected native panic sanitation"
        );
        assert!(
            !MCP_SERVER_SOURCE.contains("#[ignore]"),
            "the focused private MCP proof is not ignored"
        );
    });

    admission_role(&mut roles_seen, "authority_surface_fences", || {
        for (path, source) in [
            ("mcp_contract.rs", MCP_CONTRACT_SOURCE),
            ("mcp_contract_runtime.rs", MCP_RUNTIME_SOURCE),
            ("mcp_server.rs", MCP_SERVER_SOURCE),
            ("mcp_wire.rs", MCP_WIRE_SOURCE),
        ] {
            for forbidden in [
                "std::fs",
                "File::open",
                "OpenOptions",
                "std::process",
                "Command::new",
                "TcpStream",
                "TcpListener",
                "UdpSocket",
                "tokio::",
                "async fn",
                "LINKEDSPEC_TRACE_LEVEL",
                "dump_parser_source",
                "return_descriptor",
                "call_spec_handler",
            ] {
                assert!(
                    !source.contains(forbidden),
                    "{path} exposes no forbidden {forbidden} authority"
                );
            }
        }
        for forbidden_method in [
            "pub fn load_source",
            "pub fn open_source",
            "pub fn compile",
            "pub fn execute",
            "pub fn trace",
            "pub fn cache",
            "pub fn semantic_index_from_path",
        ] {
            assert!(
                !MCP_SERVER_SOURCE.contains(forbidden_method),
                "public server exposes no {forbidden_method}"
            );
        }
        assert!(
            !PRIMARY_CLI_SOURCE.contains("McpServer")
                && !PRIMARY_CLI_SOURCE.contains("serve_stdio"),
            "primary parser CLI has no MCP bootstrap"
        );
    });

    assert_eq!(roles_seen, ROLE_ORDER);
}

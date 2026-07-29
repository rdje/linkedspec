//! FUTURE-PARITY-BACKLOG.10.9.3.2 — public Rust MCP stdio/lifecycle proof.

use linkedspec_runtime::{
    McpRegistrationOptions, McpServer,
    semantic_index::{SemanticIndex, SemanticIndexOptions, SemanticSourceDetail},
};
use serde_json::Value;
use std::io::{self, Cursor, Read, Write};
use std::sync::Arc;

const CORPUS: &str =
    include_str!("../../../capability_conformance/mcp_semantic_transport/corpus.json");
const CANONICAL_FRAMES: &str =
    include_str!("../../../capability_conformance/mcp_semantic_transport/canonical_frames.jsonl");
const GRAPH: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/graph.spec");
const RUST_SERVER: &str = "linkedspec-semantic-rust";
const IO_LOG_RECORD: &[u8] = b"linkedspec_mcp_io_failure\n";

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
        .expect("response carries a server identity");
    *name = Value::String(RUST_SERVER.to_string());
    response
}

fn frame_bytes(value: &Value) -> Vec<u8> {
    let mut bytes = serde_json::to_vec(value).expect("frame serializes");
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

#[test]
fn public_stdio_matches_every_neutral_raw_classification() {
    let corpus: Value = serde_json::from_str(CORPUS).expect("MCP corpus parses");
    for row in corpus["raw_inputs"].as_array().expect("raw corpus") {
        let id = row["id"].as_str().expect("raw id");
        let mut server = McpServer::new().expect("production MCP server constructs");
        let mut input = Cursor::new(raw_fixture(row));
        let mut output = Vec::new();
        let mut log = Vec::new();
        server
            .serve_stdio(&mut input, &mut output, b"raw-principal", Some(&mut log))
            .unwrap_or_else(|error| panic!("{id} reaches graceful EOF: {error}"));
        assert!(log.is_empty(), "{id} remains operationally silent");
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
        assert_eq!(output, expected, "{id} exact public wire bytes");
    }
}

#[test]
fn public_stdio_emits_only_ordered_canonical_native_frames() {
    let index = graph_index();
    let mut server = McpServer::new().expect("production MCP server constructs");
    let handle = server
        .register_index(
            Arc::clone(&index),
            b"wire-principal",
            McpRegistrationOptions::default(),
        )
        .expect("graph index registers");
    let discover = frame("discover_request");
    let list = frame("tools_list_request");
    let capabilities = with_handle(frame("capabilities_call_request"), &handle);
    let query = with_handle(frame("query_call_request"), &handle);
    let initialized = frame("legacy_initialized_notification");
    let mut input_bytes = Vec::new();
    for request in [&discover, &list, &capabilities, &query, &initialized] {
        input_bytes.extend(frame_bytes(request));
    }

    let mut input = Cursor::new(input_bytes);
    let mut output = Vec::new();
    let mut log = Vec::new();
    server
        .serve_stdio(&mut input, &mut output, b"wire-principal", Some(&mut log))
        .expect("public stream reaches graceful EOF");

    let mut expected = Vec::new();
    for response in [
        frame("discover_response_rust"),
        rust_identity(frame("tools_list_response_perl")),
        rust_identity(frame("capabilities_call_response")),
        frame("query_call_response"),
    ] {
        expected.extend(frame_bytes(&response));
    }
    assert_eq!(output, expected, "decoded and wire payloads are identical");
    assert!(!output.contains(&b'\r'), "wire output uses LF only");
    assert!(log.is_empty(), "normal stream is silent");
    assert_eq!(
        server
            .serve_stdio(
                &mut Cursor::new(Vec::<u8>::new()),
                &mut Vec::new(),
                b"wire-principal",
                None,
            )
            .expect_err("EOF-stopped server cannot restart")
            .code,
        "linkedspec_mcp_server_shutdown"
    );
}

struct FailingReader;

impl Read for FailingReader {
    fn read(&mut self, _buffer: &mut [u8]) -> io::Result<usize> {
        Err(io::Error::other("private reader path and principal"))
    }
}

struct ChunkThenFailReader {
    chunk: Option<Vec<u8>>,
}

impl Read for ChunkThenFailReader {
    fn read(&mut self, buffer: &mut [u8]) -> io::Result<usize> {
        let Some(chunk) = self.chunk.take() else {
            return Err(io::Error::other("private later reader failure"));
        };
        assert!(chunk.len() <= buffer.len());
        buffer[..chunk.len()].copy_from_slice(&chunk);
        Ok(chunk.len())
    }
}

struct FailingWriter;

impl Write for FailingWriter {
    fn write(&mut self, _buffer: &[u8]) -> io::Result<usize> {
        Err(io::Error::other("private writer path and response"))
    }

    fn flush(&mut self) -> io::Result<()> {
        Err(io::Error::other("private flush path"))
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
        Err(io::Error::other("private flush path"))
    }
}

#[test]
fn eof_and_io_failures_release_indexes_and_sanitize_every_channel() {
    let index = graph_index();
    let retained = Arc::downgrade(&index);
    let mut server = McpServer::new().expect("production MCP server constructs");
    server
        .register_index(
            Arc::clone(&index),
            b"release-principal",
            McpRegistrationOptions::default(),
        )
        .expect("release index registers");
    drop(index);
    assert!(retained.upgrade().is_some());
    server
        .serve_stdio(
            &mut Cursor::new(Vec::<u8>::new()),
            &mut Vec::new(),
            b"release-principal",
            None,
        )
        .expect("clean EOF succeeds");
    assert!(retained.upgrade().is_none(), "EOF releases registry Arc");

    let index = graph_index();
    let retained = Arc::downgrade(&index);
    let mut server = McpServer::new().expect("production MCP server constructs");
    server
        .register_index(
            Arc::clone(&index),
            b"failure-principal",
            McpRegistrationOptions::default(),
        )
        .expect("failure index registers");
    drop(index);
    let mut output = Vec::new();
    let mut log = Vec::new();
    let error = server
        .serve_stdio(
            &mut FailingReader,
            &mut output,
            b"failure-principal",
            Some(&mut log),
        )
        .expect_err("input failure is typed");
    assert_eq!(error.code, "linkedspec_mcp_io_failure");
    assert_eq!(error.message, "The MCP stdio stream failed.");
    assert!(output.is_empty());
    assert_eq!(log, IO_LOG_RECORD);
    assert!(
        retained.upgrade().is_none(),
        "input failure releases registry Arc"
    );

    let request = frame_bytes(&frame("discover_request"));
    let mut input = ChunkThenFailReader {
        chunk: Some(request),
    };
    let mut server = McpServer::new().expect("production MCP server constructs");
    let mut output = Vec::new();
    let mut log = Vec::new();
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
    let retained = Arc::downgrade(&index);
    let mut server = McpServer::new().expect("production MCP server constructs");
    server
        .register_index(
            Arc::clone(&index),
            b"writer-principal",
            McpRegistrationOptions::default(),
        )
        .expect("writer index registers");
    drop(index);
    let mut input = Cursor::new(frame_bytes(&frame("discover_request")));
    let mut log = Vec::new();
    assert_eq!(
        server
            .serve_stdio(
                &mut input,
                &mut FailingWriter,
                b"writer-principal",
                Some(&mut log),
            )
            .expect_err("output failure is typed")
            .code,
        "linkedspec_mcp_io_failure"
    );
    assert_eq!(log, IO_LOG_RECORD);
    assert!(
        retained.upgrade().is_none(),
        "output failure releases registry Arc"
    );
    let log_text = String::from_utf8(log).expect("log is UTF-8");
    for private_word in [
        "graph",
        "handle",
        "principal",
        "source",
        "request",
        "response",
        "path",
        "object",
        "exception",
    ] {
        assert!(!log_text.contains(private_word), "log hides {private_word}");
    }

    let index = graph_index();
    let retained = Arc::downgrade(&index);
    let mut server = McpServer::new().expect("production MCP server constructs");
    server
        .register_index(
            Arc::clone(&index),
            b"flush-principal",
            McpRegistrationOptions::default(),
        )
        .expect("flush index registers");
    drop(index);
    let mut input = Cursor::new(frame_bytes(&frame("discover_request")));
    let mut output = FlushFailingWriter::default();
    let mut log = Vec::new();
    assert_eq!(
        server
            .serve_stdio(&mut input, &mut output, b"flush-principal", Some(&mut log),)
            .expect_err("flush failure is typed")
            .code,
        "linkedspec_mcp_io_failure"
    );
    assert_eq!(output.bytes, frame_bytes(&frame("discover_response_rust")));
    assert_eq!(log, IO_LOG_RECORD);
    assert!(
        retained.upgrade().is_none(),
        "flush failure releases registry Arc"
    );
}

#[test]
fn public_stdio_rejects_invalid_authority_before_consuming_input() {
    let mut server = McpServer::new().expect("production MCP server constructs");
    let request = frame_bytes(&frame("discover_request"));
    let mut input = Cursor::new(request.clone());
    let mut output = Vec::new();
    assert_eq!(
        server
            .serve_stdio(&mut input, &mut output, b"", None)
            .expect_err("empty authorization fails closed")
            .code,
        "linkedspec_mcp_invalid_authorization"
    );
    assert_eq!(input.position(), 0, "invalid authority consumes no input");
    assert!(output.is_empty());

    server
        .serve_stdio(&mut input, &mut output, b"valid-principal", None)
        .expect("server remains usable after argument rejection");
    assert_eq!(output, frame_bytes(&frame("discover_response_rust")));
}

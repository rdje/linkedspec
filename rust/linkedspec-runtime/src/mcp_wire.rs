//! Strict bounded MCP JSON-line framing over borrowed streams.

use crate::mcp_contract_runtime;
use crate::mcp_server::{McpServer, McpServerError};
use serde_json::Value;
use std::collections::HashSet;
use std::io::{self, Read, Write};
use std::panic::{AssertUnwindSafe, catch_unwind};

const READ_CHUNK_BYTES: usize = 65_536;
const UTF8_BOM: &[u8] = b"\xef\xbb\xbf";
const IO_LOG_RECORD: &[u8] = b"linkedspec_mcp_io_failure\n";
const SAFE_INTEGER_ID: &str = "9007199254740991";

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Rejection {
    Parse,
    InvalidRequest,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum TokenKind {
    String,
    Number,
    Other,
}

#[derive(Clone, Copy, Debug)]
struct IdToken {
    kind: TokenKind,
    start: usize,
    end: usize,
}

struct Scanner<'a> {
    bytes: &'a [u8],
    offset: usize,
    maximum_depth: usize,
    id_token: Option<IdToken>,
}

pub(crate) fn serve<R: Read + ?Sized, W: Write + ?Sized>(
    server: &mut McpServer,
    input: &mut R,
    output: &mut W,
    authorization_context: &[u8],
    mut log: Option<&mut dyn Write>,
) -> Result<(), McpServerError> {
    let (maximum_line_bytes, maximum_depth) = request_limits()?;
    let mut buffer = Vec::with_capacity(READ_CHUNK_BYTES.min(maximum_line_bytes + 1));
    let mut overlong = false;
    let mut chunk = [0_u8; READ_CHUNK_BYTES];

    loop {
        let count = match input.read(&mut chunk) {
            Ok(count) => count,
            Err(error) if error.kind() == io::ErrorKind::Interrupted => continue,
            Err(_) => return io_failure(server, &mut log),
        };
        if count == 0 {
            if overlong {
                let response = protocol_error(None, Rejection::Parse);
                if emit_response(server, output, Some(response), None).is_err() {
                    return io_failure(server, &mut log);
                }
            } else if !buffer.is_empty() {
                let (response, prepared) =
                    process_payload(server, &buffer, authorization_context, maximum_depth);
                if emit_response(server, output, response, prepared.as_deref()).is_err() {
                    return io_failure(server, &mut log);
                }
            }
            server.shutdown();
            return Ok(());
        }

        let mut offset = 0;
        while offset < count {
            let relative_newline = chunk[offset..count].iter().position(|byte| *byte == b'\n');
            let end = relative_newline.map_or(count, |position| offset + position);
            let piece = &chunk[offset..end];
            if !overlong {
                if buffer.len().saturating_add(piece.len()) > maximum_line_bytes + 1 {
                    buffer.clear();
                    overlong = true;
                } else {
                    buffer.extend_from_slice(piece);
                }
            }
            let Some(_) = relative_newline else {
                break;
            };

            let (response, prepared) = if overlong {
                (Some(protocol_error(None, Rejection::Parse)), None)
            } else {
                let payload = buffer.strip_suffix(b"\r").unwrap_or(buffer.as_slice());
                if payload.len() > maximum_line_bytes {
                    (Some(protocol_error(None, Rejection::Parse)), None)
                } else {
                    process_payload(server, payload, authorization_context, maximum_depth)
                }
            };
            if emit_response(server, output, response, prepared.as_deref()).is_err() {
                return io_failure(server, &mut log);
            }
            buffer.clear();
            overlong = false;
            offset = end + 1;
        }
    }
}

fn request_limits() -> Result<(usize, usize), McpServerError> {
    let contract = mcp_contract_runtime::contract().map_err(|_| contract_failure())?;
    let limits = contract
        .get("request_limits")
        .and_then(Value::as_object)
        .ok_or_else(contract_failure)?;
    let line_bytes = limits
        .get("line_bytes_excluding_delimiter")
        .and_then(Value::as_u64)
        .and_then(|value| usize::try_from(value).ok())
        .filter(|value| *value > 0)
        .ok_or_else(contract_failure)?;
    let depth = limits
        .get("json_nesting_depth")
        .and_then(Value::as_u64)
        .and_then(|value| usize::try_from(value).ok())
        .filter(|value| *value > 0)
        .ok_or_else(contract_failure)?;
    Ok((line_bytes, depth))
}

fn process_payload(
    server: &mut McpServer,
    payload: &[u8],
    authorization_context: &[u8],
    maximum_depth: usize,
) -> (Option<Value>, Option<String>) {
    let request = match decode_payload(payload, maximum_depth) {
        Ok(request) => request,
        Err(rejection) => return (Some(protocol_error(None, rejection)), None),
    };
    let id = validated_id(&request).cloned();
    let dispatched = catch_unwind(AssertUnwindSafe(|| {
        server.dispatch_for_wire(&request, authorization_context)
    }));
    let (response, prepared) = match dispatched {
        Ok(Ok(result)) => result,
        Ok(Err(_)) | Err(_) => return (Some(internal_error(id.as_ref())), None),
    };
    let Some(response) = response else {
        return (None, None);
    };
    if mcp_contract_runtime::validate_frame(&response) {
        return (Some(response), prepared);
    }
    server.wire_response_emitted(prepared.as_deref());
    (Some(internal_error(id.as_ref())), None)
}

fn decode_payload(payload: &[u8], maximum_depth: usize) -> Result<Value, Rejection> {
    if payload.starts_with(UTF8_BOM) || std::str::from_utf8(payload).is_err() {
        return Err(Rejection::Parse);
    }
    let mut scanner = Scanner {
        bytes: payload,
        offset: 0,
        maximum_depth,
        id_token: None,
    };
    scanner.skip_whitespace();
    scanner.parse_value(0, true)?;
    scanner.skip_whitespace();
    if scanner.offset != payload.len() {
        return Err(Rejection::Parse);
    }
    let value: Value = serde_json::from_slice(payload).map_err(|_| Rejection::Parse)?;
    if !value.is_object() {
        return Err(Rejection::InvalidRequest);
    }
    if let Some(id) = value.get("id")
        && !valid_wire_id(id, scanner.id_token, payload)
    {
        return Err(Rejection::InvalidRequest);
    }
    Ok(value)
}

impl Scanner<'_> {
    fn parse_value(&mut self, depth: usize, root: bool) -> Result<(), Rejection> {
        self.skip_whitespace();
        let byte = self.peek().ok_or(Rejection::Parse)?;
        match byte {
            b'{' => self.parse_object(depth + 1, root),
            b'[' => self.parse_array(depth + 1),
            b'"' => self.parse_string().map(|_| ()),
            b't' => self.parse_literal(b"true"),
            b'f' => self.parse_literal(b"false"),
            b'n' => self.parse_literal(b"null"),
            b'-' | b'0'..=b'9' => self.parse_number(),
            _ => Err(Rejection::Parse),
        }
    }

    fn parse_object(&mut self, depth: usize, root: bool) -> Result<(), Rejection> {
        if depth > self.maximum_depth {
            return Err(Rejection::Parse);
        }
        self.offset += 1;
        self.skip_whitespace();
        if self.take(b'}') {
            return Ok(());
        }
        let mut keys = HashSet::new();
        loop {
            if self.peek() != Some(b'"') {
                return Err(Rejection::Parse);
            }
            let key = self.parse_string()?;
            if !keys.insert(key.clone()) {
                return Err(Rejection::Parse);
            }
            self.skip_whitespace();
            if !self.take(b':') {
                return Err(Rejection::Parse);
            }
            self.skip_whitespace();
            let start = self.offset;
            let kind = self.token_kind();
            self.parse_value(depth, false)?;
            if root && key == "id" {
                self.id_token = Some(IdToken {
                    kind,
                    start,
                    end: self.offset,
                });
            }
            self.skip_whitespace();
            if self.take(b'}') {
                return Ok(());
            }
            if !self.take(b',') {
                return Err(Rejection::Parse);
            }
            self.skip_whitespace();
        }
    }

    fn parse_array(&mut self, depth: usize) -> Result<(), Rejection> {
        if depth > self.maximum_depth {
            return Err(Rejection::Parse);
        }
        self.offset += 1;
        self.skip_whitespace();
        if self.take(b']') {
            return Ok(());
        }
        loop {
            self.parse_value(depth, false)?;
            self.skip_whitespace();
            if self.take(b']') {
                return Ok(());
            }
            if !self.take(b',') {
                return Err(Rejection::Parse);
            }
            self.skip_whitespace();
        }
    }

    fn parse_string(&mut self) -> Result<String, Rejection> {
        let start = self.offset;
        self.offset += 1;
        while let Some(byte) = self.peek() {
            match byte {
                b'"' => {
                    self.offset += 1;
                    return serde_json::from_slice(&self.bytes[start..self.offset])
                        .map_err(|_| Rejection::Parse);
                }
                0x00..=0x1f => return Err(Rejection::Parse),
                b'\\' => {
                    self.offset += 1;
                    let escape = self.peek().ok_or(Rejection::Parse)?;
                    if escape == b'u' {
                        let end = self.offset.checked_add(5).ok_or(Rejection::Parse)?;
                        let digits = self
                            .bytes
                            .get(self.offset + 1..end)
                            .ok_or(Rejection::Parse)?;
                        if !digits.iter().all(u8::is_ascii_hexdigit) {
                            return Err(Rejection::Parse);
                        }
                        self.offset = end;
                        continue;
                    }
                    if !matches!(
                        escape,
                        b'"' | b'\\' | b'/' | b'b' | b'f' | b'n' | b'r' | b't'
                    ) {
                        return Err(Rejection::Parse);
                    }
                }
                _ => {}
            }
            self.offset += 1;
        }
        Err(Rejection::Parse)
    }

    fn parse_literal(&mut self, literal: &[u8]) -> Result<(), Rejection> {
        if self.bytes.get(self.offset..self.offset + literal.len()) != Some(literal) {
            return Err(Rejection::Parse);
        }
        self.offset += literal.len();
        Ok(())
    }

    fn parse_number(&mut self) -> Result<(), Rejection> {
        if self.take(b'-') && self.peek().is_none() {
            return Err(Rejection::Parse);
        }
        match self.peek() {
            Some(b'0') => self.offset += 1,
            Some(b'1'..=b'9') => {
                self.offset += 1;
                while self.peek().is_some_and(|byte| byte.is_ascii_digit()) {
                    self.offset += 1;
                }
            }
            _ => return Err(Rejection::Parse),
        }
        if self.take(b'.') {
            if !self.peek().is_some_and(|byte| byte.is_ascii_digit()) {
                return Err(Rejection::Parse);
            }
            while self.peek().is_some_and(|byte| byte.is_ascii_digit()) {
                self.offset += 1;
            }
        }
        if self.peek().is_some_and(|byte| matches!(byte, b'e' | b'E')) {
            self.offset += 1;
            if self.peek().is_some_and(|byte| matches!(byte, b'+' | b'-')) {
                self.offset += 1;
            }
            if !self.peek().is_some_and(|byte| byte.is_ascii_digit()) {
                return Err(Rejection::Parse);
            }
            while self.peek().is_some_and(|byte| byte.is_ascii_digit()) {
                self.offset += 1;
            }
        }
        Ok(())
    }

    fn token_kind(&self) -> TokenKind {
        match self.peek() {
            Some(b'"') => TokenKind::String,
            Some(b'-' | b'0'..=b'9') => TokenKind::Number,
            _ => TokenKind::Other,
        }
    }

    fn skip_whitespace(&mut self) {
        while self
            .peek()
            .is_some_and(|byte| matches!(byte, b' ' | b'\t' | b'\r' | b'\n'))
        {
            self.offset += 1;
        }
    }

    fn take(&mut self, byte: u8) -> bool {
        if self.peek() == Some(byte) {
            self.offset += 1;
            true
        } else {
            false
        }
    }

    fn peek(&self) -> Option<u8> {
        self.bytes.get(self.offset).copied()
    }
}

fn valid_wire_id(id: &Value, token: Option<IdToken>, payload: &[u8]) -> bool {
    let Some(token) = token else {
        return false;
    };
    if token.kind == TokenKind::Number {
        let Some(raw) = payload.get(token.start..token.end) else {
            return false;
        };
        let Ok(raw) = std::str::from_utf8(raw) else {
            return false;
        };
        if raw.contains(['.', 'e', 'E']) || !safe_integer_id(raw) {
            return false;
        }
    } else if token.kind != TokenKind::String {
        return false;
    }
    mcp_contract_runtime::validate_named("requestId", id)
}

fn safe_integer_id(raw: &str) -> bool {
    let digits = raw.strip_prefix('-').unwrap_or(raw);
    let digits = digits.trim_start_matches('0');
    let digits = if digits.is_empty() { "0" } else { digits };
    digits.len() < SAFE_INTEGER_ID.len()
        || (digits.len() == SAFE_INTEGER_ID.len() && digits <= SAFE_INTEGER_ID)
}

fn validated_id(request: &Value) -> Option<&Value> {
    request
        .get("id")
        .filter(|id| mcp_contract_runtime::validate_named("requestId", id))
}

fn emit_response<W: Write + ?Sized>(
    server: &mut McpServer,
    output: &mut W,
    response: Option<Value>,
    prepared: Option<&str>,
) -> io::Result<()> {
    let Some(response) = response else {
        return Ok(());
    };
    if !server.wire_response_ready(prepared) {
        return Ok(());
    }
    if !mcp_contract_runtime::validate_frame(&response) {
        return Err(io::Error::other("invalid MCP response"));
    }
    let canonical = mcp_contract_runtime::canonical_json(&response)
        .map_err(|_| io::Error::other("MCP serialization failed"))?;
    output.write_all(canonical.as_bytes())?;
    output.write_all(b"\n")?;
    output.flush()?;
    server.wire_response_emitted(prepared);
    Ok(())
}

fn protocol_error(id: Option<&Value>, rejection: Rejection) -> Value {
    match rejection {
        Rejection::Parse => mcp_contract_runtime::json_rpc_error(id, "parse_error", None),
        Rejection::InvalidRequest => {
            mcp_contract_runtime::json_rpc_error(id, "invalid_request", None)
        }
    }
    .unwrap_or_else(|_| fallback_internal_error(id))
}

fn internal_error(id: Option<&Value>) -> Value {
    mcp_contract_runtime::json_rpc_error(id, "internal_error", None)
        .unwrap_or_else(|_| fallback_internal_error(id))
}

fn fallback_internal_error(id: Option<&Value>) -> Value {
    serde_json::json!({
        "error": {"code": -32603, "message": "Internal error"},
        "id": id.cloned().unwrap_or(Value::Null),
        "jsonrpc": "2.0",
    })
}

fn io_failure(
    server: &mut McpServer,
    log: &mut Option<&mut dyn Write>,
) -> Result<(), McpServerError> {
    server.shutdown();
    if let Some(log) = log.as_deref_mut() {
        let _ = log.write_all(IO_LOG_RECORD);
        let _ = log.flush();
    }
    Err(McpServerError::new(
        "linkedspec_mcp_io_failure",
        "The MCP stdio stream failed.",
    ))
}

fn contract_failure() -> McpServerError {
    McpServerError::new(
        "linkedspec_mcp_contract_failure",
        "The embedded MCP contract is unavailable.",
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;
    use std::io::Cursor;

    const CORPUS: &str =
        include_str!("../../../capability_conformance/mcp_semantic_transport/corpus.json");
    const RAW_IDS: [&str; 10] = [
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
    ];
    const LIFECYCLE_IDS: [&str; 10] = [
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
    ];

    fn test_server() -> McpServer {
        McpServer::new_for_test(|| Ok([0x5a; 32]), || Ok(10_000), 4, 16)
    }

    fn frame(name: &str) -> Value {
        mcp_contract_runtime::frame(name).unwrap().unwrap()
    }

    fn frame_bytes(value: &Value) -> Vec<u8> {
        let mut bytes = mcp_contract_runtime::canonical_json(value)
            .unwrap()
            .into_bytes();
        bytes.push(b'\n');
        bytes
    }

    fn error_bytes(kind: &str) -> Vec<u8> {
        frame_bytes(&mcp_contract_runtime::json_rpc_error(None, kind, None).unwrap())
    }

    fn run_stream(bytes: Vec<u8>) -> (Result<(), McpServerError>, Vec<u8>, Vec<u8>) {
        let mut server = test_server();
        let mut input = Cursor::new(bytes);
        let mut output = Vec::new();
        let mut log = Vec::new();
        let result = serve(
            &mut server,
            &mut input,
            &mut output,
            b"principal",
            Some(&mut log),
        );
        (result, output, log)
    }

    fn raw_fixture(row: &Value) -> Vec<u8> {
        match row["encoding"].as_str().unwrap() {
            "hex" => decode_hex(row["data"].as_str().unwrap()),
            "utf8" => row["data"].as_str().unwrap().as_bytes().to_vec(),
            "repeat_hex" => {
                let byte = decode_hex(row["byte"].as_str().unwrap())[0];
                let count = usize::try_from(row["count"].as_u64().unwrap()).unwrap();
                let mut bytes = vec![byte; count];
                bytes.extend(decode_hex(row["suffix"].as_str().unwrap()));
                bytes
            }
            "nested_json" => {
                let depth = usize::try_from(row["depth"].as_u64().unwrap()).unwrap();
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
        assert_eq!(hex.len() % 2, 0);
        hex.as_bytes()
            .chunks_exact(2)
            .map(|pair| {
                let pair = std::str::from_utf8(pair).unwrap();
                u8::from_str_radix(pair, 16).unwrap()
            })
            .collect()
    }

    #[test]
    fn embedded_raw_and_lifecycle_inventories_are_exact() {
        let corpus: Value = serde_json::from_str(CORPUS).unwrap();
        let raw = corpus["raw_inputs"]
            .as_array()
            .unwrap()
            .iter()
            .map(|row| row["id"].as_str().unwrap())
            .collect::<Vec<_>>();
        let lifecycle = corpus["lifecycle_cases"]
            .as_array()
            .unwrap()
            .iter()
            .map(|row| row["id"].as_str().unwrap())
            .collect::<Vec<_>>();
        assert_eq!(raw, RAW_IDS);
        assert_eq!(lifecycle, LIFECYCLE_IDS);
    }

    #[test]
    fn all_neutral_raw_cases_have_exact_wire_outcomes() {
        let corpus: Value = serde_json::from_str(CORPUS).unwrap();
        for row in corpus["raw_inputs"].as_array().unwrap() {
            let id = row["id"].as_str().unwrap();
            let (result, output, log) = run_stream(raw_fixture(row));
            assert!(result.is_ok(), "{id} reaches graceful EOF");
            assert!(log.is_empty(), "{id} is operationally silent");
            let expected = if id == "valid_crlf_discovery" {
                frame_bytes(&mcp_contract_runtime::discover_response(&json!(1)).unwrap())
            } else {
                let kind = if row["expected"]["code"] == -32700 {
                    "parse_error"
                } else {
                    "invalid_request"
                };
                error_bytes(kind)
            };
            assert_eq!(output, expected, "{id} exact canonical response");
        }
    }

    #[test]
    fn decoded_keys_unicode_depth_and_line_boundaries_are_exact() {
        for bytes in [
            br#"{"\u0069d":1,"id":2,"jsonrpc":"2.0","method":"server/discover","params":{}}
"#
            .to_vec(),
            br#"{"id":1,"jsonrpc":"2.0","method":"server/discover","params":{"x":{"a":1,"\u0061":2}}}
"#
            .to_vec(),
            br#"{"id":"\uD800","jsonrpc":"2.0","method":"server/discover","params":{}}
"#
            .to_vec(),
            b"{\"id\":NaN,\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{}}\n"
                .to_vec(),
            b"\n".to_vec(),
        ] {
            assert_eq!(run_stream(bytes).1, error_bytes("parse_error"));
        }

        let mut depth_64 = vec![b'['; 64];
        depth_64.push(b'0');
        depth_64.extend(std::iter::repeat_n(b']', 64));
        depth_64.push(b'\n');
        assert_eq!(run_stream(depth_64).1, error_bytes("invalid_request"));

        let request = frame("discover_request");
        let base = mcp_contract_runtime::canonical_json(&request).unwrap();
        let mut maximum = base.into_bytes();
        maximum.resize(1_048_576, b' ');
        maximum.extend_from_slice(b"\r\n");
        assert_eq!(
            run_stream(maximum).1,
            frame_bytes(&mcp_contract_runtime::discover_response(&request["id"]).unwrap())
        );
    }

    #[test]
    fn request_id_lexemes_ranges_and_utf8_byte_limits_are_exact() {
        for id in [
            "1.0",
            "1e0",
            "9007199254740992",
            "-9007199254740992",
            "null",
        ] {
            let bytes = format!(
                "{{\"id\":{id},\"jsonrpc\":\"2.0\",\"method\":\"server/discover\",\"params\":{{}}}}\n"
            )
            .into_bytes();
            assert_eq!(run_stream(bytes).1, error_bytes("invalid_request"), "{id}");
        }
        for id in [-9_007_199_254_740_991_i64, 9_007_199_254_740_991_i64] {
            let mut request = frame("discover_request");
            request["id"] = json!(id);
            assert_eq!(
                run_stream(frame_bytes(&request)).1,
                frame_bytes(&mcp_contract_runtime::discover_response(&json!(id)).unwrap())
            );
        }

        for (characters, accepted) in [(64, true), (65, false)] {
            let id = "é".repeat(characters);
            let mut request = frame("discover_request");
            request["id"] = Value::String(id.clone());
            let output = run_stream(frame_bytes(&request)).1;
            let expected = if accepted {
                frame_bytes(&mcp_contract_runtime::discover_response(&Value::String(id)).unwrap())
            } else {
                error_bytes("invalid_request")
            };
            assert_eq!(output, expected);
            if accepted {
                assert!(!String::from_utf8(output).unwrap().contains("\\u00e9"));
            }
        }
    }

    #[test]
    fn stream_continues_after_rejections_and_accepts_final_frame_at_eof() {
        let list = frame("tools_list_request");
        let expected_list =
            frame_bytes(&mcp_contract_runtime::tools_list_response(&list["id"]).unwrap());

        let mut parse_then_valid = b"{\n".to_vec();
        parse_then_valid.extend(frame_bytes(&list));
        let mut expected = error_bytes("parse_error");
        expected.extend(expected_list.clone());
        assert_eq!(run_stream(parse_then_valid).1, expected);

        let mut overlong_then_valid = vec![b'x'; 1_048_577];
        overlong_then_valid.push(b'\n');
        overlong_then_valid.extend(frame_bytes(&list));
        let mut expected = error_bytes("parse_error");
        expected.extend(expected_list);
        assert_eq!(run_stream(overlong_then_valid).1, expected);

        let mut discover = frame("discover_request");
        discover["id"] = json!("réq");
        let mut unterminated = frame_bytes(&discover);
        unterminated.pop();
        assert_eq!(
            run_stream(unterminated).1,
            frame_bytes(&mcp_contract_runtime::discover_response(&json!("réq")).unwrap())
        );
    }

    #[test]
    fn prepared_cancellation_is_suppressed_but_emitted_response_is_final() {
        let mut server = test_server();
        let request = frame("discover_request");
        let (response, prepared) = server.dispatch_for_wire(&request, b"principal").unwrap();
        assert!(response.is_some());
        let prepared = prepared.expect("wire response remains active until emission");
        let mut cancel = frame("cancelled_notification");
        cancel["params"]["requestId"] = request["id"].clone();
        assert_eq!(server.dispatch(&cancel, b"principal").unwrap(), None);
        assert!(!server.wire_response_ready(Some(&prepared)));

        let mut input = frame_bytes(&request);
        input.extend(frame_bytes(&cancel));
        let expected =
            frame_bytes(&mcp_contract_runtime::discover_response(&request["id"]).unwrap());
        assert_eq!(run_stream(input).1, expected);
    }
}

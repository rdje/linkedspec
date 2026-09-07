---
id: rust-mcp-final-eof-byte-limit-gap
title: "Rust MCP accepts one extra payload byte at final EOF"
answers:
  - "does Rust MCP enforce the same byte limit at EOF and newline"
  - "why does a 1048577 byte MCP EOF frame succeed in Rust"
  - "which task owns MCP final EOF payload size enforcement"
  - "do passing MCP line and EOF unit tests cover their combined boundary"
date: 2026-09-07
status: confirmed-open
tags: [rust, perl, mcp, stdio, eof, framing, limits, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.3.26: twelve paired public serve_stdio controls, exact limit and adjacent lengths across EOF/LF/CRLF; one Rust discrepancy at EOF maximum+1. Six existing Rust wire tests pass."
reverify: "Recreate the twelve valid padded discover_request cases below from the frozen bundle and execute public Rust McpServer::serve_stdio and Perl MCPServer::serve_stdio with caller-owned memory streams and repository-local managed tools."
---

# Final EOF misses the retained CR allowance check

The normative `capability_conformance/mcp_semantic_transport_contract.json` limit is
**1,048,576 payload bytes**, excluding an LF or CRLF delimiter. Startup `.3.3.26` reads all
of Rust `mcp_wire.rs` and compares independently valid canonical discovery frames padded
with ASCII spaces to four adjacent lengths. The canonical request is 279 bytes before padding.

| Payload bytes | Expected / Perl EOF | Rust EOF | LF and CRLF, both implementations |
| ---: | --- | --- | --- |
| 1,048,575 | success | success | success |
| 1,048,576 | success | success | success |
| 1,048,577 | parse error -32700 | **success** | parse error -32700 |
| 1,048,578 | parse error -32700 | parse error -32700 | parse error -32700 |

All twelve Rust and twelve Perl calls return normal EOF status, one response each,
and zero optional log bytes. The Rust program and compiler exit zero with empty process stderr.
Success responses are 487 bytes; parse-error responses are 76. These are public library calls
over owned in-memory streams; no CLI mode, external service or real user data is involved.
No other runtime or unbounded-size acceptance is inferred.

## Exact mechanism and coverage gap

The Rust reader retains at most `maximum_line_bytes + 1` bytes to allow a trailing CR.
Its LF branch removes that CR and rechecks the resulting payload length. Its EOF branch
at lines 59–70 instead passes the retained buffer directly to `process_payload`.
Rust `decode_payload` begins with BOM/UTF-8 checks and has no independent byte ceiling.
Thus maximum+1 valid bytes at EOF bypass the newline-only check; maximum+2 marks the
buffer overlong and is correctly rejected.

Perl's reader uses the same retained CR allowance and direct EOF route, but
`MCPWire::_decode_payload` rejects `length($payload) > $MAX_LINE_BYTES` before decoding.
The supporting Perl source is baseline-identical. The comparison's first attempted script
used unsupported `log_handle` and was rejected before any case ran; the corrected script
uses the authoritative `log` option. That diagnostic setup error is not a product defect.

All six existing Rust wire unit tests pass (172 filtered, 0.03 test seconds; 280.452 total,
reported build 2m42s). Their controls include ordinary final EOF, maximum-size CRLF and
overlong malformed input, but not an independently valid maximum+1 EOF frame. This is why
individual passing tests do not establish the combined boundary.

## Reproduction and evidence

Prepare `request.json` from `build_bundle()["canonical_frames"]["discover_request"]`
using `tools/mcp_contract_binding.py` canonical serialization. For each ending EOF/LF/CRLF
and length 1,048,575/1,048,576/1,048,577/1,048,578, append spaces to the payload size, then
append only the chosen delimiter. Create a new server for each input, capture exactly one
response, and compare its error code with the independent byte limit. Rust invokes:

```rust
let mut server = linkedspec_runtime::mcp_server::McpServer::new().unwrap();
let mut input = std::io::Cursor::new(bytes);
let mut output = Vec::new();
let mut log = Vec::new();
server.serve_stdio(&mut input, &mut output, b"reading-check", Some(&mut log)).unwrap();
```

Perl uses `LinkedSpec::MCPServer->new->serve_stdio(input=>$in, output=>$out,
authorization_context=>'reading-check', log=>$logs)` on equivalent in-memory handles.
The exact probe sources, command/status files and captured responses are retained under
`.linkedspec-data/scratch/startup85-mcp-wire-boundaries/`.

| Evidence | Bytes | SHA-256 |
| --- | ---: | --- |
| paired-results.json | 2250 | 6df59fc3c3c5c61aed49f5acb976539c00035a7093333f0d38b1c68bd34fb23b |
| probe.rs | 1367 | 0960419f305a049b41040482f0c316c8eb71d31705cb20660b95e6b3a95951c5 |
| perl-results.jsonl | 1164 | d389f6682f84f6da6a821891d7798e62ec1c07316c7f702cffcfece4431dee98 |
| wire-test-stdout.log | 630 | d09f4d639db1878f727918c07085671e6d19340af793cee4e976deed4f3dc3ee |
| wire-test-stderr.log | 798549 | e85ac86ff3511f5a1c96a84ea0ce15a972ef096a035feae4ca2ccc7c72077dfb |

The probe linked the verified existing runtime rlib SHA-256
`7cbddb91b8c3043adaf709ae4344f94cf0b17f80e25569456445285648f8c972`;
its managed compiler took 35.867 seconds and public execution 0.468. Compilation waited for
the wire test job to finish. The unit build's 1,870 pgen/26 rgx-core warnings remain separately
owned; no cache reset or artifact recovery occurred. All jobs/results are consumed.

[[SESSION-STARTUP-READING]] `.65.1` owns the Rust repair, `.65.2` owns delimiter/chunk/size
recurrence and six-runtime census, and `.65.3` owns public/Knowledge/canonical closure after
startup prerequisites. Related: [[rust-native-mcp-server-plan]].

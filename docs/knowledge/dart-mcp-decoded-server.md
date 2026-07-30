---
id: dart-mcp-decoded-server
title: Dart has a native dependency-free decoded MCP server around SemanticIndex
answers:
  - "is the Dart LinkedSpec MCP decoded server implemented"
  - "how do I register a Dart SemanticIndex with MCP"
  - "how do I call Dart McpServer dispatch"
  - "which Dart files implement the MCP decoded server"
  - "how does Dart MCP generate and authorize handles"
  - "does Dart MCP read contract files at runtime"
  - "is Dart MCP stdio implemented yet"
  - "is the Dart MCP implementation admitted yet"
date: 2026-07-29
status: decoded server and strict stdio implemented, exactly admitted, and parent-closed
tags: [dart, mcp, semantic-introspection, embedding, handles, security, generated-data]
evidence: dart/lib/src/mcp/mcp_contract.dart; dart/lib/src/mcp/mcp_contract_runtime.dart; dart/lib/src/mcp/mcp_server.dart; dart/lib/src/mcp/mcp_wire.dart; dart/lib/linkedspec_dart.dart; dart/test/mcp_contract_dart_binding_test.dart; dart/test/mcp_server_dart_dispatch_test.dart; dart/test/mcp_server_dart_stdio_test.dart; dart/test/mcp_server_dart_admission_test.dart; tools/generate_dart_mcp_contract.py; capability_conformance/mcp_implementation_admission.json
reverify: "bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py && bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py && bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py && bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py && bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py && bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py && cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart test/mcp_server_dart_admission_test.dart"
---

# Dart Decoded MCP Server

`FUTURE-PARITY-BACKLOG.10.9.4.1` implements the public dependency-free Dart `McpServer`. A host constructs an
immutable `SemanticIndex`, registers that exact object with 1–4,096 opaque authorization bytes and optional
lowering-only limits, then passes already-decoded JSON-like requests to `dispatch`. The server calls only fresh
`index.capabilities.toJson()` and `index.queryNeutral(request).toJson()`; `.10.9.4.2` adds strict caller-owned
stdio without changing that semantic seam. The server cannot load or compile source, execute
a parser, open a file, start a process, use a socket, enable trace, or retain a semantic response cache.

`tools/generate_dart_mcp_contract.py` renders the formatter-stable 82,875-byte private `mcp_contract.dart` part
from the same digest-verified neutral bundle as Perl and Rust. `mcp_contract_runtime.dart` verifies and decodes it
once, implements the frozen schema subset, clones public data recursively, and constructs Dart-identity response
shells without runtime contract-file reads. `mcp_server.dart` owns registry and decoded behavior.

Production handles contain exactly 256 bits from `Random.secure()`, encoded as 43 unpadded base64url characters.
The server retains only a SHA-256 authorization digest, compares all 32 bytes with a fixed-work XOR accumulator
and a dummy unknown-handle digest, measures absolute expiry with a started monotonic `Stopwatch`, bounds live
handles at 1,024, prunes expired entries, and clears retained indexes on shutdown. Unknown, expired, revoked, and
unauthorized handles are externally indistinguishable. Lowering policy may reduce source detail, digest access,
page size, and query budgets but cannot raise native authority.

Focused proof covers all canonical decoded classifications, native response identity, policy denial before native
query dispatch, clone isolation, registration/expiry/capacity/revocation/shutdown, entropy and clock failures,
authorization copying, sanitized native failures, cancellation timing, and production authority fences. Exact
`.10.9.4.3` composes those committed owners through one ordered twelve-role consumer; Dart is formally admitted
at 3/5 implementations plus 3/6 runtimes while shared rollout remains pending.
No-change `.10.9.4.4` reruns that consumer with the neutral, Perl, and Rust owners unchanged, preserves the same
ledger and all 58 rejected mutations, and closes the Dart parent before Julia starts.

Related facts: [[dart-native-mcp-server-plan]], [[dart-semantic-query-public-api]],
[[dart-mcp-strict-stdio]], [[mcp-2026-07-28-stdio-contract]], and [[mcp-implementation-admission-ledger]].

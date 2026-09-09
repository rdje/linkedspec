---
id: dart-native-mcp-server-plan
title: Dart MCP will use one generated private-part library around native SemanticIndex values
answers:
  - "how will the Dart MCP server be implemented"
  - "how do I register a Dart SemanticIndex with MCP"
  - "which Dart files will own MCP"
  - "will Dart MCP read contract files at runtime"
  - "does Dart jsonDecode reject duplicate keys"
  - "does Dart jsonEncode produce canonical JSON"
  - "how will Dart MCP generate secure handles"
  - "how will Dart MCP measure handle expiry"
  - "will Dart MCP add a crypto or MCP SDK dependency"
  - "how will Dart MCP serve stdio"
  - "will Dart MCP add a CLI mode or executable"
  - "what are the Dart MCP implementation leaves"
  - "when will Dart MCP advance the implementation ledger"
date: 2026-07-29
status: complete; generated binding/runtime, decoded server, strict stdio, admission, and parent closeout complete
tags: [dart, mcp, semantic-introspection, embedding, handles, json, stdio, security, generated-data]
evidence: docs/decisions/0059-dart-native-mcp-server-seams.md; docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.9.4.0-.4; dart/lib/src/mcp/mcp_contract.dart; dart/lib/src/mcp/mcp_contract_runtime.dart; dart/lib/src/mcp/mcp_server.dart; dart/lib/src/mcp/mcp_wire.dart; dart/test/mcp_contract_dart_binding_test.dart; dart/test/mcp_server_dart_dispatch_test.dart; dart/test/mcp_server_dart_stdio_test.dart; dart/test/mcp_server_dart_admission_test.dart; capability_conformance/mcp_implementation_admission.json
reverify: "bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py && bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py && bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py && bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py && bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py && bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py && cd dart && bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart test/mcp_server_dart_admission_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

# Dart Native MCP Server Plan

Behavior-free leaf `FUTURE-PARITY-BACKLOG.10.9.4.0` and ADR `0059` freeze Dart as the third native MCP
implementation. Leaf `.10.9.4.1` now implements `McpServer` around caller-created immutable Dart `SemanticIndex`
objects in the same process, registers 43-character opaque handles against out-of-band authorization and
lowering-only policy, calls only `capabilities` and `queryNeutral`, and exposes decoded dispatch. It does not
load paths, compile source, execute parsers, enable trace, cache semantic responses, add a primary-CLI mode, or use
an MCP/network SDK.

All four private-part owners now live under `dart/lib/src/mcp/`: generated `mcp_contract.dart`, frozen
`mcp_contract_runtime.dart`, public-host `mcp_server.dart`, and strict transport `mcp_wire.dart`.
The shared-bundle consumer generates the 82,875-byte data-only Dart part after neutral materialization/validation
and preserves the Perl/Rust files byte-identically. Runtime contract behavior is filesystem-free. The package
umbrella exports only supported server/value types; deterministic entropy/time/failure seams remain in an
unexported package-internal test harness.

The repository-managed Dart 3.9.2 probe establishes that stock `jsonDecode` overwrites both literal and escape-
equivalent duplicate keys and that `jsonEncode` preserves insertion order. Consequently the wire owner must scan
strict UTF-8 JSON tokens before decoding and recursively sort map keys before encoding. Core `Random.secure()` is
documented cryptographic and fail-closed, core `Stopwatch` is monotonic, core base64url yields the required handle
encoding, and the existing package-internal SHA-256 implementation can digest authorization bytes. No production
dependency is needed.

The omission-safe split is complete: `.10.9.4.1` owns the generated binding/runtime/registry/decoded dispatch;
`.2` owns strict stdio and lifecycle; `.3` alone advances Dart to 3/5 implementations and 3/6 runtimes while
rollout stays pending; and no-change `.4` recomposes those committed owners without replacement behavior or
status movement, closes the Dart parent, and hands the exact contract to Julia `.10.9.5`.

Related facts: [[dart-semantic-query-public-api]], [[dart-semantic-introspection-admission]],
[[mcp-native-server-topology]], [[mcp-2026-07-28-stdio-contract]],
[[dart-mcp-strict-stdio]], [[mcp-implementation-admission-ledger]], and [[rust-native-mcp-server-plan]].

## 2026-09-09 — generated-file size qualification

The 82,875-byte value above records the original implementation boundary. At
`DART-STARTUP-READING.1.9` the baseline-identical generated file is 83,214 bytes and the
generator's read-only default check passes. Current bounded reading and decoded identity proof
live in [[dart-mcp-decoded-server]]; no production seam or authority is changed here.

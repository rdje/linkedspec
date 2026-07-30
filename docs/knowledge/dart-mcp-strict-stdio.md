---
id: dart-mcp-strict-stdio
title: Dart MCP strict stdio is bounded, duplicate-safe, canonical, and caller-owned
answers:
  - "is Dart MCP strict stdio implemented"
  - "how does Dart MCP frame stdio"
  - "how does Dart MCP reject duplicate JSON keys"
  - "does Dart MCP close caller streams or sinks"
  - "how does Dart MCP handle input output or flush failures"
  - "how does Dart MCP cancellation interact with response flush"
  - "which file owns the Dart MCP wire"
date: 2026-07-29
status: strict stdio implemented; formal Dart MCP admission pending
tags: [dart, mcp, stdio, json, framing, cancellation, io, security]
evidence: dart/lib/src/mcp/mcp_wire.dart; dart/lib/src/mcp/mcp_server.dart; dart/test/mcp_server_dart_stdio_test.dart; docs/decisions/0059-dart-native-mcp-server-seams.md; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.9.4.2; tools/check_mcp_implementation_admission.py; tools/run_ci_local.sh
reverify: "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart && cd .. && bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
---

# Dart MCP Strict Stdio

`FUTURE-PARITY-BACKLOG.10.9.4.2` implements public `McpServer.serveStdio` over a caller-owned
`Stream<List<int>>`, borrowed output `IOSink`, and optional distinct borrowed log `IOSink`. The server never closes
those objects. It validates authorization before consuming input, accepts LF, CRLF, or one final complete frame at
EOF, retains at most the 1,048,576-byte payload limit plus a possible CR, and drains an overlong line without
unbounded growth.

Private `mcp_wire.dart` performs iterative depth-64 token preflight before `jsonDecode`. It rejects invalid UTF-8,
BOMs, malformed JSON and numbers, non-finite decoded values, arrays/non-object roots, invalid request-id token
kinds or safe-range values, incomplete escapes or surrogate pairs, and duplicate decoded object keys including
escape-equivalent spellings. Canonical output recursively sorts object keys, preserves list and Unicode scalar
content, uses UTF-8, and appends exactly one LF.

An accepted request id remains active through successful output flush. Cancellation observed at the deterministic
pre-emission boundary suppresses the prepared response; a flushed response is final. Graceful EOF flushes and
releases every registered index. Input, add, or flush failure performs the same shutdown, emits at most the fixed
`linkedspec_mcp_io_failure` code to the optional log, and throws the sanitized typed
`linkedspec_mcp_io_failure` error. The production authority surface imports only `dart:io show IOSink`; it gains no
file, process, socket, HTTP, isolate, parser, compiler, runtime, trace, emitter, cache, or CLI authority.

Focused binding/decoded/stdio proof is 15/15 and the complete Dart package is 352/352 with clean analysis. The
implementation ledger deliberately remains 2/5 implementations and 2/6 runtimes with rollout pending;
`.10.9.4.3` alone owns formal Dart admission.

Related facts: [[dart-mcp-decoded-server]], [[dart-native-mcp-server-plan]],
[[mcp-2026-07-28-stdio-contract]], and [[mcp-implementation-admission-ledger]].

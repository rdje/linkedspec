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

## 2026-09-09 — generated prefix reading boundary

`DART-STARTUP-READING.1.8` reads only `mcp_contract.dart` lines 1-9: generator provenance,
private part membership, binding format 1, bundle digest
`a1d2857c57ef93ea0e62403977105fdf6380f6fcb4d7a89ed5749c1bfdd64001` and the JSON declaration.
The current baseline-identical file is 83,214 bytes; 82,875 above describes its earlier boundary.
The four binding tests pass within 42 selected tests, independently checking digest/clone isolation,
frozen schema behavior, canonical frames and serialization. Those tests grant no physical payload
reading credit: .1.9 starts bytes 320-65855, with the remainder owned by .1.10.
The existing query-only scope remains; parser builders and fileless execution/debugging are parked.

## 2026-09-09 — first generated bundle window

`DART-STARTUP-READING.1.9` reads bytes 320-65855 in six complete UTF-8 windows.
This includes all canonical frames, transport policy and corpus, plus the schema prefix ending
inside `semanticQueryRequest.page`. Semantic `ok=false` remains a native payload with tool
`isError=false`; unavailable handles/policy denials use tool errors and malformed protocol input
uses JSON-RPC errors. Policy checks only explicitly supplied overlay components; unsupplied
components retain native dispatch/portable responses, as the neutral contract already records.

The four existing binding tests pass. Independent neutral validation passes 35 frames,
10 raw inputs, 10 lifecycle cases and 76 rejected mutations. The generator's default check proves
the whole 83,214-byte file byte-fresh; decoded contract/schema/corpus equal their neutral owners.
The 82,882-byte embedded JSON has the unchanged digest recorded above. Whole-bundle checks do
not grant physical credit for the remaining .1.10 bytes, runtime or server.

`bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py` checks freshness without
rewriting source. The following independent comparison preserves that same read-only boundary:

```bash
bash tools/project_data_run.sh python3 - <<'DART_MCP_BUNDLE_IDENTITY'
from pathlib import Path
import hashlib,json
source=Path('dart/lib/src/mcp/mcp_contract.dart').read_text()
quote=chr(39)*3
payload=source.split('r'+quote,1)[1].rsplit(quote,1)[0]
bundle=json.loads(payload)
for key,path in [
    ('contract','capability_conformance/mcp_semantic_transport_contract.json'),
    ('schema','capability_conformance/mcp_semantic_transport/schema.json'),
    ('corpus','capability_conformance/mcp_semantic_transport/corpus.json'),
]:
    assert bundle[key]==json.loads(Path(path).read_text()),key
assert len(payload.encode())==82882
assert hashlib.sha256(payload.encode()).hexdigest()=='a1d2857c57ef93ea0e62403977105fdf6380f6fcb4d7a89ed5749c1bfdd64001'
print('PASS embedded contract/schema/corpus identity and dated bundle bytes/digest')
DART_MCP_BUNDLE_IDENTITY
```

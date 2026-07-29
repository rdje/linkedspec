---
id: perl-mcp-decoded-server
title: Perl MCP generated binding, decoded dispatch, and strict stdio server
status: current implementation; decoded dispatch, strict stdio, and exact Perl admission complete
date: 2026-07-29
answers:
  - Is the Perl LinkedSpec MCP server implemented?
  - How do I register a Perl SemanticIndex with MCP?
  - Does Perl MCP read the neutral JSON contract at runtime?
  - How are Perl MCP handles generated and authorized?
  - Which Perl MCP methods work over decoded dispatch and stdio?
  - Does Perl MCP cache semantic query responses?
  - How does Perl MCP enforce deployment policy?
  - Can Perl MCP compile a source path or inspect the descriptor?
  - Where is the generated Perl MCP contract checked in canonical CI?
  - Is serve_stdio implemented for Perl MCP yet?
  - How does Perl MCP reject duplicate JSON keys and unsafe numeric ids?
  - What does Perl MCP emit on EOF or an I/O failure?
  - Is the Perl MCP implementation admitted?
  - How many MCP implementations and runtimes are admitted?
reverify:
  - bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
  - bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
  - bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py
  - PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t
  - bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py
  - PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t
---

# Perl MCP generated binding, decoded dispatch, and strict stdio server

`FUTURE-PARITY-BACKLOG.10.9.2.1-.2` implement the first native MCP consumer and its strict stdio transport. Public
`LinkedSpec::MCPServer` accepts an already-created opaque `LinkedSpec::SemanticIndex`, registers it under one
out-of-band authorization context, and dispatches already-decoded `server/discover`, `tools/list`, the exact two
semantic `tools/call` operations, and `notifications/cancelled`. The same object now serves caller-provided handles
through `serve_stdio(input => ..., output => ..., authorization_context => ..., log => ...)`. It cannot open source
or contract paths, compile, execute, inspect descriptors, cache semantic responses, or enter the primary facade/CLI.

`tools/generate_perl_mcp_contract.py` verifies every artifact digest named by the neutral manifest and derives the
committed data-only `perl/LinkedSpec/MCPContract.pm`. `LinkedSpec::MCPContractRuntime` decodes that embedded value
once, deep-clones every returned value, implements only the frozen JSON Schema keyword profile, and builds exact
Perl discovery/list/tool/error shells. Neither production module names or opens a neutral artifact path. Canonical
CI runs materialization, independent validation, then generated-binding freshness in that exact order; the tool
storage proof rejects omission and reordering.

Production registration reads exactly 32 bytes from `/dev/urandom`, emits a 43-character unpadded base64url
handle, and retries collisions only to a fixed bound. Expiry is absolute and monotonic; default/maximum lifetime
and 1,024-entry capacity come from the embedded contract. Authorization accepts 1..4,096 opaque bytes, retains
only SHA-256, and performs the same 32-byte XOR comparison step using a dummy digest for an unknown handle.
Unknown, expired, revoked, and unauthorized valid handles therefore share one external tool error. Only private
`_new_for_test` accepts deterministic entropy/time and reduced test capacity/collision bounds.

Registration calls native capabilities once to validate the index and retain only five ceiling scalars. A live
capabilities tool call still invokes native capabilities; an allowed query is passed unchanged to native query.
Policy can lower only source detail, page maximum, and record/relation/depth maxima. Restricted capabilities are a
schema-preserving projection; an above-policy request is denied before native query. No semantic answer is stored.
Unexpected native exceptions or invalid responses become sanitized `-32603` errors. Cancellation observed while a
response is prepared or waiting for emission suppresses it; ordinary synchronous completion remains valid.

Private `LinkedSpec::MCPWire` reads bounded chunks, retains at most the exact line ceiling plus a possible CR,
accepts LF/CRLF and a complete final EOF frame, and drains one rejected overlong line before continuing. It rejects
invalid UTF-8, BOM, malformed/non-finite JSON, batches/non-objects, depth above 64, literal or escape-equivalent
duplicate keys, non-integer/unsafe ids, and overlong lines at their contract-owned JSON-RPC layer. `JSON::PP` with
bignum decoding constructs values only after that token preflight. Output is frozen-schema-validated, sorted compact
UTF-8 JSON plus one LF. Default stderr is empty; an optional distinct log handle receives only the fixed
`linkedspec_mcp_io_failure` event on I/O failure. Graceful EOF flushes complete responses, clears the registry,
releases indexes, and returns zero; input/output failure performs the same cleanup and returns nonzero.

`FUTURE-PARITY-BACKLOG.10.9.2.3` admits this implementation through one exact twelve-role consumer and a separate
status/proof ledger. Current topology is Perl complete at 1/5 native implementations and 1/6 runtime admissions,
with every other row and shared thin rollout pending. The ledger pins the unchanged transport digest; its checker
rejects 28 status, topology, role, source-authority, tracked-input, and canonical-order mutations. The admission
consumer composes existing server/native/neutral authorities and defines no second semantic or protocol oracle.

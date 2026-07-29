---
id: perl-mcp-decoded-server
title: Perl MCP generated binding and decoded in-process server
status: current implementation; decoded dispatch complete, strict stdio pending
date: 2026-07-29
answers:
  - Is the Perl LinkedSpec MCP server implemented?
  - How do I register a Perl SemanticIndex with MCP?
  - Does Perl MCP read the neutral JSON contract at runtime?
  - How are Perl MCP handles generated and authorized?
  - Which Perl MCP methods work before the stdio wire is implemented?
  - Does Perl MCP cache semantic query responses?
  - How does Perl MCP enforce deployment policy?
  - Can Perl MCP compile a source path or inspect the descriptor?
  - Where is the generated Perl MCP contract checked in canonical CI?
  - Is serve_stdio implemented for Perl MCP yet?
reverify:
  - bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
  - bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
  - bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py
  - PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t
---

# Perl MCP generated binding and decoded in-process server

`FUTURE-PARITY-BACKLOG.10.9.2.1` implements the first native MCP consumer without adding transport I/O. Public
`LinkedSpec::MCPServer` accepts an already-created opaque `LinkedSpec::SemanticIndex`, registers it under one
out-of-band authorization context, and dispatches already-decoded `server/discover`, `tools/list`, the exact two
semantic `tools/call` operations, and `notifications/cancelled`. It cannot open source or contract paths, compile,
execute, inspect descriptors, cache semantic responses, or enter the primary `LinkedSpec` facade/CLI.

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
response is prepared suppresses it; ordinary synchronous completion remains valid.

Strict UTF-8 JSON-line parsing, duplicate-key/numeric-token preflight, canonical LF emission, optional sanitized
logging, caller-provided stdio handles, and EOF/I/O cleanup remain exclusively owned by `.10.9.2.2` and future
`LinkedSpec::MCPWire`. `serve_stdio(...)` therefore does not exist yet; use decoded `dispatch(...)` in process.

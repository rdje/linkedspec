---
id: mcp-2026-07-28-stdio-contract
title: LinkedSpec MCP v1 is modern MCP 2026-07-28 over stdio
answers:
  - which MCP protocol version does LinkedSpec target
  - is LinkedSpec MCP modern or legacy
  - does LinkedSpec MCP implement initialize or notifications initialized
  - does LinkedSpec MCP implement ping
  - does LinkedSpec MCP support legacy MCP clients
  - does LinkedSpec MCP use server discover
  - what request metadata does LinkedSpec MCP require
  - what transport does LinkedSpec MCP use
  - what methods does the LinkedSpec MCP server implement
  - how are LinkedSpec MCP handles generated and expired
  - how are MCP handle errors reported
  - how does MCP deployment policy lower semantic limits
  - what does direct native MCP response identity mean
  - can LinkedSpec MCP write logs to stdout
  - how does LinkedSpec MCP shut down
  - where is the LinkedSpec MCP machine contract
  - how many canonical MCP fixtures exist
  - how do I regenerate or verify the MCP canonical frames
  - are the native LinkedSpec MCP servers implemented yet
date: 2026-07-29
status: exact neutral contract canonical; Perl/Rust admitted at 2/5 + 2/6; Dart strict stdio implemented
tags: [mcp, json-rpc, stdio, semantic-api, security, transport, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0055 and FUTURE-PARITY-BACKLOG.10.9.1.0 select the stable final 2026-07-28 stateless revision, modern-only stdio, exact discovery/two-tool topology, explicit opaque handle registry, lowering-only deployment policy, canonical payload identity, cancellation, stderr-only sanitized logging, and EOF shutdown."
evidence_update_2026_07_29_machine_contract: "FUTURE-PARITY-BACKLOG.10.9.1.1 encodes the policy once as a digest-pinned neutral manifest, closed JSON Schema 2020-12, four semantic payloads, 35 canonical frames, ten raw-byte inputs, ten lifecycle cases, and one repository-routed deterministic materializer; no native MCP server exists yet."
evidence_update_2026_07_29_independent_validation: "FUTURE-PARITY-BACKLOG.10.9.1.2 adds a no-import/no-execution validator over the exact JSON Schema 2020-12 profile, 28 accepted and seven rejected frames, ten raw inputs, ten lifecycle cases, native/restricted payload identity, handle/policy state, and 68 rejected mutations; no server behavior exists yet."
evidence_update_2026_07_29_contract_closeout: "FUTURE-PARITY-BACKLOG.10.9.1.3 makes the exact materializer and independent validator unconditional canonical-CI steps in that order, locks omission/order mutations, closes the neutral contract parent, and adds no server or semantic behavior."
evidence_update_2026_07_29_perl_and_rust: "Perl .10.9.2 is implemented, admitted, and parent-closed at the first 1/5 + 1/6 state. Rust .10.9.3.1-.3 implement the generated binding, frozen schema runtime, secure registry, decoded public server, strict borrowed-stream stdio, and exact admission; the ledger is 2/5 implementations + 2/6 runtimes with shared rollout pending."
evidence_update_2026_07_29_rust_closeout: "Rust .10.9.3.4 recomposes the committed exact transport, both bindings, both server/admission owners, and the unchanged 2/5 + 2/6 ledger under complete focused/canonical proof; parent .10.9.3 closes and Dart .10.9.4 is next."
evidence_update_2026_07_29_dart_plan: "Dart .10.9.4.0 and ADR 0059 prove stock Dart JSON overwrites decoded duplicate keys and preserves insertion order, then freeze explicit token preflight/canonical sorting plus core secure entropy, monotonic expiry, generated private-part data, native server, stdio, admission, and closeout seams without implementation."
evidence_update_2026_07_29_dart_decoded: "Dart .10.9.4.1 implements the generated binding/runtime, secure in-process registry, and exact decoded discovery/list/two-tool/cancellation server; strict raw stdio and formal admission remain .2-.3."
evidence_update_2026_07_29_dart_stdio: "Dart .10.9.4.2 implements bounded caller-owned stdio, iterative duplicate-safe lexical preflight, canonical LF emission, cancellation through flush, fixed optional diagnostics, and EOF/I/O release; formal admission remains .3 and the ledger stays 2/5 + 2/6."
reverify: "bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py && bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py"
---

LinkedSpec contract `linkedspec-mcp-transport-v1` targets only stable MCP `2026-07-28` over stdio. This is the
modern stateless era: every request carries its version and client capabilities in `_meta`, the server implements
mandatory `server/discover`, and application state crosses requests only through explicit handles. The removed
legacy `initialize`/`notifications/initialized` handshake, sessions, and `ping` are not implemented. Any later
legacy compatibility requires measured need and a separate post-public-closeout task-tree.

The complete method surface is `server/discover`, `tools/list`, `tools/call`, and client-to-server
`notifications/cancelled`. Discovery advertises only tools with `listChanged: false`. The fixed tools are
`linkedspec_semantic_capabilities(handle)` and `linkedspec_semantic_query(handle, request)`. Every result carries
native server identity; the five implementations share exact tool schemas and bytes while PUC Lua/LuaJIT share
one Lua identity.

Registration is local host API only. It binds an already-created immutable native index to authorization and a
lowering-only deployment policy, then returns 43 unpadded base64url characters encoding 256 CSPRNG bits. Default
absolute expiry is 15 minutes, maximum expiry is 24 hours, and use never extends it. Unknown, expired, revoked,
and unauthorized handles share one non-enumerating tool execution error. Policy may only lower source/page/budget
ceilings; allowed query requests pass unchanged to the native index.

Successful tool text is the admitted canonical semantic JSON without a newline and deep-equals structured
content. The outer stdio frame is canonical JSON plus one LF. Full MCP envelopes differ by request id and native
server identity, so direct/MCP identity means the embedded semantic payload bytes. Stdout carries MCP messages
only; optional sanitized logs use stderr. EOF is graceful shutdown and clears the handle registry.

The machine contract now lives at `capability_conformance/mcp_semantic_transport_contract.json`. It pins its
schema, semantic payloads, corpus, generated canonical JSONL, materializer, validator cases, and validator by SHA-256. The corpus contains 35
ordered frames, ten exact raw-byte cases, ten lifecycle cases, all five native identities, four deliberately
indistinguishable handle states, and four lowering-policy cases. Verify its exact bytes with
`bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py`; use `--write` only
when deliberately regenerating the JSONL. Run
`bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py` for the independent
28-positive/7-negative schema and 68-mutation proof. Perl and Rust implement, admit, and parent-close that
contract. Dart implements generated/runtime/decoded/strict-stdio production owners under ADR `0059`, while its
formal admission and later Julia/Lua work remain pending.
Canonical local CI runs those exact two commands unconditionally in materializer-then-validator order; the tool
governance test rejects either an omitted materializer or reversed order.

Related facts: [[mcp-native-server-topology]], [[dart-native-mcp-server-plan]], [[dart-mcp-decoded-server]], [[dart-mcp-strict-stdio]], [[semantic-introspection-api-mcp-direction]],
[[semantic-introspection-neutral-contract]], [[project-data-storage-locality-contract]].

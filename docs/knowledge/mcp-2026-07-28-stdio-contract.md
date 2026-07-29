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
date: 2026-07-29
status: architecture accepted; machine contract and implementations pending
tags: [mcp, json-rpc, stdio, semantic-api, security, transport, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0055 and FUTURE-PARITY-BACKLOG.10.9.1.0 select the stable final 2026-07-28 stateless revision, modern-only stdio, exact discovery/two-tool topology, explicit opaque handle registry, lowering-only deployment policy, canonical payload identity, cancellation, stderr-only sanitized logging, and EOF shutdown."
reverify: "rg -n '2026-07-28|server/discover|linkedspec-mcp-transport-v1|linkedspec_mcp_handle_unavailable|linkedspec_mcp_policy_denied' docs/decisions/0055-modern-mcp-2026-07-28-stdio-contract.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/public-api/semantic-introspection.md"
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

Related facts: [[mcp-native-server-topology]], [[semantic-introspection-api-mcp-direction]],
[[semantic-introspection-neutral-contract]], [[project-data-storage-locality-contract]].

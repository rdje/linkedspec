---
id: mcp-native-server-topology
title: One MCP contract has five native server implementations and six runtime admissions
answers:
  - should LinkedSpec use one MCP server for every backend
  - does each LinkedSpec backend get its own MCP server
  - how many LinkedSpec MCP server implementations are planned
  - how many LinkedSpec MCP runtime admissions are planned
  - do PUC Lua and LuaJIT share one MCP server implementation
  - what does MCP uniformity mean across LinkedSpec backends
  - can a LinkedSpec MCP server compile or load a specification
  - is a unified MCP aggregator part of FUTURE-PARITY-BACKLOG.10.9
  - what task implements LinkedSpec MCP transport
date: 2026-07-29
status: architecture accepted; executable contract and implementations pending
tags: [mcp, semantic-api, backends, transport, embedding, parity, FUTURE-PARITY-BACKLOG]
evidence: "Director approved ADR 0054 and FUTURE-PARITY-BACKLOG.10.9.0: one exact contract, native Perl/Rust/Dart/Julia/Lua implementations, shared Lua source on PUC Lua and LuaJIT, and recurring six-runtime conformance."
reverify: "rg -n 'one exact MCP contract|five native server implementations|six runtime admissions|aggregator' docs/decisions/0054-one-mcp-contract-native-per-backend-servers.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/public-api/semantic-introspection.md"
---

LinkedSpec MCP uniformity means one versioned wire/tool/error/lifecycle contract and one conformance corpus, not
one executable that embeds every backend runtime. Perl, Rust, Dart, Julia, and Lua each implement the adapter in
the runtime that owns the registered immutable semantic index. One Lua-5.1-compatible source is admitted
independently on PUC Lua and LuaJIT, giving five source implementations and six runtime admissions.

Each embedding explicitly registers an opaque handle for an already-created native index. The MCP adapter calls
only that index's admitted `capabilities` and `query` operations. It does not read source paths, compile, execute,
traverse native objects, derive or cache semantic facts, invent explanations, or raise source/budget ceilings.

A one-endpoint aggregator is deferred outside `FUTURE-PARITY-BACKLOG.10.9`. If separately justified and
task-tree-owned after public closeout, it can only route requests to the native servers and cannot become a
semantic owner or cache.

Related facts: [[semantic-introspection-api-mcp-direction]], [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]].

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
status: exact neutral contract canonical; Perl/Rust/Dart/Julia admitted at 4/5 + 4/6; Lua decoded implementation complete but unadmitted; rollout pending
tags: [mcp, semantic-api, backends, transport, embedding, parity, FUTURE-PARITY-BACKLOG]
evidence: "Director approved ADR 0054 and FUTURE-PARITY-BACKLOG.10.9.0: one exact contract, native Perl/Rust/Dart/Julia/Lua implementations, shared Lua source on PUC Lua and LuaJIT, and recurring six-runtime conformance."
evidence_update_2026_07_29_protocol: "ADR 0055 selects stable modern MCP 2026-07-28 over stdio, with server/discover, per-request metadata, two tools, no legacy initialize/session/ping, and any later compatibility separately owned."
evidence_update_2026_07_29_machine_contract: "FUTURE-PARITY-BACKLOG.10.9.1.1 provides the one shared digest-pinned neutral manifest/schema/payload/corpus/JSONL bundle and materializer before any of the five native implementations."
evidence_update_2026_07_29_validation: "FUTURE-PARITY-BACKLOG.10.9.1.2 independently validates the same exact bundle and rejects 68 named mutations without implementing or importing a native server."
evidence_update_2026_07_29_contract_closeout: "FUTURE-PARITY-BACKLOG.10.9.1.3 composition-closes the shared contract by requiring ordered materialization and independent validation in canonical CI; Perl implementation .10.9.2 is next."
evidence_update_2026_07_29_perl_and_rust: "Perl .10.9.2 closes the first native implementation/runtime at 1/5 + 1/6. Rust .10.9.3.1-.3 implement its generated binding, frozen runtime, secure registry, decoded public server, strict borrowed-stream stdio, and exact twelve-role admission; the ledger is 2/5 + 2/6 while shared rollout remains pending."
evidence_update_2026_07_29_rust_closeout: "Rust .10.9.3.4 recomposes every committed neutral, Perl, and Rust MCP owner unchanged under focused and canonical proof, closes parent .10.9.3 without status movement, and hands the exact contract to Dart .10.9.4 after the clean closeout commit."
evidence_update_2026_07_29_dart_plan: "Dart .10.9.4.0 and ADR 0059 freeze a generated private-part binding/runtime, same-process native server, secure handles/authorization/expiry, strict duplicate-safe canonical stdio, exact admission, and no-change closeout under .1-.4 without behavior or 2/5 + 2/6 ledger movement."
evidence_update_2026_07_29_dart_decoded: "Dart .10.9.4.1 implements its generated 82,875-byte binding, frozen runtime, native secure registry, lowering-only policy, and decoded server without stdio or formal ledger movement; .2-.4 remain ordered."
evidence_update_2026_07_29_dart_stdio: "Dart .10.9.4.2 implements its private strict wire and public caller-owned serveStdio surface without formal ledger movement; admission .3 and closeout .4 remain ordered."
evidence_update_2026_07_29_dart_admission: "Dart .10.9.4.3 admits its unchanged four production owners through one ordered twelve-role consumer, advancing only Dart to 3/5 implementations and 3/6 runtime admissions while rollout remains pending and 58 mutations reject drift."
evidence_update_2026_07_29_dart_closeout: "Dart .10.9.4.4 recomposes the committed neutral, Perl, Rust, and Dart owners unchanged, preserves 3/5 implementations + 3/6 runtime admissions and all 58 mutations, closes parent .10.9.4, and hands off to Julia .10.9.5."
evidence_update_2026_07_29_julia_plan: "Julia .10.9.5.0 and ADR 0060 freeze a generated Base64 contract module, private frozen runtime, synchronous native server, strict duplicate-safe number-kind-preserving stdio, OS entropy/monotonic time/digest authorization, exact admission, and no-change closeout under .1-.4 without behavior or 3/5 + 3/6 ledger movement."
evidence_update_2026_07_29_julia_decoded: "Julia .10.9.5.1 implements its 119,538-byte generated Base64 binding, digest-verifying frozen runtime, secure native registry, lowering-only policy, and public decoded server at 48 + 139 assertions without strict stdio or formal ledger movement; .2-.4 remain ordered."
evidence_update_2026_07_29_julia_stdio: "Julia .10.9.5.2 implements strict bounded duplicate-safe number-kind-preserving stdio, canonical LF, cancellation through flush, fixed optional diagnostics, and EOF/I/O release over caller-owned IO at 170 assertions without formal ledger movement; admission .3 and closeout .4 remain ordered."
evidence_update_2026_07_29_julia_admission_closeout: "Julia .10.9.5.3 admits one exact twelve-role consumer at 178 assertions and advances only Julia to 4/5 implementations plus 4/6 runtimes with 79 rejected mutations; no-change .4 recomposes those owners and closes the Julia parent."
evidence_update_2026_07_29_lua_plan: "Lua .10.9.6.0 and ADR 0061 freeze one generated literal binding, private frozen runtime, one protected decoded server, one strict lexical wire, and one tiny native system seam from common Lua/C sources admitted independently on PUC Lua and LuaJIT; behavior and the 4/5 + 4/6 ledger remain unchanged before implementation."
evidence_update_2026_07_29_lua_decoded: "Lua .10.9.6.1 implements its one common generated/frozen/server source graph plus ABI-compiled native entropy/clock seam at 111 + 210 assertions per runtime and 94 governance mutations. Strict wire .2 and exact admission .3 remain pending, so the formal ledger intentionally stays 4/5 implementations + 4/6 runtimes."
reverify: "bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py && rg -n 'one exact MCP contract|five native server implementations|six runtime admissions|aggregator' docs/decisions/0054-one-mcp-contract-native-per-backend-servers.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/public-api/semantic-introspection.md"
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

Related facts: [[mcp-2026-07-28-stdio-contract]], [[lua-native-mcp-server-plan]], [[julia-native-mcp-server-plan]], [[julia-mcp-decoded-server]], [[julia-mcp-strict-stdio]], [[dart-native-mcp-server-plan]], [[dart-mcp-decoded-server]], [[dart-mcp-strict-stdio]], [[semantic-introspection-api-mcp-direction]], [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]].

---
id: lua-mcp-implementation-admission
title: One Lua MCP implementation is admitted independently on PUC Lua and LuaJIT
answers:
  - is the Lua MCP implementation admitted
  - which test admits Lua MCP
  - how many roles does the Lua MCP admission consumer execute
  - how many assertions does Lua MCP admission run
  - do PUC Lua and LuaJIT use the same MCP admission consumer
  - how many MCP implementations and runtimes are admitted after Lua
  - how many MCP implementation admission mutations are rejected after Lua
  - does Lua MCP admission change the server or transport contract
  - what MCP work follows Lua admission
  - is the Lua MCP parent closed
date: 2026-07-29
status: exact one-source dual-ABI admission and no-change parent closeout complete
tags: [lua, luajit, mcp, admission, conformance, governance]
evidence: "FUTURE-PARITY-BACKLOG.10.9.6.3 adds one 202-assertion twelve-role consumer source run unchanged on PUC Lua and LuaJIT. The complete Lua gate passes 111+210+247+202 per ABI, package 177x2, CLI 66x2, corpus 105/105, and storage 16x3. The formal checker reports 5/5 implementations + 6/6 runtimes, shared rollout pending, with 114 rejected mutations. Canonical CI passes all six doctrines and Phase 0 1,031/1,031 in 659 seconds plus the full dual-ABI Lua opt-in."
evidence_update_2026_07_29_closeout: "FUTURE-PARITY-BACKLOG.10.9.6.4 recomposes every committed owner without implementation, fixture, contract, ledger, or topology movement. Canonical CI passes Phase 0 1,031/1,031 in 652 seconds and the full dual-ABI Lua gate; parent .10.9.6 closes at unchanged 5/5 + 6/6 pending/114."
last_verified: 2026-07-29
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/mcp_server_lua_admission_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/mcp_server_lua_admission_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
  - "bash tools/run_lua_local.sh"
---

# Lua MCP Implementation Admission

`lua/test/mcp_server_lua_admission_test.lua` is one Lua-5.1-compatible external consumer source. Repository-
routed commands execute that identical path independently on PUC Lua and LuaJIT. The consumer declares and runs
the exact twelve governed roles once in order: contract inventory, canonical static dispatch, native
capabilities identity, native query identity, raw outcomes, lifecycle outcomes, handle indistinguishability,
policy overlay, cancellation emission, shutdown/I/O, hostile-output/log privacy, and authority fences.

The consumer exercises public `mcp_server`, native `SemanticIndex`, decoded dispatch, and caller-owned stdio
behavior. It composes the already-private focused pre-emission-cancellation and injected-native-failure proofs
only where a cooperative synchronous caller cannot create the hostile state. It also executes the production
1,024-live-handle boundary. There is no skipped role, second expected-response model, ABI fork, or second Lua
implementation.

Admission changes no generated binding, frozen runtime, server, wire, native system module, neutral transport
byte, semantic API, parser/runtime behavior, or primary CLI. The ledger records the existing four Lua production
owners once, points both runtime rows at the same consumer path, and reaches exactly 5/5 implementations plus 6/6
runtimes. `thin_mcp_transport` intentionally remains pending for recurring six-runtime composition
`FUTURE-PARITY-BACKLOG.10.9.7`. Committed-owner closeout `.10.9.6.4` has recomposed those exact authorities and
closed parent `.10.9.6` without behavior or ledger movement.

Related facts: [[lua-native-mcp-server-plan]], [[lua-mcp-decoded-server]],
[[mcp-implementation-admission-ledger]], [[mcp-native-server-topology]], and
[[mcp-2026-07-28-stdio-contract]].

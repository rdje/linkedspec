---
id: lua-recognition-transaction-dormant-red
title: Shared Lua recognition transactions are frozen at one exact dual-ABI private-authority RED
answers:
  - "where is the dormant Lua recognition transaction RED consumer"
  - "how do I run the Lua recognition transaction RED"
  - "does the Lua recognition transaction RED run on PUC Lua and LuaJIT"
  - "what is the first Lua recognition transaction failure"
  - "which private Lua transaction module is missing"
  - "does ordinary Lua discovery run recognition transaction tests"
  - "does canonical CI run Lua recognition transaction tests"
  - "does the Lua transaction RED cover emitted source"
  - "how many Lua dormant RED mutations are rejected"
date: 2026-08-11
status: dormant dual-ABI RED frozen; private authority next under FUTURE-PARITY-BACKLOG.14.3.6.1
tags: [lua, PUC-Lua, LuaJIT, recognition, transaction, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.6.0 adds lua/test/recognition_transaction_contract_test.lua at its final shared path while leaving it absent from tools/run_lua_local.sh and tools/run_ci_local.sh. Explicit authority and integration modes parse completely and exit 1 identically on PUC Lua and LuaJIT with the sole stable boundary 'Lua recognition transaction RED: missing linkedspec.recognition_transaction'. The consumer freezes the current 132/246/44 and rollout 5/9 boundary plus private authority/token/mark/effect/progress semantics and native, reconstructed, generated-plan, and in-memory emitted-module carriers. Twelve independent mutations reject missing selectors/private lookup/diagnostic/integration/current status, premature ordinary/canonical registration, facade export, and ABI command collapse. Complete ordinary Lua remains green at 177/177 per ABI, CLI 66x2, corpus 105/105, and storage 18/3. Book 79/14,412 KiB, all eight doctrines, RAM 60%, and canonical Phase 0 1,031/1,031 in 740 seconds pass."
reverify: "LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE=authority bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua; LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE=integration bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua; LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE=authority bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua; LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE=integration bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua"
---

# Dormant shared Lua recognition-transaction boundary

The final-path source is `lua/test/recognition_transaction_contract_test.lua`.
It is one Lua consumer, not an ABI-specific pair. Explicit project-data-routed
runs execute the same bytes on PUC Lua and LuaJIT in `authority` and
`integration` modes. All four runs stop only because the private direct module
`linkedspec.recognition_transaction` does not yet exist.

Authority mode freezes invocation and mark generations, opaque linear tokens,
detached cursor/boundary/mark state, falsey staged payloads, lifecycle misuse,
and exact portable diagnostics. Integration mode additionally freezes four
non-eager ActionIR nodes, recursive effect closure, cursor-only progress, native
and reconstructed runtime, generated plans, ordinary compatibility cursor
controls, and an independently loaded in-memory emitted module.

Neither explicit mode is ordinary or canonical discovery. The neutral ledger
remains 132 ActionIR rows / 246 calls / 44 mutations at rollout 5/9; PUC Lua,
LuaJIT, recurring composition, and public no-drift stay RED. Private authority
`.14.3.6.1` is the next owner.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Lua runtime seams: [[lua-runtime-rule-interpreter]], [[lua-runtime-matching-state]],
  and [[lua-typed-source-location-dormant-red]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.6.0`.

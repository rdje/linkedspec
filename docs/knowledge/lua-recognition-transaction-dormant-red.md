---
id: lua-recognition-transaction-dormant-red
title: Shared Lua recognition transactions are privately integrated but remain dormant on both ABIs
answers:
  - "where is the dormant Lua recognition transaction RED consumer"
  - "how do I run the Lua recognition transaction RED"
  - "does the Lua recognition transaction RED run on PUC Lua and LuaJIT"
  - "what is the first Lua recognition transaction failure"
  - "what is the current Lua transaction integration status"
  - "does ordinary Lua discovery run recognition transaction tests"
  - "does canonical CI run Lua recognition transaction tests"
  - "does the Lua transaction RED cover emitted source"
  - "how many Lua dormant RED mutations are rejected"
date: 2026-08-11
status: private integration green on both ABIs; admission remains dormant
tags: [lua, PUC-Lua, LuaJIT, recognition, transaction, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.6.0 adds lua/test/recognition_transaction_contract_test.lua at its final shared path while leaving it absent from tools/run_lua_local.sh and tools/run_ci_local.sh. FUTURE-PARITY-BACKLOG.14.3.6.1 adds the private module: authority mode passes 187 assertions identically on PUC Lua and LuaJIT, while integration exits 1 only with 'Lua recognition transaction integration RED: missing dedicated ActionIR nodes'. The consumer freezes the current 132/246/44 and rollout 5/9 boundary plus private authority/token/mark/effect/progress semantics and native, reconstructed, generated-plan, and in-memory emitted-module carriers. Twelve dormant mutations reject selector/private lookup/integration/current status, premature discovery, facade export, and ABI collapse; 22 separate authority mutations lock the module and next RED. Complete ordinary Lua remains green at 177/177 per ABI, CLI 66x2, corpus 105/105, and storage 18/3."
evidence_update_2026_08_11_authority_signoff: "Private authority signoff builds the book at 79 files/14,412 KiB and Knowledge at 816/6,772, passes all eight doctrines, both CLI matrices 66/66, RAM 82%, and canonical Phase 0 1,031/1,031 in 753 seconds through exact success. Integration remains dormant and RED only at missing dedicated ActionIR nodes."
evidence_update_2026_08_11_integration: "FUTURE-PARITY-BACKLOG.14.3.6.2 makes integration mode GREEN at 243 assertions on PUC Lua and 243 on LuaJIT across dedicated nodes, effect/progress policy, native, reconstructed, generated-plan, and emitted execution. Authority remains 187/187, ordinary/canonical discovery and rollout 5/9 do not move, and the checker rejects 19 integration mutations beside 22 authority and 12 dormancy mutations."
reverify: "LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE=authority bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua; LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE=integration bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua; LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE=authority bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua; LINKEDSPEC_LUA_RECOGNITION_TRANSACTION_RED_MODE=integration bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua"
---

# Dormant shared Lua recognition-transaction boundary

The final-path source is `lua/test/recognition_transaction_contract_test.lua`.
It is one Lua consumer, not an ABI-specific pair. Explicit project-data-routed
runs execute the same bytes on PUC Lua and LuaJIT in `authority` and
`integration` modes. Authority mode now passes 187 assertions on each ABI
through private direct module `linkedspec.recognition_transaction`. Integration
mode now passes 243 assertions on each ABI through the private adapter and all
four runtime carriers.

Authority mode freezes invocation and mark generations, opaque linear tokens,
detached cursor/boundary/mark state, falsey staged payloads, lifecycle misuse,
and exact portable diagnostics. Integration mode additionally freezes four
non-eager ActionIR nodes, recursive effect closure, cursor-only progress, native
and reconstructed runtime, generated plans, ordinary compatibility cursor
controls, and an independently loaded in-memory emitted module.

Neither explicit mode is ordinary or canonical discovery. The neutral ledger
remains 132 ActionIR rows / 246 calls / 44 mutations at rollout 5/9; PUC Lua,
LuaJIT, recurring composition, and public no-drift stay RED because execution
remains selector-only. Admission `.14.3.6.3` is the next owner.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Lua runtime seams: [[lua-runtime-rule-interpreter]], [[lua-runtime-matching-state]],
  and [[lua-typed-source-location-dormant-red]].
- Private authority: [[lua-recognition-transaction-private-authority]].
- Private integration: [[lua-recognition-transaction-integration]].
- Owners: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.6.0-.14.3.6.2`.

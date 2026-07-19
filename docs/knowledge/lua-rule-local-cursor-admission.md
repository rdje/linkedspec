---
id: lua-rule-local-cursor-admission
title: Lua is composed-admitted against the rule-local cursor contract on both ABIs
answers:
  - "is Lua admitted for rule local cursor parity"
  - "is LuaJIT admitted for rule local cursor parity"
  - "where is the Lua rule local cursor admission consumer"
  - "how many Lua cursor admission roles exist"
  - "which roles does the Lua cursor admission consumer cover"
  - "how is Lua cursor admission registered in local CI"
  - "what is the rule local cursor rollout after Lua admission"
  - "how many cursor migration files exist after Lua admission"
  - "how many cursor checker mutations exist after Lua admission"
  - "what proves PUC Lua and LuaJIT cursor composition"
date: 2026-07-19
status: implemented, composed-admitted, and signoff complete
tags: [lua, luajit, cursor, contract, admission, topology, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.7.6 adds lua/test/rule_local_cursor_contract_test.lua as one contract-declared 15-role consumer. The exact same source runs on PUC Lua and LuaJIT and executes native default/AND, normalized AST, loaded spec, descriptor v1, emitted/generated v2 direct/trace, mixed parent-child, recursion, both structural replacements, static/dynamic option removal, primary retirement, and all eight portable diagnostics. The neutral checker requires one marker per role, both backend-driver invocations, canonical tracked input, optional backend registration, Lua rollout state, and five new omission mutations. Exact pre-contract RED is 3/3 per ABI and green is 119/119 per ABI. The complete dual-ABI driver passes package 177/177 per ABI; primary is 65/65 in all four ABI/default-POSIX legs and corpus is 105/105 per ABI. Governance reaches 69 migration files, 6 complete / 2 pending, and 49 rejected mutations; only lua_dual_abi advances. KM 632/4,642, mdBook/four doctrines, and canonical root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 647 seconds pass."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_rule_local_cursor_contract.py"
---

`lua/test/rule_local_cursor_contract_test.lua` is the single omission-sensitive
composed consumer. It adds no compiler or runtime path. Instead, it executes
each already-implemented Lua projection exactly once in the order declared by
`capability_conformance/rule_local_cursor_contract.json`.

The neutral checker locks the 15 `role_*` functions, the consumer path, both
PUC Lua and LuaJIT invocations in `tools/run_lua_local.sh`, the canonical
optional `LINKEDSPEC_RUN_LUA=1` registration, rollout state, and mutation
sensitivity. Missing, duplicated, renamed, asymmetric, or unregistered roles
therefore fail independently of the semantic unit suites.

Lua admission advances only `lua_dual_abi`. Recurring five-backend composition
and public no-drift remain under `.9.1.8-.9`; the separate root-selection
admission remains `.9.1.1.2.5.3`.

Related: [[rule-local-cursor-neutral-contract]],
[[rule-local-cursor-and-bare-edge-contract]],
[[lua-rule-local-cursor-normalization]],
[[lua-rule-local-cursor-execution]],
[[lua-rule-local-cursor-descriptor]],
[[lua-generated-source-v2-rule-local-cursor]], and
[[lua-global-cursor-option-removal]].

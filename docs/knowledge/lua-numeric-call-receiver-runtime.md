---
id: lua-numeric-call-receiver-runtime
title: Lua numeric calls and number receivers share one strict evaluator
answers:
  - "does Lua support numeric word aliases and symbol callees"
  - "does Lua support integer and float number receiver chains"
  - "are Lua numeric comparison receiver methods terminal"
  - "how does Lua distinguish division symbol calls from regex literals"
date: 2026-10-26
status: comparison results targeted-checked on available hosts; full admission open
tags: [lua, luajit, numeric, aliases, symbols, receivers, LUA-BACKEND-PARITY]
evidence: "TYPE23.3.15.5 safe public producer/shared/selector/direct/named-calibration native/plan/fresh checks. Full July4.3.3.2 record/91-per-ABI historical proof at Git564157d106c526a7a3c6062744381ffc821cb2c5 for this path."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/numeric_comparison_results_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/numeric_comparison_results_test.lua"
---

Canonical numeric calls, word/symbol aliases and Number receivers share the
strict scalar_numeric evaluator; current value is operand one. Comparison
producers retain numeric1/0/invalid-null with strict decimal/domain rules.
TYPE23.3.15.5 replaces evaluate_fluent_calls' nonfinal-comparison stop with
scalar_result marking and includes is_comparison in common one-RHS preflight.
Public native/plan/fresh producer controls already work; shared null/SO/24-effect
RED now passes scalar/numeric/default/Array-bridge/selector/source snapshots on
PUC5.5.1/LuaJIT. Direct lexical/aggregate and exact numeric calibration pass;
six historical terminal_* expected fields now2. No free/adapter/domain change.

Slash after a Hash colon uses complete parenthesized symbol-call recognition;
valid grouped/class regex AST controls in the named numeric calibration remain
patterns. The historical July record includes deliberately invalid regex tests;
current reverify excludes known malformed native paths owned by
[[lua-native-readme-and-action-ast-reading]] / LUA-STARTUP-READING2.3.

Array reducers have separate dispatch/current result contracts:
[[terse-array-numeric-reducer-receiver-methods]]. Ordinary scalar arithmetic
inter-type breadth is next TYPE23.2.16; declared Lua5.4 and full domain/context/
portable admission remain separate from available-host focused checks.

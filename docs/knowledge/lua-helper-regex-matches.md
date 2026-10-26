---
id: lua-helper-regex-matches
title: Lua matches uses strict helper flags over the existing in-process PCRE2 owner
answers:
  - does Lua support matches helper
  - which flags does Lua matches accept
  - what does Lua matches return for invalid regex
  - does Lua receiver matches work
  - how are Lua helper regexes compiled
date: 2026-10-26
status: bounded flow checked; native malformed-pattern repair pending
tags: [lua, runtime, regex, matches, flags, PCRE2, LUA-BACKEND-PARITY]
evidence: "Regex4.3.2.2.1 history at Git4584d0b41e12581a7bc68e9ad80336abf968d72f for this path; ordinary flow23.3.10.5."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/string_predicate_result_receivers_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/string_predicate_result_receivers_test.lua"
---

Private helper regexes reuse the in-process PCRE2 owner without rule-register state. Compilation retains imsx, ignores go, rejects unknown flags and caches outcomes. Null/non-text subjects and non-regex operands are false. Pure split remains4.3.2.2.2; no public regex type.

23.3.10.5 removes starts_with/ends_with/contains_substr/matches terminal fences, adds scalar/one-operand guards and rejects null text operands. Shared native/plan/fresh/direct emptiness and direct String cases pass on PUC5.5.1/JIT after null/SO/S/12-effect and null-operand RED. Kinds/flags/SOC/SC stay correct; old matches/length terminal assertions now reflect continuations.

Malformed-pattern PUC5.5.1 crashes remain LUA-STARTUP-READING.2.3 (luaL_error %lu);23.3.10.5 re-entered its known excluded helper group. That whole group passes on JIT, is excluded from PUC passes, and needs re-admission after repair. Declared5.4/full admission open: [[lua-native-readme-and-action-ast-reading]].

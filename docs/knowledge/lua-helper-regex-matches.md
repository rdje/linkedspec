---
id: lua-helper-regex-matches
title: Lua matches uses strict helper flags over the existing in-process PCRE2 owner
answers:
  - does Lua support matches helper
  - which flags does Lua matches accept
  - what does Lua matches return for invalid regex
  - does Lua receiver matches work
  - how are Lua helper regexes compiled
date: 2026-07-12
status: current
tags: [lua, runtime, regex, matches, flags, PCRE2, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.2.2.1 adds an internal RuntimeHelperRegex value and compile_helper_regex seam in lua/src/linkedspec/interpreter.lua. It applies deterministic imsx inline flags through lua/src/linkedspec/matching.lua's disposable native PCRE2 owner, treats g/o as predicate no-ops, rejects unknown flags, caches successful/failed compilation, and executes matches in function/terminal receiver form. lua/test/run.lua covers valid flags, actual-newline m/s behavior, x, null, non-regex, unknown/invalid, receiver equivalence, and terminal continuation. PUC Lua and LuaJIT pass 73/73."
reverify: "bash tools/run_lua_local.sh"
---

## Fact

Lua helper regexes reuse the same in-process PCRE2 binding as rule matching without exposing rule-register state.
Regex ActionIR becomes an internal typed value; helper compilation prepends deterministic `i/m/s/x` inline flags,
ignores operation-only `g` and compile-once compatibility `o` for `matches`, and caches both success and failure.

`matches(value, /pattern/flags)` searches the whole scalar value. It returns false for null/non-text input,
non-regex patterns, unknown flags, and invalid patterns. Receiver form is equivalent, and because `matches` is a
terminal string-family helper, a later string receiver call returns null. The behavior is identical on PUC Lua and
LuaJIT. Pure regex/literal split is the next separate owner under `.4.3.2.2.2`.

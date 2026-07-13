---
id: lua-runtime-lazy-inline-controls
title: Lua executes inline if and switch as lazy selected-value controls
answers:
  - "does Lua execute inline if and switch values"
  - "are Lua inline control branch payloads lazy"
  - "does Lua switch evaluate its subject once"
  - "are bare Lua switch case labels literals"
  - "are i elif when otherwise inline value aliases"
  - "what does LUA-BACKEND-PARITY.4.3.6.2 implement"
date: 2026-07-13
status: current
tags: [lua, runtime, control-flow, lazy, actionir, aliases, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.6.2 adds evaluate_inline_if/evaluate_inline_switch in lua/src/linkedspec/interpreter.lua and one end-to-end lua/test/run.lua case. PUC Lua and LuaJIT pass 105/105."
reverify: "bash tools/run_lua_local.sh"
---

Lua evaluates inline `if(cond, then, ...)` and `switch(subject, ...)` before the ordinary eager helper dispatcher.
Only conditions and the selected payload execute. Selected false and null values remain distinct, expression-block
payloads keep block-local return, and an unmatched control without a fallback yields JSON null.

`switch` evaluates its subject exactly once. A bare variable in the subject position reads the working binding,
while a bare variable in `case(label, body)` is the literal label text; a compound expression such as
`case(cat(other, ""), body)` performs a dynamic read. Branch arity failures use the generic typed
`helper_arity_mismatch` diagnostic.

The similarly named structural aliases do not expand the inline value surface: `i`/`elif` remain marker-statement
aliases, and `when`/`otherwise` remain attached-block aliases. This distinction was confirmed after a Perl toolbox
probe showed that treating them as ordinary value aliases shifts their arguments through structural parsing.

Related facts: [[lua-runtime-eager-block-values]], [[lua-runtime-block-control-callback-split]],
[[cross-backend-condition-truthiness-drift]], [[rust-marker-short-alias-control]],
[[terse-when-otherwise-alias-seams]].

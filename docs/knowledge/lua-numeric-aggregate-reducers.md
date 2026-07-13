---
id: lua-numeric-aggregate-reducers
title: Lua numeric aggregate reducers are strict copied-array terminals
answers:
  - "does Lua support sum avg median range min max on arrays"
  - "what do Lua numeric reducers return for empty arrays"
  - "are Lua array numeric reducer receivers terminal"
date: 2026-07-12
status: current
tags: [lua, luajit, numeric, arrays, reducers, receivers, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.3.3 adds strict copied-array sum/avg/median/range/min/max in scalar_numeric.lua and function/receiver dispatch in interpreter.lua. Closeout .4 directly covers all six canonical calls, all six aliases, all six terminal receivers, invalid/empty/wrong-arity boundaries, and source preservation at 91/91 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh"
---

Reducers accept exactly one typed array and reuse the strict scalar numeric grammar for every element. Sum of an
empty array is zero; average, median, range, minimum, and maximum of empty arrays are null. Invalid elements or
non-array inputs are null. Median sorts a copied numeric projection and averages the middle pair for even lengths,
so source arrays never change. Array receiver forms `sum`, `avg`, `median`, `range`, `min`, and `max` are terminal.

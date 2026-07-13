---
id: lua-runtime-array-selection
title: Lua copied array selection ordering membership and uniqueness
answers:
  - "does Lua support take take_last drop_front drop_back and slice"
  - "are Lua array indexes zero based"
  - "does Lua support reversed contains index_of and uniq"
  - "what do Lua array selection helpers return for missing inputs"
  - "do Lua pure array helpers mutate their source"
date: 2026-07-12
status: current
tags: [lua, runtime, arrays, selection, ordering, membership, uniqueness, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.4.2 extends PURE_ARRAY_HELPERS and evaluate_array_helper in lua/src/linkedspec/interpreter.lua. The focused runtime copied array selection fixture in lua/test/run.lua covers all 13 governed helpers through bare, literal, function, and receiver/chained forms. PUC Lua 5.4 and LuaJIT both pass 93/93 through tools/run_lua_local.sh."
reverify: "bash tools/run_lua_local.sh && rg -n 'nonnegative_array_count|runtime copied array selection' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua returns fresh arrays from `take`, `take_last`, `drop_front`, `drop_back`, `slice`, `sorted`, `reversed`, and
`uniq`. Omitted take/drop counts default to one; `slice` uses a zero-based start and optional width, and a start
beyond the source returns an empty array. Non-array selection/order inputs return empty arrays. `first`, `last`,
and a missing `index_of` result return null; `count` returns zero for a non-array value.

`contains` returns numeric `1` or `0`, while `index_of` returns the first zero-based index. Both compare through the
portable scalar-to-text boundary. `uniq` uses that same key and preserves the first occurrence's source order.
Function and receiver forms share the dispatcher, so `items.sorted().drop_front(2).first()` composes without
mutating `items`.

Lua clamps a valid negative count to zero for safety. Dart does the same, Julia treats a negative as invalid and
falls back to the helper default, and Rust's current signed-to-unsigned path can yield an oversized count.
`FUTURE-PARITY-BACKLOG.5` owns normalization of that pre-existing cross-backend caveat.

Related facts: [[lua-runtime-array-construction]], [[lua-numeric-aggregate-reducers]],
[[dart-runtime-array-helpers]], [[julia-runtime-array-helpers]].

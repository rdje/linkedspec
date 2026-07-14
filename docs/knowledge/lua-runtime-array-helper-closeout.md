---
id: lua-runtime-array-helper-closeout
title: Lua non-callback array helper family is closed at 99/99
answers:
  - "is the Lua array helper family complete"
  - "how many Lua array helper names are closed before tree callbacks"
  - "which Lua array helpers remain after array closeout"
  - "are Lua array public docs aligned with runtime results"
  - "what is the next Lua runtime helper family"
date: 2026-07-12
status: current
tags: [lua, runtime, arrays, helpers, receivers, public-surface, closeout, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.4.6 audits all 37 names in action_contracts.lua ARRAY_HELPERS. The 34 non-callback names route through 22 PURE_ARRAY_HELPERS plus array/copy, shared is_empty/is_nonempty, shared lowercase_each/uppercase_each, pure/mutable split, push, and four end mutations; six array numeric terminals route through scalar_numeric. Existing focused tests cover construction, selection, transforms, mutation/child flow, tagged records, receivers, invalid boundaries, and exact selector rejection. PUC Lua 5.4 and LuaJIT pass 99/99. The remaining three ARRAY_HELPERS names are walk_leaves/map_leaves/reduce_leaves, explicitly owned by LUA-BACKEND-PARITY.4.3.6. Public catalog drift for mutation, count, and take was corrected and the recurring mutation-result checker expanded. A Perl toolbox probe found direct implicit push(Child) returns host count 1 while Lua returns the updated implicit array; FUTURE-PARITY-BACKLOG.5 owns normalization and current value use is documented non-portable."
evidence_update_2026_07_13_callbacks: "LUA-BACKEND-PARITY.4.3.6.5.1.2 closes hash-root callback execution and leaves the three ARRAY_HELPERS callback methods active under array-root/mixed-tree owner .4.3.6.5.2."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_uniform_binding_mutation_result_surface.py && python3 tools/check_public_aggregate_selector_surface.py && rg -n 'local ARRAY_HELPERS|local PURE_ARRAY_HELPERS|ARRAY_END_MUTATIONS|split_tagged_records' lua/src/linkedspec/action_contracts.lua lua/src/linkedspec/interpreter.lua"
---

Lua's ordinary array family is complete before tree callbacks. `ARRAY_HELPERS` admits 37 names; three are the
separately owned callback methods `walk_leaves`, `map_leaves`, and `reduce_leaves`. The remaining 34 names all
have runtime routes and focused proof:

- 22 copied construction/selection/transform/tagged helpers use `PURE_ARRAY_HELPERS`.
- `array` and `copy` use their typed constructor/copy paths.
- `is_empty` and `is_nonempty` use the shared typed value predicates.
- `lowercase_each` and `uppercase_each` use generated Unicode 17 casing.
- `split` has governed pure and mutable-target paths.
- ordinary and explicit-target `push` plus the four named end mutations share uniform-binding updated results;
  implicit child push has portable side effects but a separately routed expression-result caveat.

The six numeric array terminals—sum, average, median, range, minimum, and maximum—remain exact through the strict
numeric reducer evaluator and terminate receiver chains. The focused dual-ABI gate is 99/99.

Closeout reconciled the public helper catalog with proved behavior: non-array `count` returns `0`; non-array
`take` returns `[]`; ordinary/explicit-target push and array end mutations return independent updated snapshots.
Implicit `push(Child)` expression results remain non-portable—Perl returns its host push count and Lua returns the
updated implicit accumulator—under `FUTURE-PARITY-BACKLOG.5`. A recurring check now rejects the residual
statement-only end-mutation wording found during this audit. Rewording four formal-
grammar comments also removed false selector matches shaped as `array (statement)`, correcting that public
inventory from 31 to 27 genuine removed/history references without changing its zero-current-example result. Hash helpers
`LUA-BACKEND-PARITY.4.3.5` are next; tree callbacks remain `LUA-BACKEND-PARITY.4.3.6`.

Related facts: [[lua-runtime-array-construction]], [[lua-runtime-array-selection]],
[[lua-runtime-array-transform-pipelines]], [[lua-runtime-array-mutation-child-flow]],
[[lua-runtime-tagged-record-construction]], [[lua-numeric-aggregate-reducers]],
[[uniform-binding-array-end-result-supersession]].

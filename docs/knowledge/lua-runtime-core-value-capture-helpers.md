---
id: lua-runtime-core-value-capture-helpers
title: Lua runtime preserves four value kinds, checked local stores, and complete entry-match reads
answers:
  - what are the four Lua LinkedSpec runtime value kinds
  - how does Lua distinguish arrays harrays and codeblocks
  - does Lua copy runtime aggregates and codeblocks
  - how do Lua scalar array and harray stores work
  - does Lua nested assignment autovivify missing paths
  - are Lua DSL array indexes zero based
  - does Lua current-edge retv dispatch the child
  - which entry and match helpers execute in Lua
  - what do Lua match helpers return when no match exists
date: 2026-07-13
status: current
tags: [lua, runtime, values, stores, access, captures, positions, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.1 extends lua/src/linkedspec/interpreter.lua with runtime_value_kind, defensive four-kind copies, scalar/array/harray binding, checked direct/nested access and assignment, current-edge retv dispatch, and all entry_*/match_* reads. FUTURE-PARITY-BACKLOG.12.1.6 later routes every public bare mutation/read through one observable typed binding, and .12.1.8.5 hard-rejects exact aggregate selectors."
evidence_update_2026_07_13_eager_blocks: "LUA-BACKEND-PARITY.4.3.6.1 corrects the earlier Lua-only callback = { return(...) } storage fixture: ordinary no-pair braces are eager values. Structural codeblock identity remains for contextual final arguments, registry frames, and future explicit callable values."
reverify: "bash tools/run_lua_local.sh"
---

## Fact

Lua exposes exactly four runtime value kinds through `runtime_value_kind(...)`:
`scalar`, `array`, `harray`, and `codeblock`. Null, boolean, number, and string
are scalar values. Arrays/harrays use the typed JSON metatables; contextual and
explicit codeblocks use typed ActionIR records. Structural reads defensively copy
mutable aggregates and reparse block source into independent typed nodes.

An ordinary authored no-pair `{ statements }` expression is not an inert stored
codeblock: it executes eagerly and yields its final/local-return value. Typed
block records remain observable at contextual final-argument and registry-frame
boundaries; future explicit callable values use `{|params| ...}`.

Runtime context may keep scalar, array, and harray stores separately, but a
`.spec` name exposes one current typed value. Bare assignment and `set(name,
value)` can hold any kind; a write replaces competing slots. Exact
`array(name)` and `hash(name)` selectors reject before execution. Rules receive
copied local stores and restore their caller's stores on exit. `retv` inside an
action edge dispatches that edge child before reading.

DSL array indexes are zero-based; harray keys are strings. Direct and mixed
nested reads return null for missing/wrong-kind paths. Nested writes are
copy-on-write, permit an array write only within `[0, length]`, and never create
missing intermediate containers.

The complete `entry_*` and `match_*` family exposes text, zero-based compact
groups, named values/presence/maps, Unicode character lengths/start/end, and
1-based start/end line/column. With no match, scalar reads are null, groups/maps
are typed empty containers, named presence is `0`, and line/column is `(1, 1)`.

Related facts: [[lua-runtime-rule-interpreter]], [[lua-runtime-matching-state]],
[[lua-runtime-helper-family-split]], [[spec-lifecycle-retv-order]],
[[lua-actionir-ast-parser]], [[lua-runtime-eager-block-values]].

---
id: lua-runtime-array-construction
title: Lua copied array construction and explicit splicing
answers:
  - "does Lua support array flat flat_array and concat_arrays"
  - "how does Lua distinguish flat splicing from nested arrays"
  - "does Lua array construction preserve evaluation order"
  - "do Lua array copy and concat results alias their sources"
  - "what does flat with no arguments return in Lua"
date: 2026-07-12
status: current
tags: [lua, runtime, arrays, construction, splicing, flat, copy, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.4.1 adds flat/flat_array/concat_arrays dispatch and constructor-context splice classification to lua/src/linkedspec/interpreter.lua. lua/test/run.lua executes direct-call, array-literal, terminal receiver, nested copy, variadic scalar/array, zero-argument, ordered set side-effect, and later-source-update isolation cases. PUC Lua 5.4 and LuaJIT both pass 92/92 through tools/run_lua_local.sh."
reverify: "bash tools/run_lua_local.sh && rg -n 'ARRAY_SPLICE_HELPERS|append_array_value|runtime copied array construction' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua evaluates `array(...)` and array literal elements once from left to right. An ordinary array value—including a
`copy(...)` result—occupies one nested element. Only a direct `flat(...)` / `flat_array(...)` call or a fluent
chain whose terminal method is `flat` / `flat_array` marks its returned array for one-level insertion into the
surrounding constructor or literal.

`flat_array(...)` and `concat_arrays(...)` return fresh arrays by appending array arguments one level and retaining
non-array arguments as individual copied values. `flat(array_value)` returns a fresh copy; `flat(non_array)` wraps
the copied value; `flat()` yields `[null]`. Empty `array()`, `flat_array()`, and `concat_arrays()` return fresh empty
arrays, while `copy()` returns null. Saved copies, flat results, and concatenations do not change when a source
binding is later updated.

The zero/variadic list behavior matches the current Rust, Dart, and Julia runtimes. A 2026-07-12 Perl toolbox
probe found that the reference lowerer accepts the catalog-sized `flat(array)` / `flat_array(array)` and
`concat_arrays(array, array)` forms but emits unsupported-helper sentinels for direct zero/variadic forms.
`FUTURE-PARITY-BACKLOG.5` owns the keep-or-normalize decision; Lua parity does not erase that measured caveat.

Related facts: [[lua-runtime-core-value-capture-helpers]], [[lua-numeric-aggregate-reducers]],
[[uniform-binding-array-end-result-supersession]].

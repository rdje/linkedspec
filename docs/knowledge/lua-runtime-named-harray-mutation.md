---
id: lua-runtime-named-harray-mutation
title: Lua separates named harray mutation from pure set-key values
answers:
  - does standalone set_key mutate a Lua harray binding
  - does Lua direct hash index assignment mutate and return a value
  - does Lua set_key create an absent harray target
  - how does Lua report wrong kind harray mutation
  - are Lua harray mutation snapshots independent
  - is Lua receiver set_key pure
  - does Lua preserve numeric array index assignment
date: 2026-07-13
status: current
tags: [lua, runtime, harray, mutation, bindings, set-key, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.5.4 adds shared kind-checked harray lookup/store functions and a dropped-statement set_key handler in lua/src/linkedspec/interpreter.lua. The direct harray assignment branch uses the same seam while preserving numeric array-index assignment. lua/test/run.lua proves existing and absent targets, statement/direct updates, copied snapshots, nested isolation, pure assigned/function/receiver set_key, array-index preservation, and scalar wrong-kind fields. tools/run_lua_local.sh passes 103/103 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh"
---

Lua treats a dropped top-level `set_key(target, key, value)` call as named
harray mutation. The first argument must be a bare target. An absent target
starts as an empty harray; an existing harray is copied, updated, and stored
through the same private storage class. An incompatible current value raises
`binding_kind_mismatch` with stable `identifier`, `expected_kind`, and
`actual_kind` fields.

Direct `target[key] = value` harray assignment uses that same binding seam and
yields an independent post-operation snapshot in value positions. Later direct
or nested mutations do not change saved results. Existing numeric array-index
assignment remains supported through its array path.

Statement context is the semantic boundary. Assigned or nested
`set_key(source, key, value)` and receiver `source.set_key(key, value)` remain
pure copied transforms and do not mutate `source`.

Related facts: [[lua-uniform-binding-runtime]],
[[lua-runtime-harray-transforms]], [[terse-hash-receiver-value-chains]],
[[uniform-binding-neutral-contract]].

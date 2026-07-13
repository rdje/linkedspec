---
id: lua-runtime-harray-construction
title: Lua copied harray construction uses explicit syntax-directed splicing
answers:
  - "does Lua flat preserve harray identity"
  - "does Lua support direct and receiver flat_hash"
  - "when does Lua hash constructor splice harray entries"
  - "does Lua preserve ordinary nested harrays in hash constructors"
  - "how does Lua flatten a harray into array list context"
  - "does Lua harray construction evaluate arguments once"
  - "do Lua flat hash results alias their sources"
date: 2026-07-13
status: current
tags: [lua, luajit, runtime, harray, hash, construction, splicing, flat, copy, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.5.1 adds runtime-kind flat evaluation, copied flat_hash function/receiver dispatch, explicit hash-context splice classification, and deterministic harray-to-array list splicing in lua/src/linkedspec/interpreter.lua. The focused runtime copied harray construction case proves one-time ordered evaluation, direct/receiver forms, ordinary nested preservation, generic/hash splicing, sorted list context, deep isolation, and unchanged odd-arity behavior. tools/run_lua_local.sh passes 100/100 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh && rg -n 'HASH_SPLICE_HELPERS|sorted_harray_keys|evaluate_hash_helper|runtime copied harray construction' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua separates the evaluated container kind from the authored parent-context intent. Generic `flat(value)` returns
a fresh array when `value` is an array and a fresh harray when it is an harray. `flat_hash(value)` and
`value.flat_hash()` return copied harray values. These results do not alias their source or its nested containers.

An ordinary harray argument remains one nested value in `hash(key, value, ...)`. A harray is spliced into the
surrounding hash only when the authored argument is a direct `flat(...)` / `flat_hash(...)` call or a fluent chain
whose terminal method is `flat` / `flat_hash`. Arguments evaluate exactly once from left to right before pairing
and explicit splice application.

Explicit `flat` / `flat_hash` in `array(...)` or `[...]` list context emits alternating key/value entries. Lua
sorts harray keys first because host tables do not provide a portable insertion-order contract. The slice preserves
Lua's pre-existing trailing-null result for a direct odd-arity `hash(...)`. Sorted harray-to-array order is a Lua
determinism rule, not yet a portable sequence guarantee; `FUTURE-PARITY-BACKLOG.5` owns both cross-backend
normalization decisions.

Related facts: [[lua-runtime-harray-helper-split]], [[lua-runtime-array-construction]],
[[hash-helper-odd-arity-current-behavior]], [[uniform-binding-neutral-contract]].

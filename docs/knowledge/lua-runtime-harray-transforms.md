---
id: lua-runtime-harray-transforms
title: Lua executes copied harray transforms and receiver chains
answers:
  - which Lua harray transform helpers execute
  - does Lua merge_hash accept bare base and overlay values
  - does Lua merge_hash let later arguments override
  - is Lua value form set_key pure
  - do Lua rename drop and pick copy nested values
  - how does Lua rename_key handle an existing destination
  - do Lua harray transforms continue through receiver chains
  - what do invalid Lua harray transforms return
date: 2026-07-13
status: current
tags: [lua, runtime, harray, transforms, receiver-chains, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.5.3.1 extends lua/src/linkedspec/interpreter.lua and lua/test/run.lua with copied merge_hash, value-form set_key, rename_key, drop_keys, pick_keys, and compatible harray/array receiver continuation. One end-to-end case proves bare operands, later override, null/nested preservation, pure source behavior, saved deep isolation, invalid/missing boundaries, and deterministic rename collision behavior. tools/run_lua_local.sh passes 102/102 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh"
---

Lua's pure harray dispatcher evaluates operands once and deep-copies transform
results. `merge_hash(base, overlay)` accepts bare typed harray values, visits
arguments in source order, and lets later values replace earlier keys.
Value-form/receiver `set_key`, `rename_key`, `drop_keys`, and `pick_keys` never
mutate their input. Saved nested fields remain unchanged after later source
mutation.

Hash-returning results continue through other harray helpers; `sorted_keys` and
`sorted_values` bridge onward into array receiver chains. Missing-arity set and
rename return null. Wrong-kind set/rename/drop return the copied source, while
wrong-kind/missing pick returns null; a valid pick with no keys returns `{}`.

Lua deterministically lets the renamed old value replace an existing
destination, matching Perl and Julia. Dart and Rust currently retain the
pre-existing destination instead. Portable `.spec` files should rename only to
an absent key until `FUTURE-PARITY-BACKLOG.5` normalizes this caveat.

Standalone named `set_key(target, key, value)` mutation is now implemented by
`LUA-BACKEND-PARITY.4.3.5.4`; receiver/value forms in this fact remain pure.

Related facts: [[lua-runtime-harray-views]],
[[lua-runtime-harray-construction]], [[lua-runtime-harray-helper-split]],
[[lua-runtime-named-harray-mutation]], [[terse-hash-receiver-value-chains]],
[[terse-merge-hash-bare-overlay-boundary]].

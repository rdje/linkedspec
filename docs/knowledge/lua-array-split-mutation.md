---
id: lua-array-split-mutation
title: Lua explicit array wrappers authorize statement split replacement
answers:
  - does Lua split array target mutate arrays
  - does Lua support split array target source delimiter
  - how does Lua distinguish pure split from array split mutation
  - does Lua statement split mutate its source
  - does Lua array split preserve empty fields
date: 2026-07-12
status: current
tags: [lua, runtime, split, mutation, array, wrapper, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.2.2.4 adds dropped-statement dispatch for split(array(target), source, delimiter) in lua/src/linkedspec/interpreter.lua. It identifies the explicit array target through target_descriptor, evaluates source/delimiter once, reuses evaluate_pure_string_helper split semantics, and stores a copied typed result through bind_array. lua/test/run.lua locks regex/literal delimiters, empty fields, stale-target replacement, source preservation, scalar-held non-wrapper isolation, and pure split. PUC Lua and LuaJIT pass 76/76."
reverify: "bash tools/run_lua_local.sh"
---

## Fact

Lua requires both dropped-statement context and an explicit `array(target)` first argument to authorize split
mutation. `split(array(target), source, delimiter)` evaluates source and delimiter once, applies the same pure
literal/regex/Unicode split policy, and binds a copied typed array to the named aggregate store. This typed binding
removes any scalar or harray previously stored at the same name.

An ordinary `split(value, delimiter)` always remains pure. If its value is discarded, nothing is mutated. The
explicit mutation form also leaves its source scalar unchanged, preserves leading/trailing empty fields, and uses
the existing rule invocation store copy/restore boundary. Regex/split corpus and public no-drift is active under
`.4.3.2.2.5`.

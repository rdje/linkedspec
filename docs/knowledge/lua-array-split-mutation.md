---
id: lua-array-split-mutation
title: Lua bare three-argument split replaces one typed array binding
answers:
  - does Lua split array target mutate arrays
  - does Lua support split array target source delimiter
  - how does Lua distinguish pure split from array split mutation
  - does Lua statement split mutate its source
  - does Lua array split preserve empty fields
  - does Lua bare three argument split mutate its target
date: 2026-07-12
status: current
tags: [lua, runtime, split, mutation, array, bindings, LUA-BACKEND-PARITY]
evidence: "FUTURE-PARITY-BACKLOG.12.1.6 extends the earlier wrapper-only statement split through binding_target_descriptor and evaluate_mutable_split. split(target, source, delimiter) now validates/replaces the bare typed array and returns a copied update; two-argument split stays pure. Temporary array(target) input delegates to the same seam. PUC Lua and LuaJIT pass 85/85."
reverify: "bash tools/run_lua_local.sh"
---

## Fact

Lua treats `split(target, source, delimiter)` as the mutable form. It evaluates source and delimiter once, applies
the same pure literal/regex/Unicode split policy, validates an existing target's array kind, and returns a copied
updated typed binding. An absent target starts as an empty array. Temporary `array(target)` migration input delegates
to the same mutation seam rather than authorizing a second namespace.

An ordinary two-argument `split(value, delimiter)` always remains pure. If its value is discarded, nothing is
mutated. The mutable form leaves its source scalar unchanged, preserves leading/trailing empty fields, and uses the
existing rule invocation store copy/restore boundary.

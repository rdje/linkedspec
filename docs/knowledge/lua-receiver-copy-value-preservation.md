---
id: lua-receiver-copy-value-preservation
title: Lua receiver copy deep-copies the already evaluated fluent value
answers:
  - why did Lua meta copy flat hash count return zero
  - does Lua receiver copy preserve its receiver
  - does Lua receiver copy evaluate its receiver once
  - does Lua missing copy stay undefined
  - does Lua copy support harray array string and scalar continuations
  - how many Lua advanced corpus fixtures pass after receiver copy repair
date: 2026-07-15
status: current
tags: [lua, runtime, receiver, copy, fluent-chain, harray, corpus, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.6.2.2 classifies zero-argument receiver .copy() in fluent evaluation and applies copy_value to the already evaluated current value. Focused proof covers one-time scalar receiver evaluation, nested harray/array isolation, harray, derived-harray, array, and string continuations, missing receiver null, and unchanged function copy(value)/copy(). PUC Lua and LuaJIT pass 164/164. The unchanged terse_2_3_5_2_hash_receiver_value_chains output is [[\"a,b,c\",9,2,0,2,2,0]] at endpoint 1; exact offsets 40-98 reach 57/59 on both ABIs."
reverify: "bash tools/run_lua_local.sh"
---

# Lua Receiver Copy Value Preservation

Lua fluent chains evaluate their receiver once before processing method links. Most links
have an explicit receiver evaluator, but `copy()` previously fell through to the ordinary
function-call path. That made `meta.copy()` behave like zero-argument `copy()`: it returned
null, then `flat_hash().count_keys()` reduced that lost receiver to zero.

Zero-argument receiver `.copy()` now deep-copies the current fluent value directly. This
keeps the two contracts separate:

- `copy(value)` evaluates and copies its explicit function argument;
- `value.copy()` copies the one already evaluated receiver;
- `copy()` and `missing.copy()` remain null;
- a copied value retains its runtime kind, so harray, array, string, and scalar-compatible
  continuation families still dispatch normally.

The copy is recursive for LinkedSpec arrays and harrays. Mutating nested fields of a stored
receiver-copy result does not alter the earlier source snapshot. The focused scalar receiver
also increments its evaluation counter once before `.copy().add(1)`, preventing a future
implementation from re-evaluating the receiver while fixing the value path.

The advanced window now passes 57/59 on both Lua ABIs. PPlugin flat-array hash splicing and
history leading-trivia initialization remain independent under `.6.2.3-.4`.

Related facts: [[terse-hash-receiver-value-chains]],
[[lua-advanced-corpus-residual-split]], [[lua-runtime-array-construction]].

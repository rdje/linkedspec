---
id: lua-flat-array-hash-splicing
title: Lua hash construction splices explicit flat-array results as copied key/value tokens
answers:
  - does Lua hash flat array splice key value pairs
  - why did Lua pplugin empty return a table address key
  - does Lua harray accept receiver flat array splicing
  - what does empty flat array do inside Lua hash construction
  - do ordinary Lua array arguments splice into hashes
  - are nested flat array hash values copied in Lua
  - how many Lua advanced corpus fixtures pass after flat array hash repair
date: 2026-07-15
status: current
tags: [lua, runtime, harray, hash, flat-array, splicing, corpus, pplugin, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.6.2.3 adds canonical flat_array to HASH_SPLICE_HELPERS. The existing expression-shape classifier covers direct calls and fluent chains whose terminal method is flat_array, and the existing append_array_value path copies each array member into alternating hash key/value tokens. Focused dual-ABI proof covers direct, receiver, empty, positioned, harray alias, nested isolation, and ordinary unwrapped-array boundaries. PUC Lua and LuaJIT pass 164/164; unchanged pplugin_empty returns [{}] at endpoint 0 and exact offsets 40-98 reach 58/59 on both ABIs."
reverify: "bash tools/run_lua_local.sh && rg -n 'HASH_SPLICE_HELPERS|append_array_value|runtime copied harray construction' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

# Lua Flat-Array Hash Splicing

Lua hash construction distinguishes explicit list-context syntax from ordinary aggregate
values by inspecting the authored argument expression. A direct `flat_array(...)` call or a
fluent chain whose terminal method is `.flat_array()` now marks its returned array for
ordered insertion into both `hash(...)` and `harray(...)`:

```text
hash(flat_array(["a", 1, "b", { "nested" : 2 }]))
```

The flattened members become alternating key/value tokens, producing fields `a` and `b`.
The insertion path recursively copies nested arrays and harrays, so later mutation of the
source token array does not mutate the constructed hash. Empty direct or receiver
`flat_array` results contribute no tokens and therefore produce an empty harray.

This remains an explicit syntax boundary. An unwrapped array such as
`hash("payload", pairs)` occupies one copied value position; its runtime table shape alone
does not trigger splicing. Positioned ordinary pairs before or after an explicit splice
retain their authored order, and duplicate keys still follow the existing last-value-wins
constructor rule.

The earlier `pplugin_empty` mismatch was this constructor boundary, not plugin execution:
`hash(flat_array(defs))` treated the empty Lua array as one table-address key plus an
implicit null. It now returns the unchanged checked output `[{}]`. The advanced window is
58/59 on both Lua ABIs; only public leading-trivia initialization remains under `.6.2.4`.

Related facts: [[lua-runtime-array-construction]], [[lua-runtime-harray-construction]],
[[lua-advanced-corpus-residual-split]], [[pplugin-pluginbridge-transition-machinery]].

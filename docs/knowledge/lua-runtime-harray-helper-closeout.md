---
id: lua-runtime-harray-helper-closeout
title: Lua non-callback harray helper family is closed at 103/103
answers:
  - is the Lua harray helper family complete
  - how many ordinary Lua harray helper names are closed
  - which Lua harray helpers remain after closeout
  - how are ordinary Lua harray helpers routed
  - are Lua harray public mutation results guarded
  - what is the next Lua runtime helper family
date: 2026-07-13
status: current
tags: [lua, runtime, harray, helpers, receivers, mutation, public-surface, closeout, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.5.5 audits all 16 names in action_contracts.lua HASH_HELPERS. The 13 ordinary names route through constructor/generic hash/copy/runtime-kind flat paths, ten PURE_HASH_HELPERS entries, and shared named/direct mutation. Existing focused tests cover construction/splicing, deterministic views, copied transforms, receiver bridges, invalid boundaries, nested isolation, and uniform mutation. PUC Lua and LuaJIT pass 103/103. The remaining three HASH_HELPERS names are walk_leaves/map_leaves/reduce_leaves, explicitly owned by LUA-BACKEND-PARITY.4.3.6. The recurring mutation-result checker now guards independent hash-index snapshots and pure receiver set-key; selector and capability gates remain green."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_uniform_binding_mutation_result_surface.py && python3 tools/check_public_aggregate_selector_surface.py && perl tools/check_capability_conformance.pl && rg -n 'local HASH_HELPERS|local PURE_HASH_HELPERS|evaluate_hash_helper|execute_hash_set_key_statement' lua/src/linkedspec/action_contracts.lua lua/src/linkedspec/interpreter.lua"
---

Lua's ordinary harray family is complete before tree callbacks. `HASH_HELPERS`
admits 16 names; three are the separately owned block-bearing methods
`walk_leaves`, `map_leaves`, and `reduce_leaves`. The remaining 13 names all
have runtime routes and focused proof:

- `hash` uses typed constructor/literal paths; `copy` uses generic defensive
  copying; `flat` dispatches from the evaluated array/harray kind.
- `flat_hash`, `count_keys`, `sorted_keys`, `sorted_values`, `has_key`,
  `merge_hash`, value `set_key`, `rename_key`, `drop_keys`, and `pick_keys` use
  the copied harray dispatcher and compatible receiver continuation.
- dropped statement `set_key` and direct harray assignment use the shared
  uniform-binding mutation seam; receiver and assigned value forms stay pure.

Focused proof covers explicit splicing versus nested preservation, lexical
views, null presence, later merge override, deep source isolation, invalid and
missing inputs, absent-target creation, stable wrong-kind fields, copied
mutation snapshots, and numeric array-index preservation. The dual-ABI gate is
103/103.

Closeout retains cross-backend helper caveats under
`FUTURE-PARITY-BACKLOG.5`: direct odd hash arity, flattened harray list order,
and rename-to-existing-destination policy are not silently normalized. The
next Lua runtime parent is `.4.3.6` for codeblock values, structured controls,
generic trailing blocks, and array/harray tree callbacks.

Related facts: [[lua-runtime-harray-helper-split]],
[[lua-runtime-harray-construction]], [[lua-runtime-harray-views]],
[[lua-runtime-harray-transforms]], [[lua-runtime-named-harray-mutation]],
[[lua-runtime-array-helper-closeout]].

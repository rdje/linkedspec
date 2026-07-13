---
id: lua-runtime-harray-helper-split
title: Lua harray parity is split across five mechanisms and closeout
answers:
  - "what Lua harray helper behavior already exists"
  - "how is Lua harray helper work split"
  - "which Lua task owns flat_hash and hash splicing"
  - "which Lua task owns sorted_keys and sorted_values"
  - "which Lua task owns merge_hash and set_key"
  - "which Lua task owns harray mutation"
  - "which Lua task owns hash tree callbacks"
date: 2026-07-13
status: current
tags: [lua, runtime, harray, hash, helpers, planning, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.5.0 audits and splits 16 hash-family names into 13 ordinary names plus walk_leaves/map_leaves/reduce_leaves. Leaves .1-.3 now implement copied construction/splicing, deterministic views, and copied transforms/receiver chains at 102/102 on both Lua ABIs. Named mutation remains .4, non-callback closeout .5, callbacks .4.3.6, and cross-backend arity/order/rename-collision caveats FUTURE-PARITY-BACKLOG.5."
reverify: "bash tools/run_lua_local.sh && rg -n 'local HASH_HELPERS|name == \"hash\"|name == \"harray\"|flat_hash|count_keys|merge_hash|set_key' lua/src/linkedspec/action_contracts.lua lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua already preserves harray identity, copies nested values, binds bare typed harrays, and supports checked direct
and nested assignment. Construction leaf `.4.3.5.1` now adds runtime-kind `flat`, copied direct/receiver
`flat_hash`, ordinary nested-map preservation, and explicit hash/list-context splicing. View leaf `.4.3.5.2` adds
lexical copied key/value views plus count/membership terminals. Transform leaf `.4.3.5.3` now adds copied
merge/set/rename/drop/pick values and receiver chains; named mutation remains in the later child below.

The 16 admitted hash-family names divide into 13 ordinary helpers plus the three block-bearing callbacks
`walk_leaves`, `map_leaves`, and `reduce_leaves`. The executable split is:

- `.4.3.5.1` (done): `hash`, literals, `copy`, `flat`, `flat_hash`, explicit constructor splicing, and isolation.
- `.4.3.5.2` (done): `count_keys`, `sorted_keys`, `sorted_values`, and `has_key`.
- `.4.3.5.3` (done): copied `merge_hash`, value `set_key`, `rename_key`, `drop_keys`, `pick_keys`, and receiver
  chains.
- `.4.3.5.4`: named statement `set_key` plus direct harray assignment through uniform binding.
- `.4.3.5.5`: complete non-callback public/runtime no-drift closeout.

Hash-tree callbacks remain `.4.3.6`. Direct odd-arity `hash(...)` differs from the Perl reference and is already
owned by `FUTURE-PARITY-BACKLOG.5`; no construction child may silently normalize it.

Related facts: [[lua-runtime-core-value-capture-helpers]], [[lua-uniform-binding-runtime]],
[[lua-runtime-harray-construction]], [[lua-runtime-harray-views]], [[lua-runtime-harray-transforms]],
[[dart-runtime-hash-helpers]], [[julia-runtime-hash-helpers]],
[[hash-helper-odd-arity-current-behavior]], [[lua-runtime-array-helper-closeout]].

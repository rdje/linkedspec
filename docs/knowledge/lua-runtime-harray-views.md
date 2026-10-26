---
id: lua-runtime-harray-views
title: Lua harray views share lexical key order and copied value identity
answers:
  - "does Lua support count_keys sorted_keys sorted_values and has_key"
  - "what does Lua count_keys return for missing or non harray input"
  - "what do Lua sorted hash views return for invalid input"
  - "are Lua sorted_values ordered by sorted keys"
  - "does Lua has_key recognize a null valued field"
  - "do Lua harray views compose through receiver chains"
  - "does Perl count_keys non hash return zero or undef"
date: 2026-10-26
status: bounded key-count/has_key flow repaired; full admission open
tags: [lua, luajit, perl, runtime, harray, views, ordering, membership, copy, LUA-BACKEND-PARITY]
evidence: "Hash4.3.5.2/count23.3.3.5; historical detail at Git07d65e85378ed248a0a324e307e0eee4eaafbb05 for this path. Has_key23.3.8.5 native/plan/fresh on installed hosts."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/has_key_result_receivers_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/has_key_result_receivers_test.lua"
---

Lua computes one lexical key list for every harray view. `sorted_keys(h)` returns that list, while
`sorted_values(h)` copies values in the identical key order. Nested returned values do not alias later source
mutations. Both helpers return an empty array for missing or non-harray sources.

`count_keys(h)` returns the number of fields or zero for a missing/non-harray source. `has_key(h, key)` returns
numeric `1`/`0` and tests entry presence, not value definedness, so a field whose value is null is present. Missing
keys and wrong-kind sources return zero; free-helper missing key arguments still return zero. Ordinary receiver has_key now requires exactly one key before source/operand effects.

Function and receiver forms are equivalent. Sorted arrays continue through array receivers such as
`.join_values(...)`, `.drop_front()`, and `.first()`. 23.3.3.5 lets key counts feed existing scalar/number methods; 23.3.8.5 replaces the has_key endpoint fence with scalar-result tracking and one-key preflight. Native/plan/fresh/direct index checks pass after null/SK/four-effect RED on available PUC5.5.1/LuaJIT, preserving false retention, explicit bridges/scalar nulls and K/SK/SKA snapshots. Declared5.4/full admission remain open. Historical July13 Perl invalid-result controls corrected the book’s non-harray count_keys-null drift.

Related facts: [[lua-runtime-harray-construction]], [[lua-runtime-harray-helper-split]],
[[dart-runtime-hash-helpers]], [[julia-runtime-hash-helpers]], [[terse-hash-receiver-value-chains]].

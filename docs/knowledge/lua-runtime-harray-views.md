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
date: 2026-07-13
status: current
tags: [lua, luajit, perl, runtime, harray, views, ordering, membership, copy, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.5.2 extends the copied hash dispatcher in lua/src/linkedspec/interpreter.lua with lexical sorted_keys, copied sorted_values using the same keys, count_keys, has_key, receiver bridges, and count/membership terminal fences. lua/test/run.lua proves function/receiver forms, array continuation, null-valued membership, invalid boundaries, and nested isolation at 101/101 on PUC Lua and LuaJIT. A direct LinkedSpec::Get toolbox matrix returns 0 for count_keys on text/undef, [] for invalid sorted views, 0 for invalid has_key, and 1 for a present undef field; the mdBook catalog's stale undef statement was corrected to 0."
reverify: "bash tools/run_lua_local.sh && rg -n 'count_keys|sorted_keys|sorted_values|has_key|runtime deterministic harray views' lua/src/linkedspec/interpreter.lua lua/test/run.lua docs/linkedspec-book/src/appendix/helper-contract-catalog.md"
---

Lua computes one lexical key list for every harray view. `sorted_keys(h)` returns that list, while
`sorted_values(h)` copies values in the identical key order. Nested returned values do not alias later source
mutations. Both helpers return an empty array for missing or non-harray sources.

`count_keys(h)` returns the number of fields or zero for a missing/non-harray source. `has_key(h, key)` returns
numeric `1`/`0` and tests entry presence, not value definedness, so a field whose value is null is present. Missing
keys, missing key arguments, and wrong-kind sources return zero.

Function and receiver forms are equivalent. Sorted arrays continue through array receivers such as
`.join_values(...)`, `.drop_front()`, and `.first()`. Count and membership results are terminal within the harray
receiver chain contract. A 2026-07-13 Perl reference probe confirmed the same invalid-result boundaries; the
helper catalog's older non-harray `count_keys -> undef` sentence was documentation drift.

Related facts: [[lua-runtime-harray-construction]], [[lua-runtime-harray-helper-split]],
[[dart-runtime-hash-helpers]], [[julia-runtime-hash-helpers]], [[terse-hash-receiver-value-chains]].

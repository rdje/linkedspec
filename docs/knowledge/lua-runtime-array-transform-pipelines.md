---
id: lua-runtime-array-transform-pipelines
title: Lua copied array transform and join pipelines
answers:
  - "does Lua support join_values delimiter first"
  - "does Lua support split_each and filter_match"
  - "do Lua dropped array transform calls rebind"
  - "do Lua array transform value forms mutate their source"
  - "what does Lua join_values return for a missing array"
  - "which backends rebind dropped split_each filter_match and uniq calls"
date: 2026-07-12
status: current
tags: [lua, runtime, arrays, transforms, regex, join, uniform-binding, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.4.3 extends Lua's copied array dispatcher and dropped-statement rebinding seam in lua/src/linkedspec/interpreter.lua. The focused transform fixture in lua/test/run.lua covers direct, literal, receiver, chained, PCRE2, Unicode, invalid, terminal, copy-isolation, seven standalone rebindings, and wrong-kind cases. PUC Lua 5.4 and LuaJIT both pass 95/95 through tools/run_lua_local.sh."
reverify: "bash tools/run_lua_local.sh && rg -n 'join_values|split_each|filter_match|runtime copied array transforms' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua implements delimiter-first `join_values(delimiter, array)` and receiver-equivalent
`array.join_values(delimiter)`. A missing or null array returns null, a non-array scalar source returns an empty
string, and a valid array joins portable scalar-text representations. A receiver join is terminal in an array
receiver chain.

`split_each` applies the governed literal/PCRE2 split policy to each source element and flattens the copied pieces.
`filter_match` accepts a governed PCRE2 regex value and copies matching source elements. `trim_each`,
`filter_nonempty`, `lowercase_each`, and `uppercase_each` reuse the established scalar and generated Unicode 17
paths. Pure function and receiver forms return fresh arrays without mutating their sources.

Dropped bare statement calls rebind named typed arrays for all seven Perl-reference transforms: `split_each`,
`trim_each`, `filter_nonempty`, `filter_match`, `lowercase_each`, `uppercase_each`, and `uniq`. Wrong-kind targets
raise the neutral `binding_kind_mismatch` fields. Rust, Dart, and Julia currently rebind only the middle four and
also disagree with Perl/Lua on invalid `join_values` sources; `FUTURE-PARITY-BACKLOG.5` owns that pre-existing
cross-backend repair.

Related facts: [[lua-runtime-array-selection]], [[lua-pure-split-bridge]],
[[six-variant-unicode-17-case-parity]], [[array-helper-return-shape-caveats]],
[[dart-runtime-array-helpers]], [[julia-runtime-array-helpers]].

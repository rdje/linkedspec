---
id: lua-runtime-array-transform-pipelines
title: Lua copied array transform and join pipelines
answers:
  - "can Lua definedness receivers retain Boolean false through continuations"
  - "can Lua emptiness results continue through scalar methods with source kinds preserved"
  - "why do Lua direct default scalars reject container consumers"
  - "why do Lua reducer scalar guards include uppercase_each from String dispatch"
  - "can Lua count length count_keys and join_values results continue into scalar methods"
  - "can Lua first and last continue through selected scalar and container methods"
  - "does Lua support join_values delimiter first"
  - "does Lua support split_each and filter_match"
  - "do Lua dropped array transform calls rebind"
  - "do Lua array transform value forms mutate their source"
  - "what does Lua join_values return for a missing array"
  - "which backends rebind dropped split_each filter_match and uniq calls"
date: 2026-10-26
status: bounded value/predicate guards; declared5.4/full admission open
tags: [lua, runtime, arrays, transforms, regex, join, uniform-binding, LUA-BACKEND-PARITY]
evidence: "Transform4.3.4.3/results23.3; focused PUC5.5.1/LuaJIT; declared5.4 remains LUA-STARTUP-READING.2.2."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/definedness_result_receivers_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/definedness_result_receivers_test.lua"
---

Lua implements delimiter-first `join_values(delimiter, array)` and receiver-equivalent
`array.join_values(delimiter)`. A missing or null array returns null, a non-array scalar source returns an empty
string, and a valid array joins portable scalar-text representations. The common array-chain profile uses join as its final link.

`split_each` applies the governed literal/PCRE2 split policy to each source element and flattens the copied pieces.
`filter_match` accepts a governed PCRE2 regex value and copies matching source elements. `trim_each`,
`filter_nonempty`, `lowercase_each`, and `uppercase_each` reuse the established scalar and generated Unicode 17
paths. Pure function and receiver forms return fresh arrays without mutating their sources.

Dropped bare statement calls rebind named typed arrays for all seven Perl-reference transforms: `split_each`,
`trim_each`, `filter_nonempty`, `filter_match`, `lowercase_each`, `uppercase_each`, and `uniq`. Wrong-kind targets
raise the neutral `binding_kind_mismatch` fields. Rust/Dart/Julia now also implement all seven under5.3.1-.3. Invalid join_values source differences remain owned by FUTURE-PARITY-BACKLOG.5; transform repair does not close them.

Related facts: [[lua-runtime-array-selection]], [[lua-pure-split-bridge]],
[[six-variant-unicode-17-case-parity]], [[array-helper-return-shape-caveats]],
[[dart-runtime-array-helpers]], [[julia-runtime-array-helpers]].

evaluate_fluent_calls guards defaults/index/has_key and all four generic predicate results until actual array/harray output; generic consumers remain allowed. Join/index/has_key take one operand, generic predicates zero. Emptiness23.3.9.5 and definedness23.3.11.5 remove their terminal fences, preserving Bool/domain/source/copy. The last two entries disappear, so the empty String terminal map is removed; comparison policy stays separate. Native/plan/fresh shared/free producer/direct String checks pass on5.5.1/JIT after null/S/four-effect RED, retaining false0!/default/generic/bridges/scalar guards and1!/SC/one-call/final-null snapshots. Join false: [[lua-interpreter-helper-reading-and-false-delimiter-gap]]; malformed native regex repair2.3 and declared5.4/full admission remain open. Prior emptiness proof/details at Git77dad432e0851e4071f09ad47bc36294526dbd39 for this path.

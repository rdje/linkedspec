---
id: lua-runtime-array-transform-pipelines
title: Lua copied array transform and join pipelines
answers:
  - "can Lua count length and count_keys results continue into scalar methods"
  - "can Lua first and last continue through selected scalar and container methods"
  - "does Lua support join_values delimiter first"
  - "does Lua support split_each and filter_match"
  - "do Lua dropped array transform calls rebind"
  - "do Lua array transform value forms mutate their source"
  - "what does Lua join_values return for a missing array"
  - "which backends rebind dropped split_each filter_match and uniq calls"
date: 2026-10-26
status: selected/count values confirmed; zero-extra arity guarded; declared5.4 proof open
tags: [lua, runtime, arrays, transforms, regex, join, uniform-binding, LUA-BACKEND-PARITY]
evidence: "Historical transform slice4.3.4.3; current selected-value23.3.1.5 on measured PUC5.5.1/LuaJIT. Declared5.4 proof remains LUA-STARTUP-READING.2.2."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/count_length_receivers_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/count_length_receivers_test.lua"
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

23.3.1.5 confirms selected-value dispatch/extraction arity.23.3.3.5 preserves Count flow, removes Length/key-count endpoint stops and guards producer extras before effects. Small native/generated-plan/fresh-emitted and direct selected-value fixtures pass after RED on available PUC5.5.1/LuaJIT with matching native products, retaining kinds, Unicode, SALHK order and snapshots. Runner/interpreter compile; declared5.4/full admission stay open.

---
id: lua-full-corpus-gate
title: Lua executes the complete validated corpus at 105 of 105
answers:
  - does Lua pass the full LinkedSpec corpus
  - is Lua corpus parity 105 of 105
  - what is the permanent Lua full corpus gate
  - what does runtime corpus full mean for Lua
  - can the Lua corpus runner execute the complete manifest
  - what are the Lua corpus runner exit codes
  - is the Lua primary parser CLI implemented after corpus parity
  - what is LUA BACKEND PARITY 6.3
date: 2026-07-15
status: current
tags: [lua, corpus, parity, runner, manifest, regression, PUC-Lua, LuaJIT, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.6.3 adds one no-selector production-library regression and bare developer-runner --execute. Both paths validate and execute all 105 fixtures in manifest order with exact wrapped output, 105 passes, and zero failures; missing-directory drift returns 2 and a controlled mismatch returns 1. PUC Lua and LuaJIT pass 167/167 with status runtime-corpus-full."
evidence_update_2026_07_15_primary_cli: "LUA-BACKEND-PARITY.7.1 subsequently implements the separate primary parser adapter at 169/169 per ABI plus diagnostic shared CLI 61x2; this does not change the corpus command or runtime-corpus-full status."
reverify: "bash tools/run_lua_local.sh"
---

`LUA-BACKEND-PARITY.6.3` is Lua's complete interpreter-corpus gate. The
permanent test calls `execute_corpus_fixtures(...)` without selection options,
so strict validation precedes one ordered run of all 105 fixtures. It locks
manifest format and count, result order and count, first and last names, match
state, absent failure fields, 105 passes, zero failures, and exactly one
wrapping of every unchanged checked-in expected JSON value.

The separate developer `lua/bin/corpus_runner.lua` validates only when
`--execute` is absent. Bare `--execute` calls that same native in-memory API,
prints each ordered `PASS` or `FAIL` plus an exact summary, and runs the full
manifest. Exit `0` means all fixtures passed, exit `1` means one or more
fixture results recorded a failure, and exit `2` means arguments or strict
manifest validation failed. A selected subset is still available through the
library API; `.6.3` intentionally adds only the atomic full-manifest runner
projection.

Public Lua status is `runtime-corpus-full`, and both PUC Lua and LuaJIT pass
167/167 at this corpus boundary. `.6.3` did not implement the primary parser
command; `.7.1` has since replaced that scaffold with the exact thin adapter,
while `.7.2` owns recurring process/matrix admission. Generated
Lua and capability-census admission remain `.8.1-.8.4`; the census stays
64/0/0.

Related facts: [[lua-controlled-corpus-execution]], [[lua-corpus-manifest-io]],
[[lua-advanced-corpus-residual-split]], [[julia-full-corpus-gate]],
[[language-agnostic-backend-vision]], [[lua-primary-cli-adapter]].

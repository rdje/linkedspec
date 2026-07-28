---
id: lua-toolchain-package-policy
title: Lua uses PUC 5.4 primary, LuaJIT secondary, repo paths, and disposable dual-ABI PCRE2 builds
answers:
  - which Lua version does LinkedSpec target
  - how does LinkedSpec run Lua tests
  - what is the Lua module layout
  - where is the linkedspec Lua command
  - does the Lua backend require LuaRocks
  - which Lua JSON library is used
  - where may Lua caches be written
  - does the Lua scaffold depend on LPeg
  - how does Lua build its PCRE2 matching adapter
  - where are Lua native artifacts written
date: 2026-07-15
status: current
tags: [lua, toolchain, package, tests, json, pcre2, lpeg, cache, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.1.1 locks PUC Lua 5.4/LuaJIT and zero-dependency foundation policy. LUA-BACKEND-PARITY.4.1 rejects LPeg as a PCRE parser and adds lua/native/regex_pcre2.c plus tools/build_lua_native.sh. PROJECT-DATA-SSD-ROOTING.2.5 makes the builder self-rooted, rejects an output on another filesystem before creating it, and routes tools/run_lua_local.sh plus tools/run_lua_project_data.sh through managed repository scratch. Both commands build separate ABI modules, retain LUA_CPATH for the child command, and clean the disposable native tree."
evidence_update_2026_07_28_project_storage: "The recurring tools/test_lua_project_data_storage.sh oracle proves both ABI module pairs, generated source, traces, all 14 tracked Lua-family allocation owners after FUTURE-PARITY-BACKLOG.10.7.6.1 adds the native observation route test, safely quoted paths, hostile cross-volume build rejection, and cleanup on the repository filesystem."
reverify: "bash tools/run_lua_local.sh && bash tools/test_lua_project_data_storage.sh"
---

PUC Lua 5.4.8 is the primary LinkedSpec Lua conformance runtime. LuaJIT 2.1 uses Lua 5.1 language semantics and is
a secondary compatibility leg. Shared production modules prefer their common syntax; version-specific adapters
must be isolated and may not alter public behavior.

The repository layout is `lua/src/linkedspec/init.lua` and mechanism modules below that directory,
`lua/test/run.lua` plus focused tests, `lua/bin/linkedspec-lua`, and `lua/bin/corpus_runner.lua`.
`tools/run_lua_local.sh` owns local verification. Commands explicitly prepend
`lua/src/?.lua;lua/src/?/init.lua` to `LUA_PATH`, retain default paths with `;;`, and never write a global module
directory.

The foundation uses no LuaRocks, Busted, JSON, lint, or formatter dependency. Those tools/modules are not installed.
Corpus IO `.1.3` owns a small pure-Lua strict JSON codec with an explicit null sentinel, array/harray identity,
canonical key ordering, and strict UTF-8 validation.

Matching `.4.1` deliberately does not use installed LPeg because LPeg constructs PEG patterns and does not parse
the governed PCRE dialect. The selected provider is system PCRE2 through a minimal repository C binding. Building
requires `cc`, `pkg-config`, PCRE2 development files, and headers for the selected Lua ABI. The local gate builds
separate PUC Lua and LuaJIT modules into its own unique managed-run directory below routed `TMPDIR`, sets the
corresponding `LUA_CPATH`, and removes the directory on every exit. The builder validates the nearest existing
output ancestor before creation and the final directory afterward, so a caller cannot place native output on a
different filesystem. No binary is tracked or installed globally.

Lua itself creates no routine build cache. If a future leaf deliberately adopts LuaRocks, its retained cache must
live in a repository-root-derived cache location and its disposable work must live below managed `TMPDIR`; neither
may default to an operating-system temporary directory or developer home.

The tracked primary and corpus commands are executable checkout entrypoints,
not installed system commands. Manual use goes through `tools/run_lua_project_data.sh`, which builds the selected
ABI modules below managed repository scratch, exports `LUA_PATH`/`LUA_CPATH` for the child, and removes the native
tree on exit. Direct low-level embedding may initialize the common project-data environment and call the guarded
builder explicitly; no global Lua or native-module write occurs.

Related facts: [[lua-project-data-ssd-storage]], [[lua-runtime-matching-state]], [[lua-backend-full-parity-plan]], [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]], [[primary-cli-strict-utf8-text-contract]].
See also [[lua-primary-cli-no-drift-closeout]].

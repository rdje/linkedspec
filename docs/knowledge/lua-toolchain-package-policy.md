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
date: 2026-07-11
status: current
tags: [lua, toolchain, package, tests, json, pcre2, lpeg, cache, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.1.1 locks PUC Lua 5.4/LuaJIT and zero-dependency foundation policy. LUA-BACKEND-PARITY.4.1 rejects LPeg as a PCRE parser and adds lua/native/regex_pcre2.c plus tools/build_lua_native.sh; tools/run_lua_local.sh builds separate ABI modules in one disposable /private/tmp/linkedspec-lua-native.* tree and removes it. The local gate passes 60/60 on both runtimes with no leftover artifact."
reverify: "bash tools/run_lua_local.sh && find /private/tmp -maxdepth 1 -type d -name 'linkedspec-lua-native.*' -print"
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
separate PUC Lua and LuaJIT modules into its own unique `/private/tmp/linkedspec-lua-native.*` directory, sets the
corresponding `LUA_CPATH`, and removes the directory on every exit. No binary is tracked or installed globally.

Lua itself creates no routine build cache. If a future leaf deliberately adopts LuaRocks, its tree must live in a
caller-owned `/private/tmp/linkedspec-lua-rocks*` directory, never the repository or home directory, and must be
recursively removed after the proof.

Related facts: [[lua-runtime-matching-state]], [[lua-backend-full-parity-plan]], [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]], [[primary-cli-strict-utf8-text-contract]].

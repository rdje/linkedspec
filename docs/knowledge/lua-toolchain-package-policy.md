---
id: lua-toolchain-package-policy
title: Lua uses PUC 5.4 primary, LuaJIT secondary, repo module paths, and zero-dependency foundation tests
answers:
  - which Lua version does LinkedSpec target
  - how does LinkedSpec run Lua tests
  - what is the Lua module layout
  - where is the linkedspec Lua command
  - does the Lua backend require LuaRocks
  - which Lua JSON library is used
  - where may Lua caches be written
  - does the Lua scaffold depend on LPeg
date: 2026-07-11
status: current
tags: [lua, toolchain, package, tests, json, lpeg, cache, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.1.1 probes PUC Lua 5.4.8 and LuaJIT 2.1, their package paths, LPeg C modules, and absent cjson/dkjson/lunajson/LuaRocks/Busted/Luacheck/StyLua. It locks lua/src/linkedspec, lua/test, lua/bin, tools/run_lua_local.sh, explicit LUA_PATH, zero external scaffold dependencies, pure-Lua typed JSON ownership in .1.3, regex choice in .4.1, and private temporary rock/cache boundaries."
reverify: "lua -v; luajit -v; lua -e 'print(package.searchpath(\"lpeg\",package.cpath)); for _,n in ipairs({\"cjson\",\"dkjson\",\"lunajson\"}) do print(n,pcall(require,n)) end'; rg -n 'Locked foundation policy|LUA-BACKEND-PARITY\.1\.1' docs/tasks/LUA-BACKEND-PARITY.md"
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
canonical key ordering, and strict UTF-8 validation. Installed LPeg C modules are candidate evidence only; matching
leaf `.4.1` owns regex-provider comparison/adoption, so frontend/foundation code cannot depend on LPeg.

Lua itself creates no routine build cache. If a future leaf deliberately adopts LuaRocks, its tree must live in a
caller-owned `/private/tmp/linkedspec-lua-rocks*` directory, never the repository or home directory, and must be
recursively removed after the proof.

Related facts: [[lua-backend-full-parity-plan]], [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]], [[primary-cli-strict-utf8-text-contract]].

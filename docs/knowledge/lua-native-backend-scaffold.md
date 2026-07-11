---
id: lua-native-backend-scaffold
title: Lua has a dependency-free native module and dual-runtime scaffold
answers:
  - does the LinkedSpec Lua backend exist
  - how do I load the Lua LinkedSpec module
  - what does the Lua backend currently implement
  - does the Lua parser work yet
  - how is the Lua scaffold tested
  - what are the Lua backend command paths
date: 2026-07-11
status: current
tags: [lua, backend, scaffold, embedding, tests, PUC-Lua, LuaJIT]
evidence: "LUA-BACKEND-PARITY.1.2 adds lua/src/linkedspec/init.lua, lua/test/run.lua, lua/bin/linkedspec-lua, lua/bin/corpus_runner.lua, lua/README.md, and tools/run_lua_local.sh. Exact repo-LUA_PATH syntax/module tests pass 4/4 on PUC Lua and 4/4 on LuaJIT; command stubs produce exact stderr and exit 2. No parser/corpus/JSON/LPeg API is claimed."
reverify: "bash tools/run_lua_local.sh"
---

The repository now owns a native Lua module at `lua/src/linkedspec/init.lua`. With the documented `LUA_PATH`,
`require("linkedspec")` returns exact backend/package/version/parity/runtime and command identities. Each
`backend_status()` call returns a fresh table, so caller mutation cannot alter later status.

`lua/test/run.lua` is a dependency-free assertion driver. `tools/run_lua_local.sh` syntax-checks every Lua source,
runs four module/status/unavailable-boundary tests on PUC Lua and the same four on LuaJIT, and byte-checks the two
process stubs. It writes no cache or global module state.

`lua/bin/linkedspec-lua` and `lua/bin/corpus_runner.lua` are executable developer stubs. Both resolve the native
module relative to their own location and exit `2` with explicit scaffold messages. They do not expose fake help,
parser, corpus, or status commands. The module deliberately has no `parse_spec` function yet. Typed JSON and strict
manifest IO are owned by active `.1.3`; source parsing follows later.

Related facts: [[lua-toolchain-package-policy]], [[lua-backend-full-parity-plan]],
[[native-in-memory-backend-contract]], [[user-observable-backend-cli-parity-contract]].

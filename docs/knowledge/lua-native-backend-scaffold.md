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
evidence: "LUA-BACKEND-PARITY.1.2 adds the native scaffold; .1.3 adds typed JSON/corpus IO; .2.1-.2.4 add frontend/function projection; .3.1-.3.2 add typed ActionIR/contracts. The current local gate passes 46/46 on PUC Lua and LuaJIT plus exact process checks. No runtime/LPeg API is claimed."
reverify: "bash tools/run_lua_local.sh"
---

The repository now owns a native Lua module at `lua/src/linkedspec/init.lua`. With the documented `LUA_PATH`,
`require("linkedspec")` returns exact backend/package/version/parity/runtime and command identities. Each
`backend_status()` call returns a fresh table, so caller mutation cannot alter later status.

`lua/test/run.lua` is a dependency-free assertion driver. `tools/run_lua_local.sh` syntax-checks every Lua source,
runs forty-six current module/JSON/corpus/AST/frontend/ActionIR tests on PUC Lua and the same forty-six on
LuaJIT, byte-checks the primary command stub, and validates the exact 105-fixture corpus command. It writes no
cache or global module state.

`lua/bin/linkedspec-lua` remains an executable developer stub and exits `2` with an explicit parser message. The
corpus runner now performs strict validation and explicitly declines execution. The module exposes native
rule-level `parse_spec` / `validate_spec`, spec-owned function-node projection, and typed structural
ActionIR parse/contract resolution entrypoints; the primary command remains
unavailable until its later CLI leaf.

Related facts: [[lua-toolchain-package-policy]], [[lua-backend-full-parity-plan]], [[lua-actionir-ast-parser]],
[[lua-actionir-contract-resolver]],
[[native-in-memory-backend-contract]], [[user-observable-backend-cli-parity-contract]].

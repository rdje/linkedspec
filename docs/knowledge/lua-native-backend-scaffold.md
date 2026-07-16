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
evidence: "LUA-BACKEND-PARITY.1.2 adds the native scaffold; .1.3 adds typed JSON/corpus IO; .2.1-.2.4 add frontend/function projection; .3.1-.4.1 add typed ActionIR/contracts/registry/compiled/matching state. At the .4.1 boundary the local gate passed 60/60 on PUC Lua and LuaJIT plus exact process checks. Matching uses a disposable native PCRE2 adapter, not LPeg."
evidence_update_2026_07_15_full_corpus: "LUA-BACKEND-PARITY.6.3 closes current interpreter-corpus execution at 105/105 and 167/167 per ABI with status runtime-corpus-full; the primary command remains the later .7 surface."
evidence_update_2026_07_15_primary_cli: "LUA-BACKEND-PARITY.7.1 replaces the exit-2 scaffold with the exact thin native primary adapter at 169/169 per ABI plus diagnostic shared CLI 61x2; recurring admission .7.2 is active and status remains runtime-corpus-full."
evidence_update_2026_07_15_primary_cli_admission: "LUA-BACKEND-PARITY.7.2 makes the unchanged 61 cases recurring under default/POSIX in the focused gate, extends the warmed matrix to 5x2x61, and advances status to runtime-corpus-primary-cli."
evidence_update_2026_07_15_primary_no_drift: "LUA-BACKEND-PARITY.7.3 aligns checkout native-module lifetime, executable usage, separate corpus tooling, limitations, and gates; parent .7 closes and generated-source scaffold .8.1 activates without behavior change."
reverify: "bash tools/run_lua_local.sh"
---

The repository now owns a native Lua module at `lua/src/linkedspec/init.lua`. With the documented `LUA_PATH`,
`require("linkedspec")` returns exact backend/package/version/parity/runtime and command identities. Each
`backend_status()` call returns a fresh table, so caller mutation cannot alter later status.

`lua/test/run.lua` is a dependency-free assertion driver. `tools/run_lua_local.sh` syntax-checks every Lua source,
runs 169 current tests on PUC Lua and the same 169 on LuaJIT, passes the exact primary adapter at 61/61 under
default and POSIX environments on PUC Lua, validates the exact 105-fixture corpus, and executes it at 105/105
through the developer runner. It writes no cache or global module state.

`lua/bin/linkedspec-lua` now delegates exact parser-command options/IO/results/phase trace to native APIs. The
separate corpus runner validates by default and executes the complete manifest behind bare `--execute`. The module
now exposes the complete native parse/validate/compile/function/staged/runtime/corpus surface with
`runtime-corpus-primary-cli` status. CLI/native/corpus no-drift `.7.3` is closed;
generated-source scaffold `.8.1` is active.

Related facts: [[lua-toolchain-package-policy]], [[lua-backend-full-parity-plan]], [[lua-actionir-ast-parser]],
[[lua-actionir-contract-resolver]],
[[native-in-memory-backend-contract]], [[user-observable-backend-cli-parity-contract]],
[[lua-full-corpus-gate]].
See also [[lua-primary-cli-adapter]], [[lua-primary-cli-recurring-admission]],
[[lua-primary-cli-no-drift-closeout]].

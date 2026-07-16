---
id: lua-primary-cli-no-drift-closeout
title: Lua primary CLI, native embedding, corpus tooling, and checkout setup are no-drift
answers:
  - what did LUA BACKEND PARITY 7.3 do
  - is the Lua primary CLI parent closed
  - how do I run linkedspec lua from a checkout
  - must LUA CPATH remain set for the Lua command
  - are Lua native modules installed globally
  - does LinkedSpec Lua require LuaRocks
  - are corpus and status subcommands part of linkedspec lua
  - what remains after Lua primary CLI no drift
date: 2026-07-15
status: current
tags: [lua, cli, embedding, corpus, installation, no-drift, PUC-Lua, LuaJIT, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.7.3 corrects stale exit-2/validation-only mdBook prose and a README sequence that removed native modules before later commands used them. A disposable PUC build directly loads runtime-corpus-primary-cli, runs executable help and inline parsing, and validates 105 fixtures. The immediately prior proof is 169/169 per ABI, focused 61x2, corpus 105/105, shared 5x2x61, and canonical Phase 0 1031/1031 in 607 seconds; the no-drift closeout's canonical local CI passes Phase 0 1031/1031 in 608 seconds. No behavior changes; parent .7 closes and hands off to the generated-source plan now split by .8.1.0 into exact-v1/v2/v3 emitter core .8.1.1 and fresh-process proof .8.1.2."
evidence_update_2026_07_16_generated_isolation: "LUA-BACKEND-PARITY.8.1.2 closes fresh-process PUC Lua/LuaJIT valid/corrupt execution and cleanup at 173/173 per ABI; exact family-plan .8.2 is active."
evidence_update_2026_07_16_generated_families: "LUA-BACKEND-PARITY.8.2 closes exact family plans/execution/trace/all-family/variadic proof at 176/176 per ABI; subset .8.3 is active."
evidence_update_2026_07_16_generated_subset: "LUA-BACKEND-PARITY.8.3 closes exact contract-ordered interpreter-first 8/105 fresh-host value/metadata/plan/trace/cleanup proof at 177/177 per ABI; sole census/handoff .8.4 is active."
reverify: "bash tools/run_lua_local.sh && rg -n 'LUA_CPATH|LuaRocks|runtime-corpus-primary-cli|corpus/status|8.1' lua/README.md docs/linkedspec-book/src/public-api/native-spec-loading.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/tasks/LUA-BACKEND-PARITY.md"
---

`LUA-BACKEND-PARITY.7.3` closes the Lua primary-command parent without changing
runtime, CLI, corpus, generated-source, or capability behavior. The exact
current proof remains 169/169 native tests on PUC Lua and LuaJIT, 61/61 primary
process cases under both default and POSIX option environments on PUC Lua,
105/105 complete corpus execution, and the shared five-backend 5x2x61 matrix.
The closeout's canonical local CI also passes the reference CLI 61/61 in both
option environments and Phase 0 1031/1031 in 608 seconds.

Repository checkout use requires the two native PCRE2/filesystem modules. Build
them into caller-owned temporary storage, keep that directory alive for the
whole shell session, export `LUA_CPATH` to its `?.so` files, and use an EXIT trap
for cleanup. Exporting the documented `LUA_PATH` also enables direct
`require("linkedspec")`; the tracked primary and corpus executables locate
`lua/src` themselves. No native module, Lua package, or command is installed
globally, and LuaRocks is not a dependency.

The primary command remains parser-oriented. The unchanged manifest proves
that `status` and `corpus` are rejected positionals; validation and full
105-case execution remain on the separate developer corpus runner. Public
status stays `runtime-corpus-primary-cli`. Deterministic generated Lua source
core is current through `.8.1.1`, and fresh-process PUC Lua/LuaJIT valid/corrupt
proof is closed under `.8.1.2`. Ten-family execution `.8.2` is also closed.
Contract-sourced 8/105 admission `.8.3` is also closed, and final
census/handoff `.8.4` is active.

Related facts: [[lua-primary-cli-adapter]],
[[lua-primary-cli-recurring-admission]], [[lua-native-backend-scaffold]],
[[lua-toolchain-package-policy]], [[lua-full-corpus-gate]],
[[lua-backend-full-parity-plan]], [[lua-generated-source-scaffold-split]],
[[lua-generated-source-emitter-core]], [[lua-generated-source-fresh-process-isolation]],
[[lua-generated-source-family-plan]], [[lua-generated-source-accepted-subset]].

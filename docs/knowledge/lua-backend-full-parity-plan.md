---
id: lua-backend-full-parity-plan
title: Lua backend planning inherits the complete LinkedSpec parity contract
answers:
  - what is the Lua LinkedSpec backend plan
  - which Lua runtime is primary for LinkedSpec
  - is LuaJIT required for LinkedSpec
  - is LPeg automatically the LinkedSpec regex engine
  - what command will the Lua backend expose
  - must Lua support native in-memory LinkedSpec
  - must Lua support generated source
  - what task implements the Lua backend
  - what is the first Lua backend task
date: 2026-07-11
status: current
tags: [lua, backend, parity, embedding, cli, corpus, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.3 creates docs/tasks/LUA-BACKEND-PARITY.md after generated-source .3 closes at 60/0/0. Read-only preflight finds PUC Lua 5.4.8, LuaJIT 2.1, and LPeg on both; LuaRocks, Busted, Luacheck, and StyLua are absent. The plan splits foundation, frontend, ActionIR/compiler, matching/runtime, staged/loading/capabilities, 105 corpus, exact CLI, and generated-source v1 before code."
reverify: "lua -v; luajit -v; lua -e 'print(pcall(require,\"lpeg\"))'; rg -n 'LUA-BACKEND-PARITY|linkedspec-lua|Generated Lua source' docs/tasks/LUA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`docs/tasks/LUA-BACKEND-PARITY.md` is the dedicated third-backend rollout plan. PUC Lua 5.4 is the primary
conformance runtime. LuaJIT is a secondary compatibility leg because its language baseline is Lua 5.1; it may not
fork or weaken public behavior.

The primary product is a native in-process Lua module accepting `.spec` source and input values and returning
structured Lua results/diagnostics. `linkedspec-lua` is a thin adapter with the exact 61-case CLI interface, not a
separate product or semantics owner.

The plan inherits every admitted contract: universal source/ActionIR, scalar/array/harray/codeblock values,
newline-only statement separation with semicolons only between same-line statements, single/double quotes,
generic final-codeblock equivalence, matching/cursor/capture semantics, staged functions, descriptors,
diagnostics/trace, native resolution, 105/105 corpus, capability census, and generated-source v1 with ten families
and exact 8/105 admission.

LPeg loads on both installed runtimes, but this does not make it the selected regex engine. Lua patterns and LPeg
must be compared with the neutral regex/match-state fixtures; a native adapter is permissible if it preserves the
native in-memory module contract and exact behavior. LuaRocks and the common test/lint/format tools are absent, so
active `.1.1` must lock a reproducible repository-owned dependency/test/cache strategy before code.

Related facts: [[native-in-memory-backend-contract]], [[user-observable-backend-cli-parity-contract]],
[[backend-capability-census]], [[generated-source-contract-v1]], [[language-agnostic-backend-vision]],
[[dart-backend-interpreter-first-plan]], [[julia-backend-interpreter-first-plan]].

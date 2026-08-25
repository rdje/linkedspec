---
id: lua-progressive-span-dispatch-admission
title: Lua progressive span dispatch is privately admitted once on each supported ABI
answers:
  - "is Lua progressive span dispatch admitted"
  - "where does canonical CI run Lua progressive span dispatch"
  - "does ordinary Lua discovery run progressive span dispatch"
  - "what is the progressive span dispatch rollout after Lua admission"
  - "does the Lua progressive authority consumer run in ordinary tests"
  - "what remains after Lua progressive span dispatch admission"
date: 2026-08-25
status: current private PUC Lua and LuaJIT admission independently recomposed; recurrence and public no-drift pending
tags: [lua, PUC-Lua, LuaJIT, progressive-parsing, admission, ci, actionir, generated-source, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.6.3 moves the same 178-assertion Lua-5.1-compatible carrier consumer to lua/test/progressive_span_dispatch_contract_test.lua. tools/run_lua_local.sh runs that one source exactly once with $LUA_CMD and once with $LUAJIT_CMD. Canonical CI requires the tracked path once, then logs and invokes one exact repository-routed PUC Lua route and one exact LuaJIT route. No dormant carrier duplicate remains. The private authority, exclusive node, and native/normalized-reconstructed/generated-plan/independently loaded emitted-module behavior are unchanged; the separate 273-assertion-per-ABI authority consumer remains dormant. Neutral governance promotes only the PUC Lua and LuaJIT rows to rollout 7/9 and 112 mutations with 9 Rust + 8 Dart + 9 Julia + 9 Lua carrier paths, zero backend guards, 10 outward guards, and 26 diagnostics. Generated format, typed recurrence, public inventory, facade/schema/MCP/CLI/README, and outward surfaces do not move."
evidence_update_2026_08_25_recomposition: "FUTURE-PARITY-BACKLOG.14.6.6.4 independently reruns the unchanged carrier at 178/178 and dormant authority at 273/273 on each ABI, complete ordinary Lua, all admitted peer carriers, and every neutral/direct-dependent checker without executable movement. It closes shared Lua parent .14.6.6 at 7/9/112 and hands off typed recurring proof .14.6.7."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/progressive_span_dispatch_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/progressive_span_dispatch_contract_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test_dormant/progressive_span_dispatch_authority_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test_dormant/progressive_span_dispatch_authority_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "test ! -e lua/test_dormant/progressive_span_dispatch_contract_test.lua"
  - "test \"$(rg -c 'lua/test/progressive_span_dispatch_contract_test[.]lua' tools/run_lua_local.sh)\" -eq 2"
  - "test \"$(rg -c 'running exact Lua progressive span-dispatch admission consumer' tools/run_ci_local.sh)\" -eq 2"
---

# Private dual-ABI Lua progressive admission

The carrier proof retains its exact fixture, 178 assertions, and behavior
groups, but now lives in ordinary Lua discovery. The ordinary driver executes
the one shared source once on PUC Lua and once on LuaJIT. Canonical CI
independently requires the tracked path and repeats one exact repository-routed
command per ABI, making both runtime rollout rows explicit and recoverable.

This leaf changes no parser, compiler, runtime, authority, generated format, or
public API. It promotes only the two private Lua runtime rows. The authority
matrix remains a separate dormant proof so ordinary carrier admission does not
duplicate its 273 exhaustive assertions on each host. Recurring six-runtime
composition, typed progressive projection, and public no-drift retain their
separate owners.

Independent recomposition `.14.6.6.4` proves those committed owners unchanged,
closes the shared Lua parent, and leaves the exact recurring and public owners
pending without behavior or rollout movement.

Related facts: [[progressive-span-dispatch-audit-plan]],
[[lua-progressive-span-dispatch-private-authority]],
[[lua-progressive-span-dispatch-carriers]], and
[[lua-progressive-span-dispatch-dormant-red]], and
[[lua-progressive-span-dispatch-recomposition]].

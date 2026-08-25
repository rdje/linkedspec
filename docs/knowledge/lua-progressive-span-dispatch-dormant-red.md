---
id: lua-progressive-span-dispatch-dormant-red
title: Lua progressive span dispatch has one exact shared dual-ABI dormant RED
answers:
  - "where is the Lua progressive span dispatch RED"
  - "how do I run the Lua progressive RED on PUC Lua"
  - "how do I run the Lua progressive RED on LuaJIT"
  - "does Lua implement dispatch_span yet"
  - "what node does Lua compile dispatch_span into"
  - "what error does Lua dispatch_span produce"
  - "does the Lua staged registry resolve expr-v1"
  - "which Lua carriers preserve the progressive RED"
  - "is the Lua progressive consumer in ordinary discovery"
  - "which tasks own Lua progressive authority carriers admission and recomposition"
date: 2026-08-25
status: exact dormant final-path RED current on PUC Lua and LuaJIT; private authority next
tags: [lua, PUC-Lua, LuaJIT, progressive-parsing, dispatch-span, ActionIR, generated-source, RED, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.6.0 splits shared Lua into exact dormant RED, private authority, dormant carrier, canonical dual-ABI admission, and independent recomposition leaves. The same Lua-5.1-compatible consumer passes 85 assertions and fails only its final combined dedicated-node invariant on PUC Lua and LuaJIT. The unrelated staged registry rejects expr-v1 during resolve. The authored assignment remains one assign_scalar whose value is a generic call named dispatch_span; contract analysis reports unknown_helper, and no progressive_dispatch_span node exists. Native and normalized-JSON reconstructed execution return the same typed RuntimeInterpreterException; generated-plan and independently loaded emitted-module execution wrap the same unsupported runtime helper boundary. The emitted module contains neither generic nor dedicated spelling because normalized SpecFile JSON is hex-embedded. The consumer remains under lua/test_dormant and absent from ordinary/canonical discovery. Complete Lua stays 178/178 per ABI, CLI 66x2 per environment, corpus 105, storage 19/3, progressive 5/9/106, typed 11/3/152, recognition 138/250/58, generated/capability 80/0/0, and language 250/126."
reverify: "bash tools/run_lua_project_data.sh puc lua/test_dormant/progressive_span_dispatch_contract_test.lua; bash tools/run_lua_project_data.sh luajit lua/test_dormant/progressive_span_dispatch_contract_test.lua; bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py; test \"$(rg -c 'progressive_span_dispatch_contract_test[.]lua' tools/run_lua_local.sh tools/run_ci_local.sh)\" = 0"
---

# Shared Lua progressive span-dispatch RED

The final-path consumer is
`lua/test_dormant/progressive_span_dispatch_contract_test.lua`. It is one
Lua-5.1-compatible source executed unchanged by PUC Lua and LuaJIT. Each host
runs 86 assertions: 85 pass and only
`Lua progressive RED: missing exclusive progressive_dispatch_span node` fails.

The exact authored form parses and compiles today, but the assignment value is
still a generic `call` named `dispatch_span`. Contract analysis owns one
`unknown_helper` diagnostic; runtime evaluation owns the structured
`unsupported runtime helper 'dispatch_span'` error. Native, normalized
`SpecFile` reconstruction, generated-plan execution, and an independently
loaded emitted module converge on that boundary on both ABIs. The narrow staged
function-body registry separately rejects logical parser identity `expr-v1` at
resolve, so it is not progressive execution authority.

The consumer also locks the neutral 5/9/106 inventory, the five production
guard paths, both pending Lua rollout rows, normalized reconstruction, the
unchanged one-row generated-v2 plan, emitted identity, and absence from ordinary
and canonical discovery. Production Lua contains neither `dispatch_span` nor
`PROGRESSIVE_DISPATCH_SPAN`.

Child `.14.6.6.1` owns one private ActionIR-independent authority shared by both
ABIs. `.2` alone owns the dedicated node and four dormant carriers. `.3` alone
owns ordinary/canonical dual-ABI admission and rollout. `.4` independently
recomposes and closes the parent.

Related facts: [[progressive-span-dispatch-audit-plan]],
[[lua-typed-source-location-dormant-red]],
[[lua-recognition-transaction-private-authority]],
[[lua-generated-source-family-plan]], and
[[lua-staged-function-body-registry]].

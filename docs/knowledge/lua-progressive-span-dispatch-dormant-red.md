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
status: historical dual-ABI RED preserved as evidence; dormant carriers now GREEN, admission next
tags: [lua, PUC-Lua, LuaJIT, progressive-parsing, dispatch-span, ActionIR, generated-source, RED, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.6.0 splits shared Lua into exact dormant RED, private authority, dormant carrier, canonical dual-ABI admission, and independent recomposition leaves. The same Lua-5.1-compatible consumer passes 85 assertions and fails only its final combined dedicated-node invariant on PUC Lua and LuaJIT. The unrelated staged registry rejects expr-v1 during resolve. The authored assignment remains one assign_scalar whose value is a generic call named dispatch_span; contract analysis reports unknown_helper, and no progressive_dispatch_span node exists. Native and normalized-JSON reconstructed execution return the same typed RuntimeInterpreterException; generated-plan and independently loaded emitted-module execution wrap the same unsupported runtime helper boundary. The emitted module contains neither generic nor dedicated spelling because normalized SpecFile JSON is hex-embedded. The consumer remains under lua/test_dormant and absent from ordinary/canonical discovery. Complete Lua stays 178/178 per ABI, CLI 66x2 per environment, corpus 105, storage 19/3, progressive 5/9/106, typed 11/3/152, recognition 138/250/58, generated/capability 80/0/0, and language 250/126."
evidence_update_2026_08_25_authority: "FUTURE-PARITY-BACKLOG.14.6.6.1 adds the separate private ActionIR-independent bounded child authority and proves it at 273/273 on PUC Lua and LuaJIT. This does not change the RED: the final-path consumer remains 85-pass/one-RED, all five carrier guards stay token-free, and ordinary/canonical discovery, format, rollout, typed recurrence, and outward surfaces remain unchanged. Carrier leaf .14.6.6.2 is next."
evidence_update_2026_08_25_carriers: "FUTURE-PARITY-BACKLOG.14.6.6.2 preserves this historical RED fact while changing the current final path to one exclusive progressive_dispatch_span node and four fresh-authority carriers. The same dormant consumer now passes 178/178 per ABI; authority remains 273/273, rollout remains 5/9/106, ordinary/canonical discovery remains absent, and admission .3 is next."
reverify: "bash tools/run_lua_project_data.sh puc lua/test_dormant/progressive_span_dispatch_contract_test.lua; bash tools/run_lua_project_data.sh luajit lua/test_dormant/progressive_span_dispatch_contract_test.lua; bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py; test \"$(rg -c 'progressive_span_dispatch_contract_test[.]lua' tools/run_lua_local.sh tools/run_ci_local.sh)\" = 0"
---

# Shared Lua progressive span-dispatch RED

The final-path consumer is
`lua/test_dormant/progressive_span_dispatch_contract_test.lua`. It is one
Lua-5.1-compatible source executed unchanged by PUC Lua and LuaJIT. Leaf `.0`
recorded its exact historical 85-pass/one-RED boundary. Carrier `.2` has since
made the expanded consumer GREEN at 178/178 per host.

At the historical boundary the assignment was a generic call with an
`unknown_helper` diagnostic. It now lowers exclusively to the dedicated node;
native, normalized reconstruction, generated-plan execution, and an
independently loaded emitted module converge on the detached child result. The
narrow staged function-body registry still rejects logical parser identity
`expr-v1`, so it is not progressive execution authority.

The consumer also locks the neutral 5/9/106 inventory, nine dormant carrier
paths, both pending Lua rollout rows, normalized reconstruction, the
unchanged one-row generated-v2 plan, emitted identity, and absence from ordinary
and canonical discovery. The package facade and outward surfaces remain free of
the private intrinsic.

Child `.14.6.6.1` owns one private authority shared by both ABIs and proven
separately at 273/273 per host. `.2` now owns the dedicated node and four dormant carriers. `.3` alone
owns ordinary/canonical dual-ABI admission and rollout. `.4` independently
recomposes and closes the parent.

Related facts: [[progressive-span-dispatch-audit-plan]],
[[lua-progressive-span-dispatch-private-authority]],
[[lua-progressive-span-dispatch-carriers]],
[[lua-typed-source-location-dormant-red]],
[[lua-recognition-transaction-private-authority]],
[[lua-generated-source-family-plan]], and
[[lua-staged-function-body-registry]].

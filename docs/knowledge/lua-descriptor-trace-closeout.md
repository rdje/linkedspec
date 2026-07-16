---
id: lua-descriptor-trace-closeout
title: Lua descriptor and full-pipeline trace work is closed without early census admission
answers:
  - what closed Lua descriptor and full pipeline trace no drift
  - is LUA-BACKEND-PARITY 5.3 complete
  - why is Lua not in the capability census after full pipeline trace
  - what follows Lua descriptor trace closeout
  - does Lua 5.3.3 change behavior or capability rows
date: 2026-07-15
status: current
tags: [lua, descriptors, trace, no-drift, capability-census, task-tree, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.3.3 inventories exact API/status/test/contract/book/KM agreement at 155/155 on PUC Lua and LuaJIT, closes parents .5.3/.5 without source or manifest change, preserves the four-backend 64/0/0 census until .8.4, activates corpus .6.1, and passes canonical CLI 61x2 plus Phase 0 1..1031 in 611 seconds."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_callable_signature_contract.py && python3 tools/check_callable_codeblock_contract.py && perl tools/check_capability_conformance.pl && perl tools/check_native_spec_resolution_contract.pl && perl tools/check_language_capability_coverage.pl"
---

`LUA-BACKEND-PARITY.5.3.3` closes the descriptor/full-pipeline-trace implementation boundary. Exact public exports
and options, `native-full-pipeline-trace-v1`, the fixed-v1/variadic-v2/final-codeblock-v3 outward union, both
neutral trace capability definitions, focused Lua tests, root/Lua docs, mdBook, task/roadmap/live state, and the
Knowledge Map agree. No hidden emitter construction, compiled/engine trace retention, unowned seam, or stale
current claim remains.

This slice was deliberately not capability-census admission. ADR `0041` defines the manifest as an all-pass
backend surface, so Lua remained outside its 16 rows while corpus, primary CLI, generated-source, and generated-
subset work was incomplete. Those obligations later close, and `.8.4` adds all 16 Lua pass rows at five-backend
80/0/0.

Both Lua ABIs pass 155/155. Neutral callable checks pass 3/9/7 and 7/11/9/7/4/8; native loading passes 14/9/4;
coverage remains 246/105+1/122; public aggregate surface remains 58/27/0. The closeout changes no Lua source,
status, runtime result, test expectation/count, or capability row. Parents `.5.3` and `.5` are done; controlled/
core corpus window `.6.1` is active. Canonical local CI passes CLI 61x2 plus Phase 0 `1..1031` in 611 seconds.

Later admission: [[lua-five-backend-capability-admission]].

Related facts: [[lua-native-full-pipeline-trace]], [[lua-descriptor-trace-admission-split]],
[[lua-outward-function-descriptor-union]], [[backend-capability-census]], [[lua-backend-full-parity-plan]].

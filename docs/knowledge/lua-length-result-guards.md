---
id: lua-length-result-guards
title: Installed Lua Length guards preserve Count permission and mutation rights
answers:
  - "how does Lua guard ordinary Length result continuations"
  - "does Lua produced Length count retain scalar source ownership"
  - "does Lua Length add interpreter chunk locals or change mutation rights"
  - "which installed hosts were checked for Length guards"
  - "must Lua Length emitted modules be regenerated"
date: 2026-11-06
status: installed-host Lua74.5 implemented with focused checks; P1 key-count75.0 next; full admission open
tags: [lua, length, count, guards, source, copy, logical, with]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.74.5; docs/checkpoints/length-guard-lua-2026-11-06 retains actual declared first inputs, raw phases and readonly recovery/five corruptions. Each host24 programs12PASS12RED to24PASS, twelve healthy exact, final122 plus nearest Count92 and Count/length checks."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/length-guard-lua-2026-11-06/review.py"
  - "bash tools/run_lua_project_data.sh puc lua/test/length_result_guard_composition_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/length_result_guard_composition_test.lua"
---

Canonical Length role joins kind_guarded_result before Count initial-source
permission. Existing actual-kind guards skip incompatible operands and later
copy/eager-logical/with effects. Initial Count zero and explicit bridges remain;
produced Length Number/null rejects Count. Existing namespace adds no interpreter
chunk locals. Scalar-result state, Count one-step permission and index-based
Array-end mutation rights stay exact. Both producers/domains/signatures/copy
depths/functions/parser/schema remain unchanged.

PUC Lua5.5.1 and LuaJIT2.1.1788460057 independently freeze source-domain
[1,1,1,2,2,null] and per-route error fields before production. On both hosts,
24 authored programs12PASS12RED become24PASS, twelve healthy observations exact.
All24 emitted module texts/parsed inputs per host remain identical. Rebuild Lua
applications/runtime. Final122 new-normal checks, nearest92 Count guards and two
Count/length programs across native/plan/fresh routes pass on each host. Interpreter/
runner loadfile checks and three runner registration lines; no unsafe full runner,
formatter or declared5.4 execution.

Actual declared first Lua/native source/direct-fixture/wrapper/module/parsed
inputs and complete raw channels survive losslessly, with byte/mode identities
and five effective corruptions. Native binaries/external toolchain/transitive
closure4.2, general process/package isolation, canonical discovery4.1, declared5.4
and full23.4 remain separate. Fresh modules share process/runtime. P1 key-count75.0
is next before unrelated selection; bounded Length implementations are complete.

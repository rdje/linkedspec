---
id: julia-length-result-guards
title: Julia Length guards produced values before initial Count permission
answers:
  - "how does Julia guard ordinary Length result continuations"
  - "does Julia Length count retain scalar source ownership"
  - "does Julia Length repair change enumerate call_index or mutation guards"
  - "must Julia Length emitted modules be regenerated"
date: 2026-11-06
status: Julia74.4 implemented with focused checks; installed Lua74.5 next; full admission open
tags: [julia, length, count, guards, source, copy, logical, with]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.74.4; docs/checkpoints/length-guard-julia-2026-11-06 retains actual declared first inputs, full raw phases and readonly recovery/five corruptions. Authored24 controls12PASS12RED to24PASS, twelve healthy exact, final220 assertions."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/length-guard-julia-2026-11-06/review.py"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error julia/test/length_result_guard_composition_test.jl"
---

Canonical positional free-one/zero-extra receiver Length role joins existing
kind_guarded_result before Count initial-source permission. Existing guards reject
wrong-kind operands and later copy/eager-logical/with effects. Initial Count zero
stays; produced Length Number/null rejects Count. Scalar_result initialization/
assignments, Count one-step permission, enumerate/call_index and its separate
Array-end mutation restriction stay exact. Both producers/domains/signatures/
copy depths/functions/parser/schema remain unchanged.

Independent four-route observations freeze Julia source-domain
[1,1,1,2,2,null] and per-route runtime/generated error profiles before production.
Twelve target programs are fixed; twelve healthy observations stay exact.
Actual24 emitted module texts and parsed inputs are unchanged: rebuild Julia
applications/runtime. New normal122, Count/length6 and Count guards92 pass220
assertions with strict depwarn and empty stderr. One normal runner include.

Actual declared source/manifest/direct fixtures/wrappers/modules/parsed inputs
precede respective runs and remain recoverable with full raw channels, byte/mode
identities and five effective corruption controls. Fresh Modules share process/
runtime. Full native/transitive closure4.2, isolation, canonical discovery4.1 and
full23.4 remain separate; independently assess safe installed Lua74.5 next.

---
id: julia-constructor-result-guards
title: Julia retained constructors reuse the common actual-kind result guard
answers:
  - "which Julia owner guards retained Array and Hash constructor result methods"
  - "does Julia constructor rejection skip arguments and later with"
  - "do Julia computed Hash keys need Perl producer fixes"
  - "which scaffolds are included in Julia constructor baseline PASS counts"
date: 2026-10-31
status: bounded Julia61.4 targeted-checked; safe Lua/full admission separate
tags: [julia, constructors, source, guards, with, keys]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.61.4; constructor-julia-intake.json.gz retains same116 96PASS20RED to116PASS, nearest152/strict depwarn and all actual producers/inputs/results.96 includes five partial-group route-key scaffolds."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(ARGS[1]); include(ARGS[2]); include(ARGS[3])' julia/test/constructor_result_composition_test.jl julia/test/free_default_result_composition_test.jl julia/test/uniform_binding_contract_test.jl"
---

Original constructors/readers/computed keys/order/snapshots/functions work;
common kind_guarded_result source classification omits retained constructors.
Canonical ordinary Array/paired Hash predicate/current guard now isolates
incompatible operands/later with bodies, preserving source once, intermediate
kinds and valid empty/null with. Existing splice classifier/pair/odd/malformed/
selector/signature/domain/copy/alias/function/parser/schema policy remains.

Same116 assertions96PASS20RED to116PASS native/restoredSpec/plan/fresh Module.
96 includes five passing route-key scaffolds in failed groups.21 values/16 healthy
observations/two errors/eight syntax shapes canonically exact; nearest default91/
binding61/strict depwarn pass. Standalone flat tests need Main imports/derived
REPO_ROOT per existing contract; standard precompile retained. One runner include.
Rebuild apps/runtime, no isolated package/exhaustive excluded-runtime/full admission.

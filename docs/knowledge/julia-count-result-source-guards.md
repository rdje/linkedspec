---
id: julia-count-result-source-guards
title: Julia Count continuations retain actual kinds and initial source behavior
answers:
  - "how does Julia guard Count consumers before operands and with bodies"
  - "why does Julia Count preserve the call_index mutation restriction"
  - "does Julia Count guarding change scalar_result or source fallback"
  - "why do Julia Count source errors have different generated and native wrappers"
date: 2026-11-05
status: bounded Julia73.4 focused-checked; P1 Count/copy assessment and full admission remain open
tags: [julia, count, guards, source, null, copy, diagnostics]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.4; docs/checkpoints/count-guard-julia-2026-11-05/ retains original/qualified baseline, frozen domain/source/error observations, native debug trace, emitted modules, final and selected compatibility proof."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --depwarn=error julia/test/count_result_guard_composition_test.jl"
  - "bash tools/run_julia_project_data.sh --project=julia --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test;include(ARGS[1]);include(ARGS[2])' julia/test/count_length_receivers_test.jl julia/test/copied_null_index_composition_test.jl"
---

`_runtime_is_ordinary_count_result_chain` admits canonical positional free-one
Count sources and zero-extra receiver prefixes, excluding traversal and non-with
trailing blocks. The common fluent loop joins the existing actual-kind guard;
incompatible consumers return before operands and later `with` bodies. Valid null
still enters `with`, numeric zero stays data and explicit Array bridges work.

Only initial receiver Count without a prior result owner skips the common guard.
Count results consumed by another Count already have Number kind and reject the
Array-only consumer. Scalar-result initialization/assignments and its guard stay
intact. Retain `enumerate`/`call_index` for the separate Array-end mutation gate.
Count's source producer and copied-null policy are unchanged; the diagnostic
frozen before production is `[0,0,0,0,0,0,null]`.

Native/restored/plan/fresh Module controls pass after independent guard REDs.
Eighteen public source shapes and route-specific error message/class and selected
diagnostic fields freeze before production. Native/restored binding-kind errors have the existing
generic runtime diagnostic with optional code; generated routes use the existing
`GeneratedSourceException` execution wrapper. Uniform class/code assertions were
an observer mistake, separately retained and corrected before the guard edit.
No diagnostic-contract normalization is claimed.

Selected Count/length/copied-null index controls and strict depwarn pass; one
normal runner include is registered. Captured ASTs and complete emitted sources
precede Module loading. Fresh modules share a process/runtime, so independent
package isolation and complete transitive generation custody remain unassessed.
Registration/input-custody/general isolation/full23.4 remain separately owned.
Rebuild Julia applications for the fix; safe installed Lua73.5 follows.

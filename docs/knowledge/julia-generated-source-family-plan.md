---
id: julia-generated-source-family-plan
title: Julia generated source has exact ten-family authoritative dispatch
answers:
  - does Julia generated source expose a family plan
  - what generated rule families does Julia support
  - does the Julia generated plan control execution
  - what Julia generated plan errors exist
  - what trace roles does generated Julia execution emit
  - how is the Julia all-family matrix tested
date: 2026-07-11
status: current
tags: [julia, generated-source, family-plan, direct-execution, trace, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.3.4.2 adds GeneratedRuleFamily/GeneratedPlanRow, compiled-state classification, exact validation, generated runtime context, and portable trace in julia/src/source/SourceEmitter.jl and julia/src/runtime/Interpreter.jl. The 27-assertion family proof in julia/test/source_emitter_test.jl compares all ten roots with the native interpreter, rejects four plan mutations, and independently loads one all-family generated module. Package proof is 1,155 assertions."
evidence_update_2026_07_11_admission: "FUTURE-PARITY-BACKLOG.3.4.3 reads the exact eight-case contract subset, proves checked-in values through ordinary/staged native interpretation before emission, independently loads eight modules in separate namespaces with exact metadata/plans/trace identity, and passes complete 1,168/61x2/105 gates. Julia promotes to pass at census 60/0/0."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia julia --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/source_emitter_test.jl\")'"
---

Julia uses the exact contract-v1 family names: `default`, `or_acode`, `and_single_acode`, `and_acode_seq`,
`and_bcode`, `or_bcode`, `rep_acode`, `rep_bcode`, `rep_and_acode`, and `rep_and_bcode`.
`build_generated_rule_plan(...)` classifies effective compiled rule order into public `GeneratedPlanRow` values.

`validate_generated_rule_plan_v1(...)` runs before execution and distinguishes row-count, ordered-label,
known-family mismatch, and unknown-family failures. Unknown names are rejected before expected-family comparison.
The validated plan becomes a per-label typed family map in the runtime execution context. Every generated root and
nested rule reads that map and selects regex/acode or blind/bcode dispatch from it; native execution has no map and
retains compiled-structure selection. The plan therefore controls execution rather than serving as metadata only.

Generated traced execution adds `generated_rule_enter`, `generated_family_decision`, and `generated_rule_exit`
with source identity, rule label, and family beside the richer native Julia trace. One combined specification owns
all ten root families plus their children. The focused test first compares ten generated direct results against
native interpreter results, then loads one emitted module in a fresh caller-owned offline project and repeats all
ten executions with exact plan and trace checks. Caller project/depot state is recursively deleted.

Julia's contract-sourced manifest admission is complete; generated Julia source is classified pass at census
60/0/0. Final cross-backend closeout is owned by `.3.5`.

Related facts: [[julia-generated-source-scaffold]], [[rust-generated-source-family-plan]],
[[dart-generated-source-deferred]], [[generated-source-parity-audit]], [[julia-compiled-spec-state]],
[[julia-runtime-rule-interpreter]].

---
id: julia-runtime-rule-interpreter
title: Julia runtime interpreter executes compiled rule modes, lifecycle flow, child edges, and guarded repetition
answers:
  - where is the Julia runtime interpreter
  - does Julia execute compiled rules yet
  - does Julia support action edge dispatch
  - does Julia support blind call dispatch
  - does Julia run lifecycle blocks
  - does Julia support retv and accumulators
  - does Julia guard recursion and zero progress repetition
  - what helper behavior does the first Julia interpreter support
date: 2026-07-10
status: current
tags: [julia, runtime, interpreter, dispatch, lifecycle, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.2 adds julia/src/runtime/Interpreter.jl and exports LinkedSpecRuntimeEngine, runtime_parse(...), runtime_execute(...), RuntimeParseResult, RuntimeLifecycleEvent, and RuntimeInterpreterException. julia/test/runtests.jl verifies default repetition, action-edge and blind-call child dispatch, explicit call/returns, passive terminals, AND/OR modes, bounded repetition, zero-progress cutoff, lifecycle order/events, retv, accumulators, consume mode, nested output shapes, recursion cutoff, and runtime error boundaries. The dispatch-facing evaluator deliberately leaves general stores and broad helper/control/block/callback families to JULIA-BACKEND-PARITY.4.3."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

## Fact

Julia runtime rule execution lives in `julia/src/runtime/Interpreter.jl`.

`LinkedSpecRuntimeEngine` consumes `CompiledSpec` plus the matching/register state in
`julia/src/runtime/Matching.jl`. `runtime_parse(...)` and `runtime_execute(...)` dispatch default, AND, OR, and
bounded/unbounded repetition rules in seek or consume mode; execute action and blind-call children; preserve entry
and local matches across child entry; carry child values through `retv`; run `I/LS/LE/IT/EX/LX/E` lifecycle
payloads; and terminate repeated or recursive work through bounds, zero-progress checks, and
same-rule/slot/cursor guards.

`RuntimeParseResult` records matched/value state, the backend-neutral one-element output wrapper, final code-unit
and character cursors, and lifecycle events.

The `.4.2` ActionIR evaluator is intentionally narrow: literals, `retv`, explicit arrays,
`set(array(...), ...)`, `push(...)`, `copy(...)`, `call(...)`, explicit returns, and entry/local capture reads are
available only to support dispatch and lifecycle proofs. General variable/store behavior and the documented
string/number/array/hash/control/block/callback families belong to `.4.3` and later leaves.

Related facts: [[julia-runtime-matching-state]], [[julia-compiled-spec-state]],
[[dart-runtime-rule-interpreter]], [[spec-lifecycle-retv-order]], [[julia-backend-interpreter-first-plan]].

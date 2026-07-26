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
evidence: "JULIA-BACKEND-PARITY.4.2 adds julia/src/runtime/Interpreter.jl and exports LinkedSpecRuntimeEngine, runtime_parse(...), runtime_execute(...), RuntimeParseResult, RuntimeLifecycleEvent, and RuntimeInterpreterException. julia/test/runtests.jl verifies default repetition, action-edge and blind-call child dispatch, explicit call/returns, passive terminals, AND/OR modes, bounded repetition, zero-progress cutoff, lifecycle order/events, retv, accumulators, consume mode, nested output shapes, recursion cutoff, and runtime error boundaries. JULIA-BACKEND-PARITY.4.3.0 subsequently splits helper/value families, .4.3.1 adds the core scalar/array/hash store model plus captures, and .4.3.2 adds canonical string/scalar/numeric function and receiver dispatch over the same interpreter."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
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

The `.4.2` ActionIR evaluator began as a deliberately narrow dispatch surface. `.4.3.1` now extends that same
owner with the portable core scalar/array/hash store model, structural assignments/access, typed snapshots, and
entry/local capture maps and positions. String/numeric/array/hash helper breadth plus control/block/callback
families remain split across `.4.3.2` through `.4.3.6`.

`.4.3.2` has since implemented the string/scalar and numeric portion, including aliases, symbol callees, regex
flags, numeric failure boundaries, and compatible fluent chains. Array/hash/control/block/callback breadth remains
owned by `.4.3.3` through `.4.3.6`.

Related facts: [[julia-runtime-matching-state]], [[julia-compiled-spec-state]],
[[julia-runtime-core-value-capture-helpers]], [[julia-runtime-string-numeric-helpers]],
[[dart-runtime-rule-interpreter]],
[[spec-lifecycle-retv-order]], [[julia-backend-interpreter-first-plan]].

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

## September 11 complete interpreter consumer and .1.42 replay

The interpreter testset1883–2178 passes 39 assertions. It covers repeated matches
and output wrapping, action/explicit/passive calls, blind AND/OR, bounded and
zero-width repetition, lifecycle order, same-position recursion cutoff, local
resets versus inherited mutations, indexed child push forms and error boundaries.
These are representative cases; the independent recognition/callback/selector
repairs retain their original owners and startup prerequisites.

The whole .1.42 reading range is main965–2464 (1500 lines/52753 bytes). Complete
testsets906–2343 pass CLI71, parser74, resolver40, registry23, staged39, compiled41,
descriptor28, matching60, interpreter39 and core4: 419 assertions. The harness
retains original filename/line positions and helper definitions, blanks earlier
separate consumer includes and prefix testsets, ending at the last complete body.
It does not parse or execute the string/numeric testset2345–2568; that source is
only read through2464 here, including eager logical evaluation, diagnostics and
explicit exit. The initial ad-hoc command had an extra closing parenthesis and
failed before tests; the corrected command below passes unchanged source.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; source=readlines("julia/test/runtests.jl"; keep=true); source[12:136].="\n"; source[471:904].="\n"; include_string(Main, join(source[1:2343]), joinpath(pwd(),"julia/test/runtests.jl"))'
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py
bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py
```

Neutral staged governance passes 123 mutations plus public129, binding passes
11 migrations/7 executions/6 invalid selectors/8 constructors, and frozen write
vivification passes 105 rejected mutations. Runtime fixtures use repository-routed
temporary storage; this is a focused reading checkpoint, not a complete gate.

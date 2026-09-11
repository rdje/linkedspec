---
id: write-vivification-julia-runtime
title: Julia nested writes use one evaluated typed path and isolated dense publication
answers:
  - how does Julia implement nested write vivification
  - what Julia AST node owns document key position assignment
  - does Julia nested assignment create missing containers
  - how does Julia distinguish absent from bound null during nested writes
  - do Julia emitted parsers preserve nested write path expressions
  - where is the Julia write vivification regression test
date: 2026-09-03
status: current; Julia nested writes and map_leaves bang implemented; portable capability admitted under .19.7
tags: [julia, actionir, assignment, autovivification, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.5.1 replaces authored Julia key/index-tagged assignment lowering with ActionWritePathSegment plus ActionAssignNestedAccessExpr. Parser/compiler/runtime/source-emitter validation carries typed expressions and Unicode-scalar spans through native, SpecFile reconstruction, generated-plan, emitted-module, and primary-CLI routes. Runtime evaluates every segment then RHS, snapshots afterward, distinguishes absent from bound null, builds selector-determined dense harray/array state on an isolated copy, publishes once, preserves completed expression effects and original expression failures, and returns detached results. julia/test/write_vivification_contract_test.jl directly consumes the unchanged 5/7/11/16/3/3 neutral fixture and verifies malformed-carrier rejection. Julia map_leaves! and Lua/public admission remain pending."
evidence_update_2026_09_03_julia_map_leaves: "FUTURE-PARITY-BACKLOG.19.5.2 adds Julia's separate typed receiver-mutation carrier and identity-guarded copy-on-write runtime without changing nested-write semantics. The 496-assertion permanent suite composes callback-local, unrelated, same-receiver, shadow, and post-commit nested writes across native, reconstructed, generated-plan, emitted-module, and CLI routes. Both Julia mechanisms are current; Lua and portable/public admission remain pending."
evidence_update_2026_09_04_lua_map_leaves: "FUTURE-PARITY-BACKLOG.19.6.2 implements the same unchanged receiver-mutation contract in shared Lua on PUC Lua and LuaJIT. Julia behavior remains unchanged; all five backend implementations are current while portable/public admission remains pending."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include(\"julia/test/write_vivification_contract_test.jl\")' && bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py"
---

# Julia write-vivification runtime

Julia parses every authored one- or many-segment bracket assignment into one
`ActionAssignNestedAccessExpr`. Each `ActionWritePathSegment` owns its original typed
expression, source text, and half-open Unicode-scalar span; source spelling no longer
preselects harray versus array behavior.

`_assign_runtime_nested!` evaluates all segment expressions from left to right and then
the RHS exactly once. Only afterward does it read binding presence and copy the current
root. Evaluated strings select harrays, nonnegative integers select zero-based arrays,
missing containers are created only when the current or next selector determines their
kind, and arrays may replace or append at exactly `length` but may not contain invented
gap fillers. Present null and existing wrong-kind values fail rather than becoming new
containers.

Structural work mutates only the copied root. Success publishes once and returns another
copy; failure publishes no partial path while retaining ordinary segment/RHS side effects
that completed before the snapshot. Reads keep their older non-creating behavior.
Malformed typed write carriers are rejected by compiler, direct runtime, generated-plan,
and source-emission boundaries.

Related: [[write-vivification-neutral-contract]], [[terse-nested-value-path-assignment]],
[[julia-runtime-core-value-capture-helpers]], [[write-vivification-receiver-mutation-direction]],
and ADR `0036`.

## 2026-09-11 — exact publication and read-path reading

Julia .1.18 reads Interpreter7616-9115, including nested-write implementation.
Segments and RHS run before root lookup/copy; selector validation then precedes
isolated dense construction. Missing storage creates the first selected kind;
existing wrong-kind/null containers fail, and only successful construction is
published. Structured failures preserve segment index, evaluated prefix path and
authored Unicode span. Reads use separate non-creating traversal. Bare-store
publication clears older typed stores, while an existing root retains its selected
storage channel. Receiver-identity rejection remains the separate mutation guard.
The existing write consumer passes406 assertions; exact adjacent typed/diagnostic/
logical/capture proof is recorded in [[julia-runtime-cursor-boundary-helpers]].
No new nested-write failure was established and no repair is closed by reading.

## September 11 — write consumer prefix reading .1.51

Reading1–453 completes AST/syntax, success and structural-failure testsets through390.
Typed path expressions and scalar source spans match the neutral fixture; eleven
successes check exact segment/RHS event order and post-evaluation binding effects.
Sixteen structural failures check diagnostic fields, authored segment spans and
completed RHS effects. The expression-failure test392–465 is partially read and
excluded from execution; no later write test is credited by this prefix run.

At activationd9e63456a8ddf3616a8da20a54f720b410023435, classifier1674, routes81,
negative1946, binding61, variadic55 and write-prefix362 pass4179 assertions.
Neutral Unicode806/9/8/2, binding11/7/6/8, callable3/9/7 and write105 pass.
All source and previous repair owners remain unchanged; no full write, package,
canonical or other-backend execution is claimed.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/unicode_rule_label_classifier_test.jl"); include("julia/test/unicode_rule_label_routes_test.jl"); include("julia/test/unicode_rule_label_negative_isolation_test.jl"); include("julia/test/uniform_binding_contract_test.jl"); include("julia/test/variadic_user_function_contract_test.jl"); source=readlines("julia/test/write_vivification_contract_test.jl";keep=true); include_string(Main,join(source[1:390])*"\nend\n",joinpath(pwd(),"julia/test/write_vivification_contract_test.jl"))'
bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py
bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py
bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py
bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py
```

## September 11 — write consumer reading complete .1.52

Reading454–659 reaches EOF. Injected expression failures preserve exact exception
identity and stop later effects; reads remain noncreating. The detachment fixture
mutates actual initial/RHS/binding/result paths, while fresh function calls distinguish
absence from bound null. Malformed typed states reject through validation, engine,
emission and plan boundaries. Reconstructed/native/generated-plan/CLI results and
a freshly included emitted module agree; this emitted route is an isolated module
in the same process, distinct from the separate offline-host emitter suite.

At activationddf175b01553f886102d4e6eeff2f6759a22e52c, complete write406,
dormant progressive authority210 and admitted carrier62 pass678 assertions.
Neutral write105, progressive116/public60 and typed14/0/231 pass. Separate
parent-state diagnostic evidence belongs to [[julia-progressive-parent-state-test-gap]].
No whole package, canonical or other-backend execution is claimed. All95 Julia
files are read; independent .3 closeout and remaining startup prerequisites follow.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/write_vivification_contract_test.jl"); include("julia/test_dormant/progressive_span_dispatch_authority_test.jl"); include("julia/test/progressive_span_dispatch_contract_test.jl")'
bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py
bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
```

---
id: julia-array-transform-result-guards
title: Julia ordinary Array-transform results retain guards and initial producer policies
answers:
  - "why does Julia take result set_key run its operands"
  - "which Julia dispatcher guards take take_last drop_front drop_back slice sorted reversed concat_arrays results"
  - "what are Julia initial Array-transform Number null Hash and optional arity policies"
  - "do Julia sorted and reversed extra operands have the same effects as Dart"
  - "how are Julia Array-transform needed source count start and concat errors preserved"
  - "does the Julia Array-transform proof bind older direct-test fixtures"
date: 2026-11-10
status: Julia78.4 bounded guards focused-checked; Dart input qualification4.20 then independent Lua remain
tags: [julia, array, transform, results, guards, source, arity, inputs]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.78.4; docs/checkpoints/array-transform-result-guard-julia-2026-11-10/REVIEW.md retains unchanged37 plus119 own controls,19 original failures/137 healthy;827PASS76FAIL then903PASS; direct1728, private exact19RED/156PASS,123 full profiles/156 byte-equal pairs, first readonly0/empty stderr/nine corruptions and actual direct-input identity PASS."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-result-guard-julia-2026-11-10/review.py"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; for path in ARGS; include(path); end' julia/test/array_transform_result_guard_composition_test.jl julia/test/with_hash_results_test.jl julia/test/hash_value_result_guard_composition_test.jl julia/test/hash_view_result_guard_composition_test.jl julia/test/constructor_result_composition_test.jl"
---

At clean0c4738c4, independent156/four-route observations expose19 guard gaps:
sixteen free/receiver Arrays reach set_key and evaluate KV; three later tails run
KVW/KVDW. Constructor rejection already works. _evaluate_runtime_fluent_chain!
retained-kind classification omits these transform roles before the persistent
actual-kind consumer guard. Canonical positional eight-transform free results/
receiver prefixes now own continuations, with one initial-source permission that
excludes earlier retained/constructor/copy/size/view/Hash/Array-result owners.

Only existing take/take_last/drop_front/drop_back source[,n], slice source/start[,n],
sorted/reversed free-one/receiver-zero and concat_arrays free-two/receiver-one
qualify. Existing single compiled contextual with operand remains supported;
explicit deferred literals, other callbacks, aliases, unknown/keyword/traversal/
non-with trailing and unassessed function-receiver contexts gain no authority.
Source adds70 lines and the normal runner one include; entire producer bodies,
scalar_result initialization/guard/assignments and enumerate/call_index mutation
policy remain unchanged. Emitted/parsed format stays unchanged.

Before production,119 own controls acquire72 initial Number/null/Hash profiles,
ten optional forms, sixteen excluded extras, six earlier owners and fifteen
additional needed-source/operand errors. Seven source families yield empty
Array/count0W; concat_arrays keeps the source as an element/count2W. All sixteen
extras keep SAKW, including free sorted/reversed, unlike Dart's skipped extra A.
Optional defaults and earlier-owner skips/effects stay exact. All nineteen needed
errors retain complete native/restored diagnostics and generated-plan/fresh framing.
These finite fences establish no portable wrong-kind or arity policy.

Normal903 and selected direct1728 pass. Every137 healthy observation/123 profile
and156 actual parsed/emitted pairs stay exact across six epochs. Same-path private
old/current SDKs with compiled modules disabled and actual module path checked
reproduce19RED/156PASS with full original/repaired frames. First readonly recovery
returns0/empty stderr and rejects nine corruptions, including missing direct-input
binding. Every declared current direct input matches its actual captured identity.
Actual executable version bytes agree across epochs; manifest creation version
is not used. First repaired package stderr records successful precompilation;
selected direct/current-private stderr is empty. Nothing is suppressed.

Own source/grammar/instruments and complete selected fixture closure precede SDK
use; actual emitted/parsed files precede fresh execution. Full native/cache/
transitive/toolchain custody4.2/SESSION5, isolation, source/context/registration
and full23.4 remain separate. Rebuild Julia applications/runtime. Prospective
closure review discovers the prior Dart additional-direct binding gap; P1
23.4.20 owns its qualification after this clean leaf, before independent Lua78.5.
Related: [[array-transform-result-guard-selection]], [[julia-hash-value-result-guards]],
[[dart-array-transform-result-guards]].

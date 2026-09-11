---
id: julia-runtime-array-helpers
title: Julia runtime executes copied array pipelines and updated-value end mutations
answers:
  - does Julia runtime support array receiver chains
  - does Julia runtime support sorted drop_front first
  - does Julia runtime support split_each trim_each filter_nonempty
  - does Julia runtime support delimiter first join_values
  - does Julia runtime support flat_array and concat_arrays
  - does Julia array constructor splice flat_array results
  - does Julia runtime support numeric reducers on array receivers
  - does Julia runtime support split array target replacement
  - does Julia runtime support push_back and pop_front statements
  - do Julia value position array end mutations avoid mutation
date: 2026-07-10
status: current
tags: [julia, runtime, helpers, array, receiver-chains, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.3.3 adds copied array pipelines and originally locks statement-only end mutations. Later FUTURE-PARITY-BACKLOG.12.1.5 supersedes that result boundary under linkedspec-uniform-binding-v1: named/scalar-held array-end mutations return independent updated arrays and may feed receiver continuations. Current native/generated uniform-binding tests cover the adopted behavior."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia array helper execution lives in `julia/src/runtime/Interpreter.jl`.

Array function calls and receiver methods share a copied-value dispatcher for
count/select/order/membership, take/drop/slice, string transforms and filters,
stable uniqueness, regex filtering, split-and-flatten pipelines, delimiter-first
joining, one-level flatten/concatenation, and tagged record construction. Array
numeric receiver terminals reuse the canonical numeric reducer implementation.

`array(...)` splices only values explicitly produced by `flat(...)` or
`flat_array(...)`; ordinary arrays and `copy(array(...))` stay nested. Pure
helpers never mutate their source snapshots. The original July example used
`split(array(target), source, delimiter)`; uniform-binding adoption supersedes that
selector form. Current replacement uses `split(target, source, delimiter)` with
a bare target name and preserves empty split fields.

The destructive end methods mutate named typed storage or a scalar-held array and return an independent updated
array. Pop discards the removed element rather than returning it. A continuation such as `.count()` consumes the
updated array, while an unused result is silently dropped.

Related facts: [[julia-runtime-hash-helpers]], [[julia-runtime-string-numeric-helpers]],
[[julia-runtime-core-value-capture-helpers]], [[dart-runtime-array-helpers]],
[[terse-array-receiver-value-chains]], [[terse-array-end-mutation-methods]],
[[array-helper-return-shape-caveats]].

## 2026-09-11 — exact helper reading and boundary qualification

Julia .1.17 reads Interpreter6116-7615. Array-end mutation validates the target
before evaluating operands and returns an independent updated array. Split validates
its bare target before source/delimiter evaluation and replaces the named binding.
Pure aggregate operations retain copied inputs and explicit one-level splicing.
Statement writeback remains implemented for trim_each/filter_nonempty/lower_each/
upper_each; the source marks split_each/filter_match/uniq_each writeback pending.

Passing bounded examples does not establish all count arithmetic:
[[julia-large-number-and-slice-boundaries]] confirms drop_front overflow and wrong
array/string slices at a large valid count. Julia .2.10 owns that repair; this is
separate from scalar numeric magnitude preservation under .2.9.

Exact selected-suite replay (585 assertions plus one selection equality):

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_READING17'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT = pwd()
const CORPUS_ROOT = joinpath(REPO_ROOT, "tests", "corpus")
const selected = Set(["Neutral scalar-to-text contract", "Neutral scalar numeric contract", "Runtime string scalar and numeric helpers", "Runtime array helpers and mutations", "Runtime hash helpers and mutations", "Runtime hash and array tree traversal callbacks"])
const seen = Set{String}()
for expression in Meta.parseall(read("julia/test/runtests.jl", String)).args
    expression isa Expr || continue
    if expression.head == :function
        Core.eval(Main, expression)
    elseif expression.head == :macrocall && expression.args[1] == Symbol("@testset") && expression.args[3] in selected
        Core.eval(Main, expression)
        push!(seen, expression.args[3])
    end
end
@test seen == selected
include("julia/test/uniform_binding_contract_test.jl")
include("julia/test/map_leaves_mutation_contract_test.jl")
JULIA_READING17
bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py
bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py
```

## September 11 complete aggregate consumers and .1.43 replay

Array2570–2663 and harray2665–2733 pass two and one aggregate assertions. They
preserve copied pipelines, explicit flatten splicing, empty split fields and
updated array-end mutation results. Harray statement set_key mutates its binding;
value and receiver set_key return copies; explicit index assignment publishes
an updated root. These intentionally different outcomes are checked together.

The exact main reading range2465–3964 is1500 lines/47116 bytes. Sixteen complete
testsets2345–3938 pass138 assertions: string14, array2, harray1, pure1, position1,
zero-width1, marker1, captures2, marks3, controls6, functions9, tree2, cursor17,
diagnostics7, native trace43 and frontend trace28. Fixtures named exhaustive are
fixed governed examples, not exhaustive tests of all input values or magnitudes.
Spec-parser3940–4119 is only read through3964 and excluded from this replay.

The in-memory harness preserves source filename and line numbers, skips separate
consumer includes and earlier main testsets, and uses existing helpers only.
All temporary fixtures follow repository-routed storage. No complete component
gate, other runtime execution or repair closure is claimed.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; source=readlines("julia/test/runtests.jl"; keep=true); source[12:136].="\n"; source[471:2343].="\n"; include_string(Main, join(source[1:3938]), joinpath(pwd(),"julia/test/runtests.jl"))'
bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py
bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py
```

Neutral scalar55 cases/18 helpers, binding11/7/6/8, typed14 complete/0 pending
and231 drift controls, and logical8 complete/0 pending/26 drift controls pass.

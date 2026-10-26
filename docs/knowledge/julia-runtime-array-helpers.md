---
id: julia-runtime-array-helpers
title: Julia array helpers and standalone transform writeback
answers:
  - why do Julia has_key results require scalar guarding before container methods
  - why do Julia direct default scalar results reject container consumers
  - how do Julia aggregate results retain scalar boundaries after named array mutations
  - why does Julia count reject nonarrays and extra receiver arguments
  - can Julia first and last continue through selected scalar and container methods
  - which task owns Julia receiver copy arity validation
  - do Julia standalone split_each filter_match and uniq update arrays
  - does Julia runtime support array receiver chains
  - does Julia runtime support sorted drop_front first
  - does Julia runtime support split_each trim_each filter_nonempty
  - does Julia runtime support delimiter first join_values and joined String continuations
  - does Julia runtime support flat_array and concat_arrays
  - does Julia array constructor splice flat_array results
  - does Julia runtime support numeric reducers on array receivers
  - does Julia runtime support split array target replacement
  - does Julia runtime support push_back and pop_front statements
  - do Julia value position array end mutations avoid mutation
date: 2026-10-26
status: bounded value/default/index/has_key guards; full admission open
tags: [julia, runtime, helpers, array, receiver-chains, JULIA-BACKEND-PARITY]
evidence: "Array4.3.3/end12.1.5/transform5.3.3; selected/copy/count/aggregate/join23.3 focused fixtures."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/has_key_result_receivers_test.jl\"); include(\"julia/test/index_result_receivers_test.jl\")'"
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
At that reading only four transforms rebound. 5.3.3 adds split_each/filter_match/uniq:
validate target, copy operands left-to-right, dispatch pure helpers and store.
Native/generated-plan/fresh-emitted checks cover type/copy, absent/wrong-kind and
once-only operands. Pure forms stay unchanged; broad5.3.4 is deferred.

Passing bounded examples does not establish all count arithmetic:
[[julia-large-number-and-slice-boundaries]] confirms drop_front overflow and wrong
array/string slices at a large valid count. Julia .2.10 owns that repair; this is
separate from scalar numeric magnitude preservation under .2.9.

Historical September11 reading/replay chronology, exact commands, source ranges and assertion totals remain byte-recoverable in this file at Git bdeae4121aaad3659f5c117e08f66e1dc3cdb931. Those broad historical replays are not startup or ordinary-feature commands; use the current focused reverify above.

23.3 ordinary guards retain AbstractVector Count; join/index/has_key take one operand. Defaults/index/has_key stay scalar until actual AbstractVector/AbstractDict output.23.3.8.4 retains correct flow/K/SK/SKA, fixing container[], missing0!/extra1! and four effects; strict native/plan/fresh/direct index plus compilation pass. Integer0/1 presence/source/copy unchanged; full admission open.

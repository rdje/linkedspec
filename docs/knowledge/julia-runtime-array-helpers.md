---
id: julia-runtime-array-helpers
title: Julia array helpers and standalone transform writeback
answers:
  - why do Julia emptiness results need scalar guards while allowing repeated predicates
  - why do Julia has_key results require scalar guarding before container methods
  - why do Julia direct default scalar results reject container consumers
  - how do Julia aggregate results retain scalar boundaries after named array mutations
  - why does Julia count reject nonarrays and extra receiver arguments
  - can Julia first and last continue through selected scalar and container methods
  - which task owns Julia receiver copy arity validation
  - why do Julia copied Numbers and containers run incompatible operands
  - how does Julia preserve copied result kinds through fluent bridges
  - do Julia standalone split_each filter_match and uniq update arrays
  - does Julia split_tagged_records accept String helper results and preserve typed fields
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
date: 2026-10-27
status: bounded value/predicate guards; full admission open
tags: [julia, runtime, helpers, array, receiver-chains, JULIA-BACKEND-PARITY]
evidence: "TYPE22.4 separates tagged-record String input from Array output and preflights min-two operands with strict native/plan/fresh controls. Array4.3.3/end12.1.5/transform5.3.3; selected/copy/count/aggregate/join23.3 focused fixtures."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/emptiness_result_receivers_test.jl\"); include(\"julia/test/has_key_result_receivers_test.jl\"); include(\"julia/test/tagged_record_receivers_test.jl\")'"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test;include(\"julia/test/value_copy_test.jl\");include(\"julia/test/receiver_copy_arity_test.jl\");include(\"julia/test/logical_receiver_methods_test.jl\");include(\"julia/test/selected_value_receivers_test.jl\")'"
---

Julia array helper execution lives in `julia/src/runtime/Interpreter.jl`.

Array function calls and receiver methods share a copied-value dispatcher for
count/select/order/membership, take/drop/slice, string transforms and filters,
stable uniqueness, regex filtering, split-and-flatten pipelines, delimiter-first
joining, one-level flatten/concatenation, and tagged record construction. Array
numeric receiver methods reuse the canonical numeric reducer implementation.

Tagged records consume text and return record Arrays. TYPE22.4 keeps dispatcher
membership separate from actual Array-input guards, enabling prior String results
such as trim, and requires delimiter/tag before receiver/operand effects. Existing
producer/pattern/conversion/copy/free short-call behavior is retained. The registered
julia/test/tagged_record_receivers_test.jl passes51 strict native/plan/fresh assertions;
full split-domain/context admission remains with SESSION33.

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

23.3 guards retain AbstractVector Count; join/index/has_key/contains take one operand, emptiness zero. Defaults/index/has_key/contains/emptiness stay scalar until actual AbstractVector/AbstractDict output; generic emptiness consumers stay allowed.23.3.9.4 retains Bool flow/source/copy/1!/SA, fixing container[]/bad1!/0!/four effects; strict native/plan/fresh/direct has_key and compilation pass. Full admission open.

October27 ADR0138 copy rollout4.2.2.4 preserves already-healthy primitive
producers and recursive copies. Native/plan/fresh-source shared intake returns
null/0/SRKV and wrong-container[]/[1]/AKV; shape/legacy controls pass. The fluent
chain initializes copied_result for a direct free-copy receiver and retains it
after copy links. Existing reduction-kind guarding now also checks copied results
before incompatible Array/Hash operands, retaining scalar/default/container
bridges. No other receiver/producer policy is normalized. value_copy_test.jl
uses recursive strict kind comparison (Bool identity; Number excludes Bool),
passes12 assertions from6 RED/6 controls and is registered in runtests.jl.
Direct receiver arity/logical/selected tests yield127 focused assertions total,
including original source errors and Bool-copy compatibility; strict compilation
passes. No old expectation, helper/deferred vocabulary, depth, callable/context
or serialized format change; full admission remains separate and safe Lua5 follows.

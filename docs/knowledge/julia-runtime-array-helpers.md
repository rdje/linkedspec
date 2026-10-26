---
id: julia-runtime-array-helpers
title: Julia array helpers and standalone transform writeback
answers:
  - can Julia first and last continue through selected scalar and container methods
  - which task owns Julia receiver copy arity validation
  - do Julia standalone split_each filter_match and uniq update arrays
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
date: 2026-10-26
status: selected values confirmed; extraction arity guarded; broad checks deferred
tags: [julia, runtime, helpers, array, receiver-chains, JULIA-BACKEND-PARITY]
evidence: "Julia array4.3.3/end results12.1.5; statement repair5.3.3; selected-value23.3.1.4."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/selected_value_receivers_test.jl\")'"
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

23.3.1.4 confirms existing per-value first/last scalar/container/copy dispatch and adds a pre-effect extraction arity guard. Native/generated-plan/fresh-emitted focused controls cover function/computed sources, repeated transitions, snapshots, empty values, min/max and once-only effects; direct transform checks pass. Full fluent admission and other helper boundaries remain open.

A source-only copy-arity risk is owned by TYPE-REFERENCE-BOOK.1.2.23.3.2: the copy value-call branch does not inspect extra arguments. Its public reproduction/repair is scheduled after the native journey rollout and P1 Rust scalar work; no runtime defect result is claimed yet.

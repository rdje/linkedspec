---
id: julia-runtime-array-helpers
title: Julia runtime executes copied array pipelines and statement-only end mutations
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
evidence: "JULIA-BACKEND-PARITY.4.3.3 extends julia/src/runtime/Interpreter.jl with a copied array helper dispatcher, array receiver chains, delimiter-first joins, string/regex split and filter bridges, flat_array/concat_arrays and explicit constructor splicing, numeric reducer terminals, split(array(target), ...) replacement, tagged records, and statement-only named/scalar-held push/pop end mutations. Two focused end-to-end cases in julia/test/runtests.jl and the full 558-assertion Pkg.test() run prove pure source snapshots and value-position mutation no-ops."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia array helper execution lives in `julia/src/runtime/Interpreter.jl`.

Array function calls and receiver methods share a copied-value dispatcher for
count/select/order/membership, take/drop/slice, string transforms and filters,
stable uniqueness, regex filtering, split-and-flatten pipelines, delimiter-first
joining, one-level flatten/concatenation, and tagged record construction. Array
numeric receiver terminals reuse the canonical numeric reducer implementation.

`array(...)` splices only values explicitly produced by `flat(...)` or
`flat_array(...)`; ordinary arrays and `copy(array(...))` stay nested. Pure
helpers never mutate their source snapshots. `split(array(target), source,
delimiter)` is the explicit replacement form and preserves empty split fields.

The destructive end methods remain statement-only. A single statement
`items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, or
`items.pop_front()` mutates named typed storage or a scalar-held array. The same
method in a value position returns `nothing` without mutation, preserving the
portable method-family boundary.

Related facts: [[julia-runtime-hash-helpers]], [[julia-runtime-string-numeric-helpers]],
[[julia-runtime-core-value-capture-helpers]], [[dart-runtime-array-helpers]],
[[terse-array-receiver-value-chains]], [[terse-array-end-mutation-methods]],
[[array-helper-return-shape-caveats]].

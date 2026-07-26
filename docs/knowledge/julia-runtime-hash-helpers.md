---
id: julia-runtime-hash-helpers
title: Julia runtime executes copied hash helpers with explicit mutation and splice boundaries
answers:
  - does Julia runtime support hash receiver chains
  - does Julia runtime support sorted_keys and sorted_values
  - does Julia runtime support merge_hash pick_keys and drop_keys
  - does Julia runtime support rename_key and set_key
  - does Julia statement set_key mutate named hashes
  - do Julia value position set_key calls avoid source mutation
  - how does Julia merge_hash resolve a bare base and overlays
  - does Julia hash constructor splice flat_hash results
  - do ordinary nested Julia hash values remain nested
date: 2026-07-13
status: current
tags: [julia, runtime, helpers, hash, receiver-chains, mutation, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.3.4 extends julia/src/runtime/Interpreter.jl with copied hash helper and receiver dispatch, typed statement-only set_key mutation, base/overlay-aware merge_hash evaluation, direct hash-index assignment integration, and explicit flat/flat_hash constructor splicing. One end-to-end case in julia/test/runtests.jl proves views, pure transformations, source immutability, direct mutation, bare base/overlay merge behavior, explicit splicing, and ordinary nested-map preservation. FUTURE-PARITY-BACKLOG.12.1 later made bare typed bindings canonical and rejected exact aggregate selectors."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()' && bash tools/run_julia_project_data.sh --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --case terse_2_3_4_deep_pure_helper_composition"
---

Julia hash helper execution lives in `julia/src/runtime/Interpreter.jl`.

Function calls and receiver methods share copied-value behavior for key counts,
sorted key/value views, membership, merge, pick/drop, rename, pure set-key, and
flat-hash operations. Compatible receiver chains can continue from hash views
into array helpers without exposing mutable storage.

A single statement `set_key(target, key, value)` mutates named typed hash
storage. Function and receiver value forms return changed copies and do not
mutate the source. Direct `target[key] = value` remains expression-valued and
uses the checked assignment path established by `.4.3.1`.

`merge_hash(base, overlay)` consumes both bare typed harrays and later arguments
override earlier keys. `merge_hash(copy(base), overlay)` is the equivalent
explicit-copy spelling. Exact `hash(base)` is a removed selector and rejects
before execution. Multi-argument `hash(...)` construction splices a map only
when its argument is structurally marked by `flat(...)` or `flat_hash(...)`;
ordinary map values remain nested.

Related facts: [[julia-runtime-value-control-tree-helpers]], [[julia-runtime-array-helpers]],
[[julia-runtime-core-value-capture-helpers]], [[dart-runtime-hash-helpers]],
[[terse-hash-receiver-value-chains]], [[hash-helper-return-shape-caveats]],
[[terse-statement-separator-contract]].

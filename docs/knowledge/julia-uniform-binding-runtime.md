---
id: julia-uniform-binding-runtime
title: "Julia bare mutations use one typed binding on native and generated execution"
answers:
  - "does Julia support selector free push split and hash mutation"
  - "what does Julia set return for method chaining"
  - "how does Julia report a wrong kind bare mutation"
  - "does a saved Julia mutation result change after a later mutation"
  - "how does Julia distinguish push rule dispatch from binding mutation"
  - "are array name and hash name rejected on Julia yet"
date: 2026-07-12
status: current
tags: [julia, language, bindings, array, harray, mutation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.5 centralizes Julia bare typed assignment and kind-checked array/harray mutation in julia/src/runtime/Interpreter.jl. Native/generated proof covers the future fixture, seven neutral cases, collection rebinding, mutation continuation, static precedence, and wrong-kind fields. The complete gate passes 1,311 package assertions, CLI 61x2, 105 corpus fixtures, and canonical Phase 0 1..1030."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include(\"julia/test/uniform_binding_contract_test.jl\")' && LINKEDSPEC_JULIA_CMD=/opt/homebrew/bin/julia LINKEDSPEC_JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot bash tools/run_julia_local.sh"
---

# Julia uniform binding runtime

Julia now consumes `linkedspec-uniform-binding-v1` through the same `LinkedSpecRuntimeEngine` on native and
generated execution. `_read_runtime_store` remains the public read model across the runtime's private
`variables`/`arrays`/`hashes` migration maps; those maps do not define separate `.spec` namespaces.

Bare assignment, `set`, push/append, mutable split, hash-index and set-key mutation, array-end methods, and
standalone collection transforms validate and update that current value. An absent mutation target starts as the
required empty array or harray. An incompatible existing value throws `binding_kind_mismatch` with stable
identifier, expected-kind, and actual-kind fields. Mutation results are independent post-operation copies, and an
array-end update can continue into methods such as `.count()`.

Static compiled rules retain precedence for ambiguous `push(name, target)` calls. Otherwise the first bare name is
the array binding. Native and generated execution pass the same permanent contract.

The complete package gate exposed two historical namespace locks. Value-position `push_back` expected no mutation,
and `merge_hash(meta, overlay)` expected only the overlay after wrapper and bare hash mutations mixed stores. Both
now assert the adopted updated-value and single-binding behavior.

Exact `array(name)` and `hash(name)` remain parsed only while tracked sources migrate; Lua now supports the bare
replacements. Julia rejects and deletes those selector paths in `FUTURE-PARITY-BACKLOG.12.1.8.4`.

Related facts: [[uniform-binding-neutral-contract]], [[perl-uniform-binding-runtime]],
[[rust-uniform-binding-runtime]], [[dart-uniform-binding-runtime]],
[[julia-runtime-core-value-capture-helpers]], [[spec-facing-aggregate-selector-retirement-inventory]].

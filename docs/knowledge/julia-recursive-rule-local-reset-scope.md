---
id: julia-recursive-rule-local-reset-scope
title: Julia scopes explicit aggregate resets per recursive rule invocation
answers:
  - why did Julia recursive sexpr leak child values into parent accumulators
  - does Julia set array reset stay local to a rule invocation
  - does Julia set hash reset stay local to a rule invocation
  - do Julia undeclared child mutations remain caller visible
  - how did Julia close the recursive top rule corpus fixtures
  - what does JULIA-BACKEND-PARITY.6.2.4.3 prove
date: 2026-07-10
status: current
tags: [julia, runtime, recursion, rule-scope, stores, corpus, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.4.3 traces Julia's recursive sexpr frames and proves each I-block set(array(items), []) overwrote one shared typed-store binding. _RuntimeExecutionContext now carries a first-write snapshot map per _execute_runtime_rule! invocation. Explicit set(array(name), ...), set(hash(name), ...), and split(array(name), source, delimiter) replacement capture prior scalar/array/hash representations and restore them on rule exit. Ordinary undeclared push/append mutations remain caller-visible; active registered user functions skip this tracker because they already swap whole stores. Focused array/hash reset and shared-mutation tests pass; all three recursive top-rule fixtures pass; full Pkg.test() passes with 785 assertions; the shipped-smoke window is 21/31; status is runtime-corpus-recursive-rule-scope."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()' && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --case top_rule_body_recursion_sexpr --case top_rule_lx_recursion_nested --case top_rule_lx_recursion_sequence"
---

Julia already isolated entry/local match registers for every rule call, but its scalar, array, and hash stores were
shared for the whole parse. A recursive `I { set(array(items), []) }` therefore replaced its caller's `items`
binding. The deepest frame leaked back outward, which made the checked body-recursive value start at `"b"` and
made top-rule LX results duplicate child payloads.

The runtime now creates a binding-snapshot map for each rule invocation. On the first explicit aggregate reset of a
name, it records every existing scalar/array/hash representation. Rule exit removes the local value and restores
the caller snapshot. The reset seam includes explicit array/hash `set(...)` and explicit array-target `split(...)`
replacement.

The boundary is intentionally narrow:

- ordinary undeclared `push(...)` and append mutations stay caller-visible;
- repeated resets in one rule use the first snapshot;
- recursive children get independent scopes;
- registered user functions do not record rule-local snapshots because their established execution path already
  swaps and restores the complete typed stores.

This closes `top_rule_body_recursion_sexpr`, `top_rule_lx_recursion_nested`, and
`top_rule_lx_recursion_sequence` without changing their sources or oracle outputs.

Related facts: [[dart-recursive-dispatch-rule-local-scope]], [[rust-declare-type-token-rule-scope]],
[[top-rule-recursion-forward-progress-guard]], [[julia-shipped-corpus-smoke-split]].

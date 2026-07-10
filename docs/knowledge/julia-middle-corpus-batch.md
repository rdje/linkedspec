---
id: julia-middle-corpus-batch
title: Julia middle non-function corpus batch passes 25 fixtures unchanged
answers:
  - does Julia pass the middle helper corpus batch
  - which Julia corpus fixtures are proven green after the starter batch
  - which Julia middle corpus fixtures are routed to the function shell
  - what are the Julia middle corpus execution windows
  - what is the Julia corpus status after JULIA-BACKEND-PARITY.6.2.3
  - what is JULIA-BACKEND-PARITY.6.2.3
date: 2026-07-10
status: current
tags: [julia, corpus, parity, regression, functions, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.3 runs offsets/limits 40/17, 58/2, and 62/6 for 25 passed / 0 failed without source or fixture changes. julia/test/runtests.jl permanently locks the three windows and exact function routes with six assertions; full Pkg.test() passes with 757 assertions and package status runtime-corpus-middle."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia passes the 25 non-function manifest fixtures surrounding offsets 40 through 67 unchanged. Bounded runner
windows `40/17`, `58/2`, and `62/6` report 17/17, 2/2, and 6/6, for 25 passes and zero failures.

These windows cover attached while, deep helper composition, bare aggregate arguments, inline if/switch values,
bare values and case labels, array/hash/string/number receiver chains, numeric reducers, word/symbol arithmetic and
comparison aliases, aggregate and mutation assignment expressions, block-valued receiver chains, helper and
receiver `with` blocks, hash/array tree traversal, and quoted typed-wrapper names.

No Julia parser/runtime correction and no corpus fixture change was required. The permanent `Middle non-function
corpus batch` test locks all three window sizes and endpoints, 25 selected results, 25 passes, the empty failure
ledger, and exact routed names. Full Julia tests pass with 757 assertions and status `runtime-corpus-middle`.

Manifest offsets 57, 60, and 61 are intentionally excluded:

- `terse_3_3_1_scalar_assignment_expressions`
- `terse_3_3_4_assignment_expression_closure`
- `terse_4_3_2_user_function_runtime`

They contain top-level `fn` source and remain owned by `.6.2.5`. This is not a full corpus claim: `.6.2.4.0` has
since measured shipped-spec/parser-smoke fixtures 68–98 at 10/31 and split their failure families.

Related facts: [[julia-shipped-corpus-smoke-split]], [[julia-starter-corpus-batch]], [[julia-corpus-selection-reporting]],
[[julia-controlled-corpus-execution]], [[dart-middle-corpus-batch]], [[rust-perl-output-oracle]],
[[statement-separator-semantics]].

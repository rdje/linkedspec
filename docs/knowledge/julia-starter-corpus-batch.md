---
id: julia-starter-corpus-batch
title: Julia starter corpus batch passes the first 40 manifest fixtures unchanged
answers:
  - does Julia pass the first 40 corpus fixtures
  - which Julia corpus fixtures are proven green
  - what does the Julia starter corpus batch cover
  - what is the Julia corpus status after JULIA-BACKEND-PARITY.6.2.2
  - what is JULIA-BACKEND-PARITY.6.2.2
date: 2026-07-10
status: current
tags: [julia, corpus, parity, regression, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.2 runs julia/bin/corpus_runner.jl with --offset 0 --limit 40 and records 40 passed / 0 failed. julia/test/runtests.jl permanently locks the window with six assertions; full Pkg.test() passes with 751 assertions and package status runtime-corpus-starter."
reverify: "bash tools/run_julia_project_data.sh --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 0 --limit 40"
---

Julia passes manifest offsets 0 through 39 unchanged. The bounded runner starts at
`proof_edge_array_literal`, ends at `terse_2_2_5_2_attached_switch_blocks`, reports 40 passes and zero failures,
and exits `0`.

This window covers proof-edge scalar/array returns, declared and undeclared autoexist behavior, bare reads and
copy/wrapper behavior, return/assignment/mutation reads, shape literals, duck-typed replacement, nested mixed-path
assignment, core set/cat/copy/push/set-key/operator forms, primitive booleans/null, call spacing, newline statement
separation, direct nested access, array-end mutations, expression-valued blocks and early returns, attached
if/when/otherwise, and attached switch.

No parser/runtime correction and no corpus fixture change was required. A permanent `Starter corpus batch` test
locks the 99-case manifest count, exact endpoints, 40 selected results, 40 passes, and empty failure ledger. Full
Julia tests pass with 751 assertions and status `runtime-corpus-starter`.

This is not a full corpus claim. `.6.2.3` has since proven the surrounding non-function middle windows green at
25/25, `.6.2.4` has closed shipped-spec/parser-smoke fixtures 68–98 at 31/31, and `.6.2.5` has closed all three
top-level function fixtures through the spec-defined shell. `.6.3` has since closed the aggregate gate at 99/99.

Related facts: [[julia-spec-driven-function-shell-parser]], [[julia-middle-corpus-batch]], [[julia-corpus-selection-reporting]], [[julia-controlled-corpus-execution]],
[[dart-starter-corpus-batch]], [[rust-perl-output-oracle]], [[statement-separator-semantics]].

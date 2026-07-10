---
id: julia-full-corpus-gate
title: Julia executes the complete validated corpus at 99 of 99
answers:
  - does Julia pass the full LinkedSpec corpus
  - is Julia corpus parity 99 of 99
  - can the Julia CLI execute the full corpus without selectors
  - what does runtime-corpus-full mean
  - what is the permanent Julia full corpus gate
  - what is JULIA-BACKEND-PARITY.6.3
date: 2026-07-10
status: current
tags: [julia, corpus, parity, cli, manifest, regression, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.3 adds an eight-assertion complete-corpus regression in julia/test/runtests.jl and enables unbounded CLI execution in julia/src/corpus/CorpusManifest.jl. Direct CLI execution reports 99 passed / 0 failed; full Julia tests pass with 840 assertions and status runtime-corpus-full."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute"
---

`JULIA-BACKEND-PARITY.6.3` is the aggregate interpreter-first Julia corpus gate. The permanent test calls
`execute_corpus_fixtures(...)` without selectors, so complete manifest validation precedes one ordered execution of
all 99 fixtures. It locks manifest format `1`, manifest/result count `99`, exact result-name order, stable first and
last fixtures, 99 passes, an empty failure ledger, and exact checked-in expected output for every result.

The Julia corpus CLI now treats bare `--execute` as a full-manifest run. Repeated `--case`, zero-based `--offset`,
and optional positive `--limit` remain diagnostic selectors; offset-only execution runs through the manifest end.
Omitting `--execute` still performs validation only. Every selected run validates the complete manifest before
selection, so a subset cannot hide manifest drift.

Exit `0` means every executed fixture passed, exit `1` means at least one fixture failed, and exit `2` remains
reserved for argument, selection, or manifest validation errors. Existing regressions reject unsupported manifest
format, count mismatch, invalid/duplicate names, missing/stale fixture directories, missing files, malformed JSON,
and output mismatches.

The direct complete CLI run reports 99 passed and 0 failed. Full Julia tests pass with 840 assertions, and
package/CLI status is `runtime-corpus-full`.

Related facts: [[julia-corpus-manifest-io]], [[julia-corpus-selection-reporting]],
[[julia-controlled-corpus-execution]], [[julia-spec-driven-function-shell-parser]],
[[dart-scoped-parity-milestone-complete]], [[rust-perl-output-oracle]].

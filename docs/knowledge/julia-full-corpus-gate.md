---
id: julia-full-corpus-gate
title: Julia complete validated corpus gate and historical 99-case admission
answers:
  - does Julia pass the full LinkedSpec corpus
  - is Julia corpus parity 99 of 99
  - can the Julia CLI execute the full corpus without selectors
  - what does runtime-corpus-full mean
  - what is the permanent Julia full corpus gate
  - what is JULIA-BACKEND-PARITY.6.3
date: 2026-07-10
status: accepted; numeric admission evidence is historical
tags: [julia, corpus, parity, cli, manifest, regression, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.3 adds the complete-corpus regression and unbounded runner execution. JULIA-BACKEND-PARITY.7.3.2.4 re-runs the focused gate: corpus reports 99/0 and the suite passes with 1,017 assertions."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute"
---

`JULIA-BACKEND-PARITY.6.3` is the aggregate interpreter-first Julia corpus gate. The permanent test calls
`execute_corpus_fixtures(...)` without selectors, so complete manifest validation precedes one ordered execution of
the full fixture set. At the July admission it locked manifest format `1`, manifest/result count `99`, exact result-name order, stable first and
last fixtures, 99 passes, an empty failure ledger, and exact checked-in expected output for every result.

The Julia corpus CLI now treats bare `--execute` as a full-manifest run. Repeated `--case`, zero-based `--offset`,
and optional positive `--limit` remain diagnostic selectors; offset-only execution runs through the manifest end.
Omitting `--execute` still performs validation only. Every selected run validates the complete manifest before
selection, so a subset cannot hide manifest drift.

Exit `0` means every executed fixture passed, exit `1` means at least one fixture failed, and exit `2` remains
reserved for argument, selection, or manifest validation errors. Existing regressions reject unsupported manifest
format, count mismatch, invalid/duplicate names, missing/stale fixture directories, missing files, malformed JSON,
and output mismatches.

At that July boundary the direct complete corpus-runner CLI reported 99 passed and 0 failed; full Julia tests passed with 1,019
assertions. `runtime-corpus-full` names the historical interpreter-only boundary; current package/CLI status is
`runtime-corpus-primary-cli` after the separate direct-process gate.

Related facts: [[julia-local-verification-gate]], [[julia-corpus-manifest-io]], [[julia-corpus-selection-reporting]],
[[julia-controlled-corpus-execution]], [[julia-spec-driven-function-shell-parser]],
[[dart-scoped-parity-milestone-complete]], [[rust-perl-output-oracle]].
See also [[julia-primary-cli-process-conformance]].

The September 11 reading intake revalidates the current 105-fixture loader (20 manifest IO assertions),
not full execution. See [[julia-corpus-manifest-io]] for the exact bounded replay. The older 99-case
admission remains historical evidence and must not be presented as today's manifest size.

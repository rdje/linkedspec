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

## September 11 main consumer completion and current105 native proof (.1.44)

The main test file is now physically read through5014 EOF. Its final18 testsets
pass396 assertions: parser185, validation23, projection27, source-parser7,
manifest20, controlled58, starter6, middle6, capture6, logical6, mutation/trivia7,
recursive3, structural4, lib-reader4, shipped6, function4, full-corpus8 and AST16.
The complete corpus test executes all105 fixtures in exact manifest order and
compares every wrapped output to its checked-in expected value. Historical
subwindows and selected shipped cases remain separately checked; their results
are not counted as additional unique fixtures. Earlier99 counts stay historical.

The final main testsets run without the separate includes or earlier main bodies.
Original filename/line coordinates and helpers are retained. This is complete
native corpus execution inside focused reading proof, not the full package gate,
independent primary processes, generated carriers or other runtime backends.
The separate read-through-EOF semantic call-core consumer adds79 assertions
(475 total). Staged-call1–42 is helper setup only and receives no executed-test
claim here. Its continuation remains .1.45.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; source=readlines("julia/test/runtests.jl"; keep=true); source[12:136].="\n"; source[471:3938].="\n"; include_string(Main, join(source), joinpath(pwd(),"julia/test/runtests.jl"))'
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include("julia/test/semantic_index_call_core_test.jl")'
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
```

Neutral semantics remains6 fixture groups/20 exact queries/128 rejected mutations,
with9 complete/0 pending rollout and6 complete/0 pending admission. All startup
repairs remain open; exact positive fixture output is not a universal defect-free
claim. Source identity and three reading ranges remain frozen in the task owner.

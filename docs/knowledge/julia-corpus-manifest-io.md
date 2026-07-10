---
id: julia-corpus-manifest-io
title: Julia corpus manifest IO and drift guard
answers:
  - how does Julia validate the corpus manifest
  - does Julia load the 99 fixture corpus
  - does Julia detect missing stale fixture directories
  - does Julia parse expected.json yet
  - does Julia corpus execute all fixtures
date: 2026-07-10
status: accepted
tags: [julia, corpus, manifest, json, backend]
evidence: "JULIA-BACKEND-PARITY.1.3 adds strict manifest IO and .6.3 permanently executes the complete manifest at 99/99 with unbounded CLI execution. JULIA-BACKEND-PARITY.7.3.2.1 re-proves 99/99 with the current 868-assertion suite and status runtime-corpus-full."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.1.3` adds JSON3-backed corpus manifest IO for Julia. `load_corpus_fixtures(path)` validates
the corpus directory, manifest format `1`, `case_count`, case-name shape, duplicate names, missing/stale fixture
directories, required `input.spec` / `input.txt` / `expected.json` files, and expected JSON syntax.

The checked-in corpus under `rust/linkedspec-runtime/tests/corpus` loads as 99 fixtures. The Julia CLI and
corpus-runner non-execute commands report the validated fixture count. `JULIA-BACKEND-PARITY.6.1` now composes
this loader into the library-level `execute_corpus_fixtures(...)` controlled executor. `.6.2.1` adds selected CLI
execution/reporting. `.6.3` now locks the complete validated manifest at 99/99 exact outputs and enables bare
`--execute` as the full run.

Related facts: [[julia-full-corpus-gate]], [[julia-controlled-corpus-execution]], [[julia-corpus-selection-reporting]].

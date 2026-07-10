---
id: julia-corpus-manifest-io
title: Julia corpus manifest IO and drift guard
answers:
  - how does Julia validate the corpus manifest
  - does Julia load the 99 fixture corpus
  - does Julia detect missing stale fixture directories
  - does Julia parse expected.json yet
  - does Julia corpus execute fixtures yet
date: 2026-07-10
status: accepted
tags: [julia, corpus, manifest, json, backend]
evidence: "julia/src/corpus/CorpusManifest.jl; julia/test/runtests.jl; docs/tasks/JULIA-BACKEND-PARITY.md"
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.1.3` adds JSON3-backed corpus manifest IO for Julia. `load_corpus_fixtures(path)` validates
the corpus directory, manifest format `1`, `case_count`, case-name shape, duplicate names, missing/stale fixture
directories, required `input.spec` / `input.txt` / `expected.json` files, and expected JSON syntax.

The checked-in corpus under `rust/linkedspec-runtime/tests/corpus` loads as 99 fixtures. The Julia CLI and
corpus-runner non-execute commands report the validated fixture count. `JULIA-BACKEND-PARITY.6.1` now composes
this loader into the library-level `execute_corpus_fixtures(...)` controlled executor. The CLI `--execute` path
still deliberately returns an error until later selection/reporting and full-manifest leaves land.

Related fact: [[julia-controlled-corpus-execution]].

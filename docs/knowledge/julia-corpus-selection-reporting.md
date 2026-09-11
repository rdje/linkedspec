---
id: julia-corpus-selection-reporting
title: Julia corpus execution supports bounded selection and PASS/FAIL reporting
answers:
  - how do I execute selected Julia corpus fixtures
  - does Julia corpus execution support case names
  - does Julia corpus execution support offset and limit
  - how does the Julia corpus runner report fixture results
  - what exit codes does the Julia corpus runner use
  - does Julia allow unbounded corpus execution
  - what is JULIA-BACKEND-PARITY.6.2.1
date: 2026-07-10
status: current
tags: [julia, corpus, cli, selection, reporting, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.1 adds named/bounded selection/reporting and .6.3 enables full/offset-only runner execution. .7.3.2.5 retains 99/99 with 1,017 assertions at runtime-corpus-primary-cli."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

`execute_corpus_fixtures(...)` validates the complete manifest first, then selects either ordered `case_names` or
a zero-based `offset` window with an optional positive `limit`. Named selection preserves caller order. Oversized
limits stop at the manifest end.

Selection raises `CorpusManifestException` for missing or duplicate case names, named-plus-window combinations,
negative/non-integer offsets, non-positive/non-integer limits, and offsets outside the fixture count.

The Julia-specific CLI and `julia/bin/corpus_runner.jl` accept repeated `--case`, `--offset`, and `--limit` in
separate or `--flag=value` form. Bounded execute mode prints one `PASS <name>` or `FAIL <name>: <detail>` line per
selected fixture followed by a passed/failed summary. Exit `0` means all selected fixtures passed, exit `1` means
one or more selected fixtures failed, and exit `2` means invalid arguments or corpus/selection validation failed.

Validation-only behavior remains the default. Bare `--execute` runs the complete validated manifest (105 fixtures at the September 11 reading intake). Offset-only
execution runs from the selected zero-based offset to the manifest end. Named and bounded forms remain available
for diagnostics, and complete manifest validation always happens before selection.

`JULIA-BACKEND-PARITY.6.2.2` uses this bounded surface to prove manifest offsets 0–39 green at 40/40, and `.6.2.3`
uses three disjoint windows to prove the surrounding 25 non-function middle fixtures green, all without a
production or fixture correction.

Examples:

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --case proof_edge_array_literal
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 0 --limit 10
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute
```

Related facts: [[julia-full-corpus-gate]], [[julia-starter-corpus-batch]], [[julia-middle-corpus-batch]], [[julia-controlled-corpus-execution]], [[julia-corpus-manifest-io]],
[[dart-controlled-corpus-execution]], [[variant-specific-cli-requirement]].

September 11 `.1.8` rereads the complete selector/runner and replays 58 controlled-execution assertions,
including ordered names, duplicate/missing rejection, offset/limit bounds, required execute mode, exact
reporting exits and continuation after failures. Replay: [[julia-controlled-corpus-execution]].

---
id: julia-global-cli-61-audit
title: Julia global CLI baseline is 13 of 61 with three repair mechanisms
answers:
  - how many shared CLI cases does Julia pass before global repair
  - why does Julia fail the shared 61 case CLI suite
  - does Julia accept malformed UTF-8 files
  - is Julia primary trace canonical or native
  - how is FUTURE-PARITY-BACKLOG 1.5.4 split
  - why must the Julia conformance driver warm the project
date: 2026-07-10
status: current
tags: [julia, cli, utf8, trace, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.4.0 runs the unchanged suite against Julia, measures 13/61, and splits shared help/UTF-8/errors, canonical trace, and the recurring four-backend driver before code."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot perl tools/run_cli_conformance.pl --display-command linkedspec_julia -- /opt/homebrew/bin/julia --project={{REPO_ROOT}}/julia --startup-file=no --history-file=no {{REPO_ROOT}}/julia/bin/linkedspec_julia.jl"
---

At the `.1.5.4.0` audit, warmed Julia passes 13/61 unchanged cases: all 11 ordinary native execution/direct-result
cases and the `none`/`quiet` trace cases. This confirms that source/input selection, named resolution, top rule,
global parse mode, direct recursively canonical JSON, valid Unicode/BOM/newline handling, and ordinary native
execution do not need a semantic rewrite.

The 48 failures have three code owners. `_primary_cli_usage()` is a shorter Julia-local help template, so both help
and all usage stderr differ. `_read_primary_cli_file(...)` uses Julia `String` without `isvalid`, so malformed UTF-8
is accepted; `_print_primary_cli_runtime_error(...)` appends backend diagnostics after the portable phase heading.
`_primary_cli_trace_emitter(...)` routes rich Julia frontend/compiler/runtime events, not ADR `0024`'s canonical
phase protocol. `.1.5.4.1` owns help/strict UTF-8/phase-only errors, `.2` canonical trace, and `.3` the final matrix.

A cold first `using LinkedSpecJulia` may print Julia precompile progress to process stderr before application code
runs. The existing `tools/check_julia_primary_cli.sh` already warms the project explicitly. The final global driver
must do the same, while the application continues to own its bytes after warmup; the ambient toolchain message is
not silently classified as LinkedSpec stderr behavior.

Related facts: [[julia-primary-cli-process-conformance]], [[julia-primary-cli-arguments-resolution-loading]],
[[julia-primary-cli-failure-trace-routing]], [[canonical-primary-cli-trace-protocol]],
[[cross-backend-cli-contract-gap]], [[dart-primary-cli-closeout]].

---
id: julia-native-spec-resolution
title: Julia exposes native named and exact-path spec loading with structured pipeline exceptions
answers:
  - how does a Julia application load and compile a named LinkedSpec file without a CLI
  - where is Julia native spec resolution implemented
  - does Julia consume the shared native resolution fixture directly
  - how does Julia attach a loaded spec name and path to runtime diagnostics
  - does the Julia primary CLI delegate named and file loading to the native API
  - what does Julia return when native spec loading fails
  - does Julia still recursively search the repository for named specs
  - what did FUTURE-PARITY-BACKLOG 1.6.4.4 implement
date: 2026-07-11
status: current
tags: [julia, resolution, files, utf8, diagnostics, native-api, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.4.4 exports the Julia spec loader with typed requests/options/results/stages/codes/exceptions, consumes all 14 name + 9 resolution + 4 text cases in test/spec_loader_test.jl, composes full staged parse/validate/compile and execution, delegates primary CLI named/file selection without recursive fallback, and passes 1,110 package assertions, 61x2 CLI, and 105 corpus fixtures."
reverify: "perl tools/check_native_spec_resolution_contract.pl && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'import Pkg; Pkg.test()' && LINKEDSPEC_JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot bash tools/run_julia_local.sh"
---

`LinkedSpecJulia` exports Julia's public file-oriented API. `named_spec_request(...)` selects a portable logical
identity; `path_spec_request(...)` selects one exact host path. `SpecLoadOptions` carries cwd and direct search
roots in declared order. `resolve_spec`, `load_spec`, and `load_and_compile_spec` expose progressively composed
stages without a CLI or subprocess.

`LoadedCompiledSpec` retains requested/resolved identity, exact decoded source, and `CompiledSpec`.
`create_engine(...)` attaches the name (for named requests) and resolved path to later structured runtime errors.
The primary Julia command delegates named and explicit file source selection to this same API; inline source
continues through the existing in-memory composition. The former sorted recursive repository fallback is removed;
only cwd exact, cwd suffix, and declared direct roots participate.

`SpecPipelineException` carries typed stage/code values and `to_json(...)` projects the neutral error fields plus
path/detail when available. Five focused testsets read the shared JSON fixture directly and prove all 14/9/4
cases, top-level-function compilation/execution, parse versus validation attribution, engine identity, and exact
missing-name JSON. The full Julia gate and 61x2 CLI proof establish adapter no-drift.

Related facts: [[native-spec-resolution-contract]], [[rust-native-spec-resolution]],
[[dart-native-spec-resolution]], [[native-in-memory-backend-contract]],
[[primary-cli-four-backend-matrix]].

---
id: rust-native-spec-resolution
title: Rust exposes native named and exact-path spec loading with structured pipeline errors
answers:
  - how does a Rust application load and compile a named LinkedSpec file without a CLI
  - where is Rust native spec resolution implemented
  - does Rust consume the shared native resolution fixture directly
  - how does Rust attach a loaded spec name and path to runtime diagnostics
  - does the Rust primary CLI delegate named and file loading to the native API
  - what does Rust return when native spec loading fails
  - what did FUTURE-PARITY-BACKLOG 1.6.4.2 implement
date: 2026-07-11
status: current
tags: [rust, resolution, files, utf8, diagnostics, native-api, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.4.2 exports linkedspec_runtime::spec_loader with typed requests/options/results/errors, consumes all 14 name + 9 resolution + 4 text cases in tests/spec_loader.rs, composes full staged parse/validate/compile and execution, delegates primary CLI named/file selection, and passes 137/105/196/5/3/5/10 plus 61x2 CLI."
reverify: "perl tools/check_native_spec_resolution_contract.pl && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test spec_loader && bash tools/run_rust_local.sh"
---

`linkedspec_runtime::spec_loader` is Rust's public file-oriented API. `SpecRequest::named(...)` selects a portable
logical identity; `SpecRequest::path(...)` selects one exact host path. `SpecLoadOptions` carries cwd and direct
search roots in declared order. `resolve_spec`, `load_spec`, and `load_and_compile_spec` expose progressively
composed stages without a CLI or subprocess.

`LoadedCompiledSpec` retains requested/resolved identity, exact decoded source, and `CompiledSpec`. Converting it
with `into_engine()` attaches the name (for named requests) and resolved path to later structured runtime errors.
The primary Rust command now delegates named and explicit file source selection to this same API; inline source
continues through the existing in-memory composition.

`SpecPipelineError` serializes the neutral error type/stage/code/summary/request fields plus path/detail when
available. Five focused tests read the shared JSON fixture directly and prove all 14/9/4 cases, top-level-function
compilation/execution, parse versus validation attribution, engine identity, and exact missing-name JSON. The full
Rust gate proves no CLI byte drift.

Related facts: [[native-spec-resolution-contract]], [[rust-runtime-structured-diagnostics]],
[[native-in-memory-backend-contract]], [[primary-cli-four-backend-matrix]].

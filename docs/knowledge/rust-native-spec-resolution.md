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
date: 2026-09-08
status: current
tags: [rust, resolution, files, utf8, diagnostics, native-api, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.4.2 exports linkedspec_runtime::spec_loader with typed requests/options/results/errors, consumes all 14 name + 9 resolution + 4 text cases in tests/spec_loader.rs, composes full staged parse/validate/compile and execution, delegates primary CLI named/file selection, and passes 137/105/196/5/3/5/10 plus 61x2 CLI."
reverify: "bash tools/project_data_run.sh perl tools/check_native_spec_resolution_contract.pl && bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test spec_loader"
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

## September 7 complete loader reading

`SESSION-STARTUP-READING.3.3.35` reads all 564 lines. Requests/options keep private owned values; options
introduce no implicit search roots. Candidate construction preserves lexical first occurrence through a
HashSet filter without changing order. Cwd is joined explicitly for named/exact-path relative candidates;
search-root paths are joined as supplied. No canonicalization or recursive search is added by the loader.

Name validation rejects surrounding Unicode whitespace, control characters, absolute prefixes, backslashes
and invalid path components. Exact paths reject empty/NUL values. Resolution remembers the first non-file
while continuing to later regular files; missing candidates are skipped, other metadata failures return a
structured resolution error immediately. Selected paths must be Unicode text before loading or engine creation.
Strict UTF-8 decoding preserves valid source bytes as decoded text. Full composition attributes parse,
validation and compilation failures separately and retains the resolved path. Engine conversion adds the
requested name only for name requests, and adds the resolved path for both kinds.

Fresh neutral 14/9/4 proof passes; the native five-test/full-gate counts above remain dated July evidence.
This reading checkpoint adds no new filesystem/runtime execution claim. Prior slice .3.3.34 already used the
public exact-path loader successfully to emit ordinary and recognition modules from repository-local inputs.

## September 8 loader-consumer reading

`SESSION-STARTUP-READING.3.3.63` reconciles all 264 lines of
`rust/linkedspec-runtime/tests/spec_loader.rs`.
Five tests consume the shared 14 name / 9 resolution / 4 text cases, then cover a
loaded function's execution and engine identity, parse versus validation stages,
and exact missing-name JSON. Fixture construction represents both `directory` and
`non_regular` with directories: this exercises the non-file branch, not every OS
special-file type. Text fixtures decode their exact hexadecimal bytes before loading.
The source uses a Drop-managed scratch directory under the wrapper-supplied temporary
root. Fresh neutral 14/9/4 checks pass; this reading checkpoint does not rerun the
native five-test target or refresh the historical full-gate counts above.

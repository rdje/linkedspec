---
id: dart-native-spec-resolution
title: Dart exposes native named and exact-path spec loading with structured pipeline exceptions
answers:
  - how does a Dart application load and compile a named LinkedSpec file without a CLI
  - where is Dart native spec resolution implemented
  - does Dart consume the shared native resolution fixture directly
  - how does Dart attach a loaded spec name and path to runtime diagnostics
  - does the Dart primary CLI delegate named and file loading to the native API
  - what does Dart return when native spec loading fails
  - what did FUTURE-PARITY-BACKLOG 1.6.4.3 implement
date: 2026-07-11
status: current
tags: [dart, resolution, files, utf8, diagnostics, native-api, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.4.3 exports the Dart spec loader with typed requests/options/results/exceptions, consumes all 14 name + 9 resolution + 4 text cases in test/spec_loader_test.dart, composes full staged parse/validate/compile and execution, delegates primary CLI named/file selection, and passes format/analyze, 165 tests, 61x2 CLI, and 105 corpus fixtures."
reverify: "perl tools/check_native_spec_resolution_contract.pl && (cd dart && bash ../tools/run_dart_project_data.sh test test/spec_loader_test.dart) && bash tools/run_dart_local.sh"
---

`package:linkedspec_dart/linkedspec_dart.dart` exports Dart's public file-oriented API. `SpecRequest.named(...)`
selects a portable logical identity; `SpecRequest.path(...)` selects one exact host path. `SpecLoadOptions` carries
cwd and direct search roots in declared order. `resolveSpec`, `loadSpec`, and `loadAndCompileSpec` expose
progressively composed stages without a CLI or subprocess.

`LoadedCompiledSpec` retains requested/resolved identity, exact decoded source, and `CompiledSpec`.
`createEngine()` attaches the name (for named requests) and resolved path to later structured runtime errors. The
primary Dart command delegates named and explicit file source selection to this same API; inline source continues
through the existing in-memory composition.

`SpecPipelineException.toJson()` projects the neutral error type/stage/code/summary/request fields plus path/detail
when available. Five focused tests read the shared JSON fixture directly and prove all 14/9/4 cases, top-level-
function compilation/execution, parse versus validation attribution, engine identity, and exact missing-name JSON.
The full Dart gate proves no CLI byte drift.

Related facts: [[native-spec-resolution-contract]], [[rust-native-spec-resolution]],
[[native-in-memory-backend-contract]], [[primary-cli-four-backend-matrix]].

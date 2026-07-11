---
id: dart-native-full-pipeline-trace
title: "Dart admits one caller-owned native emitter from file loading through runtime"
answers:
  - "does Dart have full-pipeline native trace parity"
  - "can Dart loadAndCompileSpec accept a trace emitter"
  - "does Dart retain the trace emitter in LoadedCompiledSpec"
  - "how does one Dart emitter span loading compilation and runtime"
  - "what proves Dart routed full-pipeline tracing"
  - "what did FUTURE-PARITY-BACKLOG.1.6.5.3 implement"
date: 2026-07-11
status: current
tags: [dart, trace, native-api, loader, parser, compiler, runtime, FUTURE-PARITY-BACKLOG]
evidence: "dart/lib/src/io/spec_loader.dart; dart/test/native_pipeline_trace_test.dart; capability_conformance/manifest.json"
reverify: "cd dart && dart test test/native_pipeline_trace_test.dart && dart analyze --fatal-infos --fatal-warnings && cd .. && perl tools/check_capability_conformance.pl"
---

`FUTURE-PARITY-BACKLOG.1.6.5.3` adds optional `trace:` injection to Dart's public
`loadAndCompileSpec(...)`. A balanced `dart_io:load_and_compile_spec` scope and loaded-
source decision wrap the existing resolution/load boundary, then the same caller-owned
emitter propagates through staged function parsing, validation, and compilation.

`LoadedCompiledSpec` deliberately does not retain mutable emitter or sink state. The caller
passes the same emitter explicitly to `loaded.createEngine().execute(..., trace: trace)`,
making ownership and lifecycle visible while preserving ordinary compiled-result semantics.

Three direct tests prove one routed file contains balanced IO/frontend/function/staged/
compiler/runtime topics, compiled and runtime JSON remain identical, disabled tracing is
empty, source identity survives, and validation failure JSON is exact. Format, strict
analysis, 22 affected tests, the full 175-test Dart suite, 61 CLI cases in both environments,
105 corpus fixtures, and canonical core CI pass. Dart promotes to pass for the full-pipeline
row, moving the census to 57/1/2 and closing `.1.6.5`; core Phase 0 `1..1030` completes in
514 seconds.

Related facts: [[dart-frontend-compiler-trace-events]], [[dart-function-staged-trace-events]],
[[dart-runtime-trace-events]], [[dart-trace-controls-sinks]], [[dart-full-pipeline-trace-gap]].

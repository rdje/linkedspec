---
id: dart-full-pipeline-trace-gap
title: "Dart full-pipeline native trace gap is closed"
answers:
  - "where does Dart native trace injection currently begin"
  - "does Dart trace parsing validation and compilation"
  - "does Dart propagate trace through function definitions and staged jobs"
  - "what does FUTURE-PARITY-BACKLOG.1.6.5 need to implement"
  - "how is Dart full-pipeline trace split"
date: 2026-07-11
status: current
tags: [dart, trace, parser, validation, compiler, staged-parsing, function-shell, FUTURE-PARITY-BACKLOG]
evidence: "dart/lib/src/runtime/interpreter.dart; dart/lib/src/parser/spec_parser.dart; dart/lib/src/validation/spec_validator.dart; dart/lib/src/compiler/compiled_spec.dart; dart/lib/src/parser/staged_parser_registry.dart; dart/lib/src/io/spec_loader.dart; capability_conformance/manifest.json"
reverify: "rg -n 'LinkedSpecTraceEmitter|trace:' dart/lib/src/{runtime,parser,validation,compiler,action,io} capability_conformance/manifest.json"
---

Dart's public `LinkedSpecTraceEmitter` provides ordered levels, structured events, default
quietness, and stdout/route/mirror sinks. `LinkedSpecRuntimeEngine.parse(...)` and
`execute(...)` accept an optional caller-owned emitter and produce interpreter events.

`FUTURE-PARITY-BACKLOG.1.6.5.1` carries that same optional emitter through
`parseSpec(...)`, `validateSpec(...)`, `compileSpec(...)`, and `UserFunctionRegistry`.
`.1.6.5.2` extends it through function-parser construction/runtime execution, projection,
stripped-source parsing, staged queue/job phases, and body stitching. `.1.6.5.3` adds
`loadAndCompileSpec(..., trace:)`, proves explicit reuse of that same caller-owned emitter
at runtime, and admits routed/quiet/failure/identity plus complete recurring coverage. The
full-pipeline row now passes for Dart.

`FUTURE-PARITY-BACKLOG.1.6.5` closed by mechanism: completed `.1` instruments
frontend, validation, and compiler owners; completed `.2` propagates through function
extraction and staged dispatch; completed `.3` composes the public loader/runtime path, proves
traced/untraced identity, quietness, sinks, balanced failures, and full recurring no-drift
before promotion to census 57/1/2.

Related facts: [[dart-runtime-trace-events]], [[dart-trace-controls-sinks]],
[[trace-cross-variant-capability-contract]], [[julia-frontend-compiler-staged-trace-events]].

## September 10 complete pipeline-consumer reading

`DART-STARTUP-READING.1.42` completes native pipeline test lines 4-182 after the preceding
imports. Its four tests pass within the selected 39-test suite. One caller-owned emitter
spans loading, frontend/function/staged work, compilation and runtime; JSON identity,
balanced scopes, quiet disabled tracing and structured validation errors are checked.
Scratch and routed logs use the managed temporary root and are removed by owned teardown.
The error comparison is structured equality across calls, not exception-object identity.

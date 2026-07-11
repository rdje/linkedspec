---
id: dart-full-pipeline-trace-gap
title: "Dart native tracing reaches core frontend/compiler but not function/staged composition"
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

`FUTURE-PARITY-BACKLOG.1.6.5.1` now carries that same optional emitter through
`parseSpec(...)`, `validateSpec(...)`, `compileSpec(...)`, and `UserFunctionRegistry`.
The function-definition parser/projection shell, staged job dispatch, and
`loadAndCompileSpec(...)` do not yet expose the complete propagation path. Consequently,
the capability census correctly distinguishes Dart's passing controls/runtime/core-
compiler work from its still-open full-pipeline row.

`FUTURE-PARITY-BACKLOG.1.6.5` is split by mechanism: completed `.1` instruments
frontend, validation, and compiler owners; active `.2` propagates through function
extraction and staged dispatch; `.3` composes the public loader/runtime path, proves
traced/untraced identity, quietness, sinks, balanced failures, and full recurring no-drift
before promotion.

Related facts: [[dart-runtime-trace-events]], [[dart-trace-controls-sinks]],
[[trace-cross-variant-capability-contract]], [[julia-frontend-compiler-staged-trace-events]].

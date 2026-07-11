---
id: dart-full-pipeline-trace-gap
title: "Dart native tracing currently begins at the runtime interpreter"
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

Dart's public `LinkedSpecTraceEmitter` already provides ordered levels, structured events,
default quietness, and stdout/route/mirror sinks. `LinkedSpecRuntimeEngine.parse(...)` and
`execute(...)` accept an optional caller-owned emitter and produce interpreter events.

The emitter does not yet cross the rest of the native pipeline. `parseSpec(...)`,
`validateSpec(...)`, `compileSpec(...)`, `UserFunctionRegistry`, the function-definition
parser and projection shell, staged job dispatch, and `loadAndCompileSpec(...)` expose no
optional emitter. Consequently, the capability census correctly distinguishes Dart's
passing runtime-controls/events/sinks row from its full-pipeline trace gap.

`FUTURE-PARITY-BACKLOG.1.6.5` is split by mechanism: `.1` instruments frontend,
validation, and compiler owners; `.2` propagates through function extraction and staged
dispatch; `.3` composes the public loader/runtime path, proves traced/untraced identity,
quietness, sinks, balanced failures, and full recurring no-drift before promotion.

Related facts: [[dart-runtime-trace-events]], [[dart-trace-controls-sinks]],
[[trace-cross-variant-capability-contract]], [[julia-frontend-compiler-staged-trace-events]].

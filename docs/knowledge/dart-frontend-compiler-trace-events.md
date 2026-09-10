---
id: dart-frontend-compiler-trace-events
title: "Dart propagates one optional trace emitter through parsing validation and compilation"
answers:
  - "does Dart trace source parsing"
  - "does Dart trace validation"
  - "does Dart trace compilation"
  - "does Dart trace function registry construction"
  - "which Dart core APIs accept a trace emitter"
  - "what Dart trace topics identify frontend and compiler events"
  - "does Dart frontend tracing change parsed or compiled results"
  - "what did FUTURE-PARITY-BACKLOG.1.6.5.1 implement"
date: 2026-07-11
status: current
tags: [dart, trace, parser, validation, compiler, function-registry, FUTURE-PARITY-BACKLOG]
evidence: "dart/lib/src/parser/spec_parser.dart; dart/lib/src/validation/spec_validator.dart; dart/lib/src/compiler/compiled_spec.dart; dart/lib/src/action/function_registry.dart; dart/test/frontend_compiler_trace_test.dart"
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/frontend_compiler_trace_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && rg -n 'dart_(frontend|compiler):|LinkedSpecTraceEmitter\\? trace' lib/src/{parser/spec_parser.dart,validation/spec_validator.dart,compiler/compiled_spec.dart,action/function_registry.dart}"
---

`FUTURE-PARITY-BACKLOG.1.6.5.1` extends existing public Dart operations with an
optional named `LinkedSpecTraceEmitter` parameter. It does not create separate traced
parser/compiler variants, and existing calls remain source-compatible.

The propagated entrypoints are `parseSpec(...)`, `validateSpec(...)`,
`compileSpec(...)`, and `UserFunctionRegistry.fromSpec(...)` / `fromFunctions(...)`.
High-level `dart_frontend:parse_spec`, `dart_frontend:validate_spec`,
`dart_compiler:compile_spec`, and `dart_compiler:function_registry` topics provide
balanced success/failure scopes. Medium decisions report parsed rule counts, completed
or skipped validation, function definitions, compiled rules, and dependency-regex work.
Failure exits rethrow the original exception object.

Focused tests prove exact traced/untraced `SpecFile` and `CompiledSpec` JSON identity,
disabled-emitter quietness, exact nested event order, and balanced parse/validation
failure exits. The complete Dart gate passes 168 tests, 61 CLI cases in both supported
option environments, and all 105 corpus fixtures. Later `.2` and `.3` complete function/
staged/native composition and admit the full pipeline at census 57/1/2.

Related facts: [[dart-full-pipeline-trace-gap]], [[dart-runtime-trace-events]],
[[dart-trace-controls-sinks]], [[trace-cross-variant-capability-contract]].

## 2026-09-10 — validation prefix and check order

`DART-STARTUP-READING.1.34` reads spec_validator.dart 1-355. Validation retains
one balanced trace scope around its ordered checks. The prefix owns nonempty
specs, Unicode declaration/target labels, duplicate names, named-slot validity
and uniqueness, registry collisions, variadic/final-codeblock metadata and
parameter restrictions, malformed Raw rejection and lifecycle brace checks.
Strict unused-rule validation remains opt-in; remaining implementations are
read in .1.35.

All 27 selected emitter/trace/frontend/spec-validation tests pass. Earlier
lifecycle/regex-brace and recognition-effect findings remain Dart .2.2/.2.4;
this checkpoint changes no validation behavior or accepted syntax.

---
id: dart-function-staged-trace-events
title: "Dart propagates one optional trace emitter through function extraction and staged parse jobs"
answers:
  - "does Dart trace user function definition parsing"
  - "does Dart trace function AST projection"
  - "does Dart trace staged parse job phases"
  - "which Dart function and staged APIs accept a trace emitter"
  - "what Dart trace topics identify function and staged events"
  - "does Dart function staged tracing change AST results"
  - "what did FUTURE-PARITY-BACKLOG.1.6.5.2 implement"
date: 2026-07-11
status: current
tags: [dart, trace, function-shell, staged-parsing, runtime, FUTURE-PARITY-BACKLOG]
evidence: "dart/lib/src/parser/user_function_definition_parser.dart; dart/lib/src/parser/user_function_definition_shell.dart; dart/lib/src/parser/staged_parser_registry.dart; dart/test/function_staged_trace_test.dart"
reverify: "cd dart && dart test test/function_staged_trace_test.dart && dart analyze --fatal-infos --fatal-warnings && rg -n 'dart_(frontend:function|staged):|LinkedSpecTraceEmitter\\? trace' lib/src/parser/{user_function_definition_parser.dart,user_function_definition_shell.dart,staged_parser_registry.dart}"
---

`FUTURE-PARITY-BACKLOG.1.6.5.2` extends the existing optional caller-owned
`LinkedSpecTraceEmitter` through Dart's user-function extraction and staged parse-job
pipeline. Existing quiet calls remain source-compatible.

Propagation covers parser-spec construction and cache selection, definition-shell runtime
execution, AST projection, stripped rule parsing, full staged spec composition, single and
batch job execution, function-body dispatch, and body stitching. High-level
`dart_frontend:function_*` and `dart_staged:*` scopes are balanced on success and failure.
Medium decisions report parser cache hits, definition counts/projection, normalized sorted
queues, per-job resolve/load/compile/execute phases, and stitched result fields. The same
emitter also reaches the nested existing runtime and core frontend/compiler scopes.

Four focused tests prove complete topic presence and nesting balance, exact traced/untraced
AST JSON, disabled quietness, unchanged staged resolve failures, and preservation of the
original function-projection diagnostic rather than misclassifying it as stripped-rule
parsing. The complete Dart gate passes 172 tests, 61 CLI cases in both option environments,
and all 105 corpus fixtures. Later `.3` completes native loader/runtime composition and
admits the full pipeline at census 57/1/2.

Related facts: [[dart-frontend-compiler-trace-events]], [[dart-full-pipeline-trace-gap]],
[[dart-runtime-trace-events]], [[trace-cross-variant-capability-contract]].

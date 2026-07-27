---
id: dart-trace-controls-sinks
title: Dart runtime exposes trace controls, event primitives, and sink routing
answers:
  - does Dart have trace controls
  - how does Dart configure trace sinks
  - what is LinkedSpecTraceConfig
  - which Dart entrypoints have traced variants
  - can Dart claim trace parity after DART-BACKEND-PARITY.4.5.2
  - what runtime trace events does Dart emit after DART-BACKEND-PARITY.4.5.3
date: 2026-07-09
status: current
tags: [dart, trace, runtime, diagnostics, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.5.2 added dart/lib/src/trace/trace.dart, public trace exports, LinkedSpecRuntimeEngine trace parameters and parseWithTrace/executeWithTrace, and test/trace_test.dart."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/trace_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && rg -n 'LinkedSpecTraceConfig|LinkedSpecTraceEmitter|parseWithTrace|executeWithTrace|DART-BACKEND-PARITY\\.4\\.5\\.2' dart/lib dart/test docs/tasks/DART-BACKEND-PARITY.md docs/linkedspec-book/src/public-api/trace-api.md"
---

Dart trace controls live in `dart/lib/src/trace/trace.dart` and are exported
from `package:linkedspec_dart/linkedspec_dart.dart`.

`DART-BACKEND-PARITY.4.5.2` adds:

- `LinkedSpecTraceLevel` with ordered `none`, `low`, `medium`, `high`, `full`,
  and `debug` levels plus numeric thresholds;
- `LinkedSpecTraceConfig`, including `fromEnvironment(...)` support for the
  documented `LINKEDSPEC_TRACE_*` controls;
- `LinkedSpecTraceSinkMode` for stdout, routed-file, and mirror sinks;
- `LinkedSpecTraceEmitter` with structured event, scope, decision, log, and dump
  primitives;
- routed-file reset/truncate behavior;
- `LinkedSpecRuntimeEngine.parse(..., trace: emitter)`,
  `execute(..., trace: emitter)`, `parseWithTrace(...)`, and
  `executeWithTrace(...)`.

This does not complete Dart backend parity. `.4.5.2` proved controls, sinks,
and output preservation with parse-scope events. `.4.5.3` adds runtime
interpreter events for parse/rule scopes, regex match/no-match decisions,
action-edge and blind-call child-dispatch decisions, lifecycle marks,
cursor-control marks, recursion-cutoff decisions, and
`capture_until_boundary(...)` source-boundary marks. `.4.5.4` closes the
diagnostics/trace no-drift sweep and advances Dart to staged registry work.

Related facts: [[dart-runtime-diagnostics-trace-split]],
[[trace-cross-variant-capability-contract]], [[dart-runtime-structured-diagnostics]],
[[dart-runtime-trace-events]], [[dart-diagnostics-trace-boundary]].

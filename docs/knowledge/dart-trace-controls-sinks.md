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

## 2026-09-10 — complete trace owner reading

`DART-STARTUP-READING.1.34` reads all 404 trace lines. Config derives explicit
environment values only when fromEnvironment is called; numeric thresholds and
aliases govern event filtering. The emitter copies its event/line lists for
readers, formats nested scopes and writes synchronously to stdout/file/mirror.
File setup/reset happens during construction, independently of later filtering.

All 27 selected emitter/trace/validation tests pass. The primary CLI has a
separate canonical trace adapter; its numeric overflow/reset-before-failure
remains [[dart-primary-cli-trace-overflow]] under Dart .2.3. This reading does
not merge those APIs or claim a fresh replay of that seven-case failure.

## September 11 trace consumer reading through line 260

Dart .1.52 reads trace_test.dart 1-260. Level aliases/numeric thresholds,
environment configuration, reset/route/mirror sinks and structured scope/decision/
log/dump events are checked. Native traced and untraced JSON results match while
action/blind dispatch, lifecycle, cursor and source-boundary events remain visible.
All 38 selected tests pass, including the complete seven-test trace file.
The temporary-file helper tail belongs to .1.53; execution gives no unread source
credit. The separate primary-CLI overflow/reset defect .2.3 remains open.

## September 11 trace consumer tail complete

Dart .1.53 reads trace_test.dart 261-269 through EOF. The helper registers
teardown to remove its temporary directory and returns its trace.log path.
The repository wrapper supplies the project-local system temporary root.
All 29 selected tests pass, including all seven trace tests. This completes
physical consumer reading and leaves the separate primary-CLI .2.3 defect open.

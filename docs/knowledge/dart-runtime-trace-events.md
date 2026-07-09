---
id: dart-runtime-trace-events
title: Dart runtime emits interpreter trace events behind the optional trace emitter
answers:
  - does Dart runtime tracing include rule scopes
  - does Dart runtime tracing include regex branch decisions
  - does Dart runtime tracing include lifecycle block events
  - does Dart runtime tracing include source-boundary events
  - what did DART-BACKEND-PARITY.4.5.3 implement
date: 2026-07-09
status: current
tags: [dart, trace, runtime, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.5.3 instruments dart/lib/src/runtime/interpreter.dart and extends dart/test/trace_test.dart."
reverify: "cd dart && dart test test/trace_test.dart && dart analyze --fatal-infos --fatal-warnings && rg -n 'dart_runtime:(rule|regex_match|child_dispatch|lifecycle_block|cursor_control|source_boundary|recursion_guard)' lib/src/runtime/interpreter.dart test/trace_test.dart"
---

`DART-BACKEND-PARITY.4.5.3` adds Dart runtime interpreter trace events behind
the optional `LinkedSpecTraceEmitter`.

When tracing is enabled, `LinkedSpecRuntimeEngine` now emits:

- parse and rule enter/exit scopes;
- recursion-cutoff decisions;
- regex match/no-match decisions;
- action-edge and blind-call child-dispatch decisions;
- lifecycle block mark events;
- cursor-control mark events for `save_cursor()`, `restore_cursor()`,
  `rewind_match_start()`, and `rewind_entry_start()`;
- source-boundary mark events for `capture_until_boundary(...)`.

The instrumentation is trace-only. Without an emitter, the runtime stays quiet.
Focused trace tests compare traced and untraced parse-result JSON to lock output
preservation.

Related facts: [[dart-trace-controls-sinks]], [[dart-runtime-diagnostics-trace-split]],
[[trace-cross-variant-capability-contract]], [[rust-trace-runtime-branch-events]].

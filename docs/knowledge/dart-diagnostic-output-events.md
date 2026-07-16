---
id: dart-diagnostic-output-events
title: Dart native diagnostic helpers use typed caller-owned per-invocation events
answers:
  - how do I capture Dart print say and print_each diagnostic output
  - what is Dart RuntimeDiagnosticOutputEvent
  - which Dart runtime methods accept diagnosticOutputSink
  - is Dart diagnostic output quiet without a sink
  - how do Dart diagnostic sink failures propagate
  - what typed outcome does Dart exit_now throw
  - are Dart diagnostic events part of RuntimeDiagnostic or native trace
date: 2026-07-16
status: current
tags: [Dart, runtime, helpers, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.4 adds RuntimeDiagnosticOutputEvent/Sink and RuntimeExitNow to native parse/execute and traced aliases. diagnostic_output_contract_test.dart consumes all linkedspec-diagnostic-output-v1 render, arity, ordering, quiet, wrong-kind, sink-failure, and exit scenarios and proves trace separation. tools/run_dart_local.sh passes 220 tests, analyzer/formatter, primary CLI 61x2, and 105/105 corpus fixtures."
reverify: "cd dart && dart test test/diagnostic_output_contract_test.dart test/runtime_interpreter_test.dart test/trace_test.dart && cd .. && rg -n 'RuntimeDiagnosticOutput(Event|Sink)|RuntimeExitNow|diagnosticOutputSink' dart/lib dart/test/diagnostic_output_contract_test.dart"
---

Dart callers install a sink for one native invocation:

```dart
final events = <RuntimeDiagnosticOutputEvent>[];
final result = engine.parse(
  input,
  diagnosticOutputSink: events.add,
);
```

`parse`, `execute`, `parseWithTrace`, and `executeWithTrace` accept the optional callback. Omitting it keeps valid
calls eager and quiet. Every event has `helperName`, current `ruleLabel`, and Unicode `message`; `toJson()` emits
the exact neutral `helper_name`/`rule_label`/`message` record.

Arity rejects before argument effects. Valid calls evaluate once left-to-right. `print` and `say` deliver one
event per call; `print_each` evaluates target/prefix/suffix once and delivers one event per array item. Null and
aggregates render empty, booleans render `1`/`0`, empty and wrong-kind targets are eventless, and helper results
remain null and structural.

Sink invocation is synchronous. A private transport marker carries any thrown object through Dart's action-block
and runtime diagnostic wrappers, then `Error.throwWithStackTrace` restores that exact object and stack to the
caller. This includes a sink that throws `RuntimeInterpreterException` itself. `RuntimeExitNow(status)` is a
separate typed immediate outcome, so preceding events arrive and later actions do not run. Neither rich event
data nor sink failures are `RuntimeDiagnostic` or native trace records.

Generated Dart entrypoint propagation remains owned by `.5.1.7`; this native leaf does not claim it.

Related facts: [[diagnostic-output-neutral-contract]], [[cross-backend-diagnostic-output-drift]],
[[dart-runtime-structured-diagnostics]], [[dart-trace-controls-sinks]], [[rust-diagnostic-output-events]],
[[perl-diagnostic-output-events]], [[lua-diagnostic-output-events]].

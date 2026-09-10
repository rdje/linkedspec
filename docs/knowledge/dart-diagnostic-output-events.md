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
  - how do generated Dart parsers expose diagnostic output
date: 2026-07-16
status: current
tags: [Dart, runtime, helpers, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.4 adds RuntimeDiagnosticOutputEvent/Sink and RuntimeExitNow to native parse/execute and traced aliases. FUTURE-PARITY-BACKLOG.5.1.7 threads the optional sink through generated helpers and emitted direct/traced entrypoints. diagnostic_output_contract_test.dart consumes native and generated linkedspec-diagnostic-output-v1 scenarios and proves exact events, values, trace separation, caller-object identity, and typed exit."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/diagnostic_output_contract_test[.]dart test/runtime_interpreter_test[.]dart test/trace_test.dart && cd .. && rg -n 'RuntimeDiagnosticOutput(Event|Sink)|RuntimeExitNow|diagnosticOutputSink' dart/lib dart/test/diagnostic_output_contract_test.dart"
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

Generated Dart callers pass `diagnosticOutputSink:` to `executeGeneratedParserV2` or its traced counterpart;
emitted `execute` and `executeWithTrace` expose the same optional named argument. A private generated carrier
restores arbitrary caller failures with their stack while ordinary failures retain generated-source attribution.

Related facts: [[diagnostic-output-neutral-contract]], [[cross-backend-diagnostic-output-drift]],
[[dart-runtime-structured-diagnostics]], [[dart-trace-controls-sinks]], [[rust-diagnostic-output-events]],
[[perl-diagnostic-output-events]], [[lua-diagnostic-output-events]].

## September 10 complete diagnostic-consumer reading

`DART-STARTUP-READING.1.37` completes all 342 lines of
`dart/test/diagnostic_output_contract_test.dart`; its seven tests pass within the selected
38-test suite. Native and alias paths prove ordered Unicode, quiet results, every scalar
render row, arity rejection before effects, wrong-kind silence, events before typed exit,
caller error-object identity and trace separation. Generated direct/traced helpers prove
their stated outcomes; this file does not independently compile an emitted module.
The identity assertions do not independently assert stack-object identity.
The neutral checker passes three helpers, eleven render rows, six scenarios,
eight complete/zero pending legs and twenty drift mutations.
These diagnostic-sink controls do not close the distinct semantic-observer wrapping defect
in [[dart-semantic-observer-action-failure-wrapping]].

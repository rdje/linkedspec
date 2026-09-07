---
id: rust-diagnostic-output-events
title: Rust native diagnostic helpers use typed caller-owned per-execution events
answers:
  - how do I capture Rust print say and print_each diagnostic output
  - what is Rust RuntimeDiagnosticOutputEvent
  - which Rust Engine methods accept a diagnostic output sink
  - is Rust diagnostic output quiet without a sink
  - how do Rust diagnostic sink failures propagate
  - what typed outcome does Rust exit_now return
  - are Rust diagnostic events part of RuntimeDiagnostic or native trace
  - how do generated Rust parsers expose diagnostic output
date: 2026-09-07
status: current
tags: [Rust, runtime, helpers, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.3 adds RuntimeDiagnosticOutputEvent/Sink/ExecutionError and top/direct-value Engine entrypoints. FUTURE-PARITY-BACKLOG.5.1.7 adds paired typed-v1 and compatibility generated direct/traced entrypoints plus GeneratedDiagnosticOutputExecutionError. diagnostic_output_contract.rs consumes native and generated linkedspec-diagnostic-output-v1 scenarios and proves exact events, values, trace separation, downcastable sink identity, and typed exit."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test diagnostic_output_contract --test runtime_diagnostics --test trace_controls && rg -n 'RuntimeDiagnosticOutput(Event|Sink|ExecutionError)|execute(_value)?_with_diagnostic_output' rust/linkedspec-runtime/src rust/linkedspec-runtime/tests/diagnostic_output_contract.rs"
---

Rust callers install a sink for one top-rule or direct-value execution:

```rust
use linkedspec_runtime::RuntimeDiagnosticOutputSink;
use std::convert::Infallible;

let sink = RuntimeDiagnosticOutputSink::new(|event| {
    consume(event.helper_name, event.rule_label, event.message);
    Ok::<(), Infallible>(())
});
let output = engine.execute_with_diagnostic_output("input", Some(&sink))?;
```

`execute_value_with_diagnostic_output(input, options, sink)` is the direct-value counterpart. Passing `None`, or
using the legacy `execute`/`execute_value` and existing diagnostic/trace methods, installs no rich sink: valid
helper arguments still evaluate but no helper writes stdout or stderr.

Every `RuntimeDiagnosticOutputEvent` has exactly `helper_name`, current `rule_label`, and Unicode `message`.
`print`/`say` yield one event per call; `print_each` yields one per item after evaluating its target, prefix, and
optional suffix once. Arity rejects before argument effects; null and aggregates render empty; booleans use
`1`/`0`; wrong-kind targets are eventless; helper results remain null and structural.

`RuntimeDiagnosticOutputExecutionError` preserves three distinct native outcomes. `Runtime` contains the existing
structured `RuntimeExecutionError`; `Sink` retains the caller's concrete error value behind a downcastable shared
error payload and aborts synchronously; `Exit(RuntimeExitNow { status })` represents immediate parser control.
This event channel does not enter `RuntimeDiagnostic`, native trace, or ADR `0024` primary phase trace.

Generated Rust callers use paired `execute_generated_parser_with_diagnostic_output_v1` and
`execute_generated_parser_with_trace_and_diagnostic_output_v1` functions, or their compatibility counterparts.
Emitted modules expose `execute_with_diagnostic_output`, `execute_with_trace_and_diagnostic_output`,
`parse_with_diagnostic_output`, and `parse_with_trace_and_diagnostic_output`. Existing signatures remain intact;
`GeneratedDiagnosticOutputExecutionError` keeps generated-source, compatibility, sink, and exit outcomes distinct.

Related facts: [[diagnostic-output-neutral-contract]], [[cross-backend-diagnostic-output-drift]],
[[rust-runtime-structured-diagnostics]], [[perl-diagnostic-output-events]], [[lua-diagnostic-output-events]].

## September 7 complete event-type reading

`SESSION-STARTUP-READING.3.3.14` reads all 112 lines / 3,792 bytes of
`diagnostic_output.rs`. Sink clones share one `Rc<RefCell<Box<FnMut>>>` callback;
returned concrete errors are retained in `Rc<dyn Error>`. Runtime, sink and exit
variants preserve their respective Display and Error::source values. These types
do not promise thread-safe or arbitrary reentrant callback delivery.

The fresh neutral checker passes three helpers, eleven render rows, six scenarios,
eight complete/zero pending legs and twenty mutations. This is contract/type-reading
proof; no native/generated delivery suite is freshly run for this checkpoint.

## September 7 output-failure precedence reading

`SESSION-STARTUP-READING.3.3.16` reads the public execution wrappers and their
finish adapter. On an error, a retained caller sink failure wins, then `exit_now`
status, then ordinary structured runtime failure. The combined generated trace/output
wrapper finishes that typed outcome before replaying trace; a subsequent replay or
scope-exit error preserves an existing Sink or Exit outcome. Other outcomes can become
trace-write runtime errors. Trace setup errors also use the same typed adapter.
These are source-level precedence facts, not fresh callback-delivery measurements.
The neutral diagnostic checker again passes 3 helpers/11 render rows/6 scenarios,
8 complete/0 pending legs and 20 mutations.

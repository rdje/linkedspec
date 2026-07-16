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
date: 2026-07-16
status: current
tags: [Rust, runtime, helpers, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.3 adds RuntimeDiagnosticOutputEvent/Sink/ExecutionError and top/direct-value Engine entrypoints. diagnostic_output_contract.rs consumes all linkedspec-diagnostic-output-v1 render, arity, ordering, quiet, wrong-kind, sink-failure, and exit scenarios and proves trace separation. tools/run_rust_local.sh passes 137 unit, 105 corpus, six diagnostic-output, 105 generated-classifier, 197 integration, existing diagnostics/trace/source-emitter suites, and primary CLI 61x2."
reverify: "cd rust && cargo test -p linkedspec-runtime --test diagnostic_output_contract --test runtime_diagnostics --test trace_controls && cd .. && rg -n 'RuntimeDiagnosticOutput(Event|Sink|ExecutionError)|execute(_value)?_with_diagnostic_output' rust/linkedspec-runtime/src rust/linkedspec-runtime/tests/diagnostic_output_contract.rs"
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

Generated Rust entrypoint sink propagation remains separately owned by `.5.1.7`; native completion does not claim
that later projection.

Related facts: [[diagnostic-output-neutral-contract]], [[cross-backend-diagnostic-output-drift]],
[[rust-runtime-structured-diagnostics]], [[perl-diagnostic-output-events]], [[lua-diagnostic-output-events]].

---
id: julia-diagnostic-output-helpers
title: Julia native diagnostic helpers use typed caller-owned per-invocation events
answers:
  - does Julia support print print_each and say
  - where does Julia diagnostic helper output go
  - how do I capture Julia print say and print_each diagnostic output
  - what is Julia RuntimeDiagnosticOutputEvent
  - which Julia runtime methods accept diagnostic_output_sink
  - is Julia diagnostic output quiet without a sink
  - how do Julia diagnostic sink failures propagate
  - what typed outcome does Julia exit_now throw
  - are Julia diagnostic events part of RuntimeDiagnostic or native trace
  - why did Julia simenv once fail on exit_now
  - why did Julia ds_vhistory once return proj foo
  - what did JULIA-BACKEND-PARITY.6.2.4.2.2 prove
date: 2026-07-16
status: current
tags: [Julia, runtime, helpers, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.5 adds RuntimeDiagnosticOutputEvent/Sink and RuntimeExitNow to native parse/execute and traced aliases. diagnostic_output_contract_test.jl consumes all linkedspec-diagnostic-output-v1 render, arity, ordering, quiet, wrong-kind, sink-failure, and exit scenarios and proves trace separation. tools/run_julia_local.sh passes package tests, primary CLI 61x2, and 105/105 corpus fixtures."
reverify: "LINKEDSPEC_JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia LINKEDSPEC_JULIA_CMD=/opt/homebrew/bin/julia bash tools/run_julia_local.sh && rg -n 'RuntimeDiagnosticOutput(Event|Sink)|RuntimeExitNow|diagnostic_output_sink' julia/src julia/test/diagnostic_output_contract_test.jl"
---

Julia callers install a sink for one native invocation:

```julia
events = RuntimeDiagnosticOutputEvent[]
result = runtime_parse(
    engine,
    input;
    diagnostic_output_sink = event -> push!(events, event),
)
```

`runtime_parse`, `runtime_execute`, `runtime_parse_with_trace`, and `runtime_execute_with_trace` accept the
optional callback. Omitting it keeps valid calls eager and quiet. Every event has exact `helper_name`, current
`rule_label`, and Unicode `message` fields; `to_json(event)` emits the same neutral record.

Arity rejects before argument effects. Valid calls evaluate once left-to-right. `print` and `say` deliver one
event per call; `print_each` evaluates target/prefix/suffix once and delivers one event per array item. An omitted
suffix is empty. Null and aggregates render empty, booleans render `1`/`0`, empty and wrong-kind targets are
eventless, and helper results remain `nothing` and structural.

Sink invocation is synchronous. A private transport marker carries any thrown object through Julia's action-
block and runtime-diagnostic wrappers, then restores that exact object to the caller. This includes a sink that
throws `RuntimeInterpreterException` itself. `RuntimeExitNow(status)` is a separate typed immediate outcome, so
preceding events arrive and later actions do not run. Neither rich event data nor sink failures are
`RuntimeDiagnostic` or native trace records.

Before `.5.1.5`, Julia sent helper messages through low trace, accepted permissive arities, gave omitted
`print_each` suffixes a newline, and wrapped `exit_now` as `RuntimeInterpreterException`. Those facts remain
historical root-cause evidence; they are not current native behavior. Generated Julia entrypoint propagation
remains owned by `.5.1.7`.

The earlier `JULIA-BACKEND-PARITY.6.2.4.2.2` slice only added eager trace-routed helpers: simenv then advanced to
unsupported `exit_now`, while ds_vhistory exposed a separate leading-trivia `/proj/foo` result. Later Julia
exit, statement-mutation, and public-entry repairs closed both fixture paths. They remain useful implementation
history, but the current 105/105 corpus no longer has either failure.

Related facts: [[diagnostic-output-neutral-contract]], [[cross-backend-diagnostic-output-drift]],
[[julia-diagnostics-trace-boundary]], [[dart-diagnostic-output-events]], [[rust-diagnostic-output-events]],
[[perl-diagnostic-output-events]], [[lua-diagnostic-output-events]].

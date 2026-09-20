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
  - how do generated Julia parsers expose diagnostic output
  - how does the Julia integration adapter report typed diagnostic events and exits
date: 2026-09-20
status: current
tags: [Julia, runtime, helpers, diagnostic-output, events, sink, Unicode, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.5 adds RuntimeDiagnosticOutputEvent/Sink and RuntimeExitNow to native parse/execute and traced aliases. FUTURE-PARITY-BACKLOG.5.1.7 threads the optional sink through generated helpers and emitted direct/traced entrypoints. diagnostic_output_contract_test.jl consumes native and generated linkedspec-diagnostic-output-v1 scenarios and proves exact events, values, trace separation, caller-object identity, and typed exit."
evidence_update_2026_07_18_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.6.4 migrates the unchanged generated diagnostic direct/traced roles to execute_generated_parser_v2 and emitted contract-v2 modules."
reverify: "bash tools/run_julia_local.sh && rg -n 'RuntimeDiagnosticOutput(Event|Sink)|RuntimeExitNow|diagnostic_output_sink' julia/src julia/test/diagnostic_output_contract_test.jl"
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
historical root-cause evidence; they are not current native behavior. Generated callers now pass
`diagnostic_output_sink = ...` to `execute_generated_parser_v2` or its traced counterpart; emitted `execute` and
`execute_with_trace` expose the same keyword. A private generated carrier restores arbitrary caller failures while
ordinary failures retain generated-source attribution.

The earlier `JULIA-BACKEND-PARITY.6.2.4.2.2` slice only added eager trace-routed helpers: simenv then advanced to
unsupported `exit_now`, while ds_vhistory exposed a separate leading-trivia `/proj/foo` result. Later Julia
exit, statement-mutation, and public-entry repairs closed both fixture paths. They remain useful implementation
history, but the current 105/105 corpus no longer has either failure.

Related facts: [[diagnostic-output-neutral-contract]], [[cross-backend-diagnostic-output-drift]],
[[julia-diagnostics-trace-boundary]], [[dart-diagnostic-output-events]], [[rust-diagnostic-output-events]],
[[perl-diagnostic-output-events]], [[lua-diagnostic-output-events]].

## September 11 — diagnostic consumer reading and literal coverage

Julia .1.34 reads all310 lines and passes82 existing assertions. Its scalar renderer
maps the codeblock row to an eager block_value at34-49. Separate direct/generated
controls use an actual codeblock_literal, retain state=before and one empty print
event, passing12 assertions with eager comparisons. Runtime behavior is correct
for those controls; .2.25 owns the permanent fixture correction and counterpart
audit. Exact proof: [[julia-contract-consumer-reading]].

## September20 — application adapter

Integration .4.2 demonstrates the admitted API in
examples/integration/julia/bin/parse_words.jl. Optional --diagnostics passes a sink
for each runtime_execute call, serializing event fields to stderr while stdout
holds only direct values. RuntimeExitNow retains its grammar status in a separate
record; the application chooses process exit 1 and stops the input loop. Prior
values/events remain delivered. RuntimeInterpreterException keeps to_json fields,
and native trace remains separate. Working and clean-source consumers verify
exact Unicode events, typed exit/prior-output behavior and runtime source identity.
The existing 82-assertion diagnostic suite, including caller sink identity and
trace separation, passes unchanged. No runtime API or exception semantics change.

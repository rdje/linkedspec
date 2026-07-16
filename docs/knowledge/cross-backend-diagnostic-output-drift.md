---
id: cross-backend-diagnostic-output-drift
title: Diagnostic helpers diverge in arity, evaluation, formatting, transport, and process control
answers:
  - are print say and print_each identical across all backends
  - what diagnostic output drift exists between Perl Rust Dart Julia and Lua
  - which task owns diagnostic output normalization
  - why is FUTURE-PARITY-BACKLOG.5.1 needed
  - does Perl print_each evaluate prefix and suffix once
  - can Perl diagnostic helpers corrupt primary CLI UTF-8 or bypass canonical exit handling
  - which backend has typed diagnostic output events
date: 2026-07-16
status: current
tags: [parity, helpers, diagnostic-output, Perl, Rust, Dart, Julia, Lua, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.1.0 establishes the five-backend baseline with Knowledge Map/toolbox/native/process evidence. FUTURE-PARITY-BACKLOG.5.1.2/.3 replace Perl host coupling and Rust direct stderr with exact arity-before-effects, once-only arguments, typed synchronous caller-owned events, quiet default execution, preserved sink failure, and typed immediate exit. Dart discard, Julia trace/permissive-arity drift, and Lua formal neutral admission remain separately owned."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{print_each(items, \"<\", \">\")}), qq{\\n}' && rg -n 'lower_(say|print|print_each)_statement|RuntimeDiagnosticOutput|_evaluateValues|_call_runtime_diagnostic_output_helper|diagnostic_sink' perl/LinkedSpec/ActionIR/ControlFlow.pm rust/linkedspec-runtime/src dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

Recognition is not semantic parity. The planning audit established four independent mechanisms: arity/invalid
calls, evaluation count/order, scalar/message formatting, and transport/process control.

| Backend | Arity and evaluation | Current formatting/transport |
| --- | --- | --- |
| Perl | Exact helper arities reject before argument evaluation. Valid calls evaluate every argument exactly once left-to-right; `print_each` snapshots its target and decorations before iterating. | Native parsers deliver typed `LinkedSpec::RuntimeDiagnosticOutputEvent` objects through an optional parse-scoped sink. No sink is quiet; sink failures and typed immediate exit propagate without parser-error rewriting. |
| Rust | Exact helper arities reject before effects. Valid calls evaluate every argument once left-to-right. | Native top/direct-value execution accepts an optional typed sink; absent sinks are quiet, events preserve exact call/item formatting, and sink/runtime/exit outcomes remain distinct. |
| Dart | All authored arguments evaluate once left-to-right; no helper-specific arity check. | Every value is discarded and no diagnostic message exists. |
| Julia | All authored arguments evaluate once left-to-right; no helper-specific arity check. | `print`/`say` concatenate into one low trace record; `print_each` emits one trace record per item but defaults missing prefix to empty and missing suffix to newline. Extra arguments are evaluated then ignored for `print_each`. |
| Lua | `print`/`say` require at least one argument; `print_each` requires 2/3. All arguments evaluate exactly once left-to-right. | One synchronous typed `RuntimeDiagnosticOutputEvent` is delivered per `print`/`say` call or array item. Messages carry helper, rule, and exact Unicode text; missing sink is quiet and sink failure propagates immediately. |

The `.5.1.0` primary-process arity probe remains the pre-repair baseline: all backends except Lua accepted
zero-argument `print`/`say`; invalid `print_each` arities took different paths; and Perl could leak host output or
swallow a raw generated-handler error. Perl `.5.1.2` and Rust `.5.1.3` now reject those arities through typed
native seams before effects, and sinkless execution stays quiet. Other backend and generated/CLI projections
retain their separate owners.

Before `.5.1.2`, Perl's reference lowering was not a once-only oracle here. The toolbox lowered:

```text
print_each(items, set(left, num_add(left, 1)), set(right, num_add(right, 1)))
```

to a host `foreach` whose prefix and suffix assignments were inside the loop. With `items=["a","b"]`, the exact
native probe emitted `1a12b2` and returned `[2,2]`; ordinary `print` emitted `11` and returned `[1,1]`. Perl now
evaluates both decorations once before event iteration, so those bytes remain historical root-cause evidence.

Pre-repair host process control was coupled too: `say("before"); exit_now(23); say("after")` made the Perl primary
command write `before\n` and exit 23 directly. Perl now delivers only the preceding event to an installed native
sink and raises `LinkedSpec::RuntimeExitNow`; Rust likewise delivers that event through
`RuntimeDiagnosticOutputSink` and returns typed `RuntimeExitNow` from its native event API. Sinkless execution
emits no helper text. Dart, Julia, and sinkless Lua also emit no helper text, while Lua native execution with a
sink delivers the pre-exit event and raises typed status 23.

Generated and primary routes remain separately relevant. Perl's live native parser is generated handler code and
now owns the native sink slot, but independently emitted execution entrypoints do not yet expose that option. Rust,
Dart, and Julia generated APIs currently expose trace entrypoints but no diagnostic sink; Lua generated execution
already copies `diagnostic_sink` options. All five primary adapters deliberately invoke native execution without
a rich diagnostic sink, and ADR `0024`'s canonical phase trace is independent. Rust's native helper bypass is
repaired, but generated Rust entrypoints do not yet expose the sink option owned by `.5.1.7`.

This is a parity prerequisite, not permission to add another backend-local convention. Planning leaf `.5.1.0`
and neutral contract `.5.1.1` are complete; Perl native `.5.1.2` and Rust native `.5.1.3` are completed rollout
legs. `.5.1.4-.6` own Dart, Julia, and Lua native alignment; `.5.1.7` owns generated propagation plus quiet primary commands;
`.5.1.8` owns the symmetric recurring gate; and `.5.1.9` owns public no-drift closeout before the structured-format
program may execute.

Related facts: [[perl-diagnostic-output-events]], [[rust-diagnostic-output-events]],
[[lua-diagnostic-output-events]], [[julia-diagnostic-output-helpers]],
[[trace-cross-variant-capability-contract]].

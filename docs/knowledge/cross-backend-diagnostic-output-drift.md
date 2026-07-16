---
id: cross-backend-diagnostic-output-drift
title: Native and generated diagnostic helpers share one event contract across five backends
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
evidence: "FUTURE-PARITY-BACKLOG.5.1.0 establishes the five-backend baseline with Knowledge Map/toolbox/native/process evidence. FUTURE-PARITY-BACKLOG.5.1.2-.6 admit Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT against exact arity-before-effects, once-only arguments, typed synchronous caller-owned events, quiet default execution, preserved sink failure, and typed immediate exit. FUTURE-PARITY-BACKLOG.5.1.7 propagates the same outcomes through every generated direct/traced entrypoint and locks quiet canonical primary projection across five backends, two environments, and 62 cases."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{print_each(items, \"<\", \">\")}), qq{\\n}' && rg -n 'lower_(say|print|print_each)_statement|RuntimeDiagnosticOutput|_evaluateValues|_call_runtime_diagnostic_output_helper|diagnostic_sink' perl/LinkedSpec/ActionIR/ControlFlow.pm rust/linkedspec-runtime/src dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

Recognition is not semantic parity. The planning audit established four independent mechanisms: arity/invalid
calls, evaluation count/order, scalar/message formatting, and transport/process control.

| Backend | Arity and evaluation | Current formatting/transport |
| --- | --- | --- |
| Perl | Exact helper arities reject before argument evaluation. Valid calls evaluate every argument exactly once left-to-right; `print_each` snapshots its target and decorations before iterating. | Native parsers deliver typed `LinkedSpec::RuntimeDiagnosticOutputEvent` objects through an optional parse-scoped sink. No sink is quiet; sink failures and typed immediate exit propagate without parser-error rewriting. |
| Rust | Exact helper arities reject before effects. Valid calls evaluate every argument once left-to-right. | Native top/direct-value execution accepts an optional typed sink; absent sinks are quiet, events preserve exact call/item formatting, and sink/runtime/exit outcomes remain distinct. |
| Dart | Exact helper arities reject before effects. Valid calls evaluate every argument once left-to-right. | Native parse/execute and traced aliases deliver exact typed events through an optional sink; absent sinks are quiet, and caller failure/exit retain their types. |
| Julia | Exact helper arities reject before effects. Valid calls evaluate every argument once left-to-right. | Native parse/execute and traced aliases deliver exact typed events through an optional sink; absent sinks are quiet, caller failure/exit retain their types, and rich events stay out of native trace. |
| Lua | `print`/`say` require at least one argument; `print_each` requires 2/3. All arguments evaluate exactly once left-to-right. | Native parse/execute and traced aliases deliver exact events on PUC Lua and LuaJIT; missing sinks are quiet, arbitrary sink failures retain identity, and `RuntimeExitNow` is distinct typed control. |

The `.5.1.0` primary-process arity probe remains the pre-repair baseline: all backends except Lua accepted
zero-argument `print`/`say`; invalid `print_each` arities took different paths; and Perl could leak host output or
swallow a raw generated-handler error. Perl `.5.1.2`, Rust `.5.1.3`, Dart `.5.1.4`, Julia `.5.1.5`, and Lua
`.5.1.6` now reject those arities through typed native seams before effects, and sinkless execution stays quiet.
Generated/CLI projections remain separate.

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
`RuntimeDiagnosticOutputSink` and returns typed `RuntimeExitNow` from its native event API. Dart and Julia likewise
deliver the pre-exit event through their parse-scoped sinks and throw typed exit. Sinkless execution emits no
helper text; Lua native execution with a sink also delivers the pre-exit event and raises typed status 23.

Generated and primary routes are now aligned too. Perl's independently emitted `Execute`, `ExecuteWithTrace`, and
`Get` accept invocation options containing `diagnostic_sink`. Rust adds paired typed-v1 and compatibility
direct/traced functions because existing Rust signatures cannot gain optional arguments. Dart and Julia add
optional named/keyword sinks to their emitted direct/traced functions. Lua retains its option-bearing direct/
traced functions and now preserves caller sink failures plus typed exit across generated-source attribution.
Every generated route retains quiet sinkless execution, exact event order and result neutrality, native trace-role
separation, ordinary generated-source attribution, caller failure identity, and typed immediate exit.

All five primary adapters deliberately install no rich sink. The shared `success_diagnostic_helpers_quiet` case
executes `print`, `say`, and `print_each` yet admits only canonical JSON `"visible"` plus one newline on stdout,
empty stderr, and status 0. It passes unchanged for all five commands under default and POSIX environments as case
62/62. ADR `0024`'s independent phase-trace cases pass unchanged and contain no rich diagnostic event.

This is a parity prerequisite, not permission to add another backend-local convention. Planning leaf `.5.1.0`
and neutral contract `.5.1.1` are complete; all five native `.5.1.2-.6` legs and generated/primary `.5.1.7` are
complete. `.5.1.8` owns the symmetric recurring gate, and `.5.1.9` owns public no-drift closeout before the
structured-format program may execute.

Related facts: [[perl-diagnostic-output-events]], [[rust-diagnostic-output-events]],
[[dart-diagnostic-output-events]], [[lua-diagnostic-output-events]], [[julia-diagnostic-output-helpers]],
[[trace-cross-variant-capability-contract]].

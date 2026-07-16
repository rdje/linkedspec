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
evidence: "FUTURE-PARITY-BACKLOG.5.1.0 re-runs the Knowledge Map inventory, LinkedSpec::call_spec_handler_subst/Get/dump_parser_source, native runtime tests/probes, and exact five-command process probes. Perl host lowering repeats print_each prefix/suffix effects per item, leaves invalid print_each calls raw, emits non-UTF-8 host bytes/warnings through the strict primary command, and lets host exit bypass canonical failure framing. Rust eagerly evaluates then writes separate stderr lines and ignores decoration. Dart eagerly discards. Julia emits joined messages through low trace with permissive arity and newline default. Lua emits typed synchronous caller-owned events with exact arity and quiet default. The audit splits FUTURE-PARITY-BACKLOG.5.1.1-.9 before behavior code."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{print_each(items, \"<\", \">\")}), qq{\\n}' && rg -n 'lower_(say|print|print_each)_statement|eprintln!|_evaluateValues|_call_runtime_diagnostic_output_helper|diagnostic_sink' perl/LinkedSpec/ActionIR/ControlFlow.pm rust/linkedspec-runtime/src/engine.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

Recognition is not semantic parity. The planning audit established four independent mechanisms: arity/invalid
calls, evaluation count/order, scalar/message formatting, and transport/process control.

| Backend | Arity and evaluation | Current formatting/transport |
| --- | --- | --- |
| Perl | `print()`/`say()` fall through to zero-argument host built-ins. `print_each` lowers only at arity 2/3; other calls remain raw and fail inside the generated handler. `print_each` prefix/suffix expressions execute once **per item**, not once per call. | Host `print`/`say`/`foreach` write directly. Aggregate arguments expose host references. Unicode helper output can place invalid mixed-encoding bytes on the strict primary command's stdout and emit `Wide character` warnings. |
| Rust | All authored arguments evaluate once left-to-right; no helper-specific arity check. | `print`/`say` write every argument as a separate stderr line. `print_each` writes one bare item per stderr line and ignores evaluated prefix/suffix. |
| Dart | All authored arguments evaluate once left-to-right; no helper-specific arity check. | Every value is discarded and no diagnostic message exists. |
| Julia | All authored arguments evaluate once left-to-right; no helper-specific arity check. | `print`/`say` concatenate into one low trace record; `print_each` emits one trace record per item but defaults missing prefix to empty and missing suffix to newline. Extra arguments are evaluated then ignored for `print_each`. |
| Lua | `print`/`say` require at least one argument; `print_each` requires 2/3. All arguments evaluate exactly once left-to-right. | One synchronous typed `RuntimeDiagnosticOutputEvent` is delivered per `print`/`say` call or array item. Messages carry helper, rule, and exact Unicode text; missing sink is quiet and sink failure propagates immediately. |

The exact primary-process arity probe confirms the operational consequence. With a trailing `return("ok")`, all
backends except Lua accept zero-argument `print`/`say`; Perl alone places a newline before JSON for `say()`.
One-argument and four-argument `print_each` return primary JSON `null` on Perl after the raw generated-handler
failure is swallowed, write `x` to Rust stderr, stay quiet and return `"ok"` on Dart/Julia, and fail the Lua
primary invocation. A wrong-kind scalar target is quiet on Rust/Dart/Julia/Lua but takes Perl's raw failure path.

Perl's reference lowering is not a once-only oracle here. The toolbox lowers:

```text
print_each(items, set(left, num_add(left, 1)), set(right, num_add(right, 1)))
```

to a host `foreach` whose prefix and suffix assignments are inside the loop. With `items=["a","b"]`, the exact
native probe emits `1a12b2` and returns `[2,2]`; ordinary `print` emits `11` and returns `[1,1]`. This contradicts
the existing public once-only design sentence and must be repaired, not copied.

Host process control is coupled too. `say("before"); exit_now(23); say("after")` makes the Perl primary command
write `before\n` and exit 23 directly. Rust writes `before\n` to stderr before its canonical invocation failure;
Dart, Julia, and sinkless Lua emit no helper text and return canonical exit 1. Lua native execution with a sink
delivers exactly the pre-exit event and then raises its typed status-23 exception.

Generated and primary routes are separately relevant. Perl's live native parser is generated handler code. Rust,
Dart, and Julia generated APIs currently expose trace entrypoints but no diagnostic sink; Lua generated execution
already copies `diagnostic_sink` options. All five primary adapters deliberately invoke native execution without
a rich diagnostic sink, and ADR `0024`'s canonical phase trace is independent. Perl and Rust still leak solely
because their native helpers bypass caller-owned transport.

This is a parity prerequisite, not permission to add another backend-local convention. Planning leaf `.5.1.0`
is complete without behavior changes. `.5.1.1` now owns the neutral executable contract; `.5.1.2-.6` own Perl,
Rust, Dart, Julia, and Lua native alignment; `.5.1.7` owns generated propagation plus quiet primary commands;
`.5.1.8` owns the symmetric recurring gate; and `.5.1.9` owns public no-drift closeout before the structured-format
program may execute.

Related facts: [[lua-diagnostic-output-events]], [[julia-diagnostic-output-helpers]],
[[trace-cross-variant-capability-contract]].

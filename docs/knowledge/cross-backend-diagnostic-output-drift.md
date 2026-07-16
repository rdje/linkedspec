---
id: cross-backend-diagnostic-output-drift
title: Current backends recognize diagnostic helpers but do not yet share one output contract
answers:
  - are print say and print_each identical across all backends
  - what diagnostic output drift exists between Perl Rust Dart Julia and Lua
  - which task owns diagnostic output normalization
  - why is FUTURE-PARITY-BACKLOG.5.1 needed
date: 2026-07-15
status: current
tags: [parity, helpers, diagnostic-output, Perl, Rust, Dart, Julia, Lua, FUTURE-PARITY-BACKLOG]
evidence: "The LUA-BACKEND-PARITY.4.3.8 source audit finds one shared recognized print/say/print_each family but divergent execution: Perl lowers host print/say and prefix/item/optional-suffix print_each; Rust writes each argument/item as stderr lines and ignores print_each prefix/suffix; Dart evaluates and discards; Julia trace-routes concatenated output but defaults an omitted print_each suffix to newline; Lua now emits typed caller-owned events using Perl-reference formatting. FUTURE-PARITY-BACKLOG.5.1 owns a neutral contract and five-backend alignment before structured-format execution."
reverify: "rg -n 'lower_(say|print|print_each)_statement|say.*print.*print_each|case .print.|_call_runtime_diagnostic_output_helper|evaluate_runtime_diagnostic_output' perl/LinkedSpec/ActionIR/ControlFlow.pm rust/linkedspec-runtime/src/engine.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

Recognition is not semantic parity. The five current backends presently differ as follows:

| Backend | Current execution |
| --- | --- |
| Perl | Lowers to host `print`/`say`; `print_each` emits prefix + item + optional suffix. |
| Rust | Writes each argument/item as a separate stderr line; `print_each` ignores authored prefix/suffix. |
| Dart | Evaluates arguments but emits no diagnostic message. |
| Julia | Concatenates and trace-routes messages; an omitted `print_each` suffix defaults to newline. |
| Lua | Delivers typed caller-owned events, stays quiet without a sink, and follows Perl-reference formatting. |

This is a parity prerequisite, not permission to add another backend-local convention. With Lua `.8.4` complete,
pending `FUTURE-PARITY-BACKLOG.5.1` is the next clean-pivot candidate to define exact
arity, scalar text, newline/prefix/suffix behavior,
wrong-kind handling, event grouping/order, sink/trace routing, quietness, error propagation, Unicode, parse-result
neutrality, and `exit_now` interaction. It then aligns native and generated/CLI paths where applicable before the
structured-format program may execute.

Related facts: [[lua-diagnostic-output-events]], [[julia-diagnostic-output-helpers]],
[[trace-cross-variant-capability-contract]].

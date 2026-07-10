---
id: julia-exit-now-control
title: Julia terminating exit_now runtime control
answers:
  - does Julia support exit_now
  - what status does Julia exit_now use by default
  - why does Julia simenv fail with exit_now in begin_end_blocks
  - is Julia exit_now a value helper or terminating control
date: 2026-07-10
status: current
tags: [julia, runtime, control, exit-now, diagnostics, corpus, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.4.5.1 adds Julia runtime dispatch for exit_now(...). The optional first status expression is evaluated; absent or nonnumeric status defaults to Rust-compatible 1. The helper immediately throws RuntimeInterpreterException with the current rule in its message, and the established runtime wrapper attaches structured runtime_execution top/rule/spec attribution. Focused tests lock exit_now(7), default exit_now(1), unreachable successor statements, and structured diagnostics. simenv_multiline_value advances from unsupported exit_now to deliberate exit_now(1) in rule begin_end_blocks because its earlier statement-form substr mutation has not yet changed the block-name scalar; JULIA-BACKEND-PARITY.6.2.4.5.2 owns that prerequisite. Full Pkg.test() passes with 801 assertions, shipped smoke remains 25/31, and status is runtime-corpus-exit-now."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

`exit_now(...)` is immediate parser-flow termination. It does not return a value and no later statement in the
action block executes.

Julia evaluates the optional first argument as the exit status. A numeric argument is preserved; an absent or
nonnumeric argument uses status `1`, matching the Rust backend contract. The thrown message is
`exit_now(<status>) in rule <rule>`. Existing interpreter wrappers attach the structured diagnostic rather than
creating a second fatal-error path.

At the `.6.2.4.5.1` boundary, simenv's fatal failure proved that the helper executed rather than exposing an
`exit_now(...)` defect. `.6.2.4.5.2` has since implemented the earlier statement-form `substr(...)` mutation, so
the BEGIN/END block names normalize before comparison and simenv passes.

Related fact: [[julia-statement-regex-mutation]].

---
id: julia-trace-controls-sinks
title: Julia runtime exposes trace controls, structured events, sinks, and traced entrypoints
answers:
  - does Julia have trace controls
  - how does Julia configure trace sinks
  - what is LinkedSpecTraceConfig in Julia
  - which Julia runtime entrypoints accept tracing
  - does Julia tracing preserve parse output
  - what trace controls does Julia expose beneath runtime instrumentation
date: 2026-07-10
status: current
tags: [julia, trace, runtime, diagnostics, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.5.2 adds julia/src/trace/Trace.jl, public trace exports, optional runtime emitter plumbing, runtime_parse_with_trace/runtime_execute_with_trace, and 29 focused assertions in julia/test/runtests.jl. The full 617-assertion suite proves levels/environment config, event primitives, stdout/route/mirror sinks, reset, default quiet, parse-scope routing, and result preservation."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia trace controls live in `julia/src/trace/Trace.jl` and are exported from
`LinkedSpecJulia`.

The control surface includes ordered `LinkedSpecTraceLevel` values equivalent
to none/low/medium/high/full/debug, named aliases and numeric thresholds,
`LinkedSpecTraceConfig`, immutable `with_trace_*` updates, and
`trace_config_from_environment(...)` for the documented
`LINKEDSPEC_TRACE_*` controls.

`LinkedSpecTraceEmitter` records structured enter/exit/decision/mark/dump/log
events and rendered lines. It routes output to stdout, a routed file, or both;
routed files support reset/truncate at emitter creation.

`runtime_parse(...)` and `runtime_execute(...)` accept an optional emitter.
`runtime_parse_with_trace(...)` and `runtime_execute_with_trace(...)` construct
one from config. Disabled/default execution stays quiet, and traced parse
results equal untraced results.

At `.4.5.2`, runtime tracing emitted the top-level parse scope only. `.4.5.3`
now adds rule, regex, dispatch, lifecycle, recursion, cursor, and source-boundary
instrumentation while retaining this control/sink surface. Final trace parity
remains gated by `.4.5.4` no-drift.

Related facts: [[julia-runtime-structured-diagnostics]],
[[julia-runtime-diagnostics-trace-split]], [[julia-runtime-trace-events]],
[[dart-trace-controls-sinks]],
[[trace-cross-variant-capability-contract]].

---
id: julia-trace-controls-sinks
title: Julia exposes shared trace controls sinks and traced native pipeline entrypoints
answers:
  - does Julia have trace controls
  - how does Julia configure trace sinks
  - what is LinkedSpecTraceConfig in Julia
  - which Julia runtime entrypoints accept tracing
  - does Julia tracing preserve parse output
  - what trace controls does Julia expose beneath runtime instrumentation
  - which Julia frontend compiler and staged APIs accept tracing
date: 2026-07-10
status: current
tags: [julia, trace, runtime, diagnostics, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.5.2 adds trace controls/sinks; .7.3.2.1 spans the native pipeline; .7.3.2.4 completes CLI stdout/route/mirror/file/reset/emoji behavior. The current suite is 1,017 and corpus 99/99."
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
routed files support reset/truncate at emitter creation. Reset also truncates a
selected file in stdout mode, where later trace is not appended. The shared
renderer applies level-specific emoji when enabled.

`runtime_parse(...)` and `runtime_execute(...)` accept an optional emitter.
`runtime_parse_with_trace(...)` and `runtime_execute_with_trace(...)` construct
one from config. Disabled/default execution stays quiet, and traced parse
results equal untraced results.

`parse_spec(...)`, `validate_spec(...)`, `compile_spec(...)`, function-shell
projection/parsing, and staged job dispatch/stitching now accept and propagate
the same optional emitter. They do not maintain a separate frontend trace sink
or traced implementation.

At `.4.5.2`, runtime tracing emitted the top-level parse scope only. `.4.5.3`
now adds rule, regex, dispatch, lifecycle, recursion, cursor, and source-boundary
instrumentation while retaining this control/sink surface. `.4.5.4` closes the
scoped runtime no-drift proof, and `.7.3.2.1` later closes the frontend/compiler/
function-shell/staged coverage required by primary CLI trace options.

Related facts: [[julia-runtime-structured-diagnostics]],
[[julia-runtime-diagnostics-trace-split]], [[julia-runtime-trace-events]],
[[julia-diagnostics-trace-boundary]],
[[dart-trace-controls-sinks]],
[[trace-cross-variant-capability-contract]], [[julia-frontend-compiler-staged-trace-events]],
[[julia-primary-cli-failure-trace-routing]].

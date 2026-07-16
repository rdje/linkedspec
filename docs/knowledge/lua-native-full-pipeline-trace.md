---
id: lua-native-full-pipeline-trace
title: Lua passes one caller-owned emitter through the complete native parser pipeline
answers:
  - does Lua have full pipeline trace
  - how does Lua trace native spec loading compilation and runtime
  - which Lua APIs accept a trace emitter
  - what Lua trace topics identify construction phases
  - does Lua retain the trace emitter in compiled or engine state
  - does Lua full pipeline tracing change results or errors
  - what is native-full-pipeline-trace-v1
  - what did LUA-BACKEND-PARITY 5.3.2 implement
date: 2026-07-15
status: current
tags: [lua, trace, native-api, parser, compiler, staged-parsing, runtime, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.3.2 adds one optional caller-owned emitter across every existing native pipeline owner. PUC Lua and LuaJIT pass 155/155 with exact ordered topics, filters, routed sinks, balanced errors, no hidden factory calls, and result identity."
evidence_update_2026_07_15_no_drift: "LUA-BACKEND-PARITY.5.3.3 confirms exact API/status/test/contract/book/KM agreement without source or census change, closes parents .5.3/.5, and activates corpus .6.1."
reverify: "bash tools/run_lua_local.sh && rg -n 'lua_(io|frontend|compiler|staged|runtime):|options\.trace|trace = emitter' lua/src/linkedspec lua/test/run.lua lua/README.md docs/linkedspec-book/src/public-api/{trace-api,native-spec-loading}.md"
---

`LUA-BACKEND-PARITY.5.3.2` closes the Lua construction-to-runtime trace gap. A caller creates one
`LinkedSpecTraceEmitter`, stores it in `spec_load_options(...)`, and passes that same identity explicitly to loaded
engine creation and `runtime_parse(...)`. Inline parse, validation, compile, function parser/shell, user-function
registry, staged-dispatch, and runtime-engine APIs likewise accept an optional `trace` field.

High-level scopes cover `lua_io:*`, `lua_frontend:*`, `lua_compiler:*`, `lua_staged:*`, and engine/runtime
`lua_runtime:*` topics. Medium decisions cover resolution candidates, loaded content, parser-cache choice,
function projection/registry entries, compiled rules/dependency regex state, normalized staged queues, each staged
resolve/load/compile/execute phase, and body stitching. Existing detailed interpreter rule/branch/position events
remain unchanged.

The emitter is observational state, not compiled state. `LoadedCompiledSpec`, `CompiledSpec`, and runtime engines
do not retain it, and no construction owner calls `trace_emitter(...)`. The caller therefore controls sink lifetime
and must pass the emitter again for runtime events. Absent/disabled tracing is empty; low filters the medium/high
construction stream; medium admits decisions; high and above admit balanced scopes. Error scopes close before the
original typed value is rethrown. Focused proof locks exact routed topic order, zero hidden factory calls, balanced
validation failure, unchanged `SpecPipelineError` JSON, and exact traced/untraced descriptor/runtime JSON on PUC
Lua and LuaJIT at 155/155. Public status at this trace boundary is `native-full-pipeline-trace-v1`; complete corpus
`.6.3` has since advanced it to `runtime-corpus-full` without changing trace behavior. Capability census expansion
remains owned solely by `.8.4`. No-drift `.5.3.3` closes parents `.5.3`/`.5` and hands off to corpus `.6.1`.

Related facts: [[lua-trace-controls-sinks]], [[lua-runtime-trace-events]],
[[lua-native-spec-pipeline]], [[lua-descriptor-trace-admission-split]],
[[trace-cross-variant-capability-contract]], [[lua-descriptor-trace-closeout]], [[lua-full-corpus-gate]].

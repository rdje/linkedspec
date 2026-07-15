---
id: lua-trace-controls-sinks
title: Lua exposes typed trace controls caller-owned sinks and traced runtime entrypoints
answers:
  - does Lua have trace controls
  - how does Lua configure trace sinks
  - what trace environment variables does Lua support
  - which Lua runtime entrypoints accept tracing
  - does Lua tracing preserve parse output
  - what events does the Lua trace emitter expose
  - where is Lua runtime tracing implemented
date: 2026-07-15
status: current
tags: [lua, trace, runtime, diagnostics, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.4.2 adds native levels/config/events/sinks and balanced parse-scope entrypoints at 128/128 on PUC Lua and LuaJIT; .4.4.3 separately owns deeper interpreter instrumentation."
reverify: "bash tools/run_lua_local.sh"
---

Lua trace controls live in `lua/src/linkedspec/trace.lua` and are exported from
the top-level `linkedspec` module.

The native control surface provides ordered none/low/medium/high/full/debug
levels, named aliases, numeric thresholds, immutable typed configs, and
`trace_config_from_environment(...)`. It recognizes
`LINKEDSPEC_TRACE_LEVEL` with `LINKEDSPEC_DUMP_VERBOSITY` fallback plus
`LINKEDSPEC_TRACE_FILE`, `LINKEDSPEC_TRACE_MIRROR_STDOUT`,
`LINKEDSPEC_TRACE_RESET_FILE`, and `LINKEDSPEC_TRACE_EMOJI`.

A caller-owned emitter records typed enter/exit/decision/mark/dump/log events
and rendered line snapshots. Output may go to stdout, a routed file, or both;
routed files support reset/truncate at emitter creation and append otherwise.
Optional emoji follow the event-level bucket. Disabled configuration records
and writes nothing.

`runtime_parse(...)` and `runtime_execute(...)` accept an emitter in the
options table as `trace`. `runtime_parse_with_trace(...)` and
`runtime_execute_with_trace(...)` accept a config, construct the emitter, and
preserve the caller's options table. At `.4.4.2`, runtime tracing emits only a
balanced `lua_runtime:parse` scope. Traced and untraced successful result JSON
is identical on PUC Lua and LuaJIT. Rule, regex, branch, lifecycle, cursor, and
source-boundary events remain the exclusive next owner `.4.4.3`; full native
frontend/compiler/function-shell/staged propagation remains dependency-gated
`.5.3`.

Related facts: [[lua-runtime-structured-diagnostics]],
[[lua-runtime-diagnostics-trace-split]], [[dart-trace-controls-sinks]],
[[julia-trace-controls-sinks]], [[trace-cross-variant-capability-contract]].

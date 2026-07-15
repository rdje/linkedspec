---
id: lua-runtime-diagnostics-trace-split
title: Lua diagnostics and trace work is split by mechanism and pipeline dependency
answers:
  - "how is Lua runtime diagnostics and trace work split"
  - "what does LUA-BACKEND-PARITY.4.4 implement"
  - "why does Lua full pipeline trace remain in 5.3"
  - "when will Lua trace frontend compiler function and staged phases"
  - "which Lua leaf adds structured runtime diagnostics"
  - "which Lua leaf adds trace controls and sinks"
  - "which Lua leaf adds runtime trace events"
date: 2026-07-15
status: current
tags: [lua, diagnostics, trace, runtime, staged-parsing, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.4.0; completed Dart .4.5 and Julia .4.5 plus later full-pipeline trace records"
reverify: "rg -n 'LUA-BACKEND-PARITY\\.4\\.4|LUA-BACKEND-PARITY\\.5\\.3' docs/tasks/LUA-BACKEND-PARITY.md && rg -n 'DART-BACKEND-PARITY\\.4\\.5|JULIA-BACKEND-PARITY\\.4\\.5' docs/tasks/{DART,JULIA}-BACKEND-PARITY.md"
---

`LUA-BACKEND-PARITY.4.4.0` separates two dependency epochs that the original parent sentence had combined.

The executable runtime epoch is owned under `.4.4`:

- `.4.4.1` adds neutral structured `RuntimeDiagnostic` payloads on typed runtime exceptions;
- `.4.4.2` adds ordered trace levels, configuration, event primitives, caller-owned sinks, and traced runtime
  entrypoints;
- `.4.4.3` instruments the existing interpreter with rule, regex, child-dispatch, lifecycle, recursion, cursor,
  source-boundary, mark, and capture events where applicable;
- `.4.4.4` closes dual-ABI, API, book, task, Knowledge Map, live-doc, and canonical no-drift without claiming more.

Full native-pipeline propagation remains `LUA-BACKEND-PARITY.5.3`. It depends on `.4.4` plus general staged-function
execution `.5.1` and native loading `.5.2`, then carries one caller-owned emitter through loading, source parsing,
validation, compilation, function-shell work, staged dispatch, and runtime. This is not a deferral of runtime
observability; it prevents trace from claiming owners that do not yet exist.

The order follows completed Dart and Julia evidence. Both variants first landed structured runtime diagnostics,
controls/sinks, and interpreter events. Their frontend/compiler/function/staged propagation was added later, after
the staged pipeline existed. Lua reuses that dependency-safe architecture.

The planning slice changes no Lua behavior or capability claim. At this boundary Lua already has a typed runtime
exception seam, parse-scoped rule stack, compiled action/source records, cursor/capture/mark state, and a per-parse
caller-owned option table; `.4.4.1` is the first active implementation leaf.

Related facts: [[trace-cross-variant-capability-contract]], [[dart-runtime-diagnostics-trace-split]],
[[dart-full-pipeline-trace-gap]], [[julia-runtime-diagnostics-trace-split]],
[[julia-frontend-compiler-staged-trace-events]], [[lua-backend-full-parity-plan]].

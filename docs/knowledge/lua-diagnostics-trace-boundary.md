---
id: lua-diagnostics-trace-boundary
title: Lua native runtime diagnostics and trace boundary is closed without a full-pipeline claim
answers:
  - is Lua diagnostics trace no drift closed
  - what is the Lua frontier after LUA-BACKEND-PARITY 4.4.4
  - does Lua have structured runtime diagnostics and trace events
  - does Lua claim full trace parity after diagnostics trace closeout
  - what remains before Lua full pipeline trace
date: 2026-07-15
status: current
tags: [lua, diagnostics, trace, runtime, task-tree, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.4.4 closes the scoped native runtime diagnostics/trace parent after exact API/source/test/public-doc inventory; PUC Lua and LuaJIT pass 129/129, and canonical local CI passes CLI 61x2 plus Phase 0 1..1031 in 608 seconds."
evidence_update_2026_07_15_full_pipeline: "LUA-BACKEND-PARITY.5.3.2 later completes caller-owned full native-pipeline propagation at 155/155 on both ABIs; the .4.4.4 statement remains its historical runtime-only boundary."
reverify: "bash tools/run_lua_local.sh && rg -n 'runtime-trace-events|LUA-BACKEND-PARITY\\.4\\.4\\.4|lua_runtime:(rule|regex_match|child_dispatch|lifecycle_block|recursion_guard|cursor_control|source_boundary|mark_capture)' lua/src lua/test lua/README.md README.md ROADMAP.md ROADMAP_V2.md docs/TASK_TREE.md docs/tasks/LUA-BACKEND-PARITY.md docs/linkedspec-book/src docs/knowledge"
---

`LUA-BACKEND-PARITY.4.4.4` closes Lua's native runtime diagnostics/trace
no-drift sweep without changing runtime code.

The closed boundary comprises:

- typed neutral runtime diagnostics with top/deepest-rule/handler attribution;
- ordered trace levels, immutable configuration and environment controls,
  structured event/scope primitives, and caller-owned stdout/routed-file/mirror
  sinks with reset/append behavior;
- direct-emitter and config-wrapper runtime entrypoints that stay quiet by
  default and preserve parse results;
- parse/rule scopes plus regex, action/blind dispatch, recursion, lifecycle,
  cursor, source-boundary, and governed mark/capture runtime events.

Public status remains the precise `runtime-trace-events`. Parent `.4.4` is
closed and staged-function/native-loading `.5.1` becomes active. This is not a
full native-pipeline trace claim: `.5.3` remains responsible for carrying one
caller-owned emitter through loading, frontend, validation, compilation,
function-shell, staged dispatch, and runtime after `.5.1` and `.5.2` create
those owners.

Related facts: [[lua-runtime-structured-diagnostics]],
[[lua-trace-controls-sinks]], [[lua-runtime-trace-events]],
[[lua-runtime-diagnostics-trace-split]],
[[trace-cross-variant-capability-contract]], [[lua-native-full-pipeline-trace]].

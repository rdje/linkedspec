---
id: lua-runtime-trace-events
title: Lua runtime emits structured rule branch dispatch lifecycle cursor boundary and mark trace events
answers:
  - what runtime trace events does Lua emit
  - does Lua trace regex match decisions
  - does Lua trace action and blind child dispatch
  - does Lua trace lifecycle blocks and recursion guards
  - does Lua trace cursor controls and capture boundaries
  - does Lua trace governed mark and capture positions
  - what did LUA-BACKEND-PARITY.4.4.3 implement
date: 2026-07-15
status: current
tags: [lua, runtime, trace, observability, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.4.3 instruments lua/src/linkedspec/interpreter.lua behind the optional emitter and adds focused traced/untraced identity proof in lua/test/run.lua; PUC Lua and LuaJIT pass 129/129."
reverify: "bash tools/run_lua_local.sh && rg -n 'lua_runtime:(rule|regex_match|child_dispatch|lifecycle_block|recursion_guard|cursor_control|source_boundary|mark_capture)' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

`LUA-BACKEND-PARITY.4.4.3` instruments the existing Lua interpreter behind the
optional caller-owned trace emitter; there is no parallel traced runtime.

At `high`, execution emits balanced parse/rule scopes and lifecycle-block
marks. At `debug`, it emits regex match/no-match decisions, action/blind
child-dispatch decisions, recursion-cutoff decisions, all four cursor-control
transitions, successful and unusable source-boundary events, governed helper
mark/capture positions, and post-mutation rule-slot capture/named-mark events.

Details retain rule, target, entry/alternative, byte-span, cursor, stack-depth,
lifecycle-line, boundary-span, helper, arity, and rule-slot identity where the
mechanism provides it. Public cursor/capture values remain Unicode-character
based; internal trace spans report the byte offsets used by the Lua runtime.

Disabled or absent emitters remain no-ops. Focused dual-ABI tests prove exact
traced/untraced result JSON across successful, no-match, action-dispatch,
blind-dispatch, and recursion-cutoff paths. The public mechanism status is
`runtime-trace-events`; full frontend/compiler/function/staged propagation is
still dependency-gated under `.5.3`.

Related facts: [[lua-trace-controls-sinks]],
[[lua-runtime-diagnostics-trace-split]], [[julia-runtime-trace-events]],
[[dart-runtime-trace-events]], [[trace-cross-variant-capability-contract]].

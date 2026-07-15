---
id: lua-logical-helper-execution
title: Lua and or not are eager boolean helpers over governed Lua truthiness
answers:
  - does Lua execute and or not
  - are Lua logical helpers eager or short circuit
  - what do empty Lua and or not return
  - does Lua not evaluate extra arguments
  - what truthiness do Lua logical helpers use
date: 2026-07-15
status: current
tags: [lua, runtime, helpers, logical, truthiness, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.9.1 adds one interpreter logical-family evaluator. It evaluates all authored arguments once left-to-right, then composes through runtime_truthy. Empty and/or/not return false/false/true; not evaluates extras but negates its first value. Focused proof includes decisive-operand side effects, scalar zero text, empty aggregates, boolean identity, and receiver with continuation. tools/run_lua_local.sh passes 123/123 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh && rg -n 'LOGICAL_HELPERS|evaluate_runtime_logical|runtime logical helpers are eager' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua evaluates logical helpers in two phases: first every authored argument runs exactly once from left to right;
then the retained values are composed through the same `runtime_truthy` function used by Lua controls.

- `and(values...)` is false for no values and true only when every value is truthful.
- `or(values...)` is false for no values and true when at least one value is truthful.
- `not(values...)` is true for no values and otherwise negates the first value; any extra values are still eagerly
  evaluated for their side effects.

Results are real booleans. They remain ordinary values and can feed a compatible continuation such as `.with()`.
Lua's current truthiness treats scalar `"0"` as false and empty arrays/harrays as true. This leaf deliberately does
not select a global policy: `FUTURE-PARITY-BACKLOG.5.2` owns cross-backend truthiness, arity, Dart evaluation and
empty-`and`, and Perl keyword-lowering normalization.

Related facts: [[lua-exhaustive-runtime-call-audit]], [[cross-backend-condition-truthiness-drift]],
[[julia-logical-helper-execution]], [[lua-runtime-lazy-inline-controls]].

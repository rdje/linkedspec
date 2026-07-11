---
id: lua-runtime-rule-interpreter
title: Lua runtime interpreter executes compiled modes, lifecycle flow, local child dispatch, and guarded repetition
answers:
  - where is the Lua runtime interpreter
  - does Lua execute compiled LinkedSpec rules in memory
  - which rule modes does Lua execute
  - does Lua support action and blind child dispatch
  - does Lua run lifecycle blocks in order
  - how do Lua retv and direct output work
  - does Lua next advance a rule iteration
  - does Lua support exit_now
  - are Lua rule stores local across child calls
  - how does Lua guard recursion and zero progress
date: 2026-07-11
status: current
tags: [lua, runtime, interpreter, dispatch, lifecycle, control-flow, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.2 adds lua/src/linkedspec/interpreter.lua and exports runtime_engine(...), runtime_parse(...), runtime_execute(...), typed results/events/errors, and JSON projection. lua/test/run.lua locks default/AND/OR/repetition modes, action/blind children, lifecycle order, local stores, retv, return/next/exit_now, bounds, cursors, direct output, false/null identity, recursion, zero progress, and typed failures. tools/run_lua_local.sh passes 66/66 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh"
---

## Fact

Lua compiled-rule execution lives in `lua/src/linkedspec/interpreter.lua` over
`CompiledSpec` and the native-PCRE2 match/register layer.

`runtime_engine(compiled, options)` accepts seek/consume mode and a positive
safety limit. `runtime_parse(engine, input)` and its `runtime_execute` alias
execute default, Single, AND, OR, optional, star/plus, and bounded modes through
regex or blind paths. Action/blind children inherit entry match state, return
through `retv`, and cannot leak scalar/array/harray writes into their caller.
Applicable lifecycle payloads execute in `I`, `LS`, `LE`, `IT`, `EX`, `LX`, `E`
order and produce typed event records.

The dispatch-facing evaluator supports literal/four-kind values, narrow stores
and accumulators, child `call`/`push`, entry/local match text, explicit
`return(...)` and `return_undef()`, iteration-correct `next()`, and immediate
typed `exit_now(status)`. Lua boolean fallback idioms are avoided at value
boundaries so `false` remains distinct from `json.null`.

Repetition enforces minimum/maximum bounds, zero-progress termination, and the
configured iteration fence. Same-rule/slot/cursor recursion returns a clean
non-match. `RuntimeParseResult` retains matched/value state, the neutral
one-element direct-output wrapper, final byte/code-unit and character cursors,
and lifecycle events. Broader helper/value/control semantics remain owned by
`LUA-BACKEND-PARITY.4.3`.

Related facts: [[lua-runtime-matching-state]], [[lua-compiled-spec-state]],
[[julia-runtime-rule-interpreter]], [[dart-runtime-rule-interpreter]],
[[spec-lifecycle-retv-order]], [[lua-actionir-ast-parser]].

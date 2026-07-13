---
id: lua-runtime-array-mutation-child-flow
title: Lua array mutation and action-edge child push share one typed binding seam
answers:
  - "does Lua support push child target and index forms"
  - "does Lua action edge push reuse the cached child result"
  - "does Lua expose an implicit rule accumulator"
  - "does Lua support fluent action edge push into an explicit target"
  - "do Lua array mutations return independent updates"
date: 2026-07-12
status: current
tags: [lua, runtime, arrays, mutation, action-edge, accumulator, uniform-binding, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.4.4 types rule accumulators as json.array values, exposes current and otherwise-absent compiled-rule accumulators through lookup_binding, and routes child push through dispatch_edge_child plus append_array_binding in lua/src/linkedspec/interpreter.lua. Focused tests in lua/test/run.lua lock four whole/indexed implicit/explicit forms, fluent implicit/explicit action-edge push, wrong-kind fields, and the existing append/end/split/static-precedence contract. PUC Lua 5.4 and LuaJIT pass 98/98 through tools/run_lua_local.sh."
reverify: "bash tools/run_lua_local.sh && rg -n 'accumulator_stack|literal_nonnegative_index|runtime child push' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua rule accumulators are typed arrays. The current rule name reads that live array when no explicit binding of the
same name exists; another otherwise-absent compiled rule name reads as an empty array. Explicit typed bindings keep
precedence. All accumulator mutations pass through the same kind-checking and copied-result seam as ordinary bare
array bindings.

Action-edge child push supports the complete reference family:

- `push(Child)` appends the whole cached child result to the current rule accumulator.
- `push(Child, target)` appends the whole result to an explicit accumulator.
- `push(Child, index)` appends one zero-based child-result item to the current accumulator.
- `push(Child, target, index)` selects into an explicit accumulator.

After `-> Child`, fluent `.push` and `.push(target)` reuse that action edge's cached child result. A compiled-rule
first argument retains static child-call precedence; numeric disambiguation requires a literal nonnegative integer.
Wrong-kind explicit targets raise neutral `binding_kind_mismatch` fields.

Ordinary `push`/`+=`, three-argument mutable split, and array-end push/pop already share the same binding seam and
return independent updated arrays where the uniform-binding contract requires them. Pure two-argument `split`
remains copied and non-mutating.

Related facts: [[lua-uniform-binding-runtime]], [[uniform-binding-neutral-contract]],
[[uniform-binding-array-end-result-supersession]], [[rust-action-edge-child-return-dispatch]],
[[julia-action-edge-child-push]].

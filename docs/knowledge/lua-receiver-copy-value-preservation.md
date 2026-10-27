---
id: lua-receiver-copy-value-preservation
title: Lua receiver copy preserves values and rejects extra operands before effects
answers:
  - does Lua receiver copy reject extra arguments before effects
  - why do Lua copied Numbers and containers run incompatible operands
  - how does Lua preserve copied result kinds through fluent bridges
  - why did Lua meta copy flat hash count return zero
  - does Lua receiver copy preserve its receiver
  - does Lua receiver copy evaluate its receiver once
  - does Lua missing copy stay undefined
  - does Lua copy support harray array string and scalar continuations
  - how many Lua advanced corpus fixtures pass after receiver copy repair
date: 2026-10-27
status: copy arity repaired on available PUC5.5.1/LuaJIT; declared5.4/full admission open
tags: [lua, runtime, receiver, copy, fluent-chain, harray, LUA-BACKEND-PARITY]
evidence: "Value-copy repair LUA-BACKEND-PARITY.6.2.2; early arity repair TYPE-REFERENCE-BOOK.1.2.23.3.2.4."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/receiver_copy_arity_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/receiver_copy_arity_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/value_copy_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/value_copy_test.lua"
---

Receiver `value.copy()` copies the already evaluated current value recursively,
retaining array/harray/scalar kind and nulls for compatible continuations.
Function `copy(value)` copies its explicit operand; `copy()` stays null.
The original6.2.2 fix prevented receiver copy from falling through to zero-argument
function evaluation, which lost the receiver and reduced a later count to zero.
Its public controls establish nested container detachment and once-only receiver
evaluation; other backends have distinct domains/depths (see the book).

23.3.2.4 confirms extra receiver operands previously fell through to function
copy: the public probe returns [1,2], copying the operand after both effects.
Adding copy to existing first/last chain preflight returns null before either
effect. The registered receiver_copy_arity fixture checks direct/selected invalid
shapes and valid detachment/scalar/null/once-only controls on native/generated-plan/
fresh-emitted routes; the direct selected-value fixture also passes. Fresh matching
native products use available PUC5.5.1/LuaJIT, not declared PUC5.4.8; restoration
remains LUA-STARTUP-READING.2.2. Full fluent/copy admission stays open.

Historical July15 proof (not refreshed):6.2.2 passed164 focused checks and advanced
57/59; subsequent6.2.3-.4 reached59/59. Exact original commands, offsets and record
bytes remain at Git222db28a32a4047ca9fccba03927c3eb975a29bb for this path.
Related: [[terse-array-receiver-value-chains]], [[terse-hash-receiver-value-chains]].

October27 ADR0138 rollout4.2.2.5 preserves the healthy primitive/null producer
and copy_value recursion. Both safe hosts independently reproduce shared guard
null/0/SRKV and wrong-container[]/[1]/AKV on native/plan/fresh routes; method shape
and legacy accumulator/String payload controls pass before changes. The existing
evaluate_fluent_calls function initializes local copied_result from the direct
free-copy receiver and retains it after copy method links. Actual-kind guarding
now covers copied results before Array/Hash-only operands, including subsequent
scalar/default/container bridges. No unrelated consumer policy is normalized.
The registered value_copy_test.lua passes four strict JSON groups per route/host;
direct receiver arity, logical methods/source errors and selected-value controls
pass. Interpreter/runner loadfile compiles with no new module-level locals.
No old oracle, producer/depth/free-signature/callable/context or serialized-format
change; full admission and declared5.4 remain separate. The bounded approved
copy rollout across five backends is complete; next feature is queued direct-call
computed selection, with complete source/context/portable/canonical admission23.4.

---
id: lua-logical-helper-execution
title: Lua logical helpers and lazy controls share the neutral typed truth seam
answers:
  - does Lua execute and or not
  - are Lua logical helpers eager or short circuit
  - what do empty Lua and or not return
  - does Lua not evaluate extra arguments
  - what truthiness do Lua logical helpers use
  - what arity do Lua and or not accept
  - why is the Lua logical arity guard inlined
  - does Lua logical parity pass on PUC Lua and LuaJIT
date: 2026-07-15
status: current
tags: [lua, runtime, helpers, logical, truthiness, LUA-BACKEND-PARITY]
evidence: "FUTURE-PARITY-BACKLOG.5.2.6 aligns Lua with ADR 0043 after the earlier eager-family implementation. runtime_truthy now makes exactly null, false, numeric zero, empty string, and empty aggregates false for helpers and lazy controls. Built-in and/or one-plus plus not exact-one arity reject before effects with exact optional RuntimeDiagnostic fields; valid operands remain eager once-left-to-right booleans and registered functions retain precedence. The unchanged consumer passes 238/238 on PUC Lua and LuaJIT across native/reconstructed/generated-plan/loaded-emitted/primary roles; the authoritative Lua gate also passes diagnostic 119, full 177, CLI 62x2, and corpus 105/105. Canonical local CI passes reference CLI 62x2 and Phase 0 1..1031/609s. The arity guard stays inside the existing evaluator because another top-level local exceeds Lua's 200-local chunk limit."
reverify: "python3 tools/check_logical_helper_contract.py && bash tools/run_lua_local.sh && rg -n 'LOGICAL_HELPERS|evaluate_runtime_logical|runtime_truthy|helper_arity_mismatch' lua/src/linkedspec/interpreter.lua lua/test/logical_helper_contract_test.lua lua/test/run.lua"
---

Lua validates a built-in logical call before operand evaluation, then executes valid helpers in two phases: every
authored argument runs exactly once from left to right; the retained values are composed through the same
`runtime_truthy` function used by lazy Lua controls.

- `and(value, ...)` and `or(value, ...)` require at least one positional value.
- `not(value)` requires exactly one positional value.
- invalid arity raises `helper_arity_mismatch` before any operand effect;
- valid `and` is true only when every value is truthful, valid `or` when at least one is truthful, and `not`
  negates its one value.

Results are real booleans. They remain ordinary values and can feed a compatible continuation such as `.with()`.
Truthiness makes null, false, numeric zero, empty strings, and empty arrays/harrays false; other finite numbers,
all nonempty strings including `"0"` and `"false"`, nonempty aggregates, and codeblocks are true. A codeblock is
not invoked merely by testing it. Controls use this truth but retain selected-branch/body laziness.

The interpreter source chunk is already at the PUC Lua/LuaJIT 200-local ceiling. Adding a new module-local arity
validator makes the module fail to load, so the small guard is intentionally inlined at the start of the existing
logical evaluator. This is a source-structure constraint, not a semantic exception.

Related facts: [[lua-exhaustive-runtime-call-audit]], [[cross-backend-condition-truthiness-drift]],
[[julia-logical-helper-execution]], [[lua-runtime-lazy-inline-controls]].

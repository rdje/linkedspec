---
id: lua-logical-helper-execution
title: Lua logical helpers and lazy controls share the neutral typed truth seam
answers:
  - does Lua support logical receiver methods
  - why does Lua receiver not report zero arguments
  - does Lua execute and or not
  - are Lua logical helpers eager or short circuit
  - what do empty Lua and or not return
  - does Lua not evaluate extra arguments
  - what truthiness do Lua logical helpers use
  - what arity do Lua and or not accept
  - why is the Lua logical arity guard inlined
  - does Lua logical parity pass on PUC Lua and LuaJIT
date: 2026-10-27
status: focused current available hosts; full declared5.4 admission separate
tags: [lua, runtime, helpers, logical, truthiness, LUA-BACKEND-PARITY]
evidence: "TYPE23.3.23.5 receiver staging/shape and strict safe native-plan-fresh/direct checks; TYPE23.3.17.5 safe public producer/source-error/shared/rejected-effect/actual-Bool/direct neutral/default native-plan-fresh focused checks. Prior July5.2.6 complete role/ABI/gate proof and arity-inline history at Git1b92335386b2bbe929646e66623a722b4351cba2 for this path."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/logical_receiver_methods_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/logical_receiver_methods_test.lua"

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

The PUC Lua/LuaJIT interpreter has a 200-local chunk ceiling; a prior added module-local arity validator made it fail to load. The guard remains intentionally inlined in the existing logical evaluator. This historical source-structure constraint changes no semantics; current Boolean tracking adds no module-level local.

Related facts: [[lua-exhaustive-runtime-call-audit]], [[cross-backend-condition-truthiness-drift]],
[[julia-logical-helper-execution]], [[lua-runtime-lazy-inline-controls]].

Logical17.5 independently confirms canonical Bool/nested/eager LRC/strict
numeric-null producers and five typed source-error cases native/plan/fresh on
PUC5.5.1/LuaJIT before code. Shared RED has scalar-container[]; valid flow/source
snapshots already work. evaluate_fluent_calls now starts scalar_result for
actual boolean and preserves it after Boolean results, keeping actual container
release and free/named-context/truth/numeric/error policies. Both hosts pass
strict canonical JSON for shared kinds/defaults/bridges, LR/LRC/S rejection
prefixes/no-consumer-operand, selected/block/literal Bool boundaries, three
actual neutral fixtures and direct defaults. Source/runner load checks pass.
No malformed native pattern/full runner, declared5.4 or complete portable
admission; [[lua-native-readme-and-action-ast-reading]] owns the exclusion.

Ordinary logical23.5 adds generic value.and(rhs,...)/or(rhs,...)/not(). The old
fluent fallback omitted receiver and not raised actual_arity0. Existing evaluator
now stages a copied source (false counts as present), then all RHS before typed
composition; free calls retain original arity/errors. Positional and/or one-plus
RHS/not zero preflight rejects malformed ordinary calls before effects. Eight
strict JSON groups and two source-error cases pass all three routes on both safe
hosts; direct result and loadfile checks pass. Actual Bool guards/scopes and
value-preserving scalar copy remain. Full method/portable/declared5.4 admission
stays separate; scalar-copy domain reconciliation is TYPE1.2.1.4.2 next.

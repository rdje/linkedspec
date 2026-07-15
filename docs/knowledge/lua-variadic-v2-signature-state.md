---
id: lua-variadic-v2-signature-state
title: Lua preserves variadic-v2 signatures before binding rest arrays
answers:
  - "does Lua preserve variadic user function signatures"
  - "how does Lua resolve variadic function arity"
  - "does Lua execute variadic rest arrays yet"
  - "does Lua expose variadic function descriptors yet"
  - "what is Lua variadic v2 status"
date: 2026-07-15
status: current
tags: [lua, functions, variadic, callable-signature, staged-parsing, registry, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.1.3.1 passes 136/136 on PUC Lua and LuaJIT and the neutral signature checker passes 3 definitions, 9 calls, and 7 invalid definitions. Exact v1/v2 state crosses shell, AST, staged jobs, registry, contracts, and compiled state; runtime and descriptors retain explicit later owners."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_callable_signature_contract.py"
---

Lua preserves the exact callable-signature union without prematurely claiming complete variadic execution.
Fixed version 1 serializes only top-level `params` and exact `arity`. Variadic version 2 serializes only the typed
six-field `callable_signature`: kind, version, positional prefix, final rest name, minimum arity, and unbounded
maximum. Its internal positional mirror is derived from that signature and identity-checked through the
spec-owned shell, typed AST, staged jobs, registry entries, call contracts, and compiled state.

Registry resolution accepts any positional arity at or above `min_arity` and reports the portable expectation
`at least N`. Mixed v1/v2 storage, malformed fields, signature/sidecar drift, duplicate or reserved parameters,
and all seven neutral invalid definitions fail through typed diagnostic owners.

This state milestone now feeds completed native runtime `.5.1.3.2`, which binds extras into one fresh typed array
and passes the unchanged neutral fixture. Outward descriptor conversion still fails closed with
`variadic_user_function_descriptor_pending` until `.5.3`; generated preservation and execution remain `.8.1-.4`.

Related facts: [[variadic-user-function-contract]], [[lua-variadic-user-function-routing]],
[[lua-staged-function-execution-split]], [[lua-fixed-v1-user-function-runtime]],
[[lua-variadic-v2-runtime]].

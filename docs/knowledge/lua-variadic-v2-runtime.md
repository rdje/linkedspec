---
id: lua-variadic-v2-runtime
title: Lua variadic functions bind extras as fresh typed arrays
answers:
  - "does Lua execute variadic user functions"
  - "how does Lua bind variadic rest values"
  - "are Lua variadic rest arrays fresh"
  - "does Lua use host varargs for LinkedSpec functions"
  - "does Lua pass the neutral callable signature fixture"
date: 2026-07-15
status: current
tags: [lua, functions, variadic, rest-parameter, runtime, isolation, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.1.3.2 passes 139/139 on PUC Lua and LuaJIT. The unchanged linkedspec-callable-signature-v1 fixture passes exactly; supplemental proof covers eager order, empty/nonempty freshness, nested array/harray/null/boolean/codeblock identity, receiver chains, minimum arity, and keyword rejection."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_callable_signature_contract.py"
---

Lua executes native variadic-v2 user functions through the same staged ActionIR body runtime used by fixed-v1
functions. The caller evaluates every positional argument exactly once from left to right. The invocation frame
copies every evaluated value, binds fixed-prefix names through the ordinary isolated stores, then copies each extra
again into one new typed `json.array()` bound to the signature's final rest name.

This is LinkedSpec rest binding, not Lua `...`, a host splat, or closure dispatch. Empty calls receive a fresh empty
array; repeated calls do not alias. Nested arrays/harrays plus null, boolean, and structural codeblock identities
survive, while mutations cannot reach caller values or another invocation. Returned rest arrays are ordinary
values and can feed compatible receiver chains.

The exact neutral fixture in `capability_conformance/callable_signature_contract.json` passes unchanged. Calls
below the fixed-prefix minimum report `user_function_arity_mismatch` with `at least N`; keywords report
`user_function_keyword_arguments_unsupported`. Outward descriptor admission remains `.5.3`, and generated
preservation/execution remains `.8.1-.4`, so native execution does not retire the future capability by itself.

Related facts: [[variadic-user-function-contract]], [[lua-variadic-user-function-routing]],
[[lua-variadic-v2-signature-state]], [[lua-staged-function-execution-split]].

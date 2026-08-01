---
id: lua-callable-codeblock-dynamic-invocation
title: Lua invokes bound callable codeblocks through one dynamic caller-frame executor
answers:
  - "can Lua invoke a codeblock variable with cb parentheses"
  - "how does Lua resolve a bound callable codeblock"
  - "do Lua codeblock arguments evaluate left to right"
  - "does a Lua callable codeblock capture lexical state"
  - "how are Lua codeblock parameters restored"
  - "can a Lua codeblock mutate caller variables"
  - "can a Lua codeblock result use key access or chaining"
  - "what errors does Lua callable codeblock invocation report"
  - "does Lua allow recursive callable codeblocks"
  - "are name equals arguments Lua codeblock keywords"
date: 2026-08-01
status: current
tags: [lua, luajit, actionir, callable, codeblock, dynamic-scope, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.8.2 adds colon-keyword and evaluated-value-access ActionIR, post-static bound-name dispatch, one scoped dynamic executor, exact neutral failures, and an ordered active-codeblock stack. The same focused consumer passes 232 assertions on PUC Lua and LuaJIT; the complete Lua gate passes 177 legacy TAP groups per ABI, CLI 66x2, corpus 105/105, and 16 storage owners."
evidence_update_2026_08_01_emitted_identity: "FUTURE-PARITY-BACKLOG.11.8.3 closes the older built-in final-helper syntax seam: contextual, explicit, and bound final callbacks now enter the same executor. Anonymous callbacks omit helper-name recursion tracking, while callbacks passed by variable retain that binding identity through helper dispatch. Native/reconstructed/generated/fresh-emitted proof passes 449 assertions per ABI; at that boundary final five-backend admission was separately owned by .11.8.4."
evidence_update_2026_08_01_five_backend_admission: "FUTURE-PARITY-BACKLOG.11.8.4 admits that same focused consumer on PUC Lua and LuaJIT into the recurring five-backend driver, completes the 25-document public projection through 22 governance mutations, and removes the satisfied future.generic_final_codeblock exclusion without changing the 80/0/0 capability census."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/callable_codeblock_literal_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/callable_codeblock_literal_contract_test.lua && bash tools/run_lua_local.sh && bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py"
---

# Lua Callable-Codeblock Dynamic Invocation

Lua resolves `cb(args)` as a bound callable only after governed controls/helpers and registered user functions.
An explicitly bound scalar, array, or harray reports `value_not_callable`; an unbound call made from an active
codeblock reports portable `unknown_helper` rather than falling through to a Lua global or host exception.

Only top-level `name: value` call syntax becomes a typed keyword argument, and callable codeblocks reject it with
`codeblock_keyword_arguments_unsupported`. `name = value` remains a positional assignment expression. Positional
arguments evaluate exactly once from left to right and are recursively copied. Fixed parameters and an optional
final rest array enter `runtime_scoped_binding.run_frame`, which clears and restores same-name scalar/array/harray
stores in reverse order on success or failure. Nonparameter caller stores remain live, so reads observe invocation-
time state and mutations persist. This is dynamic caller context, not lexical capture.

The retained typed body executes through the existing Lua interpreter. `return(...)` is invocation-local; the
final expression is the implicit result; standalone calls discard only the result. One `value_access` node lets
an evaluated call result feed key/index lookup and then existing receiver chains. Explicit literals and declared
final-codeblock values use this same executor. Built-in final helpers first resolve their callback before installing
scoped `value`; they do not treat repeated helper names as bound-callable recursion identities.

Diagnostics project neutral `callable_name`, `expected`, `got`, `value_kind`, `name`, and array-valued `cycle`
fields. Fixed/rest arity, keyword arguments, non-callable values, unknown body helpers, and ordered direct/mutual
recursion are typed identically on PUC Lua and LuaJIT. One ordered `active_codeblocks` stack is cleaned on every
exit. Lexical capture remains excluded. Independently loaded emitted-module proof is current under `.11.8.3`, and
recurring five-backend/public admission is current under `.11.8.4`.

Related facts: [[lua-callable-codeblock-literal-state]], [[lua-callable-codeblock-typed-audit]],
[[callable-codeblock-literal-contract]], [[lua-contextual-user-function-codeblock-runtime]],
[[lua-runtime-eager-block-values]], [[lua-callable-codeblock-emitted-route-identity]],
[[lua-five-backend-capability-admission]].

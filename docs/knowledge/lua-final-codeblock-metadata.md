---
id: lua-final-codeblock-metadata
title: Lua preserves final contextual codeblock intent before executing callbacks
answers:
  - "does Lua preserve callback codeblock parameter metadata"
  - "how does Lua normalize attached user function blocks"
  - "are Lua parenthesized and attached contextual blocks equivalent"
  - "does Lua promote a harray in a codeblock parameter slot"
  - "does Lua execute user function contextual blocks yet"
  - "where is Lua final codeblock descriptor support owned"
date: 2026-07-15
status: current
tags: [lua, functions, codeblock, parameter-kinds, actionir, staged-parsing, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.5.1.4.1 passes 142/142 on PUC Lua and LuaJIT. Exact shell/payload/job/AST/registry/compiled metadata, four invalid declaration forms, equivalent contextual normalization, harray non-promotion, built-in no-drift, and descriptor fencing are focused in lua/test/run.lua."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_callable_codeblock_contract.py"
---

Lua consumes the codeblock-definition record emitted by `specs/user_function_definition.spec`. The shell
canonicalizes `fixed_params` plus the final `codeblock_param` into ordinary fixed-v1 `params`/`arity` and an exact
one-entry `parameter_kinds` harray whose final name maps to `codeblock`. The body payload, staged parse job, typed
AST round-trip, immutable registry entry, stitched definition, and compiled JSON must preserve identical metadata.
Sidecar drift fails closed.

Callable metadata drives contextual normalization. For a registered definition such as
`fn apply(value, callback: codeblock)`, both `apply("x") { ... }` and `apply("x", { ... })` normalize to a typed
`codeblock_argument` with a zero-positional callable signature and the same parsed body. Normalization does not
mutate the source ActionIR. It converts only structural `block_value`; a keyed brace expression stays
`hash_literal` and is never promoted by position. Existing built-in final-codeblock contracts remain unchanged.

This is deliberately metadata-only. User-function contextual blocks are not invoked by this slice;
`LUA-BACKEND-PARITY.5.1.4.2` owns dynamic-context execution, copied/restored parameter stores, return behavior,
and wrong-kind/missing runtime diagnostics. Outward descriptor admission remains `.5.3`, generated preservation
and execution remain `.8`, and explicit `{|params| ...}` values plus bound dynamic calls remain `.11.7`.

Related facts: [[final-codeblock-parameter-declaration]], [[perl-generic-final-codeblock-normalization]],
[[lua-staged-function-execution-split]], [[lua-variadic-v2-runtime]].

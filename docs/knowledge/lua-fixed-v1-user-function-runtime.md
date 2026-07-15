---
id: lua-fixed-v1-user-function-runtime
title: Lua executes registered fixed-v1 functions through verified staged bodies and isolated stores
answers:
  - how does Lua execute registered user functions
  - does Lua support fixed-v1 user functions
  - do Lua user functions capture or mutate caller variables
  - what is the Lua user function argument evaluation order
  - how does Lua execute staged function body ASTs
  - how does Lua diagnose user function recursion
  - do Lua user function results support receiver chains
  - what is the Lua frontier after fixed-v1 function execution
date: 2026-07-15
status: current
tags: [lua, user-functions, runtime, staged-parsing, actionir, isolation, diagnostics]
evidence: "LUA-BACKEND-PARITY.5.1.2 adds registry-first fixed-v1 execution in lua/src/linkedspec/interpreter.lua and three focused dual-ABI tests in lua/test/run.lua. PUC Lua and LuaJIT pass 133/133 with status runtime-user-functions-fixed-v1; variadic-v2 state .5.1.3.1 is active."
reverify: "bash tools/run_lua_local.sh && rg -n 'execute_user_function|staged_user_function_body|active_user_functions|user_function_keyword_arguments_unsupported|runtime-user-functions-fixed-v1|LUA-BACKEND-PARITY\\.5\\.1\\.2' lua/src lua/test lua/README.md docs/tasks/LUA-BACKEND-PARITY.md docs/linkedspec-book/src"
---

## Fact

`lua/src/linkedspec/interpreter.lua` checks the compiled user-function registry
before canonical built-in helper dispatch. A registered fixed-v1 call rejects
keyword AST arguments, evaluates positional arguments exactly once from left to
right in caller scope, and passes those values to
`user_function_registry.prepare_invocation(...)`.

The invocation frame recursively copies mutable values and supplies fresh scalar,
array, and harray stores. Function execution temporarily installs only those
stores and the active-function path, then restores every caller object through a
protected cleanup boundary on both success and failure. Undeclared caller
bindings are therefore not captured, and mutations to array/harray parameters do
not change caller aggregates. Nested nonrecursive functions restore the outer
function frame the same way.

The staged `body_ast` is an execution authority rather than optional decoration.
On first use, the runtime reconstructs a typed ActionIR block from the governed
`body_source`, requires its canonical JSON to match `body_ast` exactly, and caches
only that verified source/AST pair. Missing, wrong-kind, or drifting bodies fail
closed before body execution. The result is the body's final expression or its
function-local early `return(expr)` value. Results remain ordinary LinkedSpec
values, so array, harray, string, and numeric receiver chains work; standalone
calls execute normally and discard only the returned value.

Exact arity uses `user_function_arity_mismatch`. Registered keyword arguments use
`user_function_keyword_arguments_unsupported` before any argument evaluation.
Direct and mutual recursion use `user_function_recursion` with the complete cycle
and function-owned runtime diagnostic attribution. Public status is
`runtime-user-functions-fixed-v1`; the next frontier is variadic-v2 typed-state
preservation at `LUA-BACKEND-PARITY.5.1.3.1`.

Related facts: [[lua-user-function-registry]],
[[lua-staged-function-body-registry]],
[[lua-staged-function-execution-split]],
[[lua-variadic-user-function-routing]].

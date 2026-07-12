---
id: julia-user-function-runtime-execution
title: Julia runtime executes registered fixed and variadic user functions
answers:
  - does Julia execute fixed and variadic user-defined functions
  - how are Julia user function arguments evaluated
  - do Julia user functions capture caller variables
  - do Julia user functions use fresh scalar array hash stores
  - can a Julia user function result feed a receiver chain
  - does a standalone Julia user function call discard its result
  - what happens for direct or mutual Julia user function recursion
  - what is JULIA-BACKEND-PARITY.5.2
date: 2026-07-10
status: current
tags: [julia, runtime, user-functions, actionir, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.5.2 establishes exact execution; FUTURE-PARITY-BACKLOG.4.3.2 extends the same registry-first frame to typed v2 fixed-prefix/rest signatures and passes 55 neutral assertions plus the complete Julia gate."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia's runtime checks `CompiledSpec.function_registry` inside `_evaluate_runtime_call!(...)` before ordinary
helper fallback. Fixed v1 functions require exact arity; variadic v2 functions require their fixed-prefix minimum.
Accepted positional arguments evaluate eagerly in caller scope and execute the registered body; keyword calls and
registered wrong arities diagnose instead of becoming unknown helpers.

Each call uses fresh scalar, array, and hash stores. Every param binds in the scalar store, while vector and map
values also bind into the corresponding typed local store. A variadic call binds extras as one newly allocated,
recursively copied array in both scalar and typed-array views, including an empty array. The function cannot capture caller working variables;
caller stores restore in `finally` after success or failure. Bodies execute as cached ActionIR value blocks, so the
result is the final expression or first local `return(...)` payload.

Returned values are ordinary values and can feed compatible receiver chains. Standalone calls execute through the
existing dropped-value statement path, so eager argument effects occur while the return value is ignored. Active
function-name tracking rejects direct and mutual recursion with a `RuntimeInterpreterException` whose structured
diagnostic stage is `user_function_call` and whose message includes the cycle path.

Related facts: [[julia-user-function-registry]], [[julia-staged-function-body-registry]],
[[julia-variadic-user-functions]], [[dart-user-function-runtime-execution]], [[rust-user-function-runtime-parity]],
[[terse-user-defined-functions-mvp-contract]].

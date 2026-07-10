---
id: julia-user-function-runtime-execution
title: Julia runtime executes registered exact-arity user functions
answers:
  - does Julia execute user-defined functions
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
evidence: "JULIA-BACKEND-PARITY.5.2 updates julia/src/runtime/Interpreter.jl and adds nine focused assertions in julia/test/runtests.jl. Full Pkg.test() passes with 671 assertions and package status runtime-user-functions."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia's runtime checks `CompiledSpec.function_registry` inside `_evaluate_runtime_call!(...)` before ordinary
helper fallback. Exact matches evaluate arguments eagerly in caller scope and execute the registered body;
registered wrong arities diagnose instead of becoming unknown helpers.

Each call uses fresh scalar, array, and hash stores. Every param binds in the scalar store, while vector and map
values also bind into the corresponding typed local store. The function cannot capture caller working variables;
caller stores restore in `finally` after success or failure. Bodies execute as cached ActionIR value blocks, so the
result is the final expression or first local `return(...)` payload.

Returned values are ordinary values and can feed compatible receiver chains. Standalone calls execute through the
existing dropped-value statement path, so eager argument effects occur while the return value is ignored. Active
function-name tracking rejects direct and mutual recursion with a `RuntimeInterpreterException` whose structured
diagnostic stage is `user_function_call` and whose message includes the cycle path.

Related facts: [[julia-user-function-registry]], [[julia-staged-function-body-registry]],
[[dart-user-function-runtime-execution]], [[rust-user-function-runtime-parity]],
[[terse-user-defined-functions-mvp-contract]].

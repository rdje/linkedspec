---
id: dart-user-function-runtime-execution
title: Dart runtime executes registered exact-arity user functions
answers:
  - "does Dart execute user-defined functions"
  - "does Dart resolve user functions before helper fallback at runtime"
  - "how are Dart user function arguments evaluated"
  - "how are Dart user function locals scoped"
  - "do Dart user functions feed receiver-dot chains"
  - "do standalone Dart user function calls discard results"
  - "what happens for Dart user function recursion"
  - "what is DART-BACKEND-PARITY.5.2"
date: 2026-07-09
status: current
tags: [dart, runtime, user-functions, actionir, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.5.2 updates dart/lib/src/runtime/interpreter.dart. LinkedSpecRuntimeEngine now resolves UserFunctionRegistry exact-arity calls before ordinary helper fallback, evaluates arguments eagerly in the caller, tracks active user-function calls, parses/caches function body_source as ActionIR blocks, executes bodies through the value-block evaluator, binds params into fresh function-local scalar/array/hash stores, restores caller stores, feeds returned values into receiver chains, discards standalone call results, diagnoses arity mismatches, and attaches structured recursion diagnostics. test/runtime_interpreter_test.dart covers value calls, receiver continuation, standalone discard, eager args, local-store isolation, array/hash param bindings, direct/mutual recursion, and arity mismatch diagnostics."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart user-function runtime execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` checks `compiledSpec.functionRegistry.resolveCall(...)`
inside `_evaluateCall(...)` before the ordinary runtime helper fallback. Exact
matches execute the registered function; registered wrong-arity calls throw a
runtime arity diagnostic instead of becoming an unknown helper.

Runtime behavior:

- arguments evaluate eagerly in the caller context
- params bind into fresh function-local scalar stores
- list and map argument values also populate local array/hash stores for wrapper
  and receiver-chain compatibility
- function bodies execute as ActionIR value blocks parsed from `body_source`
- the result is the final expression or local `return(...)` payload
- caller scalar/array/hash stores are restored after the call
- returned strings, numbers, arrays, and hashes can feed compatible receiver-dot
  chains
- standalone registered calls execute and discard their result through the
  existing dropped-value statement path
- direct and mutual recursion throw a `RuntimeInterpreterException` with
  `diagnostic.stage = user_function_call`

Related facts: [[dart-function-registry]], [[dart-staged-function-body-registry]],
[[dart-runtime-value-control-tree-helpers]], [[rust-user-function-runtime-parity]],
[[terse-user-defined-functions-mvp-contract]].

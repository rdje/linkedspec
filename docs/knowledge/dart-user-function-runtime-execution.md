---
id: dart-user-function-runtime-execution
title: Dart runtime executes registered fixed and variadic user functions
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
evidence: "DART-BACKEND-PARITY.5.2 establishes registry-first exact calls, eager args, local stores, results, discard, and recursion diagnostics. FUTURE-PARITY-BACKLOG.4.3.1 extends the same path with v2 minimum arity, positional-only calls, and fresh typed rest lists; six neutral contract tests and the complete Dart gate pass."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_interpreter_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart user-function runtime execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` checks `compiledSpec.functionRegistry.resolveCall(...)`
inside `_evaluateCall(...)` before the ordinary runtime helper fallback. Fixed exact
or variadic minimum matches execute the registered function; registered wrong-arity calls throw a
runtime arity diagnostic instead of becoming an unknown helper.

Runtime behavior:

- arguments evaluate eagerly in the caller context
- fixed params and one fresh variadic rest list bind into fresh function-local stores
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

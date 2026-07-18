---
id: dart-runtime-rule-interpreter
title: Dart runtime rule interpreter executes compiled rules through dispatch, lifecycle, returns, retv, and accumulators
answers:
  - where is the Dart runtime interpreter
  - does Dart execute compiled rules yet
  - does Dart support action-edge dispatch
  - does Dart support blind-call dispatch
  - does Dart run lifecycle blocks
  - does Dart support retv and accumulators
  - does Dart guard recursion and zero-progress repetition
date: 2026-07-09
status: current
tags: [dart, runtime, interpreter, dispatch, lifecycle, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.2 adds dart/lib/src/runtime/interpreter.dart and exports LinkedSpecRuntimeEngine, RuntimeParseResult, RuntimeLifecycleEvent, and RuntimeInterpreterException. test/runtime_interpreter_test.dart covers regex repetition, action-edge fluent .push, blind AND/OR dispatch, bounded repetition, zero-progress cutoff, and lifecycle order."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart runtime rule execution lives in `dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` consumes `CompiledSpec` and the `.4.1` match-state
primitives to execute compiled rules. It returns `RuntimeParseResult`, which
records the top rule value, Rust-style one-element output wrapper, cursor
offsets, match success, and lifecycle events.

The first interpreter layer covers default, AND, OR, and repetition rule
families; action-edge and blind-call child dispatch; entry/local match handoff;
explicit `return(...)` and `return_undef()`; `retv`; accumulator collection;
bounded repetition; zero-progress cutoffs; and recursion cutoffs.

The `.4.2` embedded ActionIR evaluator was deliberately narrow and
dispatch-facing. `DART-BACKEND-PARITY.4.3.1` through `.4.3.5` later extended it
with core value/store behavior, capture readers, string/number helpers, array
helpers, hash helpers, value blocks, structured controls, with-blocks, and tree
traversal callbacks.

Related facts: [[dart-runtime-matching-state]], [[dart-compiled-spec-state]],
[[dart-rule-local-cursor-execution]],
[[dart-runtime-core-value-capture-helpers]], [[dart-runtime-value-control-tree-helpers]],
[[dart-backend-interpreter-first-plan]].

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
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_interpreter_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
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

## 2026-09-09 — interpreter entry and generated plan reading

`DART-STARTUP-READING.1.15` reads interpreter lines 1-674 plus all 68 generated-plan lines.
The ten generated families derive seek/consume and blind dispatch from the validated family;
ordered plan rows retain only label/family and value equality. Existing cursor authority
remains [[dart-rule-local-cursor-execution]].

Runtime entry validates compiled regex-slot and serialized mutation state, resolves the
entry rule, creates an execution context and skips leading blank/comment lines. After rule
execution it completes optional staged enrichment, builds result/cursor/lifecycle records
and emits the optional semantic observation. Diagnostic and semantic sink failures preserve
their original error/stack; exits and runtime diagnostics keep separate trace boundaries.

Rule entry checks the selected generated family, builds the label/regex-index/cursor
recursion key, and establishes fresh match registers plus binding/recognition scopes.
This range ends at the execution try block; .1.16 owns its body and cleanup.
The 82 selected progressive/interpreter/cursor/emitter tests pass, including emitted source.
Known nested private-authority composition limits are separately preserved in
[[dart-progressive-nested-authority-gap]]; no runtime repair is made by this reading slice.

## 2026-09-09 — rule execution through initial value-block flow

`DART-STARTUP-READING.1.16` reads lines 675-2174. Rule initialization and blind/regex
selection retain terminal results/errors for recognition exit, then restore binding scope,
rule stack, registers and recursion identity through nested cleanup. Blind AND collects
implicit successful child values; repetition checks counts and progress around lifecycle
hooks. Capture-enabled regex loops select/install before LS and commit after LE before IT;
unflagged loops retain their own order. Slot identity checks precede typed observation and
trace. Action edges track prior dispatch and collect repeated explicit returns where owned.

Lifecycle I records initializer binding ownership before execution. The statement dispatcher
separates attached/marker if and switch, attached while, structural markers and expressions.
The range ends during local-return handling in value-block flow; .1.17 owns its continuation.
Existing switch omission .2.1 and effect integration .2.4 remain unresolved.

All 100 selected interpreter/cursor/recognition/observation/gap/repeated-result/slot tests pass,
including emitted and gap-primary consumers. Six native callback probes nevertheless expose
the action-block semantic failure translation documented in
[[dart-semantic-observer-action-failure-wrapping]]; new .2.8 owns repair and carrier proof.

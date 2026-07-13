---
id: dart-aggregate-selector-compile-rejection
title: "Dart rejects exact aggregate selectors across compiled and generated ActionIR"
answers:
  - "how does Dart reject array name and hash name selectors"
  - "what is the Dart aggregate selector removed diagnostic"
  - "are Dart selectors rejected inside dead code"
  - "are Dart selectors rejected inside unused user functions"
  - "does generated Dart reject caller constructed selector AST"
  - "which array and hash constructors remain valid on Dart"
  - "where was Dart selector compatibility dispatch removed"
date: 2026-07-12
status: current
tags: [dart, actionir, compiler, generated-source, bindings, retirement, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.8.3.1 adds a recursive typed-ActionIR detector in dart/lib/src/action/action_ast.dart and whole-CompiledSpec validation in compiler/compiled_spec.dart. Normal compilation, unused function bodies, deferred edge-fluent arguments, generated-source emission, and generated-plan validation reject exact selectors. Selector-specific runtime read/target/assignment/receiver/split dispatch is deleted. The focused uniform-binding suite passes 15/15, covering all six neutral invalid cases, dead code, edge fluent arguments, unused functions, caller-constructed generated payloads, and all eight retained constructor/literal classes. Strict analysis is clean and the recurring source scan is zero-positive/14 classified. The full package test leg reaches 203 passes; its only two failures are independently root-caused variadic spec.spec structural bridge drift owned by .12.1.8.3.2."
reverify: "cd dart && dart test test/uniform_binding_contract_test.dart && dart analyze --fatal-infos --fatal-warnings; cd .. && python3 tools/check_executable_aggregate_selector_sources.py"
---

# Dart aggregate-selector compile rejection

Dart represents rule payloads as typed `ActionExpr` / `ActionBlock` trees. A recursive visitor detects only exact
`array` or `hash` calls whose sole argument is one positional bare variable. It traverses calls, assignments,
access indices, shape literals, value blocks, receivers, fluent arguments, and every structured control body. The
portable detail is `aggregate_selector_removed surface=<array|hash> identifier=<name> replacement=<name>`.

Compilation validates the complete effective `CompiledSpec`. In addition to every rule payload, it parses and
checks unused function bodies plus deferred action/blind-edge fluent calls without changing the timing of unrelated
deferred parse failures. Generated-source emission and generated-plan validation repeat the boundary so a caller-
constructed compiled object cannot bypass it.

Runtime branches that formerly interpreted exact selectors as reads, assignment/mutation targets, receiver
targets, or mutable split targets are deleted. Bare typed bindings own those operations. Rejection remains
shape-exact: `array()`, `array("items")`, `array(copy(items))`, multi-argument arrays, `hash()`, valid key/value
hashes, and direct array/harray literals remain constructors or values.

Related facts: [[uniform-binding-neutral-contract]], [[dart-uniform-binding-runtime]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[rust-aggregate-selector-compile-rejection]].

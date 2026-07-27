---
id: dart-uniform-binding-runtime
title: "Dart bare mutations use one typed binding on native and generated execution"
answers:
  - "does Dart support selector free push split and hash mutation"
  - "what does Dart set return for method chaining"
  - "how does Dart report a wrong kind bare mutation"
  - "does a saved Dart mutation result change after a later mutation"
  - "how does Dart distinguish push rule dispatch from binding mutation"
  - "are array name and hash name rejected on Dart yet"
date: 2026-07-12
status: current
tags: [dart, language, bindings, array, harray, mutation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.4 centralizes Dart bare typed reads and kind-checked array/harray mutations in dart/lib/src/runtime/interpreter.dart. Native/generated integration proof covers the future fixture, all seven neutral cases, collection rebinding, append, mutation continuation, static precedence, and wrong-kind fields. Temporary wrapper mutations aliased the same current value for migration. FUTURE-PARITY-BACKLOG.12.1.8.3.1 now rejects exact selector calls across complete compiled/generated state and deletes those wrapper runtime branches; `.12.1.8.3.2` closes the complete Dart gate at 205 tests, CLI 61x2, and 105 corpus."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/uniform_binding_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

# Dart uniform binding runtime

Dart now consumes `linkedspec-uniform-binding-v1` through the same `LinkedSpecRuntimeEngine` on native and
generated-plan execution. Bare reads resolve the current typed value across the runtime's private migration stores;
those maps do not define public scalar/array/harray namespaces.

Bare push/append, mutable split, hash-index mutation, array-end methods, and standalone collection transforms
validate the existing value kind, update the binding, and return an independent copy of its post-operation value.
An absent array or harray mutation target starts as the required empty kind. An incompatible existing value throws
`binding_kind_mismatch` with stable identifier, expected-kind, and actual-kind fields. `set(name, value)` returns
the assigned value, and array-end updates can continue into methods such as `.count()`.

Static compiled rules retain precedence for ambiguous `push(name, target)` calls. Otherwise the first bare name is
the array binding. The complete neutral matrix passes both engine paths.

The full Dart gate exposed two historical boundaries. Value-position array-end mutation still expected `null`, and
bare `merge_hash(meta, overlay)` saw only the overlay after wrapper/bare mutation mixed stores. The adopted result
contract replaces the first assertion; temporary wrapper mutations now bridge to the same typed binding, fixing
the second without making selectors permanent.

Exact `array(name)` and `hash(name)` are now rejected across Dart's compiled/generated boundaries; all tracked
sources already use bare replacements. Selector-specific runtime read, target, assignment, receiver, and split
dispatch is deleted under `FUTURE-PARITY-BACKLOG.12.1.8.3.1`.

Related facts: [[uniform-binding-neutral-contract]], [[perl-uniform-binding-runtime]],
[[rust-uniform-binding-runtime]], [[dart-runtime-core-value-capture-helpers]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[dart-aggregate-selector-compile-rejection]].

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
evidence: "FUTURE-PARITY-BACKLOG.12.1.4 centralizes Dart bare typed reads and kind-checked array/harray mutations in dart/lib/src/runtime/interpreter.dart. Native/generated integration proof covers the future fixture, all seven neutral cases, collection rebinding, append, mutation continuation, static precedence, and wrong-kind fields. Temporary wrapper mutations alias the same current value for mixed-source migration; Dart format/analyze, 199 tests, 105 corpus fixtures, and CLI 61x2 pass."
reverify: "cd dart && dart test test/uniform_binding_contract_test.dart && dart analyze --fatal-infos --fatal-warnings"
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

Exact `array(name)` and `hash(name)` remain parsed only while tracked sources migrate; all backends support bare
replacements. Dart rejects and deletes those selector paths in `FUTURE-PARITY-BACKLOG.12.1.8.3`.

Related facts: [[uniform-binding-neutral-contract]], [[perl-uniform-binding-runtime]],
[[rust-uniform-binding-runtime]], [[dart-runtime-core-value-capture-helpers]],
[[spec-facing-aggregate-selector-retirement-inventory]].

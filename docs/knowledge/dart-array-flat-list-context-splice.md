---
id: dart-array-flat-list-context-splice
title: Dart array constructors splice explicit flat calls in list context
answers:
  - "why did Dart portmap output have an extra nested array"
  - "how does Dart array(flat_array(...)) behave"
  - "does Dart array(copy(...)) stay nested"
  - "which leaf fixed Dart portmap result shapes"
  - "why did vhdl_library_use pass with the portmap fix"
date: 2026-07-09
status: current
tags: [dart, runtime, arrays, portmap, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.4.1 updates dart/lib/src/runtime/interpreter.dart so `array(...)` treats explicit `flat`, `flat_array`, and `flat_hash` call or fluent arguments as list-context splices, while `copy(...)` stays nested. Focused runtime tests lock `array_flat_splice` and `array_copy_nested`; corpus_manifest_test executes the five portmap fixtures; the diagnostic corpus window is 13/31 green and `vhdl_library_use` passes."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_interpreter_test[.]dart test/corpus_manifest_test.dart && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case portmap_bare --case portmap_bit --case portmap_slice --case portmap_constant --case portmap_concatenation"
---

Dart `array(...)` mirrors the Rust/Perl list-context rule: explicit
`flat(...)`, `flat_array(...)`, and `flat_hash(...)` arguments splice their
evaluated aggregate into the constructed array. Ordinary aggregate-valued
arguments, especially `copy(...)`, remain nested.

This fixes the portmap shape where payloads such as `["foo"]` were previously
returned as `[["foo"]]`. The same list-context mechanism also fixes
`vhdl_library_use`.

Related facts: [[dart-residual-parser-smoke-split]],
[[rust-simple-spec-structural-owners]], [[rust-action-edge-child-return-dispatch]],
[[rust-perl-output-oracle]].

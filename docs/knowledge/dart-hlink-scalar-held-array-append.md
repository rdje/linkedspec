---
id: dart-hlink-scalar-held-array-append
title: Dart hlink parity requires retv refresh and scalar-held array append
answers:
  - "why did Dart hlink fixtures fail after capture helpers existed"
  - "does Dart call(child) update retv"
  - "does Dart push(array(name), value) mutate scalar-held arrays"
  - "why did tablegrep_simple_term pass with the hlink fix"
  - "which leaf fixed Dart hlink delimiter capture parity"
date: 2026-07-09
status: current
tags: [dart, runtime, hlink, tablegrep, arrays, retv, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.4.2 updates dart/lib/src/runtime/interpreter.dart so `call(...)` sets `context.retv` to the child result and `push(...)` / `items += value` route through `_appendArrayValue(...)`. The append helper mutates a scalar-held list in `context.variables[name]` when that list is the current owner, preserving later `array(name)` reads, and otherwise falls back to aggregate storage. Focused runtime tests lock scalar-held append behavior; corpus_manifest_test executes all five hlink fixtures; the focused hlink corpus command passes 5/5; the diagnostic window is 19/31 green, with `tablegrep_simple_term` passing from the same append behavior."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart test/corpus_manifest_test.dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case hlink_raw_string --case hlink_raw_escaped_brackets --case hlink_curly_brace --case hlink_bracket_body --case hlink_mixed_bracket_brace && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31 || true"
---

The hlink failures were not caused by `capture_slice()` boundaries. The child
rule matched and `LE { push(array(word_items), retv) }` ran, but
`word_items = []` had created a scalar-held list. Dart appended to aggregate
storage, while `array(word_items)` correctly read the still-empty scalar-held
list first.

Dart now refreshes `retv` after `call(...)` and uses one append path for
`push(...)` and `items += value`. If a variable currently holds a list, appends
update that scalar-held list; explicit aggregate storage remains the fallback.

This closes all five hlink fixtures and also turns `tablegrep_simple_term` green
because it uses the same `internal = []` plus `push(array(internal), retv)`
collection pattern.

Related facts: [[dart-residual-parser-smoke-split]],
[[dart-shipped-corpus-smoke-split]], [[perl-capture-slice-delimiter-seek-boundary]],
[[rust-perl-output-oracle]].

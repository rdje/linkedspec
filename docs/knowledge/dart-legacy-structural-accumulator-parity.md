---
id: dart-legacy-structural-accumulator-parity
title: Dart push(Child) now appends child returns to the current rule accumulator; ds_vhistory remains a routed direct-access oracle mismatch
answers:
  - "which leaf fixed Dart regdef_nested_register_fields"
  - "why did Dart regdef_nested_register_fields return an empty accumulator"
  - "does Dart push(Child) append to the current rule accumulator"
  - "why is Dart ds_vhistory_version_entry still routed"
  - "why does ds_vhistory object name differ between Dart and the corpus oracle"
date: 2026-07-09
status: current
tags: [dart, runtime, accumulator, direct-access, corpus, parser-smoke, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.4.4 changes dart/lib/src/runtime/interpreter.dart so one-argument action-edge `push(Child)` detects rule references, executes the child rule, refreshes `retv`, and appends the child result to the current rule accumulator rather than treating the argument as the target accumulator. Focused runtime coverage locks the general convention, and corpus_manifest_test locks `regdef_nested_register_fields`. The focused corpus command `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case regdef_nested_register_fields --case ds_vhistory_version_entry` now passes regdef and still fails ds_vhistory only at object name: expected null, actual `/proj/foo`. Code inspection shows Rust `Expr::IndexedVar` reads aggregate `ctx.get_array(name)`, while Dart `ActionIndexedVarExpr` reads scalar-held `context.variables[name]` first; public scalaref migration docs name `cur_object[1]` as the direct-access replacement surface. Therefore `.6.2.4.4.4` routes `ds_vhistory_version_entry` to `.6.2.4.4.5` for an explicit oracle/contract decision instead of weakening Dart direct access."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart test/corpus_manifest_test.dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case regdef_nested_register_fields --case ds_vhistory_version_entry || true && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31 || true"
---

Dart's previous action-edge one-argument `push(...)` handling treated the
argument as the accumulator target whenever an action edge was active. That made
`regdef_top` run `push(reg_def)` but append the child result to `reg_def`, leaving
`array(regdef_top)` empty at `LX`.

The current contract is the documented `push(Child)` convention: if the sole
argument names a rule, execute that child and append its result to the current
rule's implicit accumulator. Explicit target appends still use
`push(array(target), value)`, `push(target, value)` in unambiguous value form, or
`items += value`.

`ds_vhistory_version_entry` is intentionally not forced green in this leaf. The
fixture expects `null` for the object name, but the live source uses
`cur_object = call(object)` followed by `cur_object[1]`. Dart reads the
scalar-held call payload and returns `/proj/foo`; Rust's current `IndexedVar`
path reads only aggregate arrays and therefore yields `undef`/`null`. That
disagreement is now routed to `DART-BACKEND-PARITY.6.2.4.4.5` with evidence
instead of changing the current direct-access surface silently.

Related facts: [[accumulator-convention-healthy]],
[[scalaref-live-surface-migrated]], [[dart-residual-parser-smoke-split]],
[[dart-shipped-corpus-smoke-split]], [[rust-perl-output-oracle]].

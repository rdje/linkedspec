---
id: dart-legacy-structural-accumulator-parity
title: Dart push(Child) now appends child returns to the current rule accumulator; ds_vhistory later closed through public-parser leading trivia
answers:
  - "which leaf fixed Dart regdef_nested_register_fields"
  - "why did Dart regdef_nested_register_fields return an empty accumulator"
  - "does Dart push(Child) append to the current rule accumulator"
  - "why was Dart ds_vhistory_version_entry still routed after regdef parity"
  - "how was ds_vhistory_version_entry later closed"
date: 2026-07-09
status: current
tags: [dart, runtime, accumulator, direct-access, leading-newline, corpus, parser-smoke, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.4.4 changes dart/lib/src/runtime/interpreter.dart so one-argument action-edge `push(Child)` detects rule references, executes the child rule, refreshes `retv`, and appends the child result to the current rule accumulator rather than treating the argument as the target accumulator. Focused runtime coverage locks the general convention, and corpus_manifest_test locks `regdef_nested_register_fields`. The focused corpus command `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case regdef_nested_register_fields --case ds_vhistory_version_entry` passed regdef and failed ds_vhistory only at object name: expected null, actual `/proj/foo`. DART-BACKEND-PARITY.6.2.4.4.5 refined that residual: public `LinkedSpec::get_parser(\"ds_vhistory\")` and Rust oracle execution keep the checked null object name for the leading-newline fixture, direct generated descriptor-handler execution returns `/proj/foo`, and ordinary public-parser scalar-held `payload[1]` still returns the indexed item. DART-BACKEND-PARITY.6.2.4.4.6 then closed the residual by mirroring Perl's public-parser leading blank/comment-line skip before the top rule in Dart."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart test/corpus_manifest_test.dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case regdef_nested_register_fields --case ds_vhistory_version_entry && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31"
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

`ds_vhistory_version_entry` was intentionally not forced green in this leaf. The
fixture expects `null` for the object name, but the live source uses
`cur_object = call(object)` followed by `cur_object[1]`. Follow-up probes in
`DART-BACKEND-PARITY.6.2.4.4.5` showed the mismatch was a leading-newline
public-parser/oracle boundary: public Perl/Rust keep the null fixture, direct
generated descriptor-handler execution returns `/proj/foo`, and ordinary
scalar-held public-parser indexed reads still work.

`DART-BACKEND-PARITY.6.2.4.4.6` later closed that residual by mirroring Perl's
public-parser leading blank/comment-line skip before the top rule in Dart.

Related facts: [[accumulator-convention-healthy]],
[[scalaref-live-surface-migrated]], [[dart-residual-parser-smoke-split]],
[[dart-shipped-corpus-smoke-split]], [[ds-vhistory-leading-newline-oracle-boundary]],
[[dart-structural-pcre-parser-smoke-parity]], [[rust-perl-output-oracle]].

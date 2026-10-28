---
id: dart-implicit-blind-repetition-collections
title: Dart repeated blind choice retains child values and repeated AND retains complete groups
answers:
  - "why does Dart default blind repetition return null after successful child calls"
  - "does Dart blind repeated AND discard incomplete group values"
  - "does Dart Default blind no-hit differ from explicit zero-min repetition"
date: 2026-10-28
status: bounded39.2.4 repaired/targeted-checked; P1 post-call scope39.2.5 and admission open
tags: [dart, blind-call, repetition, collection, and, default, partial-groups]
evidence: "dart-blind-collection-intake.json.gz retains15 final sources24 inputs7healthy8actualRED ->15pass, exact source/artifact identity, reused15 fresh modules,14 public Perl source/value pairs23 rows plus separately owned post-call discrepancy, combined104pass no skips."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/blind_repetition_collection_test.dart test/minimum_miss_routes_test.dart test/repeated_and_group_results_test.dart test/sparse_and_structural_sequence_test.dart test/recognition_repetition_progress_test.dart"
---

_executeBlindOnce retains copied successful child values in an optional
per-attempt list. Repeated _executeBlindRule appends only after a complete
accepted iteration: choice extends its flat collection, AND adds one nested
group. A partial AND attempt contributes nothing but keeps consumed cursor.
Custom authored IT replaces default append. Lifecycle returns and existing
Dart post-call exits remain whole-rule compatibility behavior in this slice.
One-shot AND keeps flat values; pipe avoids unused collection copies.

Historical Default with no accepted iterations remainsnull; explicit zero-min
blind repetition returns[]. Default iteration already reached cursor8 before
repair; no mode classifier, bounds, cursor policy or iteration fix is made.
Anchored AND children distinguish sequence/grouping without pipe seek effects.
EX/E equal sentinels qualify exit-placement coverage under SESSION27.

14 exact canonical Perl public native/fresh source/value reference cases23 rows
independently expose eight Dart result failures and six healthy controls. One
added existing-Dart post-call compatibility case makes final15 sources24 rows,
seven healthy/eight actual RED ->15pass. Raw source/normalized/compiled/plan/
emitted bytes remain identical and same15 emitted modules/consumer are reused
baseline/fixed in fresh processes. Fresh values are checked, not fresh match/
cursor. Combined blind/minimum/group/structural/live progress104pass no skips;
min12/group21/guard24 source/artifact records unchanged, fatal analysis passes.

The added explicit post-call return differs from Perl: see
[[dart-perl-blind-postcall-return-gap]]. It is not a cross-backend oracle case.
P1 owner39.2.5 follows immediately before peers/admission, to reconcile return
scope and emitted retv binding then repair established defects. All original
Dart intake regressions are enabled, without claiming portable post-call parity
or complete admission. Compiler/emitter/matching/recognition authority and
schemas are unchanged; rebuild runtime with existing generated source/plans.

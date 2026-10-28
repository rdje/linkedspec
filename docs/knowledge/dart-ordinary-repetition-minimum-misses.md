---
id: dart-ordinary-repetition-minimum-misses
title: Dart ordinary repetition minimum misses return failed null outcomes and preserve consumed cursor
answers:
  - "why does Dart blind repetition minimum miss throw an interpreter error"
  - "does Dart ordinary repetition minimum failure roll back consumed input"
  - "can a Dart caller recover after a child minimum miss"
date: 2026-10-28
status: bounded39.2.3 repaired/targeted-checked; blind collections and admission remain
tags: [dart, repetition, minimum, recognition, cursor, caller-state, errors]
evidence: "dart-minimum-intake.json.gz retains12 final sources29 inputs4healthy8actualRED ->12pass, exact raw source/artifact identity and same12 emitted module reuse, combined88pass1owned-dormant, unchanged group21/guard24 source records and typed diagnostics."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/minimum_miss_routes_test.dart test/repeated_and_group_results_test.dart test/sparse_and_structural_sequence_test.dart test/recognition_repetition_progress_test.dart"
---

_executeBlindRule and noncollector _executeRegexRule formerly threw generic
RuntimeInterpreterException when accepted iterations were below min. They now
return _RuleResult(matched:false,value:null) after existing LX authority, matching
the previously repaired action-collector paths. Only these explicit miss branches
change; real errors are never caught or converted. Cursor movement remains.
_executeRule's existing finally restores caller match registers; ordinary call
stores the child's null result in retv and can continue at the consumed cursor.

12 final authored sources29 input rows retain four healthy controls and eight
actual baseline failures. Native/restored/generated-plan and the same12 emitted
modules/consumer agree after repair. Raw source/normalized/compiled/plan/emitted
bytes are identical. Tests distinguish successful null payload/matchedtrue from
failed minimum/matchedfalse, regex/blind/AND partial consumption, no-hit/zero-min/
max, caller capture/retv and subsequent direct-call recovery. Typed unknown_helper
code/rule provenance is unchanged; combined minimum/group/structural/live progress
88pass1owned-dormant, unchanged21 group/24 guard source records, fatal analysis pass.

Initial recovery used a static edge to a regex-less blind owner, rejected by
existing slot validation. The refined source uses direct public call continuation.
The real-error expectation now checks actual unknown_helper code/rule, rather
than guessed message wording. Initial epochs remain without product RED credit.
Fresh values/errors are checked, not fresh matched/cursor. EX/E same sentinels
avoid broad lifecycle placement claims; SESSION27 retains that authority work.
No compiler/emitter/matching/recognition authority/schema/family change. Rebuild
runtime with existing source/plans; blind collection39.2.4 remains separate.

---
id: named-mark-number-dart-compatibility
title: Dart named Number sources compose while preserving dynamic caller mark scopes
answers:
  - "can Dart mark_pos feed coalesce and arithmetic methods"
  - "do Dart named capture widths compose with String and Array methods"
  - "do Dart callbacks use caller named marks and isolate different rules"
  - "which named Number Dart source and generated contexts are verified"
date: 2026-10-28
status: bounded Dart49.3 local writer compatibility focused-verified; peers/selection/SDK deprecations/full admission separate
tags: [dart, marks, number, fluent, callbacks, dynamic-caller]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.34.3 at clean dbfc12ea9; named-mark-number-dart-intake.json.gz retains31-source native/restored SpecFile/plan intake, new normal consumer,9 fresh emitted modules and exact list-annotation refinement."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/named_mark_number_results_test.dart test/complete_named_mark_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings test/named_mark_number_results_test.dart"
---

All seven readonly named Number sources already compose on Dart; no runtime edit
or invented RED. Shared fixture, seven direct consumers, alternate labels/names,
partial cursor versus EOF, zero/missing/reversed defaults, symbolic shadow and
clear snapshot agree native/restored SpecFile/generated plan. Quoted/computed names
already work. Direct6/[]/KVT remains distinct from binding Hash/[]/undef/KVT.

Literal callbacks see all seven caller readers, their mark writes remain visible,
and equal callback names in different rules cannot share marks. A callback returned
from First reads Top's call-time0 then6 marks, without capturing construction state.
All seven pure-function readers and registered callback retain helper-specific
parser-state restrictions and native versus generated error classes.

New2 tests cover23 value/scope plus8 function sources; nearest complete-mark3 passes.
Nine representative emitted modules run in a fresh VM with current project package
configuration/empty stderr, not isolated dependencies. Snapshot is normal-route
proof only. Two empty-list inference warnings in the new expectations are fixed
by explicit Object? annotations alone: exact refinement comparison and final fatal
analysis/format pass after the original5 functional tests. Full domain/context/
portable admission remains23.4. Julia34.4 and safe Lua34.5 assess independently.

## Dart repair47.3 (2026-10-29)

Named text/width/take-width now require nullable localMatch after name evaluation;
one-argument capture_take uses/advances its named mark and preserves the anonymous
boundary. Missing/reversed returns null without extra mutation, empty/zero/Unicode
and name effects remain. No new owner/state/frame/schema/helper/domain policy.
Independent15-source SDK/restored/plan/separate VM2healthy13RED ->15pass, ordinary
15 cases13RED ->15pass. Four targets36 tests/fatal changed-file analysis/final format
pass; original source/normalized/compiled/plan/emitted/full metadata and both healthy
complete results/traces exact. Same15 old modules reuse updated runtime: rebuild
AOT apps, no source regeneration. Initial instrument brace error recovered before
baseline; formatting only wraps a new switch arm, tested preformat source retained.
Whole-package SDK deprecations2.25/selection23.4.1 remain. Packet
dart-named-capture-endpoint-intake.json.gz retains closure. Independent Julia47.4/
safe Lua47.5, writer49/referenced-blind48/Phase0 owner45 precede full admission.

See [[dart-named-capture-endpoint-presence-repair]] for current cause and recovery. Earlier observations remain historical.

## Dart compatibility49.3 (2026-10-29)

Current15 native/restored/plan/separate VM allpass. Existing markName evaluation
and nullable localMatch start/end guard already preserve fresh/seeded/name-effect
targets without extra writes; valid empty/zero/Unicode and local/live cursor remain.
No runtime change. Exact source/normalized/compiled/plan/emitted/full metadata/
results/traces equal49.0; original15 modules reused. Writer15/named endpoint15/
named Number-function-scope2/complete marks3 pass35 tests, fatal new-file analysis/
format clean. Wrong first-mark oracle fails1case14pass, actual fixture unchanged,
no product RED. Packet dart-writer-endpoint-intake.json.gz retains closure. Ordinary
normal discovered, canonical selection23.4.1/SDK deprecations2.25/independent49.4-.5/
48/45/full admission remain separate. No AOT/full-package/dependency isolation claim.

See [[dart-local-match-writer-presence-compatibility]] for current owner and proof; earlier observations remain historical.

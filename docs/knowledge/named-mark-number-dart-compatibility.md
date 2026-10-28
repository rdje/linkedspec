---
id: named-mark-number-dart-compatibility
title: Dart named Number sources compose while preserving dynamic caller mark scopes
answers:
  - "can Dart mark_pos feed coalesce and arithmetic methods"
  - "do Dart named capture widths compose with String and Array methods"
  - "do Dart callbacks use caller named marks and isolate different rules"
  - "which named Number Dart source and generated contexts are verified"
date: 2026-10-28
status: bounded34.3 compatibility targeted-checked; full context admission23.4 separate
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

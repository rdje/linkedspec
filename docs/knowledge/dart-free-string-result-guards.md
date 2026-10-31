---
id: dart-free-string-result-guards
title: Dart canonical free String calls reuse common actual-kind guards
answers:
  - "which Dart owner guards free trim and uppercase result consumers"
  - "do Dart free String guards preserve null and empty with"
  - "why does a Dart receiver-only trim split set_key with chain run KVW"
  - "how is Dart free String helper formatting isolated"
date: 2026-10-31
status: bounded Dart62.3 targeted-checked; P1 receiver context62.6 after62.5/before23.4
tags: [dart, string, source, guards, with, context, formatting]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.62.3; free-string-dart-intake.json.gz retains same18 13PASS5RED to18PASS, independent receiver context/nearest31/fatal analysis/format and actual producers/inputs/setup."
reverify: "From dart/: bash ../tools/run_dart_project_data.sh test test/free_string_result_composition_test.dart test/scalar_string_results_test.dart test/constructor_result_composition_test.dart"
---

Original Scalar String producers/kinds/signatures work. Canonical eight-helper
ordinary arity/value source predicate now feeds current common kind guard.
Rejected arguments/later with skip; source once/order/snapshots/Number0 index/
Boolfalse/split-select/null-empty with stay. Same18 tests13PASS5RED to18PASS;
ten healthy values/error/nine shapes/independent receiver context exact. Nearest
String7/constructor24/fatal owner-normal analysis/new-normal format pass.
New helper isolated formatting changes whitespace/two optional argument commas.
Strict token assertion caught second comma before source write; guarded recovery
reused wrapper. Activation quote/prefix guards prewrite; no setup RED credit.

Receiver-only trim/split/set_key/with independently returns [ran,KVW] on all
three routes before/after. trim marks scalarResult, split returns List and clears
it, while literal-root kindGuardedResult stays false; incompatible Hash arguments
and later body run. P1 context62.6 after62.5/before23.4 owns this defect. No Perl
unready inference, fresh isolated/exhaustive excluded-runtime/full admission.
Rebuild Dart applications/runtime.

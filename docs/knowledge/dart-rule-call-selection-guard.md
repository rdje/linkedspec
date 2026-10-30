---
id: dart-rule-call-selection-guard
title: Dart static rule-call selections reuse the actual-kind operand guard
answers:
  - "why does Dart selected call Child String execute incompatible Array operands"
  - "which Dart owner guards indexed static rule-call results"
  - "does Dart selected rule-call repair change child invocation or callable counts"
date: 2026-10-30
status: bounded Dart54.3 repaired/targeted-checked; full admission separate
tags: [dart, selection, rule-call, fluent, guards, effects]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.54.3; rule-call-result-dart-intake.json.gz retains actual5healthy/1RED→6GREEN plus computed7/boundary6/fatal new-test analysis/format and actual source/normal/producers/inputs."
reverify: "From dart/: bash ../tools/run_dart_project_data.sh test test/rule_call_result_selection_test.dart"
---

At ee23088c4, direct child return brackets/kinds/static lookup already work.
All initial shared13 native/restored/plan observations instead return [] and
execute BAD after a selected String. _isOrdinaryComputedRead excludes call,
leaving its result under legacy direct-consumer policy.

A canonical call with one bare Variable-shaped positional label now joins the
existing selected-value operand guard. Source aliases/trailing blocks/quoted/
dynamic/extra arguments retain existing policies; all remaining interpreter/
invocation/parser/reader/schema bytes stay exact. Same new6/computed7/boundary6
pass native/restored SpecFile/generated-plan; JSON reporter binds19 actual
nonhidden/no-skip completions, stderr empty. New test fatal analysis/format pass.
Shared13/kinds/once/order/live-origin/null/missing/normalized skips/static lookup/
typed function fence/explicit arguments and original bound callable counts hold.
No isolated emitted/full domain/context/error-phase/portable admission follows.

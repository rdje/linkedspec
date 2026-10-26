---
id: dart-runtime-string-numeric-helpers
title: Dart runtime executes current string/scalar and numeric helper families
answers:
  - why do Dart definedness results need scalar and zero operand guards
  - does Dart runtime support trim lowercase substr split
  - does Dart runtime support string receiver chains
  - does Dart runtime support numeric helpers
  - does Dart runtime support numeric aliases and symbol callees
  - does Dart runtime support number receiver chains
  - does Dart runtime support str_eq string comparisons
date: 2026-10-26
status: current
tags: [dart, runtime, helpers, string, numeric, DART-BACKEND-PARITY]
evidence: "String/numeric4.3.2; generic definedness23.3.11.3 focused native/restored/plan/direct proof. Historical method lists/replays at Git01e9d8aae02e76ead8575468c743490a431926a7 for this path."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/definedness_result_receivers_test.dart test/string_predicate_result_receivers_test.dart"
---

Dart's interpreter.dart canonicalActionHelperName dispatch shares implementations across helper/receiver/word/symbol forms. Pure strings cover cat, trim/case/length/substr, literal/regex predicates, replacement/removal/split, coalescing and generic definedness/emptiness; lexical str_* remain distinct. Numeric arithmetic/rounding/reducer/clamp/comparison aliases use the same dispatcher. Compatible raw.trim().lowercase() and score.abs().ceil() compose. Array/Hash breadth: [[dart-runtime-array-helpers]], [[dart-runtime-hash-helpers]]. Detailed historical lists/commands/related pointers remain at the Git record above.

23.3.11.3 adds is_defined/is_undefined to scalar-result and zero-operand lists only. Baseline valid flow, Bool/text/default/literal controls and1!/SC/one-call/final-null snapshot already pass; container[] and four malformed effects fail. Native/restored/plan shared and free producer controls plus direct String tests/fatal selected-file analysis pass after guards. Bool false renders0! and stays present through coalesce_nonempty, preserving source/copy/domain/producer semantics. No new methods/type/schema or full admission; Julia4 next.

## 2026-09-09 — large values, Unicode ordering and substring bounds

The small admitted fixture does not cover every finite magnitude. Native and reconstructed
Dart preserve direct positive/negative 1e20 but adding zero or cat clamps to signed-64
endpoints. Integer addition can wrap, and abs(min-int) remains negative.
[[dart-large-number-helper-corruption]] retains eleven exact Perl comparisons; .2.12 owns
repair while startup .55 retains the separate portable text-spelling decision.

str_* compareTo uses UTF-16 order, making U+10000 precede U+E000, opposite Perl.
[[dart-helper-unicode-order-gap]] owns eight cases under .2.13. substr can also overflow
start+length before clipping; [[dart-slice-end-overflow]] owns six array/string cases under
.2.14. The 111 selected tests and neutral numeric 55/18 pass; new emitted defect results
and completed repairs are not inferred.

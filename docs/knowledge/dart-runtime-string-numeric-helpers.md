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
evidence: "String/numeric4.3.2; definedness11.3 and numeric comparison15.3/arithmetic16.3 focused proof. Prior full fact/11.3 detail and historical-list pointer at Git82635ca70466e0d475c31597c378a1bb2c7c2248."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/scalar_arithmetic_results_test.dart test/numeric_comparison_results_test.dart"
---

Dart's interpreter.dart canonicalActionHelperName dispatch shares implementations across helper/receiver/word/symbol forms. Pure strings cover cat, trim/case/length/substr, literal/regex predicates, replacement/removal/split, coalescing and generic definedness/emptiness; lexical str_* remain distinct. Numeric arithmetic/rounding/reducer/clamp/comparison aliases use the same dispatcher. Compatible raw.trim().lowercase() and score.abs().ceil() compose. Array/Hash breadth: [[dart-runtime-array-helpers]], [[dart-runtime-hash-helpers]]. Detailed historical lists/commands/related pointers remain at the Git record above.

Definedness11.3 retains Bool/false0!/SC snapshots with zero-operand/scalar guards;
prior generic container[]/four-effect failure and full detail are at the Git
pointer above. Numeric comparison15.3 shares a canonical six-name set between
one-RHS and scalar guards: producer/valid native-restored-plan flow already works,
while scalar Array[]/24 malformed effects now reject correctly. Six numeric/
direct tests and fatal analysis pass; raw numeric1/0/strict invalid-null, aliases,
source SOC/copy and numeric selector kinds remain. Full admission stays open.

Arithmetic16.3 independently confirms producer/shared flow and numeric String
prefixes. Only scalar-container boundaries ([] instead ofnull) and28 malformed
source/operand effects fail before repair. _numericArithmeticHelperNames marks
actual scalar results; common unary/binary/clamp/add/mul guards run before
source effects. min/max overloads and numeric adapters remain unchanged. Eleven
arithmetic/direct tests, format and fatal selected analysis pass native/restored/
plan, retaining14 malformed no-effects, SOC/ASO, actual-container default copies
and strict numeric/selector kinds. Julia/Lua/full admission remain separate.

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

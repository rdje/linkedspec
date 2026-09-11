---
id: dart-julia-unicode-17-case-mapping
title: Dart and Julia casing execute generated Unicode 17 data
answers:
  - where is Dart Unicode casing implemented
  - where is Julia Unicode casing implemented
  - do Dart and Julia use host lowercase uppercase for DSL text
  - which four variants consume Unicode 17 casing
date: 2026-07-12
status: current
tags: [unicode, casing, dart, julia, generation, runtime, parity]
evidence: "LUA-BACKEND-PARITY.4.3.2.1.2.3 generates and byte-checks dart/lib/src/runtime/unicode_case_mapping.dart and julia/src/runtime/UnicodeCaseMapping.jl. Both runtime scalar/receiver/array dispatchers consume them. Twelve fixtures pass all paths; Dart full gate passes 182 tests, CLI 61x2, corpus 105/105; Julia full gate passes package tests, primary CLI conformance, corpus 105/105."
reverify: "bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py && bash tools/run_dart_local.sh && bash tools/run_julia_local.sh"
---

## Fact

Dart and Julia DSL casing no longer uses host Unicode releases. The shared generator emits native constant maps,
merged contextual-property ranges, and Final Sigma evaluators at `dart/lib/src/runtime/unicode_case_mapping.dart`
and `julia/src/runtime/UnicodeCaseMapping.jl`. Scalar helpers, receiver calls, value-array calls, and standalone array
mutation reuse the same evaluator in each backend. Host casing that remains in trace/CLI code handles fixed ASCII
protocol tokens and is not a DSL text semantic path.

Related facts: [[perl-rust-unicode-17-case-mapping]], [[unicode-17-case-contract-data]],
[[unicode-case-mapping-cross-backend-gap]].

## 2026-09-10 — opening Dart lower-map reading

`DART-STARTUP-READING.1.27` reads unicode_case_mapping.dart 1–1189, through
lower-map U+A7A0. The generated constants pin contract v1, Unicode 17.0.0 and
logical digest 5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae.
The table includes dotted-I expansion to 0069 0307, identity entries retained
by full casing data, and ordered Latin/Greek/Cyrillic/Armenian/Georgian/Cherokee/
Coptic mappings. Reading does not yet cover the remaining mappings or evaluator.

Managed regeneration byte-compares the neutral JSON and all five backend
modules and passes twelve independent fixtures with unchanged 1563/1581
mappings and 158/464 property ranges. The 33-test Dart selection separately
runs all twelve casing fixtures through direct helpers and authored helper,
receiver and array paths. This is fresh Dart and neutral/generation proof;
the historical Julia and other-backend execution counts are not refreshed.

## 2026-09-10 — Dart lower-map completion and upper-map continuation

`DART-STARTUP-READING.1.28` reads unicode_case_mapping.dart 1190–2689:
1,500 fragments / 38,936 baseline-identical bytes. This completes the lower
table through U+1E921 and reads upper mappings through U+A76F. The fullwidth
and supplementary mappings remain pinned data. Upper mappings include sharp-s
to 0053 0053, U+0149 to 02BC 004E, and ordered Greek combining sequences.
Both lowercase sigma forms map to U+03A3. Full casing is not an inverse or a
normalization operation; contextual lowercase Final Sigma remains evaluator
behavior, whose physical Dart reading belongs to .1.29.

Fresh managed regeneration byte-compares the neutral artifact and all five
modules and passes twelve independent fixtures with unchanged 1563/1581
mappings and 158/464 ranges. The 33-test Dart run remains .1.27/dfc57ce1
evidence, retained by exact source identity. No fresh Julia or other-backend
runtime execution, new defect, data revision or source repair is claimed.

## 2026-09-10 — Dart evaluator reading completion

`DART-STARTUP-READING.1.29` completes the module through line 3835.
Upper mappings end at U+1E943. Sorted inclusive property ranges use binary
search. Final Sigma examines the original rune sequence, skips case-ignorable
scalars in each direction, and requires a preceding cased scalar with no
following cased scalar. Ordinary mappings preserve unmapped runes and append
full ordered expansions; the evaluator does not normalize or consult host casing.

The fresh eleven-test Dart selection includes the casing consumer, which runs
all twelve fixtures through direct, helper, receiver and array routes. Neutral
regeneration remains the unchanged .1.28/17341bbe checkpoint; no fresh Julia
or other-backend execution, generated-data change or new defect is claimed.

## September 11 Dart casing consumer reading complete

Dart .1.53 reads unicode_case_mapping_test.dart 1-58 through EOF. One test checks
the pinned metadata and all twelve fixtures through direct lower/upper functions
and authored scalar helper, receiver and array mutation routes. All 29 selected
Dart tests pass. Fresh neutral regeneration retains 1563/1581 mappings,158/464
property ranges and12 fixtures; it is not a fresh Julia runtime execution.
The separately owned Unicode helper-order defect .2.13 is unrelated to casing.

## 2026-09-11 — Julia lower-map prefix reading

Julia .1.22 reads UnicodeCaseMapping1-343 through lower-map U+042F. Pinned
Unicode17 metadata, dotted-I expansion and Latin/Greek/Cyrillic mappings retain
exact generated bytes. The existing Julia casing consumer passes39 assertions
across twelve direct/helper/receiver/array fixtures. Fresh neutral regeneration
byte-compares all modules and preserves1563/1581 mappings,158/464 ranges and12
fixtures. No remaining-table/evaluator reading credit or new other-backend
runtime proof is claimed. Replay: [[julia-staged-diagnostic-byte-boundaries]].

## 2026-09-11 — Julia lower completion and upper prefix

Julia .1.23 reads UnicodeCaseMapping344-1843, completing lower mappings through
U+1E921 and opening upper mappings through U+03B7. Fullwidth/supplementary
ranges and retained identity rows remain pinned. Upper sharp-s expands to SS;
U+0149 expands to 02BC/004E, U+01F0 to 004A/030C, and Greek expansions retain
ordered combining scalars. Directional casing is neither an inverse nor a
normalization operation. Remaining upper/property/evaluator source is unread.

Fresh managed Unicode regeneration byte-compares the neutral artifact and all
five modules, preserving1563/1581 mappings,158/464 ranges and12 fixtures. The
39 Julia casing assertions remain .1.22/194265ff4 evidence against unchanged
source; no fresh runtime, other-backend execution or new defect is claimed.
Reverify: bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py.

## 2026-09-11 — Julia upper completion and contextual property prefix

Julia .1.24 reads UnicodeCaseMapping1844-3343, completing upper mappings
through U+1E943. Both sigma forms map to U+03A3; Greek ordered combining/iota
expansions, Latin/Armenian ligatures and supplementary mappings remain pinned.
All158 sorted inclusive cased ranges are read through U+1F189. Case-ignorable
ranges are read through U+0605; the rest and contextual evaluator remain unread.
Property membership is distinct from whether upper/lower conversion changes a
character. Fresh managed regeneration preserves every module,1563/1581 mappings,
158/464 ranges and12 fixtures. Casing39 remains .1.22/194265ff4 evidence against
unchanged source; no new runtime, data revision or defect is claimed.
Reverify: bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py.

## 2026-09-11 — Julia evaluator reading complete

Julia .1.25 reads UnicodeCaseMapping3344-3832 through EOF, completing all464
case-ignorable ranges through U+E01EF and the evaluator. Sorted inclusive ranges
use binary search. Final Sigma scans the original code points, skips ignorable
characters and requires preceding cased/no following cased context. Ordered
full mappings preserve unmapped code points without normalization or host casing.
Fresh casing39 and selection1 pass, including all twelve direct/helper/receiver/
array fixtures. Fresh regeneration preserves all modules,1563/1581 mappings and
158/464 ranges. The managed replay is in [[julia-semantic-call-staged-projection-plan]].

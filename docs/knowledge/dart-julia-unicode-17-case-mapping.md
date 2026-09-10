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

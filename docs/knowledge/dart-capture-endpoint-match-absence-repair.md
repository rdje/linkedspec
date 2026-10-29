---
id: dart-capture-endpoint-match-absence-repair
title: Dart anonymous capture readers require a local match and failed takes preserve their boundary
answers:
  - "why did Dart capture_slice_len return zero or a cursor width before matching"
  - "how does Dart distinguish an unavailable capture endpoint from an empty match"
  - "does an unavailable Dart capture_take move its rolling boundary"
  - "does the Dart anonymous endpoint repair also fix named marks"
date: 2026-10-29
status: anonymous40.3 focused repair verified; named47/peers/SDK deprecations/selection/full admission separate
tags: [dart, capture, match, source-location, absence, mutation]
evidence: "TYPE40.3 dart-capture-endpoint-intake.json.gz retains16-source SDK/restored/plan/separate VM6healthy10RED ->16pass, exact unchanged controls/inputs/metadata/traces,46 selected tests and clean changed-file fatal analysis."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/capture_endpoint_absence_test.dart test/capture_boundary_number_results_test.dart test/source_boundary_compatibility_aliases_test.dart test/null_return_acceptance_test.dart"
---

_captureEndCodeUnit falls back to cursorCodeUnit when registers.localMatch is
absent. Anonymous reads therefore manufactured empty/0 or a cursor prefix, and
takes considered that a successful span and advanced their rolling boundary.
Four guards in _captureSliceText/_captureSliceLength and zero-argument take
dispatch now require localMatch for match-start endpoints. Through-cursor and
rest readers keep their own endpoints; valid empty/zero/Unicode and successful
takes remain unchanged. No new frame/state/schema/helper/policy is introduced.

Independent16-source SDK/restored/plan/separate VM results change6healthy10RED
to16pass. Exact source/normalized/compiled/plan/emitted/metadata and six healthy
full native results/cursors/flags/output/lifecycle/traces are unchanged. Same
baseline emitted modules run against updated runtime: no regeneration; rebuild
AOT applications. Four selected files46 tests and fatal changed-file analysis/
format pass. Whole-package matching SDK infos remain DART-STARTUP-READING.2.25.

The shared fallback also serves named reads/takes/mark operations. Separate two-
source SDK controls confirm named endpoint absence/mark movement; exact behavior
is unchanged by the anonymous fix. [[dart-named-capture-endpoint-absence-gap]] and
P1 TYPE47 own target/independent repairs after40/41 before45/wider features/full
admission. No fresh named, peer backend, whole component or full admission credit.

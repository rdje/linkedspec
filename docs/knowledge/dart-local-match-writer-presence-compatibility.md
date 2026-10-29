---
id: dart-local-match-writer-presence-compatibility
title: Dart local-match mark writers already preserve targets when endpoints are absent
answers:
  - "does Dart mark_match_start preserve an existing mark without a local match"
  - "does Dart evaluate a local writer name before checking match presence"
  - "did Dart local-match writer absence require a runtime repair"
  - "which Dart routes verify missing local-match writer targets"
date: 2026-10-29
status: bounded49.3 compatibility verified; peers/selection/SDK deprecations/full admission separate
tags: [dart, marks, writer, match, absence, endpoint, mutation]
evidence: "dart-writer-endpoint-intake.json.gz retains current15/four-route compatibility, exact49.0 source/results/traces,35 selected tests and actual wrong-oracle1RED14pass."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/named_writer_endpoint_absence_test.dart test/named_capture_endpoint_absence_test.dart test/named_mark_number_results_test.dart test/complete_named_mark_contract_test.dart"
---

_callCaptureMarkHelper's mark_match_start/end cases evaluate markName first, then
read nullable localMatch.codeUnitStart/end and invoke typedMarkSet only when the
name and endpoint exist. Accepted name effects therefore remain while absence
adds no mark write or deletion. Other writers retain their own endpoints. No
runtime or generated source repair is needed for frozen49.0.

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

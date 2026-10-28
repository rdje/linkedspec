---
id: dart-accepted-null-return-provenance
title: Dart null return acceptance comes from the owning selected match or completed iteration
answers:
  - "why does Dart recognized completed blind parent with E or IT null return report false"
  - "how does Dart distinguish accepted null action returns from actual misses"
  - "does Dart null lifecycle return globally accept early I LS or failed minimum"
date: 2026-10-28
status: bounded39.2.7.1 repaired/targeted-checked; pure-null observation .7.2 and admission remain
tags: [dart, null, acceptance, lifecycle, action, return-provenance]
evidence: "dart-null-returns-intake.json.gz retains20 authored sources37 inputs5healthy15actualRED ->20pass SDK/plan, same20 baseline emitted modules and122 nearest controls."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/null_return_acceptance_test.dart test/recognition_repetition_progress_test.dart test/minimum_miss_routes_test.dart"
---

Private _returned previously derived matched solely from value != null, and
_ActionReturn carried only payload. A completed null EX/E/IT or selected action
thus lost its actual accepted outcome. The return factory now accepts an
explicit owning acceptance bit, while preserving existing non-null whole-rule
authority. This changes no public schema, compiler/emitter or source plan.

Selected regex action/LE and successful plain blind child post-call returns
carry private accepted provenance. Plain dispatch E/LX uses current complete
attempt/prior accepted next; repeated LS uses prior completed count, LE/IT
uses the accepted current attempt, satisfied EX/LX/E uses count>0. Under-minimum
LX explicitly remains unaccepted. Initial I/LS, true misses and zero-min no-hit
null remain false. No sticky previous regex hit or global null acceptance is
introduced; non-null lifecycle overrides keep their existing authority.

20 authored sources37 inputs5healthy15actualRED ->20pass native/restored/plan;
all raw source/normalized/compiled/plan/emitted bytes identical. Same20 baseline
modules/main consumer reused fresh with matching public values; direct matched
flags are asserted in SDK paths, six wrapper sources expose recognized flags
inside fresh returned values. Existing122 direct-dependent tests and fatal
static analysis pass. Early AND null skips trailing slots, legal whole-rule LE
zero-width exits remain legal, true minimum/cursor/max1/mark controls hold.

Generated applications use the updated runtime; source/plans remain valid.
Pure-null coordinator observation is still separately owned39.2.7.2:
[[dart-null-return-and-pure-observation-gaps]]. Broad lifecycle attribution,
peer intake and full admission remain tracked; no full family parity inferred.

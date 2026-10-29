---
id: dart-named-capture-endpoint-presence-repair
title: Dart named capture takes preserve their own origins and require local endpoints
answers:
  - "why did Dart named capture_take advance the anonymous boundary"
  - "do Dart named match-start capture readers return null before matching"
  - "are Dart named capture name effects evaluated when no endpoint exists"
  - "must emitted Dart parsers be regenerated for the named endpoint repair"
date: 2026-10-29
status: bounded47.3 focused repair verified; peers/writer49/selection/SDK deprecations/full admission separate
tags: [dart, capture, mark, absence, endpoint, mutation]
evidence: "dart-named-capture-endpoint-intake.json.gz retains actual producers,15-source2healthy13RED ->15pass on four routes, original modules,36 selected tests and fatal changed-file analysis/format."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/named_capture_endpoint_absence_test.dart test/named_mark_number_results_test.dart test/capture_endpoint_absence_test.dart test/complete_named_mark_contract_test.dart"
---

_callCaptureMarkHelper previously substituted the live cursor for an absent local
match on named match-start text/width/take-width. Its text capture_take always used
the anonymous origin and skipped its named argument. Names now evaluate through
existing _captureName before the nullable endpoint check; named text take uses
existing typed mark/span access, advances only its named mark on success, and
leaves the anonymous boundary alone. Anonymous zero-arg and available cursor/rest/
between/writer paths remain. No new helper/frame/schema/domain/state is introduced.

## Dart repair47.3 (2026-10-29)

Named text/width/take-width now require nullable localMatch after name evaluation;
one-argument capture_take uses/advances its named mark and preserves the anonymous
boundary. Missing/reversed returns null without extra mutation, empty/zero/Unicode
and name effects remain. No new owner/state/frame/schema/helper/domain policy.
Independent15-source SDK/restored/plan/separate VM2healthy13RED ->15pass, ordinary
15 cases13RED ->15pass. Four targets36 tests/fatal changed-file analysis/final format
pass; original source/normalized/compiled/plan/emitted/full metadata and both healthy
complete results/traces exact. Same15 old modules reuse updated runtime: rebuild
AOT apps, no source regeneration. Initial instrument brace error recovered before
baseline; formatting only wraps a new switch arm, tested preformat source retained.
Whole-package SDK deprecations2.25/selection23.4.1 remain. Packet
dart-named-capture-endpoint-intake.json.gz retains closure. Independent Julia47.4/
safe Lua47.5, writer49/referenced-blind48/Phase0 owner45 precede full admission.

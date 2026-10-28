---
id: dart-active-edge-body-candidate-ownership
title: Dart body choice now uses authored outgoing edges through one shared helper
answers:
  - "why did a wildcard entry swallow a Dart body edge"
  - "how does Dart preserve reversed duplicate action edge priority"
  - "where does Dart filter outgoing body choice candidates"
date: 2026-10-28
status: bounded36.2 repaired/targeted-checked; full admission and independent peers open
tags: [dart, regex, slots, dispatch, source, trace]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.2; active-edge-body-dart-intake.json.gz exact baseline/candidate/final sources and channels."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/active_edge_body_candidates_test.dart"
---

Both _selectRegexMatch and _executeRegexOnce formerly chose across complete
rule.regexPatterns, so untargeted declarations could consume input and catalog
order could override authored edge order. Private _matchChoice now queries each
outgoing edge.regexIndex through existing _matchSpecific in authored order on
non-AND action-edge choice. Earliest start wins, ties keep first authored; a
cursor-start candidate returns immediately. Full catalogs and selected original
indices/captures remain intact; no extra per-selection regex compilation or
text-derived identity. Entry/AND/no-edge/blind/cursor/frame/formats keep owners.

Final13pass native/restored SpecFile/generated-plan; exact native/generated trace
slot2 is collected in memory through public caller-owned emitters. Existing
duplicate15-role/rule-local5/capture collection4 selected groups and fatal changed
analysis pass. No full suite/matrix/independent emitted package or peer admission.

Initial LS-return gap carrier compounds an independent live-cursor bug, owned38
before admission. The corrected selection still returns early before Dart's
_acceptRegexMatch advances cursor; public Hcat probe retains1 versus reference4.
Final dispatch gap test reads inside the edge to isolate eligibility; no expected
nulls are normalized and runtime cursor code is unchanged. See the separate
[[dart-gap-early-ls-return-cursor-drift]] card and retained complete epochs.

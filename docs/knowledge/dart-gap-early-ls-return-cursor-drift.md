---
id: dart-gap-early-ls-return-cursor-drift
title: Dart early LS return exposes selected captures before advancing its live cursor
answers:
  - "why does Dart LS return leave a child cursor before its selected match"
  - "why can Dart capture_gaps LS return append unexpected null payloads"
  - "which task owns Dart early LS selected-match cursor drift"
date: 2026-10-28
status: P1 owned38.0/.1 after33/35/34 and before37/full23.4 admission or push
tags: [dart, cursor, lifecycle, gap, return, source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.2 public Hcat native/generated/reference native/fresh probes, exact source/trace/channels in active-edge-body-dart-intake.json.gz."
reverify: "Recover probe_dart_gap_ls_cursor.dart and probe_perl_gap_ls_cursor.pl from active-edge-body-dart-intake.json.gz; use the project-routed Dart/Perl commands retained there."
---

On Hcat, Top selects H, calls Value then reports its payload and caller mark.
Value selects cat with capture_gaps; LS returns gap text, match text and live
mark_pos. Reference Perl native/fresh returns [[empty,cat,4],4]; Dart native/plan
returns [[empty,cat,1],1]. Native trace selects Value alternative1 span1..4
with cursor_before1, isolating live cursor from selected captures and eligibility.

_prepareGapCandidate installs registers and context but not cursorCodeUnit.
_acceptRegexMatch advances to codeUnitEnd only after LS. A lifecycle return
unwinds before that write; a broad incoming wildcard can rematch the unconsumed
suffix and append nulls. These cursor paths were not changed by36.2. The H/cat
control has no competing untargeted match, distinguishing this from body choice.

P1 owner38.0 reconciles ADR0045/0048, live cursor versus committed gap boundary,
early-return, rollback and explicit LS cursor mutation authority before38.1 fixes
Dart through its existing sole state owner. Correct expected4 and original broad
carrier values must be verified; do not bless current1/null suffixes. Other
backends are not inferred defective. Full23.4/push waits for verified repair.

2026-10-29 shared authority38.0 freezes selected live end before flagged LS,
preserved explicit LS rewind through action/return, separate post-LE boundary
commit and existing cursor-regression guard. Public reference8sources10inputs
native/separate emitted agree, portable7/9 plus unflagged compatibility1/1.
[[gap-selected-match-ls-live-cursor-authority]] retains exact target/proof.
Independent backend repair still pending; no new backend RED or completion credit.

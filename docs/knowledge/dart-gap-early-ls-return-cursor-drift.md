---
id: dart-gap-early-ls-return-cursor-drift
title: Dart capture-enabled LS observes selected end and preserves explicit cursor rewind
answers:
  - "why does Dart LS return leave a child cursor before its selected match"
  - "why can Dart capture_gaps LS return append unexpected null payloads"
  - "which task owns Dart early LS selected-match cursor drift"
date: 2026-10-28
status: bounded38.1 fixed/targeted-checked; independent peers and full admission remain
tags: [dart, cursor, lifecycle, gap, return, source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.2 public Hcat native/generated/reference native/fresh probes, exact source/trace/channels in active-edge-body-dart-intake.json.gz."
reverify: "Recover probe_dart_gap_ls_cursor.dart and probe_perl_gap_ls_cursor.pl from active-edge-body-dart-intake.json.gz; use the project-routed Dart/Perl commands retained there."
---

## Pre-repair diagnosis (2026-10-28)

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

## Repaired behavior (2026-10-29)

2026-10-29 .38.1 now advances the existing live cursor at flagged preselection
and carries matchPreselected to acceptance, avoiding an overwrite of authored LS
rewind. Gap boundary/commit/discard/rollback, ordinary acceptance and unflagged
timing are unchanged. Independent7portable sources9inputs3healthy4RED ->7pass,
plus legacy1/1; same8 baseline modules fresh, exact inputs/four healthy outcomes
and legacy traces preserved. Hcat4/prefix5/emoji scalar5, rewinds1 and typed
repeated commit regression verified. Normal/nullable28 plus selected gap native/
rollback/reconstruction/plan2tests pass; formatted/fatal changed analysis clean.
Whole-package analysis still has only owned SDK matching warnings under startup
2.25, not a complete gate pass. Packet dart-gap-ls-cursor-intake.json.gz retains
closure. Julia38.2/Lua38.3 independent repairs and broader admission remain.

2026-10-29 Julia38.2 supplies explicit original broad-carrier acceptance
supplement for Dart38.1: current9normal/fatal test analysis and reference native/
separate emitted1/1 pass, one exact payload/span/cursor6 and no null suffixes.
Earlier core7/9 and8-module fresh receipts remain frozen; supplemental broad
Dart/Julia fresh emission is23.4.1-owned before admission.

---
id: julia-gap-early-ls-return-cursor-drift
title: Julia capture-enabled LS observes selected end and preserves explicit cursor rewind
answers:
  - "why does Julia early LS return leave the caller cursor before the match"
  - "does Julia capture_gaps LS return retain selected-match cursor position"
  - "which task owns Julia early LS cursor drift"
date: 2026-10-28
status: bounded38.2 fixed/targeted-checked; independent Lua and broader admission remain
tags: [julia, cursor, lifecycle, gap, return, source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.3 public Hcat four-route probe and exact Perl oracle source; active-edge-body-julia-intake.json.gz."
reverify: "Recover probe_active_edge_julia_gap_ls_cursor.jl from active-edge-body-julia-intake.json.gz; run through tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error."
---

## Pre-repair diagnosis (2026-10-28)

Top selects H on Hcat, calls Value and reports child payload plus caller cursor.
Value selects cat under capture_gaps; LS reports gap, match and live cursor.
Julia native/reconstructed SpecFile/generated plan/fresh Module all return
[[empty,cat,1],1], whereas Perl native/fresh returns[[empty,cat,4],4] for the exact
same source. No competing untargeted pattern exists in this control.

_prepare_runtime_gap_candidate! installs local registers/context but not live
cursor. _accept_runtime_regex_match! advances cursor only after LS. Early return
unwinds first; broad incoming patterns can rescan the suffix and append nulls.
36.3 leaves these cursor paths unchanged. P1 owner38.2 reuses shared authority38.0
to preserve gap-boundary commit/discard, whole-rule return, rollback and explicit
LS cursor mutations while repairing the live cursor through its sole owner.
Correct4/4 and broad-carrier expected values must be verified before admission;
do not bless current1/nulls or infer a Lua defect. Diagnostic is separate from
the healthy normal test, with no semantic success credit. See also
[[dart-gap-early-ls-return-cursor-drift]].

2026-10-29 shared authority38.0 freezes selected live end before flagged LS,
preserved explicit LS rewind through action/return, separate post-LE boundary
commit and existing cursor-regression guard. Public reference8sources10inputs
native/separate emitted agree, portable7/9 plus unflagged compatibility1/1.
[[gap-selected-match-ls-live-cursor-authority]] retains exact target/proof.
Independent backend repair still pending; no new backend RED or completion credit.

## Repaired behavior (2026-10-29)

38.2 advances the existing live cursor during flagged preselection and carries
match_preselected to acceptance, preserving authored LS rewind. Ordinary cursor,
whole returns, unflagged timing and gap boundary/commit/discard/rollback remain.
Independent core portable7/9 has3healthy4RED ->7pass plus legacy1/1; same8
modules fresh and exact inputs/four healthy observations/legacy traces preserved.
Current normal124 includes original broad carrier1/1 with one payload/span/cursor6
without null suffixes across SDK/restored/plan. Nullable390/recognition207 and
six exact existing nested-gap/rollback assertions pass; normal included once.
Broad reference native/separate emitted1/1 and supplemental Dart9normal/fatal
test analysis pass. Core fresh proof remains eight modules; supplemental Dart/
Julia broad fresh replay required under23.4.1 before admission. Current packet
julia-gap-ls-cursor-intake.json.gz retains closure; Lua38.3 independent next.

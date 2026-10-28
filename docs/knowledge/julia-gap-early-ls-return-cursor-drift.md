---
id: julia-gap-early-ls-return-cursor-drift
title: Julia early LS return exposes selected captures before advancing its live cursor
answers:
  - "why does Julia early LS return leave the caller cursor before the match"
  - "does Julia capture_gaps LS return retain selected-match cursor position"
  - "which task owns Julia early LS cursor drift"
date: 2026-10-28
status: P1 owned38.2 after shared38.0/Dart38.1, before37/full23.4 admission or push
tags: [julia, cursor, lifecycle, gap, return, source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.3 public Hcat four-route probe and exact Perl oracle source; active-edge-body-julia-intake.json.gz."
reverify: "Recover probe_active_edge_julia_gap_ls_cursor.jl from active-edge-body-julia-intake.json.gz; run through tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error."
---

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

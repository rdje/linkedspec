---
id: julia-active-edge-body-candidate-ownership
title: Julia body choice now uses outgoing compiled slots in authored edge order
answers:
  - "why did Julia wildcard entry declarations swallow body edges"
  - "where does Julia filter outgoing body choice candidates"
  - "does Julia preserve reversed duplicate action edge priority"
date: 2026-10-28
status: bounded36.3 repaired/targeted-checked; safe Lua intake/full admission open
tags: [julia, regex, slots, dispatch, source, trace]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.36.3; active-edge-body-julia-intake.json.gz retains exact source and native/reconstructed/plan/fresh Module outputs."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia, JSON3, Test; include("julia/test/active_edge_body_candidates_test.jl")'"
---

_select_runtime_regex_match and _execute_runtime_regex_once! formerly chose
against full catalogs. Shared _match_runtime_choice now tests outgoing compiled
edge.regex_index alternatives in authored order for non-AND action-edge choice,
reusing _match_runtime_specific and retaining original captures/indices. Earliest
start wins and equal starts keep first authored; at-cursor candidates may return
immediately. Full catalogs and indexed-first/AND/blind/no-edge/frame/cursor/gap/
format owners remain unchanged; no extra per-selection regex compilation.

Refined58pass/34RED becomes92pass across native/reconstructed SpecFile/generated
plan/fresh emitted Module; strict Bool/Number distinction, exact Unicode/source/
gap/slot and priority controls pass. Existing duplicate121/rule-local104/capture
collection12 selected assertions pass. Both slot traces use memory; no temp owner.
Fresh Module is same-process independent loading, not isolated package proof.

The initial merged stream interleaves stderr inside one JSON row; separated
streams before production recover17 complete observations. Final normal test
removes only an unasserted adjacent diagnostic, with exact assertion equality
and syntax checked. That diagnostic confirms live/caller cursor1 versus reference4
on Hcat; [[julia-gap-early-ls-return-cursor-drift]] owns38.2 before admission.
No cursor policy change, null rebasing, full suite/matrix or peer claim here.

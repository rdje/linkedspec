---
id: julia-index-source-guards
title: Julia index role preserves guards and leading null effects
answers:
  - "how does Julia guard free index_of and index continuations"
  - "why does Julia index guarding retain call_index"
  - "does Julia index guarding change scalar_result or membership copying"
  - "where are Julia index source and null-plus-with tests"
date: 2026-10-31
status: bounded Julia72.4 targeted-checked; full admission separate
tags: [julia, array, index_of, guards, null, with]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.72.4; index-guard-julia-intake.json.gz retains actual strict106 before/after, eleven runtime files/four consumers, sources/instruments and raw phases/stderr qualification."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; const REPO_ROOT=pwd(); include(ARGS[1]); include(ARGS[2]); include(ARGS[3]); include(ARGS[4])' julia/test/index_result_guard_composition_test.jl julia/test/index_result_receivers_test.jl julia/test/null_array_keys_test.jl julia/test/contains_result_guard_composition_test.jl"
---

Julia72.4 preserves canonical index_of source/prefix guards. Independent unchanged106 assertions90PASS16RED become106PASS native/restoredSpec/plan/fresh Module with strict Number-versus-Bool identity: shared16/null-prefix3/null-with2/source18 scaffold. Baseline90 includes four failing-group route-key scaffolds; fifteen healthy values/two needed errors/eighteen public shapes remain exact. All19 values preserve numeric0/null/no-match/equality/null-empty/SNC snapshots/defaults/explicit Array bridges/valid null-empty-Array with/function state. Free container/free-with/receiver-bridge/function gaps are repaired by a pure canonical free-two/ordinary one-needle role in common kind_guarded_result. Existing leading nullable index needle effects remain; earlier rejection exits before later operands/bodies. Retain call_index for both leading index qualification and the separate Array-end mutation gate. Producer/scalar_result assignment and guard/with/preflight/copy depth/context/schema stay; one exact runner include, P1 copy72.6 separate. Nearest index6/null-key36/contains141=183/strict depwarn pass. Stderr contains only anchored package-precompile/cache-lock notices; injected unclassified warning rejected. Eleven actual joined/one-stem runtime files derive from four consumers, including index spec/inline expectations and nearest contains excluded shapes;206 other inputs/per-phase identities exact at behavioral epochs, not complete generation closure. Actual sources/instruments/templates/inputs/raw phases retained in index-guard-julia-intake.json.gz. Book/card/map/target/task/roadmap/live/resume/history align; rebuild Julia apps/runtime. Manual checklist under23.4.3 scope limit. Independent safe Lua72.5 next, then mandatory P1 copied-null/rejection72.6 before unrelated selection. No isolated package/general nullable Array/general isolation/domain/context/full23.4 admission; no full suite or push.

_runtime_is_ordinary_index_result_chain qualifies canonical positional free-two/one-needle roles. The common loop uses call_index only to preserve a leading nullable index consumer; the separate non-leading Array-end mutation rejection remains. scalar_result starts false for null, so its existing guard/assignment stay unchanged. Presence and membership retain their existing later-null rights. General copy/null/rejection72.6 remains separate.

Later copied-null dispatch repaired by bounded72.6.4: [[julia-copied-null-index]]. Earlier leading-only nullable-index descriptions are historical. Retain enumerate/call_index for the separate Array-end mutation restriction while canonical nullable index crosses both guards.

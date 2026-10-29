---
id: julia-local-match-writer-presence-compatibility
title: Julia local-match mark writers already preserve targets when endpoints are absent
answers:
  - "does Julia mark_match_start preserve existing marks without a local match"
  - "does Julia evaluate local writer names before checking match presence"
  - "did Julia local-match writer absence need a runtime repair"
  - "which Julia routes verify missing local-match writer target preservation"
date: 2026-10-29
status: bounded49.4 compatibility verified; safe Lua/selection/full admission separate
tags: [julia, marks, writer, match, absence, endpoint, mutation]
evidence: "julia-writer-endpoint-intake.json.gz retains15-source/four-route compatibility,378 selected assertions and actual wrong-oracle3fail102pass with depwarn=error."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error julia/test/named_writer_endpoint_absence_test.jl"
---

_call_runtime_named_capture_helper!'s mark_match_start/end cases evaluate mark_name,
then require a non-null current local_match before calling _typed_mark_set! with
the respective codeunit edge. Absence therefore adds no write/delete after name
effects; other writer families retain their own endpoints and ownership. No
runtime or generated-source repair is needed for frozen49.0.

## Julia compatibility49.4 (2026-10-29)

Current15 native/restored/plan/separate emitted allpass. Existing name evaluation
then nullable local_match guard before typed mark update already preserves fresh/
seeded/name-effect targets and real empty/zero/Unicode/local-live cursor behavior.
No runtime change. Writer105/named endpoint105/named Number-function-scope155/
complete marks13 pass378 assertions with depwarn=error/empty healthy stderr. Wrong
first-mark oracle3fail102pass, fixture/runtime untouched; no product RED. Exact
source/normalized/compiled/plan/emitted/full metadata/results/high traces retained;
runtime/compiler/emitter/fixture match activation HEAD, no regeneration. Packet
julia-writer-endpoint-intake.json.gz retains closure. Normal runtests include
verified; selection23.4.1/safe Lua49.5/48/45/full admission remain separate. Same
project/depot, no isolated dependency or full package claim.

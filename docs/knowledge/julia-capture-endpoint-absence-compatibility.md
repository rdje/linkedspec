---
id: julia-capture-endpoint-absence-compatibility
title: Julia already preserves unavailable anonymous capture endpoints and failed take boundaries
answers:
  - "does Julia capture_slice_len return null before a local match"
  - "does Julia capture_take advance its boundary without a local match"
  - "did Julia need a runtime repair for anonymous endpoint absence"
  - "which Julia regression distinguishes missing endpoints from real empty matches"
date: 2026-10-29
status: bounded40.4 independent compatibility and normal registration verified; canonical selection/Lua/named/full admission separate
tags: [julia, capture, endpoint, absence, presence, mutation, generated]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.40.4 julia-capture-endpoint-intake.json.gz retains16-source SDK/restored/plan/separate-process emitted compatibility,718 selected assertions and actual three-failure wrong-oracle control."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error julia/test/capture_endpoint_absence_test.jl"
---

_call_runtime_anonymous_capture_helper! in julia/src/runtime/Interpreter.jl uses
nullable local_match for match-start endpoints. Missing endpoint returns nothing
before span projection or take mutation; through-cursor/rest families select their
own endpoints. Present empty/zero/Unicode remain valid. No runtime repair needed.

Independent16-source native/restored full matched/value/Unicode cursor/output/
lifecycle/high trace, plan and separate-process emitted Module all match frozen
40.0. Full source/normalized/compiled/plan/emitted/metadata and actual observations
are retained. Registered normal112/Number75/aliases141/null390 assertions pass718
with depwarn=error. A temporary wrong empty-text expectation at root_blind_I fails
three value routes with109pass/0error; this discriminates the oracle, no product
RED claim. Runtime/compiler/emitter/shared fixture match the clean activation base.

Fresh process uses current project/depot and independently loads retained generated
source, no isolated dependency package. No helper/policy/schema/generation change,
regeneration requirement, named/peer/full component or admission credit. Canonical
selection23.4.1/Lua40.5/nested-error41/named47/Phase0 owner45 remain separate.

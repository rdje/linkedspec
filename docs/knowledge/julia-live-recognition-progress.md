---
id: julia-live-recognition-progress
title: Julia live recognize_once repetitions share private typed progress and preserve caller origin
answers:
  - "does live Julia recognize_once enforce repetition progress"
  - "where does Julia live repetition progress diagnostic keep caller origin and offsets"
  - "which Julia zero-width paths remain legal after live progress repair"
  - "why does Julia early AND progress check carry repetition start"
date: 2026-10-28
status: bounded39.3.6 repaired/targeted-checked; remaining Julia features and admission open
tags: [julia, recognition, repetition, progress, trace, diagnostics, scope]
evidence: "julia-live-progress-intake.json.gz retains24 safe authored sources9healthy15actualRED ->24pass234 SDK assertions, same24 baseline emitted modules/consumer and direct-dependent proof."
reverify: "bash tools/run_julia_project_data.sh --project=julia julia/test/recognition_repetition_progress_test.jl"
---

ActionRecognizeOnceExpr now wraps the actual child in a private caller-origin
stack, removed in finally. Accepted normal/next repeated regex/blind completion
calls RecognitionTransaction.validate_repetition_progress before count/IT/max/
ordinary zero exits. The neutral adapter delegates to this typed private owner;
existing recursion diagnostics and public exports/schema remain unchanged.

Early repeated AND actions currently escape the whole rule before loop finalizing;
a private repetition_start_codeunit parameter validates that accepted completion.
39.3.2 owns group-return repair and can remove this plumbing once all accepted
groups reach the common loop guard. No repeated AND collection parity is claimed:
three healthy historical scalar controls explicitly name that repair owner.

Whole-rule LE returns remain legal before the progress check, and ordinary parsing
outside recognize_once and one-shot zero recognition remain legal. IT cannot
bypass a completed accepted repetition check. Existing RuntimeInterpreterException
preserves code/failing rule/runtime_execution through action unwinding. Low trace
MARK julia_runtime:recognition_repetition_progress_failure retains actual private
code/rule/caller-origin/start_offset/end_offset. Generated/fresh existing error
envelopes preserve code text; private trace fields are not claimed there.

24 safe sources9healthy15actualRED ->24pass234 SDK assertions; same24 baseline
modules/consumer reused in a separate process. Exact raw source/normalized/
compiled/plan/emitted strings and9 healthy control observations unchanged.
Prefix1/current-edge/scope cleanup, legal LE/ordinary/one-shot/consuming controls
pass. Compiler/emitter/matching unchanged. Normal Julia driver includes exactly
one new consumer. The packet retains initial harness Dict/interleaved-stream
corrections before valid evidence; neither is product RED. Other Julia feature,
lifecycle/Unicode/recursive admission and full canonical checks remain tracked.

39.3.2 now routes early and normal repeated AND groups through the common loop
progress guard and removes repetition_start_codeunit plumbing. All24 original
guard sources remain unchanged; three historical scalar expectations become
arrays and234 assertions pass. Current group mechanism/proof:
[[julia-repeated-and-group-outcomes]]. Original .6 packet/9-control identity
claim stays historical to that commit; no private early escape remains current.

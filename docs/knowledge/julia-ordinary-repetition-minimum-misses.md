---
id: julia-ordinary-repetition-minimum-misses
title: Julia ordinary repetition minimum misses return failed null without rewinding consumed input
answers:
  - "why does Julia blind repetition minimum miss throw an interpreter error"
  - "does Julia ordinary minimum failure roll back consumed input"
  - "can Julia recover after a child repetition minimum miss"
date: 2026-10-28
status: bounded39.3.3 repaired/targeted-checked; blind post-call nullable and admission remain
tags: [julia, repetition, minimum, recognition, cursor, errors, recovery]
evidence: "julia-minimum-intake.json.gz retains12 qualified sources29 inputs4healthy8actualRED ->12pass289 assertions, exact inputs/control/error identity and same12 baseline fresh modules."
reverify: "bash tools/run_julia_project_data.sh --project=julia julia/test/minimum_miss_routes_test.jl"
---

_execute_runtime_blind_rule! and noncollector _execute_runtime_regex_rule!
formerly threw generic expected-at-least errors below minimum. After existing
LX authority, both now return _RuntimeRuleResult(false,nothing), matching the
already repaired collector paths. No real exception is caught or converted.
Consumed input remains consumed; caller match registers are restored by the
existing rule finally, and direct calls store null retv and can continue.

12 qualified sources29 inputs4healthy8RED ->12pass289 assertions native/restored
matched/value/cursor and generated/fresh values/errors. Same12 baseline modules/
consumer reused separate process; raw source/normalized/compiled/plan/emitted
strings and four healthy observations unchanged. Successful-null versus failed
minimum, no-hit/zero-min/max, partial cursor, LX override, recognition, caller
capture/retv and recovery all pass. Original group21/live24/sparse31 fixture
bytes unchanged; sparse blind_minimum enabled, blind_default remains owned.

Initial peer unknown_helper code oracle is unqualified for ordinary Julia fallback:
the actual helper error/rule/runtime phase survives but code is absent. P2 .8
owns contract reconciliation/repair before admission:
[[julia-unknown-runtime-helper-diagnostic-gap]]. Preservation oracle checks
actual text/rule/phase and exact before-after identity; initial epochs retained
without invalid product RED credit. One recognition source uses canonical bound
commit spelling before baseline. Compiler/emitter/matching/recognition authority
unchanged; no broad lifecycle/null/collection/full admission claim.

---
id: julia-named-capture-take-origin-repair
title: Julia named capture_take reuses named span guards and advances only its mark
answers:
  - "why did Julia capture_take with a name change the anonymous boundary"
  - "did Julia named capture endpoints need new absence guards"
  - "does Julia named capture_take evaluate its name before checking endpoints"
  - "must Julia emitted parsers be regenerated for named capture_take"
date: 2026-10-29
status: bounded47.4 focused repair verified; safe Lua/writer49/selection/full admission separate
tags: [julia, capture, mark, endpoint, absence, mutation]
evidence: "julia-named-capture-endpoint-intake.json.gz retains own15-source8healthy7RED ->15pass on four routes,105 normal assertions and385 selected assertions with depwarn=error."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error julia/test/named_capture_endpoint_absence_test.jl"
---

_evaluate_runtime_call! previously sent capture_take(name) to its anonymous helper,
ignoring the name and changing capture_start. Only that one-argument overload now
dispatches to _call_runtime_named_capture_helper!, selecting its existing match-
start text branch and valid-only mark update. Its existing name evaluator, nullable
local-match register and typed span guards supply the required behavior. The
anonymous zero-argument path and other helpers remain unchanged.

## Julia repair47.4 (2026-10-29)

Named nullable endpoint guards already work. One-argument capture_take previously
dispatches anonymously; it now shares the existing named helper's name/typed span/
valid-only mark update paths. Zero-argument anonymous and available endpoints/
writers remain unchanged, no new state/frame/schema/helper/domain policy.
Independent15-source SDK/restored/plan/separate-process8healthy7RED ->15pass;
ordinary84pass21fail ->105pass. Named105/anonymous112/named Number-function-scope155/
complete marks13 pass385 assertions with depwarn=error. Source/normalized/compiled/
plan/emitted/full metadata and8 healthy complete outcomes/traces exact. Same15 old
modules reuse updated runtime/precompile image; no source regeneration. Actual
post-edit precompile/cache notices are strictly qualified/retained, no warning/
error suppression or empty-stderr claim. Current project/depot, no isolation.
Packet julia-named-capture-endpoint-intake.json.gz retains closure, normal runtests
registration verified; exact selection23.4.1 remains. Safe Lua47.5/49/48/45 and full
admission remain separate. Earlier anonymous/Number observations remain historical.

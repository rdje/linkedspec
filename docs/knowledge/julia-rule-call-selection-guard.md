---
id: julia-rule-call-selection-guard
title: Julia static rule-call selections reuse the actual-kind operand guard
answers:
  - "why does Julia selected call Child String execute incompatible Array operands"
  - "which Julia owner guards indexed static rule-call results"
  - "do Julia static rule-call selections preserve emitted Module behavior"
date: 2026-10-30
status: bounded Julia54.4 repaired/targeted-checked; full admission separate
tags: [julia, selection, rule-call, fluent, guards, effects]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.54.4; rule-call-result-julia-intake.json.gz retains actual31healthy/4RED→35GREEN plus computed25/boundary65 and actual source/normal/producers/inputs."
reverify: "bash tools/run_julia_project_data.sh --project=julia --depwarn=error julia/test/rule_call_result_selection_test.jl"
---

At d726758c4, direct child return brackets/kinds/static lookup already work.
All four shared13 native/reconstructed/plan/fresh Module observations execute
BAD and return[] after a selected String. _runtime_is_ordinary_computed_read
excludes call, leaving its result under legacy direct-consumer policy.

A canonical call with one bare Variable-shaped positional label joins the
existing selected-value guard. Quoted/dynamic/extra arguments/trailing blocks
retain prior roles; remaining interpreter/invocation/parser/reader/schema bytes
stay exact. Same new35/computed25/boundary65 pass under depwarn=error. Seven new
observations cover four routes; nearest computed uses its native/plan/fresh
routes. Shared13/kinds/once/order/live-origin/null/missing/normalized skips/static
lookup/typed function fence/explicit arguments and bound callable counts hold.
Exact one-line runner include registers the normal. Stderr is successful package
precompilation progress only. Fresh Module is same-process, not isolated package;
no full runner/source-domain/context/error-phase/portable admission follows.

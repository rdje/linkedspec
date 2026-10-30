---
id: rust-rule-call-selection-guard
title: Rust static rule-call selections reuse the ordinary actual-kind guard
answers:
  - "why does Rust a selected rule-call String execute incompatible Array operands"
  - "which Rust owner guards call Child indexed results"
  - "does Rust rule-call bracket composition change child invocation or callable counts"
date: 2026-10-30
status: bounded Rust54.2 repaired/targeted-checked; full admission separate
tags: [rust, selection, rule-call, fluent, guards, effects]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.54.2; rule-call-result-rust-intake.json.gz retains actual5healthy/1RED→6GREEN plus computed6/boundary6/owned fmt and original source/normal/inputs."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test rule_call_result_selection"
---

At2302be673, Rust already parses direct call result reads and preserves values,
static labels/function restrictions. Shared13 instead exposes a guard gap:
call(Child)[2].take(BAD) returns [] and executes BAD when entry2 is a String.
Engine::is_ordinary_computed_read excludes call, leaving its selected value on
legacy direct-consumer policy. The single observed failing native route stops
before restored/plan in that test; those pre-repair routes are not claimed.

A single positional Variable-shaped static label now joins the existing
ordinary selected-kind guard. Invocation, parser, typed reader, bound callable
coercion/count and all other engine bytes stay exact. Same new6/computed6/
boundary6 pass native/restored CompiledSpec/generated-plan; owned formatting
passes after a token-identical wrap. Actual kinds/once/order/live-origin/null/
missing/normalized skips/static lookup/function fence and explicit arguments
hold. Public compiled-rule classifier builds authored fixture plans. No new
quoted/dynamic/extra-argument source or child/error/deferred/schema/isolated-
source/full domain/context/portable admission. Dependency warnings stay opaque.

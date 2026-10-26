---
id: array-contains-result-handoff
title: Array contains result handoff and required-needle ownership
answers:
  - why does contains cat return undef on Perl
  - does contains return a Boolean or numeric flag
  - which task normalizes contains missing needle
  - why does contains nested in a Perl Array emit a host call
  - does contains snapshot its source before needle effects
  - why does Rust contains see a rebound Array
  - does contains distinguish null from empty text
  - why do Julia contains checks reject Bool lookalikes
date: 2026-10-26
status: Five ordinary backends targeted-checked; full admission open
tags: [array, contains, fluent, predicate, arity, task-tree]
evidence: "TYPE23.2.13 public native/fresh/substitution probe; contains-results.md; existing function[2,2] and punctuation-light contract; FUTURE5.6 explicitly activated."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/contains_result_receiver_contract.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test contains_result_receivers"
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/contains_result_receivers_test.dart"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; include(\"julia/test/contains_result_receivers_test.jl\")'"
  - "bash tools/run_lua_project_data.sh puc lua/test/contains_result_receivers_test.lua"
---

TYPE23.3.13.1-.5 implement ordinary contains scalar-result/one-operand guards on Perl/Rust/Dart/Julia/Lua. Raw producers remain numeric1/0, false renders0! and survives coalesce_nonempty. Perl distinguishes null from empty; Rust/Dart/Julia/Lua text keys merge them (.text.json versus .perl.json). P1 TYPE23.2.14 immediately after Lua5 owns that actual reference mismatch and unassessed sibling aggregate re-read seams; no sibling failure/equality repair inferred here.

Rust additionally fixes named-source re-read: consume evaluated args.first() rather than array_consuming_arg’s current ctx binding after needle effects. Native RED0/O/[z] becomes captured1/O/[z]; absent-source stays0/O/[a]. Perl/Dart/Julia/Lua captures already worked. Shared native/fresh Perl, native/restored/plan Rust/Dart and native/plan/fresh Julia/Lua retain1!/SOC/once-only/final-null, source families, false/generic/bridges/scalar guards and raw kinds. Julia requires Number and not Bool because == accepts lookalikes. Direct changed-surface checks pass; full domain/portable admission23.4 stays open.

Original FUTURE5.6 owns required-needle normalization: missing/extra before effects, both bare/parenthesized aliases identical. Perl’s nested malformed host-call/compile fallthrough is fixed; Rust/Dart/Julia/Lua actual calibration tests replace old missing0 with null. Lua5 producer/shared/direct/named alias checks pass on PUC5.5.1/LuaJIT; declared5.4 stays separate. Free signatures/equality are unchanged. Full prior assessment/source/replay records remain in this path at Git10e1005299b9a3b24ecdc08870b3046bbd5a22cd and contains-results.md/probe_contains_results.pl.

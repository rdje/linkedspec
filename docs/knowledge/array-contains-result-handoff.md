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
date: 2026-10-26
status: Perl/Rust ordinary handoff targeted-checked; others/admission open
tags: [array, contains, fluent, predicate, arity, task-tree]
evidence: "TYPE23.2.13 public native/fresh/substitution probe; contains-results.md; existing function[2,2] and punctuation-light contract; FUTURE5.6 explicitly activated."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/contains_result_receiver_contract.t"
---

Perl free membership retains numeric1/0, null distinct from empty and zero/false compatibility. TYPE23.3.13.1 adds contains only to one-operand preflight and Array scalar-result map. Shared native/fresh and direct comparison pass12 assertions after malformed-body/host-call compile RED. Hit/miss/raw kinds, source families, false/generic/bridge/scalar guards and1!/SOC/once-only/final-null pass. Existing nested and named source snapshots already worked; no producer/equality repair inferred.

Direct malformed calls already rejected. Nested missing bare/parenthesized and extra calls now uniformly return null before effects, eliminating raw items.contains() host fallthrough. Exact prior assessment/probe is retained in this path at Git299a3f67a30b991aa07b1d38922d8582a321146d and contains-results.md.

Original FUTURE-PARITY-BACKLOG.5.6 coordinates one-needle ordinary guards with TYPE23.3.13.1-.5 and actual calibration updates. Rust2 now enforces null/no-effects with named alias calibration; Dart/Julia/Lua missing0 normalization remains pending. Independent producer-kind/domain assessment remains required. Free signatures/equality/full domain and portable admission23.4 remain separate.

Rust23.3.13.2 adds scalar/one-operand lists and fixes contains named-source re-read: args.first() retains the typed value captured before needle effects; array_consuming_arg otherwise prefers current ctx. Native RED gave0/O/[z], now native/restored/plan gives1/O/[z] and absent-source0/O/[a]. Shared/direct comparison and named alias checks pass five tests. Rust retains numeric flags and null/empty merging (.rust.json), an actual Perl mismatch owned P1 TYPE23.2.14 after rollout along with unassessed sibling array/hash re-read seams. No sibling failure or equality repair is claimed.

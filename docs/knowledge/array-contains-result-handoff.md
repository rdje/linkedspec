---
id: array-contains-result-handoff
title: Array contains result handoff and required-needle ownership
answers:
  - why does contains cat return undef on Perl
  - does contains return a Boolean or numeric flag
  - which task normalizes contains missing needle
  - why does contains nested in a Perl Array emit a host call
  - does contains snapshot its source before needle effects
date: 2026-10-26
status: bounded contract frozen; implementations pending
tags: [array, contains, fluent, predicate, arity, task-tree]
evidence: "TYPE23.2.13 public native/fresh/substitution probe; contains-results.md; existing function[2,2] and punctuation-light contract; FUTURE5.6 explicitly activated."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_contains_results.pl"
---

Perl free membership returns numeric1/0 with null distinct from empty and zero/false scalar compatibility. Nested cat true1! works; ordinary receiver continuation lowers return undef because MethodLowering.pm array return-family marks contains terminal. Source/operand/consumer nested snapshot already1!/SOC/final-null; null-source0/SO; named source remains captured before needle rebinding. Preserve these producers, not a uniform Boolean policy.

Direct malformed contains returns unsupported-helper undef before effects; nested Array missing forms both emit items.contains() and fail an undefined host helper. Missing bare and parenthesized forms agree within each context. TYPE23.3.13.1 owns this immediate fallthrough/result fix.

FUTURE-PARITY-BACKLOG.5.6 explicitly owns one-authored-needle ordinary receiver guards, coordinated with TYPE23.3.13.1-.5 and actual calibration-test updates. Prior four-backend missing-needle0 is intentionally replaced by null/no-effects, preserving alias equivalence and free signatures/equality. Other backends require independent raw-kind/domain assessment. Full context/domain/portable admission23.4 remains open; no repairs claimed at freeze.

---
id: perl-callable-while-execution
title: Perl callable while preserves check order and guarded local returns
answers:
  - "does attached while execute inside a Perl callable body"
  - "what happens after the 10000th callable while body"
  - "does callable while guard failure preserve effects and parameter identity"
  - "why do conditional tests no longer expect control_while failures"
date: 2026-10-03
status: current typed attached while executor; numeric helpers and portability telemetry separate
tags: [perl, callable, while, guard, return, actionir]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5 exact RED/GREEN, guard effects/span/identity, direct canonical controls and published PUC CLI comparisons."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5-review.py"
---

CodeblockRuntime::_execute_sequence now intercepts typed control_while with an attached body.
It evaluates the condition with RuntimeLogical truthiness before each iteration; only a true
condition increments/checks the existing 10000 guard, then executes the body. A final false
condition after body10000 succeeds. Another true check raises while_iteration_limit_exceeded
before body10001, with iteration_limit10000, iterations_executed10000 and the typed node span.
Previous nonparameter effects survive; original fixed/rest slots/array and error identities restore.

Nested loops and conditional branches propagate the local return flag. Callable/eager boundaries
consume it; eager local returns let the outer callable continue. A loop statement itself yields null.
Source-poisoned typed invocation proves execution does not reparse stored source. Exact source/dump/
emitted bytes and native/fresh errors remain retained. The direct canonical guard uses its existing
host diagnostic; its public result boundary agrees without a claim of typed-error equivalence.

Four older current conditional/null tests replace only source-identical old loop failures. All old
cases/producers/captures are unchanged; the null claim is historical at85e63d655. The current reviewer
covers those successor tests. Numeric helper num_lt still rejects in this private evaluator and remains
startup87.3; boolean literal kind, function statement MVP, next normalization/backlog5, metadata order/
readiness, dispatcher/full16 and other-backend admission stay separate. Seven PUC CLI comparisons
cover selected values/null/eager/guard boundaries only. Observation corruptions are not runtime mutants.

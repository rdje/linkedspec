---
id: perl-array-transform-source-preflight
title: Literal Number Array-transform sources reach ambient numeric Array slots
answers:
  - "why does Perl take 3 read an unrelated host Array"
  - "why does Perl sorted on a Number produce host data"
  - "which task owns Array transform Number source isolation before result guards"
  - "where are Perl Array transform initial source and optional arity profiles frozen"
date: 2026-11-07
status: source78.0 and result78.1.1 bounded repairs focused-checked; independent peers/full admission separate
tags: [perl, array, transforms, numeric, isolation, source, guards]
evidence: "Preflight78.1.0 retains the original source defect. Source78.0 at docs/checkpoints/array-transform-source-perl-2026-11-07/REVIEW.md retains16RED to189PASS, exact old/current private-image inverse and two readonly0 recoveries/six corruptions. Own123 policies and173 healthy projections stay exact; all37 current result projections/artifact pairs retain their original19 failures/18 healthy."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-source-perl-2026-11-07/review_result_preservation.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-result-perl-2026-11-07/review_preflight.py"
---

Original preflight substitution/handler/native/full emitted-fresh evidence shows the eight
ordinary take/take_last/drop_front/drop_back/slice/sorted/reversed/concat_arrays
producers lower literal Number3 to a named Perl Array `@3`. Their legacy symbol
shortcuts accept a Number spelling before the computed-source fallback can
reject it. Localized `@main::3` data changes the result on both execution routes;
an identically populated outer generated package does not. Empty-host `[]`
observations alone conceal the defect. This is a read, not observed mutation.

Source78.0 applies the existing `_method_value_is_numeric_literal` predicate at
exactly eight shortcuts in `perl/LinkedSpec/ActionIR/MethodLowering.pm`. Genuine
Arrays retain their original shortcut; Number literals use the original computed
source path. Native/fresh Number3 empty/main/outer controls now pass independently
of host data. Own123 policies and173 before-healthy observations remain exact.
Old/current images at one controlled private load path reproduce16RED/189PASS;
all matching module/handler pairs survive. Original37 result outputs, errors and
artifact identities remained unchanged at source78.0. Subsequent composition78.1.1
owns the bounded result guards; see `docs/knowledge/perl-array-transform-result-guards.md`.

Do not
normalize initial sources to an Array-result guard, change global extractors or
infer peer behavior. Preserve genuine Arrays, source/optional/count/start/error/
variadic-concat and earlier-owner policies. Original37 result failures remain
separately owned, alongside own123 historical source/arity/error profiles.

Readonly recovery validates actual activation source archives and artifacts,
native/fresh observations, original errors and six specific counterfactuals.
The initial missing-observer failure is preserved separately from the first
qualified SDK intake. All captured own Perl/three grammar inputs match activation
Git before source repair; recovery reads retained historical inputs rather than
claiming latest runtime behavior. Full source/context/native-transitive custody, isolation,
registration and admission remain separately owned. This is a finite causal
finding, not a complete source-domain audit.

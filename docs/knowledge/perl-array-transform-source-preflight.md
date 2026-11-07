---
id: perl-array-transform-source-preflight
title: Literal Number Array-transform sources reach ambient numeric Array slots
answers:
  - "why does Perl take 3 read an unrelated host Array"
  - "why does Perl sorted on a Number produce host data"
  - "which task owns Array transform Number source isolation before result guards"
  - "where are Perl Array transform initial source and optional arity profiles frozen"
date: 2026-11-07
status: demonstrated source defect; immediate repair78.0 precedes result78.1.1
tags: [perl, array, transforms, numeric, isolation, source, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.78.1.0; docs/checkpoints/array-transform-result-perl-2026-11-07/PREFLIGHT.md retains original37, own123 profiles and48 localized-host controls. All16 free/receiver main-seeded routes read host data through @3; empty/outer controls do not. No production repair yet."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-result-perl-2026-11-07/review_preflight.py"
---

Public substitution/handler/native/full emitted-fresh evidence shows the eight
ordinary take/take_last/drop_front/drop_back/slice/sorted/reversed/concat_arrays
producers lower literal Number3 to a named Perl Array `@3`. Their legacy symbol
shortcuts accept a Number spelling before the computed-source fallback can
reject it. Localized `@main::3` data changes the result on both execution routes;
an identically populated outer generated package does not. Empty-host `[]`
observations alone conceal the defect. This is a read, not observed mutation.

Source78.0 owns the bounded Number-AST barriers before composition78.1.1. Do not
normalize initial sources to an Array-result guard, change global extractors or
infer peer behavior. Preserve genuine Arrays, source/optional/count/start/error/
variadic-concat and earlier-owner policies. Original37 result failures remain
separately owned, alongside own123 historical source/arity/error profiles.

Readonly recovery validates actual activation source archives and artifacts,
native/fresh observations, original errors and six specific counterfactuals.
The initial missing-observer failure is preserved separately from the first
qualified SDK intake. Full source/context/native-transitive custody, isolation,
registration and admission remain separately owned. This is a finite causal
finding, not a complete source-domain audit.

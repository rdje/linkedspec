---
id: typed-path-mutation-result-checker-root-kind
title: The mutation-result checker must require typed-root rather than hash-only assignment prose
answers:
  - "why did canonical CI reject the uniform binding mutation result surface on 2026-08-31"
  - "does name key assignment return only a hash snapshot"
  - "why does the mutation result checker require updated root snapshot"
  - "which task repaired stale hash snapshot checker anchors"
  - "can an integer selector update an array root on Perl"
date: 2026-08-31
status: current; corrected under FUTURE-PARITY-BACKLOG.19.2.2
tags: [perl, typed-path, mutation, checker, documentation, canonical-ci, root-kind]
evidence: "Canonical attempt one for FUTURE-PARITY-BACKLOG.19.2.2 passes through punctuation-light zero-argument behavior, then tools/check_uniform_binding_mutation_result_surface.py rejects two required hash-snapshot phrases. Git/source comparison proves FUTURE-PARITY-BACKLOG.19.2.1 intentionally generalized the book to updated root snapshots because string selectors choose harrays and nonnegative integers choose arrays, while the checker literals were not updated. The corrected checker requires the existing root-generic sentences, passes 53 public files / 12 anchors / 9 historical cards, and the final exact staged canonical candidate passes from the beginning."
last_verified: 2026-08-31
reverify:
  - "python3 tools/check_uniform_binding_mutation_result_surface.py"
  - "rg -n 'updated root snapshot|typed path selection' docs/linkedspec-book/src/appendix/helper-contract-catalog.md docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md tools/check_uniform_binding_mutation_result_surface.py"
---

# Typed-path mutation-result checker root kind

Perl typed-path assignment is no longer harray-only. An evaluated string selector updates an harray; a
nonnegative integer selector updates an array. Its expression result must therefore be described and guarded as
an independent updated root snapshot, not an updated hash snapshot.

Canonical CI exposed a checker/book disagreement rather than a runtime or book defect. The book already taught the
correct root-generic semantics after `FUTURE-PARITY-BACKLOG.19.2.1`, while the recurring mutation-result checker
still required two historical hash-only phrases. `FUTURE-PARITY-BACKLOG.19.2.2` owns updating those literal anchors
to the existing accurate sentences and rerunning the exact staged canonical candidate.

Related: [[terse-mutation-assignment-expression-values]], [[write-vivification-perl-reference]], ADR `0036`, and
`FUTURE-PARITY-BACKLOG.19.2.1-.2`.

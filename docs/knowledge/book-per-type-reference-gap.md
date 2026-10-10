---
id: book-per-type-reference-gap
title: Per-type method reference is substantial but not certified complete
answers:
  - "does the mdbook thoroughly document every supported type and method"
  - "does the book have a section for string integer real array hash and codeblock"
  - "which task owns the per-type language reference gap"
  - "is codeblock documentation directly navigable as a type section"
  - "which owner repairs contradictory legacy documentation task statuses"
date: 2026-10-10
status: current qualitative gap; owned scheduled follow-up
tags: [documentation, mdbook, types, methods, continuity]
evidence: "October10 DBIQNP book review: current SUMMARY and scalar/string, numeric, array/hash/pipeline headings plus Values codeblock prose and sampled table entries. No complete implementation-to-book inventory was performed. TYPE-REFERENCE-BOOK owns inventory and per-type repair; .8 owns the exact legacy status contradictions. Current AST callback work continues."
reverify: "Read docs/tasks/TYPE-REFERENCE-BOOK.md; inspect docs/linkedspec-book/src/SUMMARY.md, docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md headings, and docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md Returning payloads section. Complete source/contract reconciliation belongs to TYPE-REFERENCE-BOOK.1 before claiming exhaustive coverage."
---

The book already contains substantial scalar/string, numeric, array/hash and codeblock material. Its current
navigation follows general DSL/usage chapters; numeric integer/real distinctions are grouped, array/hash
construction, mutation, pipelines and traversal are distributed, and detailed codeblock prose is under Returning
payloads rather than a dedicated navigable type section. Several sampled operations have brief table entries and
shared examples. This supports an organization/depth gap, not a complete missing-method inventory or count.

TYPE-REFERENCE-BOOK schedules canonical per-type sections and complete individual operation entries after the
active private callback lane. Inventory actual contracts first, including constructors, operators, helpers,
receiver methods, aliases, invocation and backend limits. Preserve the actual type model: do not invent separate
integer/real types or codeblock dot-methods from headings alone. Each verified operation needs arguments,
results/mutation, edge cases, chaining/callback behavior and worked examples.

Three legacy documentation task files contain explicit completion-status contradictions. TYPE-REFERENCE-BOOK.8
owns the precise reproductions and relevant Git reconciliation before correction. These findings are scheduled
through verified repair; they do not redirect the active AST callback task. This card publishes no numerical
coverage claim and does not supersede dated historical book verification.

---
id: book-per-type-reference-gap
title: Per-type method reference is substantial but not certified complete
answers:
  - "does the mdbook thoroughly document every supported type and method"
  - "does the book have a section for string integer real array hash and codeblock"
  - "which task owns the per-type language reference gap"
  - "is codeblock documentation directly navigable as a type section"
  - "which owner repairs contradictory legacy documentation task statuses"
date: 2026-10-26
status: syntax/helper spellings indexed; signatures/receivers and comprehensive fluent gaps pending
tags: [documentation, mdbook, types, methods, continuity]
evidence: "Syntax1.1 and helper spelling1.2.1 indexes link actual source roles; signatures/result types and comprehensive fluent semantics remain open. No execution/parity/completeness claim."
reverify: "Read docs/checkpoints/type-operation-inventory/syntax.md and TYPE-REFERENCE-BOOK.1.2.1 children; follow each canonical contract before inferring a method or runtime type."
---

The book has substantial scalar/string, numeric, array/harray and codeblock material,
but the October10 review established navigation/depth gaps rather than a complete
missing-method count. Integer/real notation does not establish separate binding
namespaces or method tables; callback invocation and methods on a yielded value
are distinct roles.

`docs/checkpoints/type-operation-inventory/syntax.md` now indexes non-call value
forms, binding/path operators, eager/deferred blocks and callable structure, with
result/effect/copy/context boundaries and root-relative canonical authorities.
It preserves current signed-index, grouped-value, raw-regex and retirement limits.
`docs/checkpoints/type-operation-inventory/helpers.md` indexes primary resolver spellings, current numeric/control aliases, source-boundary compatibility and excluded dedicated/internal diagnostics. Signatures/effects and actual receiver/result transitions remain the next inventory children. A syntax entry does not establish backend execution,
parity, complete documentation coverage or a comprehensive fluent family.

TYPE-REFERENCE-BOOK.1.2.23 owns useful missing methods and inter-type transitions,
including string split -> array methods -> selected string -> string methods.
Every verified operation needs arguments, results/mutation, edge cases,
chaining/callback semantics and worked examples. Inventory today's names and
missing useful families separately before declaring a type complete.

The precise legacy task-status contradictions encountered in October10 intake
remain owned by TYPE-REFERENCE-BOOK.8; relevant Git/dates must be reconciled before
repair. Feature-first direction defers that maintenance and broad verification.

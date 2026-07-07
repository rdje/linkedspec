---
id: perl-actionir-ast-statement-operator-lowering
title: Perl assignment and mutation operator statements consume ActionIR AST nodes
answers:
  - "are Perl assignment statements lowered from AST"
  - "does name equals value lowering still regex parse statement source"
  - "does items plus equals value lowering consume AST"
  - "does hash index assignment lowering consume AST"
  - "which leaf moved statement operators to AST"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, statements]
evidence: "PERL-ACTIONIR-AST-MIGRATION.4.1 changed MethodLowering so assign_scalar, assign_array_append, and assign_hash_index AST nodes lower from typed target/key/value fields before the legacy statement-regex paths. Focused t/actionir_ast_parser.t coverage poisons original statement identifiers and AST source fields and proves name = [poison], items += poison, and meta[poison_key] = { poison_key : poison_value } lower from AST fields while preserving existing assignment/mutation semantics."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now consumes typed AST nodes for the three
operator-shaped statement mutations that the ActionIR parser already recognizes:

- `assign_scalar` for `name = value`;
- `assign_array_append` for `items += value`;
- `assign_hash_index` for `meta[key] = value`.

The AST path materializes trusted helper/action expression text from typed node fields and
then reuses the existing lowering policies. This preserves scalar assignment target-kind
inference, source-slot scalar reads, array append mutation value slots, and hash key/value
lowering while removing source-regex ownership for those operator statements.

Helper-call statements such as `set(...)`, `push(...)`, `set_key(...)`, `return(...)`,
and `return_undef()` moved to AST lowering in `PERL-ACTIONIR-AST-MIGRATION.4.2`; see
`docs/knowledge/perl-actionir-ast-statement-call-lowering.md`.

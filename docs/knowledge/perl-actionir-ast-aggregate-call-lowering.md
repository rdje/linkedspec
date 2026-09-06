---
id: perl-actionir-ast-aggregate-call-lowering
title: Perl MethodLowering consumes AST call nodes for aggregate wrappers and collection/hash helpers
answers:
  - "are aggregate helper calls lowered from AST in Perl"
  - "does Perl AST call lowering cover array_copy hash_copy copy"
  - "does Perl AST call lowering preserve array quoted wrapper boundaries"
  - "does Perl AST call lowering cover collection helpers"
  - "does Perl AST call lowering cover hash helpers"
  - "which helper calls still need Perl AST migration"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, aggregate-helpers, wrappers]
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.2.2 added a slot-aware aggregate-call dispatcher inside MethodLowering. Deprecated scalar/array/hash wrappers, copy helpers, flat helpers, array collection helpers, aggregate numeric reducers, capture map/group helpers, and hash helpers now reconstruct supported helper-call surfaces from typed AST fields before entering the existing Perl helper catalog through the compatibility bridge. Focused fake-source tests in t/actionir_ast_parser.t prove covered aggregate helper calls do not reuse call-node source text. The dispatcher preserves aggregate symbol slots and quoted-wrapper literal boundaries, so array(items) reads @items while array(\"items\") remains a literal payload. PERL-ACTIONIR-AST-MIGRATION.3.2.3 later added unresolved-helper diagnostics for unsupported covered helper forms; .3.3 later added AST fluent_chain lowering for receiver-dot value chains."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now consumes supported aggregate/helper
families from `LinkedSpec::ActionIR::AST` `call` nodes. The dispatcher rebuilds the
helper-call surface from typed AST fields, then deliberately reuses the existing Perl
helper catalog through the compatibility bridge so public output stays byte-compatible.

The original `.3.2.2` migration covered the families below. Retired names in this historical inventory
are not current authoring syntax; [[terse-helper-retirement-no-drift-closeout]] owns their later removal.
[[perl-uniform-binding-runtime]] owns the subsequent single typed binding model.

The milestone inventory was:

- deprecated wrapper aliases: `scalar`/`s`, `array`/`a`, `hash`/`h`;
- copy and flatten helpers: `array_copy`, `hash_copy`, `copy`, `flat`, `flat_array`,
  `flat_hash`;
- array collection helpers and value pipelines: `count`, `first`, `last`, `take`,
  `take_last`, `drop_front`, `drop_back`, `slice`, `concat_arrays`, `split`,
  `split_tagged_records`, `sorted`, `reversed`, `contains`, `index_of`, `join_values`,
  `split_each`, `trim_each`, `filter_nonempty`, `filter_match`, `uniq`,
  `lowercase_each`, `uppercase_each`;
- aggregate numeric reducers: `num_sum`, `num_avg`, `num_median`, `num_range`, and
  aggregate forms of `num_min`/`num_max` plus their word aliases;
- hash helpers and terminals: `merge_hash`, value-form `set_key`, `rename_key`,
  `drop_keys`, `pick_keys`, `has_key`, `count_keys`, `sorted_keys`, `sorted_values`,
  entry/match map helpers.

The migration preserved the then-existing aggregate symbol slots and quoted constructor boundaries.
Current scalar-held aggregate values follow uniform binding; the old `@items`/`%meta` explanation is not
an unconditional current storage rule. `array("items")` remains a literal constructor payload.
Wrong-kind host-slot reads found during startup are separately owned in `SESSION-STARTUP-READING.17`.

Follow-up status: `PERL-ACTIONIR-AST-MIGRATION.3.2.3` now diagnoses supported helper
shapes that cannot lower cleanly through the unresolved-helper metadata channel.
Receiver-dot `fluent_chain` traversal is now covered by
`PERL-ACTIONIR-AST-MIGRATION.3.3`; see
`docs/knowledge/perl-actionir-ast-fluent-chain-lowering.md`. Return-payload AST
traversal subsequently landed at `.3.4`, and statement operators, helper calls, and block bodies at
`.4.1`–`.4.3`; [[perl-actionir-ast-value-lowering-dispatcher]] links their completed owners.

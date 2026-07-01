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
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.2.2 added a slot-aware aggregate-call dispatcher inside MethodLowering. Deprecated scalar/array/hash wrappers, copy helpers, flat helpers, array collection helpers, aggregate numeric reducers, capture map/group helpers, and hash helpers now reconstruct supported helper-call surfaces from typed AST fields before entering the existing Perl helper catalog through the compatibility bridge. Focused fake-source tests in t/actionir_ast_parser.t prove covered aggregate helper calls do not reuse call-node source text. The dispatcher preserves aggregate symbol slots and quoted-wrapper literal boundaries, so array(items) reads @items while array(\"items\") remains a literal payload. Receiver-dot fluent_chain lowering and covered-call diagnostics remain later leaves."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now consumes supported aggregate/helper
families from `LinkedSpec::ActionIR::AST` `call` nodes. The dispatcher rebuilds the
helper-call surface from typed AST fields, then deliberately reuses the existing Perl
helper catalog through the compatibility bridge so public output stays byte-compatible.

Covered families include:

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

The key compatibility boundary is slot policy. Aggregate source slots stay symbol-shaped
when the helper contract expects a working array/hash name, so `array(items)` continues
to read `@items` and `hash(meta)` continues to read `%meta`. Quoted wrapper payloads stay
literal constructor payloads, so `array("items")` does not alias `@items`.

Still pending after this card: diagnostics for supported call shapes that cannot lower
cleanly (`PERL-ACTIONIR-AST-MIGRATION.3.2.3`), receiver-dot `fluent_chain` traversal
(`.3.3`), return-payload AST traversal (`.3.4`), and statement/control lowering.

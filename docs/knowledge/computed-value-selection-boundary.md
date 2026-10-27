---
id: computed-value-selection-boundary
title: Computed Array and Hash bracket reads need general typed postfix composition
answers:
  - can a split result be indexed directly
  - can a literal array be indexed before a fluent method
  - why does Perl split call indexing fail handler compilation
  - which task owns computed value bracket selection
  - does computed selection change grouped expression or write syntax
  - is value_access already represented by the native backends
date: 2026-10-27
status: frozen additive target; implementations24.1-.5 and full admission separate
tags: [actionir, selection, fluent, arrays, hash, perl, composition]
evidence: "TYPE23.1.4 public Get/fresh probe and exact computed-selection-intake.json; normative computed-selection.md/shared fixture."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_computed_selection.pl"
---

At d98e139d7, named signed/typed selected continuations work on public Perl
Get/fresh, while pure-call/fluent/Array-literal/Hash-literal/block postfix reads
fail handler compilation. Exact source/errors are retained in the linked intake.
Perl AST only parses binding-based access and fluent call segments; its lowerer
has a special raw callable-result bridge through CodeblockRuntime::read_path,
not general typed computed access. Other runtimes already carry value_access
(receiver plus segments), with distinct admitted parser source shapes.

TYPE23.3.24 owns the additive ordinary read feature, Perl first and independent
backend checks after it. Reuse existing entry kinds, signed valid reads, once-only
receiver then ordered selectors and actual-result consumers. Full target and
exclusions are docs/checkpoints/type-operation-inventory/computed-selection.md.
Named read lookup order, grouping87.4, computed writes, dynamic Hash-key/coercion,
copy-domain/depth, callable/deferred/context and portable admission remain separate.
No backend support is inferred from merely carrying the AST node. Planned book
syntax must not become a runnable promise until its implementation is checked.

Related: [[rust-single-index-read-bypasses-typed-binding]],
[[terse-array-receiver-value-chains]], [[write-vivification-neutral-contract]].

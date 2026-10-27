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
  - why does actionir_ast_parser expect an obsolete substr sentinel
  - how do computed receiver and selector writes stay function local
  - why are direct computed call results separate from fluent literal selections
  - can value_access recognition change legacy callable raw status
date: 2026-10-27
status: Perl24.1.1 noncall sources checked; direct calls24.1.2 and full admission open
tags: [actionir, selection, fluent, arrays, hash, perl, composition]
evidence: "TYPE23.1.4 public Get/fresh probe and exact computed-selection-intake.json; normative computed-selection.md/shared fixture."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/computed_selection_noncall_contract.t t/computed_selection_callable_compat.t t/actionir_ast_parser.t"
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

Perl24.1.1 now emits typed fluent/literal/block reads through the shared guarded
ValueExpr reader, preserving named output and source/selector scopes. Bounded
native/fresh PASS36, frozen callable compatibility PASS5 top-level, parser PASS24,
direct selected/indexed PASS36, syntax and a ready zero-fallback descriptor pass.
Direct calls remain excluded: the wider candidate reroutes existing callable
negative-float/string reads, changing counts0 to2/null and raw1 to0. The original
producer/RED/restored packet is computed-callable-compat-intake.json. Restoring the
legacy path preserves four exact values1/2/0/0 and raw1.24.1.2 owns direct pure/
helper/function reads without reader/count/provenance/metadata promotion. Parent
24.1/full fixture and other backends remain open; AST names alone prove no support.

Three parser source-layout/sentinel assertions were stale after String19.1
(ea6f82c2a). Exact base producers reproduce them; the retained baseline probe/JSON
shows healthy discard and malformed substr-null behavior. Assertions now execute
semantic values. An initial -I-only overlay was invalidated by actual module paths,
then corrected explicitly. This repair is closed with24.1.1; full admission stays open.

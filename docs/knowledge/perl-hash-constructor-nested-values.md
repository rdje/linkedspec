---
id: perl-hash-constructor-nested-values
title: Perl hash constructors must lower complete value ASTs before emitting host source
answers:
  - "why did a hash constructor return the word start instead of a span offset"
  - "can nested hash constructor arrays mix bare bindings and helpers"
  - "why did a nested object in hash trigger hash_literal_use_colon"
  - "which test covers native and emitted nested grammar span values"
  - "why does flat meta fail while flat_hash meta works"
date: 2026-09-27
status: constructor repair verified; generic flat typed-binding repair scheduled separately
tags: [perl, actionir, constructor, hash, shape, source-span, readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1 owns the constructor correction. Public Get and call_spec_handler_subst reproduce bare start in generated host source; direct shapes preserve its value. Final native/fresh emitted regression has 96 assertions across a typed constructor matrix and six accepted/seven rejected nesting cases, with repeated execution. Six focused suites pass 120 top-level tests; complete Phase0 passes 1033/1033 in 1043 seconds. Exact evidence is in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1-verification.json. Generic flat(meta) returns null while flat_hash(meta) returns exact fields; .1.1.6 is the director-selected immediate next repair."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t t/actionir_ast_parser.t; env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/phase0_regression.t"
---

The first ordinary `.spec` nesting trial used `start = entry_start_pos()` in a
recursive rule and `return(hash("span", [start, cursor_pos()]))` at its closing
edge. Before repair, Perl emitted `[start, do { ...cursor_position... }]`: `start`
was a host bareword and became a string. Direct `return([start, cursor_pos()])`
and `return({"span":[start, cursor_pos()]})` correctly emitted `$start`.

In `perl/LinkedSpec/ActionIR/MethodLowering.pm`, `lower_ast_aggregate_call_node`
reconstructed the constructor through `ast_expr_source_node`. That reconstruction
kept ordinary variables in DSL spelling but lowered nested calls to host Perl.
The legacy hash bridge could not reparse this mixed array, then fell back to raw
source. Nested harray literals also leaked colon syntax into host source. Simply
lowering the shape before passing it through that bridge is insufficient: a
lowered Perl harray's `=>` is then mistaken for removed authored DSL syntax.

The correction constructs hash pairs from typed AST value nodes directly. It
retains existing key normalization and the flat-list compatibility path, and
leaves single bare-identifier selector handling to its existing boundary.
`t/actionir_ast_parser.t` supplies deliberately false node source text to ensure
normal constructor values use typed fields. `t/generated_source_contract.t`
executes bound values, nested shapes/helpers, fresh function locals, null, false,
container values, empty hashes and explicit `flat_hash` composition through
native and independently loaded fresh emitted parsers. Exact JSON compares
result kinds as well as contents; reuse checks run both input sequences twice.

`tests/language-readiness/nested-tree/grammar.spec` is a small readiness grammar,
not S-expression standard support. Its independent cases retain the original
Unicode scalar span expectations. Remaining backend/mutation assessment belongs
to `.1.1.3.1.2`; neither a green Perl trial nor this repair activates the campaign.

## Separate generic flattening defect

For `meta = {"existing":1}; value = 7`, public Get returns null from
`hash(flat(meta), "added", value)`, and public lowering reports unsupported
`hash`. Changing only `flat` to `flat_hash` returns `{"existing":1,"added":7}`.
The generic flat branch in `lower_flat_list_value_expr` lacks the scalar-held
harray handling present in `flat_hash`. `.1.1.6` owns source-located baseline and
repair proof immediately after the constructor commit, coordinated with startup `.17`'s broader
typed aggregate obligation. This is a scheduled defect, not a claim that the
explicit-helper control fixes generic flattening.

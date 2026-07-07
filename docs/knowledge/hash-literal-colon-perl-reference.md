---
id: hash-literal-colon-perl-reference
title: "SPEC-FORMAT-TERSE.9.2 added Perl reference colon hash-literal syntax during the migration window."
answers:
  - "does Perl accept colon hash literal syntax"
  - "where is Perl colon hash literal implemented"
  - "does generated Perl still use fat arrow after colon source"
  - "does colon hash literal affect expression-valued blocks"
  - "does colon hash literal support preserve old => during migration"
  - "does colon hash literal support preserve blind call =>"
date: 2026-07-07
status: current
tags: [spec-format-terse, hash-literal, colon-association, perl, actionir, migration, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.9.2 updated perl/LinkedSpec/ActionIR/AST/Parser.pm so brace hash-literal detection and pair splitting use a top-level hash-pair scanner that accepts `:` and `=>` during the migration window while skipping `::`. Perl direct source forms such as `return({ key : value })`, nested `{ \"fixed\" : [value], key : { \"nested\" : value } }`, `name = { key : value }`, `meta[key] = { \"inner\" : value }`, `return(set(meta, { key : value }))`, and `return([value, { key : value }])` lower and run. Old `{ old => value, key : value }` still parses during the window, generated Perl host code still emits hashrefs with Perl `=>`, and non-pair brace values such as `{ JSON::PP }` and `{ set(x,\"a\"); x }` remain expression-valued blocks. Locks: t/actionir_ast_parser.t focused parser coverage and t/phase0_regression.t subtest spec_format_terse_9_2_perl_colon_hash_literal_support; full phase0 passes with plan 1..1023."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return({ key : value })}, q{return({ \"fixed\" : [value], key : { \"nested\" : value } })}, q{name = { key : value }}, q{meta[key] = { \"inner\" : value }}, q{return({ set(x,\"a\"); x })}) { print \"$stmt => \", LinkedSpec::call_spec_handler_subst(\"Top\", $stmt), \"\\n\" }' && prove -q -Iperl t/actionir_ast_parser.t"
---

# Perl Colon Hash Literals

`SPEC-FORMAT-TERSE.9.2` added Perl-reference support for direct hash-literal colon
association syntax:

```text
return({ key : value })
return({ "fixed" : [value], key : { "nested" : value } })
name = { key : value }
meta[key] = { "inner" : value }
```

During the migration window the Perl reference accepts both `:` and the old `=>`
separator in direct hash literals. The old source spelling is still scheduled for
hard retirement under `.9.5`; blind-call edge `=> Rule` syntax is not part of this
hash-literal migration.

The generated Perl host source still uses Perl hashref syntax with `=>`, for example
`return({ key : value })` lowers to `return {$key => $value}`. That is implementation
output, not current `.spec` source syntax.

The parser scanner ignores double-colon while deciding whether braces are a hash
literal, so non-pair brace values such as `{ JSON::PP }` remain expression-valued
blocks instead of being misclassified as hash literals.

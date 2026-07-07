---
id: hash-literal-colon-perl-reference
title: "Perl reference uses colon hash-literal syntax; old hash-literal => is retired."
answers:
  - "does Perl accept colon hash literal syntax"
  - "where is Perl colon hash literal implemented"
  - "does generated Perl still use fat arrow after colon source"
  - "does colon hash literal affect expression-valued blocks"
  - "does Perl still accept old hash literal =>"
  - "what diagnostic replaces old hash literal => on Perl"
  - "does colon hash literal support preserve blind call =>"
date: 2026-07-07
status: current
tags: [spec-format-terse, hash-literal, colon-association, perl, actionir, retired-syntax, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.9.2 added Perl-reference support for direct `{ key : value }` hash literals, and SPEC-FORMAT-TERSE.9.5 hard-retired old direct hash-literal `=>` source. `perl/LinkedSpec/ActionIR/AST/Parser.pm` still detects top-level `=>` inside brace payloads only to produce a `hash_literal_fat_arrow_removed` AST node with reason `hash_literal_use_colon`; it no longer produces `hash_literal` entries for that separator. `perl/LinkedSpec/ActionIR/MethodLowering.pm` lowers that retired node to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon` and serializes AST source hashes with `:` so current colon literals do not loop through the retired path. Generated Perl host code still emits Perl hashrefs with `=>`, and non-pair brace values such as `{ JSON::PP }` and `{ set(x,\"a\"); x }` remain expression-valued blocks. Locks: t/actionir_ast_parser.t and phase0 subtests `spec_format_terse_9_2_perl_colon_hash_literal_support` plus `spec_format_terse_9_5_perl_hash_literal_fat_arrow_retired`."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return({ key : value })}, q{return({ old => value })}, q{return({ set(x,\"a\"); x })}) { print \"$stmt => \", LinkedSpec::call_spec_handler_subst(\"Top\", $stmt), \"\\n\" }' && prove -q -Iperl t/actionir_ast_parser.t"
---

# Perl Colon Hash Literals

The Perl reference accepts direct hash-literal colon association syntax:

```text
return({ key : value })
return({ "fixed" : [value], key : { "nested" : value } })
name = { key : value }
meta[key] = { "inner" : value }
```

Old direct hash-literal `=>` source is retired. `{ old => value }` and mixed
`{ old => value, key : value }` forms lower to the explicit
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon` diagnostic instead
of parsing as hash literals or falling through as host Perl. Blind-call edge
`=> Rule` syntax is not part of this hash-literal retirement.

The generated Perl host source still uses Perl hashref syntax with `=>`, for example
`return({ key : value })` lowers to `return {$key => $value}`. That is implementation
output, not current `.spec` source syntax.

The parser scanner ignores double-colon while deciding whether braces are a hash
literal, so non-pair brace values such as `{ JSON::PP }` remain expression-valued
blocks instead of being misclassified as hash literals.

---
id: hash-literal-fat-arrow-retired
title: "SPEC-FORMAT-TERSE.9.5 retired old direct hash-literal => source."
answers:
  - "is old hash literal => still accepted"
  - "what replaced old hash literal =>"
  - "what diagnostic appears for { key => value }"
  - "does hash literal => fall back to a block"
  - "does blind call => remain valid after hash literal retirement"
  - "why must lowered Perl hashrefs not be reparsed during hash literal retirement"
date: 2026-07-07
status: current
tags: [spec-format-terse, hash-literal, fat-arrow, retired-syntax, perl, rust, actionir, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.9.5 hard-retired old direct hash-literal `=>` source on both Perl and Rust. Perl `ActionIR/AST/Parser.pm` returns `hash_literal_fat_arrow_removed` with reason `hash_literal_use_colon`, and `MethodLowering.pm` lowers it to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon`; it also serializes AST source hashes with `:` so current colon literals are not re-routed through the retired syntax. Rust `linkedspec-core/src/expr.rs::hash_pair_separator_at` accepts only `:`, and `parse_hash_literal` detects `=>` only to emit the same diagnostic. Brace classifiers still detect top-level `=>` so old source diagnoses instead of falling through as an expression-valued block. Blind-call edge `=> Rule`, source-language payloads, historical records, and generated Perl host hashrefs remain separate owners. Full phase0 exposed the key implementation boundary: once a colon hash literal has lowered to a Perl host hashref such as `{$key => $value}`, later AST paths must not feed that host snippet back into the source parser. Multi-argument `array(...)` now emits `[...]` directly from already-lowered args and lowers nested calls like `hash(meta)` before direct emission."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{return({ old => value })}), \"\\n\"; print LinkedSpec::call_spec_handler_subst(\"Top\", q{return(array({ key : value }, hash(meta))) }), \"\\n\"' && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core hash_literal_fat_arrow && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_9_"
---

# Hash-Literal Fat Arrow Retirement

Current direct hash literals use colon association:

```text
return({ key : value })
return({ "fixed" : value })
```

Old direct hash-literal fat-arrow source is retired:

```text
return({ key => value })
```

Perl and Rust both route that old source to
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon`. It does not parse
as a current hash literal and does not fall back to an expression-valued block or
host-language hash syntax.

This retirement is scoped to ActionIR value syntax. Blind-call edge `=> Rule`
syntax, source-language associations such as VHDL payloads, generated Perl host
hashrefs, and historical records remain separately owned.

One implementation trap is now locked: generated Perl host hashrefs contain Perl
`=>` after successful colon lowering, so already-lowered host snippets must not
be reparsed as source DSL. The AST multi-argument `array(...)` constructor emits
its `[...]` result from lowered argument expressions directly.

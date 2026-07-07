---
id: hash-literal-colon-rust-parity
title: "SPEC-FORMAT-TERSE.9.3 added Rust colon hash-literal syntax during the migration window."
answers:
  - "does Rust accept colon hash literal syntax"
  - "where is Rust colon hash literal implemented"
  - "does Rust colon hash literal affect expression-valued blocks"
  - "does Rust colon hash literal support preserve old => during migration"
  - "does colon hash literal support preserve blind call => on Rust"
  - "does Rust colon hash literal support receiver chains"
date: 2026-07-07
status: current
tags: [spec-format-terse, hash-literal, colon-association, rust, actionir, migration, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.9.3 updated rust/linkedspec-core/src/expr.rs so direct hash-literal parsing accepts `:` and old `=>` pair separators during the migration window. Brace classification uses a top-level hash-pair scanner that skips `::`, nested braces, brackets, parentheses, strings, and regex literals. Runtime `Expr::HashLiteral` evaluation in rust/linkedspec-runtime/src/engine.rs was already separator-agnostic once the AST exists. Focused parser tests lock colon-only nested hashes, mixed old/new separators, assignment and mutation RHS slots, expression-valued assignment slots, and scanner edge cases. Runtime test terse_9_3_colon_hash_literals_parse_and_run locks direct assignment, hash-index mutation RHS, value-form `set(...)` / `=(...)`, array composition, direct hash receiver chaining, and expression-valued block precedence."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_colon_hash_shape_literal_value_expr && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_mixed_hash_pair_separators_during_migration_window && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_colon_shape_literals_in_assignment_and_mutation_slots && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core top_level_hash_pair_separator_scanner_skips_nested_and_namespace_colons && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_9_3_colon_hash_literals_parse_and_run"
---

# Rust Colon Hash Literals

`SPEC-FORMAT-TERSE.9.3` added Rust parser/runtime parity for direct hash-literal
colon association syntax:

```text
return({ key : value })
name = { key : value }
meta[key] = { "inner" : value }
{ key : value }.count_keys()
```

During the migration window Rust accepts both `:` and the old `=>` separator in
direct hash literals. The old source spelling is scheduled for hard retirement
under `.9.5`; blind-call edge `=> Rule` syntax remains separate rule-body syntax.

The implementation boundary is Rust parser-side: `rust/linkedspec-core/src/expr.rs`
creates the same `Expr::HashLiteral` AST for either separator. Runtime evaluation
already consumes `Expr::HashLiteral` entries without knowing which separator was
used in source.

The brace scanner deliberately skips double-colon and nested separators, so `::`
does not make a brace payload a hash literal, and non-pair braces still route to
expression-valued block parsing.

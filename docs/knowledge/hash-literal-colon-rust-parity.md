---
id: hash-literal-colon-rust-parity
title: "Rust uses colon hash-literal syntax; old hash-literal => is retired."
answers:
  - "does Rust accept colon hash literal syntax"
  - "where is Rust colon hash literal implemented"
  - "does Rust colon hash literal affect expression-valued blocks"
  - "does Rust still accept old hash literal =>"
  - "what diagnostic replaces old hash literal => on Rust"
  - "does colon hash literal support preserve blind call => on Rust"
  - "does Rust colon hash literal support receiver chains"
date: 2026-07-07
status: current
tags: [spec-format-terse, hash-literal, colon-association, rust, actionir, retired-syntax, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.9.3 added Rust parser/runtime parity for direct `{ key : value }` hash literals, and SPEC-FORMAT-TERSE.9.5 hard-retired old direct hash-literal `=>` source. `rust/linkedspec-core/src/expr.rs::hash_pair_separator_at` now accepts only `:`, while `parse_hash_literal` detects `=>` only to return `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon` with a `use ':'` diagnostic. Brace classification still detects top-level `=>` so old source routes to that diagnostic rather than falling through as an expression-valued block. Runtime `Expr::HashLiteral` evaluation remains separator-agnostic once a valid AST exists. Locks: parser tests for colon hashes, retired fat-arrow diagnostics, assignment/mutation slots, scanner edge cases, runtime test `terse_9_3_colon_hash_literals_parse_and_run`, and compile-failure test `terse_9_5_hash_literal_fat_arrow_is_retired`."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_colon_hash_shape_literal_value_expr && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_retired_hash_literal_fat_arrow_reports_colon_migration && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_colon_shape_literals_in_assignment_and_mutation_slots && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core top_level_hash_pair_separator_scanner_skips_nested_and_namespace_colons && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_9_3_colon_hash_literals_parse_and_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_9_5_hash_literal_fat_arrow_is_retired"
---

# Rust Colon Hash Literals

Rust supports direct hash-literal colon association syntax:

```text
return({ key : value })
name = { key : value }
meta[key] = { "inner" : value }
{ key : value }.count_keys()
```

Old direct hash-literal `=>` source is retired. `{ old => value }` and mixed
`{ old => value, key : value }` forms fail ActionIR parsing/compile with
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon` and a `use ':'`
diagnostic. Blind-call edge `=> Rule` syntax remains separate rule-body syntax.

The implementation boundary is Rust parser-side: `rust/linkedspec-core/src/expr.rs`
creates `Expr::HashLiteral` only for colon-separated source. Runtime evaluation
consumes `Expr::HashLiteral` entries without knowing which valid separator was
used in source.

The brace scanner deliberately skips double-colon and nested separators, so `::`
does not make a brace payload a hash literal, and non-pair braces still route to
expression-valued block parsing.

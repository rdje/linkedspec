---
id: terse-rust-expression-valued-block-seams
title: "SPEC-FORMAT-TERSE.2.1.3 - Rust supports core expression-valued block parity."
answers:
  - "do Rust expression-valued blocks work"
  - "does Rust Expr have a block-value variant"
  - "where are Rust expression-valued blocks implemented"
  - "how does Rust parse braces in value expressions now"
  - "does Rust preserve hash literals when adding block values"
  - "what did SPEC-FORMAT-TERSE.2.1.3 land"
date: 2026-06-29
status: confirmed
tags: [dsl, blocks, expressions, rust, parser, runtime, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.2.1.3 on 2026-06-29 landed Rust parser/runtime parity for the Perl core expression-valued block subset. rust/linkedspec-core/src/expr.rs now has Expr::BlockValue, parse_brace_expr(), and top-level hash-pair detection so '{}' and keyed '{ key : value }' stay hash literals while non-empty braces without a top-level hash-pair delimiter parse as block values. rust/linkedspec-runtime/src/engine.rs now evaluates Expr::BlockValue through eval_block_value(): side-effect statements execute in order, the final expression is the value, and a final return(expr) is block-local. At .2.1.3, non-final return(expr) was rejected/deferred to SPEC-FORMAT-TERSE.2.1.4; .2.1.4 later closed that early-return boundary (see [[terse-expression-valued-block-early-return]]). Locks: focused core parser tests for expression-valued blocks, focused runtime terse_2_1_3 tests, a new Perl-oracle fixture terse_2_1_3_expression_valued_blocks, and Rust corpus oracle over 34 fixtures."
reverify: "cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core expression_valued_block && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_1_3 && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Rust Expression-Valued Block Seams

`SPEC-FORMAT-TERSE.2.1.3` lands Rust parity for the Perl-reference core expression-valued block contract.

The current Rust model has two separate pieces:

- `CodeBlock` parses lifecycle statement lists.
- `Expr` parses value expressions such as variables, calls, arrays, and hashes.

`Expr::BlockValue` is the value-returning block expression. The parser keeps hash literals first: `{}` and
top-level hash-pair `{ key : value }` forms remain `Expr::HashLiteral`, while non-empty brace payloads without a
top-level hash-pair delimiter become block values.

The runtime has the matching gap:

- `execute_block()` still executes lifecycle statement blocks and returns `()`.
- `eval_expr()` now dispatches `Expr::BlockValue` to `eval_block_value()`.

The landed `.2.1.3` contract:

- preserve `{}` and keyed top-level hash-pair literals;
- parse non-empty brace payloads without a top-level hash-pair delimiter as `Expr::BlockValue`;
- evaluate side-effect statements in order;
- return the final expression value;
- treat a final `return(expr)` as the block-local payload for this core subset;
- reject/defer non-final `return(expr)` to `.2.1.4`.

`.2.1.4` later closed the non-final `return(expr)` boundary; see
[[terse-expression-valued-block-early-return]] for the current early-return contract.

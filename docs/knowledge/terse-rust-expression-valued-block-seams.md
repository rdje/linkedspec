---
id: terse-rust-expression-valued-block-seams
title: "SPEC-FORMAT-TERSE.2.1.3 - Rust expression-valued block parity seams are parser Expr plus runtime eval_expr."
answers:
  - "where should Rust expression-valued blocks be implemented"
  - "does Rust Expr have a block-value variant"
  - "how does Rust currently parse braces in value expressions"
  - "why does Rust reject { set(x,\"a\"); x } today"
  - "what runtime seam evaluates Rust block values"
  - "what does SPEC-FORMAT-TERSE.2.1.3 own"
date: 2026-06-29
status: confirmed
tags: [dsl, blocks, expressions, rust, parser, runtime, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.2.1.3 ownership on 2026-06-29 used the .2.1.1/.2.1.2 KM cards and Rust code-read. rust/linkedspec-core/src/expr.rs defines statement-only CodeBlock plus Expr variants for calls, variables, arrays, and hashes, but no block-value Expr. Parser::parse_expr routes '{' directly to parse_hash_literal(); parse_hash_literal preserves '{}' and keyed '=>' entries, but rejects non-empty non-fat-arrow braces such as { set(x,\"a\"); x } because it expects '=>'. rust/linkedspec-runtime/src/engine.rs execute_block runs statement blocks and returns (), while eval_expr has ArrayLiteral and HashLiteral arms but no block-value arm. Therefore .2.1.3 owns adding Rust parser/runtime parity for the Perl core: non-empty braces without top-level '=>' become expression-valued blocks, hash literals keep precedence, final expressions and final return(expr) yield the block value, and true mid-block early return remains .2.1.4."
reverify: "rg -n 'pub enum Expr|CodeBlock|parse_expr|parse_hash_literal|execute_block|fn eval_expr|ArrayLiteral|HashLiteral' rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs"
---

# Rust Expression-Valued Block Seams

`SPEC-FORMAT-TERSE.2.1.3` is the Rust parity owner for the Perl-reference core expression-valued block contract.

The current Rust model has two separate pieces:

- `CodeBlock` parses lifecycle statement lists.
- `Expr` parses value expressions such as variables, calls, arrays, and hashes.

There is no `Expr` variant for a value-returning block. In `parse_expr()`, `{` currently goes straight to
`parse_hash_literal()`, so `{}` and `{ key => value }` are hash literals, while a non-empty brace payload
without `=>` is rejected instead of becoming a block expression.

The runtime has the matching gap:

- `execute_block()` executes lifecycle statement blocks and returns `()`.
- `eval_expr()` evaluates arrays and hashes as values, but has no block-value arm.

The implementation boundary for `.2.1.3` is therefore:

- preserve `{}` and keyed top-level `=>` hash literals;
- add a Rust expression form for non-empty brace payloads without top-level `=>`;
- evaluate side-effect statements in order;
- return the final expression value;
- treat a final `return(expr)` as the block-local payload for this core subset;
- leave true mid-block early return to `.2.1.4`.

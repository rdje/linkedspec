---
id: terse-rust-shape-literal-value-parity
title: "SPEC-FORMAT-TERSE.1.2.3.5.3 - Rust direct shape literals are value expressions."
answers:
  - "does Rust parse [] and {} shape literal value expressions"
  - "does Rust [value] read scalar value inside a shape literal"
  - "does Rust { key : value } read scalar key and value"
  - "where is current Rust duck typed assignment behavior recorded"
  - "what remains after SPEC-FORMAT-TERSE.1.2.3.5.3"
date: 2026-06-29
status: confirmed
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, rust, oracle]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5.3 landed on 2026-06-29. Rust `linkedspec-core::expr::Expr` now has `ArrayLiteral` and `HashLiteral` variants, and `parse_expr` accepts leading `[` / `{` as direct shape-literal value primaries. Array elements, hash keys, and hash values recurse through `parse_expr`; runtime `Engine::eval_expr` evaluates each member through normal expression evaluation and constructs `RuntimeValue::Array` / `RuntimeValue::Hash`, converting hash keys with `RuntimeValue::to_str()` like the existing `hash(...)` helper. Parser locks cover return payloads, mutation RHS slots, and roundtrip display/parse. Runtime locks prove typed nested return payloads and mutation RHS shape payloads. The Perl-oracle corpus added `terse_1_2_3_5_3_shape_literal_return_values` and `terse_1_2_3_5_3_shape_literal_mutation_rhs`, bringing the green corpus to 30 fixtures at that leaf. SPEC-FORMAT-TERSE.1.2.3.5.4 later landed historical Rust RHS target-kind parity; SPEC-FORMAT-TERSE.11.3 superseded it with duck-typed assignment value binding. See [[terse-rust-duck-typed-assignment-parity]]."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core shape_literal && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_2_3_5_3 && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Rust Shape-Literal Value Parity

Rust now accepts direct shape literals as value expressions:

```text
[]
[value, cat("a", "b"), true, []]
{ key : value, "fixed" : [value] }
```

The member semantics match the accepted Perl value contract from
[[terse-shape-literal-value-expressions]]: bare elements, keys, and values are scalar working-variable reads;
quoted hash keys are fixed fields; helpers, primitive literals, direct access, and nested shape literals compose
through the normal expression path.

This leaf intentionally stopped before RHS target-kind inference. At the historical `.1.2.3.5.3` boundary:

```text
name = [value]
```

stored the array payload in scalar `name`; it did not replace array working variable `name`.

Rust target-kind parity later landed in [[terse-rust-rhs-shape-target-kind-parity]], then
`SPEC-FORMAT-TERSE.11.3` superseded that storage behavior with [[terse-rust-duck-typed-assignment-parity]].

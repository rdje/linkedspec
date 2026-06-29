---
id: terse-rust-shape-literal-value-parity
title: "SPEC-FORMAT-TERSE.1.2.3.5.3 - Rust direct shape literals are value expressions."
answers:
  - "does Rust parse [] and {} shape literal value expressions"
  - "does Rust [value] read scalar value inside a shape literal"
  - "does Rust { key => value } read scalar key and value"
  - "does Rust name = [value] infer an array working variable yet"
  - "what remains after SPEC-FORMAT-TERSE.1.2.3.5.3"
date: 2026-06-29
status: confirmed
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, rust, oracle]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5.3 landed on 2026-06-29. Rust `linkedspec-core::expr::Expr` now has `ArrayLiteral` and `HashLiteral` variants, and `parse_expr` accepts leading `[` / `{` as direct shape-literal value primaries. Array elements, hash keys, and hash values recurse through `parse_expr`; runtime `Engine::eval_expr` evaluates each member through normal expression evaluation and constructs `RuntimeValue::Array` / `RuntimeValue::Hash`, converting hash keys with `RuntimeValue::to_str()` like the existing `hash(...)` helper. Parser locks cover return payloads, mutation RHS slots, roundtrip display/parse, and the `.1.2.3.5.4` boundary that `name = [value]` remains `AssignScalar`. Runtime locks prove typed nested return payloads, mutation RHS shape payloads, and scalar-held RHS shape assignment. The Perl-oracle corpus now includes `terse_1_2_3_5_3_shape_literal_return_values` and `terse_1_2_3_5_3_shape_literal_mutation_rhs`, bringing the green corpus to 30 fixtures."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core shape_literal && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_2_3_5_3 && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Rust Shape-Literal Value Parity

Rust now accepts direct shape literals as value expressions:

```text
[]
[value, cat("a", "b"), true, []]
{ key => value, "fixed" => [value] }
```

The member semantics match the accepted Perl value contract from
[[terse-shape-literal-value-expressions]]: bare elements, keys, and values are scalar working-variable reads;
quoted hash keys are fixed fields; helpers, primitive literals, direct access, and nested shape literals compose
through the normal expression path.

This leaf intentionally stops before RHS target-kind inference. On Rust today:

```text
name = [value]
```

stores the array payload in scalar `name`; it does not replace array working variable `name`. Matching the Perl
aggregate bare-target inference rule is `SPEC-FORMAT-TERSE.1.2.3.5.4`.

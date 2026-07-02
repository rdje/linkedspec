---
id: terse-numeric-comparison-word-aliases
title: "SPEC-FORMAT-TERSE.3.2.3.3 makes bare comparison words numeric aliases."
answers:
  - "are eq ne gt ge lt le numeric now"
  - "does gt(10,2) lower as numeric greater-than"
  - "how do I write lexical string comparison now"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.3"
date: 2026-07-02
status: current
tags: [spec-format-terse, comparisons, helper-aliases, string-helpers, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.3.2.3.3 implementation; perl/LinkedSpec/ActionIR/FlowExpr.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; rust/linkedspec-core/src/validation.rs; rust/linkedspec-runtime/src/engine.rs; t/phase0_regression.t; rust/linkedspec-runtime/tests/integration_test.rs; rust/linkedspec-runtime/tests/corpus/terse_3_2_3_3_numeric_comparison_word_aliases; docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md"
reverify: "perl -Iperl -MLinkedSpec::RuleIR::EmitContext -e 'print LinkedSpec::RuleIR::EmitContext::_lower_flow_composite_expr(q{gt(10, 2)})' && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_3_2_3_3_numeric_comparison_word_aliases_run"
---

# Terse Numeric Comparison Word Aliases

`SPEC-FORMAT-TERSE.3.2.3.3` flips ordinary comparison word calls to numeric semantics on Perl and Rust:

- `eq(lhs,rhs)` -> `num_eq(lhs,rhs)`
- `ne(lhs,rhs)` -> `num_ne(lhs,rhs)`
- `gt(lhs,rhs)` -> `num_gt(lhs,rhs)`
- `ge(lhs,rhs)` -> `num_ge(lhs,rhs)`
- `lt(lhs,rhs)` -> `num_lt(lhs,rhs)`
- `le(lhs,rhs)` -> `num_le(lhs,rhs)`

Lexical string comparisons use the explicit bridge names `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`,
and `str_le`.

Comparison symbol callees such as `>(a,b)`, `>=(a,b)`, `==(a,b)`, and `!=(a,b)` remain deferred to
`SPEC-FORMAT-TERSE.3.2.3.4`.

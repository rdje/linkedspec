---
id: terse-scalar-assignment-expression-values
title: "SPEC-FORMAT-TERSE.3.3.1 ships scalar assignment expressions that store and yield the scalar value."
answers:
  - "does return(name = value) work now"
  - "does =(target, value) work as scalar assignment"
  - "does scalar assignment yield a value in terse specs"
  - "do set and assign yield scalar values in value positions"
  - "can an assignment expression feed a receiver chain"
  - "are direct shape assignment expressions implemented"
  - "where are aggregate assignment expression values recorded"
  - "what is next after SPEC-FORMAT-TERSE.3.3.1"
date: 2026-07-02
status: current
tags: [spec-format-terse, assignment, expressions, scalar, rust-parity, oracle]
evidence: "SPEC-FORMAT-TERSE.3.3.1 implementation in perl/LinkedSpec/ActionIR/MethodExpr.pm, perl/LinkedSpec/ActionIR/MethodLowering.pm, rust/linkedspec-core/src/expr.rs, and rust/linkedspec-runtime/src/engine.rs; locks in t/actionir_ast_parser.t, t/phase0_regression.t spec_format_terse_3_3_1_scalar_assignment_expression_values, rust/linkedspec-runtime/tests/integration_test.rs terse_3_3_1_scalar_assignment_expressions_run, and rust/linkedspec-runtime/tests/corpus/terse_3_3_1_scalar_assignment_expressions. SPEC-FORMAT-TERSE.3.3.2 later landed direct RHS shape assignment expression values; see [[terse-aggregate-assignment-expression-values]]. SPEC-FORMAT-TERSE.3.3.3 later landed array append and hash-index mutation expression values; see [[terse-mutation-assignment-expression-values]]. SPEC-FORMAT-TERSE.3.3.4 later closed the parent docs/oracle compatibility contract; see [[terse-assignment-expression-closure]]."
reverify: "prove -q -Iperl t/actionir_ast_parser.t t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_1_scalar_assignment_expressions_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_2_aggregate_assignment_expressions_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# Terse Scalar Assignment Expression Values

`SPEC-FORMAT-TERSE.3.3.1` makes scalar non-shape assignment forms value expressions on both Perl and Rust.

- `name = value` stores in scalar `name` and yields the stored value.
- `=(name, value)` is the scalar operator-call equivalent.
- Scalar `set(name, value)` and `assign(name, value)` compatibility forms yield the stored scalar value when used
  in scalar value positions.
- Assignment expression values can appear in helper arguments, expression-valued blocks, user functions, and
  compatible receiver chains such as `=(raw, " hi ").trim()`.

`SPEC-FORMAT-TERSE.3.3.2` later implemented direct RHS shape assignment values after target-kind inference:
`return(items = [value])` and `return(meta = { key => value })` now store and yield aggregate values on Perl and
Rust. `SPEC-FORMAT-TERSE.3.3.3` then implemented mutation assignment values: `return(items += value)` yields the
updated array snapshot and `return(meta[key] = value)` yields the updated hash snapshot. `SPEC-FORMAT-TERSE.3.3.4`
then closed the parent docs/oracle compatibility contract; see [[terse-assignment-expression-closure]].

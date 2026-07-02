---
id: terse-aggregate-assignment-expression-values
title: "SPEC-FORMAT-TERSE.3.3.2 ships aggregate assignment expressions that store and yield assigned shapes."
answers:
  - "does return(items = [value]) work now"
  - "does =(items, [value]) yield an array value"
  - "does set(meta, { key => value }) yield a hash value"
  - "do bare aggregate assignment targets infer array or hash kind in value positions"
  - "how do array(target) and hash(target) assignment expressions behave"
  - "does scalar(payload) keep direct shape assignment payloads scalar"
  - "what is next after SPEC-FORMAT-TERSE.3.3.2"
date: 2026-07-02
status: current
tags: [spec-format-terse, assignment, expressions, aggregate, target-kind-inference, rust-parity, oracle]
evidence: "SPEC-FORMAT-TERSE.3.3.2 implementation in perl/LinkedSpec/ActionIR/MethodLowering.pm, perl/LinkedSpec/RuleIR/EmitContext.pm, rust/linkedspec-core/src/expr.rs, and rust/linkedspec-runtime/src/engine.rs; locks in t/actionir_ast_parser.t, t/phase0_regression.t spec_format_terse_3_3_2_aggregate_assignment_expression_values, rust/linkedspec-runtime/tests/integration_test.rs terse_3_3_2_aggregate_assignment_expressions_run, and rust/linkedspec-runtime/tests/corpus/terse_3_3_2_aggregate_assignment_expressions"
reverify: "prove -q -Iperl t/actionir_ast_parser.t t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_2_aggregate_assignment_expressions_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# Terse Aggregate Assignment Expression Values

`SPEC-FORMAT-TERSE.3.3.2` makes direct RHS shape assignments value expressions on both Perl and Rust.

- `items = [value]`, `set(items, [value])`, and `=(items, [value])` infer an array working variable for a bare
  target, store the assigned array, and yield the assigned array value.
- `meta = { key => value }`, `set(meta, { key => value })`, and `=(meta, { key => value })` infer a hash working
  variable for a bare target, store the assigned hash, and yield the assigned hash value.
- Explicit `array(items)` and `hash(meta)` targets match the direct RHS shape and yield aggregate snapshots.
- Explicit `scalar(payload)` targets keep the scalar payload boundary, so `set(scalar(payload), [value])` stores
  and yields a scalar-held array payload.

This leaf extends the target-kind inference contract from statement assignments into value positions. It did not
close array append values or hash-index mutation values; those later landed in `SPEC-FORMAT-TERSE.3.3.3`. See
[[terse-mutation-assignment-expression-values]].

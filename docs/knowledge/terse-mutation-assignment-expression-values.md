---
id: terse-mutation-assignment-expression-values
title: "SPEC-FORMAT-TERSE.3.3.3 ships mutation assignment expressions that return updated aggregate snapshots."
answers:
  - "does return(items += value) work now"
  - "does items += value yield an array"
  - "does meta[key] = value yield a hash"
  - "can mutation assignment expressions feed receiver chains"
  - "what is the value contract for array append assignment expressions"
  - "what is the value contract for hash-index assignment expressions"
  - "what is next after SPEC-FORMAT-TERSE.3.3.3"
  - "did SPEC-FORMAT-TERSE.3.3.4 close assignment expressions"
date: 2026-07-02
status: current
tags: [spec-format-terse, assignment, mutation, expressions, array, hash, rust-parity, oracle]
evidence: "SPEC-FORMAT-TERSE.3.3.3 implementation in perl/LinkedSpec/ActionIR/MethodLowering.pm, perl/LinkedSpec/RuleIR/EmitContext.pm, rust/linkedspec-core/src/expr.rs, and rust/linkedspec-runtime/src/engine.rs; locks in t/actionir_ast_parser.t, t/phase0_regression.t spec_format_terse_3_3_3_mutation_assignment_expression_values, rust/linkedspec-runtime/tests/integration_test.rs terse_3_3_3_mutation_assignment_expressions_run, and rust/linkedspec-runtime/tests/corpus/terse_3_3_3_mutation_assignment_expressions. SPEC-FORMAT-TERSE.3.3.4 later closed the parent assignment-expression contract; see [[terse-assignment-expression-closure]]."
reverify: "prove -q -Iperl t/actionir_ast_parser.t t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_parenthesized_mutation_assignment_receiver_chains && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_3_mutation_assignment_expressions_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# Terse Mutation Assignment Expression Values

`SPEC-FORMAT-TERSE.3.3.3` makes array append and hash-index mutation operators value expressions on both Perl and
Rust.

- `items += value` mutates the named working array and yields the updated array snapshot after the push.
- `meta[key] = value` mutates the named working hash and yields the updated hash snapshot after the field write.
- Bare RHS/key identifiers in these mutation slots keep the shipped scalar-read contract: `items += value` reads
  scalar `value`, and `meta[key] = value` reads scalar `key` plus scalar `value`.
- The snapshot values compose in `return(...)`, helper arguments, expression-valued blocks, user functions, and
  compatible receiver chains such as `(items += value).count()` and `(meta[key] = value).count_keys()`.
- Statement behavior is unchanged: using the same forms as statements still mutates the named working target.

This closes the append/hash-index part of the `.3.3` assignment-expression split. At that time array end methods
remained statement-only; uniform binding later superseded that boundary and made them return updated arrays.
`SPEC-FORMAT-TERSE.3.3.4` later closed the parent docs/oracle compatibility contract; see
[[terse-assignment-expression-closure]] and [[uniform-binding-array-end-result-supersession]].

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
status: historical baseline; Perl typed-path results superseded by FUTURE-PARITY-BACKLOG.19.2.1
tags: [spec-format-terse, assignment, mutation, expressions, array, hash, rust-parity, oracle]
evidence: "SPEC-FORMAT-TERSE.3.3.3 implementation in perl/LinkedSpec/ActionIR/MethodLowering.pm, perl/LinkedSpec/RuleIR/EmitContext.pm, rust/linkedspec-core/src/expr.rs, and rust/linkedspec-runtime/src/engine.rs; locks in t/actionir_ast_parser.t, t/phase0_regression.t spec_format_terse_3_3_3_mutation_assignment_expression_values, rust/linkedspec-runtime/tests/integration_test.rs terse_3_3_3_mutation_assignment_expressions_run, and rust/linkedspec-runtime/tests/corpus/terse_3_3_3_mutation_assignment_expressions. SPEC-FORMAT-TERSE.3.3.4 later closed the parent assignment-expression contract; see [[terse-assignment-expression-closure]]."
evidence_update_2026_08_31_typed_paths: "FUTURE-PARITY-BACKLOG.19.2.1 generalizes Perl name[key] assignment from harray-only interpretation to typed path selection: evaluated string selects harray and nonnegative integer selects array, so its expression result is an updated typed-root snapshot. FUTURE-PARITY-BACKLOG.19.2.2 canonical attempt one catches and repairs two recurring checker anchors that still demanded the historical hash-only wording."
evidence_update_2026_09_04_five_backend_typed_paths: "FUTURE-PARITY-BACKLOG.19.3.1/.19.4.1/.19.5.1/.19.6.1 carry the same typed path result through Rust, Dart, Julia, PUC Lua, and LuaJIT. All five backends now classify assignment selectors from evaluated string/nonnegative-integer kind and return detached updated roots; portable/public admission remains separately pending."
reverify: "prove -q -Iperl t/actionir_ast_parser.t t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_parenthesized_mutation_assignment_receiver_chains && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_3_mutation_assignment_expressions_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# Terse Mutation Assignment Expression Values

At its 2026-07-02 boundary, `SPEC-FORMAT-TERSE.3.3.3` made array append and hash-index mutation operators value
expressions on both Perl and Rust.

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

Perl later superseded the harray-only `meta[key]` interpretation under `FUTURE-PARITY-BACKLOG.19.2.1`: evaluated
string selectors still update harrays, while nonnegative integers update arrays. Rust, Dart, Julia, PUC Lua, and
LuaJIT now share that typed-root result under `.19.3.1`, `.19.4.1`, `.19.5.1`, and `.19.6.1`.

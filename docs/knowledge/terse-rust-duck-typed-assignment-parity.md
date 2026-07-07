---
id: terse-rust-duck-typed-assignment-parity
title: "SPEC-FORMAT-TERSE.11.3 - Rust bare assignment binds typed values instead of retagging direct RHS shapes."
answers:
  - "does Rust name = [value] still infer an array working variable"
  - "does Rust set(items, [value]) bind a scalar held array value"
  - "does Rust =(items, [value]) return the assigned typed value"
  - "how do Rust array(name) and hash(name) read scalar held typed values"
  - "how do explicit array(name) and hash(name) assignment targets behave after duck typed assignment"
  - "where did Rust duck typed assignment parity land"
  - "what superseded Rust RHS shape target-kind inference"
date: 2026-07-05
status: current
tags: [spec-format-terse, assignment, duck-typing, variables, rust, runtime, value-binding, oracle, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.11.3 changed rust/linkedspec-runtime/src/engine.rs after the Perl reference change in SPEC-FORMAT-TERSE.11.2. Rust removed the direct RHS-shape retagging helpers for bare assignment and now evaluates the RHS and stores the resulting RuntimeValue through RuntimeContext::set_scalar for Expr::AssignScalar, statement-form name = value, and helper-form set(name,value) / =(name,value). Direct RHS arrays and hashes are therefore scalar-held typed values for bare targets: items = [value], set(items, [value]), and =(items, [value]) bind and yield the array RuntimeValue; meta = { key : value } binds and yields the hash RuntimeValue. Explicit raw array(name) and hash(name) targets remain aggregate storage and route through set_array/set_hash. Runtime scalar-held snapshots are guarded by bare_kind(name) == Scalar and feed array(name), hash(name), copy(...), aggregate-consuming helper slots, and compatible receiver chains. The same leaf closed the Perl reference readback gap exposed by the oracle for scalar-held copy(name) and bare array receiver chains. Integration locks cover terse_11_3, scalar-slot shorthand readback, .3.3.2 aggregate assignment expression values, and .3.3.4 assignment-expression closure. tools/gen_oracle_corpus.pl now emits terse_11_3_shape_assignment_value_binding and terse_11_3_assignment_replacement_and_explicit_targets; the manifest lists 91 fixtures and the Rust oracle passes."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_11_3 && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_2_aggregate_assignment_expressions_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_3_3_4_assignment_expression_closure_run && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Rust Duck-Typed Assignment Parity

Rust now matches the Perl duck-typed assignment contract:

```text
items = [value]
set(items, [value])
=(items, [value])
meta = { key : value }
```

These forms bind the array or hash as the variable's current typed value. They do not retag a bare target into the
array or hash aggregate store.

Explicit aggregate targets remain deliberate aggregate storage:

```text
set(array(items), [value])
set(hash(meta), { key : value })
```

When a name is scalar-bound to an array or hash value, `array(name)`, `hash(name)`, `copy(name)`, aggregate-consuming
helper slots, and compatible receiver chains read guarded snapshots of that scalar-held typed value. Later explicit
aggregate mutations such as `items += value`, `set(array(items), ...)`, `meta[key] = value`, or
`set(hash(meta), ...)` can retag the name back to aggregate storage.

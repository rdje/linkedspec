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
date: 2026-09-07
status: historical assignment milestone; aggregate selector and storage guidance superseded by uniform bindings
tags: [spec-format-terse, assignment, duck-typing, variables, rust, runtime, value-binding, oracle, SPEC-FORMAT-TERSE]
evidence: "Historical 2026-07-05 milestone, superseded for aggregate selectors and public storage by uniform bindings. SPEC-FORMAT-TERSE.11.3 changed rust/linkedspec-runtime/src/engine.rs after the Perl reference change in SPEC-FORMAT-TERSE.11.2. Rust removed the direct RHS-shape retagging helpers for bare assignment and now evaluates the RHS and stores the resulting RuntimeValue through RuntimeContext::set_scalar for Expr::AssignScalar, statement-form name = value, and helper-form set(name,value) / =(name,value). Direct RHS arrays and hashes are therefore scalar-held typed values for bare targets: items = [value], set(items, [value]), and =(items, [value]) bind and yield the array RuntimeValue; meta = { key : value } binds and yields the hash RuntimeValue. Explicit raw array(name) and hash(name) targets remain aggregate storage and route through set_array/set_hash. Runtime scalar-held snapshots are guarded by bare_kind(name) == Scalar and feed array(name), hash(name), copy(...), aggregate-consuming helper slots, and compatible receiver chains. The same leaf closed the Perl reference readback gap exposed by the oracle for scalar-held copy(name) and bare array receiver chains. Integration locks cover terse_11_3, scalar-slot shorthand readback, .3.3.2 aggregate assignment expression values, and .3.3.4 assignment-expression closure. tools/gen_oracle_corpus.pl now emits terse_11_3_shape_assignment_value_binding and terse_11_3_assignment_replacement_and_explicit_targets; the manifest lists 91 fixtures and the Rust oracle passes."
reverify: "bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test uniform_binding_contract"
---

# Rust Duck-Typed Assignment Parity

The July `.11.3` milestone established these typed bare assignments:

```text
items = [value]
set(items, [value])
=(items, [value])
meta = { key : value }
```

These forms bind the array or hash as the variable's current typed value. They do not retag a bare target into the
array or hash aggregate store.

The following aggregate-target and storage description is historical. Exact `array(IDENTIFIER)` and
`hash(IDENTIFIER)` selectors were later retired under `FUTURE-PARITY-BACKLOG.12.1.8.2`; use bare typed bindings
for current reads and targets. See [[rust-aggregate-selector-compile-rejection]] and
[[uniform-binding-neutral-contract]]. The older 91-fixture count above is dated milestone evidence.

At `.11.3`, explicit aggregate targets still selected aggregate storage:

```text
set(array(items), [value])
set(hash(meta), { key : value })
```

At that milestone, a scalar-bound array or hash could be read through guarded snapshots by the shown selectors,
`copy(name)`, aggregate-consuming helper slots, and compatible receiver chains. Explicit aggregate mutations could
retag the old host storage. This is not the current public storage model, which exposes one typed binding per name.

`SESSION-STARTUP-READING.3.3.8` reconciles this historical card while reading the core expression tests. The test
name ending `until_target_inference_leaf` is also historical naming debt owned by startup repair `.41.6`; its
`AssignScalar` assertions do not schedule another target-inference implementation. Fresh neutral uniform-binding
checks pass 11 migrations, 7 executions, 6 invalid selectors and 8 constructors; no new native execution is claimed.

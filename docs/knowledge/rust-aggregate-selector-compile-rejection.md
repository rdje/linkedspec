---
id: rust-aggregate-selector-compile-rejection
title: "Rust rejects exact aggregate selectors across compiled and generated ActionIR"
answers:
  - "how does Rust reject array name and hash name selectors"
  - "what is the Rust aggregate selector removed diagnostic"
  - "are Rust selectors rejected inside dead code"
  - "are Rust selectors rejected inside unused user functions"
  - "does generated Rust reject serialized selector AST"
  - "which array and hash constructors remain valid on Rust"
  - "where was Rust selector compatibility dispatch removed"
date: 2026-07-12
status: current
tags: [rust, actionir, compiler, generated-source, bindings, retirement, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.8.2 adds recursive typed-AST detection in linkedspec-core/src/expr.rs and whole-CompiledSpec validation in compiler.rs. Normal compilation, traced compilation, generated-source emission, v1 decode, and legacy generated adapters reject exact selectors. Selector-specific runtime read/target/assignment/receiver dispatch is deleted. The focused uniform-binding suite passes 15/15, covering six neutral invalid cases, dead code, edge fluent arguments, unused functions, generated payloads, and eight retained constructor/literal classes. Complete core tests pass 185+3+8; runtime integration passes 197/197; all 105 interpreted cases and the final post-rename 105-case generated classifier (329.32 seconds), full Rust package and CLI 61x2, and canonical local CI pass. The recurring source scan is zero-positive/13 classified rejection sites."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test uniform_binding_contract && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test generated_source_full_manifest_classifier && python3 tools/check_executable_aggregate_selector_sources.py"
---

# Rust aggregate-selector compile rejection

Rust represents lifecycle and user-function code as typed `Expr` / `CodeBlock` trees. Every expression can now
report the first exact `array` or `hash` call whose only argument is one bare identifier. The walk includes nested
arguments, assignments, direct-access indices, shape literals, value blocks, receivers, and fluent-call arguments.
It emits `aggregate_selector_removed surface=<array|hash> identifier=<name> replacement=<name>`.

The compiler validates the complete `CompiledSpec` after all functions and rules exist, so unused function bodies,
unreachable branches, every lifecycle block, action/blind edge code, and deferred edge-fluent arguments share one
boundary. Generated-source emission validates before serialization, and generated-plan decode validates untrusted
serialized `CompiledSpec` data before plan validation or execution. Native and generated paths therefore cannot
disagree merely because one started from already-compiled JSON.

Runtime branches that formerly interpreted exact selectors as reads, mutation targets, assignment targets, or
receiver targets are deleted. Bare bindings own those operations. Rejection remains shape-exact: `array()`,
`array("items")`, `array(copy(items))`, multi-argument arrays, `hash()`, valid key/value hashes, and direct array/
harray literals remain constructors or values.

Related facts: [[uniform-binding-neutral-contract]], [[rust-uniform-binding-runtime]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[perl-aggregate-selector-compile-rejection]].

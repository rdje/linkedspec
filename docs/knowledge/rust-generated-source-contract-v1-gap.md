---
id: rust-generated-source-contract-v1-gap
title: Rust generated source predates contract v1 and needs identity, errors, exact plan rejection, and neutral trace roles
answers:
  - "does Rust generated source already satisfy contract v1"
  - "what blocks Perl generated-source admission"
  - "does Rust generated source carry source identity"
  - "does Rust expose generated_source_error"
  - "does Rust reject an unknown generated family"
  - "does Rust emit the neutral generated trace roles"
date: 2026-07-11
status: current
tags: [rust, generated-source, contract, parity, diagnostics, trace, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.3.1.3.0 audits rust/linkedspec-runtime/src/source_emitter.rs and its tests. emit_rust_source accepts only &CompiledSpec and returns Result<String,String>; emitted text has a format marker but no contract-id or source-identity marker. The private validator reports raw text, its typed enum cannot represent unknown family input, and the Repetition compatibility value weakens exact family matching. Traced execution emits rich rust_runtime:generated_plan:* topics rather than generated_rule_enter/generated_family_decision/generated_rule_exit. Existing capability remains real: cargo test -p linkedspec-runtime --test source_emitter passes 3/3 in 35.69 seconds, covering ten families, legacy repetition, independent temporary crates, and the accepted eight-case subset. Leaves .3.1.3.1-.3 own contract alignment and admission before any capability promotion."
reverify: "rg -n 'emit_rust_source|LINKEDSPEC_GENERATED_SOURCE_FORMAT|source_identity|generated_source_error|generated_plan_unknown_family|generated_rule_enter|generated_family_decision|generated_rule_exit|rust_runtime:generated_plan' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/source_emitter.rs && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated-Source Contract-v1 Gap

The existing Rust source path is a sound pre-contract scaffold, not yet the
neutral v1 baseline. It already emits deterministic native source, compiles it
in isolated temporary crates, validates a typed family table, directly executes
all ten structural families, supports traced execution, and passes the accepted
eight-case corpus subset.

Contract v1 adds observations that scaffold never modeled:

- caller-supplied source identity and contract-id markers;
- structured `generated_source_error` fields/stages/codes;
- all four exact plan rejection codes, including unknown family;
- the three neutral generated trace roles in addition to rich native events.

The compatibility `emit_rust_source(&CompiledSpec) -> Result<String, String>`
must remain usable while an idiomatic typed v1 request/error API is added.
Metadata/errors and plan/trace are separate implementation leaves; only the
later admission leaf may promote Perl or close the contract baseline.

Related facts: [[generated-source-contract-v1]],
[[generated-source-parity-audit]], [[rust-generated-source-family-plan]].

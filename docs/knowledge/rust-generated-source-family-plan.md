---
id: rust-generated-source-family-plan
title: Rust generated source embeds and validates a rule-family plan before direct execution
answers:
  - "how does Rust generated source classify rule families"
  - "what is GeneratedRuleFamily"
  - "what is GENERATED_RULES in emitted Rust source"
  - "does generated Rust source validate its family plan"
  - "does generated Rust source execute directly yet"
  - "what did RUST-PARITY.8.3.1 add"
date: 2026-07-04
status: accepted
tags: [rust, codegen, source-emitter, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.3.1 preserves parsed RuleMode on CompiledRule and adds source_emitter GeneratedRuleFamily / GeneratedRuleSpec planning. emit_rust_source now emits COMPILED_SPEC_JSON plus GENERATED_RULES rows. execute_generated_parser deserializes the embedded CompiledSpec, validates generated labels/families against classify_generated_rule_family, and then delegates through Engine. classify_generated_rule_family distinguishes Default, OrAcode, AndSingleAcode, AndAcodeSeq, AndBcode, OrBcode, and Repetition. The focused source_emitter test builds generated modules in an isolated temp crate for default, OR acode, AND single-acode, AND sequential-acode, AND bcode, and OR bcode family markers. Direct generated execution is not yet landed; RUST-PARITY.8.3.2 owns default/OR acode direct execution next."
reverify: "rg -n 'GeneratedRuleFamily|GeneratedRuleSpec|GENERATED_RULES|classify_generated_rule_family|execute_generated_parser|RuleMode' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs rust/linkedspec-core/src/types.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated-Source Family Plan

`RUST-PARITY.8.3.1` establishes the generated-source planning contract before
direct Rust handler-family execution starts.

Generated source now carries two embedded artifacts:

- `COMPILED_SPEC_JSON`: the serialized interpreted `CompiledSpec`.
- `GENERATED_RULES`: a table of labels and generated rule families.

The supported family markers are `Default`, `OrAcode`, `AndSingleAcode`,
`AndAcodeSeq`, `AndBcode`, `OrBcode`, and `Repetition`.

At runtime, `execute_generated_parser(...)` deserializes the compiled spec,
validates the generated labels and family classifications against the embedded
compiled rules, and then delegates through the existing `Engine`.

Direct generated execution has not landed yet. The next executable leaf is
`RUST-PARITY.8.3.2`, which owns direct default/OR acode generated execution.

---
id: rust-generated-source-family-plan
title: Rust generated source embeds a validated rule-family plan and routes direct-capable families through it
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
evidence: "RUST-PARITY.8.3.1 preserves parsed RuleMode on CompiledRule and adds source_emitter GeneratedRuleFamily / GeneratedRuleSpec planning. emit_rust_source emits COMPILED_SPEC_JSON plus GENERATED_RULES rows. execute_generated_parser deserializes the embedded CompiledSpec, validates generated labels/families against classify_generated_rule_family, and then enters Engine::execute_generated_with_plan. classify_generated_rule_family distinguishes Default, OrAcode, AndSingleAcode, AndAcodeSeq, AndBcode, OrBcode, and Repetition. RUST-PARITY.8.3.2 made Default and OrAcode run directly inside the generated-plan executor; AND acode, bcode, and REP families still fall back until their owned leaves. The focused source_emitter test builds generated modules in an isolated temp crate for default, OR acode, AND single-acode, AND sequential-acode, AND bcode, and OR bcode markers."
reverify: "rg -n 'GeneratedRuleFamily|GeneratedRuleSpec|GENERATED_RULES|classify_generated_rule_family|execute_generated_parser|RuleMode' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs rust/linkedspec-core/src/types.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated-Source Family Plan

`RUST-PARITY.8.3.1` established the generated-source planning contract, and
`RUST-PARITY.8.3.2` started routing direct-capable families through it.

Generated source now carries two embedded artifacts:

- `COMPILED_SPEC_JSON`: the serialized interpreted `CompiledSpec`.
- `GENERATED_RULES`: a table of labels and generated rule families.

The supported family markers are `Default`, `OrAcode`, `AndSingleAcode`,
`AndAcodeSeq`, `AndBcode`, `OrBcode`, and `Repetition`.

At runtime, `execute_generated_parser(...)` deserializes the compiled spec,
validates the generated labels and family classifications against the embedded
compiled rules, and then calls `Engine::execute_generated_with_plan(...)`.

Direct generated execution has landed for `Default` and `OrAcode`. AND acode,
bcode, and REP families still fall back inside the plan-aware executor until
their owned leaves replace those paths.

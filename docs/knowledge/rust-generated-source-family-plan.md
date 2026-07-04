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
evidence: "RUST-PARITY.8.3.1 preserves parsed RuleMode on CompiledRule and adds source_emitter GeneratedRuleFamily / GeneratedRuleSpec planning. emit_rust_source emits COMPILED_SPEC_JSON plus GENERATED_RULES rows. execute_generated_parser deserializes the embedded CompiledSpec, validates generated labels/families against classify_generated_rule_family, and then enters Engine::execute_generated_with_plan. classify_generated_rule_family distinguishes Default, OrAcode, AndSingleAcode, AndAcodeSeq, AndBcode, OrBcode, and Repetition. RUST-PARITY.8.3.2 made Default and OrAcode run directly inside the generated-plan executor; RUST-PARITY.8.3.3 made AndSingleAcode and AndAcodeSeq run directly with ordered AND sequence semantics; RUST-PARITY.8.3.4 made AndBcode and OrBcode run directly with shared blind-edge tail handling and OR first-match semantics. RUST-PARITY.8.3.5 closed the non-REP matrix by asserting generated-source coverage for all six non-repetition families; REP is the only fallback family and is owned by RUST-PARITY.8.4. The focused source_emitter test builds generated modules in an isolated temp crate for default, OR acode, AND single-acode, AND sequential-acode, AND bcode, and OR bcode markers."
reverify: "rg -n 'GeneratedRuleFamily|GeneratedRuleSpec|GENERATED_RULES|classify_generated_rule_family|execute_generated_parser|RuleMode' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs rust/linkedspec-core/src/types.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated-Source Family Plan

`RUST-PARITY.8.3.1` established the generated-source planning contract.
`RUST-PARITY.8.3.2`, `.8.3.3`, `.8.3.4`, and `.8.3.5` route every non-REP
family through it directly.

Generated source now carries two embedded artifacts:

- `COMPILED_SPEC_JSON`: the serialized interpreted `CompiledSpec`.
- `GENERATED_RULES`: a table of labels and generated rule families.

The supported family markers are `Default`, `OrAcode`, `AndSingleAcode`,
`AndAcodeSeq`, `AndBcode`, `OrBcode`, and `Repetition`.

At runtime, `execute_generated_parser(...)` deserializes the compiled spec,
validates the generated labels and family classifications against the embedded
compiled rules, and then calls `Engine::execute_generated_with_plan(...)`.

Direct generated execution has landed for `Default`, `OrAcode`,
`AndSingleAcode`, `AndAcodeSeq`, `AndBcode`, and `OrBcode`. REP is the only
fallback family left inside the plan-aware executor, and `.8.4` owns replacing
that path.

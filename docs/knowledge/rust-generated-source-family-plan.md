---
id: rust-generated-source-family-plan
title: Rust generated source embeds one validated neutral family plan and routes every family through it
answers:
  - "how does Rust generated source classify rule families"
  - "what is GeneratedRuleFamily"
  - "what is GENERATED_PLAN in emitted Rust source"
  - "did Rust generated source remove GENERATED_RULES"
  - "does generated Rust source validate its family plan"
  - "does generated Rust source execute directly yet"
  - "what did RUST-PARITY.8.3.1 add"
date: 2026-07-18
status: current
tags: [rust, codegen, source-emitter, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.3.1-.8.5 established ten generated families and direct execution across them. FUTURE-PARITY-BACKLOG.9.1.4.5 replaces the emitted typed GENERATED_RULES table with exactly one ordered GENERATED_PLAN of label/family rows, removes the historical Repetition compatibility marker, validates v2 plan rows against current compiled classification, and derives cursor policy from each validated family. The focused source_emitter test builds generated modules in an isolated temp crate for all ten families plus zero-progress/recursion termination and the governed corpus subset."
reverify: "rg -n 'GeneratedRuleFamily|GeneratedPlanRow|GENERATED_PLAN|classify_generated_rule_family|execute_generated_parser_v2|RuleMode' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter"
---

# Rust Generated-Source Family Plan

`RUST-PARITY.8.3.1` established the generated-source planning contract.
`RUST-PARITY.8.3.2`, `.8.3.3`, `.8.3.4`, `.8.3.5`, and `.8.4` route every
current generated family through it directly.

Generated source v2 now carries two embedded artifacts:

- `COMPILED_SPEC_JSON`: cursor-free serialized interpreted `CompiledSpec` state.
- `GENERATED_PLAN`: one table of ordered labels and neutral family strings.

The current family markers are `default`, `or_acode`, `and_single_acode`,
`and_acode_seq`, `and_bcode`, `or_bcode`, `rep_acode`, `rep_bcode`,
`rep_and_acode`, and `rep_and_bcode`. The historical `Repetition` compatibility
marker and emitted typed table are gone.

At runtime, `execute_generated_parser_v2(...)` first validates the artifact
contract, then deserializes the compiled spec,
validates the generated labels and family classifications against the embedded
compiled rules, derives seek/consume from the validated family, and enters the
generated-plan engine.

Direct generated execution has landed for every current family marker. `.8.5`
added the manifest-backed corpus-subset proof; see
[[rust-generated-source-corpus-subset]]. See
[[rust-generated-source-v2-rule-local-cursor]] for the v2 reconstruction and
v1 rejection boundary.

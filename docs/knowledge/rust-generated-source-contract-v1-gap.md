---
id: rust-generated-source-contract-v1-gap
title: Rust generated source now has v1 identity and errors; exact plan rejection and neutral trace roles remain
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
evidence: "FUTURE-PARITY-BACKLOG.3.1.3.0 audited the original gap. FUTURE-PARITY-BACKLOG.3.1.3.1 adds emit_rust_source_v1(&CompiledSpec, source_identity), exact contract/version/identity metadata, GeneratedSourceError stages/codes/attribution, caller compile/load projection, typed generated execute entrypoints, and compatibility-preserving emit_rust_source/parse adapters. Focused source_emitter passes 4/4 and the complete Rust gate passes 137/105/196/5/4/5/10 plus 61x2 CLI. The remaining private typed-enum plan cannot represent arbitrary unknown family input, Repetition remains a compatibility family value, and traced execution still exposes rich rust_runtime:generated_plan:* topics rather than generated_rule_enter/generated_family_decision/generated_rule_exit. Leaves .3.1.3.2-.3 own those residual roles and admission."
reverify: "rg -n 'emit_rust_source|LINKEDSPEC_GENERATED_SOURCE_FORMAT|source_identity|generated_source_error|generated_plan_unknown_family|generated_rule_enter|generated_family_decision|generated_rule_exit|rust_runtime:generated_plan' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/source_emitter.rs && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated-Source Contract-v1 Gap

The Rust source path now has a typed v1 boundary while retaining its original
compatibility API. It emits deterministic native source with caller identity,
contract/version metadata, typed execution failures, isolated compilation,
all-family execution, and the accepted eight-case corpus subset.

The completed `.3.1.3.1` observations are:

- caller-supplied source identity and contract-id markers;
- structured `generated_source_error` fields/stages/codes;
- caller-owned compile/load error projection;
- typed generated execution beside exact string compatibility adapters.

The residual `.3.1.3.2` work is exact neutral family strings, all four plan
rejections including arbitrary unknown-family input, and the three neutral
generated trace roles beside richer native events. Only `.3.1.3.3` may promote
Perl or close the contract baseline.

Related facts: [[generated-source-contract-v1]],
[[generated-source-parity-audit]], [[rust-generated-source-family-plan]].

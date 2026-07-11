---
id: rust-generated-source-contract-v1-gap
title: Rust generated source satisfies the admitted contract-v1 baseline; breadth remains
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
evidence: "FUTURE-PARITY-BACKLOG.3.1.3.0 audited the original gap; .3.1.3.1 adds typed identity/metadata/errors. FUTURE-PARITY-BACKLOG.3.1.3.2 adds emitted GeneratedPlanRow plan()/validate_plan(), exact ten neutral families, distinct row-count/label/known-family/unknown-family rejection, direct v1 top-rule result, and generated_rule_enter/generated_family_decision/generated_rule_exit beside rich rust_runtime:generated_plan:* topics. The neutral fixture exposed the historical accumulator envelope and drove a generated-plan-aware direct-value seam; legacy parse and traced APIs retain exact envelope behavior. FUTURE-PARITY-BACKLOG.3.1.3.3 repeats focused and complete gates and admits this baseline. Rust remains partial solely for 8/105 generated compile/run breadth owned by .3.2."
reverify: "rg -n 'emit_rust_source|LINKEDSPEC_GENERATED_SOURCE_FORMAT|source_identity|generated_source_error|generated_plan_unknown_family|generated_rule_enter|generated_family_decision|generated_rule_exit|rust_runtime:generated_plan' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/source_emitter.rs && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated-Source Contract-v1 Gap

The Rust source path now satisfies the contract-v1 baseline while retaining its
original compatibility API. It emits deterministic native source with caller
identity, contract/version metadata, typed failures, an exact neutral plan,
direct result, portable trace roles, isolated all-family execution, and the
accepted eight-case subset.

The completed `.3.1.3.1` observations are:

- caller-supplied source identity and contract-id markers;
- structured `generated_source_error` fields/stages/codes;
- caller-owned compile/load error projection;
- typed generated execution beside exact string compatibility adapters.

Typed v1 execution returns the direct top-rule value; legacy `parse` and
`parse_with_trace` keep the accumulator envelope. The `.3.1.3.3` admission is
complete. Rust remains partial only for generated breadth until `.3.2` expands
the proof from eight fixtures to all 105.

Related facts: [[generated-source-contract-v1]],
[[generated-source-parity-audit]], [[rust-generated-source-family-plan]].

---
id: rust-generated-nonrep-matrix-closed
title: Rust generated source has closed the non-REP family matrix
answers:
  - "is the Rust generated non-repetition matrix closed"
  - "which generated families run directly in Rust"
  - "what remains after RUST-PARITY.8.3.5"
  - "does generated Rust source still fall back for non-REP families"
  - "which leaf closed the generated non-REP matrix"
date: 2026-07-04
status: accepted
tags: [rust, codegen, source-emitter, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.3.5 made GeneratedPlanExecutor::execute_rule route all six non-REP families directly: Default, OrAcode, AndSingleAcode, AndAcodeSeq, AndBcode, and OrBcode. At .8.3.5 completion, Repetition was the only generated fallback; RUST-PARITY.8.4 later replaced that opaque bucket with explicit direct REP families. The source_emitter test asserts non-REP coverage with a BTreeSet completeness check and still builds/runs generated modules in an isolated temp crate."
reverify: "rg -n 'GeneratedRuleFamily::Repetition|expected_non_rep_families|RUST-PARITY\\.8\\.3\\.5|execute_generated_with_plan' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated Non-REP Matrix Closed

`RUST-PARITY.8.3.5` closed the non-repetition generated-source matrix.

Direct generated execution covers every non-REP generated family:

- `GeneratedRuleFamily::Default`
- `GeneratedRuleFamily::OrAcode`
- `GeneratedRuleFamily::AndSingleAcode`
- `GeneratedRuleFamily::AndAcodeSeq`
- `GeneratedRuleFamily::AndBcode`
- `GeneratedRuleFamily::OrBcode`

At `.8.3.5` completion, `GeneratedRuleFamily::Repetition` was the only generated
fallback family. `RUST-PARITY.8.4` has since replaced that opaque bucket with
direct explicit REP families; see [[rust-generated-rep-matrix-closed]] for the
current REP state.

The source-emitter test matrix keeps this boundary mechanical by collecting the
covered non-REP families and asserting equality with the complete expected set.

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
evidence: "RUST-PARITY.8.3.5 makes GeneratedPlanExecutor::execute_rule route exhaustively by GeneratedRuleFamily. Default, OrAcode, AndSingleAcode, AndAcodeSeq, AndBcode, and OrBcode enter direct generated execution; Repetition is the only family that falls back to Engine::execute_rule. The source_emitter test asserts its matrix covers all six non-REP families with a BTreeSet completeness check and still builds/runs generated modules in an isolated temp crate. Focused source_emitter, runtime-lib, and clippy checks pass. RUST-PARITY.8.4 owns REP direct execution."
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

`GeneratedRuleFamily::Repetition` is now the only generated fallback family. It
is owned by `RUST-PARITY.8.4`, which covers repetition handler families and
termination guards.

The source-emitter test matrix keeps this boundary mechanical by collecting the
covered non-REP families and asserting equality with the complete expected set
before REP work starts.

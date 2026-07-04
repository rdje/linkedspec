---
id: rust-generated-and-acode-direct
title: Rust generated source directly executes AND acode families
answers:
  - "does generated Rust source execute AND acode directly"
  - "which Rust generated families execute directly"
  - "what did RUST-PARITY.8.3.3 add"
  - "how does Rust handle AND acode sequence"
  - "what remains after direct AND acode generation"
  - "which leaf owns direct bcode generation"
date: 2026-07-04
status: accepted
tags: [rust, codegen, source-emitter, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.3.3 extends GeneratedPlanExecutor direct execution from Default/OrAcode to AndSingleAcode and AndAcodeSeq. The shared Rust regex/acode loop now treats non-repetition AND multi-regex rules as ordered sequences: regex slot 0, then slot 1, etc.; an out-of-order or incomplete sequence fires LX when present and returns undef before E. The focused source_emitter matrix proves AND single-acode and a two-slot AND sequential-acode case whose second edge returns and-seq, so stopping after the first regex would fail. Bcode families still fall back until RUST-PARITY.8.3.4; REP families remain RUST-PARITY.8.4."
reverify: "rg -n 'AndSingleAcode|AndAcodeSeq|is_and_acode_seq|RUST-PARITY\\.8\\.3\\.3|RUST-PARITY\\.8\\.3\\.4' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated AND Acode Direct Execution

`RUST-PARITY.8.3.3` makes the generated-plan executor run these additional
families directly:

- `GeneratedRuleFamily::AndSingleAcode`
- `GeneratedRuleFamily::AndAcodeSeq`

The important semantic lock is ordered AND acode sequence. For non-repetition
AND regex/acode rules with multiple regex slots, Rust now requires slot `0`,
then slot `1`, and so on before the rule can complete. If a later regex matches
early, or the next expected regex does not match, the rule follows the no-match
exit path and returns `undef` before the rule `E` block.

The direct generated-source matrix proves this with a two-slot rule whose second
edge returns `and-seq`. A one-match fallback would stop after the first regex
and return the wrong result.

Remaining generated families:

- `.8.3.4`: direct AND/OR bcode execution.
- `.8.4`: REP family direct execution and termination guards.

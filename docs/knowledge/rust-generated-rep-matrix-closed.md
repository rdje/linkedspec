---
id: rust-generated-rep-matrix-closed
title: Rust generated source directly executes explicit REP generated families
answers:
  - "is the Rust generated REP matrix closed"
  - "which generated REP families run directly in Rust"
  - "does generated Rust source still fall back for repetition rules"
  - "what did RUST-PARITY.8.4 add"
  - "how does Rust generated source handle REP-AND acode"
  - "how does Rust generated source handle repeated bcode"
date: 2026-07-04
status: accepted
tags: [rust, codegen, source-emitter, repetition, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.4 splits generated repetition classification into RepAcode, RepBcode, RepAndAcode, and RepAndBcode. GeneratedPlanExecutor routes all four through direct execution. The shared Rust runtime repeats blind-call OR choice and AND sequence steps with min/max bounds plus zero-progress termination, and REP-AND acode counts complete ordered regex groups before firing IT. Generated-source validation still accepts the old coarse Repetition marker for REP rules in existing v1 generated modules, then specializes it at execution time. rust/linkedspec-runtime/tests/source_emitter.rs covers all REP families, zero-progress termination, same-position recursive-call termination, and legacy Repetition marker compatibility, then builds/runs generated modules in an isolated temp crate. Focused Rust checks, mdBook, Knowledge Map, memory/doctrine gates, whitespace, and full local CI pass."
reverify: "rg -n 'RepAcode|RepBcode|RepAndAcode|RepAndBcode|expected_rep_families|rep_zero_progress_case|rep_recursion_guard_case|RUST-PARITY\\.8\\.4' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture"
---

# Rust Generated REP Matrix Closed

`RUST-PARITY.8.4` replaced the opaque generated repetition bucket with explicit
generated REP families:

- `GeneratedRuleFamily::RepAcode`
- `GeneratedRuleFamily::RepBcode`
- `GeneratedRuleFamily::RepAndAcode`
- `GeneratedRuleFamily::RepAndBcode`

Current generated source routes those families through direct generated-plan
execution. `GeneratedRuleFamily::Repetition` remains as a compatibility enum
value for older v1 generated modules; current classification no longer emits it,
but validation accepts it for REP rules and execution specializes it through the
same direct family path.

Two shared runtime semantics were required so generated source could keep using the
interpreter as its first oracle:

- repeated bcode rules now loop OR choice or AND sequence steps with min/max bounds
  and a zero-progress guard;
- REP-AND acode rules count a complete ordered regex group as one repetition, so
  `IT` runs once per group rather than once per regex slot.

The source-emitter matrix proves bounded REP acode, bounded REP bcode, bounded
REP-AND acode, bounded REP-AND bcode, zero-progress termination, same-position
recursive-call termination, and legacy `Repetition` marker compatibility in
generated modules built in the isolated temp crate.

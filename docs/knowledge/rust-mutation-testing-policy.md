---
id: rust-mutation-testing-policy
title: Rust mutation testing is explicit, targeted, and never a per-commit gate
answers:
  - "does LinkedSpec use cargo mutants"
  - "will cargo mutants run on every commit"
  - "is Rust mutation testing part of pre commit or ordinary local CI"
  - "when should Rust mutation tests run"
  - "how many Rust mutation candidates does LinkedSpec have"
  - "what Rust source is excluded from mutation testing"
  - "how are surviving Rust mutants handled"
  - "is mutation score a LinkedSpec quality target"
date: 2026-07-15
status: current
tags: [rust, testing, mutation-testing, cargo-mutants, local-ci, quality]
evidence: "FUTURE-PARITY-BACKLOG.20.0 and ADR 0039. Knowledge Map/source/local-CI audit found no prior mutation plan. Installed cargo-mutants 27.0.0 list-only census reported 3,333 candidates across 19 files: core 1,217 and runtime 2,116; engine.rs 1,343, expr.rs 522, parser.rs 320. No mutant executed. The generated Unicode mapping is byte-regenerated and behavior-checked from its governed generator, so it is the initial narrow exclusion."
reverify: "cargo mutants --version && cargo mutants --manifest-path rust/Cargo.toml --workspace --list --json | jq '{count: length, files: ([.[].file] | unique | length), by_package: (group_by(.package) | map({package: .[0].package, count: length}))}' && rg -n 'AUTO-GENERATED|unicode_case_mapping' rust/linkedspec-runtime/src/unicode_case_mapping.rs tools/check_unicode_case_contract.py"
---

# Rust Mutation-Testing Policy

LinkedSpec adopts `cargo-mutants` as a Rust test-strength tool, but mutation execution is never part of the
per-commit workflow, pre-commit hooks, or ordinary local CI—not even a diff- or file-scoped campaign. Normal
focused and broader tests remain the commit gates. Mutation runs are explicit on-demand investigations or
meaningful milestone, release, or admission campaigns; targeted files precede any resource-guarded sharded breadth.

The 2026-07-15 list-only baseline contains 3,333 candidates across 19 production files (1,217 core and 2,116
runtime), so a full run would be overkill at commit cadence. No mutation score exists yet because no mutant was
executed. Every later survivor, timeout, and unviable result must be classified separately. True gaps gain focused
behavior tests; equivalent, unreachable, deliberately unspecified, or tool-limited cases need exact durable
rationale. Signoff is the strengthened contract and disposition record, not a raw percentage.

Hand-written semantic code stays eligible regardless of size. The initial exclusion is the auto-generated Rust
Unicode mapping table: its governed generator, exact-byte regeneration checker, neutral fixtures, and runtime
proof own correctness. `RUST-MUTATION-TESTING` governs future configuration, a safe manual command, a bounded
pilot, survivor repair, and measured campaign cadence.

Related: [[repo-generated-artifact-cleanup-boundary]], [[unicode-17-case-contract-data]].

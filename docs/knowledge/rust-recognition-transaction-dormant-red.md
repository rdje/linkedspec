---
id: rust-recognition-transaction-dormant-red
title: Rust recognition transactions stop first at the missing private authority module
answers:
  - "where is the dormant Rust recognition transaction RED consumer"
  - "what is the first Rust recognition transaction RED failure"
  - "how do I run the Rust recognition transaction RED"
  - "why does ordinary Cargo run zero Rust recognition transaction tests"
  - "which cfg enables the Rust recognition transaction private authority contract"
  - "which cfg enables the Rust recognition transaction integration contract"
  - "which Rust transaction API does the dormant consumer freeze"
  - "does Rust have dedicated recognition transaction ActionIR nodes"
  - "does the Rust transaction RED cover independently compiled emitted source"
  - "does the Rust recognition transaction RED change rollout or production behavior"
date: 2026-08-10
status: current dormant RED boundary; private authority belongs to FUTURE-PARITY-BACKLOG.14.3.3.1
tags: [rust, recognition, transaction, ActionIR, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.3.0 adds rust/linkedspec-runtime/tests/recognition_transaction_contract.rs behind outer cfg linkedspec_recognition_transaction_red and nested integration cfg linkedspec_recognition_transaction_integration_red. Ordinary offline Cargo discovers the target and runs zero tests. Explicit outer-cfg execution exits 101 with one E0432 unresolved import linkedspec_runtime::recognition_transaction and no competing error. A direct current Rust CLI probe reports exactly four unknown-helper warnings for recognition_checkpoint, recognize_once, recognition_commit, and recognition_rollback, then returns null. The consumer derives the neutral 132/246, token 8+17, effects 6, marks 6, progress 8, diagnostics 15, mutations 41, rollout 2/9 authority; freezes monotonic opaque invocation/frame/token/snapshot ownership; and nests dedicated lowering plus native, reconstructed, generated-plan, independently compiled emitted-source, and compatibility expectations. It has zero Cargo-manifest or canonical-driver references, changes no production Rust module, and leaves Rust rollout RED. Focused Rust and mdBook proof pass; the complete host-authorized canonical gate passes repository containment, moved-root execution, CLI 66/66 twice, RAM 55%, and Phase 0 1031/1031 in 700 seconds."
reverify: "source tools/project_data_env.sh && cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract && ! rg -q 'recognition_transaction_contract[.]rs' rust/Cargo.toml tools/run_ci_local.sh && RUSTFLAGS='--cfg linkedspec_recognition_transaction_red -Awarnings' cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract 2>&1 | rg 'E0432|linkedspec_runtime::recognition_transaction'"
---

# Dormant Rust recognition-transaction RED

The final-path consumer is
`rust/linkedspec-runtime/tests/recognition_transaction_contract.rs`. Its
file-level custom cfg deliberately leaves ordinary Cargo and canonical CI with
zero active tests. Enable only `linkedspec_recognition_transaction_red` to
exercise the private state contract. The first and sole compiler boundary is
the absent `linkedspec_runtime::recognition_transaction` module, which belongs
to `.14.3.3.1`.

The outer contract freezes one source-local authority with opaque monotonic
invocation, frame, mark, and token generations; detached snapshots; recursive
same-label mark isolation; falsey-safe match/payload separation; exact
commit/rollback restoration; and portable lifecycle, escape, source, and
invocation errors. The nested integration cfg remains dormant behind that
boundary and freezes four dedicated non-eager ActionIR nodes, effect closure,
cursor-only progress, native/reconstructed/generated-plan execution, and a
freshly compiled emitted-source project under the repository-local Cargo
target workspace.

Current Rust recognizes none of this behavior. Its CLI treats the four exact
forms as unknown generic helpers. The consumer is not named by the manifest or
canonical driver, no production source changes, and the neutral rollout stays
at neutral plus Perl 2/9 complete.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Authored/static policy: [[cursor-transaction-authored-contract]].
- Perl reference admission: [[perl-recognition-transaction-integration]].
- Safety audit: [[cursor-transaction-safety-audit-plan]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.3.0`; first implementation seam `.14.3.3.1`.

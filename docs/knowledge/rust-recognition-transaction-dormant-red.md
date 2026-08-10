---
id: rust-recognition-transaction-dormant-red
title: Rust recognition transactions have a cfg-private authority and stop next at integration
answers:
  - "where is the dormant Rust recognition transaction RED consumer"
  - "where is the private Rust recognition transaction authority"
  - "what is the next Rust recognition transaction RED failure"
  - "how do I run the Rust recognition transaction RED"
  - "why does ordinary Cargo run zero Rust recognition transaction tests"
  - "why did the Rust transaction RED expose test defects only after the private module existed"
  - "which cfg enables the Rust recognition transaction private authority contract"
  - "which cfg enables the Rust recognition transaction integration contract"
  - "which Rust transaction API does the dormant consumer freeze"
  - "does Rust have dedicated recognition transaction ActionIR nodes"
  - "does the Rust transaction RED cover independently compiled emitted source"
  - "does the Rust recognition transaction RED change rollout or production behavior"
date: 2026-08-10
status: current cfg-private authority boundary; integration belongs to FUTURE-PARITY-BACKLOG.14.3.3.2
tags: [rust, recognition, transaction, ActionIR, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.3.0 adds rust/linkedspec-runtime/tests/recognition_transaction_contract.rs behind outer cfg linkedspec_recognition_transaction_red and nested integration cfg linkedspec_recognition_transaction_integration_red. FUTURE-PARITY-BACKLOG.14.3.3.1 adds rust/linkedspec-runtime/src/recognition_transaction.rs and its documentation-hidden lib.rs route under the same outer custom cfg only. The authority owns source-local monotonic invocation/frame/mark/token generations, detached snapshots, strict matched/payload separation, exactly-once attempt state, restore-before-invalidate misuse handling, and terminal drop/unwind cleanup. Ordinary offline Cargo discovers zero tests; explicit outer-cfg execution passes 7/7. Supplying the module exposed defects that the prior E0432 had masked in the dormant consumer: constructor shadowing, six abbreviated nonexistent neutral JSON keys, and an incomplete nonexistent syntax path. The repaired assertions retain the governed semantics and add explicit nesting/token-drop coverage. Nested integration cfg now fails first at FUTURE-PARITY-BACKLOG.14.3.3.2: missing classify_recognition_effects and validate_recognition_progress plus missing RecognitionCheckpoint, RecognizeOnce, and RecognitionRollback Expr variants. The module has no ordinary manifest/driver route and does not change parser, ActionIR, engine, generated source, rollout 2/9, or current public behavior. Complete Rust-local and canonical signoff pass; canonical proof includes CLI 66/66 twice, RAM 65%, and Phase 0 1,031/1,031 in 701 seconds."
reverify: "source tools/project_data_env.sh && cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract && RUSTFLAGS='--cfg linkedspec_recognition_transaction_red -Awarnings' cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract && RUSTFLAGS='--cfg linkedspec_recognition_transaction_red --cfg linkedspec_recognition_transaction_integration_red -Awarnings' cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract 2>&1 | rg 'classify_recognition_effects|validate_recognition_progress|RecognitionCheckpoint|RecognizeOnce|RecognitionRollback'"
---

# Cfg-private Rust recognition-transaction boundary

The final-path consumer is
`rust/linkedspec-runtime/tests/recognition_transaction_contract.rs`. Its
file-level custom cfg deliberately leaves ordinary Cargo and canonical CI with
zero active tests. Enable only `linkedspec_recognition_transaction_red` to
exercise the private state contract. The documentation-hidden
`linkedspec_runtime::recognition_transaction` module now satisfies that outer
contract at 7/7 while remaining absent from ordinary builds.

The private module implements one source-local authority with opaque monotonic
invocation, frame, mark, and token generations; detached snapshots; recursive
same-label mark isolation; falsey-safe match/payload separation; exact
commit/rollback restoration; and portable lifecycle, escape, source, and
invocation errors. Restore precedes invalidation on retry, nesting, escape,
cross-authority misuse, unwind, and token drop. Supplying the module also made
the consumer compile far enough to expose three masked test defects: a shadowed
constructor, six stale abbreviated JSON keys, and an incomplete stale authored-
surface assertion. Those test-only repairs preserve the frozen contract and add
explicit nesting/drop cleanup coverage.

The nested integration cfg remains RED at `.14.3.3.2`. It now reaches the
missing dedicated ActionIR variants plus effect/progress classifiers rather
than the private-authority seam. The same nested section continues to freeze
native/reconstructed/generated-plan execution and a freshly compiled emitted-
source project under the repository-local Cargo target workspace.

Current authored Rust still recognizes none of this behavior. Its CLI treats
the four exact forms as unknown generic helpers. Neither custom cfg is enabled
by the manifest or canonical driver, and the neutral rollout stays at neutral
plus Perl 2/9 complete.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Authored/static policy: [[cursor-transaction-authored-contract]].
- Perl reference admission: [[perl-recognition-transaction-integration]].
- Safety audit: [[cursor-transaction-safety-audit-plan]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.3.0-.1`; next integration seam `.14.3.3.2`.

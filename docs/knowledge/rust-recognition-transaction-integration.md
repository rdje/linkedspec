---
id: rust-recognition-transaction-integration
title: Rust recognition transactions are integrated behind two dormant custom cfgs
answers:
  - "where are Rust recognition transactions integrated"
  - "which Rust nodes represent recognition transactions"
  - "how does Rust preserve a false recognition payload"
  - "how does Rust bind recognition transactions to cursor boundary and marks"
  - "which Rust recognition transaction carriers pass"
  - "does emitted Rust source execute recognition transactions"
  - "are Rust recognition transactions admitted or public"
  - "why does ordinary Cargo run zero Rust recognition transaction tests"
  - "what is the next Rust recognition transaction leaf"
date: 2026-08-10
status: current cfg-private integration; admission remains FUTURE-PARITY-BACKLOG.14.3.3.3
tags: [rust, recognition, transaction, ActionIR, effects, progress, generated-source, dormant, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.3.2 adds cfg-private RecognitionCheckpoint, RecognizeOnce, RecognitionCommit, and RecognitionRollback Expr nodes with exact static normalization and serde reconstruction. The runtime exposes the neutral six-graph effect fixed point and eight-case cursor-progress validator, then binds native and generated-plan invocation entry/exit to the existing source-local authority over real cursor, anonymous boundary, recursive same-label marks, explicit child acceptance, and falsey-safe staged payloads. Structural AST inspection switches only transaction-bearing emitted modules to direct effective-engine execution. The nested consumer passes 12/12 across lowering, policy, native, reconstructed, generated-plan, independent emitted-source, and compatibility assertions; outer authority remains 7/7 and ordinary discovery remains 0 tests. No manifest or canonical-driver registration changes, so neutral rollout stays 2/9 and public support remains Perl-only."
reverify: "source tools/project_data_env.sh && RUSTFLAGS='--cfg linkedspec_recognition_transaction_red --cfg linkedspec_recognition_transaction_integration_red -Awarnings' cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract && git diff --exit-code -- rust/Cargo.toml tools/run_ci_local.sh"
---

# Cfg-private Rust recognition-transaction integration

The parser recognizes only the four complete static forms and replaces them
with dedicated expression nodes, so `recognize_once(token, call(Rule))` retains
the rule name without eagerly evaluating a generic call. Serde reconstruction
preserves the same typed tree.

Each native or generated-plan rule invocation enters one private frame. The
adapter synchronizes the actual cursor, anonymous boundary, and invocation-
local named marks with the authority. A separate completion channel carries
the child's match state; commit carries its staged payload, preserving a
successful `false`, zero, empty string, or undefined result. Unfinished tokens
restore their checkpoint during invocation exit before the terminal error is
reported.

Generated source uses structural AST inspection rather than text matching.
Only transaction-bearing modules route their compatibility `parse` entry
through the direct effective engine; ordinary emitted source stays on the
existing generated-plan compatibility path. The independent emitted consumer
builds entirely beneath `rust/target/test-workspaces` and removes its child
workspace after execution.

Both custom cfgs remain absent from Cargo manifests and the canonical driver.
This is implementation evidence for the pending Rust admission leaf, not a
current authored Rust capability.

Definitive signoff preserves that boundary: the canonical gate passes all
mandatory contracts, both 66-case CLI environments, repository-local storage
and moved-root proofs, RAM at 45%, and Phase 0 at 1,031/1,031 in 735 seconds.
The exact final marker is `[ci] local CI gate passed`.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Historical dormant boundary: [[rust-recognition-transaction-dormant-red]].
- Private authority: [[rust-recognition-transaction-dormant-red]].
- Perl admitted precedent: [[perl-recognition-transaction-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.3.2`; admission owner `.14.3.3.3`.

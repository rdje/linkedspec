---
id: rust-recognition-transaction-integration
title: Rust recognition transactions are integrated and canonically admitted
answers:
  - "where are Rust recognition transactions integrated"
  - "which Rust nodes represent recognition transactions"
  - "how does Rust preserve a false recognition payload"
  - "how does Rust bind recognition transactions to cursor boundary and marks"
  - "which Rust recognition transaction carriers pass"
  - "does emitted Rust source execute recognition transactions"
  - "are Rust recognition transactions admitted or public"
  - "how is the Rust recognition transaction consumer registered in canonical CI"
  - "which backend follows Rust recognition transaction admission"
date: 2026-09-07
status: admitted Rust integration; current neutral rollout 9/9; historical native test counts qualified below
tags: [rust, recognition, transaction, ActionIR, effects, progress, generated-source, admitted, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.3.2 adds cfg-private RecognitionCheckpoint, RecognizeOnce, RecognitionCommit, and RecognitionRollback Expr nodes with exact static normalization and serde reconstruction. The runtime exposes the neutral six-graph effect fixed point and eight-case cursor-progress validator, then binds native and generated-plan invocation entry/exit to the existing source-local authority over real cursor, anonymous boundary, recursive same-label marks, explicit child acceptance, and falsey-safe staged payloads. Structural AST inspection switches only transaction-bearing emitted modules to direct effective-engine execution. The nested consumer passes 12/12 across lowering, policy, native, reconstructed, generated-plan, independent emitted-source, and compatibility assertions; outer authority remains 7/7 and ordinary discovery remains 0 tests. No manifest or canonical-driver registration changes, so neutral rollout stays 2/9 and public support remains Perl-only."
evidence_update_2026_08_10_admission: "FUTURE-PARITY-BACKLOG.14.3.3.3 removes both custom cfgs across the exact nine-source Rust inventory, keeps the authority module documentation-hidden, makes the unchanged integrated consumer ordinary at 12/12, and requires/logs/executes its exact cargo test command once in canonical CI. The checker rejects eight path/log/command/stale-cfg mutations. Only Rust advances: rollout 3/9, semantic 42, public 3/11/25, and guide 1/4/8; Dart and all later legs remain RED."
evidence_update_2026_08_11_signoff: "The first canonical pass caught two stale rollout/availability assertions in the exact Perl consumer; its corrected 51-test proof passes. The outer Codex sandbox denied the nested macOS containment profile, while the isolated authorized oracle passed. One uninterrupted authorized canonical rerun then passes all eight doctrines, Perl 51/51, Rust 12/12, six-family containment, relocation, CLI 66x2, RAM 77%, and Phase 0 1,031/1,031 in 739 seconds before the exact local-CI marker."
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && ! rg -n 'linkedspec_recognition_transaction' rust/linkedspec-core rust/linkedspec-runtime"
---

# Admitted Rust recognition-transaction integration

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

Admission removes both custom cfgs from the complete parser/runtime/test source
inventory. Cargo therefore discovers the unchanged 12-test consumer ordinarily,
and canonical CI requires, logs, and executes its exact target once. The private
authority remains documentation-hidden, so this admits authored behavior without
creating a separately supported low-level Rust API.

Definitive signoff preserves that boundary: the canonical gate passes all
mandatory contracts, both 66-case CLI environments, repository-local storage
and moved-root proofs, RAM at 77%, and Phase 0 at 1,031/1,031 in 739 seconds.
The exact final marker is `[ci] local CI gate passed`.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Historical dormant boundary: [[rust-recognition-transaction-dormant-red]].
- Private authority: [[rust-recognition-transaction-dormant-red]].
- Perl admitted precedent: [[perl-recognition-transaction-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.3.2-.3`; Dart RED owner `.14.3.4.0`.

## September 7 authority prefix and current governance

`SESSION-STARTUP-READING.3.3.27` reads authority lines 1–872 and supporting helpers
1387–1454, all baseline-identical. Source authority uses Arc identity; invocation/frame/mark/
transaction generations are monotonic and checked for exhaustion. Invocation states retain weak
token references and tokens retain weak frame references. Snapshots clone cursor/boundary/marks.
Attempt status, matched state and payload presence remain separate, preserving false, zero, empty
string and explicit JSON null without using their truthiness to decide recognition.

The authority rejects nested live checkpoints, requires exactly one attempt, and restores live
snapshots before terminal/misuse errors. Its restore helper checks Invalidated before touching
frame state, unlike the measured Perl gap under [[perl-recognition-invalidated-token-restoration]].
The nine allowed/eleven rejected effects propagate through a recursive fixed point; missing
callees introduce unknown effects. Progress policy observes cursor advancement independently
of payload/boundary/mark changes. Remaining live-runtime adapters stay on the next reading leaf.

Fresh neutral proof passes 138 node rows/250 calls/58 mutations, token 8/17, six graphs, six
mark cases and eight progress cases, with rollout 9/9 complete. Public sequence is 3/26/45,
guide 1/14/18 and admission guards remain Rust 8, Dart 13, Julia 14, Lua authority/integration/
admission 22/19/22. The August 12-test native counts and then-next Dart/3-of-9 handoffs above
are historical; this reading does not rerun native recognition or emitted-source consumers.

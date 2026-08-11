---
id: dart-recognition-transaction-dormant-red
title: Dart recognition transactions have a private authority and stop next at integration
answers:
  - "where is the dormant Dart recognition transaction RED consumer"
  - "where is the private Dart recognition transaction authority"
  - "how do I run the Dart recognition transaction RED"
  - "how do I enable only the Dart recognition transaction integration RED"
  - "why does ordinary Dart test not discover recognition transactions"
  - "what is the next Dart recognition transaction failure"
  - "which Dart recognition transaction API is frozen"
  - "does the Dart transaction RED cover UTF-16 state"
  - "does the Dart transaction RED cover emitted source"
  - "does the Dart recognition transaction RED change rollout or production behavior"
date: 2026-08-11
status: current private-authority boundary; integration owned by FUTURE-PARITY-BACKLOG.14.3.4.2
tags: [dart, recognition, transaction, ActionIR, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.4.0.1 freezes dart/test_dormant/recognition_transaction_contract_test.dart at the absent private module. FUTURE-PARITY-BACKLOG.14.3.4.1 adds unexported dart/lib/src/runtime/recognition_transaction.dart over the existing SourceAuthority and removes the exact analyzer exclusion. One source-local authority owns opaque frame/token handles, monotonic invocation/mark/transaction generations, detached cursor/boundary/mark snapshots, same-label isolation, strict match/payload state, one attempt and terminal, restore-before-invalidate misuse/unwind/discard, and exact portable diagnostics. The default routed target passes 6 authority tests with 4 integration skips. LINKEDSPEC_DART_RECOGNITION_TRANSACTION_INTEGRATION_RED=1 exposes exactly four later failures: missing dedicated nodes, missing effect/progress methods, native unknown_helper, and emitted unknown_helper. Fatal analysis is clean, ordinary discovery remains 383 tests, no canonical route names the file, and production UTF-16 behavior plus neutral 132/246/42 and rollout 3/9 remain unchanged. Complete Dart passes format 100/0, ordinary 383, storage 21/47, CLI 66x2, and corpus 105; definitive CI passes eight doctrines, containment/relocation, CLI 66x2, RAM 65%, and Phase 0 1,031/1,031 in 697 seconds."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/recognition_transaction_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && bash ../tools/run_dart_project_data.sh test --reporter failures-only"
---

# Private Dart recognition-transaction boundary

The final-path consumer is
`dart/test_dormant/recognition_transaction_contract_test.dart`. Ordinary Dart
test discovery ignores that directory. The unexported
`dart/lib/src/runtime/recognition_transaction.dart` module now supplies the
frozen authority API, so strict analysis includes the consumer and its default
repository-routed invocation passes six authority tests.

One source-local authority owns monotonic invocation, mark, and transaction
generations plus opaque frames and tokens. Snapshots are detached; recursive
same-label marks are isolated; match presence is separate from a falsey staged
payload; and retry, escape, cross-owner use, nesting, unwind, and explicit
discard restore before invalidation. The module is not exported by the package
facade and does not recognize authored syntax.

The consumer already owns the complete later integration boundary: UTF-16-safe
state snapshots, recursive mark isolation, exact neutral diagnostics, dedicated
non-eager authored forms, effect and progress policy, falsey payloads, native
and reconstructed execution, generated-plan execution, independently analyzed
emitted source, and ordinary cursor compatibility. This RED slice changes no
production Dart source, canonical registration, rollout row, or public support
claim.

Set `LINKEDSPEC_DART_RECOGNITION_TRANSACTION_INTEGRATION_RED=1` to expose only
the next integration boundary. Its four tests fail at missing dedicated
ActionIR lowering, effect/progress classifiers, native runtime dispatch, and
the same emitted-runtime dispatch. Integration `.14.3.4.2` owns those seams;
admission `.14.3.4.3` moves the consumer to ordinary discovery only after every
frozen assertion is GREEN.

## Links

- Neutral contract: [[recognition-transaction-neutral-contract]].
- Rust precedent: [[rust-recognition-transaction-dormant-red]].
- Dart typed-source authority: [[dart-typed-source-location-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.4.0.1-.1`; next owner `.14.3.4.2`.

---
id: dart-recognition-transaction-dormant-red
title: Dart recognition transactions are frozen behind one exact missing private-authority boundary
answers:
  - "where is the dormant Dart recognition transaction RED consumer"
  - "how do I run the Dart recognition transaction RED"
  - "why does ordinary Dart test not discover recognition transactions"
  - "why does Dart analysis exclude one recognition transaction test"
  - "what is the next Dart recognition transaction failure"
  - "which Dart recognition transaction API is frozen"
  - "does the Dart transaction RED cover UTF-16 state"
  - "does the Dart transaction RED cover emitted source"
  - "does the Dart recognition transaction RED change rollout or production behavior"
date: 2026-08-11
status: current dormant boundary owned by FUTURE-PARITY-BACKLOG.14.3.4.1
tags: [dart, recognition, transaction, ActionIR, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.4.0.1 adds dart/test_dormant/recognition_transaction_contract_test.dart and excludes only that exact file in dart/analysis_options.yaml. The explicitly routed test parses the neutral contract, freezes an immutable-source authority with opaque frames and tokens, monotonic invocation/mark generations, detached snapshots, falsey-safe match/payload separation, exact terminal restoration, all eight token escapes, lifecycle and cross-owner diagnostics, four dedicated non-eager ActionIR nodes, effect/progress validation, native/reconstructed/generated-plan carriers, independently analyzed emitted source, and ordinary cursor compatibility. Its only compile boundary is the absent private package module package:linkedspec_dart/src/runtime/recognition_transaction.dart and its RecognitionTransactionAuthority, RecognitionFrameState, and RecognitionTransactionException types. Ordinary fatal analysis passes, ordinary dart test passes 383 tests, and neither canonical runner names the dormant file. Production, UTF-16 registers/results, neutral 132/246/42, and rollout 3/9 are unchanged."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/recognition_transaction_contract_test.dart; bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings; bash ../tools/run_dart_project_data.sh test --reporter failures-only"
---

# Dormant Dart recognition-transaction boundary

The final-path consumer is
`dart/test_dormant/recognition_transaction_contract_test.dart`. Ordinary Dart
test discovery ignores that directory, while `analysis_options.yaml` excludes
only this file until the future private authority exists. The explicit
repository-routed invocation exits 1 solely at the missing private transaction
module and its three frozen public-to-package test types.

The consumer already owns the complete later integration boundary: UTF-16-safe
state snapshots, recursive mark isolation, exact neutral diagnostics, dedicated
non-eager authored forms, effect and progress policy, falsey payloads, native
and reconstructed execution, generated-plan execution, independently analyzed
emitted source, and ordinary cursor compatibility. This RED slice changes no
production Dart source, canonical registration, rollout row, or public support
claim.

Private authority leaf `.14.3.4.1` supplies the missing module and removes the
temporary analyzer exclusion. Integration `.14.3.4.2` then advances the next
RED inside the unchanged consumer; admission `.14.3.4.3` moves it to ordinary
discovery only after every frozen assertion is GREEN.

## Links

- Neutral contract: [[recognition-transaction-neutral-contract]].
- Rust precedent: [[rust-recognition-transaction-dormant-red]].
- Dart typed-source authority: [[dart-typed-source-location-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.4.0.1`; next owner `.14.3.4.1`.

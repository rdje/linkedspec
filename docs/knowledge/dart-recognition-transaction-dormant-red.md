---
id: dart-recognition-transaction-dormant-red
title: Dart recognition transactions are integrated privately and await admission
answers:
  - "where is the dormant Dart recognition transaction RED consumer"
  - "where is the private Dart recognition transaction authority"
  - "how do I run the Dart recognition transaction RED"
  - "how do I enable only the Dart recognition transaction integration RED"
  - "why does ordinary Dart test not discover recognition transactions"
  - "what is the next Dart recognition transaction failure"
  - "does Dart have dedicated recognition transaction ActionIR nodes"
  - "does Dart execute recognition transactions through generated and emitted carriers"
  - "which Dart recognition transaction API is frozen"
  - "does the Dart transaction RED cover UTF-16 state"
  - "does the Dart transaction RED cover emitted source"
  - "does the Dart recognition transaction RED change rollout or production behavior"
date: 2026-08-11
status: current private integration boundary; admission owned by FUTURE-PARITY-BACKLOG.14.3.4.3
tags: [dart, recognition, transaction, ActionIR, dormant, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.4.0.1 freezes dart/test_dormant/recognition_transaction_contract_test.dart; `.1` adds the unexported source-local authority; `.2` integrates four dedicated non-eager ActionIR nodes, static call(Rule) ownership, recursive effect closure, cursor-only progress, and live UTF-16 cursor/boundary/invocation-mark state. Native, serialized reconstruction, generated-plan, and freshly analyzed emitted-source carriers all route through LinkedSpecRuntimeEngine and preserve a successful false payload. LINKEDSPEC_DART_RECOGNITION_TRANSACTION_INTEGRATION_RED=1 now passes 10/10; default explicit execution remains 6 pass / 4 skipped. Fatal analysis is clean, ordinary discovery remains 383 tests, no canonical route names the dormant file, the private module has no facade export, and neutral 132/246/42 plus rollout 3/9 remain unchanged. The complete Dart gate passes format 100/0, ordinary 383, storage 21/47, CLI 66x2, and corpus 105. Admission and public promotion remain solely owned by `.14.3.4.3`."
reverify: "cd dart && env LINKEDSPEC_DART_RECOGNITION_TRANSACTION_INTEGRATION_RED=1 bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/recognition_transaction_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && bash ../tools/run_dart_project_data.sh test --reporter failures-only"
---

# Private Dart recognition-transaction integration boundary

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

The parser now replaces the four exact static forms with dedicated ActionIR
nodes. `recognize_once` stores only the token slot and static child-rule name,
so `call(Rule)` is never evaluated as an ordinary helper. Runtime invocation
entry/exit synchronizes the existing UTF-16 cursor registers, anonymous capture
boundary, and fresh same-label mark bucket through the private authority.
Effect graphs use the neutral recursive fixed point and progress accepts only
cursor advance on repetition/recursive edges.

Set `LINKEDSPEC_DART_RECOGNITION_TRANSACTION_INTEGRATION_RED=1` to prove all
ten frozen tests. Native, reconstructed, generated-plan, and emitted carriers
converge on `LinkedSpecRuntimeEngine`, so the same authority-backed behavior
preserves successful false payloads everywhere. Default execution deliberately
keeps the four integration tests skipped. Admission `.14.3.4.3` moves the
consumer to ordinary/canonical discovery and advances rollout; until then the
module stays unexported and Dart remains unavailable publicly.

## Links

- Neutral contract: [[recognition-transaction-neutral-contract]].
- Rust precedent: [[rust-recognition-transaction-dormant-red]].
- Dart typed-source authority: [[dart-typed-source-location-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.4.0.1-.2`; next owner `.14.3.4.3`.

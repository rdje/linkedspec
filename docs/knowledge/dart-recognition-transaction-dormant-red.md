---
id: dart-recognition-transaction-dormant-red
title: Dart recognition transactions are integrated privately and canonically admitted
answers:
  - "where is the admitted Dart recognition transaction consumer"
  - "how are Dart recognition transactions registered in canonical CI"
  - "are Dart recognition transactions publicly exported"
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
status: current private integrated and canonically admitted Dart boundary
tags: [dart, recognition, transaction, ActionIR, dormant, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.4.0.1 froze dart/test_dormant/recognition_transaction_contract_test.dart; `.1` added the unexported source-local authority; `.2` integrated four dedicated non-eager ActionIR nodes, static call(Rule) ownership, recursive effect closure, cursor-only progress, and live UTF-16 cursor/boundary/invocation-mark state. `.3` moves the same 10-test consumer to dart/test/recognition_transaction_contract_test.dart, removes only environment/skip dormancy, keeps the authority absent from the facade, and requires/logs/executes its exact project-data-routed command once in canonical CI. Thirteen mutations reject admission/privacy/dormancy drift. Native, serialized reconstruction, generated-plan, and freshly analyzed emitted-source carriers preserve a successful false payload. Recognition is 132/246/43, rollout neutral+Perl+Rust+Dart 4/9, public 3/14/29, and guide 1/6/10. Complete Dart passes format 100/0, ordinary 393, storage 21/47, CLI 66x2, and corpus 105. Julia and all later legs remain RED."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/recognition_transaction_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && cd .. && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
---

# Admitted private Dart recognition-transaction boundary

The final-path consumer is
`dart/test/recognition_transaction_contract_test.dart`. Ordinary Dart test
discovery and canonical CI execute it. The unexported
`dart/lib/src/runtime/recognition_transaction.dart` module now supplies the
frozen authority API, so strict analysis includes the consumer and its
repository-routed invocation passes all ten tests.

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

Native, reconstructed, generated-plan, and emitted carriers
converge on `LinkedSpecRuntimeEngine`, so the same authority-backed behavior
preserves successful false payloads everywhere. Admission `.14.3.4.3` removes
the dormant switch, registers the exact consumer once, and advances only Dart
to rollout 4/9. The module stays unexported; Julia and Lua remain unavailable.

## Links

- Neutral contract: [[recognition-transaction-neutral-contract]].
- Rust precedent: [[rust-recognition-transaction-dormant-red]].
- Dart typed-source authority: [[dart-typed-source-location-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.4.0.1-.3`; next owner `.14.3.5.0`.

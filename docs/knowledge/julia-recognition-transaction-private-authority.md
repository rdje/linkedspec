---
id: julia-recognition-transaction-private-authority
title: Julia recognition transactions have a private source-local authority but no authored integration
answers:
  - "where is the private Julia recognition transaction authority"
  - "how are Julia recognition transaction tokens stored"
  - "how does Julia isolate same-label recursive transaction marks"
  - "how does the private Julia transaction authority preserve falsey payloads"
  - "what state does private Julia transaction rollback restore"
  - "how does Julia invalidate escaped or reused recognition tokens"
  - "which test proves the private Julia recognition transaction authority"
  - "is the private Julia transaction authority exported"
  - "is the private Julia transaction authority in ordinary discovery"
  - "does the private Julia transaction authority make recognition syntax available"
  - "what is the next Julia recognition transaction RED failure"
date: 2026-08-11
status: current private foundation; authored integration and admission pending
tags: [julia, recognition, transaction, invocation, marks, token, snapshot, private, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.5.1 adds julia/src/runtime/RecognitionTransaction.jl as a non-exported module included after the existing SourceLocation authority. One source-local mutable authority owns monotonic non-reused invocation, mark, and transaction generations; opaque frame/token handles; immutable copied cursor/boundary/mark state; detached snapshots; separately staged match/payload state; exactly-one attempt and terminal; and restore-before-invalidate misuse handling. The explicit frozen authority consumer passes 155/155 across recursive same-label isolation, eight falsey-safe positive cases, eight escape classes, attempt/lifecycle/cross-owner errors, exact restoration, discard, and unwind. Complete ordinary Julia remains green with typed source 127/127, storage 19/5, primary CLI, and corpus 105/105. Definitive canonical signoff passes all eight doctrines, CLI 66x2, RAM 68%, and Phase 0 1,031/1,031 in 747 seconds. RecognitionTransaction is absent from the LinkedSpecJulia export list and the final-path consumer remains absent from ordinary/canonical discovery. Integration mode first fails because the four authored calls remain generic rather than dedicated ActionIR nodes; policy and runtime integration remain FUTURE-PARITY-BACKLOG.14.3.5.2."
reverify: "test \"$(rg -c '^include\\(\"runtime/RecognitionTransaction[.]jl\"\\)$' julia/src/LinkedSpecJulia.jl)\" = 1 && ! sed -n '1,/^const BACKEND_NAME/p' julia/src/LinkedSpecJulia.jl | rg -q 'RecognitionTransaction' && LINKEDSPEC_JULIA_RECOGNITION_TRANSACTION_RED_MODE=authority bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/recognition_transaction_contract_test.jl\")'"
---

# Private Julia recognition-transaction authority

`julia/src/runtime/RecognitionTransaction.jl` is the private state foundation
for the later Julia integration leaf. `LinkedSpecJulia.jl` includes the module
after `SourceLocation.jl` but does not export it. The dormant final-path
consumer reaches it explicitly for direct proof; ordinary and canonical test
discovery still omit that consumer.

One source-local authority owns fresh invocation, mark, and transaction
generations. Callers receive opaque frame and token handles while private
mutable records retain ownership and lifecycle state. Frame values copy only
the native cursor, nullable anonymous boundary, and invocation-local named
marks. Snapshots and diagnostic records are fresh detached dictionaries.

A checkpoint binds its exact source authority, invocation, generation, rule,
origin, and starting frame state. Attempt presence and payload are separate, so
`false`, zero, an empty string, and `nothing` survive successful commit without
becoming misses. Commit retains staged state; rollback, discard, escape,
cross-owner misuse, retry, forbidden nesting, and invocation unwind restore the
snapshot before invalidating the token. Terminal invalidation is monotonic, so
reuse cannot reactivate a transaction.

The frozen authority mode passes 155 assertions. This is private foundation,
not authored transaction support: the parser still produces ordinary call
nodes, the effect/progress classifiers do not exist, runtime dispatch rejects
`recognition_checkpoint`, and rollout remains 4/9. Integration is owned only by
`.14.3.5.2`; admission remains `.14.3.5.3`.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Dormant end-to-end boundary: [[julia-recognition-transaction-dormant-red]].
- Julia typed-source owner: [[typed-source-location-runtime-rollout-plan]].
- Dart precedent: [[dart-recognition-transaction-dormant-red]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.5.1`.

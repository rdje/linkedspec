---
id: julia-recognition-transaction-private-authority
title: Julia recognition transactions use a private source-local authority under admitted execution
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
status: current private foundation consumed by ordinary and canonical admitted execution
tags: [julia, recognition, transaction, invocation, marks, token, snapshot, private, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.5.1 adds julia/src/runtime/RecognitionTransaction.jl as a non-exported module included after the existing SourceLocation authority. One source-local mutable authority owns monotonic non-reused invocation, mark, and transaction generations; opaque frame/token handles; immutable copied cursor/boundary/mark state; detached snapshots; separately staged match/payload state; exactly-one attempt and terminal; and restore-before-invalidate misuse handling. `.2` consumes it through dedicated ActionIR, effect/progress policy, and one runtime adapter. Admission `.3` registers the unchanged 203-assertion consumer ordinarily and canonically but still rejects facade export, so execution is current without making the authority public."
reverify: "test \"$(rg -c '^include\\(\"runtime/RecognitionTransaction[.]jl\"\\)$' julia/src/LinkedSpecJulia.jl)\" = 1 && ! sed -n '1,/^const BACKEND_NAME/p' julia/src/LinkedSpecJulia.jl | rg -q 'RecognitionTransaction' && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/recognition_transaction_contract_test.jl\")'"
---

# Private Julia recognition-transaction authority

`julia/src/runtime/RecognitionTransaction.jl` is the private state foundation
for Julia's admitted integration. `LinkedSpecJulia.jl` includes the module
after `SourceLocation.jl` but does not export it. The dormant final-path
consumer reaches it explicitly for direct proof; ordinary and canonical test
discovery now run that consumer exactly once.

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

The pre-admission authority selector passed 155 assertions. Private integration
consumes this foundation through four dedicated nodes, effect/progress policy,
and one runtime adapter; the admitted consumer now always runs all 203
assertions. Authored Julia support is current at rollout 5/9, but the namespace
remains deliberately unexported.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Dormant end-to-end boundary: [[julia-recognition-transaction-dormant-red]].
- Julia typed-source owner: [[typed-source-location-runtime-rollout-plan]].
- Dart precedent: [[dart-recognition-transaction-dormant-red]].
- Integration: [[julia-recognition-transaction-integration]].
- Admission: [[julia-recognition-transaction-admission]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.5.1`.

---
id: julia-recognition-transaction-dormant-red
title: Dormant Julia recognition-transaction RED was the admission prerequisite
answers:
  - "where is the dormant Julia recognition transaction RED consumer"
  - "how do I run the Julia recognition transaction RED"
  - "why does ordinary Julia test discovery omit recognition transactions"
  - "what is the first Julia recognition transaction failure"
  - "which Julia recognition transaction API is frozen"
  - "does the Julia transaction RED preserve code-unit registers"
  - "does the Julia transaction RED cover emitted source"
  - "does the Julia transaction RED allocate temporary storage"
  - "does the Julia recognition transaction RED change rollout or production behavior"
date: 2026-08-11
status: historical prerequisite completed by FUTURE-PARITY-BACKLOG.14.3.5.3 admission
tags: [julia, recognition, transaction, ActionIR, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.5.0 added julia/test/recognition_transaction_contract_test.jl at its final path but omitted it from ordinary/canonical discovery. `.1` supplied the non-exported source-local authority at 155/155, and `.2` integrated four dedicated non-eager nodes, recursive effect closure, cursor-only progress, and all four carriers at 203/203. Admission `.14.3.5.3` removes both selector modes and conditional dormancy, includes the same consumer exactly once ordinarily/canonically, retains the unexported authority, and promotes only Julia to rollout 5/9."
reverify: "test \"$(rg -c '^include\\(\"recognition_transaction_contract_test[.]jl\"\\)$' julia/test/runtests.jl)\" = 1 && ! rg -n 'LINKEDSPEC_JULIA_RECOGNITION_TRANSACTION_RED_MODE|JULIA_RECOGNITION_TRANSACTION_RED_MODE' julia/test/recognition_transaction_contract_test.jl && rg -n 'julia/test/recognition_transaction_contract_test[.]jl' tools/run_ci_local.sh"
---

# Dormant Julia recognition-transaction boundary

The final-path consumer is `julia/test/recognition_transaction_contract_test.jl`. Before admission, Julia package
discovery and canonical CI deliberately omitted it while explicit `authority` and `integration` selector modes
proved the private seams. Admission `.14.3.5.3` removes those selectors and runs all 203 assertions in ordinary
package discovery and canonical CI while the private namespace remains unexported.

The consumer freezes the complete later path now: invocation and mark generations, opaque linear tokens, detached
state, falsey payloads, exact misuse diagnostics, four non-eager nodes, recursive effect closure, cursor-only
progress, native and reconstructed runtime, generated plans, independently loaded emitted source, and unchanged
cursor controls. Emitted proof uses a fresh module with `Base.include_string`, so the dormant test creates no
project-data owner and cannot bypass the repository storage policy.

Private authority `.14.3.5.1` supplied the non-exported namespace. Integration `.14.3.5.2` closed the nested
node/policy/runtime/carrier assertions. Admission `.14.3.5.3` then removed dormancy, registered the unchanged
consumer exactly once, and advanced only Julia's rollout row.

## Links

- Neutral contract: [[recognition-transaction-neutral-contract]].
- Julia typed-source authority: [[typed-source-location-runtime-rollout-plan]].
- Dart precedent: [[dart-recognition-transaction-dormant-red]].
- Integration: [[julia-recognition-transaction-integration]].
- Current admission: [[julia-recognition-transaction-admission]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.5.0-.3`.

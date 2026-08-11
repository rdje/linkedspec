---
id: julia-recognition-transaction-dormant-red
title: Julia recognition transactions are frozen behind one missing private namespace
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
status: current dormant boundary owned by FUTURE-PARITY-BACKLOG.14.3.5.1
tags: [julia, recognition, transaction, ActionIR, RED, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.5.0 adds julia/test/recognition_transaction_contract_test.jl at its final path but omits it from julia/test/runtests.jl and canonical registration. Explicit authority and integration modes both parse fully and exit 1 solely at UndefVarError: RecognitionTransaction not defined in LinkedSpecJulia. The consumer freezes private authority generations, opaque frames/tokens, detached cursor/boundary/mark snapshots, falsey-safe match/payload separation, exact terminal restoration, eight token escapes and lifecycle/cross-owner diagnostics, four dedicated non-eager ActionIR nodes, recursive effect closure, cursor-only progress, native/reconstructed/generated-plan execution, an independently loaded Base.include_string emitted module, and ordinary cursor compatibility. It uses no filesystem temporary workspace. Complete signoff passes storage 19/5, all eight doctrines, transaction/typed-source/MCP/semantic admissions, containment/relocation, CLI 66x2, RAM 60%, and Phase 0 1,031/1,031 in 724 seconds. Production, UTF-8 code-unit registers/results, neutral 132/246/43, and rollout 4/9 are unchanged."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'source = read(\"julia/test/recognition_transaction_contract_test.jl\", String); @assert Meta.parseall(source) isa Expr' && LINKEDSPEC_JULIA_RECOGNITION_TRANSACTION_RED_MODE=authority bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/recognition_transaction_contract_test.jl\")'"
---

# Dormant Julia recognition-transaction boundary

The final-path consumer is `julia/test/recognition_transaction_contract_test.jl`. Julia package discovery is the
explicit include list in `julia/test/runtests.jl`; that list and canonical CI deliberately omit this file until
admission. The repository-routed `authority` and `integration` selections both load the neutral fixture and then
exit 1 solely because private `LinkedSpecJulia.RecognitionTransaction` does not exist.

The consumer freezes the complete later path now: invocation and mark generations, opaque linear tokens, detached
state, falsey payloads, exact misuse diagnostics, four non-eager nodes, recursive effect closure, cursor-only
progress, native and reconstructed runtime, generated plans, independently loaded emitted source, and unchanged
cursor controls. Emitted proof uses a fresh module with `Base.include_string`, so the dormant test creates no
project-data owner and cannot bypass the repository storage policy.

Private authority `.14.3.5.1` supplies the missing non-exported namespace and makes only authority mode green.
Integration `.14.3.5.2` then closes the nested node/policy/runtime/carrier assertions in the unchanged consumer;
admission `.14.3.5.3` removes the selector and includes the exact final-path file ordinarily and canonically.

## Links

- Neutral contract: [[recognition-transaction-neutral-contract]].
- Julia typed-source authority: [[typed-source-location-runtime-rollout-plan]].
- Dart precedent: [[dart-recognition-transaction-dormant-red]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.5.0`; next owner `.14.3.5.1`.

---
id: julia-recognition-transaction-admission
title: Julia recognition transactions remain admitted through one private 207-assertion consumer
answers:
  - "are recognition transactions current on Julia"
  - "where is the admitted Julia recognition transaction consumer"
  - "how does ordinary Julia discover recognition transaction tests"
  - "how does canonical CI run Julia recognition transactions"
  - "is the Julia recognition transaction authority exported"
  - "how many Julia recognition transaction assertions run"
  - "how many Julia admission mutations are rejected"
  - "what is the recognition transaction rollout after Julia admission"
  - "which recognition transaction backend is next after Julia"
date: 2026-08-11
status: current admitted Julia execution; private authority retained; Lua admitted; recurring next
tags: [julia, recognition, transaction, admission, discovery, canonical, private, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.5.3 includes julia/test/recognition_transaction_contract_test.jl exactly once from julia/test/runtests.jl and requires/logs/executes its repository-routed canonical command exactly once. It ran 203 assertions at Julia admission, 205 after both Lua runtime rows, and now runs 207 after recurring and public no-drift promotion; authority, dedicated ActionIR, effect/progress, native, reconstructed, generated-plan, and emitted behavior are unchanged. The consumer explicitly reaches the private namespace, which remains absent from exports. Fourteen mutations reject discovery/canonical omission or duplication, dormancy residue, private-lookup removal, and facade export. Neutral truth is now 129 current + four dedicated nodes / 246 calls / 58 mutations at rollout 9/9; public governance is 3/26/45 and guide governance is 1/14/18."
reverify: "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/recognition_transaction_contract_test.jl\")'"
---

# Admitted Julia recognition transactions

Julia package discovery includes `recognition_transaction_contract_test.jl`
exactly once, and canonical CI requires the tracked path plus one exact
repository-routed invocation. The file has no selector environment variable,
skip path, or conditional integration testset; every run executes all 207
assertions (203 at its own admission, two Lua-row assertions, then recurring and public no-drift assertions).

Admission changes proof and governed availability, not the implementation.
The consumer still reaches the source-local authority explicitly, and
`LinkedSpecJulia` does not export that namespace. Native UTF-8 code-unit
registers/results and native, reconstructed, generated-plan, and emitted
carrier behavior remain the same private integration proved by `.14.3.5.2`.

Neutral rollout, recurring composition, and final public no-drift are complete at 9/9.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Historical RED: [[julia-recognition-transaction-dormant-red]].
- Private authority: [[julia-recognition-transaction-private-authority]].
- Integration: [[julia-recognition-transaction-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.5.3`.

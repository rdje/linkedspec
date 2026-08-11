---
id: julia-recognition-transaction-admission
title: Julia recognition transactions remain admitted through one private 205-assertion consumer
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
evidence: "FUTURE-PARITY-BACKLOG.14.3.5.3 includes julia/test/recognition_transaction_contract_test.jl exactly once from julia/test/runtests.jl and requires/logs/executes its repository-routed canonical command exactly once. It ran 203 assertions at Julia admission and now runs 205 after asserting both promoted Lua rollout rows; authority, dedicated ActionIR, effect/progress, native, reconstructed, generated-plan, and emitted behavior are unchanged. The consumer explicitly reaches the private namespace, which remains absent from exports. Fourteen mutations reject discovery/canonical omission or duplication, dormancy residue, private-lookup removal, and facade export. Neutral truth is now 132/246/46 at rollout 7/9; public governance is 3/20/38 and guide governance is 1/10/14."
reverify: "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/recognition_transaction_contract_test.jl\")'"
---

# Admitted Julia recognition transactions

Julia package discovery includes `recognition_transaction_contract_test.jl`
exactly once, and canonical CI requires the tracked path plus one exact
repository-routed invocation. The file has no selector environment variable,
skip path, or conditional integration testset; every run executes all 205
assertions (203 at its own admission plus two current Lua-row assertions).

Admission changes proof and governed availability, not the implementation.
The consumer still reaches the source-local authority explicitly, and
`LinkedSpecJulia` does not export that namespace. Native UTF-8 code-unit
registers/results and native, reconstructed, generated-plan, and emitted
carrier behavior remain the same private integration proved by `.14.3.5.2`.

Neutral rollout is complete through PUC Lua and LuaJIT. Recurring composition
and final public no-drift remain RED.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Historical RED: [[julia-recognition-transaction-dormant-red]].
- Private authority: [[julia-recognition-transaction-private-authority]].
- Integration: [[julia-recognition-transaction-integration]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.5.3`.

---
id: julia-actionir-contract-resolver
title: Julia resolves typed ActionIR nodes against the current helper contract table
answers:
  - does Julia resolve ActionIR helper contracts
  - where is the Julia ActionIR contract resolver
  - does Julia encode non-current helper spellings
  - how does Julia classify non-current helper calls
  - does Julia reserve built-in helper names for functions
date: 2026-07-10
status: current
tags: [julia, actionir, contracts, helper-surface, validation, backend]
evidence: "JULIA-BACKEND-PARITY.3.2 adds julia/src/action/ActionContracts.jl and focused tests in julia/test/runtests.jl. The resolver entrypoints walk typed ActionIR calls, receiver methods, structural assignments, structured controls, nested arguments, block values, shapes, and access expressions, recording current canonical helper/control contracts. Non-current helper-looking calls produce unknown_helper, and raw fallback nodes produce raw_perl diagnostics. julia/src/spec/Validator.jl now shares is_known_action_ir_call_name(...) so user functions collide with active built-in helper/control names. Function-registry-aware user-call classification remains deferred to JULIA-BACKEND-PARITY.3.3."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

## Fact

Julia ActionIR contract resolution lives in `julia/src/action/ActionContracts.jl`.

Public resolver entrypoints:

- `resolve_action_block_contracts(...)`
- `resolve_action_statement_contracts(...)`
- `resolve_action_expression_contracts(...)`
- `canonical_action_helper_name(...)`
- `is_known_action_ir_call_name(...)`

The resolver records current canonical helper/control contracts from typed ActionIR nodes: function calls, receiver
methods, structural assignments, structured controls, nested arguments, block values, shape literals, and direct
access expressions. It does not carry a compatibility table for non-current helper spellings. Helper-looking names
outside the current contract table produce the generic `unknown_helper` diagnostic; `raw_perl` fallback nodes stay
explicit diagnostics.

`julia/src/spec/Validator.jl` shares the same current-name table for user-function registry collision checks, so
validation no longer maintains a second helper list.

Function-registry-aware exact-arity user-call classification is not part of `.3.2`; it is owned by
`JULIA-BACKEND-PARITY.3.3`.

Related facts: [[julia-action-ast-parser]], [[dart-actionir-contract-resolver]],
[[dart-actionir-ast-parser]], [[text-to-ast-backend-doctrine]].

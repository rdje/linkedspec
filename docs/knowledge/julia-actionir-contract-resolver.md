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
evidence: "JULIA-BACKEND-PARITY.3.2 adds julia/src/action/ActionContracts.jl and focused tests in julia/test/runtests.jl. The resolver entrypoints walk typed ActionIR calls, receiver methods, structural assignments, structured controls, nested arguments, block values, shapes, and access expressions, recording current canonical helper/control contracts. Non-current helper-looking calls produce unknown_helper, and raw fallback nodes produce raw_perl diagnostics. julia/src/spec/Validator.jl now shares is_known_action_ir_call_name(...) so user functions collide with active built-in helper/control names. JULIA-BACKEND-PARITY.3.3 adds optional UserFunctionRegistry input so exact-arity user calls classify before helper fallback while wrong-arity registered calls diagnose as user_function_arity_mismatch."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
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

**Historical .3.3 boundary:** when callers pass `function_registry`, the resolver checked exact-arity user calls before helper fallback and recorded
them as `family = "user_function"`. If the name is registered but the arity is wrong, the resolver emits
`user_function_arity_mismatch` instead of treating the call as an unknown helper.

Related facts: [[julia-action-ast-parser]], [[julia-user-function-registry]],
[[dart-actionir-contract-resolver]], [[dart-actionir-ast-parser]], [[text-to-ast-backend-doctrine]].

## September 11 source reconciliation

Current registered calls classify first with fixed or variadic minimum arity and keyword rejection; callable
bindings resolve next, then canonical helper fallback. Known builtins record argument counts and families;
recognition by this resolver does not establish complete generic builtin-arity enforcement.
Explicit/contextual callable bodies stay deferred for eager helper dependencies. Attached switches, however,
can omit retained body content from contract traversal: [[julia-attached-switch-body-omission]] owns exact
causal evidence and pending repair .2.2. Existing parser 74 / resolver 40 and callable 482 assertions pass.

## September 11 complete parser/resolver consumer reading (.1.42)

The main parser testset1136–1264 passes 74 assertions; resolver1266–1331 passes
40. Typed literals, nested writes, assignment receivers, trailing blocks and
attached controls are checked structurally. Resolver checks canonical aliases,
assignment families, unknown/raw diagnostics and builtin-name collisions.
Parsing a switch node does not prove complete body traversal or execution;
[[julia-attached-switch-body-omission]] remains open. No new arity or callable
selector guarantee follows. Replay: [[julia-runtime-rule-interpreter]], .1.42.

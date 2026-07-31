---
id: julia-generic-final-codeblock-gap
title: Julia generic final-codeblock normalization uses metadata projection and one post-registry seam
answers:
  - "why does Julia not support generic contextual final codeblock arguments"
  - "does Julia preserve callback codeblock parameter kinds"
  - "where does Julia hard code receiver trailing block names"
  - "does Julia distinguish attached and parenthesized contextual blocks"
  - "what owns FUTURE-PARITY-BACKLOG 11.6.3"
date: 2026-07-30
status: current implementation; completed by FUTURE-PARITY-BACKLOG.11.6.3
tags: [julia, actionir, codeblock, callable-contract, trailing-block, user-functions, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "Baseline probes on clean bc85c0fa exposed missing fixed_params/codeblock_param/parameter_kinds projection, a four-name receiver parser allowlist, and no codeblock_argument normalizer. FUTURE-PARITY-BACKLOG.11.6.3 now preserves final-only metadata through definition/staged/registry/descriptor/semantic state, parses receiver attachment generically, and applies one post-registry CallableContract.jl pass. Focused proof passes 125 dynamic + 118 contextual + 239 construction assertions across native, reconstructed, generated-plan, and freshly loaded emitted Julia; the complete package passes."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/callable_codeblock_literal_contract_test.jl\")'"
---

# Julia Generic Final-Codeblock Normalization

The shared `specs/user_function_definition.spec` returns a final-only typed declaration as `fixed_params`,
`codeblock_param`, and the sole `parameter_kinds` entry. Julia now projects that exact record through the
definition shell, both staged sidecars, validator, registry, version-3 descriptor, generated effective spec, and
semantic signature. Definition, payload, and job metadata are correlated independently so malformed reconstructed
state cannot silently grant a typed callback slot.

Function-surface attached blocks retain `trailing_block_arg`; parenthesized immediate blocks remain
`ActionBlockValueExpr`; attached controls parse before ordinary calls. Receiver attachment is now recognized
without a method-name allowlist, but syntax alone grants no semantics. `CallableContract.jl` combines builtin
helper/receiver contracts with the complete user-function registry, rejects unknown attached calls and wrong
pre-block arity, and converts only an admitted final immediate block into the neutral zero-positional
`ActionCodeblockArgumentExpr`. Ordinary parenthesized blocks remain eager.

Runtime helper/receiver `with`, typed user functions, and hash/array tree traversal validate a plain final
codeblock value and reuse the `.11.6.2` dynamic executor. Contextual blocks invoke it with zero positional values
and read scoped dynamic bindings; explicit codeblock values keep their authored signatures. Native, compiled-JSON
reconstruction, generated plans, and independently loaded emitted source all compile through the same normalizer
and execute through the same interpreter. No Julia closure, host callback, or second executor exists.

Related facts: [[final-codeblock-parameter-declaration]], [[julia-callable-codeblock-dynamic-invocation]],
[[dart-generic-final-codeblock-gap]], [[rust-generic-final-codeblock-normalization]],
[[julia-user-function-definition-projection]], [[julia-user-function-registry]].

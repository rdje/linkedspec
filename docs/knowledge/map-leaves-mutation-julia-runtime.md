---
id: map-leaves-mutation-julia-runtime
title: Julia preserves map_leaves bang as one typed identity-guarded receiver mutation through every supported route
answers:
  - how does Julia implement map_leaves bang
  - does Julia preserve map_leaves bang as typed ActionIR
  - does generated Julia execute map_leaves bang
  - does emitted Julia execute map_leaves bang
  - does the Julia primary CLI execute map_leaves bang
  - how does Julia identify the active map_leaves bang receiver
  - which Julia writes are blocked inside a map_leaves bang callback
  - can Julia map_leaves bang mutate callback leaves
  - can Julia map_leaves bang mutate its receiver directly
  - does Julia map_leaves bang preserve unrelated callback effects
  - does Julia map_leaves bang commit before continuation
  - are Julia map_leaves bang aggregate boundaries detached
  - how does Julia reject corrupt receiver mutation state
date: 2026-09-03
status: implemented under FUTURE-PARITY-BACKLOG.19.5.2; Lua and portable/public admission pending
tags: [julia, dsl, actionir, map-leaves, mutation, identity, atomicity, generated-source, cli, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.5.2 adds ActionReceiverMutationChainExpr with typed receiver, mutation, callback ActionBlock, and continuation carriers plus fail-closed validation at compiler, direct runtime, generated-plan, and source-emitter boundaries. Stable visible-binding identities guard the resolved receiver before direct, nested, nested-bang, helper, array-end, regex-substitution, or binding-target-pipeline operands run; callback scopes and function parameters get fresh identities. The permanent 496-assertion suite projects 4 valid / 14 invalid / 5 excluded syntax cases, executes all 10 success and 8 failure rows by stable ID, and covers statement-position commit, root-kind traversal, copied frames, detachment, composition, all 18 pre-evaluation guards, malformed receiver/kind state, SpecFile reconstruction, native/generated-plan/emitted-module/primary-CLI routes, and the zero-regex Top/child-regex dispatch interpretation. The unchanged neutral oracles reject 167 base plus 592 composition mutations."
reverify: "bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include(\"julia/test/map_leaves_mutation_contract_test.jl\")'"
---

# Julia `map_leaves!` receiver mutation

Julia parses only `IDENTIFIER.map_leaves!() { ACTION_BLOCK } CONTINUATION*` as a dedicated
`ActionReceiverMutationChainExpr`. The exclamation mark belongs to that one method token; ordinary identifiers,
function calls, other methods, bang continuations, literals, temporaries, properties, and nested receivers do not
gain bang syntax. The typed receiver, mutation, callback `ActionBlock`, continuation, exact authored source, and
half-open Unicode-scalar spans survive contract/callable/semantic traversal, `SpecFile` reconstruction, compiler
validation, generated plans, source emission, and direct runtime entry.

Every visible runtime binding has a stable identity across ordinary writes. Callback scopes and user-function
parameters receive fresh identities and restore any shadowed identity afterward. Consequently a callback may
mutate a detached leaf through `value[...]` and may mutate an unrelated binding; it may not assign, append,
nested-write, nested-bang, call a mutation helper, use an array-end method, run regex substitution, or invoke a
binding-target pipeline through the active receiver identity. Each write owner rejects before evaluating its
operand, path segment, or RHS. A same-spelling function parameter remains legal because it resolves separately.

Execution copies the existing harray or array and traverses only that original shape. Harray roots recurse through
harrays in sorted-key order; array roots recurse through arrays in index order; cross-kind aggregates are leaves.
Each callback receives detached `value`, complete copied `path`, `depth`, and `key` or `index`. Its copied result
replaces the leaf and is not revisited. Callback or re-entrant failure publishes no rebuilt receiver and always
releases the guard, while already-completed ordinary effects on unrelated bindings remain.

Complete success publishes one copied root, releases the guard, returns a separate copy, and then evaluates
ordinary fluent continuation. A later continuation failure cannot roll back that receiver commit. Native,
reconstructed, validated generated-plan, independently included emitted-module, and primary-CLI routes share the
same interpreter and carrier. Malformed programmatic state fails as
`receiver_mutation_serialized_state_invalid` before execution.

The permanent fixture deliberately uses `Top:: -> Done` with no regex on `Top`. Entering `Top` starts its loop;
the outgoing edge selects and matches `Done`'s regex. A regex owned by `Top` would not participate in that edge.

Related: [[map-leaves-mutation-neutral-contract]], [[write-map-leaves-neutral-composition]],
[[write-vivification-julia-runtime]], and ADR `0036`.

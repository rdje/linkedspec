---
id: map-leaves-mutation-lua-runtime
title: Lua preserves map_leaves bang as one typed identity-guarded receiver mutation on both ABIs
answers:
  - how does Lua implement map_leaves bang
  - does Lua preserve map_leaves bang as typed ActionIR
  - does generated Lua execute map_leaves bang
  - does emitted Lua execute map_leaves bang
  - does the Lua primary CLI execute map_leaves bang
  - does map_leaves bang work inside a Lua user function
  - how does Lua identify the active map_leaves bang receiver
  - which Lua writes are blocked inside a map_leaves bang callback
  - can Lua map_leaves bang mutate callback leaves
  - can Lua map_leaves bang mutate its receiver directly
  - does Lua map_leaves bang preserve unrelated callback effects
  - does Lua map_leaves bang commit before continuation
  - are Lua map_leaves bang aggregate boundaries detached
  - how does Lua reject corrupt receiver mutation state
date: 2026-09-04
status: implemented under FUTURE-PARITY-BACKLOG.19.6.2 on PUC Lua and LuaJIT; portable capability admitted under .19.7
tags: [lua, luajit, dsl, actionir, map-leaves, mutation, identity, atomicity, generated-source, cli, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.6.2 adds receiver_mutation_chain with typed binding_reference, receiver_mutation_call, block_value callback, and fluent_call continuation carriers plus fail-closed validation at compiler, direct runtime, generated-plan, and source-emitter boundaries. Stable visible-binding identities guard the resolved receiver before direct, nested, nested-bang, helper, array-end, regex-substitution, or binding-target-pipeline operands run; callback scopes and function parameters get fresh identities. The permanent 530-assertion suite runs unchanged on PUC Lua and LuaJIT, projects 4 valid / 14 invalid / 5 excluded syntax cases, executes all 10 success and 8 failure rows by stable ID, and covers statement-position commit, root-kind traversal, user-function bodies, copied frames, detachment, all 18 pre-evaluation guards, malformed state including top-level kind corruption, public SpecFile reconstruction, native/generated-plan/emitted-module/primary-CLI routes, all six callback and one continuation compositions, and zero-regex Top/child-regex dispatch. The unchanged oracles reject 167 base plus 592 composition mutations; the full Lua local gate passes on both ABIs."
reverify: "bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && bash tools/run_lua_project_data.sh puc lua/test/map_leaves_mutation_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/map_leaves_mutation_contract_test.lua && bash tools/run_lua_local.sh"
---

# Lua `map_leaves!` receiver mutation

Lua parses only `IDENTIFIER.map_leaves!() { ACTION_BLOCK } CONTINUATION*` as a dedicated
`receiver_mutation_chain`. The exclamation mark belongs to that one method token; ordinary identifiers,
function calls, other methods, bang continuations, literals, temporaries, properties, and nested receivers do not
gain bang syntax. The typed receiver, mutation call, callback block, continuation, exact authored source, and
half-open Unicode-scalar spans survive contract/static traversal, public `SpecFile` reconstruction, compiler
validation, generated plans, source emission, direct runtime entry, and staged user-function bodies.

Every visible runtime binding has a stable identity across ordinary writes. Callback scopes and user-function
parameters receive fresh identities and restore any shadowed identity afterward. Consequently a callback may
nested-write its detached `value` and may mutate an unrelated binding; it may not assign, append, nested-write,
nested-bang, call a mutation helper, use an array-end method, run regex substitution, or invoke a binding-target
pipeline through the active receiver identity. Each write owner rejects before evaluating its operand, path
segment, or RHS. A same-spelling function parameter remains legal because it resolves to a distinct identity.

Execution copies the existing harray or array and traverses only that original shape. Harray roots recurse through
harrays in sorted-key order; array roots recurse through arrays in index order; cross-kind aggregates are leaves.
Each callback receives detached `value`, complete copied `path`, `depth`, and `key` or `index`. Its copied result
replaces the leaf and is not revisited. Callback or re-entrant failure publishes no rebuilt receiver and always
releases the guard, while already-completed ordinary effects on unrelated bindings remain.

Complete success publishes one copied root, releases the guard, returns a separate copy, and only then evaluates
ordinary fluent continuation. A continuation failure cannot roll back that receiver commit. Native,
reconstructed, generated-plan, independently loaded emitted-module, primary-CLI, and user-function-body routes
share this carrier on PUC Lua and LuaJIT. Malformed programmatic state fails as
`receiver_mutation_serialized_state_invalid` before execution.

The permanent fixture deliberately uses `Top:: -> Done` with no regex on `Top`. Entering `Top` starts its loop;
the outgoing edge selects and matches `Done`'s regex. A regex owned by `Top` would not participate in that edge.

Related: [[map-leaves-mutation-neutral-contract]], [[write-map-leaves-neutral-composition]],
[[write-vivification-lua-runtime]], [[lua-interpreter-local-variable-ceiling]], and ADR `0036`.

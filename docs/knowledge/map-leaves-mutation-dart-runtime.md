---
id: map-leaves-mutation-dart-runtime
title: "Dart preserves map_leaves bang as one typed identity-guarded receiver mutation through every generated route"
answers:
  - "how does Dart implement map_leaves bang"
  - "does Dart preserve map_leaves bang as typed ActionIR"
  - "does generated Dart execute map_leaves bang"
  - "does emitted Dart execute map_leaves bang"
  - "does the Dart primary CLI execute map_leaves bang"
  - "how does Dart identify the active map_leaves bang receiver"
  - "which Dart writes are blocked inside a map_leaves bang callback"
  - "does Dart map_leaves bang preserve unrelated callback effects"
  - "does Dart map_leaves bang commit before continuation"
  - "are Dart map_leaves bang aggregate boundaries detached"
  - "how does Dart reject corrupt receiver mutation state"
date: 2026-09-02
status: implemented under FUTURE-PARITY-BACKLOG.19.4.2; Julia also implemented, Lua nested writes implemented, Lua bang and portable/public admission pending
tags: [dart, dsl, actionir, map-leaves, mutation, identity, atomicity, generated-source, cli, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.4.2 adds ActionReceiverMutationChainExpr with typed receiver, callback, and continuation carriers plus compiled-state validation at compiler, direct engine, source-emitter, and generated-plan boundaries. Stable scoped binding identities guard the resolved receiver before direct, nested, nested-bang, helper, array-end, or binding-target-pipeline operands run. The permanent 11-test contract projects 4 valid / 14 invalid / 5 excluded syntax cases, all frozen behavior and composition boundaries, malformed-state rejection, SpecFile reconstruction, native/generated-plan/emitted-source/independently executed/primary-CLI routes, and the unchanged neutral oracle rejects 167 base plus 592 composition mutations. The full Dart package passes 461 tests; project storage registers 25 temporary owners and 47 locked packages."
evidence_update_2026_09_03_julia_implementation: "FUTURE-PARITY-BACKLOG.19.5.2 implements the same unchanged typed identity-guarded receiver mutation on Julia. Dart behavior and its permanent proof remain unchanged; only Lua and portable/public admission remain pending."
reverify: "bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && (cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/map_leaves_mutation_contract_test.dart) && bash tools/run_dart_local.sh"
---

# Dart `map_leaves!` receiver mutation

Dart parses only `IDENTIFIER.map_leaves!() { ACTION_BLOCK } CONTINUATION*` as a dedicated
`ActionReceiverMutationChainExpr`. Its typed receiver, mutation call, callback `ActionBlock`, ordinary non-bang
continuation, exact authored source, and half-open Unicode-scalar spans survive contract resolution, callable
normalization, `SpecFile` reconstruction, compiled-state validation, generated plans, source emission, and direct
runtime entry. Malformed programmatic carriers fail closed as
`receiver_mutation_serialized_state_invalid`.

Each visible runtime binding has a stable identity across ordinary writes. Callback scopes and user-function
parameters receive fresh identities and restore the prior identity afterward, so a parameter named `tree` is not
the guarded outer `tree`. During callback execution, assignment, append, nested write, nested `map_leaves!`,
mutation helpers, array-end methods, and binding-target pipelines fail only when their resolved identity matches
the active receiver. The check happens before target segments, operands, or RHS expressions.

Execution copies the existing harray or array and traverses only that original-shape snapshot. Harray roots recurse
through harrays in sorted-key order; array roots recurse through arrays in index order; cross-kind aggregates are
leaves. Each callback receives detached `value`, complete `path`, `depth`, and `key` or `index`. Its copied result
replaces the leaf without being revisited. Callback or re-entrant failure publishes no rebuilt receiver and always
releases the guard, while already-completed ordinary effects on unrelated bindings retain their normal semantics.

After all callbacks succeed, Dart publishes one copied root, releases the guard, returns a separately copied
updated root, and only then executes ordinary fluent continuation. A continuation failure therefore cannot roll
back the completed receiver commit. Native execution, reconstructed `SpecFile`, validated generated plan, emitted
source independently analyzed/executed by a fresh caller package, and the primary CLI share these semantics.

The required composed-boundary audit also corrected an inert parent `/x/` in the frozen control to the established
zero-regex `Top:: -> Done` shape: entering `Top` runs its loop, while `Done` owns and matches `/[a-z]+/`. This is a
fixture repair, not a mutation-semantic change.

Related: [[map-leaves-mutation-neutral-contract]], [[write-map-leaves-neutral-composition]],
[[write-vivification-dart-runtime]], and ADR `0036`.

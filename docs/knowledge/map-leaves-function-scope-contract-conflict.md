---
id: map-leaves-function-scope-contract-conflict
title: "Two future map_leaves bang composition cases conflict with pure function-local binding scope"
answers:
  - "why is Perl map_leaves bang implementation paused"
  - "can a LinkedSpec user function implicitly mutate its caller tree binding"
  - "why can write_after not mutate the caller tree from an unparameterized function"
  - "how can map_leaves bang test helper mediated and post commit writes without caller capture"
  - "what decision blocks FUTURE-PARITY-BACKLOG 19.2.2"
date: 2026-08-31
status: confirmed contract conflict; director decision required before behavior code
tags: [language, map-leaves, mutation, user-functions, scope, composition, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.2.2 implementation audit. The frozen map helper-mediated case and composition write_after helper label unparameterized fn names as caller binding identities, while the admitted SPEC-FORMAT-TERSE.4 contract requires fresh function-local parameters/working variables and explicitly defers implicit caller-state capture. Exact Perl execution returns caller [{\"a\":\"A\"},[]] unchanged and helper [{},[\"entered\"]]. Existing caller-scope controls prove set(tree, ...) inside a traversal block reaches the outer binding and a trailing .with() block can write it after the preceding chain. No behavior or neutral fixture changed in the audit."
reverify: "perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.19.2.2 && rg -n 'fresh function-local|no implicit caller|caller-state-mutating' docs/knowledge/terse-user-defined-functions-mvp-contract.md docs/linkedspec-book/src/compiler/pipeline-overview.md"
---

# `map_leaves!` composition versus function scope

The neutral receiver-mutation policy is coherent, but two executable examples currently choose an impossible
carrier under the admitted language. An unparameterized `fn` cannot resolve `tree` or `audit` back into its
caller: those spellings create fresh function-local bindings. Treating them as caller identities would introduce
implicit capture and caller-state mutation across all five backends, a separately deferred language feature.

The narrow contract repair is to retain the same receiver-identity and transaction semantics using existing
caller-scope constructs. `set(tree, ...)` is a helper-mediated write from the callback block, and a trailing
`.with() { tree[...] = ...; return(value) }` runs after the bang result is produced while still resolving the
rule's `tree` binding. The same-spelling shadow case remains valid because its `tree` is an explicit function
parameter and therefore deliberately has a different identity.

No repair is adopted until the director chooses between preserving pure functions with those fixture carriers
and opening a separately ratified five-backend implicit-capture program.

Related: [[map-leaves-mutation-neutral-contract]], [[write-map-leaves-neutral-composition]],
[[terse-user-defined-functions-mvp-contract]], and ADR `0036`.

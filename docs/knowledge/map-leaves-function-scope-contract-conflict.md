---
id: map-leaves-function-scope-contract-conflict
title: "Two map_leaves bang composition carriers were corrected to preserve pure function-local scope"
answers:
  - "why was Perl map_leaves bang implementation paused"
  - "can a LinkedSpec user function implicitly mutate its caller tree binding"
  - "why can write_after not mutate the caller tree from an unparameterized function"
  - "how can map_leaves bang test helper mediated and post commit writes without caller capture"
  - "how was the FUTURE-PARITY-BACKLOG 19.2.2 function scope conflict resolved"
date: 2026-08-31
status: resolved; option A preserves pure functions and uses caller-scope carriers
tags: [language, map-leaves, mutation, user-functions, scope, composition, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.2.2 implementation audit found that the frozen map helper-mediated case and composition write_after helper labeled unparameterized fn names as caller binding identities, while the admitted SPEC-FORMAT-TERSE.4 contract requires fresh function-local parameters/working variables and defers implicit caller-state capture. Exact Perl execution returned caller [{\"a\":\"A\"},[]] unchanged and helper [{},[\"entered\"]]. The director chose option A: the helper-mediated case now uses inline explicit-target set(tree, ...), and post-commit proof uses caller-scoped .with(). Pure functions remain unchanged, both observations remain executable, and the corrected current composition corpus has 592 mutations."
reverify: "perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.19.2.2 && bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && rg -n 'fresh function-local|no implicit caller|caller-state-mutating' docs/knowledge/terse-user-defined-functions-mvp-contract.md docs/linkedspec-book/src/compiler/pipeline-overview.md"
---

# `map_leaves!` composition versus function scope

The neutral receiver-mutation policy was coherent, but two executable examples chose an impossible
carrier under the admitted language. An unparameterized `fn` cannot resolve `tree` or `audit` back into its
caller: those spellings create fresh function-local bindings. Treating them as caller identities would introduce
implicit capture and caller-state mutation across all five backends, a separately deferred language feature.

The adopted narrow repair retains the same receiver-identity and transaction semantics using existing
caller-scope constructs. `set(tree, ...)` is a helper-mediated write from the callback block, and a trailing
`.with() { tree[...] = ...; return(value) }` runs after the bang result is produced while still resolving the
rule's `tree` binding. The same-spelling shadow case remains valid because its `tree` is an explicit function
parameter and therefore deliberately has a different identity.

The director chose that repair. No caller capture or caller-state-mutating function behavior was introduced;
`.19.2.2` could therefore implement Perl `map_leaves!` inside its original ownership boundary.

Related: [[map-leaves-mutation-neutral-contract]], [[write-map-leaves-neutral-composition]],
[[terse-user-defined-functions-mvp-contract]], and ADR `0036`.

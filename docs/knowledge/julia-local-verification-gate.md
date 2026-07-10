---
id: julia-local-verification-gate
title: Julia parity has a focused local gate and optional local-CI integration
answers:
  - how do I run Julia parity checks
  - how do I run the Julia local gate
  - does run_ci_local include Julia checks
  - does Julia local CI require a Julia SDK by default
  - how do I select the Julia executable for LinkedSpec checks
  - how do I select the Julia depot for LinkedSpec checks
  - what does JULIA-BACKEND-PARITY.6.4 prove
date: 2026-07-10
status: current
tags: [julia, ci, verification, corpus, depot, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.4 adds tools/run_julia_local.sh over Pkg.test(), CLI checks, and full 99-fixture execution. tools/run_ci_local.sh invokes it only under LINKEDSPEC_RUN_JULIA=1. JULIA-BACKEND-PARITY.7.3.2.1 proves the focused gate at 868 assertions and 99/99 corpus execution."
reverify: "LINKEDSPEC_JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot bash tools/run_julia_local.sh && rg -n 'LINKEDSPEC_RUN_JULIA|run_julia_local' tools/run_ci_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md"
---

Use the focused Julia gate when changing the Julia backend or its parity documentation:

```bash
bash tools/run_julia_local.sh
```

The script runs Julia `Pkg.test()`, Julia backend CLI help/status, corpus-runner help, and complete 99-fixture
execution. It runs from the repository root and uses the committed Julia project/manifest.

Host installations may select an executable and writable depot:

```bash
LINKEDSPEC_JULIA_CMD=/path/to/julia \
LINKEDSPEC_JULIA_DEPOT_PATH=/path/to/depot \
bash tools/run_julia_local.sh
```

Without an explicit depot override, the script respects `JULIA_DEPOT_PATH`; otherwise it uses a temp-root
`linkedspec-julia-depot` outside the repository. Generated precompile output is therefore kept out of the worktree.

The canonical shared local CI remains core-only unless explicitly opted in:

```bash
LINKEDSPEC_RUN_JULIA=1 bash tools/run_ci_local.sh
```

That boundary keeps ordinary core verification available on machines without Julia. A Julia-capable checkout has
one explicit opt-in that composes the focused gate without duplicating its commands.

Related facts: [[julia-mdbook-usage-status]], [[julia-full-corpus-gate]], [[julia-backend-scaffold-package]],
[[dart-local-verification-gate]], [[native-in-memory-backend-contract]], [[phase0-regression-structure]].

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
  - how do I run one targeted Julia command with repository local storage
  - does the Julia gate retain absolute manifest usage paths
  - what does JULIA-BACKEND-PARITY.6.4 prove
date: 2026-07-15
status: current
tags: [julia, ci, verification, corpus, depot, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.4 adds tools/run_julia_local.sh; FUTURE-PARITY-BACKLOG.1.5.4.2 proves its 1,019 assertions, nine canonical primary process families, and 99/99 corpus after trace convergence. PROJECT-DATA-SSD-ROOTING.2.4 adds tools/run_julia_project_data.sh plus the 17-owner storage oracle, defaults package operations offline, removes the duplicate operating-system-temp/developer-home depot fallback, and expands the complete gate to package tests, storage proof, primary conformance, and 105/105 corpus."
reverify: "bash tools/run_julia_local.sh && rg -n 'LINKEDSPEC_RUN_JULIA|run_julia_local' tools/run_ci_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md"
---

Use the focused Julia gate when changing the Julia backend or its parity documentation:

```bash
bash tools/run_julia_local.sh
```

The script runs Julia `Pkg.test()`, the complete storage oracle, the
`tools/check_julia_primary_cli.sh` process checker, corpus-runner help, and all 105 corpus fixtures. It derives the
repository root from its own location and uses the committed Julia project/manifest.

Use the same storage boundary for one targeted Julia command:

```console
$ bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia'
```

The default writable depot is the ignored repository-relative retained cache. Its five locked external package
trees and General registry resolve offline; the trailing empty depot entry adds only Julia-managed system depots.
Supported wrappers remove Julia's disposable `manifest_usage.toml` after package commands so the retained cache
does not preserve absolute checkout or managed-run paths. A caller may select another Julia executable; a storage
override is accepted only when the common initializer proves that it shares the repository filesystem.

Canonical local CI keeps the complete Julia gate behind its existing explicit SDK opt-in:

```console
$ LINKEDSPEC_RUN_JULIA=1 bash tools/run_ci_local.sh
```

This keeps the core gate usable where Julia is unavailable while ensuring Julia-capable signoff composes the
complete storage/package/primary/corpus boundary without duplicating commands.

For exact cross-backend command identity, `tools/run_primary_cli_matrix.sh` explicitly warms the Julia project and
combines it with Perl, Rust, Dart, and Lua in both environments. `.1.5.4.3` closes the original recurring 4x2x61
proof; Lua `.7.2` extends the same matrix to 5x2x61.

Related facts: [[julia-mdbook-usage-status]], [[julia-full-corpus-gate]], [[julia-backend-scaffold-package]],
[[dart-local-verification-gate]], [[native-in-memory-backend-contract]], [[phase0-regression-structure]],
[[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-failure-trace-routing]], [[julia-primary-cli-process-conformance]],
[[julia-canonical-primary-cli-trace]], [[primary-cli-four-backend-matrix]].

---
id: julia-backend-scaffold-package
title: Julia backend package and command surface
answers:
  - where is the Julia backend package
  - how do I run Julia backend tests
  - what is the Julia backend CLI
  - what is the Julia corpus runner command
  - what does the Julia backend package implement
  - does Julia corpus execution exist yet
date: 2026-07-10
status: accepted
tags: [julia, backend, scaffold, cli, corpus]
evidence: "The repo-owned julia package exposes native APIs, primary CLI and separate corpus runner. .6.3 locks 99/99; .7.3.2.5 locks nine primary process families. Current tests pass with 1,017 assertions at runtime-corpus-primary-cli."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

The Julia backend lives under `julia/` as package `LinkedSpecJulia`. It has package metadata, a committed manifest,
module status helpers, CLI and corpus-runner entrypoints, README commands, smoke tests, and JSON3-backed corpus
manifest validation.

The package has grown beyond the original scaffold: it now includes source/ActionIR parsers, compiled state, an
executable interpreter, staged and runtime user functions, structured diagnostics/tracing, and complete 99/99
library/CLI corpus execution. See the linked current Julia fact cards for each mechanism.
`julia/bin/linkedspec_julia.jl` is the variant-specific CLI, and `julia/bin/corpus_runner.jl` is the corpus-runner
entrypoint. The corpus runner accepts `--corpus <path>` for validation, bare `--execute` for the complete manifest,
and named/offset/limit selectors for diagnostics. `tools/run_julia_local.sh` owns the focused package/CLI/corpus gate.
The primary CLI accepts exact source/input/parser/trace controls, executes through the native library, and emits
the direct top-rule value as canonical JSON.

Related facts: [[julia-mdbook-usage-status]], [[julia-local-verification-gate]], [[julia-full-corpus-gate]],
[[julia-controlled-corpus-execution]], [[julia-corpus-selection-reporting]],
[[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-failure-trace-routing]], [[julia-primary-cli-process-conformance]].

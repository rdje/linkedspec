---
id: julia-backend-scaffold-package
title: Julia backend scaffold package and command surface
answers:
  - where is the Julia backend package
  - how do I run Julia backend tests
  - what is the Julia backend CLI
  - what is the Julia corpus runner command
  - what does the Julia scaffold implement
  - does Julia corpus execution exist yet
date: 2026-07-10
status: accepted
tags: [julia, backend, scaffold, cli, corpus]
evidence: "julia/Project.toml; julia/Manifest.toml; julia/src/LinkedSpecJulia.jl; julia/bin/linkedspec_julia.jl; julia/bin/corpus_runner.jl; julia/test/runtests.jl"
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

The Julia backend lives under `julia/` as package `LinkedSpecJulia`. It has package metadata, a committed manifest,
module status helpers, CLI and corpus-runner entrypoints, README commands, smoke tests, and JSON3-backed corpus
manifest validation.

The package has since grown beyond the original scaffold: it now includes source/ActionIR parsers, compiled state,
an executable interpreter, staged and runtime user functions, structured diagnostics/tracing, and controlled
library-level corpus execution. See the linked current Julia fact cards for each mechanism.
`julia/bin/linkedspec_julia.jl` is the variant-specific CLI, and `julia/bin/corpus_runner.jl` is the corpus-runner
entrypoint. The corpus runner accepts `--corpus <path>` for manifest validation and still deliberately rejects
unbounded `--execute`; `.6.2.1` now permits named or limit-bounded execution while full parity is incomplete.

Related facts: [[julia-controlled-corpus-execution]], [[julia-corpus-selection-reporting]].

# LinkedSpec Julia Backend

This directory is the repository-owned Julia backend scaffold. The current status is package and command
surface only: no `.spec` parser, ActionIR parser, runtime interpreter, manifest validation, or corpus execution
semantics are implemented yet.

This scaffold was created by `JULIA-BACKEND-PARITY.1.2`; the active next boundary is
`JULIA-BACKEND-PARITY.1.3` for manifest-backed corpus IO and drift detection.

## Commands

From the repository root:

```bash
julia --project=julia -e 'import Pkg; Pkg.instantiate()'
julia --project=julia -e 'import Pkg; Pkg.test()'
julia --project=julia julia/bin/linkedspec_julia.jl --help
julia --project=julia julia/bin/linkedspec_julia.jl status
julia --project=julia julia/bin/linkedspec_julia.jl corpus --corpus rust/linkedspec-runtime/tests/corpus
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus
```

Under managed harnesses where the default Julia depot is not writable, prefix commands with a writable depot:

```bash
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot julia --project=julia -e 'import Pkg; Pkg.test()'
```

Optional formatter/linter commands are intentionally not part of the scaffold gate until the corresponding tools
are added as dev dependencies or installed locally:

```bash
julia --project=julia -e 'using JuliaFormatter; format("julia")'
julia --project=julia -e 'using JET; JET.test_package("LinkedSpecJulia")'
```

## Current Boundary

The scaffold proves that Julia package metadata, library loading, CLI routing, and a no-op corpus-runner entrypoint
exist. `JULIA-BACKEND-PARITY.1.3` owns manifest file IO and drift detection. Later leaves own `.spec` parsing,
typed helper/action AST, compiled state, runtime interpretation, staged functions, diagnostics, tracing, and corpus
execution.

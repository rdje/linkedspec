# LinkedSpec Julia Backend

This directory is the repository-owned Julia backend scaffold. The current status is package and command
surface, manifest-backed corpus validation, source AST/data types, core `.spec` source parsing, and frontend
source validation: no top-level function-shell projection, ActionIR parser, runtime interpreter, or corpus
execution semantics are implemented yet.

This scaffold was created by `JULIA-BACKEND-PARITY.1.2`, and manifest IO was added by
`JULIA-BACKEND-PARITY.1.3`. Source AST/data types were added by `JULIA-BACKEND-PARITY.2.1`, and source parsing
was added by `JULIA-BACKEND-PARITY.2.2`. Frontend validation and strict syntax behavior were added by
`JULIA-BACKEND-PARITY.2.3`. The active next boundary is `JULIA-BACKEND-PARITY.2.4` for top-level function-shell
projection through `specs/user_function_definition.spec`.

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

The corpus commands validate `manifest.json`, fixture directory drift, required `input.spec` / `input.txt` /
`expected.json` files, and expected JSON syntax. `--execute` is intentionally unavailable until parser/runtime
semantics land.

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

The scaffold proves that Julia package metadata, library loading, CLI routing, manifest-backed corpus validation,
drift/file guards, and source AST JSON round-tripping exist. `src/spec/Ast.jl` defines spec files, functions,
source spans, staged parse jobs, rule headers/modes, body element variants, edge targets, and fluent calls.
`src/spec/Parser.jl` exposes `parse_spec(...)` for rule paragraphs, headers/modes, regex slots, lifecycle blocks,
action/blind-call edges, fluent continuations, markers, comments, and block boundaries. `src/spec/Validator.jl`
exposes `validate_spec(...)` for top-rule presence, duplicate labels/functions, user-function registry shape,
raw body-line rejection, mixed edge-family rejection, grouped action-edge block requirements, undefined edge
targets, regex-slot bounds, regex structure, and strict unused-rule checks. Later leaves own top-level function
shell parsing, typed helper/action AST, compiled state, runtime interpretation, staged functions, diagnostics,
tracing, and corpus execution.

# LinkedSpec Julia Backend

This directory is the repository-owned Julia backend scaffold. The current status is package and command
surface, manifest-backed corpus validation, source AST/data types, core `.spec` source parsing, frontend source
validation, spec-shaped user-function shell projection, typed helper/action AST parsing, canonical ActionIR contract
resolution, a user-function registry seam, and compiled-spec state: no runtime interpreter or corpus execution
semantics are implemented yet.

This scaffold was created by `JULIA-BACKEND-PARITY.1.2`, and manifest IO was added by
`JULIA-BACKEND-PARITY.1.3`. Source AST/data types were added by `JULIA-BACKEND-PARITY.2.1`, and source parsing
was added by `JULIA-BACKEND-PARITY.2.2`. Frontend validation and strict syntax behavior were added by
`JULIA-BACKEND-PARITY.2.3`. Function-definition shell projection was added by `JULIA-BACKEND-PARITY.2.4`.
Typed helper/action AST parsing was added by `JULIA-BACKEND-PARITY.3.1`, ActionIR contract resolution was added by
`JULIA-BACKEND-PARITY.3.2`, the user-function registry seam was added by `JULIA-BACKEND-PARITY.3.3`, and
compiled-spec state was added by `JULIA-BACKEND-PARITY.3.4`. The active next boundary is
`JULIA-BACKEND-PARITY.4.1` for regex matching and match-state tracking.

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
targets, regex-slot bounds, regex structure, and strict unused-rule checks. `src/spec/UserFunctionDefinitionShell.jl`
exposes `project_user_function_definition_asts(...)` and
`parse_spec_with_user_function_definition_asts(...)` for consuming `function_definition` /
`function_definition_error` nodes shaped by `specs/user_function_definition.spec`; direct `parse_spec(...)` remains
rule-only and does not raw-scan `fn` shells. `src/action/ActionAst.jl` and `src/action/ActionParser.jl` expose
`parse_action_block(...)`, `parse_action_statement(...)`, and `parse_action_expression(...)` for typed ActionIR
blocks, statements, calls, literals, access paths, shape literals, assignments, receiver chains, trailing blocks,
block values, structured controls, and raw fallback nodes with JSON projection. `src/action/ActionContracts.jl`
exposes `resolve_action_block_contracts(...)`, `resolve_action_statement_contracts(...)`,
`resolve_action_expression_contracts(...)`, `canonical_action_helper_name(...)`, and
`is_known_action_ir_call_name(...)` for canonical helper/control contract records and generic
unknown-helper/raw diagnostics over typed ActionIR nodes; optional `function_registry` input classifies exact-arity
registered user calls before helper fallback and reports wrong-arity registered calls. `src/action/FunctionRegistry.jl`
exposes `UserFunctionRegistry`, `user_function_registry_from_spec(...)`, `body_parse_jobs(...)`,
`resolve_user_function_call(...)`, and `stitch_function_body_ast(...)` for ordered user-function records, staged body
parse-job queues, exact-arity lookup, JSON projection, and immutable `body_ast` stitching.
`src/compiler/CompiledSpec.jl` exposes `compile_spec(...)`, `CompiledSpec`, `CompiledRule`,
`CompiledDependencyRegexState`, `CompiledDescriptorState`, `compiled_rule(...)`, `action_payloads(...)`, and
`to_descriptor_json(...)` for ordered compiled rules, dependency refs, dependency-regex rows, mode metadata,
lifecycle/action payload ASTs with registry-aware contracts, function registry projection, and descriptor-shaped JSON.
Later leaves own runtime interpretation, staged parser execution, diagnostics, tracing, and corpus execution.

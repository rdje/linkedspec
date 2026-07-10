# LinkedSpec Julia Backend

This directory is the repository-owned Julia backend scaffold. The current status is package and command
surface, manifest-backed corpus validation, source AST/data types, core `.spec` source parsing, frontend source
validation, spec-shaped user-function shell projection, typed helper/action AST parsing, canonical ActionIR contract
resolution, a user-function registry seam, compiled-spec state, runtime regex/match-state primitives, and first
compiled-rule interpreter dispatch with core value/store/capture semantics plus string/numeric, array, hash,
value/control/block, and tree-callback families: cursor/diagnostic/staged-function/corpus breadth is not implemented
yet.

This scaffold was created by `JULIA-BACKEND-PARITY.1.2`, and manifest IO was added by
`JULIA-BACKEND-PARITY.1.3`. Source AST/data types were added by `JULIA-BACKEND-PARITY.2.1`, and source parsing
was added by `JULIA-BACKEND-PARITY.2.2`. Frontend validation and strict syntax behavior were added by
`JULIA-BACKEND-PARITY.2.3`. Function-definition shell projection was added by `JULIA-BACKEND-PARITY.2.4`.
Typed helper/action AST parsing was added by `JULIA-BACKEND-PARITY.3.1`, ActionIR contract resolution was added by
`JULIA-BACKEND-PARITY.3.2`, the user-function registry seam was added by `JULIA-BACKEND-PARITY.3.3`, and
compiled-spec state was added by `JULIA-BACKEND-PARITY.3.4`. Runtime regex matching and match-state tracking were
added by `JULIA-BACKEND-PARITY.4.1`, and first executable rule dispatch was added by
`JULIA-BACKEND-PARITY.4.2`. `JULIA-BACKEND-PARITY.4.3.0` split helper/value work by runtime mechanism. Core
value/store/capture behavior landed in `.4.3.1`, and string/scalar plus numeric helpers landed in `.4.3.2`. The
array helper and mutation boundary landed in `.4.3.3`, and hash helper and mutation behavior landed in `.4.3.4`;
`.4.3.5` landed value/control/block/callback execution, and `.4.3.6` closed final helper/value no-drift. `.4.4` is
active for explicit cursor controls and boundary capture.

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
`src/runtime/Matching.jl` exposes seek/consume regex matching with stable alternative indexes, complete and compact
capture projections, named captures, zero-based code-unit spans, public character offsets, line/column projection,
cursor state, separate entry/local match registers, and zero-progress detection. Julia's native PCRE integration
accepts the currently required Python-style named captures, POSIX classes, inline/scoped flags, possessive
quantifiers, and recursive patterns directly.
`src/runtime/Interpreter.jl` exposes `LinkedSpecRuntimeEngine`, `runtime_parse(...)`, `runtime_execute(...)`,
`RuntimeParseResult`, `RuntimeLifecycleEvent`, and `RuntimeInterpreterException`. It executes compiled default,
AND, OR, and bounded/unbounded repetition families; action/blind child edges; lifecycle order; `retv`; explicit
returns; narrow array accumulators/capture reads; recursion guards; and zero-progress cutoffs in seek or consume
mode. The embedded ActionIR evaluator now preserves scalar/array/hash/null/boolean/number shapes through separate
stores, bare reads, typed `array(name)` / `hash(name)` snapshots, `copy(...)`, literals, assignments, indexed and
nested reads, and checked no-autovivification nested writes. It also exposes entry/local capture text, groups,
named maps/existence, character spans, and line-column helpers. `.4.3.2` executes current string/scalar and numeric
transforms, predicates, lexical comparisons, aliases and symbol callees, reducers, invalid-input boundaries, and
compatible string/number receiver chains through one canonical dispatcher. `.4.3.3` executes copied array
pipelines, string/regex/split bridges, flatten/concat and explicit constructor splicing, numeric reducer terminals,
typed split replacement, and statement-only named/scalar-held end mutations. `.4.3.4` executes copied hash views
and pure transformations, base/overlay-aware merge resolution, direct hash-index assignment, explicit flat-style
splicing, and statement-only named set-key mutation. `.4.3.5` executes expression-valued blocks with local returns,
attached/marker/inline controls, deterministic while guards, immediate helper/receiver with-blocks, and scoped
hash/array tree traversal callbacks. `.4.3.6` confirms the complete helper/value boundary is no-drift at 567
assertions. `.4.4` adds explicit LIFO cursor save/restore, entry/local anchor rewinds, character-based
cursor/input helpers, and earliest named-rule boundary capture without consuming the boundary. Valid boundary
rules with no later match capture to EOF; wholly unresolved boundary sets return `nothing` without moving the
cursor. The full suite passes with 581 assertions and package status `runtime-cursor-boundary`. `.4.5` owns
diagnostics and tracing through four scoped children. `.4.5.1` exports `RuntimeDiagnostic`, attaches optional
spec/top/rule/handler attribution to `RuntimeInterpreterException`, preserves richer child diagnostics, and keeps
successful output unchanged. The full suite passes with 588 assertions and status `runtime-diagnostics`;
`.4.5.2` adds ordered trace levels, environment/config controls, structured events/scopes/decisions/logs/dumps,
stdout/routed-file/mirror sinks with reset, and output-preserving traced runtime entrypoints. The full suite now
passes with 617 assertions at that controls-only boundary. `.4.5.3` adds rule scopes, regex decisions,
action/blind dispatch, lifecycle marks, recursion cutoffs, cursor transitions, and source-boundary events. The
full suite now passes with 631 assertions and status `runtime-trace-events`; `.4.5.4` owns final no-drift. Staged
parser and corpus execution remain later leaves.

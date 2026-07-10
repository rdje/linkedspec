# LinkedSpec Julia Backend

This directory is the repository-owned Julia backend. Its current `runtime-corpus-leading-trivia` status covers the
package/command surface, manifest validation, source and ActionIR frontends, staged user-function projection/body
parsing, compiled descriptor state, runtime matching and rule/lifecycle dispatch, value/helper/control/callback
families, cursor/boundary behavior, structured diagnostics/tracing, registered function execution, and controlled
library-level corpus execution plus bounded CLI selection/reporting. The current 99-fixture manifest, unbounded
corpus CLI, local-gate integration, and final parity closeout remain later leaves.

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

The backend proves that Julia package metadata, library loading, CLI routing, manifest-backed corpus validation,
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
full suite now passes with 631 assertions and status `runtime-trace-events`; `.4.5.4` closes that no-drift boundary
without changing source or overclaiming broader trace parity. `.5.1` adds the minimal staged registry provider:
`actionir-body.spec` resolves to the fixed built-in adapter, jobs execute in stable path/span/id order, portable
cache/compiled/result records are exposed, and neutral `action_block` JSON is immutably stitched into `body_ast`.
The staged-registry boundary passed with 662 assertions and status `runtime-staged-registry`. Registered exact-arity calls
execute before helper fallback with eager caller arguments, fresh function-local scalar/array/hash stores,
final-expression or local-return results, compatible receiver continuation, standalone result discard, and
direct/mutual recursion diagnostics. `.5.3` proves source-ordered definitions, normalized staged payload/jobs,
stitched `body_ast`, descriptor function metadata, and runtime output through one executable compiled state.

`src/corpus/CorpusManifest.jl` now also exposes `execute_corpus_fixtures(...)`, `CorpusExecutionResult`,
`CorpusFixtureExecutionResult`, and result-query helpers. The library executor validates the manifest, runs every
fixture through parse/compile/runtime, compares runtime output to the expected JSON wrapped exactly once, retains
optional trace lines and structured runtime diagnostics, and records every failure without aborting later fixtures.
The optional `spec_parser` callback is a controlled seam for already-projected staged function shells; the default
is direct rule-only `parse_spec(...)`. The full suite passes with 715 assertions and status
`runtime-controlled-corpus` at that boundary. `.6.2.0` splits the 99-fixture rollout into bounded
selection/reporting, starter 0–39, middle non-function 40–67, shipped-spec/parser-smoke 68–98, and spec-defined
function-shell owners. `.6.2.1` adds ordered named/offset/limit library selection plus bounded runner PASS/FAIL
reporting. `.6.2.2` proves starter fixtures 0–39 green at 40/40 without a production correction. `.6.2.3` proves
non-function windows 40–56, 58–59, and 62–67 green at 25/25 unchanged and explicitly routes offsets 57, 60, and
61 to the function-shell leaf. Full tests pass with 757 assertions and status `runtime-corpus-middle`. `.6.2.4.0`
measures shipped-spec/parser-smoke fixtures 68–98 at 10 passed / 21 failed and splits the failures into recoverable
mechanism leaves. `.6.2.4.1` adds the complete direct anonymous capture-boundary family, closes all three hlink
delimiter cases, and routes EBNF logging to structural output. `.6.2.4.2.1` adds eager logical helpers, closes
three portmap cases plus tablegrep. `.6.2.4.2.3` adds shared strict helper regex flag normalization and closes
`portmap_constant`. `.6.2.4.2.2` adds eager `print`/`print_each`/`say` execution through the configured low-level
trace sink without changing parse output. Simenv advances to unsupported `exit_now`, while history reaches its
leading-trivia output mismatch. Full tests pass with 780 assertions, status is
`runtime-corpus-diagnostic-output` at that boundary. `.6.2.4.3` scopes explicit aggregate resets per rule
invocation, preserves ordinary caller-visible child mutations, and closes all three recursive top-rule cases.
Full tests pass with 785 assertions, status is `runtime-corpus-recursive-rule-scope`, the shipped-smoke window is
21/31 at that boundary. `.6.2.4.4` adds implicit/explicit whole and indexed action-edge child-push forms. All four
spec.spec smokes pass; both EBNF cases retain full structures and route quote-only statement mutation to `.5.2`.
Full tests pass with 793 assertions, status is `runtime-corpus-action-edge-child-push`, the shipped-smoke window is
25/31 at that boundary. `.6.2.4.5.1` adds immediate `exit_now(...)` termination with explicit numeric status,
default status `1`, and the existing structured rule/top/spec diagnostic attribution. Simenv now executes its
fatal branch as `exit_now(1) in rule begin_end_blocks`, proving the helper is supported while exposing the
statement-form mutation prerequisite owned by `.6.2.4.5.2`. Full tests pass with 801 assertions, status is
`runtime-corpus-exit-now`, with the shipped-smoke window at 25/31 at that boundary.
`.6.2.4.5.2` distinguishes statement-context four-argument regex substitution from pure numeric slicing. Bare
scalar targets mutate through strict helper flags and `$n` replacement expansion; standalone/value-form numeric
`substr(...)` stays pure. Both EBNF, both lib_reader, and simenv fixtures now pass exact oracle output. Full tests
pass with 808 assertions, status is `runtime-corpus-statement-mutation`, the shipped-smoke window is 30/31, and
`.6.2.4.5.3` has since mirrored public-parser leading blank/comment skipping without weakening ordinary indexed
reads. History passes, the shipped window is 31/31, full tests pass with 810 assertions, status is
`runtime-corpus-leading-trivia`, and `.6.2.4.6` owns final no-drift.

Library example:

```julia
using LinkedSpecJulia

result = execute_corpus_fixtures("path/to/corpus")
if !corpus_execution_passed(result)
    for failure in corpus_failures(result)
        println(failure.name, ": ", failure.failure)
    end
end
```

The CLI and `bin/corpus_runner.jl` now allow bounded execution. Named selection may repeat `--case`; window
selection uses a zero-based `--offset` and positive `--limit`:

```bash
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --case proof_edge_array_literal
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 0 --limit 10
```

Validation-only behavior remains the default. Until the current 99-fixture corpus is green, CLI execution requires
`--case` or `--limit`; unbounded and offset-only requests are rejected.

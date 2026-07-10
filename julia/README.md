# LinkedSpec Julia Backend

This directory is the repository-owned Julia backend. Its current `runtime-corpus-full` status covers the
package/command surface, manifest validation, source and ActionIR frontends, staged user-function projection/body
parsing, compiled descriptor state, runtime matching and rule/lifecycle dispatch, value/helper/control/callback
families, cursor/boundary behavior, structured diagnostics/tracing, registered function execution, and controlled
library-level corpus execution, bounded CLI selection/reporting, and spec-driven top-level user-function source
composition plus full ordered 99-fixture library and CLI execution. Local-gate integration and native primary
rule/function execution with direct canonical JSON are complete; normalized error/trace conformance, capability
census, generated source, and final complete-parity closeout remain open.

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
`.4.3.5` landed value/control/block/callback execution, and `.4.3.6` closed final helper/value no-drift. Cursor,
diagnostic/trace, staged-function, shipped-corpus, function-shell, and full-corpus work through `.6.3` has since
landed; `.6.4` owns the focused optional-SDK verification gate, `.7.1` closes public documentation, and `.7.2` is
complete with generated source deferred to the future split proof lane. `.7.3.0` found that this corpus/status CLI
does not yet match the required cross-variant parser CLI contract. ADR `0023` defines that exact interface;
`.7.3.2.0` splits repair, `.7.3.2.1` closes compile/parser/function-shell/staged trace coverage, `.7.3.2.2`
closes exact arguments plus source/input resolution/loading, and `.7.3.2.3` closes native rule/function execution
plus recursively key-sorted direct JSON. `.7.3.2.4` is active for normalized failures/exits/trace routing.

## Commands

Run the complete repo-owned Julia gate from the repository root:

```bash
bash tools/run_julia_local.sh
```

It runs package tests, primary CLI help, a direct canonical-output parse, retired-subcommand rejection,
corpus-runner help, and the full 99-fixture corpus. The shared
core gate includes it only when explicitly requested:

```bash
LINKEDSPEC_RUN_JULIA=1 bash tools/run_ci_local.sh
```

Use `LINKEDSPEC_JULIA_CMD=/path/to/julia` to select a Julia executable and
`LINKEDSPEC_JULIA_DEPOT_PATH=/path/to/depot` to select a writable depot. Without a depot override, the script
respects `JULIA_DEPOT_PATH` or uses a platform temp directory outside the repository.
The focused gate prints the resolved depot. Under disk pressure, remove only that depot's regenerable `compiled/`
subdirectory after confirming no Julia process is using it; preserve packages, registries, environments, and
artifacts.

Direct commands from the repository root:

```bash
julia --project=julia -e 'import Pkg; Pkg.instantiate()'
julia --project=julia -e 'import Pkg; Pkg.test()'
julia --project=julia julia/bin/linkedspec_julia.jl --help
julia --project=julia julia/bin/linkedspec_julia.jl \
  --inline-spec $'Top::\n /x/\n E { return(hash("b", 2, "a", 1)) }\n' \
  --input x
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute
```

The primary command validates the exact cross-backend options, prepares named/file/inline source plus literal/file
input, executes rule-only or spec-driven top-level-function source through the native library, and prints the
direct top-rule value as compact JSON with every nested object key sorted plus one newline. The example prints
`{"a":1,"b":2}`. `status` and `corpus` are rejected as primary subcommands. The separate corpus runner validates
`manifest.json`, fixture directory drift, required `input.spec` / `input.txt` /
`expected.json` files, and expected JSON syntax. Bare `--execute` runs all 99 fixtures; selectors narrow a run
without bypassing complete manifest validation.

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

## Native Trace Propagation

Julia uses one caller-owned `LinkedSpecTraceEmitter` across frontend, compiler, staged, and runtime phases. Pass it
with the optional `trace` keyword; omitting the keyword is the normal quiet path:

```julia
using LinkedSpecJulia

source = """
Top::
 /x/
 E { return(match_text()) }
"""

config = trace_config_enabled(LinkedSpecTraceDebug)
trace = LinkedSpecTraceEmitter(config)

spec = parse_spec(source; trace = trace)
validate_spec(spec; trace = trace)
compiled = compile_spec(spec; trace = trace)
result = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x"; trace = trace)
@assert result.value == "x"
```

The same emitter can cover spec-driven top-level functions and staged body jobs:

```julia
function_source = """
fn echo(value) { return(value) }
Top::
 /x/
 E { return(echo(match_text())) }
"""

spec = parse_spec_with_staged_user_function_definitions(function_source; trace = trace)
```

Use the existing routed-file helpers when stdout must stay machine-readable:

```julia
config = with_trace_reset_file(with_trace_file(
    trace_config_enabled(LinkedSpecTraceDebug),
    "linkedspec.trace.log",
))
trace = LinkedSpecTraceEmitter(config)
spec = parse_spec(source; trace = trace)
compiled = compile_spec(spec; trace = trace)
```

Frontend topics use `julia_frontend:*`, compiler topics use `julia_compiler:*`, staged phases use
`julia_staged:*`, and runtime topics remain `julia_runtime:*`. A disabled emitter and an omitted emitter both
preserve results and produce no trace output.

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
These parse/projection/validation APIs accept an optional caller-owned trace emitter and propagate it through
their nested operations. `src/compiler/CompiledSpec.jl` exposes `compile_spec(...)`, `CompiledSpec`, `CompiledRule`,
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
The optional `spec_parser` callback is a controlled parser-override seam. At the `.6.1` boundary the default was
direct rule-only `parse_spec(...)`; `.6.2.5` now keeps that primary path and falls back after a source parse error
to spec-driven top-level function projection. The full suite passed with 715 assertions and status
`runtime-controlled-corpus` at the `.6.1` boundary. `.6.2.0` splits the 99-fixture rollout into bounded
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
reads. History passes, and `.6.2.4.6` adds the complete offset-68/limit-31 regression with stable endpoints, exact
outputs, and zero failures. The shipped window is permanently 31/31. `.6.2.5` adds
`parse_user_function_definition_asts(...)` and `parse_spec_with_staged_user_function_definitions(...)`: Julia
executes the checked-in definition spec over source, normalizes neutral nodes, and reuses staged body parsing. All
three routed top-level function fixtures pass. `.6.3` adds one atomic complete-corpus regression and enables
unbounded CLI execution: the manifest runs 99/99 green in exact order. Full tests pass with 840 assertions, status
is `runtime-corpus-full`, `.6.4` owns the focused optional-SDK gate, and `.7.1` closes public documentation. `.7.2`
defers generated source to `FUTURE-PARITY-BACKLOG.3`. `.7.3.0` splits the newly clarified exact user-facing CLI
parity gap. `.7.3.1` ratifies ADR `0023`; `.7.3.2.0` splits Julia CLI alignment into five mechanisms. `.7.3.2.1`
now closes parse/validation/compile/function-shell/staged trace propagation through the existing emitter and sinks;
the full suite passed with 868 assertions and the focused gate remained 99/99. `.7.3.2.2` closes exact options,
resolution, and loading with 50 focused assertions. `.7.3.2.3` closes native primary execution and recursively
key-sorted direct JSON with 22 focused assertions; the full suite passes with 942 assertions and 99/99 remains
green. `.7.3.2.4` is active for normalized failures/exits/trace routing. Generated source remains deferred but
blocks complete parity because Rust exports it.

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

The CLI and `bin/corpus_runner.jl` run the complete corpus with bare `--execute`. Named selection may repeat
`--case`; window selection uses a zero-based `--offset` and optional positive `--limit`:

```bash
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --case proof_edge_array_literal
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 0 --limit 10
```

Validation-only behavior remains the default. Offset-only execution runs from that zero-based offset through the
manifest end. Every execution mode validates the complete manifest before selecting fixtures.

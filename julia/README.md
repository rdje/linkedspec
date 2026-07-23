# LinkedSpec Julia Backend

This directory is the repository-owned Julia backend. Its current `runtime-corpus-primary-cli` status covers the
package/command surface, manifest validation, source and ActionIR frontends, staged user-function projection/body
parsing, compiled descriptor state, runtime matching and rule/lifecycle dispatch, value/helper/control/callback
families, cursor/boundary behavior, structured diagnostics/tracing, registered function execution, and controlled
library-level corpus execution, bounded CLI selection/reporting, and spec-driven top-level user-function source
composition plus full ordered 105-fixture library and CLI execution. Local-gate integration and native primary
rule/function execution with direct canonical JSON, stable failure/trace routing, and ten-family direct-process
conformance are complete. Cross-backend cursor admission and final complete-parity closeout remain open; current
generated source is v2/format 2. Public named/exact-path resolution, strict UTF-8 loading, staged compilation, source
identity, and structured pipeline exceptions now also live in the native module rather than only the CLI; this
status remains a Julia-local milestone, not a complete backend-parity claim. Julia consumes the complete native,
generated, primary, and recurring `linkedspec-logical-helper-v1` proof; its public no-drift admission is closed.

Current global rollout is intentionally ahead of this historical local milestone. Root-selection core
`FUTURE-PARITY-BACKLOG.9.1.1.2.4.1` accepts one-or-more-rule markerless sources and resolves an explicit selector,
the first authored marker, or the first authored rule from one compiled-state owner before runtime context or user
code. Portable zero/unknown failures, strict authored-edge behavior, and immutable descriptor root identity are
locked by a neutral-consuming focused suite. The root-core leaf initially reached 32/65 in both environments with
33 cursor-owned failures; cursor option removal has since advanced the unchanged manifest to 65/65 twice.
Composed cursor admission advances the complete package to 3,291/3,291. Standalone corpus execution remains
105/105. Composed root routes `.4.2`
now make loaded, normalized, generated direct/traced, and independently emitted direct/traced execution reuse the
same resolver. Low trace records requested/effective/basis, loader and generated wrappers preserve portable
zero/unknown identities, and plan validation remains first. Cursor generated-source `.9.1.6.4` now emits
contract-v2/format 2 with the same minimal label/family plan, derives the exact five seek/five consume mapping,
rejects v1 before payload reconstruction, and removes the private v1 forced-seek engine. Dart cursor admission is
cleanly committed at `7aa9c578`, satisfying Julia's final cursor dependency. Public cursor-option removal `.5`
now removes engine/loader/corpus/primary global state, rejects legacy API/CLI spellings before execution, omits the
help/request-trace field, and preserves `--top-rule`. Admission `.6` adds one exact contract-declared 15-role
consumer and locks the complete/canonical driver topology. Complete Julia is 3,291, shared primary is 65/65 twice,
corpus is 105/105, and neutral cursor rollout is 5 complete / 3 pending with 67 files and 44 mutations. Exact root
admission `.4.3` subsequently passed as a separate 15-role consumer. Root-selection parity is closed at 7
complete / 0 pending; `bash tools/check_root_rule_selection_five_backend.sh` composes that consumer with every
other backend and the selected primary matrix.
The final root-selection ledger is 7 complete / 0 pending.

Duplicate regex-slot identity is closed at 7 complete / 0 pending. Julia uses
direct authored-alternative matching and preserves target/index identity through
normalized `SpecFile` reconstruction, emitted source, descriptors, trace,
primary execution, and typed diagnostics. The recurring proof is
`bash tools/check_duplicate_regex_slot_identity_five_backend.sh`.

Repeated-action result parity is closed at 8 complete / 0 pending. Julia treats
bare `OR` as minimum-one repetition, collects one typed action-edge return per
accepted explicit-repetition hit, preserves lifecycle whole-rule returns and
scalar pipe, and retains generated-source v2. The exact recurring proof is
`tools/check_repeated_action_result_five_backend.sh`.

## Semantic source and compilation foundation

Julia now exposes the complete semantic-introspection foundation owner. `semantic_index` accepts either copied
valid `AbstractString` input or copied strict `AbstractVector{UInt8}` input, builds the exact source map, and then
retains one staged compiled-or-failed outcome. It does not accept or infer a path. The required caller policy is a
nonempty control-free logical name, one source-detail ceiling, and an optional exact Unicode-17 rule selector:

```julia
using LinkedSpecJulia

index = semantic_index(
    "Top::\n /x/\n";
    logical_name = "example.spec",
    source_detail_ceiling = SemanticSourceTextDetail,
)

identity = source_identity(index)
@assert identity.source_id == "source:0"
@assert identity.byte_length == 11
@assert identity.scalar_length == 11
@assert startswith(identity.content_digest, "sha256:")

snapshot = semantic_snapshot(index)
@assert snapshot.state == SemanticCompiledSnapshotState
@assert snapshot.has_execution == false
@assert compilation_authority(index) == SemanticCompilationAuthority(true, true, true)
@assert compilation_diagnostic(index) === nothing
@assert entry_selection(index) == SemanticEntrySelection("Top", "first_authored_marker")
@assert generated_plan_input(index).rows ==
    (SemanticGeneratedPlanRow("Top", "default"),)

@assert source_excerpt_for_bytes(index, 0, 5) == "Top::"
@assert locate_exact(index, "/x/") == SemanticSourceSpan(7, 10, 2, 2, 2, 5)
```

The public ceilings are `SemanticSourceNoneDetail`, `SemanticSourceIdentityDetail`,
`SemanticSourceSpanDetail`, and `SemanticSourceTextDetail`. Identity is caller-owned and never inferred from a
host path. Content SHA-256 is disclosed only at `text`; spans require `span`; excerpts require `text`. Byte ranges
are zero-based, half-open, and must land on strict UTF-8 scalar boundaries. Line and Unicode-scalar columns are
one-based; `\r\n` advances to the next line only at `\n`, and combining characters each occupy one scalar column.
`source_span_for_scalars` uses zero-based half-open scalar ranges. `locate_exact` finds the first exact occurrence
at or after an exact `after_byte` boundary.

`SemanticIndexError` reports stable `stage`, `code`, `message`, and immutable sorted field pairs. Malformed Julia
strings and malformed bytes reject before character iteration; invalid options reject before source handling;
mid-scalar, out-of-range, non-integer, and Boolean coordinates reject as typed source-map failures. The index's
normal display omits the logical name, source text, digest, selector, private map, and compiler objects.

After strict source construction, the owner invokes the staged user-function-aware parser, validator, compiler,
entry selector, and shared generated-source-v2 plan builder exactly once. A language failure does not discard the
source owner: `semantic_snapshot(index).state` becomes `SemanticFailedCompilationSnapshotState`,
`compilation_authority` reports which stages succeeded, and `compilation_diagnostic` returns a detached portable
failure. Successful outcomes expose only detached entry identity and generated plan input. The private `SpecFile`,
`CompiledSpec`, merged authored function/rule order, and source map never cross the API.

Construction never invokes the caller's target parser, action or lifecycle code, generated execution, runtime,
trace, diagnostic-output sink, or semantic observer. `semantic_snapshot(index).has_execution` is therefore always
false at this layer. Returned public structs are immutable, and each `to_json` call creates detached mutable JSON
state.

The owner now also retains the complete private static and call provenance graph; it is deliberately not yet a
public records/query API. The calls target is exact at 22 records / 25 relations: a typed 18/16 core for functions,
helpers, calls, bindings, resolution, and shapes, plus three distinct staged payload/job/result records and one
selected generated handler-plan record with nine directed provenance relations. Typed native sidecars must match
their function owner before neutral staging facts are retained. The generated-v2 input must match the caller
logical identity, complete compiled label order, and unique selected entry row; the owner never emits or executes
generated source. Native payload/job/body-AST state, implementation text, paths, compiler objects, and mutable
containers do not cross the private projection boundary. Public semantic query and runtime observation remain
dependency-ordered later work.

Behavior-free query planning is now complete, but the API below is deliberately not implemented yet. Query must
read only one fresh detached materialization of that private projection; it cannot reach the retained source/map,
compiler, staged sidecars, AST/ActionIR, regex, generated implementation, execution, observation, trace, path, or
host state. The completed surface will expose `semantic_capabilities(index)`,
`semantic_query(index, request::SemanticQuery)`, and `semantic_query_neutral(index, request)` together. Typed and
raw-neutral calls will enter one evaluator and return immutable typed values with fresh `to_json` dictionaries.

Julia will match the 19 non-runtime canonical response hashes and all 26 malformed-request boundaries. Numeric
validation must reject `Bool` before `Integer` because `true isa Integer`; the digest flag must require an actual
`Bool`. Implementation is intentionally split as private record/source/list/get/explain, then private directional
traversal/pages/budgets/costs, then complete public exposure, then no-change composition. The twentieth runtime
response remains a separate observation task.

The planning signoff passes neutral 6/20/81, focused admitted query consumers, Julia focused 530 plus detached
22/25/10, complete Julia 8,072/primary/105, primary 5x2x66, ten Unicode legs, unchanged governance, canonical
Rust/Dart admission + primary 66x2 + Phase 0 1,031/655s, book/KM 687/5,277, doctrines, and exact 1,812,240-KiB
cleanup preserving all 517 Pgen artifacts. No query symbol is public at this boundary.

The source/outcome parent is composition-closed without additional production or replacement test code. Its two
committed suites pass 135 + 85 = 220 focused assertions; complete Julia passes 7,762 package assertions, primary
process conformance, and corpus 105/105; the shared five-backend 5x2x66 primary matrix and all ten self-hosted
Unicode manifest legs pass. All no-drift ledgers remain unchanged. The closeout canonical gate passes Rust semantic
admission in 80.84 seconds, Dart admission 1/1, primary 66x2, and Phase 0 1,031/1,031 in 630 seconds. Static semantic
record construction has since reached exact private 22/25 parity. Its six semantic suites pass 530 assertions;
complete Julia passes 8,072 package assertions, primary process conformance, and corpus 105/105. The shared
5x2x66 primary matrix, all ten Unicode legs, unchanged governance, and canonical Rust 76.95s + Dart 1/1 + primary
66x2 + Phase 0 1,031/622s pass. No-change closeout `.10.6.4.3` recomposes the six committed semantic suites at
focused 530 and passes the same complete Julia/matrix/Unicode/governance boundary plus canonical Rust 77.68s,
Dart 1/1, primary 66x2, and Phase 0 1,031/622s. The private calls/staging/generated parent is composition-closed;
query and runtime observation remain later work.

Behavior-free Julia preflight `.9.1.6.0` mapped the exact starting boundary: compact `|` was misclassified as AND,
engines carried global seek, bare rule labels remained raw, parent/child agreement was 5/8, structural agreement
was 1/2, descriptors carried global mode, and generated source was v1/format 1. Normalization `.1`, intrinsic normal
execution `.2`, descriptor v1 `.3`, generated v2 `.4`, and public option removal `.5` corrected their owned seams.
One exact 15-role consumer closes composed admission `.6`. Shared primary is 65/65 twice, the package passes all
3,291 assertions, and corpus stays 105/105.

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
closes exact arguments plus source/input resolution/loading, `.7.3.2.3` closes native rule/function execution plus
recursively key-sorted direct JSON, and `.7.3.2.4` closes normalized failures/exits/trace routing. `.7.3.2.5` now
closes nine-family direct-process conformance and focused-gate/public-status alignment. `.7.3.3` closes local
outer no-drift; the Julia tree remains active/delegated to global `.1.5`, `.1.6`, and `.3`, not complete.

## Commands

Run the complete repo-owned Julia gate from the repository root:

```bash
bash tools/run_julia_local.sh
```

It runs package tests, the ten-family primary process checker in `tools/check_julia_primary_cli.sh`, corpus-
runner help, and the full 105-fixture corpus. The shared
core gate includes it only when explicitly requested:

```bash
LINKEDSPEC_RUN_JULIA=1 bash tools/run_ci_local.sh
```

The complete driver is expected to pass. Use the exact shared runner to verify 65/65 in both environments and the
standalone corpus command to verify 105/105. Cursor topology is admitted; root topology still waits for `.4.3`.
The focused route suite is:

```bash
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia \
  julia --project=julia -e \
  'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/root_rule_selection_routes_test.jl")'
```

It passes 57 assertions, including a fresh isolated generated module.

Use `LINKEDSPEC_JULIA_CMD=/path/to/julia` to select a Julia executable and
`LINKEDSPEC_JULIA_DEPOT_PATH=/path/to/depot` to select a writable depot or ordered depot list. Without a depot
override, the script respects `JULIA_DEPOT_PATH` or uses a platform temp directory outside the repository. For a
stacked path, both repository drivers create only the first entry (`:` separator on POSIX, `;` on Windows-like
shells); that first entry must be nonempty and writable.
The focused gate prints the resolved depot. Under disk pressure, remove only that depot's regenerable `compiled/`
subdirectory after confirming no Julia process is using it; preserve packages, registries, environments, and
artifacts.

A temporary depot containing only regenerated `compiled/` cache entries does not contain package source. For a
direct offline command after such cleanup, put the writable temporary depot first and the existing package depot
second:

```bash
JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia \
  julia --project=julia -e 'import Pkg; Pkg.test()'
```

The first entry owns new cache writes; the second supplies already-installed package sources. Do not use a lone
compiled-only depot and do not delete the source-bearing package depot as cache cleanup. Add
`JULIA_PKG_OFFLINE=true` when the installed depot already contains every dependency and network access must not be
attempted.

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
`{"a":1,"b":2}`. Compilation, input loading, and invocation failures use stable stderr headings and exit `1`;
usage failures exit `2`. Trace defaults to stdout without a file and route with one; explicit stdout/route/mirror,
reset, and emoji compose without changing routed canonical stdout. `status` and `corpus` are rejected as primary
subcommands. The separate corpus runner validates
`manifest.json`, fixture directory drift, required `input.spec` / `input.txt` /
`expected.json` files, and expected JSON syntax. Bare `--execute` runs all 105 fixtures; selectors narrow a run
without bypassing complete manifest validation.

## Native and Generated Logical Helpers

`and`, `or`, and `not` are eager boolean value helpers. `and` and `or` require at least one positional argument;
`not` requires exactly one. Invalid calls fail before evaluating any operand with `helper_arity_mismatch` and
structured `code`, `helper_name`, `actual_arity`, and `expected_arity` fields. Valid operands evaluate exactly once
from left to right, so use `if`, `switch`, or `while` when later side effects must be skipped.

Logical helpers and lazy controls share one `_runtime_truthy` typed policy: `nothing`, false, numeric zero, the empty string,
and empty vectors/dictionaries are false; nonzero numbers, every nonempty string (including `"0"` and `"false"`),
and nonempty aggregates are true. A typed codeblock value is true without invocation; this runtime rule does not
activate the separately future explicit callable-literal syntax.

```text
Top::
 /x/
 E {
   seen = []
   eager = or(true, { push(seen, "still-runs"); return(false) })
   lazy = if(false, { push(seen, "skipped"); return(true) }, { return(false) })
   return(hash("eager", eager, "lazy", lazy, "seen", copy(seen)))
 }
```

The result is `{"eager":true,"lazy":false,"seen":["still-runs"]}`. Native, reconstructed, generated-plan,
emitted-module, and primary-command paths share these semantics. Direct/traced generated-plan calls and
`LinkedSpecGeneratedParser.execute` / `LinkedSpecGeneratedParser.execute_with_trace` retain the same value,
effect order, failure attribution, and trace-result identity. The primary command keeps its stable generic
`linkedspec: parser invocation failed` process projection for invalid calls; native callers can inspect
`to_json(error.diagnostic)` for the structured fields.

Run `bash tools/check_logical_helper_five_backend.sh` from the repository root for the full recurring neutral,
six-runtime, selected-primary, and support-ledger proof. Canonical local CI exposes the same all-toolchain leg as
`LINKEDSPEC_RUN_LOGICAL_MATRIX=1 bash tools/run_ci_local.sh`.

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

## Native Spec Resolution and Loading

Use the public progressive API when a Julia application starts from a named `.spec` or exact file path:

```julia
using LinkedSpecJulia

loaded = load_and_compile_spec(
    named_spec_request("grammars/Expression"),
    SpecLoadOptions(
        pwd();
        search_roots = [joinpath(pwd(), "specs")],
    ),
)

println(loaded.loaded.resolved.path)
engine = create_engine(loaded)
result = runtime_execute(engine, "input")
```

`resolve_spec(...)` validates and selects a regular file. `load_spec(...)` additionally reads and strictly decodes
UTF-8 while preserving BOM, Unicode normalization, newlines, and surrounding text. `load_and_compile_spec(...)`
continues through the staged function-aware parser, validation, and compiler. Use
`path_spec_request("path/to/file.spec")` for one exact absolute or cwd-relative host path with no suffix or search-
root fallback. Named identities use `/` components and search cwd exact, cwd with `.spec`, then caller-declared
direct roots in order; resolution never recursively scans them.

Failures throw `SpecPipelineException` with typed stage/code values, request identity, optional resolved path and
detail, and a neutral `to_json(...)` projection. `create_engine(...)` carries the requested name and resolved path
into later runtime diagnostics. The primary CLI delegates named/file sources to this API but keeps its stable
phase-only process errors and deferred input-file order.

## Native Diagnostic Output

Parser-authored `print`, `say`, and `print_each` messages use a caller-owned event channel that is separate from
parse results and trace. Install a callback for one invocation with the `diagnostic_output_sink` keyword:

```julia
events = RuntimeDiagnosticOutputEvent[]
result = runtime_parse(
    engine,
    input;
    diagnostic_output_sink = event -> push!(events, event),
)
```

Each event exposes exact `helper_name`, current `rule_label`, and Unicode `message` fields; `to_json(event)` emits
the same three-key record. `runtime_parse`, `runtime_execute`, `runtime_parse_with_trace`, and
`runtime_execute_with_trace` accept the optional callback. Omitting it stays quiet without skipping valid-call
argument effects.

Arity is validated before any argument evaluates: `print`/`say` require at least one positional argument and
`print_each` requires two or three. Valid arguments evaluate once left-to-right. A callback failure propagates as
the exact caller object, including `RuntimeInterpreterException`, and aborts later items/actions. `exit_now`
throws `RuntimeExitNow(status)` after any preceding event. Neither event data nor callback failures become
`RuntimeDiagnostic` or native trace records. Independently emitted modules expose the same keyword on direct and
traced entrypoints:

```julia
value = LinkedSpecGeneratedParser.execute(
    input;
    diagnostic_output_sink = event -> push!(events, event),
)
traced = LinkedSpecGeneratedParser.execute_with_trace(
    input,
    trace_config;
    diagnostic_output_sink = event -> push!(events, event),
)
```

Generated `LinkedSpecGeneratedParser.execute` and `LinkedSpecGeneratedParser.execute_with_trace` retain their
sinkless forms. Caller failures cross generated framing unchanged; ordinary failures retain generated-source
attribution.

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
fn collect(prefix, ...items) { return({ "prefix" : prefix, "items" : items }) }
Top::
 /x/
 E { return(collect(echo(match_text()), "tail")) }
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
unknown-helper/raw diagnostics over typed ActionIR nodes; optional `function_registry` input classifies exact-v1 or
fixed-prefix/rest-v2 registered calls before helper fallback, rejects keyword arguments, and reports wrong-arity
registered calls. `src/action/FunctionRegistry.jl`
exposes `UserFunctionRegistry`, `user_function_registry_from_spec(...)`, `body_parse_jobs(...)`,
`resolve_user_function_call(...)`, and `stitch_function_body_ast(...)` for ordered user-function records, staged body
parse-job queues, exact/minimum-arity lookup, v1/v2 JSON projection, and immutable `body_ast` stitching. Variadic
calls evaluate positional arguments once left-to-right and bind extras as one fresh typed array; generated Julia
source preserves the same signature through canonical JSON encoded as ASCII hex.
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
`RuntimeParseResult`, `RuntimeLifecycleEvent`, `RuntimeInterpreterException`, `RuntimeDiagnosticOutputEvent`,
`RuntimeDiagnosticOutputSink`, and `RuntimeExitNow`. It executes compiled default,
AND, OR, and bounded/unbounded repetition families; action/blind child edges; lifecycle order; `retv`; explicit
returns; narrow array accumulators/capture reads; recursion guards; and zero-progress cutoffs in seek or consume
mode. The embedded ActionIR evaluator now preserves scalar/array/hash/null/boolean/number shapes through separate
stores and bare typed bindings: `set(items, [])`, `set(meta, {})`, `copy(items)`, literals, assignments, indexed and
nested reads all resolve by runtime value kind, while exact retired selectors reject before execution. It also
exposes entry/local capture text, groups,
named maps/existence, character spans, and line-column helpers. `.4.3.2` executes current string/scalar and numeric
transforms, predicates, lexical comparisons, aliases and symbol callees, reducers, invalid-input boundaries, and
compatible string/number receiver chains through one canonical dispatcher. `.4.3.3` executes copied array
pipelines, string/regex/split bridges, flatten/concat and explicit constructor splicing, numeric reducer terminals,
typed split replacement, and updated-value named/scalar-held end mutations. `.4.3.4` executes copied hash views
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
`portmap_constant`. At the historical `.6.2.4.2.2` boundary, eager `print`/`print_each`/`say` execution used the
configured low-level trace sink without changing parse output. Simenv then advanced to unsupported `exit_now`, while history reached its
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
key-sorted direct JSON with 22 focused assertions. `.7.3.2.4` closes phase-ordered failures, stable stderr/exit,
and the complete trace sink/reset/emoji matrix with 75 focused assertions; the full suite passes with 1,017
assertions and 99/99 remains green. `.7.3.2.5` now closes nine direct process families and status is
`runtime-corpus-primary-cli`; `.7.3.3` closes the local audit without a full-parity claim. Generated source remains
deferred and blocks complete parity because Rust exports it; neutral CLI fixtures and capability census remain
global `.1.5` and `.1.6` work.

The global pure-helper parity leaf now locks the governed exhaustive source directly. Numeric predicate helpers
return `1`/`0`, direct literals splice explicit `flat(...)`, and standalone explicit working-array string
transforms mutate while value/receiver forms remain pure. Exact empty-local-match projection also preserves null
capture/position values, empty containers, numeric presence, 1-based diagnostic defaults, and real zero-width
matches. Marker-form switch siblings also execute as one nesting-aware first-match/default chain. The governed
anonymous/named capture family now uses rule-local code-unit marks with character-based public positions and
lengths. It covers stable/advancing slice, cursor, rest, from, and between reads; current/input-boundary, copied,
and anonymous-bridge marks; and symbolic bare mark arguments. Non-repeated `AND` blind-call rules surface ordered
child returns when no explicit parent return overrides them. Native named/file resolution added 82 direct contract
and pipeline assertions; at that historical boundary the package suite reached 1,110 assertions, shared CLI was
61/61 in both environments, and corpus was 105/105. The current global 66-case boundary adds the repeated-action
projection to the root-and-cursor baseline described at the top of this file and supersedes those historical
counts for present gate status.

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

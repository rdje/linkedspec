# Pipeline Overview

At a high level, LinkedSpec’s compile/runtime flow looks like this:

1. validate and prepare the compile pipeline
2. extract top-level user-function definitions into the function registry
3. bootstrap-parse the stripped `.spec` rule source into parsed entries
4. build compiled rule-table state
5. attach the validated function registry to compiled state
6. build dependency-regex state
7. build compiled descriptor state
8. validate the generated descriptor state
9. project the outward descriptor or build the runtime parser wrapper

In text-diagram form:

```text
source .spec text
  -> prepare pipeline
  -> user-function registry extraction
  -> validate source envelope
  -> bootstrap parse
  -> helper/action AST
  -> compiled_spec_state
  -> attach function registry
  -> compiled_dependency_regex_state
  -> compiled_descriptor_state
  -> validate descriptor state
  -> outward descriptor or parser coderef
```

Lua can now project the compiled-state branch into deterministic host source as well:

```text
Lua CompiledSpec + strict-UTF-8 source identity
  -> source-ordered effective callable definitions
  -> last-definition effective rule order
  -> typed SpecFile
  -> canonical sorted-key strict-UTF-8 JSON
  -> lowercase ASCII-hex payload and identity
  -> native Lua module source
  -> metadata() / execute() / execute_with_trace()
```

This generated module reloads the effective typed spec through Lua's public AST/compiler APIs and delegates to the
same runtime engine. It preserves fixed-v1, variadic-v2, and final-codeblock-v3 callable records rather than
inventing a separate compiled-state decoder. Contract/version/identity markers and typed emit/compile-load/
execution errors make the boundary inspectable. The scaffold is deterministic source generation, not an
optimizing compiler. Fresh-process dual-ABI valid/corrupt load/run/cleanup is recurring proof under `.8.1.2`;
ten-family plans, authoritative root/nested dispatch, portable generated-family trace, and an isolated all-family
module are current under `.8.2`. Contract-sourced interpreter-first 8/105 fresh-host proof closes under `.8.3`,
and `.8.4` admits Lua across all 16 capability rows at five-backend 80/0/0 and closes the backend handoff.

Ordinary Lua runtime entry now treats compiled rule family as execution policy. At every live, loaded,
normalized, direct-call, blind/action-child, recursive, or traced rule entry, AND derives consume plus sequence
and OR/default derives seek plus choice. Only the current cursor crosses a child boundary; the child re-enters
the same owner and derives again. An explicit outer `parse_mode` remains temporarily distinguishable from an
omitted value for compatibility removal in `.9.1.7.5`. Current generated-source v2 retains only ordered
label/family rows and derives the same five seek and five consume policies at generated entry; compact Pipe is
OR/choice. A stale v1 artifact is rejected before embedded spec reconstruction with regeneration guidance.

The Lua outward descriptor now projects that same normalized identity without becoming another policy owner.
Root metadata names `linkedspec-rule-local-cursor-v1` and has no global cursor field. Per-rule metadata derives
`family` and `cursor_policy` from compiled mode metadata and derives ownership plus ordered
`ownership`/`target`/`regex_index`/`block`/`fluent` rows from the compiled action/blind tables. Direct source,
normalized `SpecFile` JSON, and loaded source produce byte-identical descriptors. The projection has no decoder
and does not serialize the still-staged outer compatibility option.

The stages above are a **backend-neutral** description of how any LinkedSpec backend turns `.spec` source into a parser or descriptor. The concrete module names, line counts, and signatures used as examples in this chapter (`LinkedSpec::Validation`, `LinkedSpec::Get(...)`, `Runtime::run_get`, `pos($$input_ref)`, …) are the **Perl reference backend's** realization of those stages; another backend implements the same stage sequence in its own language.

## Staged linked parsing

LinkedSpec does not require every useful grammar boundary to be swallowed by one
up-front parser. A stage may parse the structure that is easy to anchor, emit an AST
node containing an extracted text payload plus source span, and create a later parse job
for that payload. The next job can load the spec that owns the payload's sublanguage and
replace or augment the text field with a deeper AST.

For example, a stage can recognize a top-level function shell, preserve its body text
with source provenance, and route that body to the action/body grammar that owns helper
statements. The same stage might also extract regex payloads, annotations, or embedded
DSL fragments, each routed to a different next-stage spec. Stage N therefore maps to a
parse graph, not necessarily to one stage-N+1 spec.

A parse job is a neutral contract, not a host-language trick. The job records:

- job id
- parent AST path
- node kind
- payload kind
- parser spec identity
- optional top rule
- source text and source span
- result insertion policy
- failure policy and diagnostic owner

The accepted annotation design is a future portable helper:

```text
parse_job(text_expr, hash(
  "node_kind", "function_definition",
  "payload_kind", "function_body",
  "spec", "specs/action-body.spec",
  "top", "action_block",
  "into", "body_ast",
  "on_error", "fail"
))
```

The helper creates a marker value in the stage-N AST and a backend-neutral metadata
sidecar. It does not execute the next parser inline. Result policies define where the
later AST is stitched (`replace_marker`, `replace_field`, `sibling_field`, or
`append_child`). Failure policies define whether a next-stage failure aborts the composed
parse (`fail`), preserves the original text plus diagnostics (`keep_text`), or emits a
structured diagnostic node (`diagnostic_node`). Current shipped parsers do not yet accept
or execute `parse_job(...)`.

The implemented function-body subset dispatches jobs through a staged parser registry with neutral
`resolve`, `load`, `compile`, and `execute` operations. Perl, Rust, Dart, Julia, and Lua all resolve the narrow
`actionir-body.spec` identity, record the governed built-in adapter digest/cache key, execute top rule
`action_block`, and immutably stitch `body_ast`. Lua additionally exposes one/many-job, dispatch-with-results,
stitch-only, and composed function-shell APIs. Its following fixed-v1 runtime executes registry-first calls over
verified staged bodies and fresh copied stores. Lua then preserves the exact fixed-v1/variadic-v2 signature union
through shell, AST, jobs, registry, contracts, and compiled state. Registry lookup accepts a v2 fixed-prefix
minimum through an unbounded maximum. Runtime now copies all evaluated arguments into the isolated frame, binds
the fixed prefix normally, and copies extras into one fresh typed rest array. The unchanged neutral fixture passes
exactly on both Lua ABIs at 139/139. Lua next canonicalizes final-only `callback: codeblock` definitions to fixed-v1
params/arity plus exact `parameter_kinds`, preserves that metadata across payload/job/AST/registry/compiled state,
and derives one zero-positional `codeblock_argument` from either contextual spelling. This metadata-only boundary
passes 142/142 without promoting harrays. The next runtime boundary invokes that argument in the current isolated
function frame, preserves registered-function and governed-helper precedence, restores the outer caller, returns
ordinary chainable values, and diagnoses missing/wrong-kind/arity/recursion failures. Portable resolution/loading
then adds typed named/exact-path requests, caller-owned cwd/direct roots, deterministic first-regular-file
selection, in-process byte reads, strict UTF-8 preservation, and neutral pipeline errors. It directly consumes all
14 name, nine resolution/file-kind, and four text cases on both Lua ABIs. Automatic execution of the spec-owned
function-shell grammar now resolves the bundled owner module-relatively, validates/compiles it once, and composes
only typed results through the Unicode projector and body dispatcher without a raw scanner. Both ABIs pass 151/151
with status `native-spec-defined-functions-v1`. Loaded-source composition then retains exact request/path/source/
compiled state, translates neutral parse/validate/compile failures, and creates name/path-attributed engines.
Loaded functions and runtime diagnostic identity first passed 153/153 with status `native-spec-pipeline-v1`;
native-loading no-drift then closed that parent. Exact fixed/variadic/final-codeblock outward descriptors and one
caller-owned emitter through IO, frontend, compiler, function, staged, engine, and runtime phases now pass 155/155
on both Lua ABIs with status `native-full-pipeline-trace-v1`. The compiled spec and runtime engine retain no
emitter; callers pass the same emitter explicitly when runtime parsing should continue the correlated stream.

```text
fn apply(value, callback: codeblock) {
  return(callback())
}

upper_a = apply("hello") { return(value.uppercase()) }
upper_b = apply("hello", { return(value.uppercase()) })
```

On Lua, both calls return `"HELLO"`. The contextual block is always zero-positional and sees the copied current
function frame; it is not a lexical closure. Writes to other names are visible to later statements in that
function invocation, while the outer caller is restored when the function returns. A keyed brace literal remains
a harray and fails the declared codeblock slot. Registered functions and governed helpers keep static precedence
over a colliding parameter name. Explicit `{|params| ...}` values and arbitrary bound codeblock calls remain a
separate later Lua milestone.

The general future registry extends that proven subset. Resolution checks already-known
import aliases and composed spec identities, then paths relative to the declaring spec,
then configured search roots and registry providers in declared order. The scheduler
collects jobs after the current stage parse, orders them by parent AST path, source span,
and job id, executes them in that stable order, stitches their results, and queues any
new jobs emitted by stitched results at the next stage depth. Cache keys include the
normalized spec identity, content digest, import/include graph fingerprint, selected top
rule, `.spec` language version, helper/action contract version, staged parsing contract
version, and backend capability set. Active-chain repeats of spec identity, top rule,
payload digest, and source span are staged-dispatch cycles and must diagnose.

Spec imports/composition are a separate feature. Imports let a spec reuse definitions
from other spec files. Staged parse dispatch runs another parser over text produced by a
previous parse. Keeping those concepts separate lets diagnostics explain whether a
failure happened while loading grammar material or while refining a runtime payload.

The accepted import/composition design is deliberately file-scope and language-neutral:

```text
import "common/atoms.spec" as atoms
include "common/lifecycle.spec"
```

`import` loads reusable grammar material behind an explicit alias, so references use a
qualified rule name such as `atoms.Identifier`. `include` performs a structured merge of
another parsed `.spec` into the current unqualified namespace. It is not text
concatenation, and it does not parse runtime payloads. Resolution order, collision
diagnostics, cycle reporting, source provenance, and descriptor fingerprints are part of
the neutral contract. This is a design contract for upcoming implementation; current
shipped parsers do not yet accept those directives.

For `.spec` language evolution, `specs/spec.spec` is the first authoritative grammar.
Other `.spec`-language stages derive from payloads produced through that self-hosted
path. The hardcoded bootstrap parser may bridge old behavior, but permanent syntax
should not fork into bootstrap-only grammar.

The first staged-dispatch prototype targets user-function body payloads. The
self-hosted `specs/spec.spec` grammar already extracts `fn name(args) { body }` as a
bounded text island, and current backends already have behavior to preserve for those
function bodies. The prototype describes the body payload, parse job, diagnostics, and
stitched result in `.spec`/AST terms; the fact that a current implementation proves the
slice first is evidence, not the language contract. Current shipped parsers implement
only the narrow `body_parse_job` path: a built-in registry provider resolves
`actionir-body.spec`, compiles the `action_block` adapter, executes jobs in stable queue
order, and stitches the returned `action_block` AST into `body_ast`. General public
`parse_job(...)` authoring, filesystem/import resolution, multiple provider search, and
recursive staged queues remain future work.

Prototype tests should prove AST shape, not only behavior. Before the function-body
prototype changes runtime behavior, the seam audit must predict the returned
`function_definition` AST shape, and the implementation proof must assert that exact
shape along with source provenance and diagnostics. The spec-file rule that returns
that AST needs broad variation coverage: whitespace, zero and multiple parameters,
nested braced bodies, strings, regex-looking text, adjacency to other spec constructs,
and malformed definitions where those forms should diagnose. A dedicated small spec
file/top rule is appropriate for these focused AST-shape tests; the whole
`specs/spec.spec` parser is not the only valid test harness.

The `.5.2` audit fixes the expected harness and target shape before code. A focused
function-definition AST test should dispatch from a wrapper top rule into a normal
`function_definition` rule; a direct top regex rule cannot read its own captures through
`entry_group(...)`. Optional fields should use named captures or equivalent structured
fields, because compacted numbered captures mis-shape zero-argument functions. The
target node carries `type`, `name`, parsed `params`, `arity`, exact `source_text`,
neutral `source_span`, exact inner `body_source`, `body_span`, a `body_parse_job`, and
the stitched `body_ast` after dispatch.

The current Perl reference bridge and Rust runtime adapter now consume a focused
spec-defined parser for the definition shell: `specs/user_function_definition.spec`. That spec returns the
pre-dispatch `function_definition` AST, including a neutral `body_payload` with
`kind = staged_payload`, `node_kind = function_definition`,
`payload_kind = function_body`, exact payload text, half-open source/body spans,
source-slice provenance, a source-order parent path, and the function name, params,
and arity. It also returns `body_parse_job`, a neutral parse-intent sidecar for the same
payload. The sidecar carries a deterministic job id, source-order parent AST path,
`parser_spec_id = actionir-body.spec`, `top_rule = action_block`,
`result_policy = replace_field`, `result_field = body_ast`, `failure_policy = fail`,
exact text, source span, and diagnostic ownership.

The function shell uses linked opener/closer rules: nested `body_brace` islands handle
inner `{ ... }` blocks, while `function_definition[1]` owns the outer close edge.
Quoted strings, comments, and regex literals are matched as body islands before brace
dispatch so braces inside them do not end the function. The Perl registry plus Rust, Dart, Julia, and Lua
staged-dispatch APIs validate that returned AST, normalize
source-order parent paths and parse-job ids, preserve the sidecar in
descriptor/compiled function state where that backend has the descriptor layer,
dispatch the `body_parse_job` through the minimal staged parser registry, and
stitch the returned body ActionIR AST into `body_ast`. The current registry
provider is intentionally narrow: `actionir-body.spec` is resolved as a built-in
neutral identity and executed by the existing ActionIR body-parser adapter until
a self-hosted body spec exists.

In Lua, `parse_spec_with_staged_user_function_definitions(source)` automatically executes the cached bundled
definition grammar, projects its typed nodes, and dispatches their body jobs.
`parse_spec_with_staged_user_function_definition_asts(source, definition_nodes)` remains the explicit-node seam.
Lower-level callers can inspect deterministic provider/cache/result records through
`dispatch_function_body_parse_jobs(spec)` and `staged_parser_registry_to_json(result)`;
`stitch_function_body_parse_jobs(spec)` returns only the new stitched `SpecFile`.
The Lua fixed-v1 runtime then resolves registered raw call names before helper
canonicalization. It evaluates positional arguments once left-to-right in caller scope,
copies them into fresh scalar/array/harray stores, executes the staged function body, and
restores the caller stores and active-function path on both success and failure. The
staged `body_ast` is authoritative: Lua reconstructs the typed ActionIR block from the
governed body source, requires exact canonical JSON equality with `body_ast`, and caches
only that verified pair. Final expressions and function-local `return(expr)` provide the
result; nested nonrecursive calls, standalone value drop, and compatible receiver chains
all reuse ordinary ActionIR evaluation. Exact arity, keyword arguments, recursion cycles,
and missing/drifting staged bodies retain typed function-owned diagnostics.

The current end-to-end proof covers both descriptor shape and runtime behavior. A spec
with several function bodies such as:

```text
fn normalize(value) { return(trim(value)) }
fn join_pair(left, right) { return(cat(left, right)) }
fn mk_items(first, second) { items += first; items += second; return(copy(items)) }
fn mk_meta(key, value) { meta[key] = value; return(copy(meta)) }

Top::
 -> Done {
  set(stage_meta, mk_meta("k", "v"));
  return([normalize(" x "), join_pair("a", "b"), count(mk_items("a", "b")), stage_meta["k"]])
 }
Done:
 /x/
```

has a function registry ordered as `normalize`, `join_pair`, `mk_items`, `mk_meta`.
For each function, the descriptor exposes the exact body text in `body_payload`, a
normalized `body_parse_job` at `functions.<index>.body_source`, and a stitched
`body_ast` whose `kind` is `action_block`. Running the parser on `x` returns
`["x", "ab", 2, "v"]` on the Perl reference backend; the Rust backend returns the
same payload inside its normal top-rule result collection shape.

The staged model is implementation-language neutral. Perl5, Raku, Rust, Julia, Lua,
Dart, Zig, Go, and future backends must preserve the same parse-job semantics, source
provenance, deterministic parser resolution, and result stitching behavior.

Every backend must parse helper/action language text into typed AST/IR nodes before
lowering, interpretation, or code emission. Direct text-to-text helper rewriting into
host-language source is not a conforming architecture for new backend work. The Rust
backend already follows this model with expression and statement nodes. The Perl
reference now exposes an additive `LinkedSpec::ActionIR::AST` parser seam for the helper
expression surface. The Perl reference has also started consuming that seam for non-call
value expressions in `MethodLowering`: primitive literals, scoped bare scalar reads,
direct indexed/nested access, shape literals, and block values lower from AST nodes.
Value-only helper-call composition now also consumes AST `call` nodes recursively before
reusing the existing Perl helper catalog, covering scalar normalization, string
predicate/composition, coalesce/concat, and scalar-argument numeric helpers. Aggregate
helper-call families now consume AST `call` nodes too: bare typed reads, retained aggregate constructors,
current `copy(...)`, collection
helpers, numeric reducers over aggregate operands, and hash helpers rebuild their helper
surface from typed AST fields while preserving symbol slots and quoted-constructor literal
boundaries before reusing the existing Perl helper catalog. Unsupported covered helper
forms now report through the existing unresolved-helper metadata instead of leaking as
generated host-language calls. Receiver-dot value chains now also consume AST
`fluent_chain` nodes for the array, hash, string, and number receiver families before the
legacy receiver-dot text normalizers run. Generalized return payloads now parse through
the same AST value traversal before the legacy raw fallback, preserving scalar source-slot
reads such as `return(count)` and narrow compatibility payloads that are still untyped.
Assignment and mutation operator statements (`name = value`, `items += value`, and
`meta[key] = value`) now also consume typed AST target/key/value fields before the legacy
statement-regex fallback. Helper-call statements now consume typed AST `call` fields for
current statement helpers: `set`, `set_key`, `push`, `return`, and `return_undef`, while
array end-mutation receiver statements consume AST `fluent_chain` receiver/call fields.
Retired helper-looking statement spellings are not current statement contracts.
Expression-valued block internals now consume AST `block_value`,
`action_block`, and `action_stmt` fields for side effects, block-local return payloads,
and final expressions. The parser seam now also represents attached-block and marker
structured-control statements as typed `control_*` nodes for `if`/`when`/`otherwise`,
`switch`/`case`/`default`, and `while` families, including attached bodies and switch
branches. `if`/`when`/`otherwise` statement lowering now consumes typed condition and
body nodes before reusing the existing branch engine. `switch`/`case`/`default` statement
lowering now consumes typed source, match, body, branch-list, and end-marker nodes before
reusing the existing switch stack engine. Attached `while(cond) { ... }` statement
lowering now consumes typed condition/body nodes before reusing the existing loop lowerer
and its deterministic 10000-iteration safety guard. Bodyless `while(...)` marker nodes
remain parser shape only because the current DSL has no `endwhile` product syntax. Exact one-bare-identifier
aggregate selectors are rejected on Perl at this typed boundary before lowering. Rust and Dart perform the
equivalent structural walk over every compiled ActionIR block and deferred edge-fluent argument before native or
generated execution, including dead code and unused user functions.
Standalone supported value statements now lower through the same typed AST value
traversal and produce canonical `VALUE_DROP` events: their value is computed with the
covered helper/receiver semantics and then intentionally discarded. For example,
`trim(" x ")`, `cat("a","b")`, and `" x ".trim()` do not remain raw host calls.
Unknown typed calls and function-call receiver chains in return/value positions now
diagnose through unresolved-helper metadata instead of becoming generated host-language
calls. Top-level user-function definitions now have their own registry extraction seam:
`fn name(args) { body }` definitions are recorded before bootstrap parsing, body payloads
are parsed as ActionIR `action_block` AST, and the definitions are projected through the
public descriptor. During rule ActionIR lowering, the compiler threads that registry into
the value-expression lowerer so registered exact-arity calls execute as value-producing
expressions. Registered standalone calls and receiver chains are classified through the
same registry as canonical `VALUE_DROP` statements, so the call value is computed and
discarded without raw fallback. Recursion and unsupported function-body forms are fenced
as unresolved-helper diagnostics.

The Rust backend implements the same stage end to end for the MVP surface: it extracts
top-level function definitions into `SpecFile.functions`, validates their names and
params before runtime, compiles bodies into `CompiledUserFunction` records with parsed
`CodeBlock` bodies, resolves registered calls before helper fallback, executes them in
fresh function-local stores, and lets returned values continue through compatible
receiver-dot chains. Standalone registered calls execute and discard their result.
This closes the portable MVP surface: top-level `fn name(args) { ... }` with explicit
parentheses and a braced value-oriented body. Alternate spellings, optional zero-arg
parentheses, brace-less bodies, caller-state-mutating functions, recursion,
closures/lambdas/currying, and function namespaces are future extension topics, not
current parser/compiler/runtime behavior.

ADR 0030 adopts the next versioned signature, now implemented by Perl, Rust, Dart, and Julia:

```text
fn collect(prefix, ...items) {
  return({ "prefix": prefix, "items": items })
}
```

Version-1 fixed definitions keep exact `params`/`arity`. A version-2 variadic definition carries a neutral
`callable_signature` with fixed `positional_params`, one final `rest_param`, `min_arity`, and an unbounded
`max_arity`. Calls stay positional and eagerly evaluated; extras bind as one fresh typed array, including an empty
array when there are no extras. `capability_conformance/callable_signature_contract.json` and its offline checker
lock this target. Perl's spec-owned shell emits the v2 record, `LinkedSpec::UserFunctionRegistry` validates and
preserves it through staged payload/job and outward descriptor projection, and generated source evaluates all
arguments into ordered temporaries before binding fixed values and a new rest array. Rust validates one typed
signature through parsed/compiled records, staged and public projection, serialized generated source, and native
or generated-plan execution; its function-local runtime binds the same fresh typed array. Dart preserves the same
union through its spec shell, AST/staged jobs, registry/action resolver, descriptor, normalized emitted state, and
native/generated execution; registered keyword arguments diagnose instead of leaking Dart named-argument rules.
Julia carries the same typed union through its spec projection, staged jobs, registry/action resolver, outward
descriptor, native runtime, canonical JSON/ASCII-hex emitted state, generated-plan execution, and reconstruction.
Its registered calls likewise reject keyword arguments and bind a newly copied vector into fresh scalar/array
stores. Fixed calls still require exact arity; variadic calls require at least `min_arity`. Lua now preserves the
same exact state union and resolves the minimum/unbounded arity through native `.5.1.3.1`; `.5.1.3.2` now executes
fresh typed rest arrays and the unchanged neutral fixture. Descriptor admission remains `.5.3`, and generated
owners remain `.8.1-.4`. Planning `.8.1.0` made that boundary explicit: emitter core `.8.1.1` reconstructs the
effective fixed-v1, variadic-v2, and final-codeblock-v3 state union, and isolation `.8.1.2` executes persisted valid
and corrupt modules in fresh PUC Lua and LuaJIT processes with exact cleanup. Lua `.8.2` closes exact family
execution, `.8.3` closes contract-sourced interpreter-first 8/105 fresh-host admission at 177/177 per ABI, and
sole closeout `.8.4` adds Lua to the complete five-backend native/generated contract at 80/0/0.

The current fallback boundary is deliberate. Malformed helper forms already covered by
the typed AST path report unresolved-helper metadata instead of silently becoming Perl
host calls. Retired helpers and non-DSL host-shaped statements remain explicit
compatibility debt, and a few narrow return payload compatibility shapes are still
fenced. Unknown typed calls and receiver chains are reserved for user-defined function
resolution; they must not become a broad host-language fallback. The Perl reference now
diagnoses those calls in return/value positions. In standalone statement position,
registered user-function calls/chains lower as `VALUE_DROP`; unregistered call-shaped
statements remain raw compatibility debt.

## Why the pipeline matters

Understanding the pipeline helps explain:

- where failures happen
- why diagnostics have stages
- how runtime/context metadata is preserved
- why internal state models exist

It also makes clear that the reference implementation is no longer best understood as one giant monolithic script (historically the Perl backend's `LinkedSpec.pm`).

## Stage 1: prepare the compile pipeline

Pipeline preparation normalizes options and callback ownership before real parsing begins.

This is where the compiler knows about requested options such as:

- `top_rule`
- `return_descriptor`
- runtime context plumbing

The Perl reference no longer accepts a parser-wide `parse_mode`; it rejects that retired option during option
preparation. Rust also removes its static and runtime-context override: `ExecutionOptions` selects only an entry
rule, and every entered rule derives seek/consume from its authored family. Its composed 15-role admission locks
native, reconstructed, generated, descriptor, primary, and diagnostic projections. Dart also removes its engine,
loader, corpus, staged-parser, and primary-command global override; Julia removes the corresponding high-level
state too. Lua still retains that staged option until `.9.1.7.5`. Pipeline preparation must therefore not be read
as a semantic license for a caller-global cursor policy.

Two specialty compilation modes are also set here: `parse_only` (build compiled rule-table state without generating handlers or emitting parser code) and `generate_only` (regenerate handlers from an already-compiled rule table without re-parsing). These modes support introspection and tooling workflows that need intermediate compiler artifacts.

The preparation stage also makes diagnostics better. If an invalid option or malformed callback surface is detected before parsing starts, the error can still be attributed to `compiler_pipeline:prepare_pipeline` instead of escaping as an arbitrary low-level failure.

## Stage 2: extract user-function registry

Before ordinary rule validation/bootstrap, active backends extract top-level user-function definitions into a
registry by executing `specs/user_function_definition.spec`. This bridge recognizes only top-level
`fn name(args) { body }` declarations, preserves the returned source/body spans, neutral body payload, and neutral
body parse-job sidecar, and blanks the original source region while preserving newlines. The stripped source then
flows through the existing rule-validation and bootstrap-parser path.

This stage rejects malformed definitions, duplicate function names, reserved names, built-in helper/control-name
collisions including numeric word aliases, invalid or duplicate parameters, and later rule-label collisions. Execution is not done in this
extraction stage; the registry is passed forward so the rule action-lowering stage can resolve value-position
calls.

## Stage 3: validate the source envelope

Before bootstrap parsing, LinkedSpec validates obvious `.spec` source-shape problems through a dedicated validation owner (in the Perl reference backend, `LinkedSpec::Validation` — 1,368 lines, its largest single-purpose validation owner).

This stage exists to reject malformed input early and clearly. The validation owner provides three layers of defense:

**Envelope validation** (`validate_spec_content`): checks the input is a non-empty SCALAR ref and verifies that the
first content line is a valid rule label. The Perl reference validator now requires one or more rules rather than a
`RuleName::` marker. Its ordered resolver applies ADR `0046` / `linkedspec-root-rule-selection-v1`: explicit
selector > first authored marker > first authored rule. Rust and Dart implement the same marker-optional envelope
and ordered resolver across composed routes. Julia core validation plus loaded/normalized/generated/emitted
direct/traced routes now do too; its generated plan still validates before selection and remains the minimal
ordered label/family shape. Lua core and composed routes now apply the same marker-optional resolver on PUC Lua
and LuaJIT, including portable zero/unknown failures and generated-plan-first ordering.

**Paragraph-level validation** (`validate_dsl_syntax`): the deepest layer. It detects duplicate rule definitions, rejects rule definitions inside still-open blocks, checks that action edges (`->`) and blind-call edges (`=>`) have valid target labels and block-depth balance, rejects mixed action/blind-call modes within one rule, validates Perl regex literals for compile-ability, verifies rule-header right-hand-side content, checks split-marker syntax, and reports unused/undefined rule references. When `strict_syntax => 1` is set, unused-rule and undefined-reference warnings become hard errors, which is useful for CI regressions.

Lua normalization now retains complete-line/header-rest bare child members as typed AST before validation. Once
the whole declared-label set exists, an AND-parent bare member owns blind dispatch and an OR/default-parent bare
member owns action dispatch. Undefined targets, indexed/grouped AND bare forms, mixed ownership, indexed blind
calls, and blockless grouped actions return the same portable stage/code/fields as the admitted backends. Valid
members lower into existing compiled action/blind tables; cursor execution remains the following runtime stage.

**Cross-reference validation** (`validate_dependency_regex_references`): checks that every dependency-regex entry references a rule that exists, every rule reference targets a valid regex index, and every rule's `dependency_refs` entries carry the required `label`/`idx` keys.

Errors from any layer carry structured payloads with `summary`, `detail`, and `rule_label` fields routed through the `on_failure` callback. Context-aware helpers like `get_dsl_context` correlate error positions with line numbers and surrounding source lines.

The high-level principle: malformed input should be rejected with targeted, debuggable messages before it reaches the bootstrap parser, the compiler state models, or (worst) the generated handler runtime.

## Stage 4: bootstrap parse

The bootstrap parser reads the `.spec` source and produces parsed rule entries.

This stage is still special because LinkedSpec uses a bootstrap grammar to parse the language that defines LinkedSpec parsers. That bootstrap layer is owned separately from the main compiler state model.

**Dual-path parse**: LinkedSpec also runs a second parse through the self-hosted `spec.spec` grammar as a diagnostic side channel. `BootstrapSpec::run_bootstrap_parse()` executes both the hardcoded bootstrap parser (always the primary output for format compatibility) and the `spec.spec`-generated parser, enabling cross-check comparisons via `tools/cross_check_spec_parsers.pl`. A recursion guard prevents infinite loops when `spec.spec` tries to parse itself. The self-hosted `spec.spec` is a faithful description of the format the bootstrap recognizes — it reproduces the bootstrap oracle's paragraph grouping across all shipped specs — so the two paths agree on structure even though the hardcoded bootstrap remains the primary parser.

Top-level `fn name(args) { ... }` function definitions are active in `spec.spec`, and the Perl reference records
them through a temporary pre-bootstrap registry bridge before this parse stage. The bridge removes function
definitions from the source handed to the hardcoded bootstrap parser while preserving newlines, then attaches the
validated registry to compiled state. This keeps the permanent grammar owner in `spec.spec` without making the
bootstrap parser the lasting owner of `fn` syntax. The registry is also made available to rule ActionIR lowering,
where registered value calls and standalone discard calls are compiled on the Perl reference.

## Stage 5: build compiled rule-table state

The active low-level compiler seam is:

```text
build_compiled_rule_table(...)
```

Its job is to convert parsed rule entries into `compiled_spec_state`.

That state owns:

- deterministic definition information
- compiled rule order
- the user-function registry used by rule action lowering and descriptor projection
- rules by label
- redefinition metadata
- per-rule compiled info such as regexes, handlers, dependency refs, and rule metadata

This is the compiler’s rule source of truth.

## Stage 6: build dependency-regex state

The next derived stage is:

```text
build_dependency_regex_map(...)
```

Despite the public name, the active internal path can build an explicit `compiled_dependency_regex_state`.

That state is derived from compiled rules. It exists because generated handlers need efficient combined regex dispatch for referenced child-rule regexes.

## Stage 7: build compiled descriptor state

Once compiled rule state and dependency-regex state exist, the compiler builds:

```text
compiled_descriptor_state
```

This internal state composes the two earlier state records.

It is important that validation happens against this internal state before projecting the outward descriptor. That keeps the compiler on explicit, owned structures rather than bouncing back into older loose hash shapes too early.

## Stage 8: validate descriptor state

Generated-descriptor validation checks that the compiled rule state and dependency-regex state agree.

For example, dependency references must point to rules and regex indexes that actually exist.

When validation fails, the compiler can preserve structured attribution such as:

- owner/stage
- selected top rule
- rule label
- handler source label
- specific summary/detail text

## Stage 9: project descriptor or return parser

The final public result depends on options. The entry point shown below (`LinkedSpec::Get(...)`) is the Perl reference backend's surface — see [`Get(...)` and `get_parser(...)`](../public-api/get-and-get-parser.md) for the backend-neutral roles and options.

Default behavior returns a parser coderef:

```perl
my $parser = LinkedSpec::Get(\$spec);
```

Descriptor mode returns the outward descriptor:

```perl
my $descr = LinkedSpec::Get(
  \$spec,
  return_descriptor => 1,
);
```

The outward descriptor is not the compiler’s only internal truth. It is a public/tooling projection of the state-first model.

## Runtime wrapper

Parser invocation is wrapped with a comment and blank-line skip loop. Before each match attempt the wrapper advances the cursor past any leading whitespace-only lines or `#`-to-end-of-line comment lines, so grammar rules do not need to handle these themselves. This skip wrapper is applied at runtime on every generated handler invocation, keeping the grammar surface clean. (In the Perl reference backend this is `Runtime::run_get` advancing `pos($$input_ref)`.)

# Backend Handoff

This chapter is the **single entry point** for anyone building a LinkedSpec backend
in a new language (Rust, Dart, Julia, Lua, etc.). It links every specification, contract,
and test artifact you need — in reading order.

## What You're Building

A LinkedSpec backend compiles `.spec` grammar files into runnable parsers. It must:

1. Parse `.spec` files according to the formal grammar.
2. Parse helper/action language text into typed AST/IR nodes before lowering,
   interpretation, or code emission.
3. Preserve staged linked parsing semantics: extracted text payloads can become
   source-provenance parse jobs routed to later `.spec` parsers.
4. Compile the parsed model into runtime handlers via the HandlerIR pipeline.
5. Execute those handlers with identical semantics to the Perl reference.
6. Pass the language-neutral test corpus.

The backend contract is implementation-language neutral. The same `.spec` source,
AST payloads, parse-job metadata, descriptors, diagnostics, and parser entry semantics
apply whether the implementation is Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or a
future language.

The scheduled future full-parity rollout is Dart first, Julia second, and Lua third
(ADR 0021). That order affects task-tree sequencing only; the conformance contract is
the same for every backend.

Text-to-AST is a backend conformance rule, not an optional implementation style.
Do not build a backend by applying textual helper rewrites directly into host-language
source. The Perl reference now has an additive `LinkedSpec::ActionIR::AST` parser seam
for calls, literals, variables, direct access, shape literals, block values,
assignments, expression statements, and receiver-dot chains. Its `MethodLowering`
consumer has started using that AST for non-call value expressions: primitive literals,
scoped bare scalar reads, direct indexed/nested access, shape literals, and block
values. It also lowers value-only helper-call composition from AST `call` nodes for
scalar normalization, string predicate/composition, coalesce/concat, and scalar-argument
numeric helpers. It also lowers aggregate-wrapper, collection/reducer, and hash helper
calls from AST `call` nodes while preserving their existing symbol/value slot policy.
Bare scalar reads plus canonical aggregate wrappers `array(...)`/`hash(...)` remain the destination
surface; short wrapper aliases `s(...)`/`a(...)`/`h(...)` are retired and should be reported
as unresolved helpers rather than normalized. Unsupported covered helper
forms now report unresolved-helper metadata instead of leaking as generated host-language
calls. Receiver-dot value chains now lower from AST `fluent_chain` nodes for the array,
hash, string, and number receiver families before the legacy receiver-dot text normalizers
run. Generalized return payloads now lower typed value/call/chain nodes through the same
AST traversal before raw fallback, while narrow untyped compatibility payloads still
remain migration debt. Assignment and mutation operator statements now consume typed AST
target/key/value fields before legacy fallback. Helper-call statements and returns now
consume typed AST `call` fields for `set`, `set_key`, `push`, `return`, and
`return_undef`, and array end-mutation receiver statements
consume typed AST `fluent_chain` fields. Expression-valued block side effects,
block-local returns, and final block expressions now consume typed block/statement AST
fields. Structured control-flow lowering now consumes typed AST fields for the if/when,
switch/case/default, and attached-while statement families. Standalone supported value
statements now produce canonical `VALUE_DROP` events: the backend computes the typed
value expression and intentionally discards the result. Unknown typed calls and
function-call receiver chains in return/value positions now use the unresolved-helper
diagnostic path instead of becoming generated host-language calls.
Top-level `fn name(args) { body }` definitions are now accepted and recorded in the Perl
reference descriptor registry. Each definition carries params, arity, source/body spans,
body source, and an ActionIR body AST. The registry rejects duplicate functions,
reserved names, built-in helper/control collisions, rule-label collisions, and invalid
or duplicate parameters before runtime. The Perl reference now resolves registered
exact-arity calls during value-expression lowering; wrong-arity registered calls remain
unresolved-helper diagnostics with zero raw fallback. Registered standalone calls and
receiver chains now lower as canonical `VALUE_DROP` statements on the Perl reference.
The Rust backend carries the same definitions through parsed and compiled registry
records and executes the MVP runtime surface: registered calls resolve before helper
fallback, run in fresh function-local stores, feed compatible receiver chains, and
discard standalone results.
The function surface is closed at that MVP boundary. New backends should implement
top-level `fn name(args) { ... }` with explicit parentheses and braced, value-oriented
bodies. Do not add alternate spellings (`function ... endfunction`, `fn ... endfn`),
optional zero-argument parentheses, brace-less bodies, caller-state-mutating functions,
recursive user functions, closures/lambdas/currying, or function namespaces unless a
future task-tree leaf and contract explicitly adopt them.

Staged linked parsing is also a backend conformance rule. A backend must be able to
represent an AST node that contains extracted text and a parse intent, then dispatch that
payload to a deterministic next parser while preserving source spans and parent-node
context. One stage can emit several different parse-job kinds; each kind may route to a
different next-stage `.spec`. This is different from spec imports: imports compose grammar
files, while staged dispatch parses runtime payload text already extracted by a parser.
For `.spec` language evolution, `specs/spec.spec` is the first authoritative grammar and
later `.spec` stages derive from its parsed payloads rather than a competing permanent
bootstrap grammar.

The accepted parse-job annotation design is `parse_job(text_expr, options)` once
implemented. It yields a marker value plus sidecar metadata: deterministic job id, parent
AST path, node kind, payload kind, exact text, source span, parser spec id, optional top
rule, result policy, and failure policy. Result policies are `replace_marker`,
`replace_field`, `sibling_field`, and `append_child`; failure policies are `fail`,
`keep_text`, and `diagnostic_node`. Backends must treat this as a neutral metadata
contract, not a host-language callback surface. Current shipped parsers do not yet accept
or execute `parse_job(...)`.

The accepted staged dispatch design is also neutral. Implement a registry with
`resolve`, `load`, `compile`, and `execute` operations. Resolution order is parent
import aliases/composed identities, declaring-spec-relative paths, configured search
roots, then explicit registry providers. Cache compiled parsers by normalized spec
identity, content digest, import/include graph fingerprint, selected top rule, `.spec`
language version, helper/action contract version, staged parsing contract version, and
backend capability set. Dispatch jobs in stable parent-AST-path/source-span/job-id order,
and diagnose active-chain cycles that repeat spec identity, top rule, payload digest, and
source span. Current shipped parsers implement only the first narrow function-body
provider; general staged registry/provider search and recursive dispatch queues remain
future work.

The first prototype target is user-function body payloads. A backend should treat that
as a narrow proof of the neutral staged contract: `specs/spec.spec` extracts a bounded
body payload, a parse job names the next parser/top rule, source provenance is preserved,
and the refined body AST is stitched back deterministically. Do not copy a Perl or Rust
bridge as the semantic model; host implementation details are adapters around the
`.spec`/AST contract.

The proof must include an AST-shape oracle for the returned function-definition node.
Runtime equality alone is not enough: a backend must be able to predict and then assert
the `function_definition` AST shape, including the refined body payload and provenance
fields that staged dispatch is responsible for. That oracle should be fed by a large
variation suite for the spec rule returning the AST: whitespace forms, arity forms,
nested blocks, quoted strings, regex-looking payloads, adjacency to rules or other
definitions, and invalid definitions with expected diagnostics. Use a dedicated small
spec file/top rule for those focused AST-shape tests when that gives a tighter harness.

For backend implementers, the expected harness is a wrapper top rule that dispatches to
a normal `function_definition` rule and returns collected nodes. The function rule must
not rely on compacted numbered captures for optional fields. The neutral returned node
uses parsed parameter arrays, exact inner body text, neutral source/body spans, a
function-body parse-job field, and a stitched body AST after dispatch.

The current provenance seam is the neutral `body_payload` plus `body_parse_job` returned
by `specs/user_function_definition.spec`. Neither field is a backend callback.
`body_payload` contains exact function-body text,
half-open source span, source-slice provenance, source-order parent path, function name,
params, arity, `node_kind = function_definition`, and `payload_kind = function_body`.
`body_parse_job` is the parse-intent sidecar for that payload: deterministic job id,
parent AST path, parser spec identity, top rule, result/failure policies, exact text,
source span, and diagnostic ownership. The Perl reference and Rust runtime both consume
that spec-returned AST today and normalize the source-order path/job id once the function
ordinal is known. They dispatch that job through the minimal staged parser registry:
`resolve` maps `actionir-body.spec` to a built-in provider identity, `load` records the
adapter contract digest, `compile` selects top rule `action_block`, and `execute` returns
the body `action_block` AST stitched into `body_ast`. General provider search roots,
imports, and recursive staged queues remain future work. The spec's body shell is a
linked opener/closer parse: `body_brace`
handles nested brace islands, quoted strings, comments, and regex literals are protected
before brace dispatch, and the outer close is matched by `function_definition[1]`.
Backends must converge on this same spec-defined AST contract instead of maintaining
host-language definition grammars as the staged dispatch queue becomes portable.

Rust is interpreted rather than generated Perl source, so the inspectable artifact is
the compiled rule table plus lifecycle/action expression AST rather than emitted handler
code. The Rust adapter still follows the same contract: it executes
`specs/user_function_definition.spec`, validates the returned nodes, strips definition
spans, dispatches normalized body parse jobs through the staged registry adapter, and
only then passes rule-only source to the core parser.

Spec import/composition is a separate backend conformance target once implemented. The
accepted design uses file-scope `import "path.spec" as alias` and
`include "path.spec"` directives. `import` creates a qualified namespace such as
`alias.Rule`; `include` performs a structured merge into the current unqualified
namespace. Implement this as parsed `.spec` composition, not raw text concatenation.
Backends must agree on resolution order, normalized spec identities, duplicate-name
diagnostics, import-cycle diagnostics, source provenance, and descriptor fingerprints.
Current shipped parsers do not yet accept these directives, so do not treat them as a
runtime requirement until the implementation leaf lands.

The remaining fallback boundary is not a backend pattern to copy. Malformed helper forms
already covered by the typed AST path report unresolved-helper metadata rather than host
calls. Retired helpers, non-DSL host-shaped statements, and a few narrow return payload
compatibility shapes remain fenced migration debt. Unknown typed calls and receiver
chains are reserved for user-defined function resolution and diagnostics, not broad
host-language fallback. In the Perl reference, return/value-position unknown calls
currently diagnose. Standalone registered calls/chains lower as `VALUE_DROP`, while
unregistered call-shaped statements remain raw compatibility debt. New backends should
follow the typed-AST model used by the Rust implementation from the start, including a
validated function registry before runtime resolution.

You do **not** need to read the Perl source code. Every behavioral contract is
specified in the documents below.

## Reading Order

### Step 1: Understand the Big Picture
Read the [ADR 0006](../../../docs/decisions/0006-multi-backend-vision.md) — the multi-backend
decision record. It defines the lockstep contract: same `.spec` files, same semantics,
same test corpus across all backends.

### Step 2: Learn the `.spec` Language
Read the [Formal `.spec` Grammar](formal-grammar.md). This is the definitive syntax
reference. A valid backend must accept exactly this language. No Perl bootstrap parser
knowledge is needed.

### Step 3: Understand Runtime Behavior
Read the [Runtime Semantics](runtime-semantics.md). This defines how `.spec` rules
execute: parse modes, lifecycles, explicit cursor controls, accumulators, edge dispatch, repetition
bounds, and determinism guarantees. Two independent implementations of this document
must produce identical parser behavior.

### Step 4: Implement the Helper Surface
Read the [Helper Contract Catalog](helper-contract-catalog.md). Every helper function
(100+ across 10 families) is documented with its signature, type contract, behavioral
semantics, and edge cases. Implement these helpers in your target language — they
are the building blocks users write in `.spec` lifecycle blocks.

### Step 5: Implement HandlerIR
Read the [HandlerIR Specification](../../../docs/knowledge/handler-ir-design.md). The
HandlerIR is the structured AST between the compiler and code generation. Your backend
writes an **emitter** that consumes HandlerIR nodes and produces runnable code in
your language. The JSON diagnostic backend (`_emit_handler_json`) proves the pattern.

The Rust backend currently executes an interpreted structural model
(`CompiledSpec`/`CompiledRule`) rather than direct generated Rust handlers. Its
generated-source path is tracked separately under `RUST-PARITY.8`: `.8.1`
split the work, `.8.2` added the minimal scaffold/compile-run proof, and
`.8.3.1` added a generated rule-family plan. `.8.3.2` made default/OR acode
families run directly, `.8.3.3` made AND single/sequential acode families run
directly while enforcing ordered non-repetition AND regex/acode sequence
semantics, and `.8.3.4` made AND/OR bcode families run directly with shared
blind-edge tail execution. `.8.3.5` closed the non-repetition matrix by making
generated-plan routing exhaustive for all six non-REP generated families and by
asserting that family coverage in the source-emitter matrix. `.8.4` added direct
generated execution for the four explicit REP subfamilies (`RepAcode`,
`RepBcode`, `RepAndAcode`, and `RepAndBcode`), including bounded repetition,
zero-progress termination, and same-position recursive-call guard coverage.
`.8.5` integrated the generated-source proof with the oracle corpus: the
source-emitter test still compiles and runs an all-family generated matrix, and
it now also compiles/runs a curated subset selected from the checked-in
`rust/linkedspec-runtime/tests/corpus/manifest.json`. That generated-source corpus subset includes
authored proof fixtures, terse helper/control/user-function fixtures, and
shipped `tclite`/`portmap` smokes. This is deliberately a subset proof; the
full 99-fixture corpus remains the Rust interpreter oracle gate unless a later
leaf explicitly broadens generated-source corpus coverage.
`RUST-PARITY.9` closed the Rust follow-on documentation state around that
boundary: interpreter parity is the 99-fixture corpus contract, while generated
source currently proves direct structural-family execution plus the curated
manifest subset.

The completed scoped Dart milestone follows the same parity ordering. `DART-BACKEND-PARITY`
landed interpreter-first: `.spec` parser, typed helper/action AST, compiled-spec
state, Dart runtime interpreter, then the manifest-backed corpus runner.
Generated Dart source is explicitly deferred to a future split source-emitter
lane after interpreter/corpus parity, not the primary conformance gate. The repo now has a Dart backend package under
`dart/`, including package metadata, committed lockfile, public library entrypoint,
Dart-specific CLI entrypoint, compatibility corpus-runner entrypoint, and smoke tests. Its corpus layer loads the
manifest-backed corpus, rejects manifest drift, checks required fixture files and
expected JSON syntax, and the Dart library exposes `executeCorpusFixtures(...)`
for controlled manifest fixtures. That executable harness runs fixtures through
the Dart parser, compiler, and runtime engine, then compares engine output to the
backend-neutral expected value wrapped one level with structural JSON equality.
It supports named and bounded fixture selection through the library and opt-in
CLI `--execute` mode; without a selector, the CLI runs the full manifest in
order. The Dart-specific CLI exposes this as
`dart run bin/linkedspec_dart.dart corpus --corpus <path> [--execute] ...`;
`bin/corpus_runner.dart` remains a compatibility wrapper for corpus-focused
diagnostics. The checked-in 99-fixture manifest passes through Dart execute mode,
covering the starter proof-edge, autoexist, mutation, core terse runtime,
middle helper/control/receiver, shipped-spec/parser-smoke, and top-level
function groups. The top-level `fn` corpus fixtures route through the spec-defined function shell: Dart obtains
spec-produced `function_definition` nodes, feeds them through staged body
projection, and does not raw-scan `fn` source in the corpus runner. The final shipped-spec/parser-smoke window started
at 2/31 green, reached 7/31 green after the regex-dialect, helper/action, and
recursive/default-mode bridges, reached 13/31 green after the portmap result-shape bridge, reached 19/31 green
after the hlink delimiter/capture bridge, reached 22/31 green after the helper mutation/text-normalization bridge,
reached 24/31 green after the legacy accumulator, public-parser leading-trivia, and final no-drift closeout
leaves, and is now 31/31 green after the structural regex closeout. The parser-smoke group is closed. The
portmap/action-edge result-shape leaf is
done: Dart `array(...)` splices explicit `flat*` arguments, all five portmap fixtures pass, and `vhdl_library_use`
also passes. The hlink leaf is also done: Dart `call(...)` refreshes `retv`, append-style mutations update
scalar-held lists, all five hlink fixtures pass, and `tablegrep_simple_term` also passes. The helper mutation leaf
is also done: statement-form `substr(...)` / `regex_subst(...)`, explicit split replacement, and entry/local line
helpers make `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute` pass. The basic
legacy accumulator leaf is also done: Dart `push(Child)` now appends child returns to the current rule accumulator,
so `regdef_nested_register_fields` passes. The `ds_vhistory` public-parser bridge is done too: Dart now mirrors
Perl's leading blank/comment-line skip before the top rule, so `ds_vhistory_version_entry` passes without
weakening ordinary scalar-held indexed reads. The regex-dialect
bridge is now in place for POSIX classes, inline/scoped flags, possessive
markers, lower-bound quantifiers, and Python-style named captures. Scoped flag
groups are accepted by lifting their options to the Dart `RegExp`. The missing
helper/action bridge is also in place for direct capture-slice helpers,
diagnostic output helpers, logical helpers, `exit_now`, and quoted helper-call
delimiter parsing. The recursive/default-mode bridge is in place too: compiled
action edges carry resolved regex-dispatch metadata, edge-only child regexes are
folded into the parent alternation, and explicit aggregate resets are scoped to
the current rule invocation. The structural regex leaf is now closed too:
bounded Dart matchers handle the exact shipped Lispish `(?R)`, EBNF `\K` /
`(?&name)` / `(?(DEFINE)...)`, and spec.spec recursive block forms, while
action-edge `push(child, index)` preserves indexed child payloads. The
Dart-specific LinkedSpec CLI productization is now done, and
`DART-BACKEND-PARITY.7.5` closes the scoped interpreter-first milestone.
`FUTURE-PARITY-BACKLOG.1.2` creates the dedicated `JULIA-BACKEND-PARITY`
plan. `JULIA-BACKEND-PARITY.1.1` has completed Julia toolchain/package-layout preflight, `.1.2` has created the
minimal Julia package scaffold, `.1.3` has added manifest-backed corpus IO and drift detection, `.2.1` has
added source AST/data types with neutral JSON projection, `.2.2` has added the source parser, `.2.3` has added
frontend validation and strict syntax behavior, `.2.4` has added spec-shaped top-level `fn` shell projection, and
`.3.1` has added typed helper/action AST parsing, `.3.2` has added ActionIR contract resolution, `.3.3` has added
the user-function registry seam, `.3.4` has added compiled-spec state, and `.4.1` has added runtime regex matching
and match-state tracking. `.4.2` has added first compiled-rule dispatch, and `.4.3.0` has split helper/value work by
runtime mechanism. `.4.3.1` has added core scalar/array/hash stores, typed snapshots, assignments/access, checked
nested writes, and capture maps/positions. `.4.3.2` has added string/scalar and numeric helpers, regex flags,
aliases/symbol callees, invalid-input boundaries, and compatible receiver chains. `.4.3.3` has added copied array
pipelines, split/flatten/reducer bridges, and statement-only end mutations. `.4.3.4` has added copied hash views
and transformations, statement-only named set-key mutation, direct hash-index assignment, merge-slot resolution,
and explicit flat-style splicing. `.4.3.5` has added expression-valued blocks, attached/marker/inline controls,
deterministic while guards, immediate helper/receiver with-blocks, and scoped hash/array tree callbacks. The
`.4.3.6` closeout confirms helper/value no-drift at 567 assertions without a runtime correction. `.4.4` adds an
explicit LIFO cursor stack, entry/local anchor rewinds, synchronized live/register cursor updates,
character-based cursor/input helpers, and earliest usable non-consuming named-rule boundary capture. Full Julia
tests pass with 581 assertions and package status `runtime-cursor-boundary`. `.4.5.0` splits diagnostics/trace
before code; `.4.5.1` now adds structured runtime diagnostics with spec/top/rule/handler attribution and
successful-output preservation. Full tests pass with 588 assertions, status is `runtime-diagnostics`, and
`.4.5.2` now adds ordered levels, environment/config controls, structured events/scopes/decisions/logs/dumps,
stdout/route/mirror sinks with reset, and output-preserving traced entrypoints. Full tests pass with 617
assertions, status is `runtime-trace-controls`, and `.4.5.3` is active for runtime instrumentation.
Future Julia and
Lua backend plans must own their own
variant-specific CLIs rather than relying on one
ambiguous shared command.

### Julia Backend Scaffold

`JULIA-BACKEND-PARITY.1.1` through `.4.2` are complete. The local Julia toolchain is Homebrew-managed:
`/opt/homebrew/bin/julia` reports Julia `1.12.6`, and the official Julia downloads page lists `v1.12.6` as the
current stable release. `Pkg` and `Test` work when Julia has a writable depot; under the managed harness, commands
can set `JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot` to avoid writing precompile artifacts into
`~/.julia`. The Julia package now depends on `JSON3` for manifest and expected-JSON parsing. Global
`JuliaFormatter` and `JET` packages are not installed today, so formatter/linter commands are optional until a
scaffold or verification leaf commits them as dev dependencies.

The current Julia package scaffold is:

```text
julia/
  Project.toml
  Manifest.toml
  README.md
  src/LinkedSpecJulia.jl
  src/cli/LinkedSpecJuliaCli.jl
  src/corpus/CorpusManifest.jl
  src/spec/Ast.jl
  src/spec/Parser.jl
  src/spec/UserFunctionDefinitionShell.jl
  src/spec/Validator.jl
  src/action/ActionAst.jl
  src/action/ActionParser.jl
  src/action/ActionContracts.jl
  src/action/FunctionRegistry.jl
  src/compiler/CompiledSpec.jl
  src/runtime/Matching.jl
  src/runtime/Interpreter.jl
  bin/linkedspec_julia.jl
  bin/corpus_runner.jl
  test/runtests.jl
```

The first command surface is:

```bash
julia --project=julia -e 'import Pkg; Pkg.instantiate()'
julia --project=julia -e 'import Pkg; Pkg.test()'
julia --project=julia julia/bin/linkedspec_julia.jl --help
julia --project=julia julia/bin/linkedspec_julia.jl status
julia --project=julia julia/bin/linkedspec_julia.jl corpus --corpus rust/linkedspec-runtime/tests/corpus
julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus
```

The corpus commands validate `manifest.json`, case-count/name shape, missing/stale fixture directories, required
`input.spec` / `input.txt` / `expected.json` files, and expected JSON syntax over the checked-in 99-fixture corpus.
`--execute` still reports not implemented. `julia/src/spec/Ast.jl` defines data records and JSON projection for
spec files, function definitions, source spans, staged parse jobs, rule headers/modes, body element variants, edge
targets, and fluent calls. `julia/src/spec/Parser.jl` exposes `parse_spec(...)`, which parses core `.spec` rule
paragraphs into those source AST types: headers/modes, regex slots, lifecycle blocks, action/blind-call edges,
fluent continuations, markers, comments, and block boundaries. `julia/src/spec/Validator.jl` exposes
`validate_spec(...)`, which validates parsed source ASTs for top-rule presence, duplicate labels/functions,
function registry collisions and reserved params, raw fallback lines, mixed edge families, grouped action blocks,
undefined references, regex-slot bounds, regex structure, and strict unused-rule behavior.
`julia/src/spec/UserFunctionDefinitionShell.jl` consumes the `function_definition` / `function_definition_error`
node shape produced by `specs/user_function_definition.spec`, validates source/body spans and staged sidecars,
normalizes `functions.<index>.body_source` parse-job paths, and strips function spans before rule parsing. Direct
`parse_spec(...)` remains rule-only rather than a Julia raw scanner. `julia/src/action/ActionAst.jl` and
`julia/src/action/ActionParser.jl` expose `parse_action_block(...)`, `parse_action_statement(...)`, and
`parse_action_expression(...)` for typed helper/action structures: blocks, value-drop statements, calls, literals,
variables, direct/nested access, shape literals, assignments, receiver chains, trailing block arguments, block
values, structured controls, and raw fallback nodes. `julia/src/action/ActionContracts.jl` exposes
`resolve_action_block_contracts(...)`, `resolve_action_statement_contracts(...)`,
`resolve_action_expression_contracts(...)`, `canonical_action_helper_name(...)`, and
`is_known_action_ir_call_name(...)` for canonical helper/control contract records and generic
unknown-helper/raw diagnostics over those typed nodes. `julia/src/action/FunctionRegistry.jl` exposes ordered
`UserFunctionRegistry` entries, staged function-body parse-job queues, exact-arity user-call resolution, duplicate
name diagnostics, JSON projection, and immutable `body_ast` stitching; `ActionContracts.jl` can use that registry to
classify exact-arity user calls before helper fallback and diagnose wrong registered arities.
`julia/src/compiler/CompiledSpec.jl` exposes `compile_spec(...)`, `CompiledSpec`, `CompiledRule`,
`CompiledDependencyRegexState`, and `CompiledDescriptorState` for ordered compiled-rule state, dependency refs,
dependency-regex rows, mode metadata, lifecycle/action payload ASTs with registry-aware contracts, function registry
projection, and descriptor-shaped JSON with `julia_interpreter_rule` handlers marked `compiled_state_only`.
`julia/src/runtime/Matching.jl` compiles stable zero-based regex alternatives and supports seek/consume selection,
full and compact capture vectors, named captures, zero-based code-unit spans, public character offsets,
line/column projection, cursor/capture anchors, separate entry/local match registers, and zero-progress detection.
Julia's native PCRE engine accepts the required named-capture, POSIX, flag, possessive, and recursive constructs
without a dialect-rewrite layer. `julia/src/runtime/Interpreter.jl` exposes `LinkedSpecRuntimeEngine`,
`runtime_parse(...)`, `runtime_execute(...)`, result/lifecycle/error records, and first execution over compiled
default/AND/OR/repetition families. It runs lifecycle order, action/blind children, `retv`, explicit returns,
narrow array/rule accumulators and capture reads, output projection, repetition bounds, zero-progress cutoffs, and
recursion guards in seek or consume mode. `.4.3.0` splits the broader evaluator into `.4.3.1` core
stores/captures, `.4.3.2` string/numeric,
`.4.3.3` array, `.4.3.4` hash, `.4.3.5` value/control/block/callback, and `.4.3.6` no-drift leaves. `.4.3.1` is now
implemented: scalar/array/hash stores, bare and typed snapshots, structural assignments/access, checked
no-autovivification nested writes, and entry/local capture maps/positions pass focused tests. `.4.3.2` is now
implemented too: current string/scalar and numeric helpers share canonical function/receiver dispatch, retain
regex flags, normalize JSON numbers, and return `nothing` for invalid arithmetic. `.4.3.3` is now implemented as
well: copied array helper/receiver pipelines, regex and split bridges, explicit flatten splicing, numeric reducer
terminals, typed split replacement, and statement-only end mutations pass focused tests. `.4.3.4` is now
implemented too: copied hash views and pure transformations, compatible receiver chains, statement-only named
set-key mutation, direct hash-index assignment, merge-slot resolution, explicit flat-style splicing, and nested-map
preservation pass focused tests. `.4.3.5` is now implemented too: expression-valued blocks with local returns,
attached/marker/inline controls, deterministic while guards, immediate helper/receiver with-blocks, scoped binding
restoration, and hash/array walk/map/reduce callbacks pass focused tests. `.4.3.6` owns final helper/value no-drift.
The closeout confirms runtime tests/status, mdBook contracts, live docs, and fact cards agree at 567
assertions; package status remains `runtime-value-control-tree`, and no runtime correction was required. `.4.4`
adds explicit LIFO cursor save/restore, entry/local anchor rewinds, character-based cursor/input helpers, and
earliest usable non-consuming boundary capture. Full tests pass with 581 assertions and status
`runtime-cursor-boundary`. `.4.5.0` splits diagnostics/trace into structured diagnostics, trace
controls/events/sinks, runtime instrumentation, and no-drift. `.4.5.1` implements exported neutral-field
diagnostic payloads on runtime exceptions while preserving successful output and richer child attribution.
`.4.5.2` implements trace levels/environment/config, event primitives, stdout/route/mirror sinks, parse-scope
routing, and traced entrypoints with default-quiet output preservation. `.4.5.3` owns internal runtime events;
later leaves own staged parser and corpus execution.

### Dart Backend Commands

Run the focused Dart gate from the repository root:

```bash
bash tools/run_dart_local.sh
```

That command runs Dart formatting, analyzer checks, the full Dart test suite,
Dart CLI help checks, a bounded Dart-specific CLI corpus smoke, and full 99-fixture corpus execution. To include Dart in
the canonical local gate on a machine with a Dart SDK, opt in explicitly:

```bash
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
```

Direct Dart commands live under `dart/`:

```bash
dart test
dart run bin/linkedspec_dart.dart --help
dart run bin/linkedspec_dart.dart corpus --corpus ../rust/linkedspec-runtime/tests/corpus --execute
dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute
```

Current Dart parity is interpreter-first and corpus-green. `DART-BACKEND-PARITY.7.2`
deliberately defers generated Dart source to a future source-emitter lane with its
own scaffold, generated family plan, direct structural-family execution proof, and
curated corpus subset. Dart-specific CLI productization is complete in
`DART-BACKEND-PARITY.7.4`, and `DART-BACKEND-PARITY.7.5` closes the scoped
Dart milestone; generated source remains outside the current backend-neutral
corpus conformance claim.

Dart
also has source-level AST/data types and staged parse-job sidecars that round-trip
through JSON with the Rust/mdBook field names. The Dart core `parseSpec(...)`
parser now produces those source AST types for rule paragraphs, headers/modes,
regex literals, lifecycle blocks, action/blind-call edges, fluent continuations,
markers, comments, and nested block boundaries, with tests over all checked-in
`specs/*.spec` files and rule-only corpus specs. Dart `validateSpec(...)` then
checks top-rule presence, duplicates, source-AST edge consistency, target
references/indexes, regex structure, malformed raw body lines, and strict-mode
unused rules. Dart also has the first function-shell projection layer:
`parseSpecWithUserFunctionDefinitionAsts(...)` consumes the
`function_definition` / `function_definition_error` nodes returned by
`specs/user_function_definition.spec`, validates source/body spans and staged
`body_payload` / `body_parse_job` sidecars, normalizes source-order parent paths
and parse-job ids, strips returned definition spans before rule parsing, and
attaches ordered `FunctionDefinition` records. This is not a Dart raw scanner for
`fn` source. The corpus runner now obtains the semantic node list by executing
`specs/user_function_definition.spec` through Dart runtime shell code and then
feeds those nodes through staged function-body projection.

Dart now also has a typed ActionIR parser seam. `parseActionBlock(...)`,
`parseActionStatement(...)`, and `parseActionExpression(...)` produce structural
nodes for helper/action code: action blocks, value-drop statements, calls,
positional and keyword arguments, primitive and regex literals, variables,
indexed/nested access, array/hash shape literals, scalar/array/hash/nested
assignments, expression-valued blocks, attached `if`/`when`/`elseif`/`else` /
`otherwise`, `while`, `switch`/`case`/`default`, receiver-dot fluent chains, and
trailing block arguments. Unsupported expressions remain explicit `raw_perl`
nodes for diagnostics. Dart also has ActionIR contract resolution:
`resolveActionBlockContracts(...)`, `resolveActionStatementContracts(...)`, and
`resolveActionExpressionContracts(...)` walk the typed nodes and record current
canonical helper/control contracts for calls, receiver methods, structural
assignments, controls, nested arguments, block values, shapes, and access
expressions. Non-current helper-looking calls produce generic diagnostics rather
than host-language fallback. Dart also has the first user-function registry seam:
`UserFunctionRegistry.fromSpec(...)` / `fromFunctions(...)` preserve ordered
`FunctionDefinition` records, expose their staged function-body parse jobs, keep
`body_payload`, `body_parse_job`, and any stitched `body_ast`, and let the ActionIR
contract resolver classify exact-arity user-function calls before helper fallback.
Wrong-arity registered calls diagnose as user-function arity errors.

Dart now also has the minimal staged parser registry in
`dart/lib/src/parser/staged_parser_registry.dart`. `executeStagedParseJobs(...)`
normalizes and stable-sorts jobs by parent AST path, source span, and job id,
resolves `actionir-body.spec` to `builtin:actionir-body.spec`, loads the fixed
built-in adapter digest, compiles top rule `action_block`, and executes the body
text through Dart's ActionIR block parser. `dispatchFunctionBodyParseJobs(...)`
and `parseSpecWithStagedUserFunctionDefinitionAsts(...)` stitch the returned
`action_block` JSON into each function definition's `body_ast`. This is still
the narrow function-body provider, not general public `parse_job(...)` authoring
or recursive staged queues.

Dart now also has a compiled-state model in `dart/lib/src/compiler/compiled_spec.dart`.
`compileSpec(...)` validates source ASTs by default and returns `CompiledSpec`
state with `definition_order`, `compiled_rule_order`, `rules_by_label`,
`redefined_rule_labels`, carried user-function registry data, per-rule regexes,
dependency refs, mode metadata, action/blind edges, lifecycle/plain/edge
`ActionBlock` payloads, and registry-aware ActionIR contract results. Its
`CompiledDependencyRegexState` derives structured child-regex dispatch data, and
`CompiledDescriptorState` projects the public descriptor shape with `spec`,
`functions`, `dependency_regex_map`, and `meta`.

Dart now has the first runtime matching layer in `dart/lib/src/runtime/matching.dart`.
`RuntimeRegexAlternation` consumes ordered compiled-rule regex lists and supports
`seek` versus `consume` matching while preserving stable alternative indexes.
`RuntimeRegexMatch` records capture-only groups, named captures, code-unit spans,
char-offset and line/column projections, and zero-width/progress checks.
`RuntimeMatchRegisters` keeps entry and local match state separate for child
dispatch and tracks the parser cursor.

Dart also has the first runtime rule interpreter in `dart/lib/src/runtime/interpreter.dart`.
`LinkedSpecRuntimeEngine` consumes `CompiledSpec` state and executes default,
AND, OR, and repetition rule families with action-edge and blind-call child
dispatch, entry/local match handoff, lifecycle blocks, explicit returns, `retv`,
accumulator collection, bounded repetition, zero-progress cutoffs, and recursion
cutoffs. Its core ActionIR evaluator now also preserves scalar, array, hash,
null, boolean, and number shapes through assignment and wrapper snapshots;
supports `array(...)`, `hash(...)`, `copy(...)`, `set(hash(...), ...)`,
hash-index mutation, nested reads, non-numeric map keys, regex literals as
values, and nested value-path assignment with no-autovivification failure
behavior; and exposes the named/map/length/start/end `entry_*` / `match_*`
capture helper family. It now also executes current string/scalar helpers,
explicit `str_*` lexical comparisons, numeric arithmetic/reducer/comparison
helpers, numeric word aliases, arithmetic/comparison symbol callees, and
compatible string/number receiver chains. It also executes array helper family
breadth, bare array working-variable receiver chains, regex split/filter
bridges, delimiter-first `join_values`, array numeric reducers, and
statement-only array end mutations. It also executes hash helper family breadth,
bare hash working-variable receiver chains, statement/value mutation boundaries,
direct hash-index assignment values, bare-overlay `merge_hash`, and explicit
flat-style hash splicing inside `hash(...)`. It also executes expression-valued
blocks with block-local `return(...)`, attached and inline structured controls,
helper/receiver `with` trailing blocks, and hash/array tree traversal receiver
callbacks with scoped callback bindings. It also treats empty array/hash returns
as successful non-null rule matches, uses child-rule match bits for blind
dispatch, and executes marker-form `if(...)` / `elseif(...)` / `else()` /
`endif()` statement chains as grouped branches. It also preserves assignment
expressions inside helper arguments, supports plain fallback values in inline
`if(...)`, evaluates single-argument numeric aggregate reducers through
aggregate-aware reads, and follows scalar-held list/map readback for
`array(name)`, `hash(name)`, and `copy(name)` unless explicit aggregate writes
supersede the scalar-held value. It now also executes explicit cursor
controls: `save_cursor()` / `restore_cursor()` for stack-based cursor restore,
`rewind_match_start()` / `rewind_entry_start()` for lifecycle-anchor rewinds,
`capture_until_boundary(rule[, ...])` for non-consuming structural boundary
capture, and char-based cursor/input helpers such as `cursor_pos`,
`cursor_rest`, `input_slice`, and `input_end_pos`. Dart runtime failures now
carry a structured `RuntimeDiagnostic` on `RuntimeInterpreterException`, with
the neutral diagnostic fields `type`, `stage`, `owner_stage`, `summary`,
`detail`, `top_rule`, `rule_label`, `handler_source_label`, and optional
`spec_name` / `spec_path`. Successful parse output remains unchanged.
Dart now also has the trace-control layer: ordered trace levels,
`LinkedSpecTraceConfig`, structured event/scope primitives, stdout/routed-file/
mirror sinks with reset/truncate behavior, and `parseWithTrace(...)` /
`executeWithTrace(...)` entrypoints that preserve parse output while emitting a
parse-scope event. Dart runtime tracing now also emits rule scopes, regex
match/no-match decisions, action/blind child-dispatch decisions, lifecycle block
marks, cursor-control marks, recursion-cutoff decisions, and
`capture_until_boundary(...)` source-boundary marks while keeping untraced
execution output-compatible. The diagnostics/trace no-drift sweep is closed.
Dart also executes registered exact-arity user-function calls before helper
fallback: arguments are eager in the caller, params bind into fresh
function-local scalar/array/hash stores, results come from the final expression
or local `return(...)`, receiver chains can continue from returned values,
standalone calls discard their results, and direct/mutual recursion is
diagnosed. Dart also preserves staged user-function descriptor shapes across
parsed functions, compiled registry jobs, descriptor records, and runtime output.
Dart corpus parity has started with controlled manifest fixtures and now has safe
named/bounded execution selection for shipped-corpus batching. The first 40
manifest fixtures, the non-`fn` middle fixtures, and the three top-level `fn`
fixtures pass in bounded execute mode.
The remaining shipped-spec/parser-smoke window is split after a diagnostic run
and is now 31/31 green. The basic regex-dialect bridge, helper/action bridge,
recursive/default-mode parser-smoke bridge, portmap result-shape bridge, and
hlink delimiter/capture bridge are done; the helper mutation/text-normalization
bridge is also done, the legacy accumulator bridge closes `regdef_nested_register_fields`, and the public-parser
leading-trivia bridge closes `ds_vhistory_version_entry`. Final parser-smoke no-drift closeout, bounded
structural regex work, routed top-level `fn` corpus-shell execution, and the full shipped 99-fixture Dart corpus
gate are done; the next Dart leaf wires that green gate into the local verification story.

### Step 6: Validate Against the Test Corpus
Run your backend against the manifest-backed corpus under
`rust/linkedspec-runtime/tests/corpus/`. The corpus root has a `manifest.json`
with `case_count` and the ordered `cases` list; every manifest entry has an
`input.spec`, `input.txt`, and `expected.json`. Your backend is compliant with
the current corpus gate when it produces structurally equivalent output for
every manifest entry, and its runner rejects missing fixture directories or
stale extra fixture directories.

For the Dart backend, the focused local gate is:

```bash
bash tools/run_dart_local.sh
```

The core local CI gate remains independent of Dart SDK availability by default; set
`LINKEDSPEC_RUN_DART=1` when invoking `tools/run_ci_local.sh` to include the Dart gate.

The checked-in Rust corpus is kept green while parity work lands incrementally. It now has
99 fixtures, including the `with(...) { ... }` helper, `.with() { ... }` receiver trailing block case, hash-tree traversal receiver block case, and array-tree traversal receiver block case; the two minimal shipped `tclite.spec` cases restored by the
default-mode repetition parity work; the shipped `Lispish.spec` `lispish_x_y` case now
migrated to direct nested access; the first `hlink_substitution` raw-string cases plus the
JSON-safe `{abc}` curly-brace delimiter case and the neutral bracket/mixed delimiter cases;
`lib_reader.spec` scalar-attribute and
comma-list attribute cases; `portmap.spec` bare, bit, slice, constant, and concatenation
cases; `ebnf.spec` expression-rule and logging-annotation payload cases; four `spec.spec`
smokes for minimal rules, action edges, user-function definitions, and comments; seven
RTL/plugin/legacy safety smokes covering `regdef`, `tablegrep`, `simenv`, `vhdl`,
`ds_vhistory`, empty `pplugin`, and empty `tkgui`; terse receiver-chain fixtures for
arrays, hashes, strings, numbers, aggregate wrapper quoting, block-valued receivers, and array-tree traversal;
numeric word aliases; arithmetic/comparison symbol callees; the terse bare-read `name`
fixture for scalar reads, scalar mutation targets, and scalar-held shape payloads;
explicit string comparisons; assignment-expression fixtures; and the shared Perl/Rust
user-function runtime fixture; plus recursive top-rule/body value fixtures for wrapper-body
recursion, nested top-rule `LX` recursion, and top-rule sequence recursion.
`RUST-PARITY.7.4` finalized the corpus guard: the generator writes
`manifest.json`, and the Rust runner fails malformed manifests, duplicate case
names, missing manifest entries, or stale extra fixture directories. The richer
legacy/plugin mismatches above remain follow-up blockers until a narrower parity
owner promotes them safely.

## Architecture Overview

```
.spec file
    │
    ▼
┌─────────────────────────┐
│  Compiler (language-     │
│  specific but spec-      │
│  driven — see spec.spec) │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Parsed .spec +          │  ← typed AST/IR, never raw textual helper rewrites
│  helper/action AST       │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  ActionIR Lowering       │  ← Backend-neutral (helpers → canonical events)
│  (100+ helpers, 10       │
│   families)              │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  HandlerIR               │  ← The decoupling seam
│  (10 variant kinds,      │
│   structured AST)        │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Backend Emitter         │  ← YOUR CODE HERE
│  (Rust / Dart / Julia /  │
│   Lua)                   │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Runtime                 │  ← Language-specific runtime
│  (regex engine, memory   │
│   model, I/O)            │
└─────────────────────────┘
```

## What the Perl Reference Provides

The Perl implementation is the **reference** — the canonical behavioral oracle.
It provides:

- A working compiler pipeline you can study for architecture understanding.
- `spec.spec` — a self-hosted grammar that can bootstrap a new compiler.
- An active `fn name(args) { ... }` definition surface owned by `spec.spec` and projected
  through the descriptor `functions` registry. The Perl reference currently uses a
  temporary pre-bootstrap extraction bridge; do not copy that bridge as the language
  contract. The accepted MVP is exact-arity, pure value/block functions with fresh
  function-local scope, no implicit caller capture, and registry resolution before
  unknown-helper fallback. Calls execute in value positions and compatible receiver
  chains; registered standalone calls compute and discard through `VALUE_DROP`. Recursion
  and unsupported function-body forms are diagnostics, not raw fallback.
- The Rust backend's parsed and compiled state records the same top-level function
  registry shape with parsed body `CodeBlock` values, and its runtime resolves registered
  calls before helper fallback with fresh function-local stores, receiver-chain
  continuation, standalone discard, and recursion diagnostics. The accepted MVP stops at
  explicit-paren, braced `fn` definitions; alternate spellings, omitted zero-arg parens,
  brace-less forms, statementful/caller-mutating functions, recursion support,
  closures/lambdas/currying, and namespaces remain deferred.
- `t/phase0_regression.t` — comprehensive regression tests.
- Phase 0 baseline showing all 21 shipped specs compile at `language_agnostic_ready_ratio == 1.0000`.

## What You Must Build

1. **`.spec` parser** — reads `.spec` files and produces parsed rule entries.
   Can be bootstrap-driven (hardcoded grammar) or self-hosted (parse spec.spec
   with itself, once bootstrapped).

2. **Staged parse-job model** — records source-provenance payload text, parser spec id,
   optional top rule, parent AST path, payload kind, result insertion policy, and failure
   behavior. Parser resolution must be deterministic and diagnostics must report both the
   selected next-stage parser and the original parent source span.

   Once implemented, the portable authoring marker is `parse_job(text_expr, options)`.
   It creates a marker value plus sidecar metadata rather than executing the next parser
   inline.

3. **Staged parser registry and queue** — resolves parser spec ids deterministically,
   caches compiled next-stage parsers by content/version/capability fingerprints,
   dispatches jobs in stable queue order, isolates runtime contexts, stitches results,
   and diagnoses cycles.

4. **Spec import/composition graph** — once implemented, loads file-scope `import` and
   `include` directives as parsed `.spec` dependencies with aliases, structured namespace
   merges, cycle diagnostics, source provenance, and descriptor fingerprints.

5. **Helper/action AST parser** — parses lifecycle/action helper code into typed
   expression and statement nodes. Calls, literals, variables, blocks, direct
   access, assignments, and receiver-dot chains must be represented structurally.
   Text-to-text helper rewriting is not a conforming design for new backends.

6. **User-function registry and resolver** — records top-level `fn name(args) { body }`
   definitions as validated AST-backed records before runtime. The registry must preserve
   definition order, expose definitions by name, reject helper/rule/reserved-name
   collisions, and resolve exact-arity value calls before unknown-helper fallback.

7. **Compiler** — transforms parsed entries and helper/action AST nodes into
   HandlerIR nodes. You can reuse the ActionIR lowering approach, but the input to
   lowering is structured AST/IR rather than raw helper source text.

8. **HandlerIR emitter** — consumes HandlerIR nodes and produces runnable code
   in your target language. Must handle all 10 variant kinds.

9. **Runtime** — the execution engine:
   - Regex engine with position tracking (equivalent to `//gcp` and `\G` anchoring).
   - Accumulator model (arrays, hashes, scalars).
   - Lifecycle execution engine (I/LS/LE/E/EX/IT/LX ordering).
   - Explicit cursor controls: `save_cursor()` / `restore_cursor()` stack
     semantics plus `rewind_match_start()` / `rewind_entry_start()` anchor
     rewinds.
   - Zero-width/lookahead boundary support through
     `capture_until_boundary(rule[, ...])` for non-consuming structural boundary
     detection and capture.
   - Zero-progress guard.

10. **Test harness** — runs `tests/corpus/` entries and compares output to
   `expected.json`.

## Practical Notes

### Regex Engine
The biggest implementation dependency. LinkedSpec requires:
- Position-tracked matching (set/query current match position).
- Ungrounded matching (match anywhere) and anchored matching (match at position).
- Identification of **which** alternative matched in a group.
- Capture groups (indexed and named).

If your target language's regex engine doesn't support embedded code position
tracking, you may need to iterate alternatives individually rather than
compiling a combined alternation.

### Memory Model
LinkedSpec uses mutable working variables (scalars, arrays, hashes) within
rule scope. These are assignment-backed, not functional. Your runtime needs
a variable store per rule invocation.

### Determinism
All operations must be deterministic. Specifically:
- No random number generation.
- Hash key iteration must be sorted (not insertion-order or random).
- First-match-wins for OR dispatch.

## Specification Index

| Document | Location | What it defines |
|---|---|---|
| Multi-backend ADR | `docs/decisions/0006-multi-backend-vision.md` | Vision, lockstep contract, reach matrix |
| Formal `.spec` Grammar | `docs/linkedspec-book/src/appendix/formal-grammar.md` | Accepted `.spec` syntax |
| HandlerIR Spec | `docs/knowledge/handler-ir-design.md` | HandlerIR node structure and emitter contract |
| Helper Contract Catalog | `docs/linkedspec-book/src/appendix/helper-contract-catalog.md` | Every helper's behavioral contract |
| Runtime Semantics | `docs/linkedspec-book/src/appendix/runtime-semantics.md` | Parse modes, lifecycles, dispatch |
| Test Corpus | `rust/linkedspec-runtime/tests/corpus/` | Manifest-backed language-neutral compliance tests |

## Handoff Checklist

Before starting a new backend, verify:
- [ ] You've read all six specification documents above.
- [ ] You understand the `.spec` language syntax (formal grammar).
- [ ] You understand the runtime execution model (runtime semantics).
- [ ] You can implement all 100+ helpers (helper catalog).
- [ ] You can implement a HandlerIR emitter for all 10 variant kinds.
- [ ] You have a regex engine capable of position-tracked alternation matching.
- [ ] You've studied the test corpus format and know how compliance is measured.
- [ ] You understand that `.spec` files are the universal contract — no
      per-backend dialects.

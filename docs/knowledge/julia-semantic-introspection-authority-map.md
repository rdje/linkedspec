---
id: julia-semantic-introspection-authority-map
title: Julia semantic introspection composes typed source and compilation authorities behind one opaque index
answers:
  - "which Julia authorities can build the semantic index"
  - "does Julia already expose semantic_index or semantic_query"
  - "does Julia CompiledSpec definition_order include functions"
  - "where do Julia semantic source spans come from"
  - "are Julia ActionSourceSpan offsets global source offsets"
  - "can a Julia String contain malformed UTF-8"
  - "does Julia parse_spec reject malformed text at an encoding boundary"
  - "what Julia failure does failed.spec report"
  - "how must Julia normalize failed.spec for semantic introspection"
  - "does Julia already have a semantic observation sink"
  - "where can Julia semantic runtime slot events be captured"
  - "where can Julia semantic final result events be captured"
  - "can Julia trace text be used as semantic observations"
  - "which Julia generated routes must propagate semantic observations"
  - "how must Julia preserve semantic observer exception identity"
  - "can Julia LoadedSpec identity enter semantic responses"
  - "can Julia outward descriptors be the semantic wire schema"
  - "are Julia semantic public values automatically immutable"
  - "must Julia semantic raw query validation reject Bool as an integer"
  - "what are the Julia semantic introspection implementation leaves"
  - "what Julia semantic source and outcome API is frozen"
  - "does Julia now implement semantic_index source construction"
  - "which Julia semantic source accessors are public"
  - "does Julia source-only semantic_index invoke the parser"
  - "does Julia semantic_index now retain a compiled-or-failed outcome"
  - "which Julia semantic compilation outcome accessors are public"
  - "what does Julia semantic_snapshot expose"
  - "how does Julia semantic_index report parse validation compile and entry failures"
  - "does Julia generated_plan_input expose compiled or emitted host state"
  - "does Julia semantic outcome construction execute caller target code"
  - "how does Julia semantic_index reject malformed UTF-8 before parsing"
  - "what are the Julia SemanticSourceDetail enum values"
  - "does Julia compiled state JSON alias CompiledSpec"
  - "does Julia descriptor JSON alias CompiledSpec"
  - "can Julia semantic construction use descriptor JSON safely"
  - "how does Julia semantic_index accept text and UTF-8 bytes"
  - "what source detail ceilings does Julia semantic_index use"
  - "which Julia semantic foundation failures throw and which become outcomes"
  - "does Julia semantic foundation construction execute target actions"
  - "does Julia semantic foundation construction use SpecLoader"
  - "how is Julia semantic authored definition order merged"
  - "is the Julia semantic source and compilation foundation composition closed"
  - "what is the next Julia semantic introspection task after source outcome closeout"
  - "what is the Julia runtime semantic observation authority plan"
  - "what are the exact Julia static semantic projection targets"
  - "why does Julia semantic static projection need neutral repetition normalization"
  - "why can Julia compiled regex patterns not directly become semantic regex slots"
  - "which Julia static semantic projection leaves own graph privacy failure and runtime-static proof"
  - "does Julia semantic_index now retain the exact private static graph"
  - "how does Julia semantic graph projection correlate authored and compiled regex slots"
  - "is the Julia semantic graph projection public"
  - "does Julia semantic_index now retain all five private static targets"
  - "what is the exact Julia native versus neutral failed diagnostic boundary"
  - "does Julia runtime-static construction contain semantic observations"
  - "how are repeated Julia lifecycle markers identified in the static projection"
  - "which Julia semantic static projection task is next"
  - "is Julia private static semantic projection composition closed"
  - "what Julia semantic introspection task follows static projection closeout"
  - "which Julia authorities own semantic calls and staging"
  - "how many records and relations are in the Julia calls target"
  - "is Julia staged function body_ast typed ActionBlock authority"
  - "how must Julia correlate ActionSourceSpan calls to authored source"
  - "what is the Julia calls staging generated implementation split"
  - "does Julia now retain the private typed call core"
  - "how many Julia typed call core records and relations exist"
  - "does Julia typed call scanning ignore strings and regex literals"
  - "does Julia now retain complete private staged and generated call provenance"
  - "how does Julia validate native staged sidecars before semantic projection"
  - "how does Julia validate the retained generated plan before semantic projection"
  - "what authority may Julia semantic query consume"
  - "what Julia semantic query types and public functions are frozen"
  - "how is Julia semantic query split across implementation leaves"
date: 2026-07-23
status: current
tags: [julia, semantic-introspection, source-map, diagnostics, runtime, generated-source, privacy]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.6.0, .10.6.2.0-.10.6.2.3, .10.6.3.0-.10.6.3.3, .10.6.4.0-.10.6.4.3, .10.6.5.0-.10.6.5.4, and .10.6.6.0; docs/knowledge/julia-semantic-static-projection-plan.md; docs/knowledge/julia-semantic-call-staged-projection-plan.md; docs/knowledge/julia-semantic-call-core-projection.md; docs/knowledge/julia-semantic-query-authority-map.md; docs/knowledge/julia-semantic-query-kernel.md; docs/knowledge/julia-semantic-query-traversal.md; docs/knowledge/julia-semantic-runtime-observation-authority-map.md; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; docs/decisions/0050-semantic-introspection-staged-artifact-records.md; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/semantic_introspection_model.json; capability_conformance/semantic_introspection_contract.json; julia/src/semantic/SemanticIndex.jl; julia/src/semantic/SemanticCompilationOutcome.jl; julia/src/semantic/SemanticStaticProjection.jl; julia/src/semantic/SemanticCallProjection.jl; julia/src/semantic/SemanticQuery.jl; julia/test/semantic_index_source_foundation_test.jl; julia/test/semantic_index_compilation_foundation_test.jl; julia/test/semantic_index_static_graph_test.jl; julia/test/semantic_index_static_remaining_test.jl; julia/test/semantic_index_call_core_test.jl; julia/test/semantic_index_call_staged_test.jl; julia/test/semantic_index_query_kernel_test.jl; julia/test/semantic_index_query_traversal_test.jl; julia/src/spec/Ast.jl; julia/src/spec/Parser.jl; julia/src/spec/Validator.jl; julia/src/parser/StagedParserRegistry.jl; julia/src/parser/UserFunctionDefinitionParser.jl; julia/src/compiler/CompiledSpec.jl; julia/src/action/ActionAst.jl; julia/src/action/ActionParser.jl; julia/src/action/ActionContracts.jl; julia/src/action/FunctionRegistry.jl; julia/src/io/SpecLoader.jl; julia/src/runtime/Interpreter.jl; julia/src/source/SourceEmitter.jl; julia/src/trace/Trace.jl
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia,Test; include(\"julia/test/semantic_index_source_foundation_test.jl\"); include(\"julia/test/semantic_index_compilation_foundation_test.jl\"); include(\"julia/test/semantic_index_static_graph_test.jl\"); include(\"julia/test/semantic_index_static_remaining_test.jl\"); include(\"julia/test/semantic_index_call_core_test.jl\"); include(\"julia/test/semantic_index_call_staged_test.jl\")'; rg -n 'semantic_index|_semantic_call_add_staged_artifacts|_semantic_call_validate_staged_authority|_semantic_call_add_generated_plan|semantic_query|SemanticQuery|regex_slot_selected|diagnostic_output_sink' julia/src"
---

Julia now has the source and compiled-or-failed semantic-index foundation from `.10.6.2.1-.2`, all five private
static construction targets from `.10.6.3.1-.2`, complete calls/staging/generated provenance from `.10.6.4`, and
the public immutable typed/raw-neutral query surface from `.10.6.5`. It still has no typed runtime semantic
observation at the `.10.6.6.0` audit boundary. The exported `semantic_index` remains an opaque native owner rather
than a renamed descriptor or a query wrapper over public dictionaries.

The reusable meaning is already present, but distributed across typed layers:

- `SpecFile`, rules, function shells, body elements, and staged payload/job/result sidecars own authored structure.
- `CompiledSpec`, `CompiledRule`, typed action nodes/contracts, the function registry, selected entry, generated
  rule-family plan, and emitted-source plan own accepted and executable structure.
- `SpecPortableDiagnostic` owns cloneable compilation evidence. The neutral `failed.spec` currently produces
  native code `bare_edge_target_undefined`, stage `normalize_edges`, and fields `rule_label=Top` / `target=Missing`;
  semantic projection must retain that native foundation while normalizing the v1 record to
  `unknown_rule_reference` at neutral stage `compile`.
- `RuntimeParseResult` owns final output and Unicode-scalar cursor position. The runtime's accepted regex-slot seam
  owns selected rule/slot identity before effects are applied.

No one native span is the neutral source model. Ordinary `SourceSpan` is line-only. `StagedSourceSpan` has scalar
start/stop plus line bounds. `ActionSourceSpan` uses Unicode-scalar offsets local to normalized action text because
`_action_len` counts collected characters; those offsets are neither global-source nor UTF-8-byte coordinates.
The adapter therefore needs one private copied accepted-source map that correlates these authorities to canonical
zero-based half-open UTF-8 byte and Unicode-scalar positions.

Julia's type system does not supply the strict constructor boundary automatically. A `String` can contain invalid
UTF-8 bytes. Exact malformed sequences `ff`, `c3 28`, `e2 82`, and `ed a0 80` all have `isvalid == false`, but direct
`parse_spec` fails inconsistently as `InvalidCharError` or `SpecParseException`, while staged parsing reports
`UserFunctionDefinitionParserException`. Direct `Vector{UInt8}` input has no parser method. Semantic construction
must therefore copy either valid `AbstractString` or `AbstractVector{UInt8}` input, reject invalid text/bytes before
any character iteration or language parsing, and retain only caller logical identity. `SpecLoader` checks decoded
file bytes but also retains requested/resolved host paths and origin; it cannot be a constructor or identity owner.

`CompiledSpec.definition_order` is rule order, not complete definition order: the calls fixture retains `Top` and
`Done` there while its function shell lives in separate typed staged/function state. Neutral definition order must
merge authored rule and function authorities. The outward descriptor likewise contains a Julia-native projection;
it is compatibility state, not the portable record/relation schema.

Behavior-free runtime audit `.10.6.6.0` freezes observation as a separate optional invocation-local typed sink.
Existing high trace emits the string topic `julia_runtime:regex_slot_selected`, but trace detail is not typed
semantic evidence and there is no final result trace topic. Capture belongs directly at the accepted-slot seam and
only after successful final `RuntimeParseResult` construction. The slot event's scalar position must derive from
`one_match.codeunit_end`, because the context cursor is deliberately not mutated until the following accept call;
the final event reuses `RuntimeParseResult.cursor_char_offset`. Direct, loaded, reconstructed, generated-plan,
emitted, and traced routes converge on these seams. Generated execution currently translates broad failures to
`GeneratedSourceException`; an invocation-local semantic callback failure marker/pass-through must rethrow the
exact caller object before generic translation, independently of the diagnostic sink. With no semantic sink, no
event is allocated and no input is hashed. See [[julia-semantic-runtime-observation-authority-map]].

Public semantic values also require deliberate detachment. Julia structs are immutable bindings but can contain
mutable `Vector` and `Dict` members, so returned capabilities, records, relations, pages, explanations, and errors
must be deep-copied or otherwise immutable. Raw-neutral validation must explicitly reject `Bool` for integer
fields because `Bool <: Integer` in Julia; the neutral `numeric_boolean` boundary cannot be inherited from a type
test alone.

Behavior-free foundation planning `.10.6.2.0` proved that detachment is mandatory at the first boundary, not only
at query time. `to_json(compiled)["definition_order"]` and
`to_descriptor_json(compiled)["meta"]["compiled_rule_order"]` return the live `CompiledSpec` vectors: changing the
supposed projection changes compiler state. The semantic foundation must not consume either JSON surface. It keeps
typed staged/compiled authorities privately and returns new structs, tuples, or recursively detached maps; its
display must omit the logical name, source, paths, and host objects.

The frozen Julia foundation surface is `semantic_index(source, options)` plus keyword convenience. It accepts copied
valid text or strict UTF-8 bytes with `SemanticIndexOptions` containing a nonempty control-free caller logical name,
one `none`/`identity`/`span`/`text` `SemanticSourceDetail`, and an optional exact Unicode-17 rule selector. Public
source values use zero-based half-open UTF-8 bytes and one-based line/Unicode-scalar columns; SHA-256 covers the
canonical bytes and is disclosable only at `text`. Exact source identity/span/excerpt/occurrence accessors must apply
the ceiling before returning a detached value and reject Boolean range arguments explicitly.

Source leaf `.10.6.2.1` implements that exact half in `julia/src/semantic/SemanticIndex.jl`. The public enum values
are `SemanticSourceNoneDetail`, `SemanticSourceIdentityDetail`, `SemanticSourceSpanDetail`, and
`SemanticSourceTextDetail`; accessors are `source_identity`, `source_span_for_bytes`,
`source_span_for_scalars`, `source_excerpt_for_bytes`, and `locate_exact`. The module includes this owner before
the parser, its implementation contains no parser/compiler reference, and the 135-assertion source suite constructs
deliberately invalid grammar successfully. Thus the source foundation does not invoke language parsing. Four malformed strings/byte
shapes reject at `decode_source`, caller byte mutation cannot change retained text, private boundary vectors become
tuples, the opaque owner suppresses normal property access, display is identity-redacted, and outward structs plus
fresh JSON projections cannot alias private state.

Committed-source signoff for `.10.6.2.1` is focused 135 and Julia 7,677/primary/105, shared primary 5x2x66, all ten
self-hosted Unicode legs, unchanged Unicode 806/9/8/2 and semantic 6/20/81 at rollout 4/9 plus admission 3/6,
Knowledge Map 682/5,166, and canonical Rust 78.39s + Dart 1/1 + primary 66x2 + Phase 0 1,031/630s.

Outcome leaf `.10.6.2.2` extends that stable owner. It calls the staged user-function-aware parser, validator,
compiler with duplicate validation disabled, entry selector, and shared generated-v2 plan builder once.
It merges functions and rules by authored source position because `CompiledSpec.definition_order` contains only
rules (`Top`, `Done`) while the calls fixture function `normalize` precedes them. Native portable failure stays
exact: `failed.spec` is `bare_edge_target_undefined` / `normalize_edges` with `rule_label=Top`, `target=Missing`;
missing selection is `entry_rule_not_found` / `select_entry_rule`. Fatal process exceptions rethrow; all ordinary
parse/validation/compile/selection/plan failures become detached failed-compilation outcomes. Generated plan rows
for the calls fixture are `Top/default`, `Done/default` and use caller logical identity rather than a path.

The public accessors are `semantic_snapshot`, `compilation_authority`, `compilation_diagnostic`, `entry_selection`,
and `generated_plan_input`. A snapshot reports stable id, compiled/failed state, source ceiling and digest
availability, with `has_execution=false`. Authority reports only parsed/validated/compiled presence. Diagnostics,
entry selection, and plan contract/version/logical identity/label-family rows are immutable detached values; they
never expose the private parser/compiler owners or emitted implementation. The `none` ceiling denies generated plan
identity.

Construction has no path input and never calls `SpecLoader`, a target runtime engine, generated execution, trace,
diagnostic output, or semantic observation. The existing staged frontend may compile/execute its declared trusted
function-shell/body parser specifications as compiler infrastructure; that is distinct from executing the caller's
target spec. A target action containing an unconditional host error still parses, validates, compiles, selects, and
plans successfully during the probe. Public semantic records/query remain absent until later leaves.

Outcome proof adds 85 assertions: source/outcome focus is 220 and complete Julia is 7,762/primary/105. Native
`failed.spec`, parse fallback, empty-rule validation, missing selector, compile/plan fallback classification, fatal
exception identity, text/byte convergence, detached JSON, and forbidden host-key/source topology are exact. The
neutral semantic ledger remains 6/20/81 at rollout 4/9 and admission 3/6 because foundation ownership alone is not
backend admission. Stable primary 5x2x66, ten Unicode legs, Knowledge Map 682/5,172, canonical Rust 82.82s + Dart
1/1 + primary 66x2 + Phase 0 1,031/643s, and exact 1.56-GB cleanup preserving all 517 Pgen artifacts close the
outcome leaf.

Closeout `.10.6.2.3` reruns the exact committed source 135 plus outcome 85 suites as one 220-assertion composition,
then the complete Julia gate, stable 5x2x66 primary matrix, all ten Unicode legs, and every no-drift contract. It
adds no production or replacement test code. Canonical Rust semantic admission 1/1 in 80.84 seconds, Dart 1/1,
primary 66x2, and Phase 0 1,031/1,031 in 630 seconds pass. Parent `.10.6.2` is therefore composition-closed without
promoting Julia; Knowledge Map 682/5,174 and exact 1.56-GB cleanup preserving all 517 Pgen artifacts pass.
Behavior-free static authority planning `.10.6.3.0` is the next dependency-eligible leaf.

Behavior-free static plan `.10.6.3.0` now freezes five construction targets: graph 12 records / 14 relations,
privacy at `text` 4/3, privacy at `identity` 4/3, failed compilation 6/4, and runtime-static 7/8 after execution/
event removal. Direct Julia probes show the current source map reproduces all 14 neutral source references exactly.
The projector must compose copied source/map, parsed authored occurrences, typed compiled state, selected entry,
and the native diagnostic; no descriptor/compiled JSON projection is an authority.

Two Julia-specific normalization traps are now durable. Native `is_repetition(Default)` is true with minimum zero,
but neutral v1 treats `Default`, `And`, `Single`, and `Pipe` as non-repeating with null bounds. Compiled rule regex
vectors also include parent matchers attached to cross-rule action edges: graph Top has two compiled `a` patterns,
but only Child's two authored structural slots become records. Self-indexed runtime matchers remain slots. Source
correlation must therefore scan the complete trimmed authored member, group parsed fragments by line, and correlate
ordinary/self-indexed slots plus edges/lifecycles to typed compiled owners.

The failed foundation stays native `bare_edge_target_undefined` / `normalize_edges`; projection alone emits the
neutral unknown-rule diagnostic, decision, explanation, and evidence. Because that validation failure precedes
the foundation's merged authored-definition step, failed rule order comes directly from parsed rules. Implementation
is graph/source/evidence `.10.6.3.1`, both privacy ceilings plus normalized failure/runtime-static/isolation `.2`,
and composed closeout `.3`, with no public projection/query, execution observation, or semantic promotion. See
[[julia-semantic-static-projection-plan]].

Plan signoff passes direct five-target/14-source-reference probes, focused 220, complete Julia 7,762/primary/105,
5x2x66, ten Unicode legs, unchanged neutral/public ledgers, Knowledge Map 683/5,188, mdBook/doctrines, canonical
Rust 78.75s + Dart 1/1 + primary 66x2 + Phase 0 1,031/632s, and exact 1.56-GB cleanup preserving 517 Pgen
artifacts. No production/test/fixture/API/format/query/observation/ledger behavior changes; graph `.10.6.3.1`
followed only after the clean plan commit.

Graph `.10.6.3.1` now retains the exact private compiled graph behind `SemanticIndex` as recursively immutable
plain semantic objects/arrays. Its full-member scanner correlates authored slots with typed compiled owners,
excludes cross-rule parent matchers, preserves duplicate and self-indexed occurrences, translates native Default
repetition to neutral non-repetition, and materializes canonical ids/order/source evidence. The exact target is 12
records / 14 relations / seven source references. An unexported underscore-only test seam returns fresh detached
data; no public graph/query accessor, path, host AST/IR/compiler/regex, second parse, target execution, trace,
observer, or generated-format change exists. New 70/focused 290 and Julia 7,832/primary/105 pass together with
5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust 78.38s + Dart 1/1 + primary 66x2 + Phase 0
1,031/641s. Privacy/failure/runtime-static/isolation were assigned to `.10.6.3.2` and are completed below; Julia
was not promoted by the graph leaf.

Remaining-target leaf `.10.6.3.2` now closes that private boundary. Both privacy ceilings deep-equal 4/3, failed
construction deep-equals 6/4, and runtime-static deep-equals 7/8. The native foundation remains
`bare_edge_target_undefined` / `normalize_edges`; only the private projection becomes portable
`unknown_rule_reference` / `compile` with parsed rule order, exact target-member evidence, decision, explanation,
and relations. Generic parse/validation/selection/plan failures retain their native detached diagnostic instead of
returning an empty projection.

Runtime construction contains no execution, event, `observed_as`, or trace-derived fact. Two self-indexed slots
remain distinct without redundant self dispatch. Repeated `E` lifecycle members become distinct occurrence ids
with exact order, return shape, source, and containment. Every proof copy is fresh plain JSON; retained values are
tuple-backed, and source ceilings, public omission, path/host/AST/IR/compiler/loader/emitter/executor/trace/sink/
observer/environment/time/random denial are locked. New 99/focused 389 and Julia 7,931/primary/105 pass with
5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust 78.27s + Dart 1/1 + primary 66x2 + Phase 0
1,031/697s. All five private targets now exist.

Typed call-core leaf `.10.6.4.1` now extends that same retained private graph before canonicalization and freeze.
`SemanticCallProjection.jl` materializes the exact non-staged 18 records / 16 relations from typed compiled,
function-registry, ActionIR, contract, and source-map authorities. It reparses retained function-body payloads and
requires exact staged-AST equality, resolves typed contracts, scans only bounded authored owner text, skips escaped
strings and context-valid regex literals, and assigns outer-before-inner owner-local call ids plus global authored
order. User functions resolve before the governed `trim`/`match_text`/`return` helpers; signatures, binding
read/write, and conservative fixed-point shapes are retained without executing target code. The proof seam stays
underscore-only and detached. Staged/generated completion remains `.10.6.4.2`; no public records/query, runtime
observation, trace dependency, rollout, or admission change exists yet. Completion `.10.6.4.2` now validates the
native staged payload/job/body-result correlation and retained generated plan contract/identity/order/selected row,
then retains three neutral staged records and one selected handler-plan record with exactly nine added provenance
relations. The complete private target is 22/25/10; native sidecar values, body AST, generated implementation,
paths, execution, and trace remain absent. New 62/focused 530 and Julia 8,072/primary/105 pass. No-change
`.10.6.4.3` now recomposes all six committed semantic suites at focused 530 and the complete matrix/Unicode/
governance/canonical boundary; canonical Rust is 77.68s, Dart 1/1, primary 66x2, and Phase 0 1,031/622s. Parent
`.10.6.4` is composition-closed without promotion; query authority audit `.10.6.5.0` is next after commit.

Behavior-free query audit `.10.6.5.0` now freezes the next boundary. The existing recursively tuple-backed
`_SemanticStaticProjection` is the sole evaluator authority, and every call must consume a fresh detached
materialization. It cannot receive retained source/map, source above the construction ceiling, parser/compiler,
staged sidecars, AST/ActionIR, regex, generated implementation, executor, runtime observation, trace, diagnostic
sink, path, environment, time, randomness, or another host object. A direct calls-target probe confirms 22/25/10,
fresh nested mutation isolation, retained immutable type, and complete public query omission.

Julia must match all 19 non-runtime response hashes and all 26 raw-neutral malformed boundaries before exposure.
Its closed vocabulary mirrors the admitted Rust/Dart types, uses copied tuples and recursively immutable facts,
and returns fresh JSON projections. Public `semantic_capabilities(index)`, typed
`semantic_query(index, request::SemanticQuery)`, and raw `semantic_query_neutral(index, request)` appear together
only after completion. The raw validator tests `Bool` before `Integer` because `true isa Integer`; it also requires
an actual Boolean for the digest flag. Implementation is private record/source/list/get/explain `.10.6.5.1`,
private traversal/pages/budgets/costs plus all static hashes `.2`, complete public typed/raw-neutral surface and all
boundaries `.3`, and no-change composition `.4`. Runtime events remain `.10.6.6`. See
[[julia-semantic-query-authority-map]].

The behavior-free audit passes neutral 6/20/81, admitted Perl/Rust/Dart focused query suites, Julia focused 530
plus the detached 22/25/10 probe, Julia 8,072/primary/105, primary 5x2x66, ten Unicode legs, unchanged ledgers,
canonical Rust/Dart admission + primary 66x2 + Phase 0 1,031/655s, book/KM 687/5,277, doctrines, and exact
1,812,240-KiB cleanup preserving 517 Pgen artifacts. No query API or ledger is promoted.

Private kernel `.10.6.5.1` and traversal completion `.10.6.5.2` implement the full static evaluator behind the
opaque index. Public `.10.6.5.3` now exports its immutable types plus capabilities, typed query, and raw-neutral
query through one validator/evaluator. All 19 non-runtime hashes are exact through both paths, and all 26 malformed
boundaries are exact with clone/privacy/non-execution/host denial. Evaluation still receives exactly one detached
projection; runtime events remain `.10.6.6`. See [[julia-semantic-query-kernel]],
[[julia-semantic-query-traversal]], and [[julia-semantic-query-public-api]].

No-change leaf `.10.6.3.3` recomposes the committed four-suite topology at focused 389 without production/test
replacement. Complete Julia remains 7,931/primary/105, primary is 5x2x66, all ten Unicode legs pass, every ledger
is unchanged, and canonical Rust 80.89s + Dart 1/1 + primary 66x2 + Phase 0 1,031/653s pass. This closes private
static parent `.10.6.3` without public query, runtime observation, or promotion. Calls, bindings, staged provenance,
and generated-plan meaning are next owned by behavior-free authority/split leaf `.10.6.4.0` after the clean commit.

Behavior-free calls/staging/generated leaf `.10.6.4.0` now freezes an exact additive authority map before code.
The neutral calls target is 22 records / 25 relations; the existing static base is 6/6, the typed non-staged core
is 18/16, and staged plus selected-generated completion adds four records / nine relations. Julia's function
registry, typed compiled edge Action AST, reparsed typed function body plus staged-JSON equality, action contracts,
copied source map, and retained generated-v2 plan provide all required authority without target execution or trace.

`CompiledSpec.definition_order` remains rule-only, so complete authored order comes from the foundation's merged
function/rule source positions. `ActionSourceSpan` is local decoded-scalar space over normalized action text, not a
global byte range; bounded occurrence-safe scanning must correlate typed outer-before-inner calls to exact raw
function shells and action edges. Native function payload/job/result fields are mapped deliberately to ADR `0050`
rather than copied, and only the selected entry plan row becomes a generated artifact. Implementation is split as
private typed core `.10.6.4.1`, staged/generated completion `.2`, and no-change composition `.3`; public query,
runtime observation, rollout, and admission remain later work. See [[julia-semantic-call-staged-projection-plan]].

Plan signoff passes focused 389, Julia 7,931/primary/105, primary 5x2x66, all ten Unicode legs, unchanged ledgers,
Knowledge Map 684/5,231, mdBook/doctrines, canonical Rust admission 77.84 seconds + Dart 1/1 + primary 66x2 +
Phase 0 1,031/625s, and exact 1.56-GB cleanup preserving 517 Pgen artifacts. No behavior or promotion changes.

Implementation is dependency-ordered under `.10.6`: Unicode rule-label closure; source-only copied input/map
`.10.6.2.1`; staged compiled-or-failed authority `.10.6.2.2`; composed foundation closeout `.10.6.2.3`; static
graph/privacy/failure projection; calls/bindings/staged/generated projection; typed and raw query; runtime
observation across every route; and one exact 12-role Julia admission consumer. None of these facts promotes Julia
rollout or admission by itself.

## 2026-09-11 — outcome and source prefix reading

Julia .1.26 completes SemanticCompilationOutcome1-472 and reads SemanticIndex1-513.
Ordinary staged parse/validation/compilation/entry/plan failures become detached
outcomes; InterruptException, OutOfMemoryError and StackOverflowError rethrow.
Native portable diagnostics preserve their code/stage/fields; fallback failures
retain only their governed message and optional source line. Failed entry/plan
construction does not expose the compiled candidate as an accepted snapshot.

The index validates/copies strict UTF-8 text or byte input, retains caller logical
identity, suppresses ordinary property access and redacts display. Source maps
freeze byte/scalar/line/column boundaries in tuples; exact range mapping rejects
interior UTF-8 boundaries and applies disclosure ceilings before reading source.
Option validation starts in this prefix; remaining option/integer/error-freezing
source is unread. Fresh nine-suite semantic proof passes1063 assertions. New
regex-source counterexamples are separate projection evidence under Julia .2.15:
[[julia-semantic-regex-call-source-gap]]. No whole-project or repair closure follows.

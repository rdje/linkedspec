---
id: dart-semantic-introspection-authority-map
title: Dart semantic introspection must compose typed compiler authorities after Unicode label closure
answers:
  - "which Dart authorities can build the semantic index"
  - "can Dart parse the semantic privacy fixture Töp"
  - "does Dart silently truncate Unicode action or blind targets"
  - "does Dart validate rule labels in deserialized ASTs"
  - "where do Dart semantic source spans need to come from"
  - "what Dart failure does failed.spec report"
  - "does Dart already have a semantic observation sink"
  - "where can Dart semantic slot events be captured"
  - "are the spec_spec corpus fixtures current with specs/spec.spec"
  - "does the Dart 105 fixture corpus prove the current self-hosted grammar"
  - "does Dart execute freshness-locked current specs/spec.spec"
  - "can Dart generated metadata reconstruct a semantic index"
  - "does Dart compiled state preserve Unicode rule labels"
  - "which Dart routes prove exact Unicode rule label identity"
  - "are Dart function helper lifecycle fluent and mark identifiers widened by Unicode labels"
  - "is the Dart Unicode rule-label prerequisite complete"
  - "is specs/spec.spec aligned with Unicode rule labels"
  - "what are the Dart semantic introspection implementation leaves"
  - "how is the Dart semantic source foundation split"
  - "does Dart have a semantic source index"
  - "how does Dart map semantic UTF-8 byte and Unicode scalar positions"
  - "does Dart semantic index construction parse and compile source"
  - "what does Dart semantic compilation snapshot expose"
  - "what happens when Dart semantic compilation fails"
  - "how does Dart retain generated semantic plan input"
  - "does Dart semantic index construction execute target spec"
  - "is the Dart semantic source outcome foundation complete"
  - "which authorities own the Dart semantic static projection"
  - "how many exact Dart static construction targets exist"
  - "how is the Dart static semantic projection split"
  - "how must Dart normalize the failed semantic fixture"
  - "does Dart have an exact private compiled static semantic graph"
  - "how does Dart correlate repeated lifecycle markers with compiled payloads"
  - "does Dart static projection enforce text and identity privacy ceilings"
  - "does Dart normalize static failure while preserving the native foundation diagnostic"
  - "does the Dart runtime fixture have a static projection before observations"
  - "does Dart private semantic projection leak host objects or mutable owner state"
  - "is the Dart private static semantic projection composition-closed"
  - "which Dart authorities own semantic calls and staged projection"
  - "does Dart CompiledSpec definition order include function shells"
  - "are Dart function definition source spans exact character ranges"
  - "how must Dart correlate ActionIR call spans to authored source"
  - "how is Dart semantic calls projection split"
  - "does Dart semantic introspection project typed functions helpers calls and bindings"
  - "how many records and relations are in the Dart non-staged calls core"
  - "how does Dart semantic call projection resolve user functions before helpers"
  - "does Dart typed call projection preserve Unicode byte and scalar source evidence"
  - "does Dart semantic introspection distinguish staged payload parse job and result"
  - "how does Dart project generated handler plan provenance"
  - "is the Dart private calls projection exact at 22 records and 25 relations"
  - "does Dart staged semantic projection expose body AST or generated source"
  - "is the Dart calls staged generated semantic parent composition closed"
date: 2026-07-22
status: current
tags: [dart, semantic-introspection, unicode, rule-labels, source-map, diagnostics, runtime, generated-source]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.5.0, .10.5.0.2.0-.4, .10.5.1.0-.3, .10.5.2.0-.3, and .10.5.3.0-.3; docs/decisions/0012-staged-linked-parsing-architecture.md; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/semantic_introspection_model.json; capability_conformance/unicode_rule_label_contract.json; specs/spec.spec; tools/gen_oracle_corpus.pl; rust/linkedspec-runtime/tests/corpus/spec_spec_*/input.spec; dart/lib/src/semantic/semantic_index.dart; dart/lib/src/semantic/semantic_static_projection.dart; dart/lib/src/semantic/semantic_call_projection.dart; dart/lib/src/semantic/sha256.dart; dart/test/semantic_index_source_foundation_test.dart; dart/test/semantic_index_compilation_foundation_test.dart; dart/test/semantic_index_static_graph_test.dart; dart/test/semantic_index_call_projection_test.dart; perl/LinkedSpec/SemanticStaticProjection.pm; rust/linkedspec-runtime/src/semantic_index/static_projection.rs; rust/linkedspec-runtime/src/semantic_index/call_projection.rs; dart/lib/src/parser/unicode_rule_label.dart; dart/lib/src/parser/spec_parser.dart; dart/lib/src/parser/user_function_definition_parser.dart; dart/lib/src/validation/spec_validator.dart; dart/test/unicode_rule_label_routes_test.dart; dart/test/unicode_rule_label_identity_routes_test.dart; dart/test/unicode_rule_label_negative_isolation_test.dart; dart/lib/src/compiler/compiled_spec.dart; dart/lib/src/action; dart/lib/src/parser/staged_parser_registry.dart; dart/lib/src/io/spec_loader.dart; dart/lib/src/source_emitter.dart; dart/lib/src/runtime/interpreter.dart
reverify: "shasum -a 256 specs/spec.spec rust/linkedspec-runtime/tests/corpus/spec_spec_*/input.spec; python3 tools/check_semantic_introspection_contract.py; python3 tools/check_unicode_rule_label_contract.py; cd dart && dart test test/semantic_index_source_foundation_test.dart test/semantic_index_compilation_foundation_test.dart test/semantic_index_static_graph_test.dart test/semantic_index_call_projection_test.dart test/action_contracts_test.dart test/user_function_definition_shell_test.dart test/staged_parser_registry_test.dart test/unicode_rule_label_identity_routes_test.dart test/unicode_rule_label_negative_isolation_test.dart && cd ..; bash tools/run_dart_local.sh; rg -n '\\\\w|isRuleLabel|takeRuleLabelPrefix|RuleHeader.fromJson|EdgeTarget.fromJson|BareEdgeTarget.fromJson|traceRegexSlotSelected|compiledRuleOrder|buildGeneratedRulePlan|sourceText' specs/spec.spec dart/lib/src -g '*.dart' -g '*.spec'"
---

Dart already owns most semantic meaning in typed, reusable layers. Staged parsing produces `SpecFile` rules and
function sidecars; validation owns accepted topology and `SpecPortableDiagnostic`; `CompiledSpec` owns definition
and compiled order, entry selection, exact rule keys, families/cursor policy, authored regex slots, normalized
action/blind edges, lifecycle payloads, typed ActionIR, and the function registry. `buildGeneratedRulePlan` owns
the existing generated-v2 ordered `{label, family}` plan. Descriptor JSON is a compatibility projection, not the
semantic schema, and neither AST JSON nor emitted Dart implementation source may cross the semantic API.

The behavior-free `.10.5.0` probe established these exact audit-time boundaries:

- `graph`, `calls_and_staging`, and `runtime` parse, validate, compile, rebuild through `SpecFile` JSON, and retain
  ordered generated plans; the runtime fixture returns `["A","B"]`;
- `failed.spec` reports `bare_edge_target_undefined` at `normalize_edges`, so Dart needs the same deliberate
  `unknown_rule_reference` / `compile` semantic normalization already required on Rust;
- `privacy.spec` fails before validation at `Töp::` because `spec_parser.dart` uses host `\w` for declarations;
- action and blind references are worse than a clean rejection: `-> Töp` and `=> Töp` parse as target `T`, while
  a bare `Töp` line remains raw; and
- a deserialized/programmatic AST containing invalid label `Top-Rule` passes `validateSpec` and compiles. The
  validator checks existence/collisions but does not apply ADR `0051` to declarations or references.

Once a valid Unicode label is supplied programmatically, current compiled maps, descriptor output, generated plan,
emitted source, and explicit selector preserve `Töp` exactly. That proves these consumers should compare immutable
strings, not reclassify them. The generated Dart Unicode 17 classifier/complete validator/prefix scanner now exists
and is independently locked, including supplementary-safe UTF-16 slicing. Native header/action/blind/bare parsing
consumes it, prevents invalid suffix truncation, and validation rejects invalid declarations/targets from parsed,
JSON-reconstructed, and programmatic ASTs with one portable diagnostic. Function/helper identifiers, lifecycle
markers, fluent methods, and mark names remain separate grammars. All nine positive fixtures and both distinct
pairs now retain exact identity through compiled maps/order, descriptors, generated plans, reconstruction,
isolated emitted-package execution, selectors, diagnostics, traces, strict loading, and primary commands. The
negative/isolation routes now pass all eight contract fixtures across every programmatic and reconstructed
declaration/target role, source/no-prefix boundaries, and primary compilation. Function names and parameters,
helpers, lifecycle markers, fluent methods, and named-mark variables remain on their existing narrower grammars.
Composed complete Dart/package/primary/corpus and canonical proof now close the label prerequisite without semantic
promotion. Behavior-free `.10.5.1.0` freezes the opaque source/outcome boundary and splits it in dependency order:
`.10.5.1.1` owns strict copied decoded/byte input plus the private Unicode source map, `.10.5.1.2` owns the staged
compiled-or-failed authority and generated-plan input, and `.10.5.1.3` owns composed omission-safe proof and parent
closure. No child may infer identity from `LoadedSpec`, because that existing owner couples text to a resolved host
path; the constructor instead requires a caller logical name and invokes no runtime engine.

The audit also found a neutral authority conflict outside Dart's hardcoded parser. ADR `0012` makes
`specs/spec.spec` the first authoritative `.spec` grammar, but its rule-header and edge productions embedded host
`\w`. Shared leaves `.10.5.0.1.0-.1` now resolve that conflict: one generated literal class is independently
checked and consumed at all 12 declaration/reference sites, while Dart derives that atom in its bounded structural
bridge and directly executes current canonical source. The native Dart parser/validator now follow that shared
closure rather than claiming parity from grammar alone.

The earlier apparently green self-hosted corpus did not cover current authority: all four `spec_spec_*` inputs were
stale identical copies. Shared closeout `.10.5.0.1.2` regenerated them verbatim from canonical `specs/spec.spec`,
added byte/hash freshness enforcement, and composed current grammar across Perl, Rust, Dart, Julia, and Lua under
both command environments. Corpus 105/105 now refers to freshness-locked current source rather than the former
snapshot.

Exact source evidence is adapter work. Ordinary Dart rule headers/body elements retain one-based lines, while
`ActionSourceSpan` is local to normalized action text rather than a general source map. Function-definition
sidecars are richer and retain source/body spans, payload/job/result policy, and typed body AST. A semantic
constructor must copy accepted decoded text/canonical UTF-8 bytes plus a caller logical name, build zero-based
half-open byte and one-based Unicode-scalar coordinates, and correlate typed owners without exposing AST layout.
`LoadedSpec` retains exact strict-decoded source but also a resolved host path, so it cannot supply semantic identity
implicitly.

Dart now has the source-and-outcome `SemanticIndex.fromSource` / `SemanticIndex.fromUtf8` foundation. It copies decoded
Unicode scalar text or validated 0..255 bytes, rejects unpaired UTF-16 and malformed UTF-8 before language work,
retains canonical strict bytes plus a private byte/scalar boundary map, and exposes only ceiling-checked immutable
identity, spans, excerpts, and ordered exact lookup. Coordinates are zero-based half-open UTF-8 bytes with one-based
line and Unicode-scalar columns; mid-scalar byte boundaries are typed errors. `none`/`identity`/`span`/`text` are
applied before values leave, source text/bytes/map stay private, and debug output omits caller logical identity.
Construction then invokes staged parsing, validation, compilation with duplicate validation disabled, exact entry
selection, and generated-v2 plan construction exactly once. It retains the typed AST and compiled authority only
privately while exposing detached immutable compilation state/authority/diagnostic, selected-entry identity, and
ordered generated-plan input. Parse, validation, compile, and entry-selection failures are values in a failed
snapshot; portable Dart diagnostics remain exact rather than being prematurely normalized across backends. Target
execution, emitted-source execution, runtime sinks, trace, records, and query remain absent. Runtime already exposes
authoritative internal evidence:
`_traceRegexSlotSelected` runs after accepted structural slot selection and the entry wrapper constructs the final
`RuntimeParseResult`. Text trace and `RuntimeDiagnosticOutputSink` are different products. A later leaf must add an
optional invocation-local typed semantic sink at those seams and derive a new immutable observed index; query must
remain unable to execute.

The safe split is shared executable-label authority, Dart Unicode-label parity, opaque source/outcome foundation,
static projection, call/staged/generated projection, immutable query, typed runtime observation, and one composed
admission consumer. Until those leaves pass, semantic governance remains 6 fixture groups / 20 exact queries / 73
rejected mutations, rollout 3 complete / 6 pending, and native admission 2 complete / 4 pending. See
[[unicode-rule-label-contract]], [[semantic-introspection-neutral-contract]],
[[outward-descriptor-is-not-semantic-wire-model]], [[dart-compiled-spec-state]],
[[dart-function-definition-shell-projection]], [[dart-generated-source-v2-rule-local-cursor]],
[[dart-runtime-structured-diagnostics]], [[dart-native-spec-resolution]], and
[[dart-offline-generated-callers-require-dependency-free-package]].

The opaque source/outcome foundation is now composition-closed through `.10.5.1.3`. Exact combined proof covers
strict copied inputs, byte/scalar mapping and ceilings, graph/privacy/failure outcomes, entries and generated plan,
clone/caller isolation, and negative host-state/execution/trace/query topology. Complete Dart remains 308 package,
primary 66x2, and corpus 105/105; rollout/admission deliberately remain 3/9 and 2/6. Static normalized projection
begins independently at `.10.5.2` rather than being inferred from foundation closure.

Behavior-free leaf `.10.5.2.0` freezes the static projection boundary across five exact construction variants:
graph, privacy at `text`, privacy at `identity`, failed compilation, and runtime without execution/event records.
The projection must compose parsed authored order/member intent, typed compiled order/mode/slot/edge/lifecycle
authority, selected-entry identity, accepted source plus exact UTF-8/scalar mapping, and the native portable
diagnostic. It must not serialize `SpecFile.toJson()`, `CompiledSpec.toJson()`, descriptor state, ActionIR, compiled
regexes, generated Dart source, object identity, or paths.

Source correlation groups parsed body elements by authored line and scans the complete trimmed member, converting
Dart UTF-16 code-unit boundaries through the retained scalar/UTF-8 map exactly once. Neutral ids percent-escape
strict UTF-8 bytes. Duplicate authored slots stay distinct; parent matchers attached to cross-rule edges are not
invented as target slots; self-indexed matchers remain structural slots. The foundation's exact native
`bare_edge_target_undefined` / `normalize_edges` diagnostic is deliberately normalized only here to
`unknown_rule_reference` / `compile`, neutral ids/fields, and the ordered dependency decision/explanation.

Implementation is dependency-ordered: `.10.5.2.1` owns compiled graph records/relations/source/evidence,
`.10.5.2.2` owns both privacy ceilings, normalized failure, runtime-static, clone isolation, and host-leak denial,
and `.10.5.2.3` owns composed signoff and parent closure. Query, execution observations, trace, and semantic
rollout/admission remain later leaves.

Leaf `.10.5.2.1` now implements that compiled graph owner. `SemanticIndex` builds one private immutable projection
after its staged outcome, using the accepted source map plus typed `SpecFile`, `CompiledSpec`, and entry selection.
The graph target deep-equals the neutral records, relations, source references, shapes, and entry explanation after
source-reference materialization. A package-internal exact-oracle extension returns only detached plain data and is
omitted from `linkedspec_dart.dart`; public callers still have no record accessor or query. Repeated lifecycle
markers correlate to compiled payloads by source occurrence, not marker-name lookup, so same-marker blocks retain
their distinct value shapes. Descriptor/AST JSON, compiled regex objects, generated implementation, paths,
execution, trace, diagnostic sinks, and runtime observers remain outside the projector. Privacy, normalized
failure, runtime-static, and exhaustive host-leak proof remain owned by `.10.5.2.2`.

Leaf `.10.5.2.2` completes all remaining static construction variants. The `text` and `identity` privacy snapshots
apply their ceiling before projected source evidence leaves the owner. Failed compilation keeps the native Dart
diagnostic intact on the foundation and normalizes only the private projection into the neutral diagnostic,
decision, explanation, ids, fields, and source. The runtime fixture initially contains only static records with
`has_execution: false`; typed observations remain a later immutable derivation. Every oracle result is a fresh
JSON-compatible clone, while recursive tests and static topology deny host objects, owner mutation, public export,
AST/ActionIR/descriptor/regex leakage, execution, paths, trace, diagnostic sinks, and runtime observers.

Composed closeout `.10.5.2.3` proves the private static owner as one surface rather than a collection of passing
leaves. The six-test suite jointly covers all five construction targets and repeated-lifecycle occurrence
isolation. Complete Dart/public/canonical gates pass on the exact final code, including concurrent selector-probe
admission after repair child `.10.5.2.3.0`. Parent `.10.5.2` is therefore closed without exposing a projection or
query, executing a target, enabling trace, deriving runtime observations, or advancing rollout/native admission.
Calls/bindings/staged/generated provenance begins independently at `.10.5.3`.

Behavior-free audit `.10.5.3.0` freezes the next authority boundary. The neutral calls target contains 22 records
and 25 relations. Dart's ordered `UserFunctionRegistry` retains exact shell/body source and staged payload/job/
result sidecars; compiled edge `actionPayload.actionAst` and contract resolution retain typed calls; selected entry
plus the foundation's generated-v2 plan own handler provenance. Staged `body_ast` is exactly reproduced by typed
`parseActionBlock(bodySource)` and is only an internal consistency input, never the semantic wire schema.

Two source traps prevent a direct structural projection. `CompiledSpec.definitionOrder` contains rule labels but
not top-level function shells, and `FunctionDefinition.sourceSpan` / `bodySpan` retain lines rather than exact
character offsets. Exact authored order and function shell range must locate the shell occurrence that encloses the
staged payload's decoded-scalar body span. Rule/function ActionIR spans are local to normalized action text, so the
projector must walk typed outer-before-inner preorder while correlating each occurrence back to the complete
authored edge/shell range; it may not add local offsets blindly. Implementation is split into typed functions/
helpers/calls/bindings `.10.5.3.1`, staged/generated exact 22/25 completion `.10.5.3.2`, and closeout `.10.5.3.3`.

Leaf `.10.5.3.1` now implements the private typed core and deep-equals the neutral 18-record / 16-relation subset
after staged and generated artifact records are deliberately filtered out. Registry functions and parsed rules
merge by exact authored byte start. Typed function-body and compiled-edge ActionIR drive function/helper/call/
binding meaning; contract resolution validates the same bodies; occurrence-safe scanning maps typed outer-before-
inner calls back into each bounded shell or edge. User-function registry resolution precedes the governed helper
fallback, and conservative shapes derive only from typed literals, current bindings, registered returns, and the
three fixture helper contracts.

The interleaved Unicode proof locks the two subtle boundaries together: `Top`, `normalize`, and `Done` keep exact
authored definition order, the function shell creates no false rule edge, and `trim("é")` has distinct correct
UTF-8 byte width and Unicode-scalar column width. Binding occurrence ids remain stable, all records/relations/
source evidence/decisions/explanations/shapes match the oracle, and results are fresh JSON-compatible clones. The
test-only projection extension remains package-internal; AST/ActionIR, descriptors, regex objects, paths,
executors, trace, diagnostic sinks, and runtime observers do not cross it. Public query, runtime observation,
rollout, and admission remain unchanged.

Leaf `.10.5.3.2` completes the private target at exact 22 records / 25 relations. For each function, the projector
validates the staged registry's native decoded body payload, ActionIR parser/top-rule job, success result, parent
path, and result/failure policies, then maps them to three distinct neutral `staged_artifact` records. Exact
directions are preserved: the function contains all three, the job consumes the payload and produces the result,
and the result is staged by the job and lowered from the payload. Body source, payload/job maps, the body AST, and
ActionIR never leave the adapter.

The same leaf consumes rather than rebuilds the foundation's retained generated-v2 plan. Contract, format, source
identity, row order, and families are checked against compiled authority; only the selected entry row becomes one
separate `generated_artifact` handler-plan record connected by `generated_as`. No emitter, generated parser, or
target runtime is invoked. Full equality, staging-role/direction assertions, fresh-clone proof, and recursive
privacy denial pass, while public query, runtime observation, semantic rollout, and native admission remain absent.

Documentation-only closeout `.10.5.3.3` recomposes the final projection rather than adding behavior. One 22-test
suite jointly covers the exact calls/staged/generated target, all five static construction targets, strict source
and compilation outcomes, Unicode/interleaved and repeated-lifecycle occurrence isolation, no-execution staged
construction, fresh clones, and public omission. Complete Dart/public/canonical gates pass on the same code, so
parent `.10.5.3` is composition-closed. Immutable query `.10.5.4` is the next independent adapter layer; runtime
observation, rollout, and native admission remain unchanged.

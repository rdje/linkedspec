# Semantic Introspection

LinkedSpec now has an executable, backend-neutral contract for deep semantic introspection. Perl, Rust, and Dart have
admitted native query surfaces: opaque construction, exact static plus call/staged/generated projections, public
`capabilities`/`query` answers, optional caller-captured runtime observations, and one exact composed conformance
consumer per backend. Rust now has an opaque strict-source, exact-coordinate, compiled-or-failed foundation; exact clone-safe
static and call/staged/generated projections; a public immutable typed/raw-neutral query evaluator; and optional
caller-captured typed runtime observations that derive a separate immutable post-execution index. One exact Rust
consumer now composes those layers across every governed route.
Dart now also exposes its complete non-runtime static query surface: immutable public protocol values,
`SemanticIndex.capabilities`, typed `query`, and raw-neutral `queryNeutral` share one projection-only evaluator at
all 19 static response digests and 26 portable malformed-request boundaries. Dart additionally exposes exact typed
invocation-local runtime capture, immutable observed-index derivation at the twentieth digest, and public
generated/emitted direct and traced propagation. One omission-sensitive Dart consumer now composes all of those
owners across every governed route and admits the backend without introducing another semantic implementation.
The distinction matters:

- `linkedspec-semantic-model-v1` fixes what every backend must mean;
- `linkedspec-semantic-query-v1` fixes how callers ask and how answers are bounded;
- the neutral checker derives and digest-locks exact answers without admitting a backend early; and
- `LinkedSpec::semantic_index(...)` constructs an opaque compiled-or-failed Perl snapshot and retains clone-safe
  static plus compiled call/staging/generated records/relations;
- `$index->capabilities` and `$index->query($request)` expose the exact v1 static answer surface today; and
- `$index->with_execution_observation(\@events)` derives a new immutable runtime snapshot after normal parsing;
- `t/semantic_introspection_perl_admission.t` composes every required Perl path once; and
- `linkedspec_runtime::semantic_index::SemanticIndex` retains the Rust source/outcome authority and exact private
  static plus call/staged/generated projections;
- `SemanticIndex::capabilities()`, `query(&SemanticQuery)`, and `query_neutral(&Value)` expose Rust's exact 19-case
  static answer surface without exposing those private projections;
- `RuntimeSemanticObservationSink` captures typed events during normal Rust execution, and
  `SemanticIndex::with_execution_observation(...)` validates them into the twentieth exact answer; and
- `semantic_introspection_rust_admission.rs` composes every required Rust path once; and
- Dart `SemanticIndex.capabilities`, `query(SemanticQuery)`, and `queryNeutral(Object?)` expose the exact static
  answer surface without exporting Dart's private normalized projection or compiler authorities; and
- Dart `RuntimeSemanticObservationSink` receives immutable `regex_slot_selected` and `rule_result` facts during
  normal direct/loaded/reconstructed/traced/generated-plan engine execution; and
- `semantic_introspection_dart_admission_test.dart` composes every required Dart path once; and
- the current `return_descriptor` / descriptor APIs remain a separate lower-level compatibility surface.

The neutral contract is complete. Backend admission is **3 complete / 3 pending**: Perl, Rust, and Dart are
admitted; Julia, PUC Lua, and LuaJIT remain pending. MCP remains later transport work and does not own semantics.

## Current Dart source, outcome, and private graph foundation

Dart now exposes the complete source/outcome foundation of its future opaque semantic index. It accepts decoded
scalar text or strict UTF-8 bytes, copies the input, requires caller-owned logical identity, builds the exact
private source map, and retains one staged compiled-or-failed outcome without executing the target specification:

```dart
import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';

final index = SemanticIndex.fromUtf8(
  utf8.encode('Töp::\n /é/\n'),
  options: const SemanticIndexOptions(
    logicalName: 'privacy.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
    entryRule: 'Töp',
  ),
);

print(index.sourceIdentity.logicalName); // privacy.spec
print(index.sourceIdentity.byteLength); // 13
print(index.sourceIdentity.scalarLength); // 11
print(index.snapshot.state.wireName); // compiled
print(index.compilationAuthority.toJson());
// {parsed: true, validated: true, compiled: true}
print(index.entrySelection!.toJson());
// {label: Töp, basis: explicit_selector}
print(index.generatedPlan!.toJson()['rows']);
// [{label: Töp, family: default}]
print(index.sourceSpanForBytes(0, 6).toJson());
// {start_byte: 0, end_byte: 6, start_line: 1, start_column: 1,
//  end_line: 1, end_column: 6}
print(index.sourceExcerptForBytes(8, 12)); // /é/
```

`SemanticIndex.fromSource(...)` is the decoded-text twin. Both constructors reject an empty/control-bearing logical
name and an invalid optional entry label before language work. `fromUtf8` additionally rejects values outside
`0..255` and malformed UTF-8; `fromSource` rejects unpaired UTF-16 surrogates rather than silently replacing them.
Constructor and mapping failures are typed `SemanticIndexError` values with stable `stage`, `code`, `message`, and
sorted `fields`. No constructor accepts a path or `LoadedSpec`, and neither source bytes nor decoded text can be
read back wholesale.

The source ceiling is structural. `none` rejects identity, `identity` exposes caller name and exact byte/scalar
lengths, `span` adds zero-based half-open UTF-8 byte spans plus one-based line and Unicode-scalar columns, and
`text` adds exact excerpts and `sha256:<lowercase hex>` over canonical bytes. Byte ranges that begin or end inside
a multibyte scalar are rejected. `locateExact(needle, afterByte: ...)` supports deterministic ordered lookup of
duplicate authored text without exposing the map itself. Returned identity/span/JSON values are fresh immutable or
detached plain data, caller byte mutation cannot affect the index, and `toString()` never includes the logical name.

After source policy succeeds, construction calls the existing staged user-function-aware parser once, validates
once, and calls the compiler once with its duplicate validation disabled. It then resolves either the exact caller
selector or the established default (first authored marker, otherwise first authored rule) and copies the existing
generated-v2 plan. `snapshot` reports `compiled` or `failed_compilation` plus the fixed `has_execution: false`;
`compilationAuthority` reports only whether private parsed, validated, and compiled authority exists. Neither value
contains an AST, compiler object, source buffer, descriptor, semantic record, or query result.

A parse, validation, compile, or entry-selection error is a language outcome, not a constructor failure. The index
still exists in `failed_compilation` state with permitted source evidence and a fresh
`SemanticCompilationDiagnostic`. Existing `SpecPortableDiagnostic` values retain their exact native code, stage,
message, and fields. For example, `failed.spec` retains Dart's `bare_edge_target_undefined` / `normalize_edges`
diagnostic with `rule_label` and `target`; the later static projection, not this foundation, owns cross-backend
normalization. Parser, non-portable validator, and compiler exceptions receive deterministic semantic-foundation
fallback codes without being thrown through the constructor. Invalid options, Unicode, bytes, or UTF-8 still throw
`SemanticIndexError` before a language snapshot exists.

`entrySelection` returns only the chosen label and basis. `generatedPlan` returns only contract
`linkedspec-generated-source-v2`, format 2, caller source identity, and immutable ordered label/family rows; it does
not generate Dart source. The `none` ceiling denies plan identity, just as it denies source identity. Returned
snapshots, authority flags, diagnostics, entries, plans, and JSON are immutable or detached, so caller mutation
cannot alter the private outcome.

The Dart production package intentionally remains dependency-free. Generated-source tests resolve isolated path
callers with a fresh empty offline package cache, so a runtime digest dependency would make emitted packages
unresolvable. The package-internal SHA-256 implementation is checked against the standard empty and `abc` vectors
plus the neutral 128-byte graph fixture, while isolated generated callers remain green.

Construction does **not** invoke `LinkedSpecRuntimeEngine`, a generated parser, target actions/lifecycle code,
trace, a diagnostic-output sink, or a semantic observation sink. It performs no implicit path read. It also does
not expose normalized records or runtime observations through construction accessors. Public capabilities and
queries are a separate projection-only layer over the completed private snapshot.

The source/outcome parent is composition-closed. Its proof covers graph, Unicode privacy, native failure,
decoded/byte convergence, malformed input/options, supplementary and duplicate coordinates, all four ceilings,
default/explicit/missing entry selection, caller mutation, detached outputs, and a static denial of path,
environment, clock/random, execution, trace/sink, record, and query coupling. At this foundation boundary, complete
Dart passed 308 package tests, primary 66x2, and corpus 105/105. The closeout also fixed the retired aggregate-
selector source scan so a new nonignored untracked source cannot evade pre-staging verification. Rollout and native
admission remained pending there until the later exact `.10.5.6` consumer composed the complete adapter.

The complete private static construction surface is implemented. Every successfully compiled `SemanticIndex` retains
an immutable v1 graph built from accepted source and its byte/scalar map, parsed authored order/member intent,
typed compiled rule/slot/edge/lifecycle state, and selected-entry identity. The graph includes stable UTF-8-
escaped ids, canonical records and relations, exact source references, rule family/cursor/repetition facts,
duplicate structural slots, direct and indexed edges, lifecycle value shapes, and entry decision/explanation
evidence. Repeated lifecycle markers correlate to their compiled payloads by authored occurrence, so equal marker
names cannot alias distinct shapes.

The package-internal oracle seam returns a fresh detached plain-data clone and is deliberately absent from the
public `linkedspec_dart.dart` umbrella. Both Unicode privacy variants deep-equal the neutral model after `text` or
`identity` construction ceilings are applied, and recursive proof rejects host objects and forbidden private keys.
Dart's native `bare_edge_target_undefined` / `normalize_edges` remains unchanged at the foundation; only the
private projection maps it to the neutral `unknown_rule_reference` / `compile` diagnostic, rule ids, source,
decision, and explanation. A runtime-capable fixture initially has `has_execution: false` and no execution/event
records or relations, so static construction cannot activate trace or execution.

Dart callers cannot obtain the private projection, AST, ActionIR, descriptor, compiled regexes, generated
implementation source, paths, trace, diagnostic sinks, or runtime observers. Composed static signoff passes all
six exact construction/isolation cases plus complete Dart/public/canonical gates and closes `.10.5.2` without
semantic rollout or native-admission promotion. Calls/bindings/staged/generated projection is exact through
`.10.5.3`; capabilities/query are public through `.10.5.4.3`, while typed runtime observations and backend
admission remain later work.

The Dart calls projection is now exact. The complete neutral target has 22 records and 25 relations;
`.10.5.3.1` deep-equals the 18-record / 16-relation subset left after deliberately excluding the three staged
artifacts, one generated artifact, and every relation touching them. The private projector emits functions,
helpers, calls, bindings, reads/writes, resolution evidence, decisions, explanations, and conservative shapes from
the ordered user-function registry, typed function/edge ActionIR, resolved contracts, existing static ids, and the
immutable source map.

`CompiledSpec.definitionOrder` lists rules but not function shells, and function `sourceSpan`/`bodySpan` values are
line-only. Exact authored order therefore locates the shell occurrence enclosing the staged payload's decoded-
scalar body span, then merges its byte start with rule positions. ActionIR spans are local to normalized body or
edge code, not physical-source coordinates, so projection walks typed calls in outer-before-inner order while
matching occurrences inside the already bounded authored shell or edge source.

For example, this interleaving keeps definition order `Top`, `normalize`, `Done`; the function body is not mistaken
for part of either rule, and `trim("é")` receives the correct unequal UTF-8 byte width and Unicode-scalar width:

```text
Top::
 /x/ -> Done { return(normalize(match_text())) }

fn normalize(value) { return(trim("é")) }

Done:
 /x/
```

User-function registry resolution precedes helper fallback. Shape inference is intentionally bounded to typed
literals, current bindings, registered return signatures, and the three governed fixture helpers; uncertainty is
preserved rather than guessed. Results are fresh JSON-compatible clones, and the package-internal exact-oracle
extension is absent from the public Dart umbrella. AST/ActionIR, descriptors, compiled regexes, generated source,
paths, executors, trace, diagnostic sinks, and runtime observers remain private.

`.10.5.3.2` completes the remaining provenance from authorities already retained by construction. For every
registered function, Dart validates the native body sidecars and projects three separate `staged_artifact`
records:

- the `payload` identifies the function-body fragment and its parent path;
- the `parse_job` identifies the native ActionIR parser/top rule plus result and failure policies; and
- the `result` records successful typed lowering and its bounded value shape.

Their direction is causal and fixed: the function `contains` all three, the job `consumes` the payload and
`produces` the result, the result is `staged_by` the job, and the result is `lowered_from` the payload. The adapter
does not return body source, the sidecar payload map, parse-job implementation state, or the typed body AST. It
validates and maps existing state rather than reparsing to invent provenance.

Generated provenance remains separate. The retained `linkedspec-generated-source-v2` plan is checked against its
format, caller source identity, compiled rule order, and families. Only the selected entry row becomes one
`generated_artifact` handler-plan record linked from the selected rule by `generated_as`. This does not emit Dart
source, construct a generated parser, or execute the target specification. A staged parse job is therefore never
misclassified as generated code.

The exact calls fixture now deep-equals all 22 records and 25 relations without filtering. An additional proof
locks the three distinct staging roles, every relation direction above, the selected generated handler identity,
fresh detached clones, public omission, and recursive denial of body/AST/ActionIR/generated-source/path/execution/
trace leakage. Documentation-only `.10.5.3.3` recomposes 22 calls/static/source/outcome tests on the final code,
reruns complete Dart/public/canonical signoff, and closes the parent. Dart still exposes no semantic query or
runtime observation surface, and rollout/admission remain unchanged.

Behavior-free query audit `.10.5.4.0` now fixes the Dart adapter boundary before that API is exposed. The evaluator
may consume only a fresh detached clone of the private normalized snapshot, source-reference table, records, and
relations. It may not reach decoded source, parser/compiler objects, function sidecars, AST/ActionIR, compiled
regexes, generated implementation source, executors, trace state, paths, or host objects. The neutral target is 19
non-runtime response digests plus 26 malformed-request boundaries. Typed Dart requests and raw-neutral JSON will
enter one evaluator; the neutral seam exists to represent invalid shapes that a typed request cannot contain.

Typed record/source kernel `.10.5.4.1` is now implemented behind a package-private extension. Immutable typed
operations, directions, pages, budgets, source policies, requests, records, relations, diagnostics, page state,
costs, and responses own their aggregate values; every JSON projection is a fresh detached clone. Capabilities,
list, get, explain, source detail/ceiling, structural redaction, and portable record errors match nine complete
neutral response digests. The evaluator receives only detached normalized projection data, so it cannot compile,
execute, inspect host objects, or acquire paths or trace state.

Traversal/limits `.10.5.4.2` now adds relation-kind-filtered outgoing, incoming, and both-direction breadth-first
search. Each layer scans canonical relation order, deduplicates relation ids, and advances through unvisited record
ids. One primary-stream pager handles valid after-id cursors and page continuation across records, relations,
capabilities, and explanation steps. Record/relation/depth budgets return deterministic prefixes, exact logical
costs, and portable warnings. All 16 successful non-runtime response digests now match, including reverse,
staged/generated, page-boundary, budget, privacy, and explanation cases.

Public typed plus raw-neutral completion `.10.5.4.3` is now implemented. Every query protocol type is exported by
`package:linkedspec_dart/linkedspec_dart.dart`, and `SemanticIndex` exposes one exact static evaluator through
three caller-facing forms:

```dart
import 'package:linkedspec_dart/linkedspec_dart.dart';

final index = SemanticIndex.fromSource(
  'Top::\n /x/\n',
  options: const SemanticIndexOptions(
    logicalName: 'example.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
  ),
);

final capabilities = index.capabilities;
print(capabilities.contract); // linkedspec-semantic-query-v1

final rules = index.query(
  SemanticQuery(
    operation: SemanticQueryOperation.list,
    recordKinds: const ['rule'],
    page: const SemanticQueryPage(limit: 20),
    source: const SemanticQuerySource(detail: SemanticSourceDetail.span),
  ),
);

for (final record in rules.records) {
  print('${record.kind}: ${record.name}');
}

final neutral = index.queryNeutral({
  'contract': 'linkedspec-semantic-query-v1',
  'operation': 'get',
  'subjects': [rules.records.first.id],
  'record_kinds': <Object?>[],
  'relation_kinds': <Object?>[],
  'direction': 'outgoing',
  'page': {'after_id': null, 'limit': 100},
  'budget': {'max_records': 1000, 'max_relations': 2000, 'max_depth': 4},
  'source': {'detail': 'none', 'include_content_digest': false},
});
print(neutral.ok); // true
```

Use typed `query` for ordinary Dart embedding. Use `queryNeutral` at a serialized protocol boundary where malformed
JSON-like values must receive portable diagnostics rather than becoming Dart constructor/type errors. Both paths
return the same `SemanticQueryResponse` shape and enter the same validator/evaluator. Capabilities and response
aggregates are immutable; `toJson()` returns fresh detached data, so caller mutation cannot alter the index or a
later response.

The raw path validates the exact contract and object keys; array types/order/duplicates; operation combinations;
record/relation kinds; direction; page cursor/limit; record/relation/depth budgets; source policy/digest request and
construction ceiling; subjects; and integer-versus-boolean boundaries. All 19 non-runtime static response digests
match through both paths, and all 26 portable invalid-request boundaries return exact rejected envelopes.

Each public call receives only a new detached clone of snapshot/source-reference/record/relation data. Query code
cannot access accepted source wholesale, parser/compiler objects, function sidecars, AST/ActionIR, compiled regexes,
generated implementation source, executors, trace state, paths, environment, or host objects. It cannot compile or
execute the target, enable trace, or invent runtime events. Composition closeout `.10.5.4.4` closes the static query
parent on committed code. Runtime `execution`/`event` records are supplied only by the separately completed
`.10.5.5` caller-observation derivation; `.10.5.6` now admits both static and observed query surfaces together.

Behavior-free runtime audit `.10.5.5.0` fixed how Dart would acquire those records; the following slices now
implement that design. The exact regex-slot authority is the post-match structural-selection call: by then a match
exists and ordered slot identity has been checked, while match effects have not yet run. That seam knows the
executing rule and each selected target rule/index. The exact final-result authority is the successful public
entry wrapper after it constructs `RuntimeParseResult`; that seam knows the effective entry rule, final Unicode-
scalar cursor, exact input text, and successful completion.

Typed live capture `.10.5.5.1` now implements the engine half of that boundary. The public umbrella exports the
contract id, closed event-kind enum, immutable event value, and synchronous callback type. Install the callback on
one invocation only:

```dart
import 'package:linkedspec_dart/linkedspec_dart.dart';

final events = <RuntimeSemanticObservationEvent>[];
final result = engine.parse(
  input,
  semanticObservationSink: events.add,
);

for (final event in events) {
  print(event.toJson());
}
```

For the governed `runtime.spec` and exact input `ab\n`, the callback receives `Top[0]` at Unicode-scalar position
1, `Top[1]` at position 2, and a successful final `Top` result at position 2. Only the final event carries
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`; slot events carry no input identity
or status. `position` is always a Unicode-scalar offset even though Dart runtime matching uses host code units
internally.

The sink is separate from trace and diagnostic output. With no sink, explicit guards run before event construction
and before final input hashing. A callback failure propagates as the caller's exact object and stack after the
runtime closes any active trace scope. Successful observation does not change result, cursor, lifecycle, trace, or
diagnostic values. An immediate runtime exit may leave already-delivered slot events but never fabricates a final
successful result event.

Direct `parse`/`execute`, loaded and reconstructed engines, trace convenience methods, and the validated generated-
plan engine entry share this capture. Route propagation `.10.5.5.3` also adds the optional sink to public
`executeGeneratedParserV2` / `executeGeneratedParserWithTraceV2` and emitted-library `execute` / `executeWithTrace`.
A semantic-channel-specific private wrapper restores a caller callback's exact object and stack before the broad
generated execution catch can translate it. With no sink, the adapter returns `null` and creates no callback
closure. Generated-source contract v2 and format 2 remain unchanged.

The route proof executes both in-process helpers and fresh emitted libraries in an isolated offline caller package.
All direct and traced forms deliver the exact three events and twentieth digest; observed/unobserved results and
diagnostics are equal, routed debug trace files are byte-identical, immediate exit retains the slot event but omits
the final result, and callback failures retain exact identity. This is observation propagation, not admission.

Captured events do not mutate the static index and do not grant query-side execution. Derive an observed snapshot
explicitly after successful execution:

```dart
final staticIndex = SemanticIndex.fromSource(
  source,
  options: const SemanticIndexOptions(
    logicalName: 'runtime.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
  ),
);

final observedIndex = staticIndex.withExecutionObservation(events);
assert(!staticIndex.snapshot.hasExecution);
assert(observedIndex.snapshot.hasExecution);

final runtimeFacts = observedIndex.query(
  SemanticQuery(
    operation: SemanticQueryOperation.list,
    recordKinds: const ['execution', 'event'],
    source: const SemanticQuerySource(
      detail: SemanticSourceDetail.identity,
    ),
  ),
);
```

`withExecutionObservation(...)` validates the contract and field combinations, requires nonnegative positions and
indices, exactly one final successful entry result, and a stable input identity, then resolves every selected slot
through the static rule/regex-slot/edge graph and its `selects_regex` relation. Result and event shapes come only
from static rule/edge facts; no host result value is retained. Empty, malformed, foreign, reordered, duplicate-
final, failed-index, already-observed, or existing-but-unselected-slot evidence throws `SemanticIndexError` with
stage `execution_observation` and code `semantic_index_invalid_observation`.

The returned index owns a fresh canonical projection containing `execution:0`, ordered event records, and exact
`observed_as` relations with slot/rule evidence. Caller mutation of the event list or a detached response cannot
alter either index. Typed and raw-neutral queries match the twentieth governed response digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.

Direct, loaded, reconstructed, traced-convenience, and generated-plan engine capture is complete in `.10.5.5.1`;
immutable derivation and the twentieth digest are complete in `.2`; public generated/emitted direct and traced
propagation is complete in `.3`; and composition closeout `.4` now proves all layers together on committed code.
Parent `.10.5.5` closed without promotion. Admission `.10.5.6` subsequently composes that runtime layer with the
source, static, calls, and query owners and promotes only Dart.

## Current Rust construction and query surface

Rust callers can construct the immutable source/outcome layer from decoded text or strict UTF-8 bytes:

```rust
use linkedspec_runtime::semantic_index::{
    SemanticIndex, SemanticIndexOptions, SemanticSnapshotState, SemanticSourceDetail,
};

let source = "Töp::\n /é/\n";
let options = SemanticIndexOptions::new("privacy.spec", SemanticSourceDetail::Text);
let index = SemanticIndex::from_utf8(source.as_bytes(), options)?;

assert_eq!(index.snapshot().state, SemanticSnapshotState::Compiled);
assert_eq!(index.source_identity()?.logical_name, "privacy.spec");
assert_eq!(index.source_excerpt_for_bytes(0, 6)?, "Töp::");
# Ok::<(), Box<dyn std::error::Error>>(())
```

`SemanticIndex::from_source` is the decoded-text twin. Both constructors copy their input, require a nonempty
control-free logical name and immutable `none`/`identity`/`span`/`text` ceiling, and optionally accept one exact
entry-rule selector. They never accept or infer a source path. The byte constructor rejects malformed UTF-8 before
language parsing. Its private map uses zero-based half-open UTF-8 byte ranges, one-based lines, and one-based
Unicode-scalar columns; byte ranges that split a scalar are typed errors.

Successful construction privately retains parsed, validated, compiled, exact entry-selection, and shared
generated-source-v2 plan authority. A parse, validation, compile, or entry-selection failure instead returns the
same opaque object in `failed_compilation` state with a cloned portable diagnostic and the permitted source
evidence. Constructor policy/decode errors are `SemanticIndexError`s because no snapshot can exist. Returned
identity, span, diagnostic, entry, and plan values are owned copies; callers cannot obtain the source-map object,
accepted source, AST, `CompiledSpec`, or another host IR object.

The ceiling also governs these foundation accessors: `none` rejects source identity and generated-plan identity,
`identity` permits those but no spans or digest, `span` adds coordinate access, and `text` adds exact excerpts plus
the source digest. The custom debug representation redacts logical identity at `none` and never prints source text.

Construction parses and compiles the source but never invokes the resulting target parser or target lifecycle and
action code. It does not itself capture runtime observations or enable trace. The opaque index now retains exact private
static v1 records/relations, normalized failure evidence, and the 22-record/25-relation call/binding/staged/
generated target. Public queries can now select and redact those normalized records, but no projection accessor or
host compiler object is exposed. Runtime observation is supplied only by a completed typed caller-owned event
sequence. Composed admission exercises those existing owners without adding a second projection or evaluator. The
global rollout and native-admission ledgers are now 3/9 and 2/6.

Use the typed native request for normal Rust embedding. `SemanticQuery::new` supplies the exact v1 contract plus
canonical page, budget, direction, and source defaults:

```rust
use linkedspec_runtime::semantic_index::{
    SemanticIndex, SemanticIndexOptions, SemanticQuery, SemanticQueryOperation,
    SemanticSourceDetail,
};

let source = "Top::\n /x/\n";
let index = SemanticIndex::from_source(
    source,
    SemanticIndexOptions::new("example.spec", SemanticSourceDetail::Text),
)?;

let mut request = SemanticQuery::new(SemanticQueryOperation::List);
request.record_kinds = vec!["rule".to_string()];
request.source.detail = SemanticSourceDetail::Identity;

let answer = index.query(&request);
assert!(answer.ok);
assert_eq!(answer.records[0].id, "rule:Top");
assert_eq!(
    answer.records[0]
        .source
        .as_ref()
        .map(|source| source.logical_name.as_str()),
    Some("example.spec"),
);
# Ok::<(), Box<dyn std::error::Error>>(())
```

`index.capabilities()` is the canonical capabilities operation and returns effective kind vocabularies, page and
budget defaults/maxima, construction ceiling, and whether this particular immutable snapshot has an execution
observation. A newly constructed base reports false; a derived post-execution index reports true. Every response is
owned: changing a record, fact, source reference, or diagnostic cannot change the index or a later query.

Transport code that already has neutral JSON can call `index.query_neutral(&value)`. That seam accepts the exact
nine-field envelope and returns portable response diagnostics even for malformed types, unknown keys, non-JSON
booleans, invalid kind order, bad operation combinations, unknown subjects, or invalid cursors. Valid typed and
neutral requests enter the same evaluator and produce deep-equal responses; there is no second JSON-side semantic
implementation.

Rust implements `capabilities`, `list`, `get`, `relations`, and `explain` for every static snapshot. It applies the
same structural source policy, canonical after-id pages, filtered directional breadth-first traversal, logical
budgets/costs, and exact query diagnostics described below. The evaluator receives only a fresh clone of the
normalized projection. It has no source parser, compiler, executor, trace sink, filesystem path, ActionIR,
`CompiledSpec`, compiled regex, or generated implementation source. Runtime records become queryable only after the
caller supplies a validated completed observation as described next; composed Rust admission is exact under
`.10.4.6`.

### Capture a Rust execution observation

Install one cloneable typed sink in the `ExecutionOptions` used for a normal execution, retain its events, and then
derive a new index. The sink is invocation-local; it is independent of trace and diagnostics and does not mutate the
compiled specification or the base semantic index.

```rust
use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::semantic_index::{
    RuntimeSemanticObservationEvent, RuntimeSemanticObservationSink, SemanticIndex,
};
use std::cell::RefCell;
use std::rc::Rc;

# fn observe(
#     engine: &linkedspec_runtime::engine::Engine,
#     base_index: &SemanticIndex,
# ) -> Result<SemanticIndex, Box<dyn std::error::Error>> {
let events = Rc::new(RefCell::new(Vec::<RuntimeSemanticObservationEvent>::new()));
let retained = Rc::clone(&events);
let sink = RuntimeSemanticObservationSink::new(move |event| {
    retained.borrow_mut().push(event);
});
let options = ExecutionOptions::new().with_semantic_observation_sink(sink);

let value = engine
    .execute_value("ab\n", &options)
    .map_err(std::io::Error::other)?;
let completed_events = events.borrow().clone();
let runtime_index = base_index.with_execution_observation(&completed_events)?;

assert!(!base_index.snapshot().has_execution);
assert!(runtime_index.snapshot().has_execution);
# let _ = value;
# Ok(runtime_index)
# }
```

`RuntimeSemanticObservationEvent` has a closed `regex_slot_selected` / `rule_result` kind vocabulary. Slot events
carry executing rule, authored target rule, zero-based slot index, and post-match Unicode-scalar position. The one
final successful entry-rule result carries the final scalar position, `succeeded` status, and
`input:sha256:<lowercase hex>` over the exact UTF-8 input bytes. An unsuccessful invocation emits no final result,
so an incomplete stream cannot be mistaken for a completed execution.

`with_execution_observation` validates the v1 contract id, field combinations, exactly one final successful entry
result, selected rule/slot topology, and input identity. It clones the static projection, adds canonical execution
and event records plus `observed_as` relations, and returns a new index. Later mutation of the caller's event vector
or returned query data cannot affect either index. Query methods remain projection-only and cannot execute a parser.

Direct, loaded, reconstructed-plan, generated-plan, source-emitter, traced, and untraced option-bearing routes all
use the same authoritative slot/result seams. With no sink, they allocate no events or input digest. If a sink
panics, Rust unwinds the original panic unchanged rather than translating it into a parser, trace, or diagnostic
error.

## Current Perl construction and query surface

Perl callers can now construct the immutable source/compilation foundation using in-memory source only:

```perl
use LinkedSpec;

my $source = "Top::\n /x/\n";
my $index = LinkedSpec::semantic_index(
  \$source,
  logical_name => "example.spec",
  source_detail_ceiling => "text",
);
```

Both `logical_name` and `source_detail_ceiling` are required. The ceiling is exactly `none`, `identity`, `span`,
or `text`; an optional `top_rule` selects the same existing compilation entry rule. The constructor accepts a
decoded Perl character scalar or unflagged strict UTF-8 bytes. It copies the input, retains canonical UTF-8 bytes
for spans/digests, rejects malformed UTF-8 with a typed `LinkedSpec::SemanticIndex::Error`, and never accepts or
reads a source path.

The returned `LinkedSpec::SemanticIndex` is opaque rather than a blessed compiler hash. Successful source retains
private descriptor authority; a language compilation failure still returns the same object with an immutable
`failed_compilation` outcome and structured diagnostic evidence. Construction does not execute the parser. Public
queries receive only cloned plain-data projections, so descriptor coderefs, compiled regex objects, decoded source,
source-map objects, and filesystem identities cannot leak through the API.

Ask for effective limits and supported vocabularies with no request object:

```perl
my $capabilities = $index->capabilities;
die "semantic query unavailable" unless $capabilities->{ok};

my $facts = $capabilities->{records}[0]{facts};
print $facts->{source_detail_ceiling}, "\n"; # text
print $facts->{page_max}, "\n";              # 1000
```

`capabilities` returns the same complete response as the canonical v1 `capabilities` operation. Each call returns
a fresh copy; changing a returned record or nested fact cannot change the index or a later response.

All regular operations use the exact neutral request envelope. For example, list rules with source identity but
without source text:

```perl
use JSON::PP ();

my $answer = $index->query({
  contract => "linkedspec-semantic-query-v1",
  operation => "list",
  subjects => [],
  record_kinds => ["rule"],
  relation_kinds => [],
  direction => "outgoing",
  page => {after_id => undef, limit => 100},
  budget => {max_records => 1000, max_relations => 2000, max_depth => 4},
  source => {detail => "identity", include_content_digest => JSON::PP::false},
});

for my $rule (@{$answer->{records}}) {
  print $rule->{id}, " ", $rule->{source}{logical_name}, "\n";
}
```

Queries never compile, execute, read a path, enable trace, or mutate the request. Invalid requests are returned as
portable response diagnostics rather than host exceptions.

Capture runtime facts during a normal parser invocation, then derive a separate immutable index:

```perl
my $runtime_source = <<'SPEC';
Top::OR{2}
 /a/ -> Top[0] { return("A") }
 /b/ -> Top[1] { return("B") }
SPEC
my $parser = LinkedSpec::Get(\$runtime_source);
my $runtime_base_index = LinkedSpec::semantic_index(
  \$runtime_source,
  logical_name => "runtime.spec",
  source_detail_ceiling => "text",
);
my @events;
my $input = "ab\n";
my $value = $parser->(
  \$input,
  {semantic_observation_sink => sub { push @events, $_[0] }},
);

my $runtime_index = $runtime_base_index->with_execution_observation(\@events);
my $runtime_answer = $runtime_index->query({
  contract => "linkedspec-semantic-query-v1",
  operation => "list",
  subjects => [],
  record_kinds => ["execution", "event"],
  relation_kinds => [],
  direction => "outgoing",
  page => {after_id => undef, limit => 100},
  budget => {max_records => 1000, max_relations => 2000, max_depth => 4},
  source => {detail => "identity", include_content_digest => JSON::PP::false},
});
```

The sink receives `LinkedSpec::RuntimeSemanticObservationEvent` objects synchronously. Slot events contain the
executing rule, exact selected target rule/authored regex index, and post-match position. The final event contains
the selected entry rule, final position, `succeeded` status, and `input:sha256:...` identity over every original
input byte, including a trailing newline. If the callback dies, its exact exception identity is rethrown. The
observer is separate from textual trace and `diagnostic_sink`; all three can be active together.

The base `$index` stays static. Derivation validates native event type/schema, selected rule/slot topology, final
entry result, and input identity, copies the observation, and returns a different opaque index. Later caller
mutation cannot alter it. A query never captures events or runs a parser itself.

The internal source mapper is already exact: zero-based half-open strict-UTF-8 byte offsets, one-based lines,
one-based Unicode-scalar columns, rejected mid-codepoint ranges, and deterministic cursor-ordered lookup for
duplicate source text. Record-specific correlation is now performed only after compilation, against descriptor
order/topology and already accepted source; the general mapper still invents no grammar semantics.

## Current private static projections

Perl's `LinkedSpec::SemanticStaticProjection` and Rust's `semantic_index::static_projection` are internal layers
retained by their opaque indexes. Neither is a second public API. Each combines four authorities without
serializing any one of them:

- the backend's typed compiled owner supplies rule order, normalized family/cursor/repetition, ownership, and
  resolved edges;
- accepted decoded source distinguishes direct and indexed authored forms and supplies rule, slot, edge, and
  lifecycle ranges;
- the source mapper turns those ranges into exact strict-UTF-8 byte/line/scalar-column references; and
- structured diagnostic authority supplies failed-compilation fields.

The result contains v1 spec, source, rule, regex-slot, edge, lifecycle, diagnostic, decision, and explanation
records plus their static relations. Record ids percent-escape strict UTF-8 bytes with uppercase hex, duplicate
patterns keep separate authored slot numbers, unbounded repetition becomes null, and no-edge rules report `none`.
An indexed edge has target shape `regex_slot`; a direct edge has target shape `rule`. A self-indexed edge emits
`selects_regex` but not a redundant `dispatches_to` relation back to the same rule.

Failed `Top: / Missing`-style dependency intent remains source-aware even though no descriptor was produced. The
private projection normalizes the runtime `bare_edge_target_undefined` failure to portable
`unknown_rule_reference`, with `rule_id`/`missing_rule_id`, a dependency-resolution decision, and its ordered
explanation step. Returned copies admit only plain data and booleans; coderefs, compiled regex objects, backend
AST/IR, object identities, and paths are rejected at the clone boundary.

Each backend's focused projection tests materialize internal source keys and deep-compare the complete graph,
Unicode privacy at both construction ceilings, and failed snapshots, plus the runtime fixture's complete static
half, against the neutral oracle. Perl and Rust public evaluators now each own query-time source redaction, pages,
traversal, budgets, and costs over cloned projections. The composed Perl and Rust admission consumers are
described with the executable oracle below; both runtime observation surfaces are exact and admitted.

## Current private call, staging, and generated projection

The corrected calls fixture exercises every compiled authority that the static graph alone cannot represent:

```spec
fn normalize(value) { return(trim(value)) }

Top::
 /x/ -> Done {
   result = normalize(match_text())
   return(result)
 }

Done:
 /x/
```

The private Perl and Rust projections now each match all 22 neutral records and 25 relations for this source.
Definition order is `function:normalize`, `rule:Top`, `rule:Done`. Typed ActionIR traversal records `trim` in the function body,
then outer `normalize`, nested `match_text`, and the later `return` in the action block. The assignment creates a
mutable action binding; `normalize` writes it, and `return` reads it. Exact registered function resolution carries
a decision and two ordered explanation steps instead of exposing the registry object.

Value shapes are intentionally conservative. `trim` and `match_text` return `string` under the governed semantic
helper vocabulary, so `normalize`, the binding, the return call, the edge, and the owning rule can retain string
shape. A literal, binding, registered function, or governed helper may strengthen a shape; an unrecognized
expression remains `unknown` rather than inheriting a backend guess.

Function-body staging remains three distinct records:

```text
payload <-consumed by- parse_job -produces-> result
   ^                                      |
   +-------------- lowered_from ----------+
                         result -staged_by-> parse_job
```

The separate generated artifact reports `linkedspec-generated-source-v2`, format 2, family `default`. Each
compiler and semantic projector share their backend's existing generated-plan identity and handler-family owner,
so the semantic layer neither duplicates the family classifier nor generates implementation text.

Source coordinates have an important split. Function sidecar `source_span`/`body_span` fields count decoded
characters, while the typed call trees own semantic call structure. Only the final source-reference boundary
converts scalar spans to strict UTF-8 byte offsets and one-based Unicode-scalar columns. A focused `# préface`
case locks exact call excerpts and columns so ASCII cannot hide byte/character confusion. Original-source
correlation also treats top-level function shells as definitions, not rule material; an interleaved function
therefore cannot become a synthetic bare edge.

These projection mechanics remain internal implementation evidence. Perl and Rust expose the normalized records
only through their public query surfaces. Returned or retained values contain only
canonical JSON data and booleans: no descriptor coderef/compiled regex, raw function record, ActionIR layout,
generated source, object identity, or path. Perl runtime observation/routes and admission are implemented by
`.10.3.5-.10.3.6`; Rust query, runtime observation/routes, and admission are implemented by `.10.4.4-.10.4.6`.

## Why this is separate from the descriptor

The outward descriptor is a stable compatibility projection with `spec`, `functions`, `dependency_regex_map`,
and `meta`. It is useful input to a semantic index, but it is not a portable wire schema. For example, the Perl
descriptor deliberately contains compiled regex objects and handler coderefs. Rust, Dart, Julia, and Lua use
their own typed native representations for the same meanings.

The semantic model therefore normalizes those meanings into closed records and relations. It forbids host object
identity, backend AST/IR type names, callable objects, compiled regex objects, implicit filesystem paths, host
exceptions, and generated implementation source.

## Perl authority map

The behavior-free Perl audit establishes how the first adapter must be assembled. No single current object is a
semantic snapshot:

| Authority | Reusable meaning | Work still owned by the semantic adapter |
|---|---|---|
| decoded source plus canonical UTF-8 bytes | exact accepted text | coordinates/excerpts/digests are projected; query ceilings redact them structurally |
| outward descriptor | deterministic rule/function order, family/cursor/repetition/entry, edges, slots, staged function records | host values are normalized privately before public query |
| typed ActionIR AST | source-preorder calls, bindings, and nested spans | private resolution, portable shapes, and evidence now projected |
| runtime context | structured compilation failure | static unknown-rule normalization now implemented; other portable failures remain later |
| generated-source v2 owners | contract/format and handler family | separate generated-artifact relation now projected; never snapshot reconstruction |
| runtime handlers | exact accepted slot and final-result seams | typed invocation-local observation delivery now implemented separately from trace/diagnostics |

The query evaluator is deliberately not another semantic authority. It receives one cloned plain-data projection,
selects and redacts it under the v1 protocol, and returns a fresh plain-data response.

`LinkedSpec::Get` is character-oriented internally. Direct raw UTF-8 bytes for the privacy fixture's `Töp::`
label fail validation, while strict UTF-8 decoding first compiles the exact label and Unicode regex. Existing file
loaders already use strict decoding. The current semantic constructor now owns that boundary: it accepts decoded
text or strict UTF-8 bytes, rejects malformed input, preserves canonical bytes for byte offsets and digests, and
accepts only a caller-registered logical name—never an implicit host path.

## Rust authority map and current private projection

The Rust audit reaches a similar composition boundary with different native owners. Parsed rules and
function extraction, `CompiledSpec`, typed ActionIR, structured diagnostics, strict loaders, and generated-source-v2
plans collectively own reusable meaning. `CompiledSpec` is serde-safe and preserves descriptor equality after an
exact round trip, but ordinary rule/body AST nodes retain only lines and compiled expressions have no general source
span. Rust therefore uses an immutable source mapper over accepted text plus canonical UTF-8 bytes; staged
function sidecars are the richer exception, retaining character spans, typed body AST, and payload/job metadata.

Leaf `.10.4.1` implements that foundation in `linkedspec-runtime`. It preserves caller-owned logical identity,
strict UTF-8 bytes, exact byte/scalar coordinates, source ceilings, raw portable compilation failure, effective
entry identity, and shared generated-v2 plan rows around private parsed/compiled authority. It serializes no host
state. Leaf `.10.4.2` now composes that source with typed `CompiledSpec` root/family/cursor/repetition/slot/edge/
lifecycle authority into private plain-data static records and relations. It deliberately normalizes Rust's
`bare_edge_target_undefined` / `regex_slot_identity_invalid` seams to the neutral
`unknown_rule_reference`/`compile` evidence and deep-equals graph, both privacy ceilings, failure, and the runtime
static half. Leaf `.10.4.3` then composes compiled function registry data, typed ActionIR, normalized staged
sidecars, exact authored-source correlation, and the existing generated-v2 plan into the corrected 22-record/
25-relation call target. Definition/call preorder, helper and exact function resolution, conservative shapes,
bindings, Unicode source references, function-shell isolation, staged directions, and generated provenance now
deep-equal the neutral oracle. Leaf `.10.4.4` exposes typed and raw-neutral capabilities/query over fresh clones of
that normalized projection and matches all 19 static response digests.

Direct and generated Rust executors use authoritative slot-selection and rule-result seams. Completed leaf
`.10.4.5` adds a separate optional invocation-local typed observation sink there and derives a new immutable
post-execution index. It matches the twentieth response across direct, loaded, reconstructed, generated-plan,
source-emitter, traced, and untraced routes. It never parses trace text, changes diagnostic output, or lets queries
execute. Composed `.10.4.6` then admits those already-complete layers with one exact 12-role consumer.

The prerequisite is resolved by ADR `0051` and task `.10.4.0.2`: the published/Rust rule-label contract is a
nonempty sequence of pinned Unicode 17.0.0 `XID_Continue` scalars at every position. Identity is exact,
case-sensitive, and normalization-sensitive; no normalization or folding occurs. Rust now parses and validates
the admitted `Töp` fixture label across source, references, selectors, compiled/descriptor/generated identity,
strict loaders, and traces. Positive, negative, decomposed, and case-distinct route proofs prevent parser/book
drift. This removed the blocker for completed Rust semantic construction `.10.4.1` without admitting the Rust
semantic API at that prerequisite boundary. The later Dart/Julia/Lua semantic backend lanes inherit the pinned-
label prerequisite before their own v1 fixture admission. Toolbox repair `.10.4.0.1` made the semantic diagnostic
entry mechanically current; composed Rust admission advances its guarded claims to executable 6/20/73, rollout
3+6, admission 2+4, and complete Perl/Rust observation/admission state without changing response digests.

Dart audit `.10.5.0` now maps the next backend before behavior. Its staged `SpecFile` and function sidecars,
`CompiledSpec`, function registry, typed ActionIR resolution, portable diagnostics, strict loaded text, generated-v2
plan, and runtime slot/result seams are reusable authorities. Ordinary rule/body state is line-oriented, action
spans are local to normalized action text, and `LoadedSpec` also carries a host path; exact v1 construction therefore
needs a copied accepted-source byte/scalar mapper plus caller logical identity. Immutable source/outcome, static,
calls/staging/generated, query, runtime observation, and composed admission are frozen as `.10.5.1-.10.5.6`.

The audit also proves why two label prerequisites come first. Shared `.10.5.0.1` now generates/guards one pinned
class, consumes it at all 12 first-authoritative `specs/spec.spec` label sites, freshness-locks the four corpus
copies, and proves current grammar across five backends. Dart `.10.5.0.2.0-.1` generates the corresponding native
classifier/scanner, replaces all host-regex header/action/blind/bare label scans, rejects invalid-prefix
truncation, and validates parsed plus external AST declarations/targets. Existing compiled maps, descriptors,
generated plans/emitted source, and explicit selectors preserve valid Unicode strings exactly. Leaf `.2` now
proves that claim for all nine positive fixtures and both distinct pairs across compiled state, reconstruction,
an isolated emitted package, selectors, diagnostics, traces, strict loading, and primary commands. Leaves `.3-.4`
then split negative/isolation from composed signoff. Leaf `.3` now rejects all eight invalid fixtures across every
external-AST declaration/target role, source/no-prefix boundaries, and primary compilation while proving unrelated
function/parameter/helper/lifecycle/fluent/mark spellings remain unchanged. Composed `.4` closes the Dart label
prerequisite after complete Dart and canonical proof. It does not advance semantic rollout/admission; the opaque
source/outcome foundation begins independently at `.10.5.1`.

The complete Dart corpus's 105/105 result now includes four byte-fresh `spec_spec_*` inputs copied from current
`specs/spec.spec`. Shared closeout `.10.5.0.1.2` added exact hash/byte enforcement and composed the current grammar
across Perl, Rust, Dart, Julia, and Lua under default and POSIX environments, so the earlier stale-snapshot caveat
no longer applies.

## Julia authority map and prerequisite

Julia now exposes the opaque source and compiled-or-failed foundation through `SemanticIndex` and
`semantic_index`; it does not yet expose semantic records, capabilities, query, or typed runtime observation. Audit
`.10.6.0` mapped the typed authorities later consumed by the foundation and the remaining projection work: staged
rules and function shells, `CompiledSpec`, typed action nodes/contracts and function registry, portable diagnostics,
selected entry/generated-v2 plan, accepted runtime regex slots, and final parse results. The outward descriptor
remains a separate compatibility projection rather than a semantic wire schema.

Julia needs its own private canonical source map. Ordinary spec spans retain lines only; staged spans use scalar
positions; action spans are scalar offsets local to normalized action text. Compiled `definition_order` contains
rules but not staged function shells, so neutral authored order must merge both authorities. The constructor must
also explicitly reject malformed text as well as malformed bytes: Julia can represent invalid UTF-8 inside a
`String`. Four malformed byte shapes currently fail inconsistently as `InvalidCharError`, `SpecParseException`, or
staged `UserFunctionDefinitionParserException`, while byte vectors have no parser method. The future constructor
must reject both forms at a strict encoding boundary before parsing. Only a caller logical name may enter semantic
identity; resolved loader paths remain private.

Runtime observations will use a separate optional typed sink at the accepted-slot and successful final-result
seams. Existing `julia_runtime:regex_slot_selected` trace text is diagnostic evidence, not a typed semantic event,
and it has no matching final-result topic. Direct, loaded, reconstructed, generated, emitted, and traced routes
must propagate the same sink while preserving results, cursor, trace, diagnostics, and the exact callback
exception identity through generated execution's broad error translation. Returned values also need deliberate
deep detachment because immutable Julia structs may still contain mutable vectors and dictionaries; raw-neutral
numeric validation must reject booleans even though `Bool` is an `Integer` subtype in Julia.

ADR `0051` alignment is the first prerequisite. Before `.10.6.1.1`, Julia's five declaration/reference patterns
used host PCRE2 `\w` backed by Unicode 16.0.0, not the pinned Unicode 17.0.0 `XID_Continue` table. Exhaustive
comparison found
5,175 required scalars missing and 923 forbidden scalars accepted. Required `A·B` is rejected, forbidden `²` is
accepted, `Top:::` truncates to valid prefix `Top`, and programmatic or reconstructed action/blind/bare targets can
bypass membership validation into compiled and generated artifacts. Leaves `.10.6.1.0-.4` therefore generate and
route one pinned classifier, prove exact positive/distinct identity and negative/isolation across all routes, and
close without semantic promotion. Source/outcome, static graph, calls/staging/generated, query, runtime observation,
and one exact 12-role admission then follow as `.10.6.2-.7`.

Planning leaf `.10.6.1.0` is complete without behavior changes. It fixes the generated target as internal
`julia/src/spec/UnicodeRuleLabel.jl`, derived from the existing 806 neutral ranges and independently regenerated,
byte-compared, and endpoint-checked. The artifact supplies binary-search scalar membership, complete-label
validation, and a Julia-character-index-safe prefix scanner.

Implementation `.10.6.1.1` now consumes that artifact before `Parser.jl`. The five label-bearing host-regex
patterns are removed; one byte-boundary-safe scanner family handles complete headers, body termination,
action/blind/bare target groups, existing optional-index spellings, and allowed remainders. Invalid suffixes and
third colons cannot become valid prefixes, and malformed arrow starts remain raw syntax for the existing validator
rather than disappearing. Both traced and untraced validation check declarations and all three target kinds before
duplicate/structure/target checks, returning portable `invalid_rule_label` / `validate_rule_labels` evidence.
The generated helpers are internal module bindings, not exports or a new public API.

The remaining proof is deliberately staged. `.10.6.1.1` owns generation plus parser/validator routing and passes
1,755 focused assertions, complete Julia 5,466/primary/105, the 5x2x66 primary matrix, the ten-leg Unicode manifest,
and canonical Rust admission 79.93s plus Dart 1/1, primary 66x2, and Phase 0 1,031/663s. Exact-identity leaf `.2`
derives ten unique scalar sequences from all nine positive fixtures and both exact-distinct pairs. Its 130
assertions prove exact authored/compiled order and keys, compiled JSON, descriptor metadata, generated plans,
JSON reconstruction, direct and generated execution, deterministic emitted-payload reconstruction, a fresh
offline emitted host, strict source loading without resolved-path leakage, every explicit selector, exact portable
missing-selector diagnostics, native/generated traces, and inline plus UTF-8 file primary commands. Focused
composition is 1,885; complete Julia is 5,596/primary/105; 5x2x66 and the ten-leg Unicode manifest pass. No
production API, generated format, or semantic-governance state changes. Canonical proof passes Rust admission
1/1 in 80.21 seconds, Dart 1/1, primary 66x2, and Phase 0 1,031/1,031 in 645 seconds.

Negative/isolation `.10.6.1.3` consumes all eight negative fixtures directly. For declaration, action, blind, and
bare roles, both programmatic and JSON-reconstructed ASTs return the exact portable `invalid_rule_label` diagnostic
before validation, compilation, descriptor, generated plan, or emitted source can succeed. Complete physical
source tokens cannot recover a valid prefix; newline remains only a token boundary. Native/generated selectors
preserve the exact invalid scalar sequence as a missing entry, strict loaders keep existing typed path attribution
inside the loader while the detail is path-free, and primary commands emit only the portable compilation heading.
Function/parameter ASCII validation and the existing ActionParser ASCII-first host-word continuation remain
separate: `Töp` continues to be an action helper/variable/fluent/assignment identifier, while `A·B` and a
supplementary-first identifier remain raw there. Lifecycle, mark, regex, and bounded-mode grammars are unchanged.
The suite passes 1,946 assertions; focused composition is 3,831 and complete Julia is 7,542/primary/105. The
5x2x66 matrix, all ten Unicode-manifest legs, and Unicode/semantic/capability/generated/public no-drift contracts
pass without production, API, format, or semantic-governance change. Canonical proof passes Rust admission 1/1 in
79.56 seconds, Dart 1/1, primary 66x2, and Phase 0 1,031/1,031 in 645 seconds; exact cleanup reclaims about 1.57 GB
while preserving Pgen. Closeout `.10.6.1.4` reruns the committed four-suite proof at focused 3,831, complete Julia
7,542/primary/105, 5x2x66, and all ten Unicode-manifest legs. Unicode, semantic, capability, generated-source, and
public ledgers remain unchanged; the closeout adds no production/test/fixture/API/format state. Canonical proof
passes Rust admission 1/1 in 78.46 seconds, Dart 1/1, primary 66x2, and Phase 0 1,031/1,031 in 630 seconds; exact
cleanup reclaims about 1.57 GB while preserving Pgen. Parent `.10.6.1` closes and behavior-free `.10.6.2.0`
follows after the clean commit. Semantic governance stays 6/20/81 at rollout 4/9 and admission 3/6.

### Julia source and compilation foundation

Planning leaf `.10.6.2.0` froze the boundary, source leaf `.10.6.2.1` implemented strict copied input and exact
mapping, and outcome leaf `.10.6.2.2` now completes the compiled-or-failed foundation. `semantic_index(source,
options)`, plus the keyword convenience form, accepts copied valid `AbstractString` or strict
`AbstractVector{UInt8}` input. `SemanticIndexOptions` requires a nonempty control-free caller logical name, one
`SemanticSourceDetail` ceiling, and an optional exact Unicode-17 rule selector. The exported ceiling values are
`SemanticSourceNoneDetail`, `SemanticSourceIdentityDetail`, `SemanticSourceSpanDetail`, and
`SemanticSourceTextDetail`.

```julia
using LinkedSpecJulia

index = semantic_index(
    "Top::\n /x/\n";
    logical_name = "example.spec",
    source_detail_ceiling = SemanticSourceTextDetail,
)

identity = source_identity(index)
@assert identity.byte_length == 11
@assert identity.scalar_length == 11
@assert startswith(identity.content_digest, "sha256:")

@assert semantic_snapshot(index).state == SemanticCompiledSnapshotState
@assert semantic_snapshot(index).has_execution == false
@assert compilation_authority(index) == SemanticCompilationAuthority(true, true, true)
@assert compilation_diagnostic(index) === nothing
@assert entry_selection(index) == SemanticEntrySelection("Top", "first_authored_marker")
@assert generated_plan_input(index).rows ==
    (SemanticGeneratedPlanRow("Top", "default"),)

@assert source_excerpt_for_bytes(index, 0, 5) == "Top::"
@assert locate_exact(index, "/x/") == SemanticSourceSpan(7, 10, 2, 2, 2, 5)
```

`SemanticIndexError`, `SemanticSourceIdentity`, and `SemanticSourceSpan` are typed public values. Source accessors
map zero-based half-open UTF-8 bytes to one-based line and Unicode-scalar columns, return excerpts and ordered exact
occurrences only when the ceiling permits, and disclose canonical-byte SHA-256 only at `text`. Numeric inputs
reject `Bool` explicitly before accepting `Integer` because Julia makes `Bool <: Integer`. `\r\n` changes line at
the newline; carriage return and combining characters each advance one scalar column.

Strict construction validates options, copies and validates input, hashes it, and builds private immutable boundary
tables before language parsing. Malformed Julia strings or UTF-8 bytes reject at `decode_source` before character
iteration. Once that boundary succeeds, the owner invokes the existing staged user-function-aware parser,
validator, compiler with duplicate validation disabled, entry selector, and shared generated-v2 plan builder once.
It retains the typed `SpecFile`, `CompiledSpec`, merged authored function/rule order, entry, and plan privately.

Public outcome accessors return fresh detached `SemanticSnapshot`, `SemanticCompilationAuthority`,
`SemanticCompilationDiagnostic`, `SemanticEntrySelection`, and `SemanticGeneratedPlanInput` values. A successful
snapshot is `SemanticCompiledSnapshotState`; ordinary parse, validation, compile, selection, or plan failure
returns the same opaque index in `SemanticFailedCompilationSnapshotState`. Authority flags identify the completed
stages, while native portable diagnostics retain their exact code, stage, message, and sorted fields. Fatal
`InterruptException`, `OutOfMemoryError`, and `StackOverflowError` still propagate.

The calls fixture proves why authored order needs an adapter: function `normalize` is first in source, but compiled
definition order contains only rules `Top` and `Done`. `failed.spec` retains native
`bare_edge_target_undefined` / `normalize_edges` with `rule_label=Top` and `target=Missing`; an unknown selector
retains `entry_rule_not_found` / `select_entry_rule`. The shared generated plan carries contract
`linkedspec-generated-source-v2`, format 2, caller logical identity, and immutable label/family rows. The `none`
ceiling denies its source identity just as it denies `source_identity`.

Detachment is a correctness requirement: the audit proved that both
`to_json(compiled)["definition_order"]` and descriptor `meta.compiled_rule_order` alias live compiler vectors.
The semantic owner never consumes those projections. The opaque constructor and display expose no source buffer,
private map, path, logical name, digest, selector, AST/ActionIR, `SpecFile`, or `CompiledSpec`; every `to_json`
result is fresh mutable plain data that cannot alter retained state.

There is no source-path constructor and `SpecLoader` is not an identity owner. The staged frontend may use its
declared trusted parser specifications as compiler infrastructure, but construction never invokes the caller's
target parser, action, lifecycle, generated execution, trace, diagnostic-output sink, or semantic observer. A
probe whose target action unconditionally throws still parses, validates, compiles, selects, and produces a plan,
which directly verifies that boundary. Query, static records, runtime observation, MCP, rollout, and admission stay
outside this foundation.

Outcome implementation adds 85 assertions to the 135 source assertions. Closeout `.10.6.2.3` then recomposes those
exact committed suites at focused 220 without production or replacement test code; complete Julia is 7,762 package
assertions plus primary process and corpus 105/105. The shared primary matrix remains 5 backends x 2 environments x
66 cases and the self-hosted Unicode manifest remains ten 1/1 legs. Unicode stays 806/9/8/2; semantic governance
stays 6 groups / 20 queries / 81 mutations at rollout 4/9 and native admission 3/6; capability/generated/public
stay 80/0/0, v1/10/80-0-0, and 59/27/0. The parent adds no record/query/runtime surface and causes no semantic
promotion. The closeout canonical proof includes Rust semantic admission 1/1 in 80.84 seconds, Dart 1/1, primary
66x2, and Phase 0 1,031/1,031 in 630 seconds. Parent `.10.6.2` is composition-closed; static authority planning
`.10.6.3.0` follows after the clean commit. Knowledge Map 682/5,174 and exact 1.56-GB safe cleanup pass while all
517 Pgen issue artifacts remain preserved.

Implementation is omission-safe and dependency ordered:

1. `.10.6.2.1` added copied strict input, SHA-256 identity, private byte/scalar mapping, ceilings, typed source
   errors/values, exact source accessors, detachment, and source-only proof.
2. `.10.6.2.2` added one private staged compiled-or-failed outcome, merged function/rule order, entry identity,
   generated-v2 plan input, detached outcome accessors, and negative target-execution/path/descriptor topology.
3. `.10.6.2.3` recomposed both suites, complete Julia and canonical gates, no-drift ledgers, cleanup, and parent
   closure before static projection begins.

### Julia private static projection plan

Behavior-free audit `.10.6.3.0` fixes the next boundary before projector code. Julia will build the same five
private static targets already proven by Perl, Rust, and Dart:

| Construction target | Snapshot boundary | Records | Relations |
|---|---|---:|---:|
| graph | compiled, `text`, no execution | 12 | 14 |
| Unicode privacy | compiled, `text`, no execution | 4 | 3 |
| Unicode privacy limited | compiled, `identity`, no execution | 4 | 3 |
| failed compilation | failed, `span`, no execution | 6 | 4 |
| runtime fixture before observation | compiled, `text`, no execution | 7 | 8 |

The runtime-static target is derived by removing the execution record, three event records, and every relation
touching them from the runtime oracle, then setting `has_execution` to false. Building an index therefore cannot
silently run the target or turn trace output into events.

The static model is composed from several native owners. Copied accepted source, caller logical identity, SHA-256,
and the private source map own source references. Parsed rules and grouped body elements own authored order,
complete member spelling, explicit target-index spelling, entry markers, and lifecycle occurrences. Typed
`CompiledSpec` / `CompiledRule` own accepted compiled order, modes, structural slots, resolved action/blind edges,
payload presence, typed Action AST return shapes, and lifecycle payload identity. The existing detached entry value
owns the selected root and basis. The existing native diagnostic owns failure evidence before normalization.

The current source foundation already reproduces every one of the 14 neutral graph/privacy/failed/runtime source
references exactly: zero-based half-open UTF-8 bytes, one-based Unicode-scalar columns, excerpts, and digests all
agree. The projector still has to scan complete authored members because Julia's parsed element fragments are
intentionally smaller. For example, this one physical member becomes separate parsed regex and edge fragments:

```text
 /a/ -> Child[0] { return("first") }
```

Its final edge evidence spans the complete member, not only `-> Child[0]`. Multiline action blocks use the same
balanced-member boundary, and repeated lifecycle markers correlate to compiled payloads by authored occurrence.

Two normalization traps are explicit. First, Julia's native `is_repetition(Default)` is true with minimum zero,
while semantic v1 intentionally treats `Default`, `And`, `Single`, and `Pipe` as non-repeating with null bounds.
Second, `CompiledRule.regex_patterns` includes a parent matcher attached to a cross-rule edge. In the graph fixture,
Top therefore has two compiled `a` patterns, but the semantic target contains only Child's two structural regex
slots. A matcher is retained as a slot when it is an ordinary structural slot or a self-indexed matcher; the
runtime fixture's `Top[0]` and `Top[1]` matchers remain slots. Duplicate patterns never merge.

Failure normalization also remains one-way. The opaque foundation keeps Julia's native
`bare_edge_target_undefined` / `normalize_edges` diagnostic and its `rule_label=Top`, `target=Missing` fields. The
private projector alone emits `unknown_rule_reference` / `compile`, neutral rule ids and message, one dependency-
resolution decision, one ordered explanation, a `diagnoses` relation, and an `explained_by` relation citing
`diagnostic:compile:0`. Validation fails before the foundation builds its merged authored-definition tuple, so the
failed rule row is recovered from the retained parsed rule rather than an empty compiled-order view.

Stable ids percent-escape strict UTF-8 bytes with uppercase hexadecimal and use the closed record/relation kind
ranks. Internal storage must be recursively immutable and every oracle or later query copy fresh and detached.
This layer adds no public projection accessor: later query code applies `none`/`identity`/`span`/`text` beneath the
construction ceiling. Paths, parser/compiler objects, AST/ActionIR values, regex objects, descriptor state,
generated implementation source, executors, trace, diagnostic sinks, and runtime observers remain inaccessible.

Implementation is dependency-ordered: `.10.6.3.1` owns the exact compiled graph/source/evidence target;
`.10.6.3.2` owns both privacy ceilings, failed normalization, runtime-static absence, repeated-lifecycle safety,
clone isolation, and host-leak denial; `.10.6.3.3` recomposes all five targets and closes the private static parent.
The plan itself changes no production API, query, trace, runtime observation, generated format, semantic rollout,
or native admission.

Plan verification passes the existing source/outcome suites at 220 assertions, complete Julia at 7,762 package
assertions plus primary and corpus 105/105, the full five-backend/two-environment 66-case matrix, and all ten
Unicode-manifest legs. The neutral and public ledgers remain unchanged. Knowledge Map 683/5,188, mdBook, all four
doctrines, canonical Rust admission 78.75 seconds, Dart admission 1/1, reference primary 66x2, Phase 0
1,031/1,031 in 632 seconds, and exact 1.56-GB generated cleanup pass. `.10.6.3.1` is eligible only after this
behavior-free plan is committed cleanly.

### Julia private static projection implementation

Leaves `.10.6.3.1-.2` now implement all five construction targets behind the opaque Julia `SemanticIndex`:

| Target | Records | Relations | Exact boundary |
|---|---:|---:|---|
| graph | 12 | 14 | compiled graph, seven private source references |
| privacy | 4 | 3 | `text` ceiling, digest and excerpts available |
| privacy limited | 4 | 3 | `identity` ceiling, digest and source text unavailable |
| failed | 6 | 4 | portable failure projection over an unchanged native diagnostic |
| runtime static | 7 | 8 | compiled meaning only; no execution, events, or observations |

The failure boundary is deliberately two-layered. Julia's foundation still reports
`bare_edge_target_undefined` at stage `normalize_edges` with `rule_label=Top` and `target=Missing`. The private
static projection alone emits `unknown_rule_reference` at stage `compile`, portable rule ids, the dependency
decision and explanation, `diagnoses`/`explained_by` relations, and exact source evidence for `Missing`. Other
ordinary parse, validation, compile, entry-selection, and plan failures retain their native detached diagnostic;
the projector includes whatever parsed rules are available instead of returning an empty semantic snapshot.

Runtime-static construction never executes the target. Its target contains two self-indexed slots and their
`selects_regex` relations, but no execution/event records, `observed_as` relation, or redundant self
`dispatches_to`. Repeated lifecycle markers are occurrence-specific: two authored `E` members become distinct
`E:0` and `E:1` ids with independent order, value shape, source line, and containment relation.

Every test materialization is a fresh plain JSON tree, while retained object/array values remain tuple-backed and
recursively immutable. Tests deny path-like host values and forbid source text/bytes owners, AST/ActionIR,
descriptor/compiler/regex objects, loaders, emitted/generated execution, trace, diagnostic sinks, runtime
observers, environment reads, clocks, and randomness. The underscore-only proof seam is not exported; there is
still no public semantic query or projection accessor, and no rollout or native-admission movement.

Exact proof adds 99 assertions and composes with source 135, outcome 85, and graph 70 at focused 389. Complete
Julia passes 7,931 package assertions, primary process conformance, and corpus 105/105. The five-backend matrix is
5x2x66 and all ten Unicode-manifest legs pass. Canonical local CI passes Rust semantic admission in 78.27 seconds,
Dart admission 1/1, primary 66x2, and Phase 0 1,031/1,031 in 697 seconds. No-change `.10.6.3.3`, documented below,
recomposes these committed targets and closes the private static parent.

### Julia private static projection closeout

Leaf `.10.6.3.3` adds no production code, replacement test, fixture, API, or generated-format change. It runs the
four committed source 135, outcome 85, graph 70, and remaining-target 99 suites together at focused 389. That
composition reconfirms graph 12/14/7, both privacy targets at 4/3, failed 6/4, runtime-static 7/8, exact source
ceilings/evidence/order, projection-only failure normalization, lifecycle occurrence identity, detached/immutable
copies, generic failure fallback, private omission, and host denial as one surface.

Complete Julia passes 7,931 package assertions, primary process conformance, and corpus 105/105. The full primary
matrix passes 5 backends x 2 environments x 66 cases and all ten Unicode-manifest legs pass. Unicode remains
806/9/8/2; semantic governance remains 6/20/81 at rollout 4/9 and native admission 3/6; capability/generated/public
remain 80/0/0, v1/10/80-0-0, and 59/27/0. Canonical local CI passes Rust semantic admission in 80.89 seconds,
Dart admission 1/1, primary 66x2, and Phase 0 1,031/1,031 in 653 seconds. Parent `.10.6.3` is therefore
composition-closed with no public query, runtime observation, or semantic promotion. Behavior-free authority plan
`.10.6.4.0` now separates typed calls/bindings core from staged/generated completion before projection changes.

### Julia calls, staging, and generated authority plan

Behavior-free leaf `.10.6.4.0` fixes the exact private calls target before implementation. The neutral
`calls_and_staging` snapshot has 22 records and 25 relations. Julia's existing static projection supplies six
records and six relations. Typed functions, helpers, calls, bindings, their decisions, and explanations complete
an 18/16 non-staged core; three staged artifacts and one selected generated-plan artifact add four records and
nine relations.

The adapter composes existing authorities rather than inventing a second semantic engine:

- the accepted source map supplies canonical UTF-8 byte and Unicode-scalar evidence;
- the function registry supplies exact definitions, parameters, signatures, shell/body text, and staged sidecars;
- `parse_action_block` supplies a typed function-body Action AST whose JSON must equal the retained staged
  `body_ast`, and action contracts validate it;
- compiled edge Action AST supplies assignment, nested calls, return, and binding behavior; and
- retained generated-v2 plan input supplies contract, format, logical identity, ordered families, and selected row.

`CompiledSpec.definition_order` contains rules only. Exact neutral definition order therefore merges functions and
rules by authored source start. `ActionSourceSpan` is also local Unicode-scalar space over normalized action text,
not a global byte range. The projector walks typed calls outer-before-inner and correlates them through a balanced,
occurrence-safe scan bounded to the exact raw function shell or action edge. A staged global body range selects the
unique enclosing function shell. All nine distinct neutral source ranges already reproduce exactly, and an
interleaved `é` probe proves multibyte byte widths do not corrupt scalar columns or member identity.

Resolution checks an exact registered user function before the deliberately narrow neutral helper table. The
calls fixture uses only `trim`, `match_text`, and `return`. Shape inference is a conservative fixed point over typed
literals, current bindings, registered returns, and those governed helper contracts; unsupported meaning remains
`unknown`. Fixed-arity definitions derive a signature from parameters when native v1 has none, while a future
variadic native signature maps its rest/min/max values without inventing a bounded maximum.

Native Julia staging fields are not copied into the neutral schema. The three distinct payload, parse-job, and
result records use ADR `0050` roles and directions; body source, job maps, serialized AST, and typed ActionIR stay
private. Generated provenance validates the retained plan against compiled rule order and selects only the unique
entry row (`default` for this fixture). It never emits or executes generated Julia source.

Implementation is dependency-ordered: `.10.6.4.1` adds the private typed 18/16 core;
`.10.6.4.2` completes staged/generated 22/25; `.10.6.4.3` recomposes committed proof without replacement code.
The existing underscore-only proof seam remains private. Public query, runtime observation, trace-derived facts,
semantic rollout, and native admission remain later leaves.

Plan verification passes the four committed semantic suites at focused 389, complete Julia at 7,931 package
assertions plus primary and corpus 105/105, the full five-backend/two-environment 66-case matrix, and all ten
Unicode-manifest legs. Every governance ledger remains unchanged. Knowledge Map 684/5,231, mdBook, all four
doctrines, canonical Rust admission 77.84 seconds, Dart admission 1/1, reference primary 66x2, Phase 0
1,031/1,031 in 625 seconds, and exact 1.56-GB safe cleanup preserving 517 Pgen artifacts pass. Typed core
implementation becomes eligible only after this behavior-free plan is committed cleanly.

### Julia private typed call core

Leaf `.10.6.4.1` now implements the exact non-staged 18-record / 16-relation subset behind Julia's opaque
`SemanticIndex`. It extends the existing 6/6 static base with one function, three governed helpers, one action
binding, four function-form calls, one user-call resolution decision, and two explanation steps. The entire
materialized target deep-equals the neutral snapshot after staged and generated records/relations are filtered out;
those four future records and nine relations remain exclusively owned by `.10.6.4.2`.

Meaning comes only from accepted typed authorities. The projector reparses the already-retained function body into
an `ActionBlock`, proves its JSON form equals the staged `body_ast`, resolves contracts against the function
registry, and traverses that typed block plus compiled edge Action AST. It does not parse the `.spec` again, execute
the target, invoke an emitter, inspect a descriptor, or derive facts from trace. The existing static owner invokes
the call extension before canonical ordering and recursive freeze.

Traversal is deterministic. Functions and rules merge by exact authored source start. Within each owner, an outer
call is emitted before calls in its arguments; ids use owner-local order while the record `order` field is global.
An exact registered user function resolves before governed helper fallback. Only `trim`, `match_text`, and `return`
are helper authorities for this target. The emitted signature supports both native v1 fixed parameters and a future
rest parameter with unbounded maximum arity. Function return, call argument/return, binding value, edge value, and
rule value shapes use a conservative fixed point; unsupported expressions remain `unknown`.

Raw authored text owns location, not meaning. A bounded scanner correlates typed preorder to occurrences inside
the exact function body or action member. It ignores escaped quoted strings and ActionIR regex literals while
balancing call parentheses. This matters because `/trim(fake())/i` before a real `trim(value)` must not steal the
typed call's source reference. The copied source map then emits zero-based UTF-8 byte spans and one-based line/
Unicode-scalar columns. Interleaved `é`, duplicate nested calls, and regex-contained call-looking text retain exact,
distinct evidence.

The retained projection stays recursively immutable and host-free; the underscore-only proof materializer returns
fresh detached plain JSON. No public call accessor, records API, query, runtime observation, path, compiler AST/IR,
registry, source-map object, execution callback, trace, diagnostic sink, environment, time, or random state is
exposed. The new suite passes 79 assertions and the five Julia semantic suites pass 468. Complete Julia passes
8,010 package assertions, primary process conformance, and corpus 105/105. Full primary passes 5x2x66; all ten
Unicode-manifest legs pass; governance stays 806/9/8/2, 6/20/81 at 4/9 + 3/6, 80/0/0, v1/10/80-0-0, and
59/27/0. Canonical CI passes Rust semantic admission in 77.41 seconds, Dart 1/1, reference primary 66x2, and Phase
0 1,031/1,031 in 622 seconds. mdBook and Knowledge Map 685/5,252 pass; exact safe cleanup removes 1,618,660 KiB
while preserving all 517 Pgen artifacts.

### Julia private staged and generated completion

Leaf `.10.6.4.2` extends that same retained owner to the complete 22-record / 25-relation target. For every
accepted function, the projector requires native payload and typed parse-job fields to agree with the function
definition, authored body, exact staged span, parameter/signature form, parser/top-rule intent, stitch policy,
failure policy, and nonempty typed body result. Only after that correlation succeeds does it emit distinct neutral
payload, parse-job, and result records. Their three `contains` relations plus exact `consumes`, `produces`, two
`lowered_from`, and `staged_by` directions preserve provenance without exposing the native payload map, parse-job
object, serialized body AST, or typed ActionIR.

Generated provenance uses the retained `SemanticGeneratedPlanInput`; it does not rebuild a plan. Contract id,
format version, caller logical identity, complete ordered compiled-label coverage, and exactly one selected entry
row must agree. The projection emits only one neutral handler-plan record with the retained selected family
(`default` for this fixture) and one `generated_as` relation. No Julia source emission, generated implementation
text, module loading, or generated execution occurs.

The complete projection deep-equals the neutral calls snapshot at 22/25 with ten source references. Corrupted
payload/job fields and mismatched plan contract, logical identity, label order, or selected row reject through the
typed semantic correlation error. Fresh materialization, tuple-backed retention, plain JSON, host/path denial, and
absence of public staged/generated accessors remain exact. The new suite passes 62 assertions; all six semantic
suites pass 530; complete Julia passes 8,072 package assertions, primary process conformance, and corpus 105/105.
Full primary passes 5x2x66, all ten Unicode legs pass, governance stays 806/9/8/2, 6/20/81 at 4/9 + 3/6,
80/0/0, v1/10/80-0-0, and 59/27/0, and canonical CI passes Rust semantic admission in 76.95 seconds, Dart 1/1,
reference primary 66x2, and Phase 0 1,031/1,031 in 622 seconds. Public query, runtime observation, rollout, and
native admission remain later leaves.

### Julia private calls composition closeout

Leaf `.10.6.4.3` adds no projector, replacement test, fixture, contract, public API, or generated-format behavior.
It reruns the six committed source, outcome, graph, remaining-static, typed-call, and staged/generated suites in one
process at exact focused 530. This composition reconfirms all 22 records, 25 relations, and ten source references,
including Unicode-safe authored order and locations, nested and duplicate call identity, regex-contained text
isolation, user-before-helper resolution, fixed/rest signatures, conservative shapes, binding/decision/staging
directions, selected-plan authority, corrupt sidecar/plan rejection, recursive freeze, detached copies, private
omission, and the complete host/path/AST/IR/emitter/executor/trace/sink/observer denial boundary.

Complete Julia remains 8,072 package assertions plus primary process conformance and corpus 105/105. The full
five-backend primary matrix passes 5x2x66 and all ten Unicode-manifest legs pass. Governance remains 806/9/8/2,
6/20/81 at rollout 4/9 and native admission 3/6, 80/0/0, v1/10/80-0-0, and 59/27/0. Canonical CI passes every
doctrine and portable contract, Rust semantic admission 1/1 in 77.68 seconds, Dart admission 1/1, reference primary
66x2, and Phase 0 1,031/1,031 in 622 seconds. Parent `.10.6.4` is therefore composition-closed without promoting
Julia. Immutable public query begins with behavior-free authority audit `.10.6.5.0`; runtime observation and exact
native admission remain `.10.6.6-.7`.

### Julia immutable query authority plan

Behavior-free leaf `.10.6.5.0` freezes the API boundary before query code. Julia's existing
`_SemanticStaticProjection` is the sole evaluator authority. It contains the snapshot plus recursively tuple-backed
source references, records, and relations. Each call must receive one fresh detached materialization; it cannot
receive the retained decoded source/map, source above the construction ceiling, parser/compiler, staged sidecars,
AST/ActionIR, compiled regexes, generated implementation, loader/emitter/executor, runtime observation, trace or
diagnostic sink, path, environment, clock, randomness, or another host object.

The completed audit is fully verified without changing behavior: neutral governance remains 6 fixture groups / 20
responses / 81 rejected mutations at rollout 4/9 and native admission 3/6; focused Julia proof is 530 plus a fresh
detached 22-record / 25-relation / 10-source-reference probe. Complete Julia 8,072/primary/105, primary 5x2x66,
all ten Unicode legs, unchanged ledgers, canonical Rust/Dart admission + reference primary 66x2 + Phase 0
1,031/655s, book/KM 687/5,277, doctrines, and exact 1,812,240-KiB cleanup preserving 517 Pgen artifacts pass.

The query parent owns 19 static response hashes. The twentieth `runtime_events` hash needs caller-captured
post-execution authority and stays in `.10.6.6`. Raw-neutral validation must reproduce all 26 portable malformed-
request envelopes. Julia needs a deliberate numeric fence: page and budget fields test `Bool` before `Integer`
because `true isa Integer`, while `include_content_digest` accepts only an actual `Bool`.

The frozen immutable vocabulary is `SemanticQueryOperation`, `SemanticQueryDirection`, `SemanticQueryPage`,
`SemanticQueryBudget`, `SemanticQuerySource`, `SemanticQuery`, `SemanticQuerySourceReference`,
`SemanticQueryRecord`, `SemanticQueryRelation`, `SemanticQueryDiagnostic`, `SemanticQueryPageState`,
`SemanticQueryCost`, and `SemanticQueryResponse`. It reuses `SemanticSourceDetail`, `SemanticSourceSpan`, and
`SemanticSnapshot`. Collections are copied tuples; variable-shape facts and diagnostic fields are recursively
immutable; every `to_json` call returns a fresh `Dict`/`Vector` tree.

These public calls were planned together at `.10.6.5.0` and are now implemented by `.10.6.5.3`:

```julia
capabilities = semantic_capabilities(index)

rules = semantic_query(
    index,
    SemanticQuery(
        operation = SemanticQueryListOperation,
        record_kinds = ("rule",),
        page = SemanticQueryPage(limit = 20),
        source = SemanticQuerySource(detail = SemanticSourceSpanDetail),
    ),
)

neutral = semantic_query_neutral(index, Dict(
    "contract" => "linkedspec-semantic-query-v1",
    "operation" => "get",
    "subjects" => [rules.records[1].id],
    "record_kinds" => [],
    "relation_kinds" => [],
    "direction" => "outgoing",
    "page" => Dict("after_id" => nothing, "limit" => 100),
    "budget" => Dict("max_records" => 1000, "max_relations" => 2000, "max_depth" => 4),
    "source" => Dict("detail" => "none", "include_content_digest" => false),
))
```

Typed `semantic_query` is the ordinary embedding path. `semantic_query_neutral` is the transport-facing path where
wrong container/scalar shapes must produce portable response diagnostics rather than Julia dispatch or constructor
errors. Both enter the same evaluator and return the same typed response envelope. `semantic_capabilities` is the
canonical capabilities request, not a separate information source.

Implementation is omission-safe: `.10.6.5.1` adds private immutable values and capabilities/list/get/explain plus
source redaction; `.2` adds filtered directional breadth-first traversal, canonical pages/cursors, logical budgets/
costs, deterministic prefixes, and all 19 static hashes; `.3` exports the complete typed/raw-neutral surface and
locks all 26 boundaries, clone isolation, non-interference, privacy, and host denial; `.4` recomposes committed
proof without a replacement evaluator. Planning itself changes no production code, test, fixture, contract,
public API, generated format, runtime observation, rollout, or admission.

### Julia private immutable query kernel

Leaf `.10.6.5.1` now implements the first dependency-safe portion while keeping every planned public name absent.
`SemanticQuery.jl` contains the complete frozen request/response vocabulary plus the private
`_semantic_query_kernel`. It matches nine full response digests: capabilities, graph rule listing, duplicate-regex
text detail, entry explanation, call symbols/shapes, failed diagnostics, privacy with no source, privacy with text
and digest, and forbidden source detail.

At the `.10.6.5.1` boundary, the kernel owned only non-traversal default-page/default-budget behavior. It preserves
canonical record order, decision-before-step explanations with their `explained_by` relations, exact logical costs,
source-ceiling errors,
structural redactions below text detail, and digests only at requested text detail. Cursor and non-default page,
record/relation/depth budgets, directional breadth-first traversal, deterministic incomplete prefixes, and the
remaining ten static digests were assigned to `.10.6.5.2`.

All values are immutable structs with copied tuples. Variable facts and diagnostic fields use distinct private
tuple-backed object and array wrappers, so empty JSON objects and arrays remain different without retaining mutable
containers. Every `to_json` conversion returns a fresh `Dict`/`Vector` tree. Page and budget construction rejects
`Bool` before accepting `Integer`, preserving the portable boundary despite Julia's subtype relationship.

Each evaluation invokes `_semantic_static_projection_materialize(index)` exactly once and passes only that fresh
detached plain-data clone to the evaluator. Retained source text/maps/outcomes, parser/compiler/staged owners,
AST/IR, regex, generated implementation, execution, observation, trace/sinks, paths, environment, time, randomness,
and other host state remain unreachable. The new suite passes 100 assertions and all seven Julia semantic suites
pass 630; complete Julia passes 8,172/primary/105, primary passes 5x2x66, and all ten Unicode legs pass. Governance
remains 6/20/81 at rollout 4/9 and native admission 3/6. At that historical boundary, `semantic_capabilities`,
`semantic_query`, `semantic_query_neutral`, and the query types remained unexported pending `.10.6.5.3` raw
validation. Canonical signoff passes Rust admission 1/1 in 80.95 seconds, Dart 1/1, reference primary 66x2, Phase
0 1,031/1,031 in 662 seconds, book/KM 688/5,287, all four doctrines, and exact 1,613,088-KiB cleanup preserving
517 Pgen artifacts.

### Julia private traversal, paging, budgets, and costs

Leaf `.10.6.5.2` completes the private static evaluator without exporting a partial query API. The same
`_semantic_query_kernel` now matches all 19 non-runtime response hashes. Its ten completion cases cover reverse
graph dispatch, staged and generated provenance, after-id and page boundaries, record/relation/depth limits,
unsupported contracts, and invalid operation combinations.

Paging always starts from the filtered primary stream: records for list/get/capabilities, relations selected by
traversal, or explanation steps after the mandatory decision. `after_id` must occur in that stream. The selected
prefix is bounded by both page size and the applicable logical budget. Page-only truncation carries a next cursor
without a warning. Budget truncation carries the same deterministic cursor, forces `complete=false`, and returns
`semantic_query_budget_exceeded`. Explain reserves one record budget unit for its decision and derives
`explained_by` relations only for returned steps.

Relation traversal is filter-constrained breadth-first search in outgoing, incoming, or both directions. Relation
ids are selected only once across layers; visited record ids are removed from each next frontier; first logical
depth is retained; and selected relations are finally restored to canonical source order. A remaining matching
layer beyond `max_depth` produces the exact depth-limited prefix. When relation and depth ceilings both constrain a
query, `max_relations` is the reported limit.

Costs describe returned model work, not host resources: records returned, relations returned, and deepest returned
BFS layer. Rejected requests report zero cost. The evaluator still consumes exactly one detached projection clone
and has no route to source/compiler/staged/AST/IR/generated/runtime/trace/path/host authority. New proof is 118,
all eight semantic suites compose at 748, and complete Julia reaches 8,290 package assertions plus primary process
conformance and corpus 105/105. At that historical boundary, query values and names remained unexported pending
`.10.6.5.3` and its 26 raw-neutral validation boundaries; runtime events remain `.10.6.6`. Full primary
5x2x66, ten Unicode legs, unchanged ledgers, canonical Rust 82.53s + Dart 1/1 + primary 66x2 + Phase 0
1,031/647s, book/KM 689/5,298, doctrines, and exact 1,613,224-KiB cleanup preserving 517 Pgen artifacts pass.

### Julia public typed and raw-neutral query

Leaf `.10.6.5.3` exports the complete frozen query vocabulary and the three public calls together. There is no
second transport evaluator: `semantic_query` converts the immutable typed request into the neutral shape consumed
by `semantic_query_neutral`, and both enter one validator/evaluator. Each request materializes exactly one fresh
detached static projection; its detached snapshot also supplies rejected envelopes before valid requests enter the
kernel. `semantic_capabilities(index)` is the canonical capabilities request through that same seam.

The raw-neutral input may be an ordinary `Dict` or a direct `JSON3.Object`. It must have exactly the v1 top-level,
page, budget, and source keys. Wrong contracts, containers, fields, enum values, subject/filter types and
duplicates, kind ranks/order, direction, cursor, page/budget values, source policy, digest type/detail policy,
operation combinations, subjects, cursors, and explanation targets produce the exact portable rejected response.
Julia rejects `Bool` before `Integer` for all numeric fields. Invalid requests return no records, relations,
diagnostics beyond the one portable boundary diagnostic, explanation steps, or logical costs.

All 19 non-runtime canonical responses have identical hashes through typed and raw-neutral paths. The new public
suite covers those 38 responses and all 26 malformed boundaries, then locks fresh response and request clones,
interleaving isolation, source privacy and ceilings, every public export, callback non-invocation, construction and
query non-execution, exactly one materialization seam, and denial of retained source/compiler/parser/AST/IR/
generated/runtime/trace/environment/time/random authority. It passes 315 assertions; all nine semantic suites
compose at 1,063, and complete Julia reaches 8,605 package assertions plus primary process conformance and corpus
105/105. The twentieth runtime-events response remains `.10.6.6`, and this leaf does not promote the shared
semantic rollout or native-admission ledgers. No-change closeout `.10.6.5.4` is next after the clean commit.
Full primary 5x2x66, ten Unicode legs, canonical Rust 79.96s + Dart 1/1 + primary 66x2 + Phase 0 1,031/634s,
mdBook/KM 690/5,307, all four doctrines, and exact 1,613,820-KiB cleanup preserving Julia package/registry caches
and all 517 Pgen artifacts pass.

## Exact v1 record model

Every record has exactly:

```text
id, kind, name, owner_id, order, source, facts, redactions
```

The fixed kind order is:

```text
capabilities, spec, source, rule, regex_slot, edge, lifecycle,
function, helper, binding, call, staged_artifact, generated_artifact,
diagnostic, decision, execution, event, explanation_step
```

Each kind has a closed fact vocabulary. Nullable fields remain present as `null`; portable responses cannot grow
backend-only facts. Records sort by kind rank, source order, then id.

Every relation has exactly:

```text
id, kind, from_id, to_id, order, source, facts, evidence_ids
```

The fixed relation order is:

```text
declares, contains, depends_on, dispatches_to, selects_regex, calls,
resolves_to, reads, writes, consumes, produces, lowered_from, staged_by,
generated_as, diagnoses, observed_as, explained_by
```

Relations sort by source-record order, relation-kind rank, target order, then id. Arrays are order-sensitive; JSON
object-key order is not.

## Stable identity

Ids are deterministic inside one immutable snapshot. Names are encoded as strict UTF-8 bytes; bytes outside
`A-Z`, `a-z`, `0-9`, `.`, `_`, `~`, and `-` use uppercase percent escapes. For example:

```text
rule:T%C3%B6p
regex:rule:T%C3%B6p:0
```

Important id families include:

```text
rule:<escaped-label>
regex:<rule-id>:<authored-slot>
edge:<rule-id>:<normalized-source-order>
call:<owner-id>:<preorder>
staged:<artifact-kind>:<owner-id>:<owner-order>
decision:<kind>:<subject-id>
explanation:<decision-id>:<order>
relation:<kind>:<from-id>:<to-id>:<order>
```

V1 does not promise that ids survive source edits. A durable project identity belongs to the caller, outside this
model.

## Staged parsing is explicit

The first executable fixture exposed a hole in the design: staged provenance had relations but no honest record
for a payload, parse job, or result. ADR 0050 corrected the schema before implementation. A function body now has
three separate `staged_artifact` records:

```text
function owner
  contains -> payload  <- consumes - parse job
  contains -> parse job - produces -> result
  contains -> result   - staged_by -> parse job

payload - lowered_from -> authored source
result  - lowered_from -> payload
spec    - generated_as -> generated artifact
```

A parse job is not a `generated_artifact`. Staged records carry payload/node kind, parent path, parser spec, top
rule, result/failure policy, status, and value shape. Generated artifacts remain separately versioned emitted or
reconstructed products.

## Query envelope

All operations use one exact request shape. Unused arrays remain present and empty:

```json
{
  "contract": "linkedspec-semantic-query-v1",
  "operation": "get",
  "subjects": ["rule:Top"],
  "record_kinds": [],
  "relation_kinds": [],
  "direction": "outgoing",
  "page": {"after_id": null, "limit": 100},
  "budget": {"max_records": 1000, "max_relations": 2000, "max_depth": 4},
  "source": {"detail": "span", "include_content_digest": false}
}
```

Operations are:

- `capabilities`: one synthetic capabilities record;
- `list`: canonical records, optionally filtered by record kind;
- `get`: canonical records for one or more ids;
- `relations`: deterministic directional breadth-first relation traversal; and
- `explain`: one decision, its ordered explanation steps, and only their `explained_by` relations.

To follow incoming dispatch edges, change the operation-specific fields while keeping every envelope key:

```perl
my $incoming = $index->query({
  contract => "linkedspec-semantic-query-v1",
  operation => "relations",
  subjects => ["rule:Child"],
  record_kinds => [],
  relation_kinds => ["dispatches_to"],
  direction => "incoming",
  page => {after_id => undef, limit => 100},
  budget => {max_records => 1000, max_relations => 2000, max_depth => 4},
  source => {detail => "identity", include_content_digest => JSON::PP::false},
});
```

Relation filters constrain traversal itself. Results are returned in canonical relation order even though the
frontier is explored breadth-first.

The response always has exactly:

```text
contract, model, ok, snapshot, records, relations, page, cost, diagnostics
```

Compilation/runtime diagnostics are semantic `diagnostic` records. Query failures use the separate four-field
response diagnostic shape and these portable codes:

```text
semantic_query_budget_exceeded
semantic_query_invalid
semantic_query_source_detail_forbidden
semantic_query_contract_unsupported
```

## Pagination and budgets

`page.after_id` is the last returned canonical id, not a backend cursor. Default/max page limits are 100/1000.
Default budgets are 1,000 records, 2,000 relations, and depth 4; maxima are 10,000, 20,000, and depth 8.

When a budget is reached, the response returns a deterministic canonical prefix, sets `page.complete` to false,
and reports `semantic_query_budget_exceeded`. Logical cost counts emitted primary records/relations and the deepest
emitted relation frontier, never CPU time, allocations, object visits, or other backend-private work.

For example, listing with `max_records => 2` returns the first two canonical records, reports
`cost.records_examined == 2`, leaves `page.complete` false, and names `max_records` in the warning diagnostic. A
page limit can also make a page incomplete, but that is ordinary pagination and does not produce a budget warning.

## Source detail and privacy

An index has a caller-selected source ceiling. Each query requests one level:

| Detail | Returned source data | Source-derived facts |
|---|---|---|
| `none` | `source: null` | null plus an exact redaction path |
| `identity` | source id and caller-registered logical name | still redacted |
| `span` | identity plus exact UTF-8 span | still redacted |
| `text` | span plus exact excerpt; optional digest | available |

Spans use zero-based, half-open strict-UTF-8 byte offsets, one-based lines, and one-based Unicode-scalar columns.
Digests are `sha256:` plus lowercase hex over the exact source bytes. A query above the ceiling is rejected; it is
never silently downgraded. The Unicode fixture locks uppercase id escaping, multibyte offsets, scalar columns,
redaction, excerpt, and digest behavior.

## Runtime observations do not make queries execute parsers

A semantic query is read-only. It cannot compile a spec, evaluate an action, run a parser, load an undeclared
file, or enable tracing. Runtime records appear only when the caller gives the index an already completed typed
execution observation. A failed compilation may still produce a diagnostic-only semantic snapshot.

The base Perl and Rust indexes report `has_execution` and `execution_observation` as false. A derived index reports
both as true and adds `execution:0`, two exact slot events, one final rule-result event, and their `observed_as`
relations for the canonical `Top::OR{2}` / `ab\n` fixture. All 20 canonical answers are available through both
native APIs.
Direct parsers, loaded specs, portable loader results, captured generated source, independently loaded generated
`Execute`/`Get`/`ExecuteWithTrace`, and validated reconstructed plans produce the same observation and response.
Rust's direct, loaded, reconstructed, generated-plan, source-emitter, traced, and untraced option routes likewise
produce the same observation and twentieth response. Neither backend's query evaluator executes a parser.

## Executable oracle

The contract artifacts are:

```text
capability_conformance/semantic_introspection_contract.json
capability_conformance/semantic_introspection_model.json
capability_conformance/semantic_introspection/*.spec
tools/check_semantic_introspection_contract.py
```

Run:

```bash
python3 tools/check_semantic_introspection_contract.py
```

The gate validates six fixture groups, derives 20 full canonical responses, compares each response with its fixed
SHA-256 digest, and reports 81 rejected mutations. The cases cover graph/slot/lifecycle meaning, calls and shapes,
staged and generated provenance, explanations, failed compilation, caller-captured runtime events, reverse
relations, page cursors and boundaries, record/relation/depth budgets, all source policies, a lowered ceiling, an
unsupported contract, and an invalid operation combination.

The checker runs unconditionally in canonical local CI. It admits only an owned backend whose exact consumer,
ordered roles, tracked path, canonical driver, native status, and rollout row all agree; every later backend still
fails if promoted early. It also reads `TOOLBOX.md` and locks the exact command output plus Perl, Rust, and Dart
runtime/admission claims. Internal omission and wrong-value probes prove that documentation guard independently of the 81
semantic-contract mutations.

Perl's native evaluator has a separate exact gate:

```bash
PERL5LIB= prove -Iperl t/semantic_index_perl_query.t
```

It reconstructs the five static source/ceiling inputs through the public constructor, executes the 19 non-runtime
canonical requests, and compares every full response digest. Additional cases lock request validation, source
privacy, clone isolation, silence, path/host-layout denial, and successful query evaluation while the compilation
entrypoint is disabled.

Rust's equivalent static gate is:

```bash
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_query
```

Its five tests reconstruct every static source/ceiling input, match all 19 non-runtime response digests through
both typed and neutral entrypoints, cover the same exact 26 request/error boundaries, and lock privacy, response/
input isolation, deterministic interleaving, absent execution state, and host/path/IR denial.

Rust's runtime route gate is:

```bash
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_runtime_observation
```

Its seven tests match the twentieth digest through typed and raw-neutral queries across direct, loaded,
reconstructed, generated-plan, source-emitter, traced, untraced, and independently compiled emitted-module routes.
They also lock malformed observation rejection, base/derived/event/response isolation, query non-execution, exact
observer panic identity, Unicode-scalar positions, trace/diagnostic neutrality, and the absence of a completion
event after failed entry selection.

The runtime route gate is:

```bash
PERL5LIB= prove -Iperl t/semantic_index_perl_runtime_observation.t
```

Its 106 assertions match the twentieth response digest across eight execution roles, preserve exact result/input/
cursor and generated-plan behavior, reject malformed or foreign observations, prove derived queries work with the
execution entrypoint replaced by a die, preserve exact observer exception identity, and compare trace plus
diagnostic streams with and without semantic capture.

Perl admission composes those separate gates through one omission-sensitive consumer:

```bash
PERL5LIB= prove -Iperl t/semantic_introspection_perl_admission.t
```

Its 12 exact-once roles cover strict byte/text source normalization, compiled graph/calls/privacy snapshots,
failed compilation, runtime direct/loaded/generated/traced routes, native capabilities plus neutral JSON, all 20
canonical query digests, privacy/page/budget/error/explain behavior, query non-interference, immutable returned
data, and stale host-path/object/IR denial. The neutral checker rejects eight additional Perl
path/role/driver/registration/admission mutations and advances only the Perl rows.

Rust admission composes its source, projection, query, and runtime gates through one omission-sensitive consumer:

```bash
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_introspection_rust_admission
```

Its 12 exact-once roles cover strict byte/text convergence, compiled graph/calls/privacy and failed snapshots,
direct/loaded/reconstructed/generated-plan/source-emitter/traced runtime routes, native typed plus neutral JSON,
all 20 canonical digests, privacy/pages/budgets/errors/explain, no-execute immutability, and host-path/object/IR
denial. Eight Rust-specific mutations lock path, role order, driver, canonical registration, native status, and
Rust-only rollout promotion.

Dart admission composes the same owners through one omission-sensitive consumer:

```bash
cd dart
dart test test/semantic_introspection_dart_admission_test.dart
```

Its 12 exact-once roles cover strict UTF-8 byte/decoded-text convergence; compiled graph/calls/privacy and failed
snapshots; direct, loaded, JSON-reconstructed, generated-plan, public generated-helper, standalone emitted, and
traced runtime routes; typed native plus neutral JSON; all 20 canonical digests; privacy, pages, budgets, portable
errors, and explanations; query non-execution and base/response immutability; and denial of host paths, objects,
AST/ActionIR, or generated implementation source. Eight Dart-specific mutations lock path, role order, driver,
canonical registration, native status, and Dart-only rollout promotion. The complete Dart gate passes format
85/0, analyzer, package 336/336, primary 66x2, and corpus 105/105.

The static rule facts also have an authority outside the semantic model. The checker reads
`linkedspec-rule-local-cursor-v1`, normalizes descriptor `or_default`/`seek` into neutral `or`/`seek`, derives
entry/repetition from each exact header, and reconciles rule ownership with normalized edge records. Therefore a
bare/default rule is never treated as an AND rule merely because a hand-authored model row says so, and a rule
with no compiled edges reports `none` instead of invented blind ownership. Three mutations update the wrong model
fact and all affected response hashes together; the independent cross-contract check still rejects each change.

Generated-plan identity has the same external-authority rule. The checker reads the admitted generated-source-v2
contract and exact ten-family vocabulary. The calls fixture's default entry compiles and emits family `default`;
the earlier `and_acode` model value was neither the selected family nor a legal v2 spelling. Illegal and
coordinated valid-but-wrong family mutations fail without relying on a selected query response.

Spec identity likewise comes only from the caller-registered logical name. The calls source is registered as
`calls_and_staging.spec`, so its semantic name is `calls_and_staging`; snapshot id `calls` cannot replace that
identity. Direct and coordinated wrong-name mutations fail even though no current query selects the spec row.

## Rollout and MCP boundary

The dependency order is:

| Owner | Work | Current state |
|---|---|---|
| `.10.2` | neutral contract, fixtures, exact oracle | complete |
| `.10.3.0` | Perl authority map and safe implementation split | complete |
| `.10.3.1` | Perl strict source/map/compiled-or-failed outcome foundation | implemented; admission unchanged |
| `.10.3.2.0` | correct and independently gate neutral static rule facts | complete |
| `.10.3.2.1` | Perl private static graph/diagnostic projection | implemented; admission unchanged |
| `.10.3.3.0-.10.3.3.1.0` | correct generated family and spec identity before projection | complete |
| `.10.3.3.1.1` | Perl private calls/bindings/staged/generated projection | implemented; admission unchanged |
| `.10.3.4` | Perl capabilities/query/privacy/pages/budgets | implemented; all 19 static digests exact; admission unchanged |
| `.10.3.5` | Perl runtime observations and direct/loaded/generated routes | implemented; twentieth digest exact; admission unchanged |
| `.10.3.6` | composed Perl semantic admission | complete; 12 roles, 20 exact queries, Perl-only promotion |
| `.10.4.1-.10.4.3` | Rust source/outcome plus static/call/staged projections | complete |
| `.10.4.4` | Rust capabilities/query/privacy/pages/budgets | implemented; all 19 static digests exact; admission unchanged |
| `.10.4.5` | Rust runtime observations and direct/loaded/generated routes | implemented; twentieth digest exact; admission unchanged |
| `.10.4.6` | composed Rust semantic admission | complete; 12 roles, 20 exact queries, Rust-only promotion |
| `.10.5.0` | Dart authority and Unicode-label prerequisite | complete |
| `.10.5.1.0` | Dart source/outcome contract and dependency split | complete; behavior-free |
| `.10.5.1.1` | Dart strict input/private map and source ceiling | complete; dependency-free source map |
| `.10.5.1.2` | Dart staged compiled-or-failed owner and generated-v2 plan | complete; no target execution |
| `.10.5.1.3` | Dart composed source/outcome foundation closeout | complete; privacy/isolation/host-state proof |
| `.10.5.2.0` | Dart exact static authority map and dependency split | complete; behavior-free |
| `.10.5.2.1` | Dart compiled graph/source/evidence projection | complete; private exact graph, no public query |
| `.10.5.2.2` | Dart privacy/failure/runtime-static and isolation parity | complete; all five private construction targets exact |
| `.10.5.2.3` | Dart composed static signoff and parent closure | complete; focused 6/6 plus full gates |
| `.10.5.2` | Dart private static projection parent | complete; all five construction targets exact |
| `.10.5.3.0` | Dart calls/staging/generated authority map and split | complete; behavior-free exact 22/25 plan |
| `.10.5.3.1` | Dart typed functions/helpers/calls/bindings core | complete; exact private 18/16 non-staged subset |
| `.10.5.3.2` | Dart staged/generated exact completion | complete; private 22/25 target deep-equals neutral oracle |
| `.10.5.3.3` | Dart calls composition closeout | complete; 22/22 final-code composition, no production change |
| `.10.5.4.0` | Dart query authority map and dependency split | complete; behavior-free 19-digest/26-boundary plan |
| `.10.5.4.1` | Dart typed record/source query kernel | complete; package-private, immutable, nine exact static digests |
| `.10.5.4.2` | Dart relations/pages/budgets/costs | complete; all 16 successful static digests exact |
| `.10.5.4.3` | Dart public typed/raw-neutral query | complete; exact 19 digests and 26 boundaries |
| `.10.5.4.4` | Dart composed query closeout | complete; final committed-code composition and gates |
| `.10.5.4` | Dart immutable typed/raw-neutral query parent | complete |
| `.10.5.5.0` | Dart runtime-observation authority map and split | complete; behavior-free exact seam/route plan |
| `.10.5.5.1` | Dart typed direct/loaded/reconstructed capture | complete; exact events/non-interference/failure identity |
| `.10.5.5.2` | Dart immutable observed-index derivation | complete; exact topology/immutability/twentieth digest |
| `.10.5.5.3` | Dart generated/emitted/traced observation routes | complete; exact events/outputs/traces/exit/callback identity, unchanged v2/format 2 |
| `.10.5.5.4` | Dart runtime-observation composition closeout | complete; committed semantic/runtime/public signoff without promotion |
| `.10.5.5` | Dart typed runtime observation parent | complete |
| `.10.5.6` | Dart composed semantic admission | complete; 12 roles, 20 exact queries, Dart-only promotion |
| `.10.6.0` | Julia authority and Unicode preflight | complete; behavior-free map and dependency split |
| `.10.6.1.0` | Julia Unicode classifier/route plan | complete; exact behavior-free generator, parser, validator, fixture, isolation, and gate split |
| `.10.6.1.1` | Julia generated classifier plus parser/validator routing | complete; focused 1,755, Julia 5,466/primary/105, 5x2x66, ten-leg manifest, and canonical signoff |
| `.10.6.1.2` | Julia exact positive/distinct downstream identity | complete; 130 new assertions, focused 1,885, Julia 5,596/primary/105, 5x2x66, and ten-leg manifest without production change |
| `.10.6.1.3` | Julia exhaustive negative rejection and unrelated-grammar isolation | complete; 1,946 new assertions, focused 3,831, Julia 7,542/primary/105, 5x2x66, ten-leg manifest, canonical signoff, and cleanup without production change |
| `.10.6.1.4` | Julia composed Unicode-label closeout | complete; committed focused 3,831, Julia 7,542/primary/105, 5x2x66, ten-leg manifest, no-drift, canonical signoff, and cleanup without promotion |
| `.10.6.2.0` | Julia source/outcome contract and dependency split | complete; behavior-free exact API/privacy/no-execution boundary, canonical proof, and cleanup |
| `.10.6.2.1` | Julia strict copied input and private source map | complete; 135 focused, Julia 7,677/primary/105, 5x2x66 plus ten Unicode legs, canonical signoff, and cleanup |
| `.10.6.2.2` | Julia compiled-or-failed outcome foundation | complete; 85 new/focused 220, Julia 7,762/primary/105, 5x2x66 plus ten Unicode legs, exact detached authority/diagnostic/entry/plan, canonical/cleanup, no execution or promotion |
| `.10.6.2.3` | Julia source/outcome foundation closeout | complete; committed focused 220, Julia 7,762/primary/105, matrices/no-drift/canonical signoff, and parent closure without production change |
| `.10.6.3.0` | Julia static authority map and dependency split | complete; five targets, normalization, privacy, and host fences frozen |
| `.10.6.3.1` | Julia compiled graph/source/evidence projection | complete; private exact 12/14/7 graph, no public query |
| `.10.6.3.2` | Julia privacy/failure/runtime-static and isolation | complete; exact 4/3 + 4/3 + 6/4 + 7/8 targets, no promotion |
| `.10.6.3.3` | Julia composed private static closeout | complete; committed focused 389 plus full matrices/canonical proof, no replacement code or promotion |
| `.10.6.4.0` | Julia calls/staging/generated authority map and dependency split | complete behavior-free plan; exact 22/25 and `.1-.3` ownership frozen |
| `.10.6.4.1` | Julia typed function/helper/call/binding core | complete; exact private non-staged 18/16, new 79/focused 468, no promotion |
| `.10.6.4.2` | Julia staged/generated calls completion | complete; exact private full 22/25, new 62/focused 530, no promotion |
| `.10.6.4.3` | Julia calls/staging/generated composition closeout | complete; committed focused 530 plus full gates, no replacement code or promotion |
| `.10.6.5.0` | Julia query authority map and dependency split | complete and fully verified behavior-free plan; detached authority, 19 hashes, 26 boundaries, and `.1-.4` frozen |
| `.10.6.5.1` | Julia private immutable non-traversal query kernel | complete; nine exact hashes, new 100/focused 630, no exports |
| `.10.6.5.2` | Julia private relations/pages/budgets/costs | complete; all 19 static hashes, new 118/focused 748, full signoff, no exports |
| `.10.6.5.3` | Julia public typed/raw-neutral query | complete; 19 typed/raw hashes, 26 malformed boundaries, new 315/focused 1,063, no runtime or ledger promotion |
| `.10.6.5.4` | Julia immutable query composition closeout | pending |
| `.10.6.6-.7` | Julia runtime observation and exact admission | pending |
| `.10.7` | PUC Lua and LuaJIT identity | pending |
| `.10.8` | recurring six-runtime proof | pending |
| `.10.9` | thin MCP transport | pending |
| `.10.10` | public no-drift and closure | pending |

The future MCP server has only capabilities and query tools over a caller-registered opaque native handle. It
cannot compile, read a path, traverse backend objects, cache a second semantic model, invent explanations, or
raise source/budget ceilings. Direct native and MCP responses must be identical after canonical JSON encoding.

Perl, Rust, and Dart callers can use the admitted native static and caller-captured runtime query surfaces now. No later
backend may claim semantic-introspection admission until its composed conformance leaf closes. Other
backends should continue using their existing descriptor APIs described in
[Descriptor Introspection](descriptor-introspection.md) until their native semantic adapter lands.

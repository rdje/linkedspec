# Semantic Introspection

LinkedSpec now has an executable, backend-neutral contract for deep semantic introspection. Perl and Rust have
admitted native query surfaces: opaque construction, exact static plus call/staged/generated projections, public
`capabilities`/`query` answers, optional caller-captured runtime observations, and one exact composed conformance
consumer. Rust now has an opaque strict-source, exact-coordinate, compiled-or-failed foundation; exact clone-safe
static and call/staged/generated projections; a public immutable typed/raw-neutral query evaluator; and optional
caller-captured typed runtime observations that derive a separate immutable post-execution index. One exact Rust
consumer now composes those layers across every governed route.
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
- the current `return_descriptor` / descriptor APIs remain a separate lower-level compatibility surface.

The neutral contract is complete. Backend admission is **2 complete / 4 pending**: Perl and Rust are admitted;
Dart, Julia, PUC Lua, and LuaJIT remain pending. MCP remains later transport work and does not own semantics.

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
SHA-256 digest, and reports 73 rejected mutations. The cases cover graph/slot/lifecycle meaning, calls and shapes,
staged and generated provenance, explanations, failed compilation, caller-captured runtime events, reverse
relations, page cursors and boundaries, record/relation/depth budgets, all source policies, a lowered ceiling, an
unsupported contract, and an invalid operation combination.

The checker runs unconditionally in canonical local CI. It admits only an owned backend whose exact consumer,
ordered roles, tracked path, canonical driver, native status, and rollout row all agree; every later backend still
fails if promoted early. It also reads `TOOLBOX.md` and locks the exact command output plus Perl and Rust runtime/
admission claims. Internal omission and wrong-value probes prove that documentation guard independently of the 73
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
| `.10.5.1.1-.10.5.1.3` | Dart strict input/map, compiled-or-failed owner, composed foundation | pending in dependency order |
| `.10.5.2-.10.5.6` | Dart projections, query, observation, and admission | pending |
| `.10.6` | Julia parity | pending |
| `.10.7` | PUC Lua and LuaJIT identity | pending |
| `.10.8` | recurring six-runtime proof | pending |
| `.10.9` | thin MCP transport | pending |
| `.10.10` | public no-drift and closure | pending |

The future MCP server has only capabilities and query tools over a caller-registered opaque native handle. It
cannot compile, read a path, traverse backend objects, cache a second semantic model, invent explanations, or
raise source/budget ceilings. Direct native and MCP responses must be identical after canonical JSON encoding.

Perl and Rust callers can use the admitted native static and caller-captured runtime query surfaces now. No later
backend may claim semantic-introspection admission until its composed conformance leaf closes. Other
backends should continue using their existing descriptor APIs described in
[Descriptor Introspection](descriptor-introspection.md) until their native semantic adapter lands.

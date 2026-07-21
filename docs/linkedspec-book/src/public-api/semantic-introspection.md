# Semantic Introspection

LinkedSpec now has an executable, backend-neutral contract for deep semantic introspection. Perl has the first
admitted native query surface: opaque construction, exact static plus call/staged/generated projections, public
`capabilities`/`query` answers, optional caller-captured runtime observations, and one exact composed conformance
consumer. Rust now has two private implementation layers: an opaque strict-source, exact-coordinate,
compiled-or-failed foundation and an exact clone-safe static v1 projection, without public query or admission yet.
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
  static projection needed by later calls/query leaves; and
- the current `return_descriptor` / descriptor APIs remain a separate lower-level compatibility surface.

The neutral contract is complete. Backend admission is **1 complete / 5 pending**: Perl is admitted; Rust, Dart,
Julia, PUC Lua, and LuaJIT remain pending. MCP remains later transport work and does not own semantics.

## Current Rust construction foundation

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
action code. It does not capture runtime observations or enable trace. The opaque index now retains exact private
static v1 records/relations plus normalized failure evidence, but exposes no public record or query method yet.
Calls/staging, query, runtime observation, and admission remain later Rust leaves. Therefore the global rollout and
native-admission ledgers remain 2/9 and 1/6.

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

Each backend's focused projection test materializes internal source keys and deep-compares the complete graph,
Unicode privacy at both construction ceilings, and failed snapshots, plus the runtime fixture's complete static
half, against the neutral oracle. Perl's public evaluator owns query-time source redaction, pages, traversal,
budgets, and costs today; Rust's equivalent remains `.10.4.4`. The composed Perl admission consumer is described
with the executable oracle below; Rust calls/staging projection is the next dependency.

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

The private Perl projection now matches all 22 neutral records and 25 relations for this source. Definition order
is `function:normalize`, `rule:Top`, `rule:Done`. Typed ActionIR traversal records `trim` in the function body,
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

The separate generated artifact reports `linkedspec-generated-source-v2`, format 2, family `default`. Compiler
and semantic projector call the same `LinkedSpec::GeneratedSource` identity and handler-family owners, so the
semantic layer neither duplicates the family classifier nor generates implementation text.

Source coordinates have an important split. Function registry `source_span`/`body_span` fields and typed ActionIR
local spans count decoded characters. Only the final source-reference boundary converts them to strict UTF-8 byte
offsets and one-based Unicode-scalar columns. A focused `# préface` case locks exact call excerpts and columns so
ASCII cannot hide byte/character confusion. The original-source rule scanner also masks descriptor-owned top-level
function ranges while preserving newlines, matching the compiler's function-blanked rule input; an interleaved
function therefore cannot become a synthetic bare edge.

These projection mechanics remain internal implementation evidence, while their normalized records are now
callable through the public query surface. Returned answers contain only canonical JSON data and booleans: no
descriptor coderef/compiled regex, raw function record, ActionIR layout, generated source, object identity, or
path. Runtime observation/routes are implemented by `.10.3.5`; composed admission closes through `.10.3.6`.

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
static half. Public capabilities/query remain absent.

Direct and generated Rust executors already have parallel authoritative slot-selection and rule-result seams. They
currently emit textual trace decisions only; no typed semantic observer or query object exists. The planned runtime
leaf adds a separate optional invocation-local sink at those seams and derives a new immutable post-execution index.
It must not parse trace text, alter diagnostic output, or let queries execute.

The prerequisite is resolved by ADR `0051` and task `.10.4.0.2`: the published/Rust rule-label contract is a
nonempty sequence of pinned Unicode 17.0.0 `XID_Continue` scalars at every position. Identity is exact,
case-sensitive, and normalization-sensitive; no normalization or folding occurs. Rust now parses and validates
the admitted `Töp` fixture label across source, references, selectors, compiled/descriptor/generated identity,
strict loaders, and traces. Positive, negative, decomposed, and case-distinct route proofs prevent parser/book
drift. This removed the blocker for completed Rust semantic construction `.10.4.1` without admitting the Rust
semantic API. The later Dart/Julia/Lua semantic backend lanes inherit the pinned-label prerequisite before
their own v1 fixture admission. Toolbox repair `.10.4.0.1` has aligned the semantic diagnostic entry with the
executable 6/20/65, rollout 2+7, admission 1+5, and complete Perl observation/admission state. The checker now
requires those high-value claims exactly once, denies their stale forms, and runs omission plus wrong-value guard
probes without changing the neutral response digests or 65 contract-mutation inventory.

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

The base Perl index reports `has_execution` and `execution_observation` as false. A derived index reports both as
true and adds `execution:0`, two exact slot events, one final rule-result event, and their `observed_as` relations
for the canonical `Top::OR{2}` / `ab\n` fixture. All 20 canonical answers are available through the native API.
Direct parsers, loaded specs, portable loader results, captured generated source, independently loaded generated
`Execute`/`Get`/`ExecuteWithTrace`, and validated reconstructed plans produce the same observation and response.

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
SHA-256 digest, and reports 65 rejected mutations. The cases cover graph/slot/lifecycle meaning, calls and shapes,
staged and generated provenance, explanations, failed compilation, caller-captured runtime events, reverse
relations, page cursors and boundaries, record/relation/depth budgets, all source policies, a lowered ceiling, an
unsupported contract, and an invalid operation combination.

The checker runs unconditionally in canonical local CI. It admits only an owned backend whose exact consumer,
ordered roles, tracked path, canonical driver, native status, and rollout row all agree; every later backend still
fails if promoted early. It also reads `TOOLBOX.md` and locks the exact command output, Perl runtime test, and
12-role composed-admission claims. Internal omission and wrong-value probes prove that documentation guard rather
than inflating the separately governed 65 semantic-contract mutations.

Perl's native evaluator has a separate exact gate:

```bash
PERL5LIB= prove -Iperl t/semantic_index_perl_query.t
```

It reconstructs the five static source/ceiling inputs through the public constructor, executes the 19 non-runtime
canonical requests, and compares every full response digest. Additional cases lock request validation, source
privacy, clone isolation, silence, path/host-layout denial, and successful query evaluation while the compilation
entrypoint is disabled.

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
| `.10.4` | Rust parity | source/outcome and static projection complete; calls/query/runtime/admission pending |
| `.10.5` | Dart parity | pending |
| `.10.6` | Julia parity | pending |
| `.10.7` | PUC Lua and LuaJIT identity | pending |
| `.10.8` | recurring six-runtime proof | pending |
| `.10.9` | thin MCP transport | pending |
| `.10.10` | public no-drift and closure | pending |

The future MCP server has only capabilities and query tools over a caller-registered opaque native handle. It
cannot compile, read a path, traverse backend objects, cache a second semantic model, invent explanations, or
raise source/budget ceilings. Direct native and MCP responses must be identical after canonical JSON encoding.

Perl callers can use the admitted native static and caller-captured runtime query surface now. No later backend may
claim semantic-introspection admission until its composed conformance leaf closes. Other
backends should continue using their existing descriptor APIs described in
[Descriptor Introspection](descriptor-introspection.md) until their native semantic adapter lands.

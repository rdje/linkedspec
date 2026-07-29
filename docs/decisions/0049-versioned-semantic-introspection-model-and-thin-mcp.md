# 0049 - Semantic introspection uses one versioned native model and a thin MCP transport

- Date: 2026-07-20
- Status: accepted; native six-runtime rollout admitted; amended/clarified by ADRs 0050/0054/0055
- Tags: architecture, introspection, semantic-api, mcp, provenance, diagnostics, explainability, portability, parity

## Context

LinkedSpec already retains most of the facts needed by semantic tools, but they currently live at several
different owner boundaries. The outward descriptor exposes the stable four-key `spec`, `functions`,
`dependency_regex_map`, and `meta` projection. Typed compiled state retains normalized rules, regex slots, edges,
lifecycle payloads, ActionIR, function registrations, and source order. Structured diagnostics and trace retain
compile/runtime observations. Generated-source v2 retains a validated ordered `{label, family}` plan and synthetic
source relationships.

Those are useful inputs, but none is the semantic introspection wire model. A toolbox probe against the Perl
reference proved the most concrete boundary: `return_descriptor` is a pure projection, yet its handler and
dependency-regex values are native coderef and compiled-regex objects. Serializing that hash directly as portable
JSON fails. The other backends deliberately use their own typed descriptor representations. Widening the descriptor
until it contains every AST, trace, diagnostic, and generated-source detail would therefore leak host layouts and
couple compatibility data to a new query product.

The design inventory found equivalent reusable authorities, not one reusable serialized layout:

| Backend | Reusable current authorities | Normalization gap owned by later leaves |
|---|---|---|
| Perl | `CompilerState`, outward descriptor projection, `RuleIR`/typed `ActionIR`, function/staged registry, structured runtime context/diagnostics, trace, and generated handler metadata | native coderef/compiled-regex values; compiler/source/action records are distributed across owners |
| Rust | typed `CompiledSpec`/`CompiledRule`, `descriptor.rs`, `Expr`, portable diagnostics, native trace, runtime engine, and generated plan/source records | no semantic index, call graph, inferred-shape graph, evidence chain, or source-policy projection |
| Dart | `CompiledSpec`/`descriptorState`, typed action AST/contracts/function registry, portable diagnostics, trace, and source emitter | native JSON methods expose compiler structures, not versioned semantic records/relations |
| Julia | `CompiledSpec`/`descriptor_state`, typed Action AST/contracts/function registry, portable diagnostics, trace, and generated plan/source records | dictionaries/type projections still need the same neutral ids, facts, ordering, redaction, and evidence |
| Lua/LuaJIT | compiled-spec/descriptor methods, action AST/contracts/function registry, typed runtime diagnostics, trace, and generated plan/source objects | tables/metatables/object identity must be projected identically on both ABIs without becoming schema |

Across all five, current state already answers definition and compiled order, rule family/cursor/repetition,
structural regex-slot identity, normalized edge ownership/targets, lifecycle payload ownership, staged function
body provenance, callable signatures, generated plan identity, and many portable diagnostics. No current owner
assembles reverse graph relations, stable semantic ids, cross-owner call resolution, value/target shape inference,
bounded pagination, structural source redaction, or portable explanation evidence. Those are new model work, not
reasons to duplicate parsing or runtime semantics.

Users instead need stable answers to questions such as:

- What rules and symbols exist, which rule is entered first, and why?
- Which authored regex slot or child rule does an edge select, and who owns dispatch?
- Which lifecycle action can replace a repeated rule's default result?
- Does a call resolve to a helper, user function, codeblock, rule, or unresolved target?
- What value or target shape is known at a call, return, binding, or edge?
- Which source slice produced a normalized record, and how did it relate to staged or generated source?
- Which portable diagnostic explains a compile/runtime decision, and what ordered evidence led to it?

The answers must be equivalent across Perl, Rust, Dart, Julia, Lua, LuaJIT, and later backends. ADR `0022` makes
native in-memory embedding primary; ADR `0023` requires user-observable parity; ADR `0037` keeps rich selective
observability as a related but distinct event stream.

## Decision

### 1. One neutral semantic model owns the answers

Adopt `linkedspec-semantic-model-v1` as the backend-neutral model and
`linkedspec-semantic-query-v1` as its query protocol. Every backend builds an immutable `SemanticIndex` from the
same logical authorities:

1. normalized compiled spec/rule/function state;
2. typed ActionIR and its contract-resolution results;
3. source and staged-provenance records;
4. generated artifact/plan relationships;
5. portable compile diagnostics; and
6. an optional caller-owned execution observation captured by normal parsing.

Building or querying an index is read-only. It must not execute a parser, evaluate user code, mutate compiled
state, load undeclared files, or enable tracing. Runtime questions require an already captured immutable execution
observation; a query never creates one implicitly. A failed compilation may be wrapped as a diagnostic-only
semantic snapshot so its portable diagnostics and available source evidence remain queryable.

The existing outward descriptor remains its own compatibility contract. It is an input authority where useful,
not the semantic schema and not the MCP payload. Backend AST/IR type names, object identities, callable values,
compiled regex objects, memory addresses, host exceptions, and generated implementation source are forbidden from
portable semantic records.

### 2. Stable identity is deterministic within one immutable snapshot

An index has snapshot id `snapshot:0`. Public ids are reproducible across backends for the same neutral input and
remain stable for the lifetime of that immutable snapshot; v1 does not promise that ids survive source edits.
Callers needing a durable project identity keep it outside this model.

Names in ids use their strict UTF-8 bytes. Bytes outside `[A-Za-z0-9._~-]` are percent-escaped as uppercase
`%HH`. The required id families are:

| Kind | Required id form |
|---|---|
| spec/source | `spec:0`, `source:<source-order>` |
| rule | `rule:<escaped-label>` |
| regex slot | `regex:<rule-id>:<zero-based-authored-slot>` |
| edge | `edge:<rule-id>:<zero-based-normalized-source-order>` |
| lifecycle | `lifecycle:<rule-id>:<marker>:<zero-based-marker-order>` |
| function/helper | `function:<escaped-name>`, `helper:<escaped-canonical-name>` |
| binding/call | `binding:<owner-id>:<escaped-name>:<preorder>`, `call:<owner-id>:<preorder>` |
| capabilities/generated artifact | `capabilities:0`, `generated:<artifact-kind>:<source-order>` |
| diagnostic/decision | `diagnostic:<phase>:<order>`, `decision:<kind>:<subject-id>` |
| explanation/relation | `explanation:<decision-id>:<order>`, `relation:<kind>:<from-id>:<to-id>:<order>` |
| execution/event | `execution:<order>`, `event:<execution-id>:<order>` |

Source order means the declared spec-graph order from the owning compiled snapshot, never host map iteration.
Within one query, records sort by the model's fixed kind rank, then source order, then id. Relations sort by source
record order, fixed relation-kind rank, target order, then relation id. Diagnostics and explanation evidence stay
in causal order. Object-key order is not semantic; arrays are always order-sensitive.

### 3. Records and relations are normalized facts, not serialized IR

Every semantic record has exactly `id`, `kind`, `name`, `owner_id`, `order`, `source`, `facts`, and `redactions`.
Every relation has exactly `id`, `kind`, `from_id`, `to_id`, `order`, `source`, `facts`, and `evidence_ids`.
Nullable fields are present as null rather than disappearing. `facts` is controlled by the model version; a
backend-specific fact is not permitted in a portable response. A source-sensitive fact key also remains present
with null when redacted; its JSON-pointer-like fact path appears in `redactions`.

The v1 record vocabulary is `capabilities`, `spec`, `source`, `rule`, `regex_slot`, `edge`, `lifecycle`,
`function`, `helper`, `binding`, `call`, `generated_artifact`, `diagnostic`, `decision`, `execution`, `event`, and
`explanation_step`. Required relation kinds are `declares`, `contains`, `depends_on`, `dispatches_to`,
`selects_regex`, `calls`, `resolves_to`, `reads`, `writes`, `lowered_from`, `staged_by`, `generated_as`,
`diagnoses`, `observed_as`, and `explained_by`. The listed order is the fixed kind rank for each vocabulary.

The versioned fact vocabulary covers:

- rule family, entry-marker identity and selection basis, cursor policy, repetition bounds, edge ownership, and
  default result shape;
- exact authored regex-slot order, pattern/flags when source policy permits, combined-regex participation, and
  zero-based slot identity independent of pattern equality;
- normalized action/blind edge ownership, target rule and slot, authored versus normalized form, attached block,
  fluent calls, and result target;
- lifecycle marker, order, scope, and whole-rule-return authority;
- helper and function signatures, arity/rest/final-codeblock policy, effects, return shape, call resolution, and
  resolution precedence;
- staged payload/job/result provenance plus generated format, plan row, compiled-state, and emitted-artifact
  relationships;
- portable diagnostic code/stage/severity/message/fields; and
- compile/runtime decisions with an ordered evidence chain whose steps state the portable rule applied, input ids,
  and resulting fact.

The executable schema leaf must freeze the nested value objects and cannot add, rename, or omit these exact v1
top-level fact keys:

| Record kind | Required fact keys |
|---|---|
| `capabilities` | `model_ids`, `query_ids`, `record_kinds`, `relation_kinds`, `source_detail_ceiling`, `page_default`, `page_max`, `budget_defaults`, `budget_maxima`, `execution_observation`, `features` |
| `spec` | `definition_order`, `compiled_rule_order`, `entry_rule_id`, `entry_selection_basis` |
| `source` | `logical_kind`, `origin_kind` |
| `rule` | `family`, `cursor_policy`, `is_entry_marker`, `is_repetition`, `rep_min`, `rep_max`, `edge_ownership`, `value_shape` |
| `regex_slot` | `authored_index`, `pattern`, `flags`, `combined_owner_ids`, `target_shape` |
| `edge` | `ownership`, `source_form`, `has_block`, `fluent_call_ids`, `value_shape`, `target_shape` |
| `lifecycle` | `marker`, `whole_rule_return`, `value_shape` |
| `function` | `signature`, `parameter_kinds`, `return_shape` |
| `helper` | `signature`, `effects`, `return_shape` |
| `binding` | `scope`, `value_shape`, `mutable` |
| `call` | `call_form`, `resolution_kind`, `argument_shapes`, `return_shape`, `target_shape` |
| `generated_artifact` | `artifact_kind`, `contract_id`, `format_version`, `plan_family` |
| `diagnostic` | `code`, `stage`, `severity`, `message`, `fields` |
| `decision` | `decision_kind`, `outcome` |
| `execution` | `input_identity`, `status`, `result_shape` |
| `event` | `event_kind`, `position`, `value_shape` |
| `explanation_step` | `rule_code`, `summary`, `input_ids`, `output_fact` |

Value shapes use the closed v1 kinds `unknown`, `null`, `boolean`, `number`, `string`, `array`, `harray`,
`codeblock`, and `union`. Array element, harray key/value, and codeblock signature shapes recurse through the same
schema. Every shape object has exactly `kind`, `element`, `key`, `value`, `signature`, and `members`; inapplicable
members are null or an empty array. Union members sort by that kind order and are deduplicated. Target shapes use
`unknown`, `rule`, `regex_slot`, `binding`, `helper`, `user_function`, `codeblock`, `generated_artifact`, and
`diagnostic`. Unknown stays explicit;
a backend may not guess a more specific shape from host runtime types.

### 4. The query and result envelopes are exact

A query object has exactly these keys:

```json
{
  "contract": "linkedspec-semantic-query-v1",
  "operation": "list",
  "subjects": [],
  "record_kinds": ["rule"],
  "relation_kinds": [],
  "direction": "outgoing",
  "page": {"after_id": null, "limit": 100},
  "budget": {"max_records": 1000, "max_relations": 2000, "max_depth": 4},
  "source": {"detail": "identity", "include_content_digest": false}
}
```

The operations are `capabilities`, `list`, `get`, `relations`, and `explain`. Operation-specific unused arrays
remain empty so fixtures and transports have one shape. `direction` is `outgoing`, `incoming`, or `both`.
`after_id` is the last returned canonical id, not an implementation cursor. Default/max page limits are 100/1000;
default/max relation depth is 4/8. Server or embedding policy may lower those maxima but must report the effective
capability before querying.

Operation rules are exact: `capabilities` and `list` require empty `subjects`; `get` requires record ids;
`relations` requires subject ids and may filter relation kinds/direction; `explain` requires one decision or
semantic subject id. `list`, `get`, and `capabilities` return records with an empty relation array. `relations`
returns relations with an empty record array. `explain` returns the decision and ordered `explanation_step` records
plus only their `explained_by` relations. Page state applies to that operation's primary record, relation, or
explanation-step stream; no hidden endpoint record consumes a page slot.

A response has exactly `contract`, `model`, `ok`, `snapshot`, `records`, `relations`, `page`, `cost`, and
`diagnostics`. Snapshot has exactly `id`, `state`, `has_execution`, `source_detail_ceiling`, and
`content_digest_available`; state is `compiled` or `failed_compilation`. Page state has `after_id`,
`next_after_id`, and `complete`. Cost has `records_examined`,
`relations_examined`, and `depth_reached`; these count canonical model traversal, not CPU, allocations, or
backend-private work. Reaching a budget returns the deterministic prefix with `complete = false` and portable
diagnostic `semantic_query_budget_exceeded`. Invalid ids, filters, source requests, or operation combinations use
`semantic_query_invalid`; a request above the source ceiling uses `semantic_query_source_detail_forbidden` without
silent downgrade; unsupported model versions use `semantic_query_contract_unsupported`. These response
diagnostics have exactly `code`, `severity`, `message`, and `fields` and describe the query itself. Compilation and
runtime diagnostics are source-aware `diagnostic` records returned through `records`, so the two roles do not
silently overlap.

The `capabilities` operation returns exactly one `capabilities:0` record. Its facts report supported model/query
ids, record/relation kinds, source ceiling, effective defaults/maxima,
execution-observation availability, and optional feature ids. Adding or changing a required field, fact, relation,
ordering rule, or meaning requires a new model/query id. `features` is an empty array in v1; extensions require a
new negotiated model/query contract rather than a silent backend-only field or kind.

### 5. Source and privacy controls are structural

Every native index has a caller-selected source-detail ceiling. Every query selects one of `none`, `identity`,
`span`, or `text`, and cannot elevate above that ceiling:

- `none` returns null source refs and redacts source-derived text;
- `identity` returns only neutral `source:<order>` ids and caller-registered logical names, never an implicit host
  path;
- `span` adds zero-based, half-open strict-UTF-8 byte offsets plus one-based line and Unicode-scalar columns; and
- `text` may add exact source excerpts and regex/action text.

A non-null source reference has exactly `source_id`, `logical_name`, `span`, `excerpt`, `content_digest`, and
`provenance_ids`. A span has exactly `start_byte`, `end_byte`, `start_line`, `start_column`, `end_line`, and
`end_column`. Unavailable fields remain null. When enabled, the digest is `sha256:` plus 64 lowercase hexadecimal
digits over the exact strict-UTF-8 source bytes.

`include_content_digest` is separately ceiling-controlled and defaults false. Redacted fact paths are listed in
the record's ordered `redactions` array; values are not replaced with misleading empty strings. An MCP request,
URI, source label, diagnostic message, or generated source must not reveal a filesystem path that the caller did
not register as a logical public identity. Limits and source ceilings are applied before semantic records leave
the native API.

### 6. Host APIs are idiomatic projections of the same operations

The exact host spelling may be idiomatic, but construction, capabilities, query inputs, normalized answers,
errors, ordering, and privacy are equivalent:

| Backend | Planned native surface |
|---|---|
| Perl | `LinkedSpec::semantic_index(...)`; `$index->capabilities`; `$index->query($query)` |
| Rust | `SemanticIndex::from_source(...)` / `from_utf8(...)`; later `index.capabilities()` and `index.query(&SemanticQuery)` |
| Dart | `SemanticIndex.fromCompiledSpec(...)`; `index.capabilities`; `index.query(query)` |
| Julia | `semantic_index(...)`; `semantic_capabilities(index)`; `semantic_query(index, query)` |
| Lua | `linkedspec.semantic_index(...)`; `index:capabilities()`; `index:query(query)` |

Each backend may also accept its idiomatic compilation-outcome and execution-observation types. The neutral
request/response projection is available in every backend for parity and transport use. No implementation must
deserialize another backend's AST/IR or accept the outward descriptor as a reconstruction format.

The canonical primary CLI gains no introspection option or command in v1. A later developer CLI may read/write the
same neutral query JSON by calling the native API, but cannot own a query, fact, limit, or diagnostic unavailable
in-process.

### 7. MCP is a handle-and-query adapter only

The thin MCP server exposes two tools:

- `linkedspec_semantic_capabilities(handle)` calls the registered native index's capabilities operation;
- `linkedspec_semantic_query(handle, request)` calls that index's query operation and returns the exact neutral
  response.

An embedding registers an opaque handle for an already created index or snapshot. Registration, authorization,
handle expiry, and unavailable-handle tool execution errors are transport/deployment concerns. The MCP server does not read
an implicit path, compile source, traverse backend objects, reinterpret records, invent explanations, increase a
source ceiling, or maintain its own semantic cache. Its contract tests compare direct native and MCP response
bytes after canonical JSON encoding.

### 8. Exact conformance precedes backend and transport rollout

The executable contract leaf must freeze six neutral fixture groups before an adapter lands:

1. rule/regex/edge/lifecycle graphs, including duplicate patterns, root selection, repetition, and action/blind
   ownership;
2. helper, user-function, codeblock, binding, call-resolution, and value/target-shape facts;
3. staged payload/job/source provenance and generated-source-v2 plan/artifact relations;
4. successful and failed compilation diagnostics plus explain-why chains for entry, cursor, edge, slot, and call
   decisions;
5. caller-captured runtime selection, iteration, lifecycle, diagnostic, and result observations; and
6. every source policy, redaction, page boundary, reverse relation, budget cutoff, invalid request, and contract
   mismatch.

Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT must emit deep-equal normalized JSON for every shared query. Exact
record/relation array order is significant; JSON object order is not. The checker rejects omitted records,
relations, evidence, redactions, backends, runtime routes, and MCP/direct comparisons. Mutation cases remove or
rename facts, reorder arrays, alter ids, exceed limits, leak a host path/type/object, strengthen an inferred shape,
change an explanation, or move semantics into MCP.

Implementation is split in dependency order under `FUTURE-PARITY-BACKLOG.10`:

- `.10.2` neutral executable schema, fixtures, expected answers, and omission/mutation checker;
- `.10.3` Perl semantic model/native reference adapter, split after the authority audit into strict source/outcome,
  static graph/diagnostic, call/staged provenance, query/privacy/budget, runtime/routes, and exact admission leaves;
- `.10.4` Rust adapter;
- `.10.5` Dart adapter;
- `.10.6` Julia adapter;
- `.10.7` Lua adapter and exact PUC Lua/LuaJIT identity;
- `.10.8` recurring six-runtime native/generated/diagnostic/execution admission;
- `.10.9` thin MCP handle/capabilities/query transport and direct-response identity; and
- `.10.10` public API/mdBook/backend-companion no-drift and parent closure.

## Consequences

- Tooling can ask graph, resolution, provenance, diagnostic, and explainability questions without learning a
  backend's compiler data structures.
- The outward descriptor stays small enough to remain a stable compatibility projection; semantic introspection
  can evolve through its own explicit version boundary.
- Exact ids, traversal counts, redactions, and explanation steps make parity testable rather than aspirational.
- Runtime introspection remains opt-in and non-interfering because queries consume caller-owned observations after
  execution.
- MCP becomes broadly useful without becoming a sixth semantic implementation or a hidden filesystem/CLI bridge.
- Each rollout leaf must keep implemented native layers distinct from still-planned transport/public layers.
  Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT plus recurring native proof are admitted; MCP machine artifacts/
  implementations and final public no-drift remain staged.

The behavior-free Perl audit in `.10.3.0` fixes the first adapter boundary. `LinkedSpec::Get` consumes decoded
characters internally; a constructor may accept decoded text or strict UTF-8 bytes, but must normalize both to one
decoded source and retain canonical bytes for byte spans/digests. The descriptor, typed ActionIR, staged function
records, structured runtime-context failures, and generated-v2 plan metadata are separate reusable authorities.
Generated metadata cannot reconstruct a semantic snapshot, rule/edge/lifecycle coordinates need a source mapper,
and optional execution observations require an invocation-local typed sink separate from textual trace.

Perl leaf `.10.3.1` implements only that constructor foundation. `LinkedSpec::semantic_index(...)` copies decoded
text or strict UTF-8 bytes, accepts caller logical identity/source ceiling with no path, precomputes exact
byte/Unicode-scalar coordinates, compiles once through the existing descriptor/runtime-context path without
execution, and retains an opaque immutable compiled-or-failed outcome. It deliberately has no public
`capabilities` or `query` methods yet; `.10.3.2-.10.3.6` retain projection, evaluation, observation, and admission.

Before static Perl projection, `.10.3.2.0` found that the executable model and response hashes were mutually
consistent but contradicted ADR `0044` and the live descriptor for bare/default rule headers. The corrected
neutral rule vocabulary maps descriptor `or_default`/`seek` to `or`/`seek`; a compiled rule with no normalized
edges reports `none`; and the failed default-family bare-edge fixture retains family-derived `action` alongside
its diagnostic. The semantic checker now consumes `linkedspec-rule-local-cursor-v1` as an independent authority
for header family/cursor, repetition, entry-marker, and ownership facts. Coordinated wrong-model plus refreshed-
hash mutations are rejected. This is an oracle correction only: it changes no parser, compiler, runtime,
descriptor, generated artifact, CLI, trace, backend admission, or MCP behavior.

Perl leaf `.10.3.2.1` consumes that corrected boundary without turning the outward descriptor into the model. A
private immutable projector combines descriptor rule/edge authority, accepted decoded source/source-map ranges,
selected entry identity, and structured failed-compilation context. Its spec/source/rule/regex-slot/edge/lifecycle/
diagnostic/decision/explanation records and relations deep-equal the graph, privacy full/limited, failed, and
runtime-static neutral targets after internal source keys are materialized. Duplicate patterns retain authored slot
ids, self-indexed edges select their slot without redundant self-dispatch, and only JSON booleans plus plain data
cross the clone boundary. Public query/capability behavior, ActionIR calls/staging, observations, and admission are
still absent, so rollout and backend admission do not advance.

Before calls/staging projection, `.10.3.3.0` found the same class of independent-authority gap on the generated
artifact. The calls model said handler family `and_acode`; exact descriptor selection was `_default`, independently
loaded generated-source-v2 metadata reported `default`, and `and_acode` was absent from the ten-family v2
vocabulary. The model now says `default`. The checker consumes the admitted contract's generated-source-v2
identity/format/family inventory and exact default header, rejecting both the old illegal family and a coordinated
valid-but-wrong family with refreshed query hashes. This also changes no behavior, query digest, rollout, or
admission; `.10.3.3.1` consumes the corrected calls/staging target.

Full calls RED then found a separate identity shortcut before projection code: every neutral spec name should be
the `.spec`-stripped caller logical identity, yet the calls row alone used snapshot id `calls` instead of
`calls_and_staging`. Correction `.10.3.3.1.0` derives every spec name from `source_fixtures.logical_name` and
rejects direct or coordinated old-name drift. It changes no response digest, path policy, behavior, rollout, or
admission; projector child `.10.3.3.1.1` consumes the fully corrected target.

Perl child `.10.3.3.1.1` now implements that private compiled layer. Descriptor function order/signatures,
source-preorder typed ActionIR, staged function sidecars, and generated-source-v2 identity compose all corrected
22 records and 25 relations without serializing the descriptor, AST, or generated implementation. Function and
ActionIR source spans are character coordinates until the final source-map projection; a multibyte-prefix lock
prevents ASCII-only byte/character aliasing. The original source scanner masks descriptor-owned top-level function
ranges before rule-member classification, matching the compiler's function-blanked input. Compiler and projector
delegate handler-family and artifact-identity facts to shared `LinkedSpec::GeneratedSource` owners. At that leaf,
this added no public query, observation, rollout, or admission; `.10.3.4-.10.3.6` retained those boundaries.

Perl leaf `.10.3.4` adds the first public native query boundary without widening the model. `$index->capabilities`
is the canonical capabilities operation, and `$index->query($request)` evaluates the exact v1 envelope over a
cloned private plain-data projection. Capabilities/list/get/relations/explain, structural source redaction and
ceilings, after-id pages, filtered directional breadth-first traversal, logical record/relation/depth budgets and
costs, explanations, and portable response diagnostics match all 19 static canonical response digests. Querying
does not compile, execute, read a path, enable trace, expose host state, or retain caller mutations. The twentieth
`runtime_events` response, route equivalence, composed Perl admission, other backends, and MCP remain later leaves;
rollout/admission therefore remain 1/9 and 0/6.

Perl leaf `.10.3.5` adds the optional execution authority without changing that model. Normal parser invocation may
receive a `semantic_observation_sink` callback. `LinkedSpec::RuntimeSemanticObservation` delivers typed
`regex_slot_selected` events from the same exact target/index/position seam as selected-slot trace and one final
`rule_result` event from the invocation wrapper. It has distinct descriptor slots and control-error identity from
both textual trace and diagnostic output. The caller then passes the completed event array to
`$index->with_execution_observation(...)`, which returns a new immutable index and never executes. The base index
remains static. Direct, loaded, captured/emitted generated direct/Get/traced, and validated-plan routes produce the
same three-event canonical runtime snapshot and twentieth response digest. At the `.10.3.5` boundary, Perl
admission still belonged to `.10.3.6`, so rollout/admission were intentionally unchanged at 1/9 and 0/6.

Perl leaf `.10.3.6` composes the complete native surface without adding another semantic owner. One contract-
declared 12-role consumer covers strict source normalization, compiled/failed/runtime snapshots, direct/loaded/
generated/traced observations, native and neutral JSON, all 20 exact query digests, privacy/pages/budgets/errors/
explain, non-interference, immutability, and stale host-leak denial. The neutral checker locks the consumer path,
ordered roles, canonical driver/registration, and Perl-only admission/rollout promotion with eight additional
mutations, for 65 total. Perl advances rollout to 2/9 and native admission to 1/6; Rust, Dart, Julia, PUC Lua,
LuaJIT, recurring proof, MCP, and public no-drift remain owned by `.10.4-.10.10`.

Rust leaf `.10.4.1` implements its first native layer without claiming the model response surface. Opaque
`SemanticIndex::from_source` / `from_utf8` constructors copy accepted decoded text and canonical strict-UTF-8
bytes, build exact byte/line/Unicode-scalar mapping, enforce one immutable source-detail ceiling, and retain
private parsed/validated/compiled-or-failed state. Successful state also retains effective entry identity and the
shared generated-source-v2 plan; language failures retain raw portable diagnostics. Returned foundation values
are owned clones and cannot expose source, map, AST, `CompiledSpec`, or another host object. Construction never
invokes the resulting target parser or target code. Static records and normalized diagnostics remain `.10.4.2`,
so rollout/admission remain 2/9 and 1/6.

Rust leaves `.10.4.2-.10.4.3` privately compose accepted source with typed compiled graph, diagnostic, ActionIR,
function-staged, and shared generated-plan owners. Rust leaf `.10.4.4` then exposes
`SemanticIndex::capabilities()`, typed `query(&SemanticQuery)`, and a raw-neutral validation seam. Both public paths
enter one evaluator over a fresh clone of the normalized projection and match all 19 static canonical response
digests. The evaluator owns only selection, source redaction/ceilings, canonical pages, filtered directional BFS,
logical budgets/costs, explanations, and portable request diagnostics; it has no compiler, executor, trace, path,
host IR, or generated source. Runtime observation `.10.4.5` and composed admission `.10.4.6` subsequently complete
the Rust surface. One exact 12-role consumer covers all 20 digests and governed execution/query routes; eight
topology mutations plus canonical registration advance only Rust to rollout 3/9 and admission 2/6. See
[[rust-semantic-query-evaluator]].

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10-.10.10`)
- Prior direction: `docs/knowledge/semantic-introspection-api-mcp-direction.md`
- Native embedding and parity: ADR `0022`, ADR `0023`
- Selective trace/observation direction: ADR `0037`
- Staged provenance: ADRs `0012`-`0016`
- Current outward descriptor contract: `capability_conformance/outward_descriptor_contract.json`
- Staged-artifact schema correction: ADR `0050`
- Native per-backend MCP server topology: ADR `0054`
- Modern MCP protocol/stdio policy: ADR `0055`

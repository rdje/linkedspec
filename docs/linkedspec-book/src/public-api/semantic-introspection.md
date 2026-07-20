# Semantic Introspection

LinkedSpec now has an executable, backend-neutral contract for deep semantic introspection. It does **not** yet
have a public native semantic-index implementation. The distinction matters:

- `linkedspec-semantic-model-v1` fixes what every backend must mean;
- `linkedspec-semantic-query-v1` fixes how callers ask and how answers are bounded;
- the neutral checker derives and digest-locks exact answers without admitting a backend early; and
- the current `return_descriptor` / descriptor APIs remain the available introspection surface until the rollout
  leaves implement the new native APIs.

The neutral contract is complete. Backend admission is **0 complete / 6 pending** for Perl, Rust, Dart, Julia,
PUC Lua, and LuaJIT. MCP remains later transport work and does not own semantics.

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
| decoded source plus canonical UTF-8 bytes | exact accepted text | source coordinates, excerpts, digests, logical-name-only identity |
| outward descriptor | deterministic rule/function order, family/cursor/repetition/entry, edges, slots, staged function records | removal of coderef/compiled-regex host values; normalized records and relations |
| typed ActionIR AST | source-preorder calls, bindings, and nested spans | registry resolution, portable shapes, evidence |
| runtime context | structured compilation failure | v1 diagnostic code/stage/message/field normalization |
| generated-source v2 metadata | contract/format, source identity, ordered family plan, entries | separate generated-artifact relation; never snapshot reconstruction |
| runtime handlers | exact accepted slot and final-result seams | a new invocation-local typed observation sink separate from trace |

`LinkedSpec::Get` is character-oriented internally. Direct raw UTF-8 bytes for the privacy fixture's `Töp::`
label fail validation, while strict UTF-8 decoding first compiles the exact label and Unicode regex. Existing file
loaders already use strict decoding. The future semantic constructor must accept decoded text or strict UTF-8
bytes, reject malformed input, preserve canonical bytes for byte offsets and digests, and accept only a
caller-registered logical name—never an implicit host path.

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

## Runtime observations do not execute parsers

A semantic query is read-only. It cannot compile a spec, evaluate an action, run a parser, load an undeclared
file, or enable tracing. Runtime records appear only when the caller gives the index an already captured immutable
execution observation. A failed compilation may still produce a diagnostic-only semantic snapshot.

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
SHA-256 digest, and reports 50 rejected mutations. The cases cover graph/slot/lifecycle meaning, calls and shapes,
staged and generated provenance, explanations, failed compilation, caller-captured runtime events, reverse
relations, page cursors and boundaries, record/relation/depth budgets, all source policies, a lowered ceiling, an
unsupported contract, and an invalid operation combination.

The checker runs unconditionally in canonical local CI. This is contract evidence only: it deliberately rejects
premature backend admission.

## Rollout and MCP boundary

The dependency order is:

| Owner | Work | Current state |
|---|---|---|
| `.10.2` | neutral contract, fixtures, exact oracle | complete |
| `.10.3.0` | Perl authority map and safe implementation split | complete |
| `.10.3.1-.10.3.6` | Perl source/outcome, static graph, calls/staging, query, runtime/routes, admission | pending |
| `.10.4` | Rust parity | pending |
| `.10.5` | Dart parity | pending |
| `.10.6` | Julia parity | pending |
| `.10.7` | PUC Lua and LuaJIT identity | pending |
| `.10.8` | recurring six-runtime proof | pending |
| `.10.9` | thin MCP transport | pending |
| `.10.10` | public no-drift and closure | pending |

The future MCP server has only capabilities and query tools over a caller-registered opaque native handle. It
cannot compile, read a path, traverse backend objects, cache a second semantic model, invent explanations, or
raise source/budget ceilings. Direct native and MCP responses must be identical after canonical JSON encoding.

Until the native rollout reaches the relevant backend, use the existing descriptor APIs described in
[Descriptor Introspection](descriptor-introspection.md).

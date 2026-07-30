# Semantic Introspection

LinkedSpec now has an executable, backend-neutral contract for deep semantic introspection. Perl, Rust, Dart,
Julia, PUC Lua, and LuaJIT have admitted native query surfaces: opaque construction, exact static plus
call/staged/generated projections, public
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
- Julia `semantic_capabilities`, `semantic_query`, and `semantic_query_neutral` expose the same immutable answers;
  typed caller observations derive the exact runtime snapshot across native, generated, and emitted routes; and
- `semantic_introspection_julia_admission_test.jl` composes every required Julia path once; and
- Lua `linkedspec.semantic_index(source, options)` now exposes the strict source map plus detached compiled-or-
  failed foundation identically on PUC Lua/LuaJIT; four root query helpers plus index `capabilities`, typed `query`,
  and raw `query_neutral` expose all 19 exact immutable static answers and 26 malformed-request boundaries; an
  optional native invocation-local sink now delivers protected typed slot/final observations on direct, loaded,
  reconstructed, execute-alias, and traced routes; `index:with_execution_observation(events)` validates those
  handles into the twentieth exact immutable answer, while generated propagation and backend admission remain
  later Lua leaves; and
- the current `return_descriptor` / descriptor APIs remain a separate lower-level compatibility surface.

The neutral contract is complete. Backend admission is **6 complete / 0 pending**: Perl, Rust, Dart, Julia, PUC
Lua, and LuaJIT are admitted. MCP does not own semantics. Its architecture, protocol policy, neutral machine
contract, and independent conformance are complete, and the exact neutral contract is composition-closed in
canonical CI. Perl, Rust, and Dart have complete decoded/strict-stdio implementations and exact runtime admission.
Dart is the third generated filesystem-free binding, frozen schema runtime, secure opaque registry, exact decoded
discovery/list/call/cancel dispatch, bounded strict JSON stdio, and ordered twelve-role public consumer. The ledger
is now 3/5 native implementations and 3/6 runtime admissions; shared rollout remains pending.

## Accepted modern MCP transport (Perl/Rust/Dart admitted)

ADR `0055` selects stable MCP `2026-07-28` over stdio for `linkedspec-mcp-transport-v1`. LinkedSpec starts on the
modern stateless protocol instead of implementing the removed legacy lifecycle:

- every request carries its protocol version and client capabilities in `params._meta`;
- mandatory `server/discover` replaces `initialize`;
- there is no `notifications/initialized`, protocol session, or `ping`;
- an explicit opaque handle relates separate calls to one immutable native index; and
- any later legacy compatibility adapter needs evidence and its own post-public-closeout task-tree.

This decision was made before server code. The official final revision was released on 2026-07-28, one day before
the decision. Selecting it now prevents five native implementations from acquiring an obsolete handshake and
session state machine before LinkedSpec has shipped an MCP surface.

### Normative machine artifacts

Every implementation consumes one root-relative, backend-neutral bundle:

| Artifact | Role |
|---|---|
| `capability_conformance/mcp_semantic_transport_contract.json` | Normative manifest: protocol, identities, methods, tools, limits, handles, policy, errors, authority, shutdown, paths, and SHA-256 inventory. |
| `capability_conformance/mcp_semantic_transport/schema.json` | Closed JSON Schema 2020-12 definitions for the accepted envelopes, requests, results, ids, tools, semantic model, and errors. |
| `capability_conformance/mcp_semantic_transport/semantic_payloads.json` | Four canonical semantic payloads: three exact admitted native responses and the one allowed restricted-capability projection. |
| `capability_conformance/mcp_semantic_transport/corpus.json` | Ordered positive, negative, handle, policy, raw-byte, and lifecycle recipes. |
| `capability_conformance/mcp_semantic_transport/canonical_frames.jsonl` | 35 compact UTF-8 JSON-RPC frames, each followed by exactly one LF. |
| `capability_conformance/mcp_semantic_transport/validator_cases.json` | Independent 28-accepted/7-rejected frame classification, exact scenario inventories, dual digest anchors, and 68 named mutations across 14 categories. |
| `tools/materialize_mcp_semantic_transport_contract.py` | Deterministic materializer and byte/digest self-check; not a server or independent checker. |
| `tools/check_mcp_semantic_transport_contract.py` | Dependency-free independent schema/provenance/raw/state/mutation checker; never imports or executes the materializer. |
| `tools/generate_perl_mcp_contract.py` | Deterministic consumer that verifies every manifest digest and checks or rewrites the committed Perl binding. |
| `perl/LinkedSpec/MCPContract.pm` | Generated data-only Perl bundle; normative authority remains in the neutral artifacts above. |
| `tools/generate_rust_mcp_contract.py` | Deterministic consumer that checks the formatter-stable, filesystem-free Rust binding. |
| `rust/linkedspec-runtime/src/mcp_contract.rs` | Generated data-only Rust bundle. |
| `tools/generate_dart_mcp_contract.py` | Deterministic consumer that checks the formatter-stable, filesystem-free Dart private part. |
| `dart/lib/src/mcp/mcp_contract.dart` | Generated data-only Dart bundle part. |

The corpus also fixes ten raw inputs, ten lifecycle cases, four indistinguishable unavailable-handle states, and
four deployment-policy cases. All five server names occur in canonical responses. The largest checked-in frame is
14,597 bytes, well below the 1,048,576-byte inbound limit. Verify the bundle from the repository root:

```bash
bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py
```

Deliberate regeneration is explicit and reviewable:

```bash
bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py --write --print-digests
```

Ordinary verification never rewrites the JSONL. The materializer proves source-key uniqueness, schema-reference
closure, exact semantic-oracle digests, mirrored text/structured content, handle/policy dispatch boundaries,
canonical LF framing, size/count invariants, and all artifact hashes. The separate checker implements every JSON
Schema 2020-12 keyword used by this bundle—including local references, exact alternatives, closed objects,
property-name and scalar/array bounds, regular-expression constraints, and URI format—then validates the schema
document itself. It independently reconstructs every frame, verifies the exact semantic payload projection,
classifies ten raw byte inputs, executes the handle/policy/lifecycle oracle, and proves all 68 named mutations fail
at their intended invariant. This is still conformance code, not an MCP server.

Canonical local CI requires every listed artifact and all five programs. It always runs the materializer before
the independent validator, then checks Perl, Rust, and Dart generated bindings in that order only after both
neutral owners pass. Recurring tool-governance proof rejects omission of any generator and binding-before-
validator order. This detects stale JSONL/digests before independent semantic validation and prevents a derived
backend binding from becoming an oracle for its own normative source.

### Current Perl in-process implementation (decoded dispatch and strict stdio)

ADR `0057` turns the neutral requirements into a bounded native implementation. Public
`LinkedSpec::MCPServer` accepts an already-created `LinkedSpec::SemanticIndex`, never a source path or descriptor.
Its owner split is:

| Owner | Current responsibility |
|---|---|
| `LinkedSpec::MCPContract` | Implemented generated data-only Perl binding derived from the exact neutral artifacts. |
| `LinkedSpec::MCPContractRuntime` | Implemented deep-cloned templates and frozen schema-profile validator; no semantic or I/O authority. |
| `LinkedSpec::MCPServer` | Implemented native handle registry, authorization/expiry/revocation/policy, decoded dispatch, and public `serve_stdio`. |
| `LinkedSpec::MCPWire` | Implemented private bounded UTF-8 JSON-line preflight, canonical output, logging, EOF, and I/O lifecycle. |

The generated binding is necessary because the server may not read contract files at runtime, while hand-copying
tool schemas and templates would create a second contract. The repository-routed generator verifies every digest
named by the neutral manifest, composes one canonical embedded JSON value, and proves the committed module byte-
fresh after the neutral materializer and independent validator. Production runtime modules name no neutral
artifact path and perform no contract-file I/O.

The audit also measured two important Perl-specific boundaries. `return_descriptor` for the graph fixture
contains two coderefs and five compiled regex objects, whereas the opaque index's canonical capabilities and
graph-list payloads exactly match the neutral digests. And installed `JSON::PP 4.06` accepts both repeated literal
keys and escape-equivalent keys such as `"a"` plus `"\u0061"`. The wire therefore preflights decoded key identity,
JSON grammar, container depth, surrogate pairing, and top-level numeric-id token kind before ordinary JSON
decoding; `JSON::PP->decode` alone is not conformant.

The current decoded host shape is deliberately in-process:

```perl
use LinkedSpec;
use LinkedSpec::MCPServer;

my $source = "Top::\n /x/\n";
my $index = LinkedSpec::semantic_index(
  \$source,
  logical_name => "example.spec",
  source_detail_ceiling => "text",
);
my $server = LinkedSpec::MCPServer->new();
my $handle = $server->register_index(
  $index,
  authorization_context => $host_authorization,
  lifetime_ms => 900_000,
  policy => {
    source_detail_ceiling => "identity",
    page_max => 100,
    budget_maxima => {max_records => 1000, max_relations => 2000, max_depth => 4},
  },
);
my $response = $server->dispatch(
  $already_decoded_request,
  authorization_context => $host_authorization,
);
$server->revoke_handle($handle);
$server->shutdown();
```

`dispatch` accepts exactly one decoded request plus its out-of-band authorization context and returns a detached
response hash, or `undef` for a notification/suppressed cancelled response. The current methods are
`server/discover`, `tools/list`, `tools/call` for the exact capabilities/query tools, and
`notifications/cancelled`.

For modern MCP over stdio, use a fresh live server/registration and let EOF own shutdown:

```perl
my $status = $server->serve_stdio(
  input => \*STDIN,
  output => \*STDOUT,
  authorization_context => $host_authorization,
  # Optional, sanitized, and required to differ from protocol output.
  log => \*STDERR,
);
die "MCP stdio failed\n" if $status != 0;
```

`serve_stdio` accepts LF or CRLF and a complete final frame at EOF. Each payload is bounded at 1,048,576 bytes;
an overlong line is drained without retaining its tail, receives one parse-error response, and cannot prevent the
next frame from being processed. The strict preflight rejects BOMs, invalid UTF-8, batches, non-object requests,
depth above 64 containers, decoded duplicate keys, malformed/non-finite numbers, decimal/exponent request ids,
and integers outside the interoperable id range. Accepted output is compact key-sorted UTF-8 JSON followed by
exactly one LF, including literal non-ASCII text. This is an embeddable server method, not a standalone executable,
facade, source loader, compiler, or semantic cache.

Production handles read exactly 32 bytes from the OS CSPRNG, encode 43 unpadded base64url characters, and expire
against a monotonic clock. Missing entropy fails closed; there is no `rand`, wall-time, PID, or hash fallback.
Authorization context is host-owned out-of-band data and never clientInfo. Only private `_new_for_test` may inject
deterministic entropy/time and reduced test bounds. The context is a nonempty opaque byte string bounded at 4,096 octets; the
server retains only its SHA-256 digest and uses one fixed-length comparison step (including a dummy digest for an
unknown handle) while making no formal interpreter-level constant-time claim. Registry/decoded dispatch `.1`,
strict stdio/lifecycle `.2`, exact Perl admission/shared ledger `.3`, and no-change closeout `.4` are implemented
and parent-closed.

### Discovery and request metadata

A modern client can discover the server before calling a tool. This is the accepted Perl-server shape; only the
server name changes for Rust, Dart, Julia, and Lua:

```json
{"id":"discover-1","jsonrpc":"2.0","method":"server/discover","params":{"_meta":{"io.modelcontextprotocol/clientCapabilities":{},"io.modelcontextprotocol/clientInfo":{"name":"example-client","version":"1.0.0"},"io.modelcontextprotocol/protocolVersion":"2026-07-28"}}}
```

The response advertises exactly one version and only the static tools capability:

```json
{"id":"discover-1","jsonrpc":"2.0","result":{"_meta":{"io.modelcontextprotocol/serverInfo":{"name":"linkedspec-semantic-perl","version":"0.1.0"}},"cacheScope":"public","capabilities":{"tools":{"listChanged":false}},"instructions":"Use linkedspec_semantic_capabilities first, then call linkedspec_semantic_query with the same authorized handle. Handles are registered by the host and cannot be created by MCP.","resultType":"complete","supportedVersions":["2026-07-28"],"ttlMs":3600000}}
```

The checked-in machine contract owns that exact instruction text and the complete canonical bytes. The required
request metadata fields are protocol version and client capabilities. `clientInfo` is optional in the
final stable schema and is never an authorization identity. A different version receives MCP error `-32022` with
`supported: ["2026-07-28"]`; missing required metadata receives `-32602`.

The five server identities are `linkedspec-semantic-perl`, `linkedspec-semantic-rust`,
`linkedspec-semantic-dart`, `linkedspec-semantic-julia`, and `linkedspec-semantic-lua`, all initially versioned
`0.1.0`. PUC Lua and LuaJIT deliberately expose the same Lua server identity because they execute one unchanged
source implementation; the conformance report, not the wire schema, identifies the ABI leg.

### Two read-only tools, and no hidden product surface

`tools/list` always returns these two tools in this order:

1. `linkedspec_semantic_capabilities(handle)`; and
2. `linkedspec_semantic_query(handle, request)`.

Their schemas are strict JSON Schema 2020-12. Both are read-only, non-destructive, idempotent, and closed-world.
There are no MCP prompts, resources, roots, sampling, elicitation, completions, subscriptions, tasks, logging
notifications, extensions, or source-loading tools. The tool list is static (`listChanged: false`) and public-cache
eligible for one hour.

The following request asks the registered graph index for its two rules. The handle is illustrative; production
handles are generated by the local registry:

```json
{"id":7,"jsonrpc":"2.0","method":"tools/call","params":{"_meta":{"io.modelcontextprotocol/clientCapabilities":{},"io.modelcontextprotocol/protocolVersion":"2026-07-28"},"arguments":{"handle":"n4xp7T2KqW9vB3cD8mRf1Hs6JyUa0Le5ZiGoXbNCwQE","request":{"budget":{"max_depth":4,"max_records":1000,"max_relations":2000},"contract":"linkedspec-semantic-query-v1","direction":"outgoing","operation":"list","page":{"after_id":null,"limit":100},"record_kinds":["rule"],"relation_kinds":[],"source":{"detail":"identity","include_content_digest":false},"subjects":[]}},"name":"linkedspec_semantic_query"}}
```

On success, `structuredContent` is the exact native neutral response object. The single text item is the admitted
canonical JSON encoding of that same object, with no trailing newline. The outer stdio response adds exactly one
LF. Request id and native `serverInfo` necessarily differ between envelopes, so direct/native identity means the
embedded semantic payload bytes and deep-equal structured content—not byte identity of the whole JSON-RPC frame.
A native semantic response whose own `ok` field is false is still a successful MCP tool call: the semantic query
ran and returned its portable answer.

### Handles are registered locally, bounded, and non-enumerating

MCP cannot create an index or handle. The embedding first constructs an immutable index through the native API,
then registers it locally with an authorization context, lowering-only deployment policy, and expiry. It conveys
the returned handle to its client out of band.

Production handles encode 256 CSPRNG bits as exactly 43 unpadded base64url characters. Default absolute lifetime
is 15 minutes, maximum lifetime is 24 hours, and successful use does not extend expiry. Hosts can revoke early;
the default registry holds at most 1,024 live entries and clears all references at shutdown. Deterministic random
and clock injection exist only as explicit test dependencies.

Every call rechecks authorization, expiry, revocation, and policy. Unknown, expired, revoked, and unauthorized
handles intentionally look identical and return an `isError: true` tool result with code
`linkedspec_mcp_handle_unavailable`. The response never echoes the handle or says which check failed. This gives a
model an actionable “obtain a current authorized handle” recovery path without creating a handle-enumeration
oracle.

The canonical unavailable-handle result is identical for unknown, expired, revoked, and unauthorized states:

```json
{"id":11,"jsonrpc":"2.0","result":{"_meta":{"io.modelcontextprotocol/serverInfo":{"name":"linkedspec-semantic-perl","version":"0.1.0"}},"content":[{"text":"{\"code\":\"linkedspec_mcp_handle_unavailable\",\"contract\":\"linkedspec-mcp-tool-error-v1\",\"message\":\"No current authorized semantic index is available for this handle.\"}","type":"text"}],"isError":true,"resultType":"complete"}}
```

### Deployment policy can only lower native authority

A registration can lower source detail, page size, and record/relation/depth budgets. The effective limit is the
component-wise minimum of the native index, server, and registration ceilings. It cannot turn on source text,
digests, or execution observations absent from the registered index.

With default policy, the capabilities payload is byte-identical to the direct native capabilities response. With
a stricter policy, the adapter first calls native capabilities and mechanically lowers only the corresponding
capability/snapshot ceiling fields so the client can see the effective boundary. A semantic query above that
boundary fails before native dispatch with tool error `linkedspec_mcp_policy_denied`. An allowed request passes
unchanged to native `query`, and its response remains byte-identical. The adapter never silently rewrites a query
or synthesizes a semantic response.

### Decoded and wire errors, cancellation, logs, and EOF

The implemented decoded dispatcher uses `-32600` for invalid request envelopes, `-32601` for unknown methods,
`-32602` for invalid metadata, parameters, or tool names, `-32603` for sanitized internal failures, and `-32022`
for unsupported MCP versions. Unavailable handles and deployment denials are tool execution errors because a model
can act on them. Unknown, malformed, or completed cancellation notifications are ignored without a response. A
cancellation observed while a response is prepared suppresses it; an ordinary synchronous response that completed
before a later notification remains valid.

Framing/JSON failures use the contract-derived `-32700` parse error while retaining these decoded classifications
unchanged. Active request state survives decoded preparation through output flush, so a cancellation observed
before emission suppresses the frame. Successful flush retires the request; a later synchronous cancellation
cannot retract emitted bytes.

Stdout contains newline-delimited MCP messages only. The server is silent on stderr by default; host-enabled logs
are sanitized and may not contain handles, source/query/response content, logical names, authorization material,
paths, host objects, or raw exceptions. Closing stdin is graceful shutdown: the server stops accepting work,
clears the registry, releases index references, finishes a complete final frame, and returns zero. Input/output
failure uses the same release path and returns one; the optional distinct log receives only a fixed sanitized
failure record. Caller handles are not closed. There is no shutdown RPC.

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
`semantic_index`, complete immutable static capabilities/query, and typed native runtime observation. The static
record projection remains deliberately private, and observed-index derivation is not yet public. Audit `.10.6.0`
mapped the typed authorities later consumed by the foundation and remaining projection work: staged
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
semantic rollout or native-admission ledgers. At this historical `.3` boundary, no-change closeout `.10.6.5.4`
was next after the clean commit.
Full primary 5x2x66, ten Unicode legs, canonical Rust 79.96s + Dart 1/1 + primary 66x2 + Phase 0 1,031/634s,
mdBook/KM 690/5,307, all four doctrines, and exact 1,613,820-KiB cleanup preserving Julia package/registry caches
and all 517 Pgen artifacts pass.

### Julia immutable query composition closeout

Leaf `.10.6.5.4` retrieves the committed authority, kernel, traversal, and public-API facts, then recomposes the
nine committed semantic suites at exact focused 1,063. It adds no second evaluator, replacement test, fixture,
contract, public API, generated format, runtime observation, rollout, or admission. The composition reconfirms all
19 typed/raw static hashes, all 26 malformed envelopes, direct transport validation, one detached materialization,
clone/privacy/source-ceiling/export behavior, and construction/query non-execution plus callback and host denial.

Complete Julia remains 8,605 package assertions plus primary process conformance and corpus 105/105. Full primary
remains 5x2x66, all ten Unicode legs pass, and the Unicode, semantic, capability, generated-source, and public
ledgers remain unchanged. Parent `.10.6.5` is therefore composition-closed. The twentieth runtime-events response
still requires caller-captured post-execution authority and remains exclusively owned by `.10.6.6`; its authority
plan begins at `.10.6.6.0` only after this closeout commit is clean. Canonical Rust 79.55s + Dart 1/1 + primary
66x2 + Phase 0 1,031/635s, mdBook/KM 690/5,307, doctrines, and exact 1,613,872-KiB safe cleanup preserving 517
Pgen artifacts and Julia package/registry caches pass.

### Julia runtime-observation authority plan

Behavior-free leaf `.10.6.6.0` froze the Julia observation boundary before any runtime or API change. At that audit
boundary Julia did not expose a semantic observation sink. The existing high-level
`julia_runtime:regex_slot_selected` trace mark is useful operational evidence, but it is a string event rather than
the versioned typed semantic contract, and trace has no final-result topic. Diagnostic output is a third,
independent optional channel.

The exact slot seam is already shared by ordinary and generated-plan execution. A match must exist and ordered
slot identity must succeed; capture then occurs before `_accept_runtime_regex_match!` changes cursor, registers, or
action state. This ordering has an important Julia detail: the context cursor is still the old cursor, so the
semantic position must convert `one_match.codeunit_end` with `codeunit_offset_to_char_offset`. The final event is
captured only after `runtime_parse` constructs one normally returned `RuntimeParseResult`, using its resolved entry
label and `cursor_char_offset`.

The planned typed contract is `linkedspec-semantic-execution-observation-v1` with closed
`regex_slot_selected` and `rule_result` event kinds. Slot events carry executing rule, target rule, zero-based
authored slot index, and scalar position. Result events carry the entry rule, final scalar position, exact full-
input SHA-256 identity, and `succeeded`; host result values are deliberately absent. The optional invocation-local
synchronous sink must be checked before event allocation and before final input hashing. A callback failure must
escape as the exact caller object.

All routes converge on the same runtime seams:

- direct `runtime_parse` and `runtime_execute`;
- their traced convenience forms;
- `LoadedCompiledSpec` through `create_engine`;
- normalized JSON reconstruction through a new `LinkedSpecRuntimeEngine`;
- validated generated-plan direct/traced helpers; and
- fresh emitted module `execute` / `execute_with_trace` wrappers.

Generated helpers currently translate broad execution failures to `GeneratedSourceException`. They therefore
need an invocation-local semantic callback-failure marker/pass-through before generic translation; it must preserve
only genuine callback failures and never reclassify an unrelated parser failure. Result values, cursors, trace
bytes/events, diagnostic events, failure behavior, and generated-source v2/format 2 remain unchanged.

Observed-index derivation is separate from capture. It validates the typed contract and field combinations,
nonnegative positions, selected entry, exactly one successful final event last, and every executing-rule edge to
target-slot `selects_regex` relation. It obtains slot source/value shape from the static edge and result source/
shape from the selected static rule, never from host values or runtime/compiler objects. The returned index owns a
new `has_execution=true` projection with canonical execution/event records and `observed_as` relations; the base
stays static and immutable. Query remains projection-only and cannot execute, install a sink, enable trace, or hash
new input.

The exact canonical input is `ab\n`, including the newline. Its input identity is
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`; the two slot events occur at
scalar positions 1 and 2, and the final event at 2. The `runtime_events` response must retain digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.

Implementation is dependency-ordered: typed engine capture `.10.6.6.1`, immutable derivation and twentieth digest
`.2`, generated/emitted direct/traced propagation plus non-interference `.3`, and no-change composition `.4`.
Planning `.0` changes no production code, tests, fixtures, contract, API, generated format, runtime behavior,
rollout, or native admission.

### Julia typed native runtime observation capture

Leaf `.10.6.6.1` now implements the typed engine-capture layer. `LinkedSpecJulia` exports
`RUNTIME_SEMANTIC_OBSERVATION_CONTRACT`, the closed `RuntimeSemanticObservationEventKind` values
`RuntimeSemanticRegexSlotSelected` and `RuntimeSemanticRuleResult`, immutable
`RuntimeSemanticObservationEvent`, the callback alias `RuntimeSemanticObservationSink`, and
`runtime_semantic_observation_event_kind_name`.

Pass the optional sink directly to a runtime call:

```julia
using LinkedSpecJulia

source = "Top::OR{2}\n /a/ -> Top[0] { return(\"A\") }\n /b/ -> Top[1] { return(\"B\") }\n"
spec = parse_spec(source)
validate_spec(spec)
engine = LinkedSpecRuntimeEngine(compile_spec(spec))

events = RuntimeSemanticObservationEvent[]
result = runtime_parse(
    engine,
    "ab\n";
    semantic_observation_sink = event -> push!(events, event),
)

@assert result.value == Any["A", "B"]
@assert [event.position for event in events] == [1, 2, 2]
@assert [runtime_semantic_observation_event_kind_name(event.event_kind) for event in events] ==
    ["regex_slot_selected", "regex_slot_selected", "rule_result"]
```

Every event carries the eight closed fields `contract_id`, `event_kind`, `rule_label`, `target_rule`,
`regex_index`, `position`, `input_identity`, and `status`. Slot events identify the executing rule, accepted target,
zero-based authored slot, and post-match Unicode-scalar position; their result-only fields are `nothing`. The final
event identifies the selected entry, final scalar position, `succeeded` status, and exact
`input:sha256:<lowercase UTF-8 digest>`; its target/index fields are `nothing`. Host parser result values are not
part of the event. `to_json(event)` returns a fresh dictionary and renders stable wire kind names.

For canonical `ab\n`, the two slots are `Top[0]` at position 1 and `Top[1]` at position 2. Final `Top` succeeds at
position 2 with identity
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`.

The same keyword is supported by `runtime_execute`, `runtime_parse_with_trace`, `runtime_execute_with_trace`,
`execute_generated_parser_v2`, and `execute_generated_parser_with_trace_v2`. Loaded compiled specs and normalized
JSON-reconstructed specs build the same engine and need no special adapter. Events are synchronous and ordered:
each accepted slot arrives after ordered identity validation and before effects, then one final success arrives
after `RuntimeParseResult` construction. A throw or immediate exit has no final event.

Semantic observation, operational trace, and diagnostic output may coexist in one invocation. They are separate
channels: installing the semantic sink does not change result/cursor values, trace bytes/events, diagnostic events,
or native failure behavior. A sink exception unwinds as the exact caller object through ordinary, traced, and
validated generated-plan calls. When no sink is present, both emission helpers return before allocating an event;
the slot path also avoids scalar conversion and the final path avoids SHA-256. Warmed focused checks measure zero
allocation at those omission helpers.

This leaf intentionally does not widen fresh emitted module `execute` / `execute_with_trace` signatures. Public
generated/emitted propagation and isolated-host non-interference remain `.10.6.6.3`, preserving generated-source
v2/format 2 here. The event constructor also deliberately does not validate cross-field/topology combinations:
`.10.6.6.2` owns strict validation against detached static rule/edge/slot evidence, immutable observed-index
derivation, and the twentieth query digest. Thus `.1` adds capture without moving semantic rollout 4/9 or native
admission 3/6.

The focused capture suite adds 66 assertions, all ten Julia semantic suites compose at 1,129, and the complete
Julia package reaches 8,671 assertions plus primary process conformance and corpus 105/105.

### Julia immutable observed runtime projection

Leaf `.10.6.6.2` now exposes `with_execution_observation(index, events)`. Capture and derivation remain separate:
the runtime produces immutable typed evidence, while this function validates a caller-retained sequence and builds
one new semantic snapshot. It accepts only an `AbstractVector` of exact `RuntimeSemanticObservationEvent` values
and a compiled static base index that has no prior execution.

Validation is deliberately strict. Every event must use the v1 contract and its kind's closed nullable-field
topology; positions and slot indices are nonnegative; exactly one `rule_result` occurs last with `succeeded`, the
selected entry rule, and a lowercase 64-hex `input:sha256:` identity. Every slot event must name an existing target
slot and an executing rule whose retained edge has the corresponding `selects_regex` relation. Empty, foreign,
reordered, duplicate-final, failed, malformed, wrong-entry, unrelated-edge, and already-observed inputs reject as
`SemanticIndexError(stage="execution_observation", code="semantic_index_invalid_observation")`.

Derivation reads only the recursively immutable static projection. Slot source and value shape come from the
selected static slot/edge; final source and result shape come from the selected static rule. No host result value,
parser, compiler, runtime context, trace, diagnostic sink, semantic sink, path, environment, or new input hash is
available to the derivation. The caller's already-recorded input identity is validated but never recomputed.

The result owns a freshly frozen projection with `has_execution=true`. It adds canonical `execution:0`, ordered
`event:execution:0:N` records, and `observed_as` relations whose evidence ids point to each selected regex slot or
the final rule. The base remains `has_execution=false`; later mutation of the caller event vector or a serialized
query response cannot change either index.

```julia
base = semantic_index(
    source;
    logical_name = "runtime.spec",
    source_detail_ceiling = SemanticSourceTextDetail,
)
observed = with_execution_observation(base, events)

@assert !semantic_snapshot(base).has_execution
@assert semantic_snapshot(observed).has_execution

response = semantic_query(
    observed,
    SemanticQuery(
        operation = SemanticQueryListOperation,
        record_kinds = ("execution", "event"),
        source = SemanticQuerySource(detail = SemanticSourceIdentityDetail),
    ),
)
@assert [record.id for record in response.records] == [
    "execution:0",
    "event:execution:0:0",
    "event:execution:0:1",
    "event:execution:0:2",
]
```

For canonical `ab\n`, typed and raw-neutral query produce the exact twentieth response digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`. The new derivation suite passes 157
assertions; all eleven semantic suites compose at 1,286 and complete Julia reaches 8,828 package assertions plus
primary process conformance and corpus 105/105. Full primary 5x2x66, all ten Unicode-manifest legs, unchanged
governance, and canonical Rust 81.49s + Dart 1/1 + reference primary 66x2 + Phase 0 1,031/648s pass. Fresh emitted
module/public generated propagation remains `.10.6.6.3`; rollout 4/9 and native admission 3/6 do not move here.

### Julia generated and emitted observation routes

Leaf `.10.6.6.3` propagates the already-existing sink through fresh generated-source modules. Both public wrappers
accept the optional keyword:

```julia
events = RuntimeSemanticObservationEvent[]
value = LinkedSpecGeneratedParser.execute(
    "ab\n";
    semantic_observation_sink = event -> push!(events, event),
)

trace_output = IOBuffer()
traced_value = LinkedSpecGeneratedParser.execute_with_trace(
    "ab\n",
    trace_config_enabled(LinkedSpecTraceDebug);
    stdout_io = trace_output,
    semantic_observation_sink = event -> push!(events, event),
)
```

`execute` forwards to `execute_generated_parser_v2`, and `execute_with_trace` forwards to
`execute_generated_parser_with_trace_v2`. Event creation still belongs only to the shared runtime seams described
above; emitted code does not implement a second observer or derive a semantic index. This keeps direct, loaded,
reconstructed, generated-plan, fresh-emitted, and traced entry points on one event contract.

The route proof compares each observed call with its no-sink baseline. Results and diagnostic events remain equal;
traced output remains byte-identical. Direct and traced routes emit `Top[0]` at position 1, `Top[1]` at position 2,
and final `Top` success at position 2. Passing either event sequence to `with_execution_observation` retains the
twentieth typed/raw-neutral digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.

Observer failures keep exact caller object identity through public helpers, fresh modules, and an isolated Julia
host. The generated-plan helper's semantic-specific failure marker rethrows that object before generic generated-
source error translation. Immediate exit emits its accepted regex slot but never invents a final successful result.

This is an additive runtime keyword, not a generated-format revision. Emitted source stays deterministic at
`linkedspec-generated-source-v2` / format 2; its serialized plan remains exact `{label, family}` rows and contains
no observation state. The new route suite passes 51 assertions, all twelve Julia semantic suites compose at 1,337,
and complete Julia reaches 8,879 package assertions plus primary process conformance and corpus 105/105. Rollout
remains 4/9 and native admission remains 3/6 until separate composition/admission owners move them.

Full signoff passes primary 5x2x66, all ten Unicode-manifest legs, unchanged governance, and canonical CI with
Rust semantic admission 1/1 in 79.78 seconds, Dart 1/1, reference primary 66x2, and Phase 0 1,031/1,031 in 637
seconds. Knowledge Map is 694 facts / 5,348 question keys; exact 1,749,080-KiB cleanup preserves Julia package/
registry caches and all 517 Pgen evidence artifacts.

No-change closeout `.10.6.6.4` retrieves the four committed Julia runtime-observation fact cards and recomposes
all twelve owner suites at exact focused 1,337. This confirms the typed event sequence, malformed/topology
rejection, twentieth typed/raw digest, callback identity, final-result omission, every native/generated/emitted
route, absent-sink fence, and result/diagnostic/trace non-interference together without replacement code or tests.
Parent `.10.6.6` is closed with generated-source v2/format 2. Exact admission `.10.6.7` adds one ordered twelve-
role consumer at `julia/test/semantic_introspection_julia_admission_test.jl`; it composes strict text/bytes,
compiled/failed/runtime snapshots, loaded and JSON-reconstructed compilation, native/generated/public-helper/
fresh-emitted/standalone-emitted direct and traced routes, typed/raw-neutral JSON, all twenty digests, bounded-query
behavior, non-execution immutability, and host/path/IR denial. Eight independent topology mutations lock the
consumer, driver, registration, Julia status, and Julia-only rollout. Governance is now 89 mutations, rollout
5/9, and native admission 4/6; PUC Lua and LuaJIT remain the next backend targets.

Final Julia admission proof passes 416/416 consumer assertions, all thirteen semantic suites at 1,753, and the
complete Julia package at 9,295 assertions plus primary-process conformance and corpus 105/105. The full primary
matrix remains 5x2x66, all ten Unicode-manifest legs pass, and the neutral checker reports 6 groups, 20 exact
queries, 89 mutations, rollout 5 complete / 4 pending, and native admission 4 complete / 2 pending. Canonical
local CI also passes all doctrine/contract gates, Rust semantic admission 1/1 in 78.60 seconds, Dart admission
1/1, reference primary 66x2, and Phase 0 1,031/1,031 in 636 seconds. The closeout removes only 1,632,888 KiB of
regenerable build/depot artifacts and preserves source plus reusable package caches.

## Current Lua authority and Unicode foundation

PUC Lua and LuaJIT remain pending for semantic introspection, and completed behavior-free audit `.10.7.0` fixes
their implementation boundary before semantic code. The shared Lua source already has strict UTF-8 parsing, typed
source and ActionIR ASTs, staged function payload/job/result sidecars, ordered compiled state, portable diagnostics,
generated-source v2, loaded
and reconstructed execution, fresh-process emitted modules, trace, Unicode cursor conversion, and deterministic
JSON. It now exposes the opaque semantic source map/SHA-256 and compiled-or-failed foundation described below. It
now retains the exact private normalized static plus calls/staging/generated projection and evaluates the first
nine static query cases behind a package-private immutable kernel. It does not yet expose a public query method or
typed semantic observation sink.

The first Unicode implementation leaf is now complete. Generator
`unicode_case/generate_unicode_rule_label_contract.py` emits private
`lua/src/linkedspec/unicode_rule_label.lua` from the pinned Unicode 17 contract: exact metadata, all 806 range
pairs, strict Lua-5.1-compatible UTF-8 decoding, binary-search scalar membership, complete-label validation, and
longest-prefix scanning from one-based byte positions. The module requires no `utf8` library, bitwise syntax,
integer subtype, optional dependency, locale class, or table iteration order, and root `linkedspec` exports none of
its classifier surface.

The accepted privacy fixture now parses and validates on both Lua ABIs:

```lua
local linkedspec = require("linkedspec")
local spec = linkedspec.parse_spec("Töp:\n /é/\n")
assert(spec.rules[1].header.label == "Töp")
assert(linkedspec.validate_spec(spec) == nil)
```

Exactly five parser roles now use that generated authority: headers, header-looking body termination, action
targets, the blind target, and bare targets. Header parsing recognizes exactly `:`/`::` and rejects a third colon;
action/blind whole-edge remainder guards and bare-edge remainder policy prevent forbidden suffixes from becoming a
valid prefix plus ignored tail. The generic ASCII word reader remains unchanged for fluent methods, lifecycle and
keyword boundaries, and all other non-label identifiers.

One validator pass immediately after the nonempty-rule check covers declarations and every action/blind/bare
target, including programmatic and reconstructed ASTs. It uses portable code `invalid_rule_label`, stage
`validate_rule_labels`, and the exact rejected label, line, and `declaration`/`edge_target` role; targets also carry
their owning `rule_label`. This closes the former external-AST bypass before duplicate, raw, structural, and target
resolution. The classifier suite checks all 1,612 range endpoints, every 9/8/2 neutral fixture, supplementary byte
boundaries, and strict malformed UTF-8 at 1,706 assertions. The native route suite checks exact declaration and
edge parsing, delimiter/remainder behavior, raw preservation, third-colon rejection, and programmatic plus JSON-
reconstructed diagnostics at 179 assertions. Both suites and the complete `1..177` package pass unchanged on PUC
Lua and LuaJIT; PUC primary remains 66x2 and corpus validation/execution remains 105/105.

Exact downstream identity is now complete too. A single suite derives ten unique byte strings from all nine
positive fixtures and both distinct pairs and preserves them through parsed/reconstructed AST, compiled order and
maps, native JSON, descriptors, generated plans, strict loading, direct generated execution, in-process and fresh-
process emitted modules, entry selectors, native/generated diagnostics, native/generated trace, and every label
through both inline and file primary commands. The normalization-sensitive pair stays two independent keys/rules;
portable compiled and descriptor artifacts deny loader paths plus Lua table/userdata identity. The suite passes
359 assertions unchanged on PUC Lua and LuaJIT without changing production source or generated-source format.

Behavior-free source/outcome planning is complete, and source `.10.7.2.1` plus outcome `.10.7.2.2` now implement
the complete pre-projection foundation. Lua exposes one `linkedspec.semantic_index(source, options)` constructor.
`source` is a Lua string
containing strict UTF-8 bytes, and `options` has exactly required `logical_name`, required
`source_detail_ceiling` (`none`, `identity`, `span`, or `text`), and optional exact Unicode-17 `entry_rule`. There
is deliberately no path or loaded-state constructor. The returned index is an empty opaque table backed by
package-private weak-key storage; its metatable is protected, writes fail, iteration reveals no state, and its
stable string form omits caller identity, source, paths, host types, and table addresses.

The source owner rejects malformed UTF-8 before lazily loading or running the outcome pipeline, retains canonical
bytes and a private
scalar-boundary map, and computes `sha256:` identity with dependency-free Lua-5.1-compatible arithmetic. It uses
zero-based half-open byte/scalar ranges and one-based line/Unicode-scalar columns. LF advances the line and resets
the column; CR is an ordinary scalar. Mid-scalar byte boundaries are typed failures. `none` denies source
identity; `identity` permits the caller name and byte/scalar lengths; `span` adds mapping and exact ordered lookup;
and `text` adds excerpts plus the digest. Implemented methods are `source_identity`, `source_span_for_bytes`,
`source_span_for_scalars`, `source_excerpt_for_bytes`, and `locate_exact`. Returned source values are immutable
opaque records or fresh detached copies; accepted source and map state are never returned wholesale.

```lua
local linkedspec = require("linkedspec")

local source = "Töp::\n /é/\n"
local index = linkedspec.semantic_index(source, {
  logical_name = "privacy.spec",
  source_detail_ceiling = "text",
  entry_rule = "Töp",
})

local identity = index:source_identity()
assert(identity.source_id == "source:0")
assert(identity.logical_name == "privacy.spec")
assert(identity.byte_length == 13)
assert(identity.scalar_length == 11)
assert(identity.content_digest ==
  "sha256:8fe5f40cc6e9f5ce438a605f4965e04a78c34f392e13761e66d042730469f8de")

local header = index:source_span_for_bytes(0, 6)
assert(header.start_line == 1 and header.start_column == 1)
assert(header.end_line == 1 and header.end_column == 6)
assert(index:source_excerpt_for_bytes(8, 12) == "/é/")

local ok, err = pcall(function()
  return index:source_span_for_bytes(2, 3) -- starts inside ö
end)
assert(not ok)
assert(err.stage == "map_source")
assert(err.code == "semantic_source_boundary_invalid")
```

`source_identity()` includes the digest only at the `text` ceiling; its detached `to_json()` form uses JSON `null`
for a withheld digest. Each span also has `to_json()`. Constructor and map failures are opaque immutable
`SemanticIndexError` values with stable `stage`, `code`, `message`, detached sorted `fields`, and `to_json()`.
Calling an accessor above its ceiling fails with `semantic_source_detail_forbidden` rather than returning partial
data. The optional `entry_rule` is validated and retained, then used by the staged outcome owner.

Outcome leaf `.10.7.2.2` runs the existing staged user-function-aware parser, validator, compiler with duplicate
validation disabled, entry selector, and generated-v2 plan builder exactly once. It retains the typed staged
`SpecFile`, compiled authority, merged authored function/rule order, selected entry, and plan only in weak-key
private state. Five additional methods expose detached immutable values: `semantic_snapshot`,
`compilation_authority`, `compilation_diagnostic`, `entry_selection`, and `generated_plan_input`.

```lua
local linkedspec = require("linkedspec")

local index = linkedspec.semantic_index(
  "Top::\n /x/ -> Child\n\nChild:\n /y/\n",
  {
    logical_name = "inline.spec",
    source_detail_ceiling = "identity",
  }
)

assert(index:semantic_snapshot().state == "compiled")
assert(index:semantic_snapshot().has_execution == false)
assert(index:compilation_authority().parsed == true)
assert(index:compilation_authority().validated == true)
assert(index:compilation_authority().compiled == true)
assert(index:compilation_diagnostic() == nil)
assert(index:entry_selection().label == "Top")
assert(index:entry_selection().basis == "first_authored_marker")

local plan = index:generated_plan_input()
assert(plan.contract_id == "linkedspec-generated-source-v2")
assert(plan.format_version == 2)
assert(plan.source_identity == "inline.spec")
assert(plan.rows[1].label == "Top")
assert(plan.rows[2].label == "Child")
```

Snapshot state is exactly `compiled` or `failed_compilation`; `has_execution` is always false. Compilation
authority exposes presence booleans only. A failed stage returns `nil` for unavailable entry and plan values and
retains one portable diagnostic. Native validation and entry-selection `code`, `stage`, `message`, and fields are
preserved exactly. Recognized parser, compiler, or generated-plan errors use deterministic
`semantic_index_parse_failed`, `semantic_index_compilation_failed`, or
`semantic_index_generated_plan_failed` fallbacks; an unrecognized exception is rethrown with identity unchanged.
Constructor/map policy failures remain immutable `SemanticIndexError` values. The `none` ceiling also denies
generated-plan identity.

```lua
local failed = linkedspec.semantic_index(
  "Top:\n Missing\n",
  { logical_name = "failed.spec", source_detail_ceiling = "identity" }
)

assert(failed:semantic_snapshot().state == "failed_compilation")
assert(failed:compilation_authority().parsed == true)
assert(failed:compilation_authority().validated == false)
assert(failed:compilation_authority().compiled == false)
assert(failed:compilation_diagnostic().code == "bare_edge_target_undefined")
assert(failed:compilation_diagnostic().stage == "normalize_edges")
assert(failed:entry_selection() == nil)
assert(failed:generated_plan_input() == nil)
```

Direct PUC Lua and LuaJIT probes agree on the frozen inputs: graph is 128 bytes with entry
`Top/first_authored_marker` and plan `Top/and_acode_seq,Child/rep_acode`; privacy is 13 bytes with `Töp/default`;
calls is 135 bytes with function `normalize`, rules `Top,Done`, and two `default` rows. `failed.spec` retains native
`bare_edge_target_undefined` / `normalize_edges`; a missing selector retains `entry_rule_not_found` /
`select_entry_rule`. Malformed byte `0xff` currently reaches trusted staging and becomes a wrapped parser error,
which is why strict semantic decoding must precede language work. A target body that calls
`fail("target must not run")` still parses, validates, compiles, selects, and plans successfully, proving the
foundation need not invoke caller target actions or lifecycle code. Trusted bundled staged-parser execution remains
compiler infrastructure. The foundation never accepts a caller path, loads caller source, emits or executes
generated code, invokes target actions or lifecycle bodies, or creates trace, diagnostic-sink, query, or
observation state. Its focused source suite passes 378 assertions and the outcome suite passes 122 assertions
identically on PUC Lua and LuaJIT. Together they cover SHA-256 padding, Unicode coordinates, every ceiling,
graph/explicit/default/markerless/staged cases, native and fallback failures, entry/plan identity, detachment,
opacity, unrecognized-error identity, dependency scans, and target no-execution.

No-change closeout `.10.7.2.3` starts from committed outcome `c8501d3a` and adds no replacement production module,
test, fixture, API, semantic record/query, runtime observation, or generated format. It reruns the source then
outcome suites unchanged for exact 378+122 assertions on both ABIs, followed by the complete Lua, cross-backend,
ledger, and canonical gates. This composition closes the opaque source/outcome parent. The next Lua work is the
behavior-free static-authority audit `.10.7.3.0`; callers must not infer a static record or query surface from the
foundation values.

### Frozen Lua private static-projection boundary

Behavior-free audit `.10.7.3.0` fixes the exact static construction inputs before projector code. The private
targets match the neutral oracle:

| Target | Construction state | Records | Relations |
|---|---|---:|---:|
| graph | compiled, `text` ceiling | 12 | 14 |
| privacy | compiled, `text` ceiling | 4 | 3 |
| privacy limited | compiled, `identity` ceiling | 4 | 3 |
| failed | failed compilation, `span` ceiling | 6 | 4 |
| runtime static half | compiled, `text` ceiling, no execution | 7 | 8 |

The runtime-static row removes the execution record, all three event records, and every `observed_as` relation.
Constructing a static index must never run target actions, lifecycle blocks, emitted source, or generated plans.

Lua does not have one host object that can be serialized as this model. The future projector composes copied
source and its private map, parsed authored members, retained compiled rules/edges/lifecycle payloads, selected
entry identity, and the native compilation diagnostic. Each authority contributes only the fact it owns. In
particular, a source line such as:

```text
 /a/ -> Child[0] { return("first") }
```

becomes several Lua body elements. Their short `source` fragments are not the complete neutral source reference,
and ActionIR spans are offsets inside normalized action text rather than global source coordinates. The projector
must group elements by authored line, scan the complete trimmed member, and then use the retained source map for
exact UTF-8 byte/scalar spans, excerpts, and digests. This reproduces all 14 unique source references across graph,
privacy, failed, and runtime-static fixtures. Rule ids use uppercase percent-escaped UTF-8, so `Töp` becomes
`rule:T%C3%B6p`.

Compiled regex arrays also require semantic classification. The graph fixture's Top rule contains two same-line
parent matchers used to dispatch to Child, but those matchers are not Top regex-slot records. Child's two authored
`/a/` occurrences remain distinct slots 0 and 1 despite equal pattern text, and Top's edges select those Child
slots. The runtime-static fixture's two self-indexed matchers are structural slots and therefore remain, with
`selects_regex` but no redundant self `dispatches_to` relation.

Repeated lifecycle markers are occurrence identities, not a marker-keyed map. Two authored `E` blocks correlate
sequentially to two compiled payloads and become `...:E:0` and `...:E:1`, preserving order, source, and separately
inferred return shape. Shape inference is conservative and reads typed ActionIR literals only; it never samples
host runtime values. Lua's native `Default` mode reports repetition with minimum zero, but neutral v1 treats
`Default`, `And`, `Single`, and `Pipe` as non-repeating with null bounds.

Failure normalization is projection-only. The retained native diagnostic remains
`bare_edge_target_undefined` / `normalize_edges`; the private neutral target maps that one case to
`unknown_rule_reference` / `compile`, portable rule ids, and the dependency-resolution decision/explanation.
Native foundation accessors continue returning the native diagnostic unchanged.

The intended private implementation shape is one recursively immutable projection retained by the existing
opaque index, plus an unexported test materializer that returns a fresh plain-JSON clone. It reparses and recompiles
nothing. No root static/query accessor is added in `.10.7.3.1-.2`, and paths, metatable/table identity,
`SpecFile`, `CompiledSpec`, AST/ActionIR, compiled regex objects, descriptors, generated implementation, loaders,
executors, trace, diagnostic sinks, observers, environment, clocks, and randomness cannot enter portable data.
`.10.7.3.1` owns only graph/source/evidence; `.10.7.3.2` owns privacy, failure, runtime-static, repeated lifecycle,
detachment, and host denial; `.10.7.3.3` recomposes all five targets before public query work begins.

#### Lua private graph implementation

The graph subset is now implemented behind the opaque index. Construction calls one package-private projector
after the existing source and compilation outcome are fixed. It consumes those retained authorities directly;
there is no second parse, validation, compilation, entry selection, generated-plan build, or target execution.
Its complete-line scanner correlates authored members before consulting typed compiled topology, so the resulting
projection exactly contains 12 records, 14 relations, and seven source references on both PUC Lua and LuaJIT.

The exact graph includes two distinct `Child` regex-slot occurrences even though both use `/a/`, two `Top` edges
that dispatch to `Child` and select slots 0 and 1, canonical entry evidence, and occurrence-addressed lifecycle
records with conservatively inferred value shapes. Cross-rule parent matchers remain absent from target slots,
self-indexed slots remain structural, native `Default` mode normalizes to non-repetition, ids use uppercase UTF-8
percent escaping, and all records and relations are canonically ordered.

Lua's table semantics require a less obvious immutability boundary: `__newindex` does not intercept replacement
of an existing key. The projector therefore stores recursive state privately behind empty protected handles,
rather than presenting populated read-only tables. Its package-module-only test materializer returns a newly
allocated JSON-shaped clone each time. Mutating that clone cannot affect later results, and neither the root
module nor the opaque index exports a graph or query accessor. Exact proof is registered in the complete Lua gate:

```bash
bash tools/run_lua_local.sh
```

The wrapper deliberately supplies both the source-module path and a freshly built ABI-matched native PCRE2
adapter; invoking the focused file directly from an unconfigured shell is not a valid verification command.

This leaf intentionally implements only the compiled graph/source/evidence target. The two privacy ceilings,
failed and runtime-static targets, repeated-lifecycle stress, and the remaining isolation proof stay in
`.10.7.3.2`; public query remains later `.10.7.5` work.

One privacy boundary is easy to misread. The construction ceiling is snapshot policy, not destructive trimming of
the private source authority. The exact identity-ceiling construction oracle retains complete private source
references so the same immutable projection can later serve any permitted detail. Before a record leaves the
native API, the query layer checks the snapshot ceiling and structurally projects `none`, `identity`, `span`, or
`text`; an excessive request fails instead of being silently downgraded. Thus an identity-ceiling index privately
knows exact source ranges but can publicly return only source id and caller-registered logical name. The internal
exact-oracle seam is not exported. Behavior-free correction `.10.7.3.2.0` aligned the Lua task wording with ADR
`0049`, the neutral `privacy_limited` oracle, and all four admitted backend query projectors before `.3.2.1` code.

#### Lua remaining private static targets

The same projector now builds all four remaining construction targets. Compiled indexes exactly retain privacy
text at 4 records / 3 relations, privacy identity at 4/3, and the static half of the runtime fixture at 7/8 with
`has_execution=false`. The runtime-static projection contains no execution or event record and no `observed_as`
relation; construction does not invoke target actions, lifecycle blocks, a generated plan, or emitted code.

Failed compilation uses only facts that survive failure. Parsed rules provide authored order, source, rule
identity, and policy; the retained native diagnostic provides the error. For the admitted missing-rule fixture,
the private projection maps native `bare_edge_target_undefined` / `normalize_edges` to portable
`unknown_rule_reference` / `compile`, then emits the exact dependency decision, explanation, target-member source,
and 6 records / 4 relations. The native foundation diagnostic remains unchanged. Unrecognized failures take a
generic or parsed-rule fallback and never invent compiled-rule order, a selected entry, or compiled topology.

Repeated lifecycle members are verified by authored occurrence rather than marker name: two `E` blocks remain
distinct `E:0` and `E:1` records with separate order, source, and conservative ActionIR-derived shapes. Every
materialization is a detached plain-data clone of recursively immutable retained state. Neither the opaque index nor
the root module gains a static or query accessor, and dependency scans deny paths, host table identity, parser/
compiler objects, regex userdata, loaders, executors, trace, sinks, observers, environment, time, and randomness.
The focused 122-assertion suite runs after the graph proof on both PUC Lua and LuaJIT through:

```bash
bash tools/run_lua_local.sh
```

This completes the implementation portion of `.10.7.3.2.1`. Its separate clean-dependency closeout starts from
implementation `3f878ad2` and process-oracle correction `e7ae984d`; canonical passes all six doctrines, Rust
semantic admission 1/1 in 78.09 seconds, Dart 1/1, Julia 416/416 in 27.4 seconds, corrected process containment,
moved-root execution, primary 66/66 in both option environments, and Phase 0 1,031/1,031 in 637 seconds. Thus
`.10.7.3.2.1` and `.10.7.3.2` are complete. No replacement implementation or test owner, public query, runtime
observation, generated format, rollout, or native admission was added; `.10.7.3.3` separately recomposes the
committed five-target owners below.

#### Lua private static projection closeout

The no-change `.10.7.3.3` closeout starts from clean commit `2a6f24c4` and adds no second projector, replacement
test suite, public accessor, query, observation, or generated format. Instead, the complete Lua gate runs the four
committed source, outcome, graph, and remaining suites together at 379, 122, 64, and 122 assertions on PUC Lua and
LuaJIT. Their composition re-establishes graph 12/14/7, both 4/3 privacy targets, failed 6/4, runtime-static 7/8,
repeated occurrence identity, detached immutable clones, fallbacks, public omission, and host/no-execution denial.

The surrounding local proof passes package `1..177` on each ABI, PUC primary 66x2, corpus 105/105, the complete
five-backend primary 5x2x66 matrix, all ten Unicode-manifest legs, and all six no-drift ledgers. Canonical CI passes
six doctrines, Rust semantic admission 1/1 in 78.12 seconds, Dart 1/1, Julia 416/416 in 27.4 seconds, corrected
process containment, moved-root execution, reference primary 66x2, and Phase 0 1,031/1,031 in 649 seconds.

This closes private static parent `.10.7.3` without moving semantic rollout 5/9 or native admission 4/6. The next
leaf, `.10.7.4.0`, is a behavior-free authority audit for functions, helpers, calls, bindings, staged payloads,
generated-plan provenance, source correlation, and the exact 22-record/25-relation target. Public queries remain
later `.10.7.5` work.

#### Lua calls, staging, and generated authority plan

Behavior-free `.10.7.4.0` freezes that target before projector code. The neutral `calls_and_staging` snapshot is
exactly 22 records / 25 relations. The committed Lua static foundation supplies 6/6; typed functions, helpers,
calls, bindings, decision, and explanation produce the exact non-staged 18/16 core; three staged artifacts and one
selected generated artifact add four records and nine relations. The staged/generated relations are three
function `contains`, five directed staging-chain edges, and one spec `generated_as` edge.

Lua's retained authorities require three important distinctions:

- `semantic_compilation_outcome.authored_definitions` already merges functions and rules by source position, while
  `CompiledSpec.definition_order` and `compiled_rule_order` deliberately remain rule-only. The projected spec
  definition order must use and source-validate the merged authority.
- A function's retained `body_ast` is a plain staged JSON-compatible table, not typed ActionIR. The projector may
  reparse only the already-retained exact `body_source`, require exact JSON equality to the staged result, resolve
  contracts through the accepted registry, and then project from typed ActionIR. This is an integrity check, not a
  second `.spec` parse or target execution.
- Edge ActionIR spans are local to normalized action code with authored indentation removed. Adding those offsets
  to the edge start is wrong: the neutral `normalize` call would become 61..84 instead of 78..101. Typed
  outer-before-inner traversal therefore drives a bounded occurrence scanner over the authored edge, with strings,
  regex literals, comments, and nested delimiters protected. Function-body spans instead map from the staged job's
  retained global decoded-scalar body range through the existing source map after equality proof.

All nine distinct neutral source ranges reproduce exactly, including shared-but-differently-keyed binding and
normalize-call evidence. An interleaved `é` probe proves the same source map remains the sole conversion authority:
its function body is scalar 68..87 but byte 69..89. Function-surface `return` is syntax, so only nested `trim` is a
call; edge-surface `return` is the governed helper. Deterministic order is merged authored definitions, statement
order, then outer call before nested arguments.

Exact registered user functions resolve before the narrow `trim`, `match_text`, and `return` helper table.
Signatures retain fixed or native variadic minimum/rest/unbounded-maximum facts. Conservative fixed-point shape
inference uses typed literals, parameter and binding state, registered return shapes, and helper contracts;
unsupported calls or cycles remain `unknown`.

Native `function_definition` / `function_body` staging is deliberately mapped to neutral payload, parse-job, and
result roles. A result becomes `succeeded` only after typed equality and contract proof. The retained immutable
generated-v2 input then validates contract, format, caller logical identity, complete `Top/default`, `Done/default`
order, and the unique selected entry row. The projector does not invoke the plan builder or emitter, infer a
family, execute native/generated code, or retain generated Lua implementation text.

Implementation remains in the existing private static projector. `.10.7.4.1` owns typed core 18/16 and a focused
dual-ABI core suite; `.10.7.4.2` now completes staged/generated 22/25 with corruption/no-execution proof;
`.10.7.4.3` is the no-change committed-owner closeout. The outward fence excludes caller paths, host/metatable
identity, source and sidecar maps, AST/ActionIR, compiled regex, descriptors, implementation source, loaders,
executors, sinks, trace/observation state, environment, clock, and randomness. No public query, observation API,
generated format, rollout, or native admission moves in this plan. The unchanged source/outcome/graph/remaining
baseline is 379/122/64/122 assertions on each Lua ABI.

Typed-core `.10.7.4.1` now deep-equals the governed non-staged snapshot at exactly 18 records, 16 relations, and
ten private source refs. It emits four calls in global typed preorder: function `trim`, edge `normalize`, nested
`match_text`, then edge `return`. The outer user-function call owns one binding write, a `calls` relation, a
`resolves_to` relation, one decision, and two exact explanation steps; the final edge return reads the same binding.
Function, call, binding, edge, and rule shapes converge to `string` without executing the caller.

The focused suite also shows why both authorities are needed. Reordered definitions containing `é` preserve
authored order and different byte/scalar widths through the existing source map. Nested duplicate calls retain
outer-before-inner occurrence identity. Quoted and regex call-like text cannot steal a typed call. A native
variadic signature retains minimum 1, unbounded maximum, `items` rest parameter, and array-of-unknown return shape.
The full extended tree is recursively frozen before the existing test materializer returns a fresh detached,
plain, host-free JSON copy.

Focused proof passes 128 assertions on PUC Lua and 128 on LuaJIT while the prior source/outcome/graph/remaining
counts stay 379/122/64/122 per ABI. Complete Lua passes package `1..177`, PUC primary 66x2, corpus 105, and storage
proof; primary 5x2x66, Unicode 10/10, and all six governance ledgers remain exact. Canonical proof passes Rust
admission 1/1 in 77.99 seconds, Dart 1/1, Julia 416/416 in 27.4 seconds, containment/moved-root execution,
reference primary 66x2, and Phase 0 1,031/1,031 in 622 seconds. No public accessor/query, runtime observation,
staged/generated role, generated format, rollout, or native admission moves.

Staged/generated `.10.7.4.2` completes the same private projection at exactly 22 records, 25 relations, and ten
source refs. Native payload and typed parse-job version, function/body/path/text/span, fixed/variadic signature,
parser/top/result/failure/diagnostic policy, and retained result must agree before three neutral staged records are
emitted. The exact three function `contains` relations and five `consumes` / `produces` / `lowered_from` /
`staged_by` directions preserve provenance without exporting sidecars, body AST, or ActionIR.

The retained generated-v2 plan must match contract, format, logical source identity, complete compiled rule order,
and one selected entry row. Only that row's existing family leaves as one handler-plan artifact plus
`generated_as`. The projector imports no source emitter, rebuilds no plan, emits or loads no source, and invokes no
target/generated runtime, trace, diagnostic, or observation path. Core/full focused proof is 136/97 assertions per
ABI; complete Lua remains 379/122/64/122 plus package `1..177`, PUC primary 66x2, corpus 105, and storage proof.
Canonical proof passes Rust admission 1/1 in 77.92 seconds, Dart 1/1, Julia 416/416 in 27.3 seconds,
containment/moved-root execution, reference primary 66x2, and Phase 0 1,031/1,031 in 616 seconds.

Composition closeout `.10.7.4.3` reruns the six committed source, outcome, graph, remaining-static, call-core, and
staged/generated suites unchanged at exact focused 920 assertions on each Lua ABI. Complete Lua, primary 5x2x66,
Unicode 10/10, all six unchanged ledgers, and canonical Rust 81.19 seconds + Dart 1/1 + Julia 416/416 in 29.0
seconds + reference primary 66x2 + Phase 0 1,031/1,031 in 648 seconds pass. No production/test/fixture/API/query/
observation/format/ledger file changes. Parent `.10.7.4` is composition-closed and behavior-free immutable-query
authority audit `.10.7.5.0` follows.

#### Lua immutable-query authority plan

Behavior-free `.10.7.5.0` freezes the outward query boundary before implementation. All 20 neutral requests are
inventoried; `runtime_events` remains later observation work, while Lua `.10.7.5.1-.3` must reproduce the other 19
complete response hashes through both typed and raw-neutral entrypoints. Raw validation owns exactly 26 portable
malformed labels, from non-object requests and unsupported contracts through bad fields, filters, numeric ranks,
source policies, operation combinations, unknown subjects, invalid cursors, and non-explainable subjects.

One fresh detached materialization of the existing private projection is the complete evaluator authority. It
contains only snapshot, source refs, records, and relations. The evaluator cannot receive retained source or source
map above that clone, parsed/compiled/staged sidecars, AST/ActionIR, compiled regexes, generated implementation,
plan builder, emitter, loader, executor, runtime observations, trace or diagnostic sinks, paths, environment,
clock, randomness, callbacks, or host identity. Querying is therefore a structural operation: it never parses,
compiles, executes, observes, enables trace, or mutates an index or request. A nested mutation of one materialized
tree cannot affect the next request.

Lua's raw-neutral boundary must preserve JSON kind explicitly. `json.harray`, `json.array`, and `json.null`
distinguish object, array, and null even when containers are empty, and direct decoder output is admissible. A
plain table is ambiguous raw input; the typed constructor may copy ordinary option/list tables because their role
is known. PUC Lua alone exposes an integer/float subtype through `math.type`, so neutral integers instead require a
finite Lua `number`, equality with `math.floor(value)`, and the exact neutral bound on both PUC Lua and LuaJIT.
Booleans are rejected by type before that check.

The public API is deliberately small:

```lua
local json = require("linkedspec.json")
local request = linkedspec.semantic_query_request("list", {
  record_kinds = {"rule"},
  source = {detail = "identity", include_content_digest = false},
})

local capabilities = index:capabilities()
local response = index:query(request)
local neutral = index:query_neutral(json.decode(request_json))
local detached = linkedspec.semantic_query_to_json(response)
```

The root also exposes `is_semantic_query_request` and `is_semantic_query_response`. Request and response values are
protected opaque values with recursively immutable stored state; collection properties and JSON projection return
fresh detached JSON-kind trees. Operations, directions, source levels, record/relation kinds, fields, envelopes,
and diagnostic codes remain lowercase neutral strings rather than backend enums.

Canonical evaluation applies primary-stream pages, filtered outgoing/incoming/both breadth-first relation
traversal, relation-id then frontier-record-id deduplication, canonical result order, logical record/relation/depth
budgets and costs, deterministic incomplete prefixes, query-time source projection/redaction, four portable
diagnostics, and decision-first explanations. Dependency order prevents partial compatibility: `.10.7.5.1` adds
private immutable protocol values and non-traversal capabilities/list/get/explain for nine hashes; `.2` adds
private traversal/pages/budgets/costs for the remaining ten; `.3` exposes all public names together and locks all
19 typed/raw hashes plus 26 raw boundaries; `.4` is the no-change committed-owner closeout. The original audit
signoff kept focused 920 per ABI, complete Lua, primary 5x2x66, Unicode 10/10, and all six ledgers exact; canonical
CI passes Rust 1/1 in 81.33 seconds, Dart 1/1, Julia 416/416 in 29.1 seconds, containment/moved-root proof,
reference primary 66x2, and Phase 0 1,031/1,031 in 648 seconds.

#### Lua public typed and raw-neutral static query API

Leaf `.10.7.5.3` publishes the complete static query surface together; no earlier subset escaped as a partial API.
The root exports `semantic_query_request`, `is_semantic_query_request`, `is_semantic_query_response`, and
`semantic_query_to_json`. Each semantic index owns `capabilities()`, typed `query(request)`, and raw-neutral
`query_neutral(value)`:

```lua
local linkedspec = require("linkedspec")
local json = linkedspec.json

local index = linkedspec.semantic_index(
  "Top::\n /x/ -> Child\n\nChild:\n /y/\n /z/\n",
  {
    logical_name = "graph.spec",
    source_detail_ceiling = "text",
  }
)

local request = linkedspec.semantic_query_request("list", {
  record_kinds = {"rule", "regex_slot"},
  page = {after_id = "rule:Child", limit = 2},
  budget = {max_records = 1000, max_relations = 2000, max_depth = 4},
  source = {detail = "identity", include_content_digest = false},
})
local response = index:query(request)
assert(linkedspec.is_semantic_query_response(response))
print(json.encode(linkedspec.semantic_query_to_json(response)))

local raw = json.decode([[
{
  "contract":"linkedspec-semantic-query-v1",
  "operation":"list",
  "subjects":[],
  "record_kinds":["rule","regex_slot"],
  "relation_kinds":[],
  "direction":"outgoing",
  "page":{"after_id":"rule:Child","limit":2},
  "budget":{"max_records":1000,"max_relations":2000,"max_depth":4},
  "source":{"detail":"identity","include_content_digest":false}
}
]])
local neutral_response = index:query_neutral(raw)
local capabilities = index:capabilities()
```

Typed construction accepts ordinary option/list tables because their roles are known, copies them immediately,
and returns a protected request. `query` accepts only that type. The raw entry instead requires exact JSON kinds:
`json.harray` for every object, `json.array` for sequences, and `json.null` for null. Direct `json.decode` output is
therefore admissible; a plain `{}` is ambiguous and rejected rather than guessed. Exact fields, kinds, order,
duplicates, operation combinations, pages, budgets, source policies, subjects, and cursors are validated before a
typed request exists.

Neutral integer validation is identical on PUC Lua and LuaJIT: a finite `number`, equal to `math.floor(value)`,
inside the governed range, with Booleans rejected first and no dependence on PUC-only `math.type`. Numeric cursor
text uses a portable decimal/exponent plus non-finite-word grammar rather than ABI-dependent `tonumber`; `0x10`
remains an ordinary textual id. The governed malformed matrix returns all 26 exact envelopes with zero logical
cost where required. Hostile metatables, callbacks, cycles, functions, threads, userdata, and ambiguous tables are
rejected without being invoked or traversed as host authority.

Both calls enter the same evaluator after exactly one fresh materialization of the private static projection.
Protocol state is recursively immutable, collection properties and JSON projection are fresh detached trees, and
mutating a request, response projection, or earlier query cannot affect any later result. The query module imports
only `linkedspec.json`; retained source/compiler/staged/AST/IR/generated/runtime/trace/path/callback authority is
unreachable. The suite matches all 19 complete response hashes through both public paths and locks public topology,
all raw boundaries, immutability, one materialization, non-execution, and host denial at 571 assertions per ABI.
Together with the six projection suites, focused semantic proof is 1,492 assertions per ABI. Runtime events remain
caller-owned `.10.7.6` work and native admission remains `.10.7.7`. Complete signoff also passes package
`1..177` per ABI, PUC primary 66x2, corpus 105/105, 13-owner storage proof, primary 5x2x66, Unicode 10/10, all six
unchanged ledgers, and canonical Rust 1/1 in 78.05 seconds, Dart 1/1, Julia 416/416 in 27.3 seconds, containment,
moved-root proof, reference primary 66x2, and Phase 0 1,031/1,031 in 624 seconds. The mdBook and Knowledge Map
729/5,824 pass.

#### Lua immutable static-query closeout

Leaf `.10.7.5.4` starts from clean public-query commit `65cb13da` and adds no replacement production module,
test, fixture, contract, API, runtime observation, generated format, or governance owner. It retrieves and reruns
the seven committed source, outcome, graph, remaining-static, call-core, staged/generated, and public-query suites
at 380 + 122 + 64 + 122 + 136 + 97 + 571 = 1,492 assertions on each Lua ABI. That recomposition again proves all
19 typed/raw static hashes, all 26 malformed boundaries, exact public topology, recursive detachment, one
materialization, input/interleaving isolation, source/privacy ceilings, portable JSON/numeric/cursor behavior,
non-execution, and compiler/runtime/trace/path/environment/time/random/callback/host denial.

Complete closeout proof passes Lua package `1..177` per ABI, PUC primary 66x2, corpus 105/105, 13-owner storage,
primary 5x2x66, Unicode 10/10, and all six unchanged governance ledgers. Canonical CI passes six doctrines, Rust
admission 1/1 in 77.93 seconds, Dart 1/1, Julia 416/416 in 27.4 seconds, elevated process containment, moved-root
proof, reference primary 66x2, and Phase 0 1,031/1,031 in 622 seconds. Parent `.10.7.5` is therefore
composition-closed. Runtime observation remains absent and belongs to the behavior-free authority/route audit in
`.10.7.6.0`; native admission remains `.10.7.7`.

#### Frozen Lua runtime-observation authority plan

Leaf `.10.7.6.0` is behavior-free: Lua still exposes no `semantic_observation_sink`, typed semantic event, or
`with_execution_observation` method. The audit instead freezes the exact authority that `.10.7.6.1-.3` must add
without deriving semantics from trace text, diagnostic output, or a host result value.

The current interpreter has two authoritative seams:

| Semantic fact | Exact Lua seam | Required position/identity |
| --- | --- | --- |
| selected regex slot | after a match and ordered slot identity succeed, before `accept_match(...)` mutates runtime state | `one:char_end()` plus `rule.label` and every target rule/authored zero-based index from `compiled_regex_slot_identities_for(...)` |
| completed entry result | immediately after a normally returned `RuntimeParseResult` is constructed | selected entry label, `cursor_char_offset`, and SHA-256 of the exact input bytes |

The first distinction is important for Unicode and ordering. At the slot seam `ctx.cursor_byte` is still the old
cursor. On both PUC Lua and LuaJIT, a direct probe of pattern `é` over `xé` reports byte end 3 but Unicode-scalar
end 2. A semantic event must use the latter. The existing `lua_runtime:regex_slot_selected` high-trace mark is
emitted at the same structural decision, but its formatted text is not a typed event and cannot be parsed back
into semantic authority.

The future protected event vocabulary is fixed by
`linkedspec-semantic-execution-observation-v1`. Every event has the same fields; inapplicable fields are null in
its detached JSON projection:

```json
[
  {
    "contract_id": "linkedspec-semantic-execution-observation-v1",
    "event_kind": "regex_slot_selected",
    "rule_label": "Top",
    "target_rule": "Top",
    "regex_index": 0,
    "position": 1,
    "input_identity": null,
    "status": null
  },
  {
    "contract_id": "linkedspec-semantic-execution-observation-v1",
    "event_kind": "regex_slot_selected",
    "rule_label": "Top",
    "target_rule": "Top",
    "regex_index": 1,
    "position": 2,
    "input_identity": null,
    "status": null
  },
  {
    "contract_id": "linkedspec-semantic-execution-observation-v1",
    "event_kind": "rule_result",
    "rule_label": "Top",
    "target_rule": null,
    "regex_index": null,
    "position": 2,
    "input_identity": "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece",
    "status": "succeeded"
  }
]
```

A normally returned parse is a succeeded invocation even when `matched` is false, so it receives one final
`rule_result`. Entry-selection and execution throws plus `RuntimeExitNow` do not. A callback failure stops before
any later event and escapes as the exact Lua value supplied by the caller. Native execution therefore needs a
semantic-only failure carrier around the callback. Generated helpers need a second semantic-only carrier before
their broad `GeneratedSourceError` translation, parallel to but distinct from the existing diagnostic-output
carrier; otherwise a caller-thrown table or an existing runtime/generated error could be misclassified.

No-sink execution must return before semantic event allocation, scalar conversion, or input hashing. Final input
identity will reuse one package-internal extraction of Lua's existing pure-Lua, Lua-5.1-compatible SHA-256
authority; it must not shell out, require an optional native digest module, or carry a duplicate implementation.
Observation remains independent of trace and `diagnostic_sink`, and adding it may not change result values,
cursors, trace bytes/events, diagnostics, failure behavior, generated-source v2/format 2, or the minimal
`{label, family}` plan.

Read-only route probes already establish the adapter topology on both Lua ABIs. Direct, loaded, normalized-AST
reconstructed, generated-plan, generated-plan traced, freshly loaded emitted, and emitted-traced execution all
return `["A","B"]` for the governed 73-byte `runtime.spec` and three-byte `ab\n` input. Native result envelopes
finish at byte/scalar offset 2. Direct traced, generated traced, and emitted traced routes each produce exactly two
existing selected-slot marks. These are topology observations only; there is still no semantic sink at this leaf.

After capture, `index:with_execution_observation(events)` will validate exact typed handles against one fresh
detached static projection. Each slot must map from its executing rule through an owned edge and `selects_regex`
relation to the named target slot; the one succeeded selected-entry result must be last. Shapes and source evidence
come only from static records. The method returns a new immutable snapshot with canonical `execution:0`, ordered
events, and `observed_as` relations while leaving the base static. It cannot parse, compile, execute, hash new
input, install a sink, enable trace, read a path, or inspect a host result. The derived `runtime_events` query must
match digest `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.

Implementation remains omission-safe: `.1` adds shared digest ownership plus typed direct/loaded/reconstructed
capture; `.2` adds strict detached derivation and the twentieth digest; `.3` propagates generated/emitted/traced
and isolated dual-ABI routes with exact callback identity; `.4` recomposes committed owners without changing
format, rollout, or admission. At the audit boundary, the unchanged seven semantic suites pass 1,492 assertions
per ABI, diagnostic callback proof passes 119 per ABI, package proof is 177/177 per ABI, and the neutral oracle
remains 6 groups / 20 responses / 89 rejected mutations at rollout 5/9 and admission 4/6.

#### Lua native typed runtime-observation capture

Leaf `.10.7.6.1` implements the native portion of that plan on both PUC Lua and LuaJIT. The optional
`semantic_observation_sink` is a function in the per-invocation options table accepted by `runtime_parse`,
`runtime_execute`, `runtime_parse_with_trace`, and `runtime_execute_with_trace`. It is deliberately rejected as an
engine option because an engine is reusable and must not retain caller callbacks.

```lua
local linkedspec = require("linkedspec")
local json = linkedspec.json

local source = [[
Top::OR{2}
 /a/ -> Top[0] { return("A") }
 /b/ -> Top[1] { return("B") }
]]
local compiled = linkedspec.compile_spec(linkedspec.parse_spec(source))
local engine = linkedspec.runtime_engine(compiled)

local events = {}
local result = linkedspec.runtime_parse(engine, "ab\n", {
  semantic_observation_sink = function(event)
    assert(linkedspec.is_runtime_semantic_observation_event(event))
    events[#events + 1] = event
  end,
})

assert(result.value[1] == "A" and result.value[2] == "B")
assert(result.cursor_code_unit == 2)
assert(result.cursor_char_offset == 2)
assert(linkedspec.RUNTIME_SEMANTIC_OBSERVATION_CONTRACT ==
  "linkedspec-semantic-execution-observation-v1")

local first = linkedspec.runtime_semantic_observation_event_to_json(events[1])
assert(first.event_kind == "regex_slot_selected")
assert(first.rule_label == "Top")
assert(first.target_rule == "Top")
assert(first.regex_index == 0)
assert(first.position == 1)
assert(first.input_identity == json.null and first.status == json.null)

local final = linkedspec.runtime_semantic_observation_event_to_json(events[3])
assert(final.event_kind == "rule_result")
assert(final.position == 2)
assert(final.input_identity ==
  "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece")
assert(final.status == "succeeded")
```

The event handle exposes those eight read-only properties but stores no public table fields; its metatable is
protected, assignment fails, and only the exact handle satisfies the guard. The JSON helper returns a fresh
detached `json.harray` every time. Mutating that projection cannot change the event, and a deep-equivalent JSON
object does not become a typed event. Constructors remain package-internal so callers cannot forge runtime
evidence.

Slot delivery occurs after a match and its compiled ordered identity are accepted but before `accept_match`
changes runtime state. Position is `one:char_end()`, not the old context cursor. For input `xé`, both ABIs therefore
report byte cursor 3 but slot/final scalar position 2. Final delivery occurs only after `RuntimeParseResult` exists.
A normally unmatched result is still a successful invocation and gets one final event; selector failures,
execution failures, and `RuntimeExitNow` do not. If the callback rejects a slot, no later slot or final event is
delivered. If it rejects the final event, the callback has seen it but the parse does not return.

Callbacks are synchronous and may throw any Lua value. A private semantic-only carrier survives nested runtime
catches and trace-scope cleanup, then restores the exact original string, table, `nil`, or existing runtime error
to the caller. Trace output/events and `diagnostic_sink` events remain byte/value-identical with and without the
semantic sink, and reentrant parses retain separate event sequences. When no sink is present, the slot path does
not construct a closure or event and does not convert the match end; the final path does not construct an event or
hash input. Source identities and final input identities share one package-internal arithmetic SHA-256 owner that
uses the common Lua 5.1 surface and no external executable or optional digest module.

Direct engines, `LoadedCompiledSpec:create_engine()`, normalized-AST reconstruction, execute aliases, traced
convenience calls, public generated-plan helpers, and freshly emitted modules all reuse this one native seam.
Generated execution installs a separate semantic callback carrier before broad generated-error translation, so
the exact arbitrary caller failure survives without sharing the diagnostic carrier. Immutable observed-index
derivation is described below. Generated-source v2/format 2, results, trace, diagnostics, rollout 5/9, and native
admission 4/6 are unchanged.

The focused native suite passes 121 assertions per ABI. The seven existing semantic suites now total 1,493 per
ABI because source-foundation proof also checks the shared SHA-256 dependency. Complete Lua passes package
`1..177` per ABI, PUC primary 66x2, corpus 105/105, and the 14-owner same-volume storage proof.
Complete signoff also passes primary 5x2x66, Unicode 10/10, every unchanged no-drift ledger, and canonical CI with
Rust admission 1/1 in 77.88 seconds, Dart 1/1, Julia 416/416 in 27.3 seconds, containment/moved-root proof,
reference primary 66x2, and Phase 0 1,031/1,031 in 621 seconds. Knowledge Map is 731 facts / 5,851 question keys.

#### Lua immutable observed-index derivation

Leaf `.10.7.6.2` adds one method to the opaque index:

```lua
local base = linkedspec.semantic_index(source, {
  logical_name = "runtime.spec",
  source_detail_ceiling = "text",
})

local observed = base:with_execution_observation(events)
assert(base:semantic_snapshot().has_execution == false)
assert(observed:semantic_snapshot().has_execution == true)

local runtime_records = observed:query(linkedspec.semantic_query_request("list", {
  record_kinds = { "execution", "event" },
  source = { detail = "text", include_content_digest = true },
}))
assert(#runtime_records.records == 4)
assert(runtime_records.records[1].id == "execution:0")
assert(runtime_records.records[2].id == "event:execution:0:0")
```

Capture and derivation have deliberately separate authority. `with_execution_observation` accepts only a dense
caller-retained sequence of the exact protected event handles described above. It rejects plain JSON lookalikes,
host-metatable sequences, gaps and nonpositive keys, unknown contracts or kinds, invalid UTF-8 labels, nonfinite,
fractional, or negative positions/indices, wrong nullable fields, unstable input identities, duplicate/reordered
results, failed or already-observed bases, and any event that cannot be proven against the static graph. There must
be exactly one succeeded final result, it must be last, and its rule must be the selected entry rule.

For each slot event, the executing rule must own an edge whose `selects_regex` relation reaches the named target
rule and zero-based authored slot. The event record receives source from that slot, value shape from the selecting
edge, and slot id as relation evidence. The final event receives source and result shape from the selected static
rule and uses that rule as evidence. The new projection adds canonical `execution:0`, ordered
`event:execution:0:N` records, and one `observed_as` relation per event, then sets `has_execution=true`.

The method materializes the base projection exactly once and recursively freezes the derived projection through
the existing static owner. It does not parse, validate or compile source; execute a parser; enable trace or
diagnostics; install a sink; hash input; read a path or environment; inspect a host result; or retain caller-owned
tables. The base remains static. Mutating the original event sequence, a detached event JSON object, a response,
or the private test materialization cannot change either index, and repeated/interleaved derivations remain
byte-identical.

For canonical `runtime.spec` over `ab\n`, typed `query` and raw-neutral `query_neutral` both retain the exact
`runtime_events` response digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`. The derivation suite passes 269
assertions on each Lua ABI. Generated-plan and emitted observation propagation is described next; derivation itself
does not change generated-source v2/format 2, semantic rollout, native admission, or any governance ledger.

Complete signoff passes Lua package `1..177` on both ABIs, PUC primary 66x2, corpus 105/105, storage 14, primary
5x2x66, Unicode 10/10, all six unchanged ledgers, and canonical CI through Phase 0 1,031/1,031 in 654 seconds.
The mdBook build and Knowledge Map 732/5,863 also pass.

#### Lua generated and emitted observation routes

Public generated-plan helpers accept the same invocation-local sink as native execution:

```lua
local generated_events = {}
local value = linkedspec.execute_generated_parser_v2(compiled, plan, input, identity, {
  semantic_observation_sink = function(event)
    generated_events[#generated_events + 1] = event
  end,
})

local observed = static_index:with_execution_observation(generated_events)
```

`execute_generated_parser_with_trace_v2` provides the traced public route. Fresh modules returned by
`emit_lua_source_v2` expose matching `execute(input, options)` and `execute_with_trace(input, config, options)`
wrappers, so callers pass the same sink without a second event vocabulary or derivation path. Direct, traced,
fresh-emitted direct/traced, and separate isolated-host proof passes unchanged on both PUC Lua and LuaJIT. Each
canonical route yields the same two slot events plus final result and therefore the same twentieth response digest.

Generated execution wraps only the supplied semantic callback in a private generated-specific carrier before
delegating to the native runtime. The runtime accepts a generated sink only when the exact wrapped function is
also present as its package-private marker. This prevents arbitrary generated metadata or a directly supplied
sink from bypassing the generated boundary. After native trace cleanup, the wrapper recognizes only its own
carrier and rethrows the original string, table, `nil`, or existing runtime error; the broad
`GeneratedSourceError` translator still owns unrelated failures. Diagnostic callbacks use their separate carrier.

The already-option-bearing emitted wrappers needed no emitted-text change. Repeated source bytes remain
deterministic `linkedspec-generated-source-v2` / format 2, and every plan row still contains exactly `{label,
family}`. No observation option, event vocabulary, callback, or retained state is serialized. With no sink, the
existing runtime guard still skips event construction, scalar conversion, and input hashing. Successful results,
cursors, trace bytes/events, and diagnostic events are unchanged; normal unmatched execution emits its final
success, while entry/runtime/`exit_now` failures do not.

The route owner passes 80 assertions per ABI. All ten Lua semantic owners compose at 1,964 assertions per ABI;
complete Lua passes package `1..177` on each ABI, PUC primary 66x2, corpus 105/105, and the 15-owner same-volume
storage oracle. Semantic rollout remains 5/9 and native admission remains 4/6 pending their separate owners.

Complete signoff passes primary 5x2x66, Unicode 10/10, all six unchanged ledgers, and canonical CI with Rust
admission 1/1 in 82.65 seconds, Dart 1/1, Julia 416/416 in 29.5 seconds, containment/moved-root proof, reference
primary 66x2, and Phase 0 1,031/1,031 in 667 seconds. The mdBook build and Knowledge Map 733/5,874 also pass.

#### Lua runtime-observation composition closeout

Leaf `.10.7.6.4` starts from clean generated-route commit `04ab4fec` and adds no replacement production module,
test, fixture, contract, API, observation vocabulary, generated format, rollout, admission, or governance owner.
It retrieves and reruns the ten committed source, outcome, graph, remaining-static, call-core, staged/generated,
public-query, native-observation, observed-index derivation, and generated-route suites at
382 + 122 + 64 + 122 + 136 + 97 + 571 + 121 + 269 + 80 = 1,964 assertions on each Lua ABI. That recomposition
again proves native, loaded, reconstructed, generated, emitted, traced, and isolated-host routes; exact arbitrary
callback identity; strict detached observation validation; the twentieth typed/raw-neutral digest; immutable
base/derived isolation; no-sink zero work; result/trace/diagnostic neutrality; and compiler/runtime/path/host
authority denial.

Complete closeout proof passes Lua package `1..177` per ABI, PUC primary 66x2, corpus 105/105, 15-owner storage,
the five-backend primary 5x2x66 matrix, all ten Unicode-manifest legs, and every unchanged governance ledger.
Canonical CI passes all six doctrines, Rust admission 1/1 in 81.52 seconds, Dart 1/1, Julia 416/416 in 29.0
seconds, elevated process containment, moved-root proof, reference primary 66x2, and Phase 0 1,031/1,031 in 656
seconds. Parent `.10.7.6` is therefore composition-closed without changing deterministic generated-source
v2/format 2, semantic rollout 5/9, or native admission 4/6. The separate ordered dual-ABI admission consumer
remains `.10.7.7`.

#### Lua dual-ABI admission

Leaf `.10.7.7` adds one file, `lua/test/semantic_introspection_lua_admission_test.lua`, rather than another semantic
model, projector, evaluator, observation seam, or runtime route. That Lua-5.1-compatible source declares the
established twelve roles once and runs byte-for-byte unchanged under both PUC Lua and LuaJIT.

The consumer composes strict byte/text normalization; compiled graph, calls, privacy, failed, and observed
runtime snapshots; direct, loaded, normalized-JSON reconstructed, public generated-plan, fresh-emitted direct/
traced, isolated emitted, native traced, and generated-helper traced execution; typed/native-neutral JSON; all
twenty exact response digests; privacy, pages, budgets, errors, explanations, request/response isolation, and query
non-execution; plus denial of paths, Lua host tables/metatables and implementation/type text, AST/ActionIR,
observation objects, generated implementation source, trace, and pointer-like identity.

Both Lua admission rows reference one identical consumer object, `tools/run_lua_local.sh` invokes its same path
exactly once per ABI, and canonical CI requires it. Nine independent mutations lock the two ABI statuses and the
shared path, ordered roles, driver, Lua-only rollout, and registration. Each ABI passes exactly 408 assertions.
At the Lua admission boundary, the neutral gate reported six groups, twenty response hashes, and 98 rejected
mutations at rollout 6/9 and native admission 6/6.

All eleven Lua semantic owners pass 2,372 assertions per ABI. Complete Lua passes package `1..177` under both
interpreters, PUC primary 66x2, corpus 105/105, and the 16-owner same-volume storage oracle. The five-backend
primary matrix passes 5x2x66 and every Unicode-manifest backend/environment leg passes. Canonical CI passes six
doctrines, Rust admission 1/1 in 80.10 seconds, Dart 1/1, Julia 416/416 in 28.5 seconds, process containment,
moved-root proof, reference primary 66x2, and Phase 0 1,031/1,031 in 663 seconds. Lua parent `.10.7` is closed;
Knowledge Map 735/5,894 passes, and recurring six-runtime composition remains separately owned by `.10.8`.

#### Recurring six-runtime proof

Leaf `.10.8` adds one completed orchestration driver,
`tools/check_semantic_introspection_six_runtime.sh`, without adding a seventh semantic consumer or changing any
backend model, query evaluator, observation seam, generated format, or public API.

One invocation runs the neutral checker followed by the exact admitted twelve-role consumers for Perl, Rust,
Dart, Julia, PUC Lua, and LuaJIT. The existing consumers remain responsible for all twenty responses, compiled/
failed/observed snapshots, native/loaded/reconstructed/generated/emitted/traced/isolated routes, privacy, pages,
budgets, portable errors, explanations, isolation, non-execution, and host-leak denial.

The v1 primary CLI deliberately has no semantic-introspection option. Recurring proof therefore selects three
existing no-drift cases across all five commands and both option environments:

```bash
bash tools/run_primary_cli_matrix.sh \
  --case success_named_source_literal_input \
  --case failure_compile_precedes_input_load \
  --case trace_failure_invoke_route_low
```

Generated-source, capability, and language-coverage ledgers complete the proof. Canonical CI requires and
syntax-checks the driver on every run, while `LINKEDSPEC_RUN_SEMANTIC_MATRIX=1` opts into the expensive
all-toolchain execution. Seven recurring mutations lock runtime presence, exact command, primary and support
inventories, CI switch, driver, and rollout. Only `recurring_six_runtime` advances; MCP and public no-drift
remain separate. The neutral gate reports 6 groups / 20 responses / 105 rejected mutations, rollout
7 complete / 2 pending, and admission 6 complete / 0 pending.

The direct recurring run passes Perl 18, Rust 1/1 in 79.67 seconds, Dart 1/1, Julia 416/416 in 29.0 seconds, and
the shared Lua consumer at 408 assertions on each ABI. The three primary cases pass all 30 command/environment
legs. Generated-source remains v2 with ten families and capability state 80/0/0; the capability census remains
16 capabilities at 80/0/0; language coverage remains 246 current call names, 105 corpus fixtures plus one exact
named-mark fixture, and 122 independently covered public Perl contracts.

Canonical CI passes all six doctrines, Rust admission 1/1 in 81.08 seconds, Dart 1/1, Julia 416/416 in 29.4
seconds, repository-contained process IO, moved-root execution, reference primary 66x2, and Phase 0 1,031/1,031
in 646 seconds. The new command is also governed as the 40th outside-working-directory routed entrypoint and the
13th shell temporary owner. Thin MCP transport `.10.9` is the next semantic-introspection leaf.

#### Lua private immutable query kernel (historical dependency boundary)

Leaf `.10.7.5.1` implemented the first dependency-safe query layer without exposing the planned API.
`lua/src/linkedspec/semantic_query.lua` contains protected typed requests and responses plus protected snapshots,
records, relations, source references, diagnostics, pages, budgets, source policies, page states, and costs. At that
historical boundary root `linkedspec` exported no request constructor, guards, serializer, or capabilities call,
and semantic indexes had no query methods. `.10.7.5.3` now exposes the complete surface described above.

The private kernel matches nine complete neutral response digests unchanged on PUC Lua and LuaJIT:
`capabilities`, `graph_list_rules`, `graph_duplicate_regex_text`, `graph_explain_entry`,
`calls_symbols_and_shapes`, `failed_diagnostic`, `privacy_none`, `privacy_text_and_digest`, and
`source_ceiling_forbidden`. It preserves canonical record order, default page and logical-cost envelopes,
decision-before-explanation-step order, only the selected `explained_by` relations, and the exact source ceiling.

Source detail is projected at query time. `none` returns null source references and replaces source-derived fact
text with JSON null plus the exact redaction path. `identity` returns caller logical identity without spans.
`span` adds the retained zero-based byte/one-based Unicode-scalar coordinates. `text` adds the excerpt and returns
the retained SHA-256 digest only when explicitly requested. A request above the construction ceiling returns
`semantic_query_source_detail_forbidden`; it is never silently downgraded.

Protocol handles are empty tables with protected metatables and weak-key private state. Stored JSON object, array,
and null identity is recursively copied into unexposed frozen nodes. The typed constructor accepts ordinary Lua
option/list tables only because their role is known, copies them immediately, rejects cycles/host tables and
nonportable numbers, and never relies on PUC-only `math.type`. Collection properties return fresh JSON-kind
containers, while `to_json` recursively returns a fresh `json.harray` / `json.array` / `json.null` tree. Mutating
caller inputs, properties, facts, or a serialized response cannot affect a retained value or later query.

`semantic_index` remains the sole authority owner. Its package-private `_semantic_query_kernel` materializes the
retained frozen static projection exactly once and passes only that detached `snapshot`, `source_refs`, `records`,
and `relations` tree into the evaluator. The query module imports only `linkedspec.json`; it cannot reach retained
source/maps/outcomes, parser/compiler/staged sidecars, AST/ActionIR, regexes, generated implementation, emitter,
loader, executor, runtime observation, trace/sinks, paths, environment, clock, randomness, callbacks, or host
identity. Querying cannot parse, compile, execute, observe, or enable trace.

#### Lua private traversal, paging, budgets, and costs (historical dependency boundary)

Leaf `.10.7.5.2` completes that same package-private evaluator at all 19 static response digests. It adds
relation-kind-filtered outgoing, incoming, and both-direction breadth-first traversal. Every layer scans the
detached canonical relation stream, skips already-selected relation ids, advances only to unvisited frontier
records, records the first depth of each relation, and finally restores canonical projection order. A query never
walks a compiler object or backend graph: its only graph is the detached neutral relation array.

One pager serves capabilities, list, get, relations, and explanation steps. `after_id` must name an item in the
already-filtered primary stream; the next item begins the page. Page limits and budgets both return deterministic
prefixes, but only a budget boundary emits a warning. For example, this neutral request shape selects the two
regex-slot records after `rule:Child` (this same shape is now accepted by the public raw call above):

```json
{
  "operation": "list",
  "record_kinds": ["rule", "regex_slot"],
  "page": {"after_id": "rule:Child", "limit": 2},
  "budget": {"max_records": 1000, "max_relations": 2000, "max_depth": 4}
}
```

Its response contains `regex:rule:Child:0` then `regex:rule:Child:1`, reports the original `after_id`, has no
`next_after_id`, is complete, and costs two examined records. In contrast, a page limit of one over the two-rule
stream returns `rule:Top`, sets `next_after_id` to `rule:Top`, sets `complete=false`, and has no diagnostic because
the caller requested a page boundary rather than exhausting a budget.

Budgets count logical returned model items, not time, allocation, I/O, compiler work, or host resource counters.
A `relations` request from `rule:Top`, filtered to `contains` with `max_relations=2`, returns the first two canonical
relations, exposes the second relation id as `next_after_id`, reports cost `{records_examined: 0,
relations_examined: 2, depth_reached: 1}`, and adds:

```json
{
  "code": "semantic_query_budget_exceeded",
  "severity": "warning",
  "message": "Semantic query budget was reached; returning the deterministic prefix.",
  "fields": {"limit": "max_relations"}
}
```

Record, relation, and depth ceilings use the same deterministic-prefix rule. Relation exhaustion takes diagnostic
precedence when both relation and depth limits constrain the result. Explain always reserves one record unit for
the decision, pages only its owned explanation steps, and emits only `explained_by` relations whose steps were
returned. Unsupported contracts, invalid operation combinations, unknown subjects, invalid primary-stream
cursors, non-explainable subjects, and digest-without-text requests return portable errors with zero logical cost.

At the `.10.7.5.2` boundary the focused query suite passed 283 assertions on each ABI. Together with source 380, outcome 122, graph 64,
remaining static 122, call core 136, and staged/generated 97, the seven semantic suites compose at 1,204 per ABI.
The complete Lua gate passes package `1..177` on both runtimes, PUC primary 66x2, corpus 105/105, and repository-
volume storage proof. Ambiguous raw JSON-like inputs, all 26 malformed-request envelopes, and every public root/
index query name were intentionally deferred together to `.10.7.5.3`; runtime events remain `.10.7.6`.
Complete signoff also passes the five-backend primary matrix in both environments, all ten Unicode manifest legs,
the six unchanged governance ledgers, and canonical CI through elevated containment, moved-root execution,
reference primary 66x2, and Phase 0 1,031/1,031.

The remaining dependency order mirrors the admitted adapters while respecting Lua's table and dual-ABI risks.
Unicode negative/isolation audit `.10.7.1.3.0` found one pre-existing body-fluent suffix-loss defect on both ABIs:
`.Töp()` and `.A·B()` validated as ASCII-prefix methods because the body adapter discarded the fluent parser's
unconsumed remainder. Narrow `.3.1` now propagates that existing remainder, so seven measured suffix classes become
exact raw validation failures while no-prefix/newline controls, valid ASCII methods, and recognized body
continuations remain intact at 166 assertions per ABI. Exhaustive `.3.2` proves every negative, trust, artifact/
runtime, and adjacent-grammar route before `.3` closes. That proof is now complete: all eight neutral negatives
reject across four roles, two AST trust paths, artifact and loaded/generated/emitted/fresh runtime routes,
selectors, diagnostics, traces, strict loaders, primary commands, and every adjacent grammar at 1,542 assertions
per ABI. Parent `.3` is closed without production, format, API, semantic, rollout, or admission movement. `.4` is
complete and recomposes every committed owner unchanged, closing the Unicode prerequisite. The opaque source and
outcome parent is composition-closed; private static projection `.3`, calls/staging/generated `.4`, immutable typed/raw-neutral
query `.5`, caller-owned typed runtime observation `.6`, and one byte-identical ordered consumer at `.7` then
remain. Public semantic values must be detached and canonical; metatable names, `table: 0x...` identity, paths,
regex userdata, AST/ActionIR, callbacks, and trace objects can never enter portable responses. Unicode behavior
changes only the Lua native label boundary: the neutral contract, generated-source format, semantic six groups /
20 responses / 89 mutations, rollout 5/9, and native admission 4/6 remain unchanged.

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
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
```

The gate validates six fixture groups, derives 20 full canonical responses, compares each response with its fixed
SHA-256 digest, and reports 105 rejected mutations. The cases cover graph/slot/lifecycle meaning, calls and shapes,
staged and generated provenance, explanations, failed compilation, caller-captured runtime events, reverse
relations, page cursors and boundaries, record/relation/depth budgets, all source policies, a lowered ceiling, an
unsupported contract, and an invalid operation combination.

The checker runs unconditionally in canonical local CI. It admits only an owned backend whose exact consumer,
ordered roles, tracked path, canonical driver, native status, and rollout row all agree. It also reads
`TOOLBOX.md` and locks the exact command output plus Perl, Rust, Dart, Julia, and dual-ABI Lua runtime/admission
claims. Internal omission and wrong-value probes prove that documentation guard independently of the 98
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
bash ../tools/run_dart_project_data.sh test test/semantic_introspection_dart_admission_test.dart
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
| `.10.6.5.4` | Julia immutable query composition closeout | complete; committed focused 1,063 plus full matrices/canonical proof, no replacement code or promotion |
| `.10.6.6.1` | Julia typed native runtime observation capture | complete; immutable events/sink, new 66/focused 1,129 |
| `.10.6.6.2` | Julia immutable observed-index derivation | complete; strict topology and exact twentieth digest, new 157/focused 1,286 |
| `.10.6.6.3` | Julia generated/emitted observation propagation | complete; direct/traced/isolated routes, new 51/focused 1,337, v2/format 2 unchanged |
| `.10.6.6.4` | Julia runtime-observation composition closeout | complete; committed focused 1,337 plus full matrices/canonical proof, no replacement code or promotion |
| `.10.6.7` | Julia exact composed semantic admission | complete; ordered 12-role consumer, 89 mutations, rollout 5/9, admission 4/6 |
| `.10.7.0` | Lua authority and Unicode preflight | complete; behavior-free map and dependency split |
| `.10.7.1` | Lua Unicode-17 rule-label prerequisite | complete; exact dual-ABI classifier, routes, identity, negatives, isolation, and closeout |
| `.10.7.2.0` | Lua source/outcome contract and dependency split | complete; behavior-free opaque API/privacy/no-path/no-execution boundary |
| `.10.7.2.1` | Lua strict copied input and private source map | complete; focused 378 per ABI, portable SHA-256 and exact coordinates |
| `.10.7.2.2` | Lua compiled-or-failed outcome foundation | complete; focused 122 per ABI, detached authority/diagnostic/entry/plan, no execution or promotion |
| `.10.7.2.3` | Lua source/outcome foundation closeout | complete; committed 378+122 per ABI plus full signoff, no replacement code or promotion |
| `.10.7.3.0` | Lua static-authority map and dependency split | complete; five exact targets, occurrence/source normalization, privacy, and host fences frozen |
| `.10.7.3.1` | Lua compiled graph/source/evidence projection | implemented; private exact 12/14/7 graph on both ABIs, no public query |
| `.10.7.3.2.0` | Lua source-ceiling boundary reconciliation | complete; full private authority, outward query redaction, no behavior change |
| `.10.7.3.2.1` | Lua remaining static targets and isolation | complete; privacy 4/3 + 4/3, failed 6/4, runtime-static 7/8, clean canonical closeout |
| `.10.7.3.3` | Lua committed static-owner recomposition | complete; dual-ABI four-suite composition and full signoff close `.10.7.3` without public query or replacement code |
| `.10.7.4.0` | Lua calls/staging/generated authority audit | complete plan; exact 6/6 -> 18/16 -> 22/25 split, typed/staged/generated authorities, source/host/privacy/no-execution fences frozen before code |
| `.10.7.4.1` | Lua typed function/helper/call/binding core | complete; exact private non-staged 18/16/10, focused 136 per ABI, no promotion |
| `.10.7.4.2` | Lua staged/generated calls completion | complete implementation; exact private full 22/25/10, focused 97 per ABI, no emitter or promotion |
| `.10.7.4.3` | Lua calls/staging/generated composition closeout | complete; six committed suites recompose at focused 920 per ABI and close `.10.7.4` with no replacement code or promotion |
| `.10.7.5.0` | Lua immutable-query authority audit | complete behavior-free plan; one detached authority, exact vocabulary, 19 hashes, 26 raw boundaries, dual-ABI JSON/numeric policy, and `.1-.4` order frozen |
| `.10.7.5.1` | Lua private immutable non-traversal query kernel | implemented; protected recursive protocol values, nine exact hashes, new 159/focused 1,080 per ABI, no public query name |
| `.10.7.5.2` | Lua private traversal, paging, budgets, and costs | implemented; all 19 static hashes, focused 283/1,204 per ABI, no public exposure |
| `.10.7.5.3` | Lua public typed/raw-neutral static query | complete; all 19 hashes and 26 malformed boundaries, query 571/focused 1,492 per ABI |
| `.10.7.5.4` | Lua immutable static-query composition closeout | complete; committed focused 1,492 plus full signoff closes `.10.7.5` without replacement code or promotion |
| `.10.7.6.0` | Lua runtime-observation authority audit | complete behavior-free plan; exact seams/routes/no-sink/callback/derivation/twentieth-digest policy frozen |
| `.10.7.6.1` | Lua typed native runtime observation capture | implemented; protected events, exact native routes/callback identity, new 121/focused 1,614 per ABI, generated and derivation fenced |
| `.10.7.6.2` | Lua immutable observed-index derivation | implemented; strict detached topology validation, exact twentieth digest, new 269/focused 1,884 per ABI, generated propagation fenced |
| `.10.7.6.3` | Lua generated and emitted runtime observation | implemented; public/fresh-emitted direct/traced plus isolated dual-ABI routes, exact callback identity and marker fences, new 80/focused 1,964 per ABI, unchanged v2/format 2 |
| `.10.7.6.4` | Lua runtime-observation composition closeout | complete; committed focused 1,964 plus full signoff closes `.10.7.6` without replacement code, format change, or promotion |
| `.10.7.7` | Lua exact dual-ABI semantic admission | complete; one shared twelve-role source passes 408 assertions per ABI, identical two-row topology and nine mutations advance only Lua to 6/9 rollout and 6/6 admission |
| `.10.7` | PUC Lua and LuaJIT identity | complete |
| `.10.8` | recurring six-runtime proof | implemented; exact six-runtime driver, three 5x2 primary cases, support ledgers, canonical opt-in, and seven mutations advance only recurring to 7/9 |
| `.10.9.0` | one-contract/five-implementation/six-runtime MCP topology | complete; behavior-free architecture record |
| `.10.9.1.0` | select the official protocol and exact transport policy | complete; ADR `0055` selects modern MCP `2026-07-28`, stdio, discovery, explicit handles, and no legacy lifecycle |
| `.10.9.1.1` | encode the exact MCP schema/payload/corpus/canonical-byte bundle | complete |
| `.10.9.1.2` | independently validate and mutate the exact MCP contract | complete; 28 accepted plus seven rejected frames, ten raw inputs, ten lifecycle cases, and 68 rejected mutations |
| `.10.9.1.3` | compose recurring governance and close the exact MCP contract | complete; unconditional ordered canonical proof, two topology mutations, no server |
| `.10.9.2.0` | audit and freeze Perl native MCP owners/security seams | complete behavior-free plan; ADR `0057`, no server |
| `.10.9.2.1` | generated Perl binding, private schema runtime, secure registry, and decoded dispatch | complete with canonical signoff |
| `.10.9.2.2` | strict Perl stdio framing, token preflight, emission, cancellation, logging, and cleanup | complete with canonical signoff |
| `.10.9.2.3` | exact Perl implementation/runtime admission and shared ledger | complete; 1/5 implementations, 1/6 runtimes, rollout pending, 28 mutations, canonical signoff |
| `.10.9.2.4` | committed-owner no-change Perl closeout | complete from clean `28f84826`; focused and canonical recomposition green; parent `.10.9.2` closed |
| `.10.9.3.0` | behavior-free Rust native owner/security audit and ADR `0058` | complete from clean `4473a812`; focused/canonical signoff; no implementation behavior |
| `.10.9.3.1` | Rust shared binding, frozen runtime, secure registry, and decoded server | implemented; focused public corpus proof; admission unchanged |
| `.10.9.3.2` | Rust strict stdio framing, lexical preflight, emission, cancellation, logging, and cleanup | implemented; private/public adversarial proof; admission unchanged |
| `.10.9.3.3` | Rust exact implementation/runtime admission | complete; one twelve-role external consumer; 2/5 implementations, 2/6 runtimes, rollout pending, 39 mutations |
| `.10.9.3.4` | committed-owner no-change Rust closeout | complete from clean `13d9ce17`; focused and canonical recomposition green; parent `.10.9.3` closed |
| `.10.9.4.0` | behavior-free Dart native owner/security/wire audit and ADR `0059` | complete from clean `7f44d2a1`; exact `.1-.4` split; no implementation or ledger movement |
| `.10.9.4.1` | generated Dart binding/runtime, secure registry, and decoded server | implemented; exact focused/public proof; admission unchanged |
| `.10.9.4.2` | strict Dart stdio, iterative lexical preflight, canonical emission, and lifecycle cleanup | implemented; exact focused/public proof; admission unchanged |
| `.10.9.4.3` | exact Dart implementation/runtime admission | complete; one ordered twelve-role public consumer; 3/5 implementations, 3/6 runtimes, rollout pending, 58 mutations |
| `.10.9.4.4` | committed-owner no-change Dart closeout | pending after the admission commit |
| `.10.9.5` | native Julia MCP implementation and admission | pending after Dart parent closure |
| `.10.9.6` | one Lua MCP implementation admitted on PUC Lua and LuaJIT | pending |
| `.10.9.7` | recurring six-runtime MCP admission and parent closeout | pending |
| `.10.10` | public no-drift and closure | pending |

ADRs `0054`/`0055` define one exact modern MCP `2026-07-28` stdio contract rather than one cross-runtime
executable. Perl, Rust, Dart, Julia, and
Lua each implement the server beside the native semantic index it serves; the same Lua-5.1-compatible source must
pass independently on PUC Lua and LuaJIT. Every implementation exposes only capabilities and query tools over a
caller-registered opaque native handle. It cannot compile, read a path, traverse backend objects, cache a second
semantic model, invent explanations, or raise source/budget ceilings. The same conformance corpus must prove
direct native and MCP responses identical after canonical JSON encoding on all six runtime legs.

The contract is modern-only: required per-request metadata plus `server/discover` replace the removed
`initialize`/`notifications/initialized` handshake, sessions, and `ping`. A later legacy adapter is separately
owned after `.10.10`; it cannot fork the native tool or semantic contract.

A future aggregator is optional and outside `.10.9`. If separately justified after public closeout, it may offer
one client endpoint only by routing to these native servers; it cannot own indexes or semantic responses and
cannot reinterpret transport errors or semantic results.

Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT callers can use their admitted native static and caller-captured
runtime query surfaces now. MCP machine artifacts and independent validation are complete. Perl, Rust, and Dart
callers can use decoded in-process dispatch plus strict stdio, and all three have exact twelve-role MCP admission.
The shared status/proof ledger is therefore 3/5 implementations and 3/6 runtimes, with shared rollout pending and
the normative transport digest unchanged.

Rust now exposes both decoded in-process and strict borrowed-stream forms of that API.
`linkedspec-runtime::McpServer` retains a caller-created
`Arc<SemanticIndex>` and calls only `capabilities()` or `query_neutral()`; compile-time generated contract data,
frozen validation, and registry/decoded dispatch remain separate owners. Production handles use 256 operating-
system random bits, digest-only authorization, monotonic expiry, bounded capacity, and lowering-only policy.
Unexpected unwind panics become sanitized internal errors. Private `mcp_wire.rs` supplies duplicate-safe lexical
preflight and canonical stdio emission without weakening the decoded API. Exact admission `.10.9.3.3` composes
all twelve roles through one external consumer and advances only Rust: the ledger is now Perl + Rust at 2/5
implementations and 2/6 runtimes, with shared rollout still pending and 39 mutations guarding status, sources,
roles, authority, and CI order. No standalone server binary, primary-CLI mode, source/path bootstrap,
SDK/network/async runtime, semantic cache, aggregator, or legacy protocol is authorized.

No-change closeout `.10.9.3.4` reruns those committed owners rather than adding an umbrella oracle. The transport
remains 35 canonical frames / 10 raw inputs / 10 lifecycle cases with 68 mutations; Perl remains 22 + 13 and Rust
remains 15 + 3 + 4 + 1. Dart `.10.9.4.1` adds a 10-test generated/runtime/decoded proof and a byte-fresh
82,875-byte binding without promoting the ledger. Strict Dart stdio `.10.9.4.2` adds five focused wire/lifecycle
tests. Exact admission `.10.9.4.3` adds one ordered twelve-role public consumer; the focused Dart MCP set is now
16 tests and expanded governance rejects 58 mutations. Dart alone advances the ledger to 3/5 implementations and
3/6 runtimes; parent `.10.9.3` remains closed and shared rollout remains pending.

### Using Dart decoded MCP dispatch and strict stdio

Behavior-free `.10.9.4.0` and ADR `0059` make the Dart ownership exact; `.10.9.4.1-.2` implement its generated
binding, frozen runtime, secure registry, decoded dispatcher, and strict stdio adapter. The package umbrella exports one in-process
`McpServer` around a caller-created immutable `SemanticIndex`, plus immutable registration/policy/error value
types. The server calls only `index.capabilities` and `index.queryNeutral(request)`; it cannot accept source text
or paths, compile, execute, enable trace, retain a semantic cache, or add a primary-CLI mode.

A repository-managed Dart 3.9.2 probe shows why the wire is explicit: `jsonDecode` keeps the last value for both
literal and escape-equivalent duplicate keys, while `jsonEncode` follows insertion order. Private `mcp_wire.dart`
therefore performs bounded strict UTF-8/JSON token preflight before decoding and recursively sorts every map's
string keys before encoding. The server uses core
`Random.secure()`, a started monotonic `Stopwatch`, base64url, and the existing package-internal SHA-256 owner for
handles, expiry, encoding, and authorization without a production package dependency.

The decoded host shape ships now:

```dart
import 'dart:convert';

import 'package:linkedspec_dart/linkedspec_dart.dart';

final index = SemanticIndex.fromUtf8(
  sourceBytes,
  options: const SemanticIndexOptions(
    logicalName: 'example.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
  ),
);
final server = McpServer();
final authorization = utf8.encode('tenant-42/read-only');
final handle = server.registerIndex(
  index,
  authorization,
  options: const McpRegistrationOptions(
    lifetimeMs: 300000,
    policy: McpDeploymentPolicy(
      sourceDetailCeiling: SemanticSourceDetail.identity,
      pageMax: 50,
      budgetMaxima: McpBudgetLimits(
        maxRecords: 100,
        maxRelations: 200,
        maxDepth: 2,
      ),
    ),
  ),
);

final response = server.dispatch({
  'jsonrpc': '2.0',
  'id': 1,
  'method': 'tools/call',
  'params': {
    '_meta': {
      'io.modelcontextprotocol/clientCapabilities': <String, Object?>{},
      'io.modelcontextprotocol/protocolVersion': '2026-07-28',
    },
    'name': 'linkedspec_semantic_capabilities',
    'arguments': {'handle': handle},
  },
}, authorization);

print(response?['jsonrpc']); // 2.0
server.revokeHandle(handle);
server.shutdown();
```

`dispatch` accepts already-decoded JSON-like values, returns a detached response map, and returns `null` for a
notification or a cancellation suppressed before completion. Authorization bytes must match registration and
remain host-owned; client metadata never supplies them. Handles contain 256 secure random bits, expire after 15
minutes by default, may select 1 through 86,400,000 milliseconds, and are bounded to 1,024 live entries.
Lowering policy can reduce source/digest/page/budget authority but cannot raise native limits. Unknown, expired,
revoked, and unauthorized handles remain indistinguishable.

For MCP clients, the host can lend the same server its byte stream and sinks. This does not add a LinkedSpec
executable or CLI mode; the embedding remains responsible for constructing the index, registering it, and
supplying the transport:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

final index = SemanticIndex.fromUtf8(
  sourceBytes,
  options: const SemanticIndexOptions(logicalName: 'example.spec'),
);
final authorization = utf8.encode('tenant-42/read-only');
final server = McpServer();
server.registerIndex(index, authorization);

await server.serveStdio(
  stdin,
  stdout,
  authorization,
  log: stderr, // Optional; omit for silent operational diagnostics.
);
```

`serveStdio` checks authorization before consuming input. It accepts LF, CRLF, and one complete final frame at
EOF, with a 1,048,576-byte payload maximum excluding the delimiter. Its iterative preflight rejects invalid
UTF-8/BOM, duplicate decoded keys (including escape-equivalent spellings), malformed/non-finite numbers,
incomplete escapes or surrogate pairs, arrays/non-object roots, nesting above 64, and request ids outside the
nonempty-128-UTF-8-byte-string or interoperable-safe-integer contract. Each admitted response is canonical UTF-8
with recursively sorted object keys and exactly one LF.

Input, output, and the optional distinct log sink are borrowed and never closed. An accepted request remains
active until its response flush succeeds: cancellation observed before emission suppresses the prepared response,
whereas flushed output is final. Graceful EOF flushes, shuts down the server, and releases all registered indexes.
Input, add, or flush failure performs the same release, optionally emits only the fixed
`linkedspec_mcp_io_failure` operational code, and throws a sanitized `McpServerException`. A server stopped by
EOF/failure cannot be restarted; construct another server for another protocol-stream lifecycle.

The generated private part is 82,875 bytes and verified after byte-identical Perl/Rust bindings. Focused proof
covers all canonical decoded classifications, native payload identity, policy/cancellation/failure behavior,
clone isolation, entropy/time/capacity/shutdown, all ten raw cases, framing boundaries, hostile I/O, caller
ownership, and production authority fences. Exact admission adds one ordered twelve-role public consumer without
changing production code. The focused MCP set is 16/16, all 353 Dart package tests pass, analysis is clean, and
the ledger is 3/5 implementations + 3/6 runtimes with rollout pending and 58 rejected governance mutations.

### Using Rust decoded MCP dispatch

The host owns index construction and authorization. Registration does not accept source text or a path:

```rust
use linkedspec_runtime::{
    McpRegistrationOptions, McpServer,
    semantic_index::{SemanticIndex, SemanticIndexOptions, SemanticSourceDetail},
};
use serde_json::json;
use std::sync::Arc;

# fn example(source: &[u8]) -> Result<(), Box<dyn std::error::Error>> {
let index = Arc::new(SemanticIndex::from_utf8(
    source,
    SemanticIndexOptions::new("example.spec", SemanticSourceDetail::Text),
)?);
let authorization = b"tenant-42/read-only";
let mut server = McpServer::new()?;
let handle = server.register_index(
    index,
    authorization,
    McpRegistrationOptions::default(),
)?;

let request = json!({
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
        "_meta": {
            "io.modelcontextprotocol/clientCapabilities": {},
            "io.modelcontextprotocol/protocolVersion": "2026-07-28"
        },
        "name": "linkedspec_semantic_capabilities",
        "arguments": {"handle": handle}
    }
});
let response = server
    .dispatch(&request, authorization)?
    .expect("requests, unlike notifications, return a response");
assert_eq!(response["jsonrpc"], "2.0");

server.shutdown();
# Ok(())
# }
```

The authorization context is opaque host data and never comes from client metadata. Calls must provide the same
bytes used at registration. Empty contexts and contexts above 4,096 bytes fail as typed host-API errors. A handle
is valid for 15 minutes by default; `McpRegistrationOptions::lifetime_ms` may select 1 through 86,400,000
milliseconds. `revoke_handle` is idempotent for a syntactically valid handle, and `shutdown` is idempotent and
releases all retained `Arc<SemanticIndex>` values.

A registration policy can only reduce native limits:

```rust
use linkedspec_runtime::{
    McpBudgetLimits, McpDeploymentPolicy, McpRegistrationOptions,
    semantic_index::SemanticSourceDetail,
};

let restricted = McpRegistrationOptions {
    lifetime_ms: Some(300_000),
    policy: Some(McpDeploymentPolicy {
        source_detail_ceiling: Some(SemanticSourceDetail::Identity),
        page_max: Some(50),
        budget_maxima: Some(McpBudgetLimits {
            max_records: 100,
            max_relations: 200,
            max_depth: 2,
        }),
    }),
};
```

The capabilities tool reports the effective lower limits. A query above any effective source, digest, page, or
budget ceiling returns `linkedspec_mcp_policy_denied` before native query dispatch; an allowed query is forwarded
unchanged. Unknown, expired, revoked, and unauthorized handles all return
`linkedspec_mcp_handle_unavailable`, deliberately preventing handle-state enumeration.

`dispatch` accepts already-decoded `serde_json::Value` data. It validates the exact envelope and method schemas,
but decoded values cannot preserve lexical facts such as duplicate object keys. Use `serve_stdio` for untrusted
raw protocol bytes.

### Using Rust strict MCP stdio

The host supplies already-open streams; the MCP server does not open files, discover a terminal, or claim process
stdio. `std::io::stdin().lock()` and `stdout().lock()` are one possible host choice, while tests and embedders can
use pipes, cursors, or other synchronous `Read`/`Write` values without changing protocol behavior:

```rust
use linkedspec_runtime::McpServer;
use std::io::{self, BufReader, BufWriter};

# fn example() -> Result<(), Box<dyn std::error::Error>> {
let authorization = b"tenant-42/read-only";
let mut server = McpServer::new()?;

// Register caller-created Arc<SemanticIndex> values before entering the loop.
// server.register_index(index, authorization, options)?;

let stdin = io::stdin();
let stdout = io::stdout();
let mut input = BufReader::new(stdin.lock());
let mut output = BufWriter::new(stdout.lock());

server.serve_stdio(
    &mut input,
    &mut output,
    authorization,
    None, // or Some(&mut a_separate_sanitized_log_writer)
)?;
# Ok(())
# }
```

The strict boundary has these exact rules:

- It reads fixed 65,536-byte chunks, retains at most 1,048,576 payload bytes plus a possible CR, and drains an
  overlong frame through its LF before accepting the next frame.
- LF, CRLF, and one complete final frame at EOF are accepted. BOM, malformed UTF-8/JSON, batches, duplicate decoded
  keys, invalid escapes or surrogate pairs, non-JSON numbers, unsafe/fractional/exponent request IDs, and nesting
  beyond 64 fail at the lexical layer.
- Validated responses are sorted-key UTF-8 JSON followed by exactly one LF and are flushed before their request
  leaves the active registry.
- Cancellation in the preparation-to-emission interval suppresses the response. A response already flushed is
  final, unknown cancellation is ignored, and rejected frames do not poison the next complete frame.
- Normal work and clean EOF write no diagnostic bytes. EOF shuts down and releases all registered indexes. Any
  read, write, or flush failure does the same, returns `linkedspec_mcp_io_failure`, and writes only the fixed
  `linkedspec_mcp_io_failure\n` record when a separate optional log is supplied.

The type signature requires distinct exclusive mutable borrows for output and optional logging, preventing a safe
caller from aliasing the protocol and diagnostic channels. Authorization is checked before the first input byte is
consumed. The adapter never accepts a source path, compiler, parser, executor, cache, SDK, network listener, or
process-lifecycle option.

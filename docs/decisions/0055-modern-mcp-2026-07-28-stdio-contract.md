# ADR 0055: LinkedSpec MCP v1 uses modern MCP 2026-07-28 over stdio

- Date: 2026-07-29
- Status: accepted; machine contract encoded under `.10.9.1.1`; independent validation and implementations pending
  under `FUTURE-PARITY-BACKLOG.10.9.1.2-.7`
- Tags: architecture, mcp, json-rpc, stdio, semantic-api, security, portability, parity

## Context

ADRs `0049` and `0054` fix the semantic and process boundaries: MCP is a thin adapter over an explicitly
registered immutable native semantic index, and one exact contract is implemented natively in Perl, Rust, Dart,
Julia, and Lua, with the Lua source admitted separately on PUC Lua and LuaJIT. Before executable transport
artifacts or server code, LinkedSpec still had to select a protocol revision and make its lifecycle, methods,
errors, handles, policy, encoding, and shutdown behavior exact.

The official MCP project released stable revision `2026-07-28` on 2026-07-28. It is the first modern, stateless
revision: every request identifies its protocol version and client capabilities in `_meta`; `server/discover`
replaces the legacy `initialize` handshake; a process/connection is not a protocol session; server-to-client
requests and `ping` are removed; and state spanning calls uses an explicit application handle. This is unusually
well aligned with LinkedSpec's already-approved registered-handle architecture.

Targeting legacy `2025-11-25`, or supporting both eras in the first release, would add a second handshake/session
lifecycle and two protocol-era state machines to five implementations before LinkedSpec has shipped any MCP
surface. It would also make the old connection-scoped model the implementation baseline just as the stable
protocol removed it. A later compatibility need can be measured after the native modern contract and public
surface are complete.

Official sources used for this decision are:

- the [stable 2026-07-28 release](https://github.com/modelcontextprotocol/modelcontextprotocol/releases/tag/2026-07-28);
- [base messages, statelessness, metadata, and JSON Schema](https://modelcontextprotocol.io/specification/2026-07-28/basic/index);
- [versioning and legacy-era compatibility](https://modelcontextprotocol.io/specification/2026-07-28/basic/versioning);
- mandatory [`server/discover`](https://modelcontextprotocol.io/specification/2026-07-28/server/discover);
- [stdio framing, cancellation, and shutdown](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/stdio);
- [tool schemas, structured content, state handles, and error ownership](https://modelcontextprotocol.io/specification/2026-07-28/server/tools);
- [cacheable-result requirements](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/caching);
- [cancellation behavior](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/cancellation); and
- [JSON-RPC 2.0](https://www.jsonrpc.org/specification).

## Decision

### 1. Protocol and transport boundary

LinkedSpec adopts contract id `linkedspec-mcp-transport-v1`, implementing stable MCP `2026-07-28` over stdio
only. The first release is modern-only:

- every request uses the modern per-request metadata model;
- `server/discover` is implemented and advertises only `2026-07-28`;
- `initialize`, `notifications/initialized`, `ping`, and protocol sessions are not implemented;
- no legacy fallback or dual-era behavior is hidden in a native server; and
- Streamable HTTP, HTTP+SSE, sockets, and a multi-server aggregator are outside `.10.9`.

An `initialize` request receives JSON-RPC `-32601` with an actionable message naming modern MCP `2026-07-28`,
even though that legacy request also lacks modern metadata. `notifications/initialized` is ignored without a
response. Any later legacy adapter requires a separately justified, post-`.10.10` task-tree and cannot change the
native modern contract.

The server is ready when its host starts the stream loop; there is no readiness handshake. Each UTF-8 JSON-RPC
message occupies one line. The server accepts LF or CRLF-delimited input, emits compact canonical JSON followed by
exactly one LF, rejects a UTF-8 BOM, duplicate object keys, JSON batches, non-object top levels, invalid UTF-8,
and malformed JSON, and never writes a log or banner to stdout. The machine contract will set an inbound
1,048,576-byte line limit excluding the delimiter and a maximum JSON nesting depth of 64.

Request ids are nonempty strings of at most 128 UTF-8 bytes or integers in the interoperable JSON safe range
`[-9007199254740991, 9007199254740991]`; booleans, null, fractional values, and values outside that boundary are
invalid requests. These LinkedSpec limits remove host-number ambiguity across all six runtime admissions.

### 2. Per-request metadata and identity

Every request except the special legacy diagnostic above requires `params._meta` containing:

- `io.modelcontextprotocol/protocolVersion`, exactly `"2026-07-28"`; and
- `io.modelcontextprotocol/clientCapabilities`, as a valid object.

`io.modelcontextprotocol/clientInfo` is accepted but not required, matching the final stable schema. When present,
it is validated as MCP `Implementation` data. Syntactically valid additional metadata is ignored unless a future
advertised extension owns it; it cannot change tool availability, semantic answers, authorization, policy, or
server identity. Client identity is display/debug data, never an authentication principal.

An unsupported version receives the standard `-32022` `Unsupported protocol version` error with exact
`data.supported = ["2026-07-28"]` and the requested version. Missing or malformed required metadata receives
`-32602`. These tools require no client feature, so the server never infers capabilities from an earlier request
and does not emit `-32021` unless a later contract explicitly adds a capability dependency.

Every successful result and every tool-execution-error result contains
`_meta["io.modelcontextprotocol/serverInfo"]` with version `0.1.0` and one native server name:

| Implementation | `serverInfo.name` |
|---|---|
| Perl | `linkedspec-semantic-perl` |
| Rust | `linkedspec-semantic-rust` |
| Dart | `linkedspec-semantic-dart` |
| Julia | `linkedspec-semantic-julia` |
| Lua on PUC Lua and LuaJIT | `linkedspec-semantic-lua` |

The Lua identity intentionally names the one source implementation, not the executing ABI. Runtime admission
reports distinguish PUC Lua from LuaJIT outside the wire contract.

### 3. Exact method and capability topology

The complete server surface is:

| Method | Role |
|---|---|
| `server/discover` | Return the single supported version, native server identity, exact tools capability, and instructions. |
| `tools/list` | Return the two tools below in fixed order, without pagination or per-caller variation. |
| `tools/call` | Validate and dispatch one governed tool call. |
| `notifications/cancelled` | Best-effort cancellation of an in-flight request; never produces a response. |

Discovery advertises exactly `{"tools":{"listChanged":false}}`; there are no advertised extensions. Both
`server/discover` and `tools/list` return `resultType: "complete"`, `ttlMs: 3600000`, and
`cacheScope: "public"`. Their contents are static, authorization-independent product metadata. The server sends
no list-changed notification and exposes no subscription.

The fixed tool order is:

1. `linkedspec_semantic_capabilities`, whose strict input is exactly `{handle}` and whose output schema is the
   admitted `linkedspec-semantic-query-v1` response schema; and
2. `linkedspec_semantic_query`, whose strict input is exactly `{handle, request}`, where `request` is the admitted
   neutral query schema and the output is the same neutral response schema.

Both tools are annotated read-only, non-destructive, idempotent, and closed-world. Neither uses `x-mcp-header`.
The machine artifact in `.10.9.1.1` owns the exact titles, descriptions, JSON Schema 2020-12 objects, discovery
instructions, and canonical bytes; implementations may not localize or embellish them.

Prompts, resources, resource templates, completions, roots, sampling, elicitation, logging notifications,
progress, subscriptions, tasks, icons, embedded resources, multi-round-trip input requests, and every extension
are deliberately unsupported. Unknown request methods return `-32601`; unknown tool names and malformed
`tools/call` parameters return `-32602`. Unknown or malformed notifications are ignored without a response.

### 4. Opaque handle registry and authorization

Registration is a native host API, never an MCP tool, resource, CLI option, path loader, or source compiler. A
host registers an already-created immutable native `SemanticIndex` together with its authorization context,
deployment policy, and bounded lifetime. The registry returns an opaque handle that the host conveys to its MCP
client out of band.

Production handles contain 256 CSPRNG bits encoded as exactly 43 unpadded base64url characters. A caller cannot
supply its own handle. The only permitted deterministic random source and clock injection are explicit test
dependencies. The default absolute lifetime is 900,000 milliseconds, the maximum is 86,400,000 milliseconds,
use does not extend expiry, and hosts may revoke early. A registry holds at most 1,024 live handles by default,
prunes expired entries before refusing a registration, and clears all entries and releases index references on
shutdown.

Each tool call revalidates the handle, authorization context, revocation state, monotonic expiry, and deployment
policy. ClientInfo, connection/process identity, handle possession alone in an authenticated deployment, and a
previous successful request are not authorization. Unknown, expired, revoked, and unauthorized handles are
externally indistinguishable: they return one tool execution error with stable code
`linkedspec_mcp_handle_unavailable`, an actionable generic message, no structured content, no handle echo, and no
classification data. This follows MCP's recoverable tool-error guidance without creating an enumeration oracle.

### 5. Deployment policy is a lowering-only transport overlay

The registered native index remains the only semantic owner. A registration policy may only lower the index's
source-detail ceiling, page maximum, and record/relation/depth budget maxima. Effective maxima are component-wise
minima of native, server, and registration ceilings. Effective defaults are the native defaults capped by those
maxima. No policy can enable source content/digests or execution observations absent from the index.

`linkedspec_semantic_capabilities` first calls the native capabilities operation. With the default policy it
returns that neutral response byte-for-byte. With a stricter policy it applies one mechanical, schema-preserving
projection only to the capability response's source/detail/digest and page/budget ceiling/default fields so the
client sees the effective limits before querying. It may not change ids, ordering, semantic records/relations,
diagnostics, evidence, features, snapshot state, or any other fact.

`linkedspec_semantic_query` rejects a request above effective deployment policy before native dispatch with tool
execution error code `linkedspec_mcp_policy_denied`. An allowed request is passed unchanged to the registered
native `query` operation, and its response is returned unchanged. The adapter never silently lowers a request or
synthesizes a semantic query response. Conformance proves exact direct/MCP payload identity under default policy,
the exact allowed capability projection under restrictive policy, unchanged allowed-query identity, and denial
before native dispatch.

### 6. Result and error ownership

A successful tool call returns `resultType: "complete"`, `isError: false`, the exact native neutral object in
`structuredContent`, and one text content item containing its admitted canonical JSON bytes without a trailing
newline. Decoding the text must deep-equal `structuredContent`. A neutral semantic response with `ok: false` is
still a successful MCP tool execution: it is the native query protocol's answer, not a transport failure.

Tool execution errors are reserved for unavailable handles and deployment-policy denial. They return
`resultType: "complete"`, `isError: true`, and one text item containing the canonical
`linkedspec-mcp-tool-error-v1` object with exactly `contract`, `code`, and `message`; `structuredContent` is absent.
No source excerpt, logical name, request content, host exception, path, authorization data, or handle appears.

Wire/request failures use JSON-RPC errors:

| Code | Ownership |
|---|---|
| `-32700` | Invalid UTF-8/JSON, BOM, duplicate key, or overlong input line. |
| `-32600` | Invalid JSON-RPC request/envelope/id or forbidden batch. |
| `-32601` | Unsupported method, including the actionable modern-only `initialize` diagnostic. |
| `-32602` | Missing/malformed metadata or method parameters, including unknown tool. |
| `-32603` | Sanitized unexpected server/native failure. |
| `-32022` | Unsupported MCP protocol version, with exact supported/requested data. |

Validation order is framing/UTF-8/JSON, JSON-RPC envelope/id, the special legacy diagnostic, required metadata,
protocol version, method parameters, tool name/schema, handle/auth/expiry, deployment policy, then native call.
Errors expose the request id only after it has passed id validation. Internal failures are sanitized and may be
logged only under the stderr rules below.

### 7. Canonical encoding, cancellation, logs, and shutdown

`linkedspec-canonical-json-v1` is the existing admitted semantic encoding: UTF-8, object keys sorted
lexicographically, arrays preserved, no ASCII-only escaping, no insignificant whitespace, and no non-finite
numbers. Semantic text content contains no newline; every outer stdio frame adds exactly one LF. Full MCP
envelopes necessarily differ by request id and native serverInfo, so direct/MCP identity means exact semantic
payload bytes in the text content plus deep-equal structured content.

Cancellation uses only `notifications/cancelled` with a request id and optional reason. A server stops and
suppresses later output when it observes cancellation before response emission; unknown, malformed, or already
completed cancellation is ignored. A runtime whose bounded synchronous native call completes before its reader
can observe the notification has completed the request normally; conformance does not invent sleep hooks or
timing-dependent semantics. Cancellation reasons and request payloads are never logged by default.

Servers are silent on stderr by default. A host may enable sanitized UTF-8 operational logs on stderr only. Logs
must never contain handles, source/request/response content, source identities, authorization material, paths,
host object identities, or raw exceptions. No logging capability or `notifications/message` surface is exposed.

EOF on stdin is the graceful shutdown signal. The server stops accepting work, suppresses output for observed
cancelled work, clears the handle registry, releases index references, flushes complete response frames, and exits
zero promptly. There is no shutdown RPC. Unexpected I/O failure exits nonzero after the same registry cleanup and
may emit one sanitized stderr record.

### 8. Executable-contract and rollout order

This decision itself added no schema fixture, checker, server, native semantic behavior, or CLI behavior. The
contract parent is dependency-ordered:

1. `.10.9.1.1` encodes the exact schemas, discovery/tool definitions, canonical bytes, and corpus;
2. `.10.9.1.2` independently validates them and rejects omission/mutation drift;
3. `.10.9.1.3` composes recurring governance and closes the neutral transport contract;
4. `.10.9.2-.6` implement Perl, Rust, Dart, Julia, and one shared Lua source; and
5. `.10.9.7` admits Perl/Rust/Dart/Julia/PUC Lua/LuaJIT and closes `.10.9`.

Leaf `.10.9.1.1` now realizes item 1 without a backend server. The normative root is
`capability_conformance/mcp_semantic_transport_contract.json`; it digest-pins one closed JSON Schema 2020-12,
four semantic payloads, a 35-frame canonical JSONL stream, ten raw-byte adversarial inputs, ten lifecycle cases,
and the repository-routed deterministic materializer. Three payloads are exact admitted native-oracle responses;
the fourth is the sole schema-preserving restricted-capability projection. Independent semantic validation and
mutation testing remain item 2 rather than being hidden in the materializer.

## Consequences

- LinkedSpec starts on the current stable, sessionless protocol instead of carrying an obsolete handshake through
  five implementations.
- Explicit opaque handles are native to the protocol model and remain out-of-band registration references, not
  hidden connection sessions.
- Current SDK adoption may lag a protocol released one day before this decision. That is a deployment
  compatibility risk, not a reason to duplicate the first native contract; public closeout will document the
  version requirement, and later compatibility work requires evidence and a separate owner.
- A strict frame/id/JSON boundary prevents cross-runtime parser and number drift before semantic dispatch.
- Default-policy direct/native identity remains exact. The only authorized stricter-policy difference is the
  mechanically bounded capability projection or a pre-dispatch tool error.
- The two tools remain read-only views over immutable indexes. No file, compiler, executor, trace, cache,
  backend-object traversal, explanation, or semantic-model authority moves into MCP.

## Links

- Semantic model and thin adapter: ADR `0049`
- Native per-backend MCP topology: ADR `0054`
- Native in-memory embedding: ADR `0022`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9.1.0-.10.9.7`)

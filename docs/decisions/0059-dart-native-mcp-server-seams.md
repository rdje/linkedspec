# ADR 0059: Dart MCP uses a generated contract part and an in-process native server

- Date: 2026-07-29
- Status: accepted; behavior-free plan `.10.9.4.0` complete; generated binding/runtime and decoded server
  `.10.9.4.1` implemented; strict stdio/admission/closeout pending under `.10.9.4.2-.4`
- Tags: architecture, mcp, dart, embedding, handles, authorization, json, stdio, security, portability

## Context

ADRs `0049`, `0054`, and `0055` require Dart to implement the same thin MCP contract as Perl and Rust while
retaining native in-process ownership. The admitted Dart `SemanticIndex` already exposes fresh clone-safe
`capabilities` and `queryNeutral(Object?)` responses from an immutable projection. It has no path, executor,
trace, generated-source, primary-CLI, or host-object authority at that public seam. Focused audit proof passes the
existing exact twelve-role semantic admission and static analysis without warnings.

Dart's package and SDK inventory creates several implementation-specific constraints:

- `dart/pubspec.yaml` has no production dependency, and offline emitted-package callers depend on keeping the
  native package dependency-free;
- the package-internal SHA-256 owner already hashes strict bytes for semantic identity and can hash authorization
  contexts without introducing a crypto package;
- SDK `3.9.2` documents `Random.secure()` as cryptographic and fail-closed with `UnsupportedError`, and `Stopwatch`
  provides a monotonically increasing elapsed counter;
- a repository-managed runtime probe proves `jsonDecode` silently retains the last literal duplicate and the last
  escape-equivalent duplicate, while `jsonEncode` preserves map insertion order rather than sorting keys; and
- no Dart MCP binding, server, registry, strict JSON-line owner, SDK, network transport, executable, or primary-CLI
  mode exists at this decision.

Therefore Dart cannot delegate strict wire admission or canonical bytes to the stock JSON codec. It also must not
read the neutral artifacts at runtime or hand-copy contract schemas and static responses into production logic.

## Decision

### 1. Public embedding and private owner topology

The implementation lives in the existing `linkedspec_dart` package. The package umbrella exports one native
`McpServer` surface plus its registration/policy/error value types. The caller constructs a native immutable
`SemanticIndex`, registers that exact object with an out-of-band authorization context and lowering-only policy,
then uses decoded dispatch or caller-owned stdio streams in the same Dart process.

Four files under `dart/lib/src/mcp/` form one Dart library with private `part` ownership:

1. `mcp_contract.dart` is deterministic generated data containing one canonical embedded bundle and digest. It
   has no I/O and no semantic logic.
2. `mcp_contract_runtime.dart` verifies and decodes that bundle once, deep-clones public values, evaluates only
   the frozen schema profile, and builds Dart-identity response/error shells.
3. `mcp_server.dart` owns the public server and value types, secure registry, decoded discovery/list/two-tool/
   cancellation dispatch, native identity, lowering-only policy, fixed-work authorization comparison, and
   sanitized failure boundary.
4. `mcp_wire.dart` owns bounded streaming, strict UTF-8/JSON token preflight, canonical LF encoding, prepared
   response emission/cancellation, optional sanitized diagnostics, EOF, I/O cleanup, and registry release.

`tools/generate_dart_mcp_contract.py` consumes the existing shared verified-bundle constructor and renders the
generated part. The neutral materializer and independent validator run first; Perl, Rust, and Dart byte-freshness
checks follow in that order. The neutral JSON remains normative, and all three bindings remain filesystem-free at
runtime.

### 2. Exact host API and retained state

The public surface is idiomatic Dart but semantically identical to the admitted servers:

- `McpServer()` constructs a production server with `Random.secure()` and a started `Stopwatch`;
- `registerIndex(SemanticIndex, authorizationContext, options)` validates native capabilities, fixes absolute
  monotonic expiry and effective policy, retains the exact index reference, and returns a generated handle;
- `revokeHandle(handle)` removes a matching entry without externally classifying prior state;
- `dispatch(request, authorizationContext)` returns one decoded JSON-RPC response map or `null` for a
  notification;
- `serveStdio(input, output, authorizationContext, log)` asynchronously runs the exact modern protocol over a
  caller-owned byte stream and borrowed `IOSink` values; and
- `shutdown()` idempotently clears entries and active requests, releasing every retained index reference.

Registry entries retain only the native index, a SHA-256 authorization digest, absolute monotonic expiry, and the
five effective policy scalars. They never retain authorization bytes, source, descriptors, requests, semantic
responses, generated source, paths, or raw failures. Every capabilities call invokes `index.capabilities` afresh;
every permitted query passes the unchanged request to `index.queryNeutral` and returns its detached `toJson()`
value unchanged.

### 3. Entropy, handles, authorization, time, and capacity

Production construction creates one cryptographic `Random.secure()` source. Registration draws exactly 32
uniform bytes with `nextInt(256)` and encodes them through core `base64Url` as exactly 43 unpadded characters.
Unsupported secure entropy, generation failure, or 16 bounded collisions fails closed with a typed sanitized
server error; there is no ordinary `Random`, time/PID/hash-chain seed, or caller-supplied handle fallback.

Authorization contexts are copied nonempty byte lists of at most 4,096 octets. Registration retains only their
existing package-internal SHA-256 digest. Lookup hashes the current context and compares the complete fixed-length
digest with a fixed-work XOR accumulator, using a fixed dummy digest for an unknown handle. This is a fixed-work
source boundary, not a claim that the Dart VM or host process is formally constant-time. Unknown, expired,
revoked, and unauthorized handles remain externally indistinguishable.

A server-local started `Stopwatch` supplies checked integer monotonic milliseconds. Lifetime is 900,000
milliseconds by default and accepts 1 through 86,400,000; use never extends it. Capacity defaults to 1,024 live
handles, expired entries are pruned before refusal, and all shutdown paths clear the registry. A package-internal,
umbrella-unexported test harness may inject deterministic entropy, time, capacity, failure, and emission seams;
the production constructor cannot.

### 4. Strict JSON, generated schema, and canonical bytes

`mcp_wire.dart` scans bytes before `jsonDecode`. One bounded non-recursive tokenizer enforces strict UTF-8, no
BOM, object-only roots, no batches or non-finite numbers, decoded duplicate-key rejection including escape-
equivalent spellings, complete escapes/surrogate pairs, exact JSON number grammar, request-id token kind/range,
and maximum nesting depth 64. Only an admitted frame reaches the stock decoder. Decoded in-process dispatch still
applies the generated frozen schema runtime, so a caller cannot bypass method, metadata, tool-input, or semantic-
request meaning.

Canonical output recursively copies maps with lexicographically sorted string keys, preserves list order and
non-ASCII scalar text, rejects unsupported/non-finite host values, then uses core `jsonEncode`. Semantic text
content contains no newline; every outer stdio frame adds exactly one LF. No map insertion order from native or
generated values becomes wire authority.

### 5. Bounded stdio, cancellation, logs, and cleanup

`serveStdio` consumes `Stream<List<int>>` chunks without assuming chunk boundaries. It retains at most the
1,048,576-byte payload limit plus the possible CR delimiter byte, drains an overlong frame through LF without
growing storage, accepts LF/CRLF and one complete final frame at EOF, and writes exact bytes through `IOSink.add`
plus `flush`. Input, output, and optional log remain caller-owned and are never closed by the server. Output and
log must be distinct objects.

An accepted request id stays active through response preparation and successful flush. Cancellation observed
before emission suppresses the prepared response; cancellation after synchronous completion cannot retract it.
The ordinary single-subscription loop adds no sleep, isolate, thread, signal, async SDK, or timing-dependent
semantic hook. The package-internal harness proves the prepare/cancel/emit boundary deterministically.

Default diagnostics are zero bytes. An optional distinct log sink receives only fixed UTF-8 operational event
codes—never handles, authorization, source/request/response content, logical identity, paths, host objects, or raw
exceptions. Graceful EOF flushes, shuts down, releases the registry, and completes normally. Input/output/flush
failure performs the same cleanup and throws one typed sanitized stream error after at most one fixed log event.

### 6. Dispatch, policy, failures, and authority fences

Only `server/discover`, `tools/list`, `tools/call`, and `notifications/cancelled` exist. Static values come from the
embedded binding. Capabilities applies only the contract-defined schema-preserving lowering projection. An above-
policy query fails before native dispatch; an allowed request reaches `queryNeutral` unchanged. Native and
response-building failures become fixed `-32603` responses with no raw `Error`, stack, source, path, request,
handle, or host detail.

Production owners may not import or call source loaders, parsers, compilers, runtime engines, trace sinks,
generated-source emitters, primary CLI entrypoints, process spawning, sockets, HTTP, SDK clients, or filesystem
APIs. The existing parser-oriented `dart/bin/linkedspec_dart.dart` and CLI modules gain no MCP bootstrap or mode.

### 7. Dependency order and admission

Dart work is dependency-ordered:

1. `.10.9.4.1` adds the Dart generated binding, frozen contract runtime, secure registry, decoded dispatch,
   policy, sanitized failure boundary, and focused public proof;
2. `.10.9.4.2` adds strict wire/framing, canonical emission, prepared cancellation, optional diagnostics, EOF/I/O
   cleanup, and focused stdio proof;
3. `.10.9.4.3` adds one exact twelve-role Dart consumer, advances only Dart to 3/5 implementations and 3/6 runtime
   admissions, extends independent mutations/canonical ordering, and leaves shared rollout pending; and
4. `.10.9.4.4` recomposes unchanged owners, closes Dart, and hands the contract to Julia.

There is no standalone MCP executable, source/path bootstrap, semantic cache, primary-CLI mode, SDK, network
transport, aggregator, or legacy protocol adapter.

## Consequences

- `.10.9.4.1` realizes the first three private owners and the supported decoded host surface exactly as decided:
  the generated part is 82,875 bytes, the package remains dependency-free, and focused proof passes all ten
  binding/runtime/registry/dispatch/security cases plus the complete 347-test Dart package.
- Dart receives a genuine same-runtime server around native immutable indexes, not a Perl/Rust shim or subprocess.
- Core Dart facilities satisfy entropy, time, base64url, UTF-8, JSON decoding, SHA-256, and stdio needs without a
  production package dependency; strictness and canonical ordering remain explicit LinkedSpec owners.
- Generated data prevents contract copying, while the lexical preflight closes stock decoder duplicate-key,
  depth, numeric, and identity ambiguities.
- Asynchronous Dart stream mechanics do not broaden MCP into an SDK/network/actor architecture or add semantic
  concurrency.
- Exact implementation/runtime admission remains separate from production behavior: the ledger intentionally
  remains 2/5 implementations and 2/6 runtimes until `.10.9.4.3`, and shared rollout cannot promote before Julia
  and both Lua runtimes pass.

## Links

- Neutral semantic boundary: ADR `0049`
- Native server topology: ADR `0054`
- Exact protocol/transport: ADR `0055`
- Native embedding: ADR `0022`
- Perl implementation precedent: ADR `0057`
- Rust implementation precedent: ADR `0058`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9.4.0-.4`)

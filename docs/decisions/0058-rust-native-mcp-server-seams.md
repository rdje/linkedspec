# ADR 0058: Rust MCP uses a generated contract binding and an in-process runtime server

- Date: 2026-07-29
- Status: accepted; generated binding/decoded server `.10.9.3.1`, strict stdio/lifecycle `.10.9.3.2`, and exact
  admission `.10.9.3.3` implemented at 2/5 + 2/6 with rollout pending; no-change closeout `.10.9.3.4` pending
- Tags: architecture, mcp, rust, embedding, handles, authorization, json, stdio, security, portability

## Context

ADRs `0049`, `0054`, and `0055` require Rust to implement the same thin MCP contract as Perl without importing
Perl objects or creating a shared multi-runtime process. The native authority already exists in
`linkedspec_runtime::semantic_index::SemanticIndex`: callers construct an immutable index from decoded text or
strict UTF-8 bytes, and public `capabilities()` plus `query_neutral(&serde_json::Value)` return clone-safe neutral
responses without filesystem, executor, trace, generated-source, or primary-CLI authority. Focused audit proof
passes foundation 6/6, query 5/5, and the existing twelve-role native admission 1/1 in 82.34 seconds.

The Rust host inventory establishes additional implementation boundaries:

- `linkedspec-runtime` is the native embedding crate; `linkedspec-rust` is only the existing parser-oriented
  primary CLI and must not gain MCP behavior;
- `serde_json 1.0.150` is already a direct runtime dependency with default map ordering, but its `Value` visitor
  inserts repeated keys into a map and therefore overwrites rather than rejects duplicates;
- canonical semantic digests already use `serde_json::to_value` followed by `to_vec`, which sorts object keys
  through the default `serde_json::Map` representation and preserves ordered arrays;
- `sha2 0.11.0` is already direct, while `getrandom 0.4.2` is present in the locked repository-local dependency
  graph transitively and exposes the operating-system `fill` API; and
- at the `.10.9.3.0` audit, no Rust MCP module, registry, strict wire owner, SDK, async runtime, network transport,
  or server executable existed.

Reading the neutral contract at runtime would violate the in-memory embedding boundary. Hand-copying its schema,
templates, and limits would create a second owner. Reusing `serde_json::from_slice` alone would admit duplicate
keys and leave the exact 64-level/number/id boundary to library behavior rather than the shared contract.

## Decision

### 1. Public embedding and private owner topology

The Rust implementation lives in `linkedspec-runtime` and exposes one public native `McpServer` surface through
the crate library. The host creates an `Arc<SemanticIndex>`, registers that exact immutable value with an
out-of-band authorization context and lowering-only policy, then uses decoded dispatch or caller-provided stdio
handles in the same process.

Four source owners keep authority narrow:

1. `mcp_contract.rs` is deterministic generated data containing one canonical embedded bundle and digest. It has
   no I/O and no semantic logic.
2. `mcp_contract_runtime.rs` parses the embedded bundle once, deep-clones public values, evaluates only the frozen
   JSON Schema profile, validates exact named frames, and builds Rust-identity response/error shells.
3. `mcp_server.rs` owns the public server, typed registration/policy/error values, secure registry, decoded
   discovery/list/two-tool/cancellation dispatch, native identity, policy, and panic sanitation.
4. `mcp_wire.rs` owns bounded streaming, strict UTF-8/JSON token preflight, canonical LF encoding, prepared
   response emission/cancellation, optional sanitized diagnostics, EOF, and I/O cleanup.

`tools/mcp_contract_binding.py` will hold the language-neutral verified-bundle construction currently embedded in
the Perl generator. `tools/generate_perl_mcp_contract.py` becomes a thin unchanged-output consumer of that owner,
and new `tools/generate_rust_mcp_contract.py` deterministically renders `mcp_contract.rs`. Both checks run after
the neutral materializer and independent validator. The refactor must prove the committed Perl binding remains
byte-identical.

### 2. Exact Rust host API and retained state

The public API is idiomatic but semantically identical to Perl:

- `McpServer::new()` constructs a production server with operating-system entropy and a monotonic clock;
- `register_index(Arc<SemanticIndex>, authorization_context, options)` validates the native capabilities response,
  fixes expiry and effective policy, and returns a generated handle;
- `revoke_handle(handle)` removes any matching entry without externally classifying prior state;
- `dispatch(&serde_json::Value, authorization_context)` returns one decoded response or no response for a
  notification;
- `serve_stdio(input, output, authorization_context, optional_log)` runs the exact modern stream over borrowed
  caller-owned handles; and
- `shutdown()` idempotently clears entries and active requests, releasing every `Arc<SemanticIndex>`.

Registry entries retain only the native `Arc`, a `[u8; 32]` SHA-256 authorization digest, absolute monotonic
expiry, and the five effective policy components. They never retain authorization bytes, source, descriptors,
requests, semantic responses, generated source, paths, or host diagnostics. Every capabilities request calls
`SemanticIndex::capabilities()` afresh; every permitted query calls `query_neutral` with the unchanged request.

### 3. Entropy, handles, authorization, time, and capacity

Production registration calls direct dependency `getrandom 0.4.2` to fill exactly 32 bytes from the operating
system CSPRNG. A small private fixed-input encoder maps those 32 bytes to exactly 43 unpadded base64url characters;
it has exhaustive known-vector/length/alphabet tests and avoids adding an otherwise-unused general base64 package.
Entropy failure and 16 bounded collisions fail closed with a typed sanitized server error; there is no PRNG,
time, PID, hash-chain, or caller-handle fallback.

Authorization contexts are nonempty byte slices of at most 4,096 octets. Registration stores only SHA-256; every
lookup compares exactly 32 bytes with a fixed-work XOR accumulator and a dummy digest for unknown handles. This is
a fixed-work code boundary, not a formal constant-time claim for the whole optimizer/process. Unknown, expired,
revoked, and unauthorized states remain externally identical.

Production monotonic time is derived from a server-local `std::time::Instant` origin and checked integer
milliseconds. Private unit-test dependencies inject entropy, time, capacity, and collision bounds; production API
cannot inject them. The registry defaults to 1,024 live handles, prunes expiry before refusal, uses no sliding
expiry, accepts 1 through 86,400,000 milliseconds, and defaults to 900,000.

### 4. Strict JSON, canonical bytes, and bounded streaming

`mcp_wire.rs` reads through `std::io::Read` into a fixed 65,536-byte chunk and retains at most the contract payload
limit plus a possible CR while draining an overlong line to LF. It accepts LF/CRLF and a complete final frame at
EOF. Before `serde_json` value construction, one bounded recursive token preflight enforces strict UTF-8, no BOM,
object-only roots, no batches/non-finite values, decoded duplicate-key rejection, complete string escapes and
surrogate pairs, exact JSON number grammar, request-id token kind/range, and maximum nesting depth 64.

Decoded requests then pass the generated frozen schema runtime in ADR `0055`'s required validation order.
Canonical output first converts typed native responses to `serde_json::Value`, then serializes the default
sorted-key map representation with preserved arrays, non-ASCII UTF-8, no insignificant whitespace/non-finite
values, and exactly one outer LF. Semantic text content has no LF.

### 5. Dispatch, panic boundary, cancellation, logs, and shutdown

The implementation exposes only `server/discover`, `tools/list`, `tools/call`, and
`notifications/cancelled`. Static values come from the embedded binding. Capabilities receives only the exact
lowering projection; an above-policy query fails before native dispatch; an allowed query passes unchanged.

Native and response-building calls execute inside `catch_unwind(AssertUnwindSafe(...))` so ordinary unwind panics
become fixed `-32603` responses without raw panic text. This does not claim recovery from `panic=abort`, process
termination, or undefined behavior. Normal typed semantic failures remain native response content.

An active request persists from accepted id through successful response flush. Cancellation observed before
emission suppresses it; after emission it cannot retract bytes. The synchronous reader is not made artificially
concurrent and gains no sleeps, threads, signals, async executor, or timing hooks. Default diagnostics are empty.
An optional distinct borrowed writer receives fixed UTF-8 event codes only—never handles, authorization, source,
logical identity, request/response content, paths, host objects, or raw errors. EOF and I/O failure both clear the
registry; the former returns success and the latter a typed error that a process host may map to nonzero status.

### 6. Dependency order and admission

Rust work is dependency-ordered:

1. `.10.9.3.1` adds shared binding generation, the Rust embedded binding/runtime, registry, decoded dispatch,
   policy, panic sanitation, and focused proof;
2. `.10.9.3.2` adds strict wire/framing, prepared cancellation, optional diagnostics, EOF/I/O cleanup, and focused
   stdio proof;
3. `.10.9.3.3` adds one exact twelve-role Rust consumer, advances only Rust to 2/5 implementations + 2/6 runtime
   admissions, expands mutation/canonical-order locks, and leaves shared rollout pending; and
4. `.10.9.3.4` recomposes unchanged owners, closes Rust, and hands the contract to Dart.

There is no new standalone binary, primary-CLI mode, SDK, network dependency, source bootstrap, aggregator, or
legacy protocol adapter. A future process wrapper still requires ADR `0054`'s separately authorized index
bootstrap and its own task-tree.

## Consequences

- Rust owns a genuine in-process server around native index objects rather than a Perl shim or subprocess IPC.
- Shared verified-bundle construction removes cross-generator drift while leaving neutral artifacts normative and
  both generated bindings filesystem-free at runtime.
- `serde_json` remains the value constructor/encoder, while strict duplicate/depth/number admission is explicit.
- One already-locked OS-entropy package becomes a direct runtime dependency; no async, network, SDK, or base64
  dependency is introduced.
- Public server behavior cannot parse/load source, compile, execute, trace, inspect host state, cache semantics, or
  alter the parser-oriented primary CLI.

## Links

- Neutral semantic boundary: ADR `0049`
- Native server topology: ADR `0054`
- Exact protocol/transport: ADR `0055`
- Native embedding: ADR `0022`
- Perl implementation precedent: ADR `0057`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9.3.0-.4`)

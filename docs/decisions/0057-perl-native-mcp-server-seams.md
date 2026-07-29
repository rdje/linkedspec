# ADR 0057: Perl MCP uses an embedded derived contract and an in-process native server

- Date: 2026-07-29
- Status: accepted; implementation `.10.9.2.1-.2` and exact admission `.10.9.2.3` complete with canonical signoff;
  no-change closeout `.10.9.2.4` pending
- Tags: architecture, mcp, perl, embedding, handles, authorization, json, stdio, security, portability

## Context

ADRs `0049`, `0054`, and `0055` require the Perl implementation to remain a thin in-process adapter over an
already-created immutable `LinkedSpec::SemanticIndex`. The exact neutral transport artifacts are complete and
canonical, but no Perl server, server API, native transport binding, or admission owner exists yet.

The behavior-free `.10.9.2.0` audit measured the existing native boundary with LinkedSpec's own tools. The
`graph.spec` descriptor contains two native coderefs and five compiled regex objects, so it cannot be a transport
payload. The opaque `LinkedSpec::SemanticIndex` instead exposes clone-safe `capabilities` and `query` methods over
plain data. Their canonical response SHA-256 values are exactly
`a5f759dc8a5d060a36f86d35d5a86ff8b6745ef87cbe03d2c8b5a3200ddfd141` and
`b8872b7340d2d6f4aaa409745fe0083bc744a594e09a05ed5b9786446594df0b` for the admitted capabilities and graph-list
queries. Neither encoded payload contains a newline.

The host/runtime audit also found boundaries that cannot be left implicit:

- the installed core `JSON::PP 4.06` has canonical UTF-8 encoding, depth limits, and bignum decoding, but accepts
  both literal duplicate keys and escape-equivalent duplicates such as `"a"` plus `"\u0061"`;
- neither `Crypt::URandom` nor `Sys::GetRandom` is available, so silently depending on a mutable global package or
  falling back to a PRNG would violate the 256-bit CSPRNG contract;
- core `Time::HiRes` provides `CLOCK_MONOTONIC`, and core `MIME::Base64` can support the exact unpadded base64url
  representation; and
- no existing Perl server, stream, registry, authorization, cancellation, or MCP-specific error owner can be
  safely reused.

The server also cannot read the neutral JSON files at runtime: that would add filesystem authority to a transport
whose embedding must work entirely in memory. Hand-copying titles, schemas, templates, and limits into production
code would create a second contract owner.

## Decision

### 1. Public embedding and private owner topology

The Perl implementation has one public native class, `LinkedSpec::MCPServer`. It is imported directly and is not
added to the primary `LinkedSpec` facade or parser CLI. The host constructs its semantic index with the existing
`LinkedSpec::semantic_index(...)`, constructs a server, registers that exact object, and either dispatches decoded
requests in process or serves caller-provided stdio-compatible handles in the same process.

Three private owners keep authority explicit:

1. `LinkedSpec::MCPContract` is deterministic generated data derived from the exact neutral manifest/schema/
   canonical corpus. It contains no I/O and no semantic logic.
2. `LinkedSpec::MCPContractRuntime` deep-clones the embedded data, validates only the frozen schema profile, and
   builds exact Perl-identity discovery/list/result/error values. It cannot parse source or call an index.
3. `LinkedSpec::MCPWire` owns strict UTF-8 JSON-line framing, canonical encoding, response emission, cancellation
   at the prepared-response boundary, optional sanitized stderr records, EOF cleanup, and I/O status.

`tools/generate_perl_mcp_contract.py` will be the reproducible derived-binding owner. Its check mode must prove the
committed Perl data module is byte-fresh from the unchanged neutral artifacts. Canonical CI runs the neutral
materializer/independent validator first, then the Perl binding check. The generated module is a consumer, never a
normative replacement.

### 2. Exact host API and registry state

The public API is deliberately small:

- `LinkedSpec::MCPServer->new()` creates a production server with OS entropy and monotonic time;
- `$server->register_index($index, authorization_context => ..., lifetime_ms => ..., policy => ...)` accepts only
  a live `LinkedSpec::SemanticIndex`, requires one nonempty opaque byte-string authorization context of at most
  4,096 octets, applies the exact
  lifetime and lowering-only policy schema, and returns a generated handle;
- `$server->revoke_handle($handle)` revokes without classifying the handle externally;
- `$server->dispatch($request, authorization_context => ...)` handles one already-decoded request without I/O;
- `$server->serve_stdio(input => ..., output => ..., authorization_context => ..., log => ...)` runs the exact
  modern stream over caller-provided handles; and
- `$server->shutdown()` idempotently clears all entries and releases index references.

The authorization context is out-of-band host data, never clientInfo and never serialized or logged. A structured
principal must be serialized by the host before registration; the server does not invent a second identity model.
Registration stores only its SHA-256 digest, not the supplied bytes. Every tool call hashes the current host
context and compares exactly 32 bytes with a branch-free XOR accumulator; an unknown handle uses a fixed dummy
digest so it follows the same comparison step. This is a fixed-work comparison boundary, not a claim that the Perl
interpreter or host process is a formally constant-time environment. Unknown, expired, revoked, and unauthorized
states take the same externally observable error path. A stream has one caller-supplied context; multi-principal
routing belongs in its host, not MCP metadata.

Registration calls the immutable index's capabilities operation once to validate compatibility and retain only
the five native limit scalars needed for pre-dispatch policy enforcement. It does not retain a semantic response.
Every capabilities tool call still calls native `capabilities` first; every allowed query calls native `query`
unchanged. This policy metadata is registry state, not a semantic cache.

The production registry uses a fixed default maximum of 1,024 live handles, prunes expired entries before a
capacity refusal, never extends expiry on use, and clears on all shutdown paths. Lifetime is 900,000 milliseconds
by default and must be an integer from 1 through 86,400,000.

### 3. Entropy, time, and test dependencies fail closed

Production handle generation reads exactly 32 bytes from the operating-system CSPRNG at `/dev/urandom` through an
EINTR-safe raw loop, encodes them as exactly 43 unpadded base64url characters, and retries on collision. This is a
strictly necessary read-only operating-system dependency, not project data. If the device cannot supply all bytes,
construction or registration fails with a typed sanitized server error; there is no time/PID/hash/`rand` fallback.

Expiry uses `Time::HiRes::clock_gettime(CLOCK_MONOTONIC)` converted to integer milliseconds. Wall time is never an
authority. A private explicitly named test constructor may inject deterministic 32-byte entropy and monotonic
clock callbacks. The production constructor accepts neither dependency, so test determinism cannot become a
deployment option accidentally.

### 4. Strict JSON and schema ownership

`LinkedSpec::MCPWire` performs a byte preflight before `JSON::PP`:

- exact LF/CRLF framing and the 1,048,576-byte payload limit;
- strict UTF-8, no BOM, no batches/non-object roots, no non-finite values, and maximum nesting depth 64;
- duplicate-key rejection after JSON string unescaping, including escape-equivalent keys; and
- numeric token preservation sufficient to distinguish integer ids from `1.0`, exponent forms, booleans, unsafe
  integers, and out-of-range values.

The wire then uses `JSON::PP` with bignum decoding and the embedded schema runtime. JSON-RPC envelope, metadata,
method, tool-input, semantic-request shape, and output validation follow ADR `0055`'s exact order. Canonical output
uses UTF-8, lexicographically sorted keys, preserved arrays, non-ASCII text, no insignificant whitespace, no
non-finite values, and exactly one outer LF.

The server never imports a mutable SDK, reads a schema path, or accepts a looser host-decoded value on the stdio
route. The in-process decoded dispatch applies the same schema runtime, so it cannot bypass transport meaning.

### 5. Dispatch, policy, errors, cancellation, and logs

The server implements only `server/discover`, `tools/list`, `tools/call`, and `notifications/cancelled`. Static
responses come from the embedded derived contract. `linkedspec_semantic_capabilities` invokes native capabilities
and applies only the exact schema-preserving lowering projection. `linkedspec_semantic_query` rejects an
above-policy request before query dispatch or passes the original request unchanged. Native responses are checked
against the frozen output schema before canonical emission; unexpected host/native failures become sanitized
`-32603` errors.

Decoded dispatch separates response preparation from emission. A request remains active until its prepared frame
is emitted; cancellation observed in that interval suppresses it. The ordinary Perl stream is synchronous, so a
native call completed before the reader can observe a later notification completes normally, as ADR `0055`
requires. No sleep, thread, signal, or timing hook is invented.

The default is zero stderr bytes. Optional logging accepts only a caller-provided stderr-like handle distinct from
the MCP output and emits fixed event codes with no handle, source/request/response content, logical identity,
authorization, path, host identity, or raw exception. EOF flushes complete frames, clears the registry, and
returns zero; I/O failure performs the same cleanup and returns nonzero with at most one sanitized log record.

### 6. Implementation and admission order

Perl work is dependency-ordered:

1. `.10.9.2.1` adds the derived binding, schema runtime, registry, decoded dispatch, policy, and focused proof;
2. `.10.9.2.2` adds strict wire/framing, prepared-response cancellation, logs, EOF, and focused stdio proof;
3. `.10.9.2.3` adds one exact Perl admission consumer plus a shared MCP implementation/admission ledger and
   checker, while leaving semantic rollout `thin_mcp_transport` pending until all six runtimes pass; and
4. `.10.9.2.4` recomposes unchanged owners, closes Perl, and hands off to Rust.

The future admission ledger is separate from the normative transport bundle. It records five implementation and
six runtime statuses/consumers without changing transport meaning or prematurely promoting the semantic rollout.

## Consequences

- The Perl server is a genuine native in-process server, not a subprocess shim or a path-loading executable.
- Exact static bytes are generated from one neutral contract while runtime behavior remains filesystem-free.
- Duplicate JSON keys, weak entropy, wall-clock expiry, clientInfo authorization, and stale generated schemas are
  closed before implementation rather than discovered during cross-backend admission.
- The additional private modules are authority boundaries, not new public products; the only new public type is
  `LinkedSpec::MCPServer`.
- No source parsing, compilation, execution, trace, semantic caching, primary CLI, or aggregator authority moves
  into MCP.

## Links

- Neutral semantic boundary: ADR `0049`
- Native server topology: ADR `0054`
- Exact protocol/transport: ADR `0055`
- Native embedding: ADR `0022`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9.2.0-.4`)

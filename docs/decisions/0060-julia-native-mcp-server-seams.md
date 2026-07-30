# ADR 0060: Julia MCP uses a generated contract module and a synchronous in-process server

- Date: 2026-07-29
- Status: accepted and complete; `.10.9.5.0-.4` plan, decoded implementation, strict stdio, exact admission, and
  no-change closeout complete
- Tags: architecture, mcp, julia, embedding, handles, authorization, json, stdio, security, portability

## Context

ADRs `0049`, `0054`, and `0055` require Julia to implement the same thin MCP contract as Perl, Rust, and Dart
without borrowing any of their runtimes. The admitted Julia package already exposes one opaque immutable
`SemanticIndex`, `semantic_capabilities(index)`, typed `semantic_query(index, request)`, and raw-neutral
`semantic_query_neutral(index, request)`. Their detached `to_json` results are the complete semantic authority
needed by MCP. None of those calls reads a path, parses new source, executes a parser, enables trace, installs a
runtime-observation sink, emits generated source, or invokes the primary CLI.

A repository-routed Julia 1.12.6 / JSON3 1.14.3 audit establishes the implementation-specific constraints:

- `julia/Project.toml` already declares JSON3 and SHA, while Base64 and Random are Julia standard libraries whose
  UUIDs can be declared explicitly without adding a third-party package;
- `RandomDevice()` obtains entropy from the operating system, `time_ns()` is documented monotonic modulo `2^64`
  and unaffected by wall-clock changes, and 32 random bytes encode to exactly 43 unpadded base64url characters;
- JSON3 retains literal and escape-equivalent duplicate keys in its lazy object, but ordinary normalization keeps
  only the last value; it also accepts an invalid-UTF-8 Julia `String` and normalizes JSON number tokens `1.0` and
  `1e0` to an integer under ordinary decoding;
- the primary CLI has a correct private recursively sorted JSON writer, but MCP must not depend on a CLI include,
  mode, or bootstrap path; and
- caller-owned Julia `IO` objects support bounded byte reads, exact writes, and flush without requiring an async
  runtime, network stack, MCP SDK, or standalone executable.

Therefore JSON3 is a value codec only after strict byte/token admission. Julia also needs to retain raw number
kind while converting the admitted tree so JSON Schema `integer` meaning is not weakened by codec normalization.
The contract bundle must be generated, digest-verified, and filesystem-free at runtime rather than copied into
Julia source by hand.

## Decision

### 1. Package ownership and file topology

The implementation remains inside the existing `LinkedSpecJulia` module. Four files under `julia/src/mcp/` own
one native server without a nested package or subprocess:

1. `McpContract.jl` is deterministic generated data containing binding format, decoded-bundle SHA-256, and one
   Base64 representation of the canonical verified bundle.
2. `McpContractRuntime.jl` verifies and decodes that bundle once, deep-copies public values, evaluates only the
   frozen schema profile, creates Julia-identity response/error shells, and owns MCP canonical JSON.
3. `McpServer.jl` owns the public value types and server, secure registry, decoded discovery/list/two-tool/
   cancellation dispatch, native identity, lowering-only policy, fixed-work authorization comparison, and
   sanitized failures.
4. `McpWire.jl` owns bounded synchronous framing, strict UTF-8/JSON lexical admission, exact numeric conversion,
   canonical LF emission, cancellation through flush, optional fixed diagnostics, EOF, I/O cleanup, and registry
   release.

`tools/generate_julia_mcp_contract.py` reuses `tools/mcp_contract_binding.py` after neutral materialization and
independent validation. It emits only Base64 alphabet data because Julia raw strings are not byte-transparent for
JSON quote escapes. Runtime decoding verifies the canonical JSON SHA-256 before JSON3 sees it. The neutral JSON
artifacts remain normative; Perl, Rust, Dart, and Julia generated files must all be byte-fresh in canonical order.

### 2. Public Julia embedding surface

The module exports `McpBudgetLimits`, `McpDeploymentPolicy`, `McpRegistrationOptions`, `McpServer`, and
`McpServerError`, plus these Julia-style operations:

- `McpServer()` constructs a production server from OS entropy and a server-local monotonic clock origin;
- `register_index!(server, index, authorization_context; options=McpRegistrationOptions())` validates fresh
  native capabilities, fixes absolute expiry/effective policy, retains the exact index, and returns a handle;
- `revoke_handle!(server, handle)` removes a syntactically valid handle without classifying its prior state;
- `dispatch_mcp(server, request, authorization_context)` accepts an already-decoded JSON-like request and returns
  one detached JSON-RPC dictionary or `nothing` for a notification;
- `serve_mcp_stdio!(server, input, output, authorization_context; log=nothing)` runs exact modern MCP over
  caller-owned borrowed `IO` values; and
- `shutdown_mcp!(server)` idempotently clears registry and active-request state.

Registration accepts only an existing `SemanticIndex`; MCP cannot create one. Every capabilities call invokes
`semantic_capabilities` afresh, every permitted query passes an unchanged detached request to
`semantic_query_neutral`, and both responses pass through `to_json` without semantic reinterpretation or caching.

### 3. Retained state, entropy, authorization, time, and policy

A registry entry retains only the native index, a 32-byte SHA-256 authorization digest, checked absolute
monotonic expiry, and five effective policy scalars. It never retains authorization bytes, source, paths,
descriptors, requests, semantic responses, generated source, trace, runtime events, or raw failures.

Production registration draws exactly 32 bytes from one `Random.RandomDevice`, maps standard Base64 to the URL
alphabet, removes padding, verifies the exact 43-character grammar, and retries at most 16 collisions. Entropy
construction/read failure, malformed output, or collision exhaustion fails closed with a typed sanitized error;
there is no default RNG, wall-clock, PID, hash-chain, or caller-supplied-handle fallback.

Authorization accepts copied nonempty `AbstractVector{UInt8}` input of at most 4,096 bytes. Only SHA-256 is
retained. Lookup always hashes the supplied context and compares all 32 bytes with an XOR/OR accumulator, using a
fixed dummy digest for a missing handle before expiry/revocation state is resolved. This is a fixed-work source
boundary, not a formal VM-level constant-time claim. Unknown, expired, revoked, and unauthorized handles remain
externally indistinguishable.

The production clock is elapsed milliseconds derived from `time_ns()` relative to construction, with checked
integer conversion. Default lifetime is 900,000 milliseconds, accepted lifetime is 1 through 86,400,000,
capacity defaults to 1,024, and expired entries are pruned before capacity refusal. Optional deployment policy
may lower only source detail/content-digest availability, page maximum/default, and three query budget maxima.
It cannot elevate native capability. A private unexported test constructor may inject entropy, time, capacity,
native failure, and pre-emission hooks; the production constructor cannot.

### 4. Decoded values, frozen schema, and canonical JSON

Decoded dispatch recursively copies only valid JSON-like values: `nothing`, `Bool`, valid UTF-8 strings, finite
numbers, vectors/tuples, and dictionaries with unique string or symbol keys that normalize uniquely to strings.
It rejects cycles, excessive host nesting, unsupported values, invalid strings, and Boolean-as-integer ambiguity.
The generated runtime independently implements only the contract's frozen JSON Schema keyword profile.

Canonical output recursively sorts string keys lexicographically, preserves array order and non-ASCII scalar
text, rejects invalid/non-finite/unsupported values, and delegates only scalar escaping/number spelling to JSON3.
The MCP owner does not call the primary CLI's private canonicalizer. Semantic text content has no line break, and
the wire appends exactly one LF to the outer canonical JSON-RPC frame.

### 5. Strict wire decoding and Julia number preservation

`McpWire.jl` reads bytes into a bounded frame buffer and performs an iterative lexical pass before decoding. It
enforces strict UTF-8, no BOM, exact JSON grammar and escapes/surrogate pairs, decoded duplicate-key rejection
including escape-equivalent spellings, root/depth limits, finite numbers, object-only/no-batch requests, and exact
request-id token type, UTF-8 byte size, and safe-integer range.

The scanner records every number token in depth-first value order. JSON3 then decodes the admitted value with
`numbertype=Float64`; one recursive converter consumes the recorded tokens, reconstructing integral lexemes as
exact integers and retaining fractional/exponent lexemes as floats. This closes JSON3's `1.0`/`1e0` coercion
without writing a second semantic/schema model. Tests must prove token/tree cardinality, large/safe integers,
negative zero, fractions, exponents, duplicate spellings, malformed UTF-8, depth, and all ten neutral raw cases.

### 6. Synchronous stdio, cancellation, diagnostics, and cleanup

`serve_mcp_stdio!` uses bounded `readbytes!` chunks and does not assume transport chunk boundaries. It retains at
most the 1,048,576-byte payload plus a possible CR byte, drains overlong frames through LF without growing the
buffer, accepts LF/CRLF and one complete final frame at EOF, and writes/flushes exact canonical bytes. Input,
output, and log objects remain caller-owned and are never closed. Output and log must be distinct.

An accepted request id remains active through response preparation and successful flush. Cancellation observed
through the deterministic pre-emission boundary suppresses the prepared response; cancellation after synchronous
completion cannot retract an emitted frame. No task, thread, channel, signal handler, sleep, SDK, or timing-based
semantic callback is introduced.

Default diagnostics are zero bytes. An optional log receives at most one fixed UTF-8 event after an unexpected
read/write/flush failure and never receives handles, authorization, source/request/response content, logical
identity, paths, host objects, stack traces, or raw exceptions. Graceful EOF flushes, shuts down, releases every
index, and returns normally. I/O failure performs the same cleanup and throws one typed sanitized stream error.

### 7. Authority fences, dependency order, and admission

Production MCP files may not call source loaders, parsers, validators, compilers, runtime engines, trace owners,
observation sinks, generated-source emitters, CLI entrypoints, environment lookup, filesystem/process/network
APIs, or MCP SDKs. The existing primary CLI gains no MCP mode or bootstrap. Base64 and Random are added only as
explicit Julia standard-library dependencies; no third-party dependency is added.

The implementation order is omission-safe:

1. `.10.9.5.1` adds generated binding/runtime, public decoded server, secure registry, policy, and focused proof;
2. `.10.9.5.2` adds strict wire/framing, canonical emission, cancellation, diagnostics, and lifecycle proof;
3. `.10.9.5.3` adds one exact ordered twelve-role Julia consumer, advances only Julia to 4/5 implementations and
   4/6 runtime admissions, extends independent mutations/canonical order, and leaves shared rollout pending; and
4. `.10.9.5.4` recomposes unchanged committed owners, closes Julia, and hands the contract to shared Lua.

There is no standalone MCP executable, source/path bootstrap, semantic cache, primary-CLI mode, async/network
transport, aggregator, or legacy adapter.

## Consequences

- Julia receives a genuine same-runtime server around its admitted immutable index, not a Perl/Rust/Dart shim or
  subprocess.
- Generated Base64 data avoids runtime artifact reads and Julia string-literal corruption while preserving one
  normative bundle and digest.
- Explicit lexical evidence closes Julia-specific duplicate-key, invalid-UTF-8, and number-kind gaps before JSON3
  becomes a value converter.
- Julia standard libraries satisfy entropy, time, Base64, SHA-256, and borrowed-I/O needs; the package adds no
  third-party production dependency.
- `.10.9.5.1-.2` implement generated/runtime/decoded behavior and strict synchronous stdio without source/path,
  semantic, async, network, or primary-CLI authority. Exact `.10.9.5.3` composes those owners through one ordered
  twelve-role external consumer and advances only Julia to 4/5 implementations plus 4/6 runtimes; rollout remains
  pending for Lua's two ABI admissions. No-change `.10.9.5.4` recomposes the committed owners and closes the Julia
  parent without changing that status or adding another oracle.

## Links

- Neutral semantic boundary: ADR `0049`
- Native server topology: ADR `0054`
- Exact protocol/transport: ADR `0055`
- Native embedding: ADR `0022`
- Perl/Rust/Dart precedents: ADRs `0057`, `0058`, and `0059`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9.5.0-.4`)

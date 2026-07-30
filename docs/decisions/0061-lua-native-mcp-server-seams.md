# ADR 0061: Lua MCP uses one literal contract binding and one dual-ABI in-process server

- Date: 2026-07-29
- Status: accepted; plan, decoded implementation, strict wire, exact dual-ABI admission, and no-change parent
  closeout complete under `.10.9.6.0-.4`
- Tags: architecture, mcp, lua, luajit, embedding, handles, authorization, json, stdio, security, portability

## Context

ADRs `0049`, `0054`, and `0055` require one final native MCP implementation in Lua. It must retain an existing
opaque immutable semantic index in the process that created it, call only `capabilities()` and `query_neutral()`,
and run from the same Lua-5.1-compatible source on PUC Lua 5.4 and LuaJIT. The ABI rows are independent runtime
admissions, not separate implementations.

The admitted Lua backend already provides the necessary semantic and data foundations: protected semantic-index
values, detached neutral query responses, strict pure-Lua JSON with explicit object/array/null kinds, canonical
encoding, strict UTF-8 validation, and a dependency-free SHA-256 implementation. It has no LuaRocks dependency.
Its native PCRE2 and filesystem modules are compiled separately for PUC Lua and LuaJIT from common C sources by
`tools/build_lua_native.sh` into repository-volume managed scratch.

Repository-routed probes on PUC Lua 5.4.8 and LuaJIT 2.1 established the remaining implementation constraints:

- the existing JSON decoder rejects literal and escape-equivalent duplicate keys and invalid UTF-8, and its
  encoder reproduces the exact 82,543-byte canonical MCP bundle on both ABIs;
- PUC Lua distinguishes integer and float values internally, but canonical encoding normalizes integral floats,
  while LuaJIT collapses all three JSON spellings `1`, `1.0`, and `1e0`; decoded values therefore cannot be the
  authority for JSON number-token kind or request-id validity;
- the canonical bundle contains no `]]`, and a Lua long-bracket literal can preserve it exactly without Base64;
  a generator still has to select the least delimiter level whose closing token is absent from arbitrary future
  bundle bytes;
- the existing pure-Lua SHA-256 hashes the complete bundle in about 1.19 seconds on PUC Lua and 0.10 seconds on
  LuaJIT, which is acceptable for one initialization-time integrity check;
- neither ABI has a suitable installed socket, POSIX, OpenSSL, JSON, or asynchronous transport module. Direct
  `/dev/urandom` reads work on the measured host but would add unnecessary filesystem authority and weak portable
  failure semantics;
- one common C99 probe, compiled once per Lua ABI, obtains 32 OS-random bytes and monotonic milliseconds using
  only the operating-system C library. On Darwin the two 50,624-byte ABI artifacts were byte-identical, depended
  only on `/usr/lib/libSystem.B.dylib`, and exposed no authority beyond the Lua API, `arc4random_buf`, and
  `clock_gettime`;
- caller-owned Lua streams share `read`, `write`, and `flush` on both ABIs. `read(4096)` blocks on an interactive
  pipe until the writer closes, whereas bounded `read(1)` processes a full 1,048,576-byte frame in about 0.096
  seconds on PUC Lua and 0.059 seconds on LuaJIT; and
- a pure-Lua base64url encoder using only values below `2^24` maps bytes `0..31` identically on both ABIs, so
  256-bit handles need no extra native or package dependency after entropy acquisition.

These measurements rule out host-decoded number classification, line-oriented unbounded reads, fixed-size
blocking reads, filesystem entropy, wall-clock expiry, `math.random`, an MCP SDK, and ABI-specific Lua sources.

## Decision

### 1. One source graph, two native loads, two admissions

The production implementation is one Lua-5.1-compatible source graph under `lua/src/linkedspec/`:

1. generated `mcp_contract.lua` contains only binding metadata, the canonical-bundle SHA-256, and the exact
   canonical bundle as a Lua long-bracket string;
2. private `mcp_contract_runtime.lua` verifies the bundle length and digest once, decodes it through the existing
   strict JSON module, validates the frozen schema profile, and returns clone-isolated contract values;
3. `mcp_server.lua` owns protected typed values, the secure same-process registry, decoded dispatch, lowering-only
   policy, cancellation state, native calls, and sanitized failures; and
4. private `mcp_wire.lua` owns untrusted bytes, iterative lexical admission, framing, canonical emission,
   cancellation through flush, optional fixed diagnostics, EOF/I/O cleanup, and borrowed-stream discipline.

`tools/generate_lua_mcp_contract.py` must use the same verified canonical-bundle constructor as the other four
generators. It chooses the smallest nonnegative count of `=` for which the corresponding long-bracket closing
delimiter does not occur in the bundle; it emits the opener immediately before the first bundle byte so Lua's
special initial-newline rule cannot alter the data. Check mode must prove byte freshness.

`lua/native/mcp_system.c` is one additional common C99 source. `tools/build_lua_native.sh` compiles it separately
against each ABI into the same managed native-output directory as the existing modules. The private module exports
only `secure_random_32()` and `monotonic_milliseconds()`. It uses `arc4random_buf` on Darwin/BSD or a complete
EINTR-safe `getrandom` loop on Linux, and `clock_gettime(CLOCK_MONOTONIC)` for time. It fails closed at compile or
runtime on unsupported systems; there is no filesystem, `math.random`, `rand`, wall-clock, process, network, or
weak fallback. Separate ABI binaries are expected deployment artifacts even when their bytes happen to match.

The root Lua package exposes one implementation and one server identity, `linkedspec-semantic-lua`, on both
runtimes. The exact same generated file, Lua source paths, test consumer, and ordered role list must be recorded
for PUC Lua and LuaJIT. ABI-conditional public behavior, source forks, optional security, and a second server
implementation are forbidden.

### 2. Idiomatic protected public API

The root `linkedspec` module will export constructors `mcp_server`, `mcp_budget_limits`,
`mcp_deployment_policy`, and `mcp_registration_options`, plus `is_mcp_server_error` and
`mcp_server_error_to_json`. Constructor inputs are ordinary caller option tables copied immediately; returned
policy/options/error/server values are protected by private metatables and expose no mutable registry fields.

The protected server provides colon methods:

- `server:register_index(index, authorization_context, options)`;
- `server:revoke_handle(handle)`;
- `server:dispatch(request, authorization_context)`;
- `server:serve_stdio(input, output, authorization_context, options)`; and
- `server:shutdown()`.

Registration accepts only an admitted protected Lua semantic index and a nonempty binary Lua string of at most
4,096 bytes as authorization context. Lua strings are immutable and copied by value; the registry retains only
its SHA-256 digest, never the supplied context. Production creates exactly 32 random bytes, encodes exactly 43
unpadded base64url characters, bounds collision attempts and capacity, uses monotonic expiry, and performs a
fixed-work digest comparison. Deterministic entropy, clock, capacity, collision, pre-emission, and native-failure
seams exist only in a package-private test constructor/harness and are not root exports.

The server retains the caller's semantic index without reconstructing it and invokes only `capabilities()` and
`query_neutral()`. It cannot read files, load or compile source, parse, execute, enable trace, derive semantic
facts, retain a second semantic cache, inspect metatables, raise native limits, invoke a primary CLI, or close
caller-owned streams.

### 3. Strict byte wire before value decoding

Decoded `server:dispatch` accepts already-admitted Lua JSON-kind values and may validate integral Lua numbers by
finiteness, `math.floor`, and the safe range. It does not claim lexical identity. The untrusted stdio boundary is
different: `mcp_wire.lua` incrementally reads one byte at a time up to the exact 1,048,576-byte limit, recognizes
LF, CRLF, and final EOF, and uses an iterative depth-64 scanner before `json.decode`.

That scanner is the authority for UTF-8, BOM, string escapes/surrogates, duplicate decoded object keys, root kind,
JSON token grammar, and the lexical distinction among integers and fraction/exponent numbers. It records enough
token-kind information to enforce schema `integer` fields and JSON-RPC ids identically after the host decoder has
collapsed numeric representation. It performs no recursive descent and admits no value before all lexical bounds
pass. The existing strict decoder and canonical encoder remain the value/canonical authorities after admission.

Each response is compact canonical JSON plus exactly one LF and is flushed before its request is considered
emitted. Pre-emission cancellation suppresses output; cancellation after a successful flush is too late. EOF and
every read/write/flush failure release indexes and active requests, never close input/output/log streams, and
surface only the fixed sanitized operational diagnostic permitted by ADR `0055`. The implementation is
synchronous and dependency-free: no coroutine scheduler, thread, socket, HTTP, SDK, subprocess, source bootstrap,
or standalone executable is introduced.

### 4. Ordered implementation and admission

`FUTURE-PARITY-BACKLOG.10.9.6` remains split as follows:

1. `.0` records this behavior-free audit and leaves the formal ledger at 4/5 implementations plus 4/6 runtimes;
2. `.1` adds the generated binding, frozen runtime, native system seam, protected decoded server/API, and focused
   identical dual-ABI proof without wire or ledger movement;
3. `.2` adds strict caller-owned stdio and hostile-I/O/lifecycle proof without ledger movement;
4. `.3` runs one exact ordered consumer unchanged on PUC Lua and LuaJIT and advances Lua to 5/5 implementations
   and the two ABI rows to 6/6 runtimes while shared rollout remains pending; and
5. `.4` recomposes the committed owners without replacement behavior and closes the Lua parent.

Step `.1` now implements this boundary from one unchanged source graph. The generated 82,827-byte module embeds
the exact 82,543-byte bundle; the frozen runtime verifies its digest/schema profile; the protected decoded server
owns secure handles, digest-only authorization, monotonic expiry, lowering-only policy, and sanitized dispatch;
and `mcp_system.c` supplies only OS entropy and monotonic time to both ABI builds. Focused proof is 111 + 210
assertions per runtime and source/CI/authority governance rejects 94 mutations without formal status movement.

Step `.2` now implements the private iterative wire and public `server:serve_stdio`. The scanner records numeric
lexemes by decoded JSON-pointer path, rejects fractional/exponent request ids, and substitutes invalid JSON-kind
sentinels only at the integer-only cancellation/page/budget fields before decoded schema validation. This keeps
the same invalid-request, invalid-params, and silent-notification outcomes on PUC Lua and LuaJIT without rejecting
fractional values in unconstrained client metadata. Caller-owned bytewise framing, canonical LF emission,
cancellation through successful flush, EOF/I/O release, and fixed optional diagnostics pass 247 assertions per
runtime; governance rejects 98 mutations while the formal ledger remains unchanged.

Step `.3` now executes one 202-assertion external consumer source independently on PUC Lua and LuaJIT. Both
runtimes prove all twelve exact roles, including native/MCP identity and the production 1,024-handle boundary;
the existing private focused seams cover only pre-emission cancellation and injected native failure. The ledger
is exactly 5/5 implementations plus 6/6 runtimes with shared rollout pending, and governance rejects 114
mutations without a production-source or transport-byte change.

Canonical admission signoff passes all six doctrines, the unchanged 35/10/10/68 transport boundary, all five
byte-fresh bindings, the complete six-runtime admission chain, Phase 0 1,031/1,031 in 659 seconds, and the full
PUC Lua/LuaJIT package gate. Step `.4` then recomposes those committed owners without production, fixture,
contract, or ledger change. Its independent canonical closeout passes Phase 0 1,031/1,031 in 652 seconds and the
same complete dual-ABI Lua gate, closing parent `.10.9.6` while recurring rollout remains `.10.9.7`.

The same neutral corpus, public decoded and stdio paths, exact semantic bytes, all raw/lifecycle classifications,
production 1,024-handle boundary, authority/privacy fences, and narrow private seams used by prior admissions are
required on both ABIs. Recurring six-runtime composition remains solely `.10.9.7`.

## Consequences

- Lua remains zero-LuaRocks and gains no MCP SDK or transport framework. Its only new native authority is a
  two-function system module compiled from one tracked C source for both existing ABI builds.
- The raw literal binding is smaller and simpler than Base64 while remaining generated, digest-verified,
  filesystem-free, and safe against future delimiter content.
- Bytewise input is intentionally selected for interactive correctness. Its measured full-limit cost is bounded
  and negligible next to semantic processing; any future optimization must first preserve nonblocking progress
  on ordinary caller-owned streams on both ABIs.
- LuaJIT's collapsed number representation cannot weaken the wire contract because lexical classification occurs
  before decoding. Decoded host dispatch remains an explicitly different trust boundary.
- No primary Lua command, corpus runner, semantic model, query response, generated-parser format, or MCP status row
  changes in the planning or decoded implementation leaves.

## Links

- Semantic model and thin-transport boundary: ADR `0049`
- Native per-backend topology: ADR `0054`
- Modern stdio contract: ADR `0055`
- Lua toolchain policy: `docs/knowledge/lua-toolchain-package-policy.md`
- Lua semantic admission: `docs/knowledge/lua-semantic-introspection-admission.md`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9.6.0-.4`)

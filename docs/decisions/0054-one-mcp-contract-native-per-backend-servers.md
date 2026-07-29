# ADR 0054: One MCP contract is implemented by native per-backend servers

- Date: 2026-07-29
- Status: accepted; exact neutral contract closed under `.10.9.1`; Perl implementation `.10.9.2.1-.2` complete;
  exact Perl admission `.10.9.2.3` and no-change closeout `.10.9.2.4` complete at 1/5 implementations + 1/6
  runtimes with canonical signoff; parent `.10.9.2` closed; Rust behavior-free plan fixed and complete under ADR
  `0058`/`.10.9.3.0`; remaining implementation/admission `.10.9.3.1-.7`
- Tags: architecture, mcp, semantic-api, backends, transport, embedding, portability, parity

## Context

ADR `0049` establishes MCP as a thin handle-and-query adapter over an already-created immutable native semantic
index. It deliberately gives MCP no authority to read source paths, compile, execute, traverse backend objects,
derive semantic records, invent explanations, raise policy ceilings, or retain a second semantic cache.

The remaining process-topology question was whether one MCP server should serve every backend or whether each
backend should provide its own server. A single cross-backend server offers one endpoint and one protocol
implementation, but the registered values are native in-memory objects owned by five different language runtimes.
One process cannot directly retain Perl, Rust, Dart, Julia, and Lua index objects without embedding runtimes,
introducing FFI, or routing through subprocess IPC. Those mechanisms would expand deployment and failure scope and
would tempt the central process to reconstruct, cache, or reinterpret semantic state.

The director approved the four-part architecture on 2026-07-29: one normative contract, one native implementation
per backend, one shared conformance suite across all runtime admissions, and only later consideration of an
optional convenience aggregator.

## Decision

1. LinkedSpec defines one exact MCP contract. Tool names and descriptions, JSON schemas, request and response
   envelopes, canonical encoding, handle lifecycle, authorization and expiry failures, deployment-policy ceiling
   rules, transport behavior, and conformance expectations are backend-neutral and versioned together.
2. The contract has five native server implementations: Perl, Rust, Dart, Julia, and Lua. Each implementation is
   embeddable in the same runtime/process that owns its registered immutable semantic indexes and calls only that
   backend's admitted native `capabilities` and `query` operations.
3. There are six runtime admissions. The single Lua-5.1-compatible server implementation runs unchanged on PUC
   Lua and LuaJIT, and both runtimes must pass independently.
4. The same backend-neutral transport corpus, failure cases, topology mutations, and direct-native/MCP canonical
   response comparisons apply to Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. Uniformity is a wire-contract and
   conformance property, not a requirement for one executable or one implementation language.
5. A server does not acquire an index by reading a path or compiling source. Its embedding explicitly registers an
   opaque handle for an index already created in the same native runtime. A standalone process wrapper is valid
   only when its caller provides an explicit, separately authorized index-bootstrap mechanism that preserves this
   boundary; no such wrapper or bootstrap is authorized by this decision.
6. A unified aggregator is not part of `FUTURE-PARITY-BACKLOG.10.9`. If later evidence justifies one endpoint, it
   requires a separate post-`.10.10` task-tree. It may only route to the native servers and must not own native
   indexes, cache semantic responses, compile/load sources, change policy ceilings, or reinterpret requests,
   results, diagnostics, or errors.

`FUTURE-PARITY-BACKLOG.10.9` is dependency-ordered as exact contract `.1`, Perl `.2`, Rust `.3`, Dart `.4`, Julia
`.5`, shared Lua `.6`, and recurring six-runtime admission/parent closeout `.7`. Planning leaf `.10.9.0` owns this
decision and split without adding transport behavior.

## Consequences

- Native opaque handles remain genuine in-process references rather than serialized stand-ins or remote backend
  object identifiers.
- Users deploy only the runtime/server implementation they need; backend failures, dependencies, and releases are
  isolated.
- Five implementations create protocol-drift risk. The executable contract and shared conformance corpus are
  therefore prerequisites, and no implementation may locally vary tool schemas or error meaning.
- Client installations that configure multiple backend servers may see the same two tool names from several
  server identities. Server identity and documentation must distinguish the backend while tool semantics remain
  identical.
- The Lua implementation remains one source owner with two runtime proofs, matching the existing dual-ABI parity
  doctrine.
- No primary LinkedSpec CLI behavior changes. MCP remains an embedding/transport surface separate from the five
  parser-oriented primary commands.

## Links

- Semantic model and thin-transport boundary: ADR `0049`
- Native in-memory embedding: ADR `0022`
- Exact user-observable parity: ADR `0023`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9-.10.9.7`)
- Modern MCP protocol/stdio policy: ADR `0055`
- Rust native implementation plan: ADR `0058`

# ADR 0062: Recurring MCP proof composes six runtimes and all twenty semantic responses

- Date: 2026-07-29
- Status: accepted plan; behavior and rollout unchanged until `FUTURE-PARITY-BACKLOG.10.9.7.1`
- Tags: architecture, mcp, semantic-api, conformance, recurring-gate, backends, storage, parity

## Context

ADRs `0049`, `0054`, and `0055` establish one neutral semantic model, one modern MCP transport contract, five
native server implementations, and six runtime admissions. The implementation ledger is complete at 5/5 source
implementations and 6/6 runtimes, while shared `thin_mcp_transport` rollout remains pending. The final MCP parent
therefore needs recurring composition rather than another implementation.

The audit found an important proof boundary. Every native semantic admission consumer already derives and
digest-checks all twenty cases in `semantic_introspection_contract.json`. Every MCP admission consumer already
executes the twelve exact transport roles, but its direct-native identity roles currently cover capabilities and
one representative graph query. Running those consumers together proves the full 35-frame, ten-raw-input,
ten-lifecycle, four-handle, four-policy, privacy, authority, and primary-CLI boundaries; it does not by itself
prove that all twenty semantic responses survive MCP byte-for-byte. Recurring orchestration may not claim that
stronger result by inference.

Adding a central response generator would create a second semantic oracle. Embedding every language runtime in
one process would violate the native-server topology. Treating the six existing consumers as sufficient would
leave the parent acceptance claim stronger than its evidence. The recurring boundary must close this gap at the
existing native adapter seams.

## Decision

### 1. Strengthen the six admitted consumers; do not add a seventh model

Leaf `.10.9.7.1` extends the existing MCP admission consumers' native-capabilities/native-query identity proof to
the exact twenty ordered `query_cases` already owned by
`capability_conformance/semantic_introspection_contract.json`:

- the capabilities case uses the registered native index's capabilities operation;
- the other cases use the registered native index's query operation, including failed, runtime-observed,
  privacy-limited, pagination, budget, explanation, and portable-error snapshots;
- each case compares direct native canonical JSON bytes with the MCP tool text and deep-equal structured content;
- each result digest must equal the existing neutral `response_sha256`; and
- a semantic response with `ok: false` remains a successful MCP tool result.

The consumers may add only test-side snapshot construction and registration needed to exercise their already
public native and MCP APIs. They may not copy expected records, relations, diagnostics, or response bodies; add a
production helper; change the semantic model; or change transport behavior. The neutral semantic checker remains
the expected-answer authority, and the native index remains the runtime answer authority.

The twelve-role admission vocabulary remains stable. `native_capabilities_identity` owns the capabilities case;
`native_query_identity` owns the remaining ordered query cases. Governance must reject a representative-only
shortcut, case omission/reorder, missing digest comparison, or skipped consumer.

### 2. One routed driver composes the exact existing authorities

Add executable `tools/check_mcp_six_runtime.sh`. It is a fail-fast orchestrator, not an MCP server or response
oracle. From a repository-derived managed run it performs this exact order:

1. validate the neutral twenty-response semantic contract;
2. materialize and independently validate the neutral MCP transport;
3. verify the Perl, Rust, Dart, Julia, and Lua generated bindings in that order;
4. run the Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT MCP admission consumers exactly once in that order;
5. validate the MCP implementation/admission/recurring ledger; and
6. run the existing three-case primary CLI no-drift projection across five commands and two environments.

The driver derives its root from its own location, sources `tools/project_data_env.sh` before runtime startup,
enters a managed run, gives Rust a disposable `CARGO_TARGET_DIR`, gives Julia a disposable writable depot in
front of the repository-local read depot, routes Dart/Lua/Python through their established wrappers, and removes
only its exact task artifact root on exit. It introduces no package, SDK, service, network, off-volume, or home-
cache dependency.

Canonical CI requires and syntax-checks the driver unconditionally. Expensive recurring execution is explicit
through `LINKEDSPEC_RUN_MCP_MATRIX=1`, matching the admitted semantic recurring-gate pattern. Existing focused and
canonical backend checks remain their own authorities.

### 3. Promotion is one coordinated, omission-sensitive transition

Only `.10.9.7.1` may make these coordinated changes:

- keep all five implementation rows and all six runtime-admission rows complete and unchanged;
- add the exact recurring-gate topology to `mcp_implementation_admission.json`;
- change its `thin_mcp_transport` rollout from pending to complete with owner
  `FUTURE-PARITY-BACKLOG.10.9.7.1`;
- change the matching semantic rollout row to the same complete status and owner;
- change semantic canonical-CI `mcp_direct_identity` from pending to the exact admitted recurring owner; and
- add both drivers/checkers to the relevant tracked-input, storage-routing, documentation, and mutation
  inventories.

The MCP checker and neutral semantic checker must reject partial promotion, owner disagreement, premature
promotion, runtime omission/reorder/duplication, command or path drift, ignored failure, driver omission,
non-executable or unrouted execution, missing canonical switch/syntax registration, incomplete twenty-case
identity, primary-surface drift, and authority expansion. Mutation totals advance only when every new mutant is
independently rejected.

### 4. Security and topology do not move

The recurring gate preserves one contract, five native server implementations, six runtime admissions, and one
Lua source identity exercised on two ABIs. A server still accepts only a caller-created native index and still
has no path, bootstrap, compilation, execution, trace, semantic-cache, arbitrary filesystem, process, network,
or primary-CLI authority. Legacy MCP and a convenience aggregator remain separately deferred; an aggregator may
later route only and cannot become part of this proof.

## Consequences

- Shared rollout is earned by direct evidence for all twenty native/MCP payload identities rather than inferred
  from one representative query.
- Expected semantic bytes still have one owner; the recurring layer contains orchestration and test adapters,
  not another semantic implementation.
- Runtime-specific construction remains inside the native consumer that already owns that runtime's admission.
- The opt-in gate is reproducible from a moved checkout and cannot strand project data on another volume.
- `.10.9.7.2` can close the MCP parent by rerunning committed owners unchanged; public API/mdBook no-drift remains
  separately owned by `.10.10`.

## Links

- Semantic model and thin adapter: ADR `0049`
- Native server topology: ADR `0054`
- Modern stdio transport: ADR `0055`
- Project-data locality: ADR `0053`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9.7.0-.2`)
- Prior recurring-gate precedent: `tools/check_semantic_introspection_six_runtime.sh`

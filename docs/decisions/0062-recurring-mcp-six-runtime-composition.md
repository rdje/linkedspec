# ADR 0062: Recurring MCP proof composes six runtimes and all twenty semantic responses

- Date: 2026-07-29
- Status: accepted and implemented; recurring/MCP parents and public semantic/MCP no-drift are complete
- Tags: architecture, mcp, semantic-api, conformance, recurring-gate, backends, storage, parity

## Context

ADRs `0049`, `0054`, and `0055` establish one neutral semantic model, one modern MCP transport contract, five
native server implementations, and six runtime admissions. The implementation ledger is complete at 5/5 source
implementations and 6/6 runtimes, while shared `thin_mcp_transport` rollout is now complete. The final MCP parent
therefore needs recurring composition rather than another implementation.

The audit found an important proof boundary. Every native semantic admission consumer already derived and
digest-checked all twenty cases in `semantic_introspection_contract.json`. Before `.10.9.7.1.1.2`, every MCP
admission consumer executed the twelve exact transport roles but its direct-native identity roles covered only
capabilities and one representative graph query. Running those consumers together proved the full 35-frame,
ten-raw-input, ten-lifecycle, four-handle, four-policy, privacy, authority, and primary-CLI boundaries, but not
that all twenty semantic responses survived MCP byte-for-byte. The consumers now carry that missing evidence,
and rooted omission-sensitive governance earns the coordinated promotion rather than inferring completion.

Adding a central response generator would create a second semantic oracle. Embedding every language runtime in
one process would violate the native-server topology. Treating the six existing consumers as sufficient would
leave the parent acceptance claim stronger than its evidence. The recurring boundary must close this gap at the
existing native adapter seams.

## Implementation audit finding — 2026-07-29

The first real Perl all-twenty spend disproved one assumption in this decision without changing committed code.
Capabilities and sixteen of nineteen query cases preserve native/MCP/digest identity, but three governed native
responses cannot cross the current public MCP boundary:

- `calls_symbols_and_shapes` contains valid `effects` and `return_shape` record facts that the shared MCP output
  schema does not admit, so response validation produces a sanitized internal error;
- `unsupported_contract` cannot reach the native portable diagnostic because MCP input validation fixes the query
  contract with `const` and returns invalid params first; and
- `source_ceiling_forbidden` cannot reach the native portable diagnostic because the default native-derived source
  ceiling is enforced as pre-dispatch MCP policy and returns policy denial first.

All five generated bindings share the schema and all five servers share the policy ordering. Test-only adaptation
would stop proving the public MCP API. The recommended correction is therefore a prerequisite contract/runtime
repair: add the complete governed semantic fact vocabulary, accept a bounded contract string so native version
diagnostics remain reachable, and reserve ceiling pre-denial for explicit deployment overlays while retaining the
native index ceiling and every explicit-policy security boundary. This necessarily changes the neutral transport
artifacts/digest, five generated bindings, and the same policy behavior in five implementations—material scope
that the original no-production-change plan excluded.

The alternative is to weaken the rollout claim to seventeen direct/MCP identities plus three distinct transport
outcomes. That preserves current transport bytes but abandons the accepted all-twenty identity objective. Leaf
`.10.9.7.1.0` records the verified evidence and paused promotion at that boundary; the authorization below resolves
the choice while rollout remains pending until implementation and proof.

## Atomic transport repair evidence — 2026-07-30

Leaf `.10.9.7.1.1.1` implements the authorized prerequisite without promoting rollout. The shared response
schema now derives the exact 72-key, first-seen union of governed semantic fact keys, including `effects` and
`return_shape`. The query `contract` field is now a nonempty string bounded to 128 characters and 128 UTF-8
bytes. Unknown but structurally valid values therefore reach the native semantic layer and retain its portable
`semantic_query_contract_unsupported` response.

The neutral deployment profile now names explicit component presence as the sole pre-dispatch enforcement
authority. Every server records presence separately from the effective native-plus-overlay value. An omitted
component reaches native dispatch and native portable diagnostics; a page-only overlay, for example, cannot
preempt a source-detail diagnostic. Explicit source, derived content-digest, page, and budget ceilings remain
lowering-only and dispatch-free when exceeded. Generated schema validation still rejects malformed requests
before authorization or native dispatch.

The materializer and independent checker derive these invariants separately and reject 76 named neutral
mutations. All five filesystem-free bindings are byte-fresh at Perl 83,411, Rust 83,225, Dart 83,214, Julia
120,030, and Lua 83,166 bytes. Focused decoded, strict-stdio, and admission proof passes on Perl, Rust, Dart,
Julia, PUC Lua, and LuaJIT. The implementation ledger deliberately remains 5/5 implementations + 6/6 runtimes,
rollout pending, with 114 governance mutations. At that repair boundary, leaf `.10.9.7.1.1.2` remained responsible
for proving all twenty direct-native/MCP/digest identities before any promotion.

## All-twenty six-runtime consumer evidence — 2026-07-30

Leaf `.10.9.7.1.1.2` strengthens only the existing five MCP admission consumers and runs the shared Lua source
unchanged under PUC Lua and LuaJIT. Each consumer constructs the six governed snapshot classes through its
native public APIs: graph, calls/staging, failed compilation, real runtime observation, full-text privacy, and
identity-ceiling privacy. No expected response body or second production/test oracle was added.

The existing `native_capabilities_identity` role now proves direct native object, canonical MCP text, decoded
text, structured content, and the governed capabilities digest. The unchanged `native_query_identity` role does
the same for all nineteen remaining cases in contract order, including calls/shapes, runtime events, pagination,
budgets, privacy, source-ceiling, unsupported-contract, invalid-operation, and explanation outcomes. Native
`ok: false` responses remain successful MCP tool envelopes.

Focused execution passes Perl's 13 ordered subtests, Rust 1/1, Dart 1/1 with clean analysis, Julia 257/257, and
the one Lua consumer at 281 assertions on each ABI. Canonical repeats all six changed admissions and passes Rust
semantic 1/1 in 81.63 seconds, Dart 1/1, Julia 416/416 in 29.5 seconds, repository containment/moved-root, CLI
66x2, RAM 59%, and Phase 0 1,031/1,031 in 661 seconds. The neutral semantic and MCP contracts remain 6/20/105
and 35/10/10/76. Formal state intentionally remains 5/5 implementations + 6/6 runtimes, rollout pending, with
114 governance mutations; `.10.9.7.1.1.3` must still add the rooted recurring composition and earn promotion.

## Routed promotion and canonical evidence — 2026-07-30

Leaf `.10.9.7.1.1.3` adds the exact rooted driver and promotes the two ledgers together under owner
`FUTURE-PARITY-BACKLOG.10.9.7.1`. Focused execution passes semantic 6/20/110, MCP 35/10/10/76, all five
byte-fresh bindings, the Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT all-twenty consumers, the complete 5/5 + 6/6/141
ledger, and the selected primary projection at 30/30. The first composed run exposed Julia's established
`Main.REPO_ROOT` include-wrapper dependency; the first canonical attempt exposed exact lexicographic ordering in
the shell-owner registry. Both integration seams are corrected and omission-checked.

The complete canonical rerun with `LINKEDSPEC_RUN_MCP_MATRIX=1` exits zero after all seven doctrines, Rust
semantic 1/1 in 81.29 seconds, Dart 1/1, Julia semantic 416/416 in 28.9 seconds, repository containment,
moved-root execution, primary CLI 66x2, RAM 54%, and Phase 0 1,031/1,031 in 643 seconds. Its optional recurring
leg independently repeats Perl 13, Rust 1/1 in 15.77 seconds, Dart 1/1, Julia 257/257 in 6.9 seconds, Lua 281/281
per ABI, the complete/141 ledger, and primary 30/30 before the canonical PASS. This evidence earns the
coordinated rollout transition without adding another response oracle or server authority.

## Unchanged implementation-parent closeout — 2026-07-30

Leaf `.10.9.7.1.1.4` starts from clean routed-promotion commit `de46b26a` and recomposes every committed owner
without replacement behavior. Focused execution again passes semantic 6/20/110, MCP 35/10/10/76, all five
byte-fresh bindings, Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT all-twenty consumers, complete 5/5 + 6/6/141
governance, and primary 30/30. The independent host-authorized canonical opt-in gate exits zero after all seven
doctrines, Rust semantic 1/1, Dart 1/1, Julia 416/416 in 29.3 seconds, repository containment/moved-root,
primary CLI 66x2, RAM 54%, and Phase 0 1,031/1,031 in 655 seconds. Its optional leg independently repeats Perl
13, Rust 1/1 in 15.88 seconds, Dart 1/1, Julia 257/257 in 6.8 seconds, Lua 281/281 per ABI, complete/141
governance, and primary 30/30.

That unchanged conjunction closes implementation parents `.10.9.7.1.1` and `.10.9.7.1`. It changes no
production, fixture, contract/binding, consumer, oracle, ledger/status, semantic, CLI, aggregator, legacy, or
server authority. At that boundary, MCP-parent no-change closeout `.10.9.7.2` remained next; the section below
records its completed evidence.

## Unchanged MCP-parent closeout — 2026-07-30

Leaf `.10.9.7.2` starts from clean implementation-parent commit `77ceb921` and recomposes the entire accepted
chain without another response model or implementation. Focused execution passes semantic 6/20/110, MCP
35/10/10/76, byte-fresh bindings at Perl 83,411 / Rust 83,225 / Dart 83,214 / Julia 120,030 / Lua 83,166 bytes,
Perl 13, Rust 1/1 in 15.70 seconds, Dart 1/1, Julia 257/257 in 6.7 seconds, Lua 281/281 per ABI, complete/141
governance, and primary 30/30.

The independent host-authorized canonical MCP opt-in exits zero after all seven doctrines, Rust semantic 1/1 in
80.25 seconds, Dart 1/1, Julia semantic 416/416 in 28.5 seconds, repository containment/moved-root, primary CLI
66x2, RAM 53%, and Phase 0 1,031/1,031. Its optional recurrence independently repeats Perl 13, Rust 1/1 in 15.52
seconds, Dart 1/1, Julia 257/257 in 6.8 seconds, Lua 281/281 per ABI, complete/141 governance, and primary 30/30.
No ledger, protocol, semantic, primary, aggregator, legacy, or authority behavior moves. This closes `.10.9.7`
and `.10.9`; semantic rollout remains 8/9 until public no-drift `.10.10` earns the final row.

## Director authorization and implementation boundary — 2026-07-30

The director authorized the recommended exact all-twenty correction and rejected no part of the proposed
one-contract/five-implementation architecture. The weaker seventeen-plus-three claim remains documented history,
not the selected path. Rollout remains pending until executable proof earns promotion.

Implementation child `.10.9.7.1.1.0` keeps the repair atomic where repository consistency requires it:

1. `.1` updates the neutral schema and policy profile, exact artifacts/digests, independent validator and
   mutations, all five generated bindings, and the same request-policy semantics in Perl, Rust, Dart, Julia, and
   shared Lua. `recordFacts` becomes the exact union of governed semantic fact keys; an unknown query contract is
   a nonempty string bounded to 128 characters and 128 UTF-8 bytes so native version diagnostics remain reachable.
   Pre-dispatch denial is keyed by explicit per-component deployment-overlay presence—not inherited native
   defaults—so default requests reach native portable diagnostics while explicit source/content/page/budget
   ceilings remain strict and dispatch-free. This atomic repair is now implemented and focused-green; it does
   not itself establish all-twenty identity or promote rollout.
2. `.2` strengthens the existing five consumers, with shared Lua run on both ABIs, to prove capabilities plus all
   nineteen query responses through direct canonical bytes, MCP text/structured content, and existing digests.
   This proof is now implemented and canonical-green without production, contract, binding, fixture, role, or
   formal-status movement.
3. `.3` adds the rooted same-volume recurring driver, independent omission governance, coordinated ledger state,
   canonical opt-in, and atomic thin-transport promotion. This is now implemented.
4. `.4` recomposes every committed owner unchanged and closes `.1.1` plus parent `.1` before MCP closeout `.2`.

Contract/schema/policy/server movement belongs to one commit because splitting those authorities would leave an
intermediate durable revision with internally inconsistent public transport semantics. Consumer evidence and
rollout promotion remain separate commits so proof precedes status.

## Decision

### 1. Strengthen the six admitted consumers; do not add a seventh model

This section defines the proof now implemented after the authorized prerequisite boundary repair. Leaf
`.10.9.7.1.1.1` repairs the three shared neutral transport seams documented above; `.10.9.7.1.1.2` performs this
consumer proof. The original consumer-only restriction is superseded only for that bounded repair;
it remains in force for semantic-model ownership and expected response bodies.

Leaf `.10.9.7.1.1.2` extends the existing MCP admission consumers' native-capabilities/native-query identity proof to
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
- That direct evidence is present on all six runtimes; the separately governed recurring driver and coordinated
  ledger transition now mark formal rollout complete.
- Expected semantic bytes still have one owner; the recurring layer contains orchestration and test adapters,
  not another semantic implementation.
- Runtime-specific construction remains inside the native consumer that already owns that runtime's admission.
- The opt-in gate is reproducible from a moved checkout and cannot strand project data on another volume.
- Implementation parents `.10.9.7.1.1` and `.10.9.7.1` are closed by unchanged recomposition, not a replacement
  oracle.
- `.10.9.7.2` closes the MCP parent by rerunning committed owners unchanged. Public semantic/MCP no-drift
  `.10.10` subsequently governs current APIs/examples/status and closes semantic rollout at 9/9 without changing
  the all-twenty semantic responses or the recurring driver.

## Links

- Semantic model and thin adapter: ADR `0049`
- Native server topology: ADR `0054`
- Modern stdio transport: ADR `0055`
- Project-data locality: ADR `0053`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.10.9.7.0-.2`, implementation
  promotion `.10.9.7.1.1.3`, and parent closeout `.10.9.7.1.1.4`)
- Prior recurring-gate precedent: `tools/check_semantic_introspection_six_runtime.sh`

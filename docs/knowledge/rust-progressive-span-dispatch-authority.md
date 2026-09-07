---
id: rust-progressive-span-dispatch-authority
title: Rust progressive span dispatch has a private immutable authority core
answers:
  - "where is the Rust progressive span dispatch authority"
  - "how does Rust progressive dispatch register child parsers"
  - "can Rust progressive dispatch load parser paths"
  - "how does Rust progressive dispatch rebase source locations"
  - "how does Rust progressive dispatch share cancellation and budgets"
  - "how does Rust progressive dispatch prevent cycles"
  - "how are Rust progressive child results detached"
  - "does Rust progressive dispatch have ActionIR carriers"
  - "does the Rust progressive authority test run in CI"
  - "why does the Rust one-byte child diagnostic fallback stay within its ceiling"
date: 2026-09-07
status: private authority/core, four carriers, and canonical Rust admission current
tags: [rust, progressive-parsing, registry, source-location, cancellation, diagnostics, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.3.1 adds rust/linkedspec-runtime/src/bounded_child_parse_authority.rs and exposes it only through the neutral doc-hidden bounded_child_parse_authority module, because outward guards reserve the progressive syntax/node terminology for later carrier admission. ProgressiveRegistry deeply owns validated logical ids, sha256 fingerprints, allowed top rules, capabilities, policy/resource ceilings, and already-compiled callbacks; register/load return typed denials and no path/provider/compiler authority exists. ProgressiveInvocation owns one SourceAuthority over caller-provided decoded snapshots plus the sole source id, Arc-identity cancellation token, monotonic deadline, shared remaining steps, active global-span chain, depth limit, and total-call limit. Dispatch derives capability/policy intersections and ceiling minima, requires the exact shared token, charges cost before synchronous child execution, enforces pre/post safe points, permits repeated identity/top/source only on a contained strictly smaller span, invalidates every cloned bounded view after the callback, and deeply detaches node-bounded serde_json results while rejecting live-looking fields. rust/linkedspec-runtime/tests/progressive_span_dispatch_authority.rs is file-level cfg linkedspec_progressive_span_dispatch_authority: ordinary discovery runs zero tests and canonical CI omits it; the opt-in proof covers all neutral cases and 26 diagnostics plus nesting, typed rebasing, expiry, mutation isolation, false payloads, and detachment. No dedicated expression node, engine/descriptor/generated carrier, format, rollout row, or outward surface moves; .14.6.3.2 and .3 own those later boundaries."
evidence_update_2026_08_17_carriers: "FUTURE-PARITY-BACKLOG.14.6.3.2 makes ProgressiveInvocation own a cloned immutable registry so one opaque ProgressiveExecutionSeed can create fresh execution-local authority without a self-reference. RuntimeContext clones share that invocation through one opaque mutex-backed state, preserving budget/call/cancellation identity. This is the host seam used by the four dormant carriers; authority semantics and the separate .3.1 consumer remain exact."
evidence_update_2026_08_26_proof_repair: "TRACE-OBSERVABILITY.5.3 repairs only the stale topology assertion left when later admission commit 5c4d4218 routed the separate contract consumer. The cfg-enabled private authority target remains absent from canonical CI and passes 4/4. Its route proof now forbids progressive_span_dispatch_authority while requiring the tracked progressive_span_dispatch_contract.rs input and cfg-enabled --test progressive_span_dispatch_contract command exactly once. Both targets remain zero-test under ordinary discovery; the admitted contract remains 1/1 in canonical CI. No authority, carrier, runtime, format, rollout, public, or other-backend behavior changes."
reverify:
  - "bash tools/run_cargo_local.sh check --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime"
  - "bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_authority"
  - "RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_authority' bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_authority"
  - "if rg -n 'progressive_span_dispatch_authority\\.rs|--test progressive_span_dispatch_authority' tools/run_ci_local.sh; then exit 1; fi"
---

# Private Rust progressive authority

This core is executable host authority, not authored Rust progressive behavior. A trusted outer host supplies
already compiled callbacks and decoded source snapshots. Authored execution can select only a validated logical
identity, allowed top rule, and one exact same-source direct span; it cannot resolve or load a parser path.

The bounded view retains the original `SourceAuthority`. Child offsets are local Unicode-scalar boundaries, while
rebased typed positions/spans and diagnostics carry the original source identity and global scalar/line/column/
UTF-8 coordinates. All view clones share one validity bit and expire when the callback finishes.

Authority only narrows: capabilities and policy modes intersect, detail/resource ceilings take minima, and nested
dispatch shares cancellation identity, deadline, remaining steps, active chain, depth, and call count. Callback
failure and panic are contained; `false` remains a valid detached payload, while `null`, live-looking fields, and
over-ceiling structures fail closed.

The August 26 focused authority proof passes four tests covering the neutral matrix and nested/mutation
adversaries. Its ordinary invocation executes zero tests. The separate final-path consumer covers four carriers;
its later canonical admission is distinct from the earlier dormant-carrier milestone.

The dedicated node and native/reconstructed/generated-plan/independently compiled emitted-source carriers use
this authority through a fresh opaque execution seed. `.14.6.3.3` routes the exact cfg-enabled consumer once in
canonical CI and promotes only Rust rollout; the separate authority consumer remains focused and dormant.
`TRACE-OBSERVABILITY.5.3` makes that distinction executable: the authority proof forbids its own route while
requiring the admitted contract's tracked input and command exactly once.

## September 7 bounded source checkpoint

`SESSION-STARTUP-READING.3.3.13` reads source lines 1–778 (26,241 bytes), through the
`ProgressiveInvocation` fields. Its constructor, dispatch, narrowing, result checks, and validation helpers
remain in `.3.3.14`; this checkpoint does not claim that the entire authority implementation is read.

The prefix owns validated immutable registry records and typed register/load denials, Arc-identity cancellation,
the caller's clock, opaque seed identity, and one mutex-backed invocation shared by execution-state clones.
Callback source-view clones share expiry; their text is bounded, and local scalar positions/spans are rebased
through the original `SourceAuthority`. Diagnostic rebasing clones the supplied data and enforces the serialized
byte ceiling. Full dispatch ordering and helper contracts remain with the suffix owner.

Fresh neutral proof passes all six authority, six cancellation, eight chain, and four execution cases,
with rollout 9/9, 116 contract mutations, and 60 public mutations. The preceding unchanged-source canonical
checkpoint `.3.3.12`, committed as `1d3715fc`, passes the separate four-carrier contract consumer 1/1 in
206.60 test seconds. The private cfg-enabled authority consumer was not freshly rerun for this reading leaf.
Existing `.41.2` owns the stale `ProgressiveDispatchArguments` comment that predates static carrier admission.

## September 7 invocation and helper checkpoint

`SESSION-STARTUP-READING.3.3.14` finishes lines 779–1639 (28,104 bytes), so the
authority file is now fully read. Construction validates decoded source membership,
positive depth/call limits and every supplied active-chain span. Dispatch validates
literal identity, exact span shape/bounds, transaction state, registry/top selection,
capability/policy/resource intersections, chain progress and token/budget/time before
charging the shared invocation and calling the compiled child.

On callback return or unwind, dispatch pops its chain frame and invalidates the
shared view before interpreting the result. Null, returned errors and panics become
typed child failures; false remains valid data. Successful results recheck cancellation
and deadline, then recursively rebuild JSON under the result-node ceiling and reject
live-looking field names. Repeated matching parser/top/source identities require a
contained strictly smaller span.

The zero-byte diagnostic concern is excluded by the actual constructor boundary:
`ProgressiveCeilings` has private fields and rejects all zero numeric ceilings.
The child-error truncator keeps complete UTF-8 scalars and uses the one-byte `?`
fallback when none fits. The existing private authority test explicitly checks
`éé` under a one-byte ceiling. That test was read, not freshly executed here.
This does not settle the callback-input versus outward source-detail interpretation
or nested resource-composition questions already owned by startup `.37.1`/`.37.2`.

Fresh neutral proof passes progressive 9/9 with 116 contract/60 public mutations
and typed source 14/0 with 231 mutations. The unchanged-source canonical consumer
result at `1d3715fc` remains dated proof; this documentation leaf does not rerun
the cfg-enabled native authority or four-carrier consumer.

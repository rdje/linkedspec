---
id: dart-progressive-span-dispatch-authority
title: Dart progressive span dispatch has callback-scoped private authority
answers:
  - "where is the Dart progressive span dispatch authority"
  - "how does Dart progressive dispatch register child parsers"
  - "can Dart progressive dispatch load a parser path"
  - "how does Dart progressive dispatch rebase source locations"
  - "how does Dart progressive dispatch share cancellation and budgets"
  - "how does Dart progressive dispatch prevent cycles"
  - "how are Dart progressive child results detached"
  - "can a Dart child retain nested dispatch authority"
  - "does the Dart progressive authority have ActionIR carriers"
  - "does the Dart progressive authority test run in CI"
date: 2026-08-17
status: private authority and carriers current; Dart admitted while the authority-only consumer stays focused and dormant
tags: [dart, progressive-parsing, registry, source-location, cancellation, diagnostics, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.4.1 adds dart/lib/src/runtime/bounded_child_parse_authority.dart without exporting it from the Dart umbrella or importing it into ActionIR/interpreter/generated carriers. ProgressiveRegistry deeply owns validated logical ids, sha256 fingerprints, allowed top rules, capabilities, ceilings, and already-compiled synchronous callbacks; register and load are typed denials and no path/provider/compiler authority exists. Each ProgressiveInvocation owns one existing SourceAuthority over copied decoded snapshots plus the sole source id, identity-bearing cancellation token, monotonic deadline, shared steps, active global-span chain, depth limit, and total-call limit. Dispatch intersects grants and policies, takes ceiling minima, charges before child work, observes pre/post safe points, requires a contained strictly smaller repeat, and deeply detaches node-bounded plain results. ProgressiveSourceView materializes only one typed direct span, rebases local Unicode-scalar positions/spans/diagnostics to the original identity, and expires after callback completion or failure. Dart cannot express Rust's borrowed invocation callback safely, so nested dispatch is exposed only by ProgressiveDispatchRequest.dispatchNested; it consults the same expired view before delegation, preventing a retained callback request from preserving live invocation authority. The analyzed-but-undiscovered authority consumer passes four groups covering every neutral 8-view, 6-authority, 6-cancellation, 8-chain, 4-execution case and all 26 diagnostics plus nesting, rebasing, expiry, retained-request denial, registry-input isolation, cyclic/live/oversized result rejection, callback containment, and UTF-8 diagnostic bounding. Full Dart analysis and 408 ordinary tests pass. The separate final-path consumer remains exact at +4/-1 missing-node RED; rollout stays 3/9/95 and .14.6.4.2-.3 exclusively own carriers and admission."
evidence_update_2026_08_17_carriers: "FUTURE-PARITY-BACKLOG.14.6.4.2 now attaches this authority through an opaque ProgressiveExecutionSeed that starts fresh execution-local invocation state. One exclusive ActionProgressiveDispatchSpanExpr and native/reconstructed/generated-plan/independently analyzed emitted-source carriers are GREEN; callbacks and authority remain absent from serialized/generated data. The final-path consumer remains dormant and Dart rollout stays pending for .4.3."
evidence_update_2026_08_17_admission: "FUTURE-PARITY-BACKLOG.14.6.4.3 admits the unchanged carrier consumer at dart/test/progressive_span_dispatch_contract_test.dart through ordinary discovery and one exact canonical route. The authority-only consumer remains under test_dormant for focused proof. Dart rollout advances to 4/9/103 without exporting the authority or changing generated format, typed recurrence, public inventory, or outward surfaces."
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings lib/src/runtime/bounded_child_parse_authority.dart test_dormant/progressive_span_dispatch_authority_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/progressive_span_dispatch_authority_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/progressive_span_dispatch_contract_test.dart"
  - "test ! -e dart/test/progressive_span_dispatch_authority_test.dart && ! rg -q 'progressive_span_dispatch_authority_test' tools/run_ci_local.sh"
---

# Private Dart progressive authority

The core is a private host API, not authored Dart behavior. A trusted caller provides already-compiled callbacks,
decoded sources, one active source identity, and all cancellation/resource limits before parsing begins. Authored
execution cannot register, enumerate, resolve, load, compile, or derive parser authority from a span.

The source view is constructed through Dart's existing typed `SourceAuthority`: one direct same-source span is
materialized, child offsets remain view-local, and typed values plus diagnostic offsets rebase to original global
Unicode-scalar coordinates. No parent cursor, mark, capture, variable, boundary, or transaction register enters
the authority object.

Dart callback lifetime requires an explicit defense that borrowed Rust references get from the type system. The
callback receives a `ProgressiveDispatchRequest`, never the mutable invocation. Its `dispatchNested(...)` method
checks the callback-scoped source view before delegating. On every return or throw, the view is invalidated, so a
retained request cannot perform a later child dispatch.

The dedicated expression and four execution carriers consume this core through a fresh opaque host seed. Their
unchanged seven-group consumer is ordinarily and canonically admitted; the authority itself remains private.

## Links

- Neutral model: [[progressive-span-dispatch-audit-plan]].
- Historical final-path RED: [[dart-progressive-span-dispatch-dormant-red]].
- Current carriers: [[dart-progressive-span-dispatch-carriers]].
- Typed source authority: [[typed-source-location-cursor-algebra-direction]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.6.4.1`.

## 2026-09-09 — bounded authority prefix reading

`DART-STARTUP-READING.1.14` reads lines 1-746. Registry entries retain already-compiled
callbacks under validated logical identities/fingerprints; maps and configuration snapshots
are copied into immutable containers. Runtime register/load methods are typed denials.
The opaque host seed starts fresh invocation accounting while preserving the caller's shared
cancellation identity. No callbacks, host source snapshots or authority objects are added
to generated plan data.

Callback requests expose bounded text, original source identity and scalar position/span/
diagnostic rebasing through SourceAuthority. Local offset checks include both endpoints;
diagnostic size uses UTF-8 JSON bytes. Each view operation checks lifetime, and dispatchNested
checks the same view before delegation. Invocation construction validates source availability,
limits and active-chain spans. The owned range ends during constructor field transfer;
`.1.15` owns its remainder, the dispatch algorithm and result-detachment helpers.

Fresh selected proof passes 24 function/progressive tests, including all four dormant
authority groups and seven admitted carrier groups. The latter independently analyzes and
executes emitted Dart source. This is selected Dart evidence, not a fresh complete-backend
or all-runtime gate; known recognition integration repair .2.4 retains its separate owner.

## 2026-09-09 — dispatch suffix and nested-authority qualification

`DART-STARTUP-READING.1.15` reads lines 747-1504 through EOF. Dispatch validates logical
identity, exact direct source span, transaction state, registry/top-rule access and the
supplied capability/policy intersection. Safe points check the shared token/deadline and
cost against shared remaining steps plus the newly computed maxSteps, then charge before
callback entry. Repeated parser/top/source spans must be contained and strictly smaller;
depth and total-call limits apply across identities. Callback cleanup removes the active
frame and expires the source view even on failure. Result copying counts nodes, rejects
cycles, live/unsupported values and reserved field tokens; diagnostic truncation is UTF-8.

Fresh ten-case composition proof narrows the earlier claims: direct cost/result-node/
diagnostic-byte limits reject or truncate as expected, but nestedDispatch delegates to the
invocation without inheriting the active callback's effective grants or remainingSteps.
A zero-remaining callback still nests; another supplies wider capabilities/ceilings and
regains them. [[dart-progressive-nested-authority-gap]] preserves the full private API replay
under existing startup .37.1/.37.2. Input visibility and outward source-detail containment
remain separate review questions; no authored or other-backend gap is inferred.

Eighty-two selected authority/carrier/interpreter/cursor/emitter tests and neutral
9/9/116/public60 checks pass, including existing emitted execution. Those consumers
remain valid for their covered routes and do not close these newly combined boundaries.

## September 11 private authority consumer reading complete

Dart .1.55 reads all794 lines of the dormant authority consumer. Four test groups
cover every neutral view/grant/cancellation/chain/execution row, all26 diagnostic
codes, nested scalar rebasing and shared invocation counters, expired views and
requests, copied registry configuration and detached/cyclic/node-bounded results.
The one-byte child-diagnostic case preserves a one-byte replacement. Its local
parentState copy is not passed into the invocation; engine non-interference remains
separate admitted-carrier evidence. Default permissive nested arguments do not
resolve startup .37's measured effective-grant/budget inheritance gap.

The authority-only file remains outside ordinary/canonical discovery and the public
umbrella; the separate seven-group carrier consumer remains admitted. The opening
RED comment describes the historical pre-carrier step. All20 selected tests pass
(nine write, four private authority, seven carrier); neutral progressive is9/9
complete,zero pending,116 mutations plus public60. No source or MCP change.

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
status: private authority and dormant carriers current; admission and Dart rollout pending
tags: [dart, progressive-parsing, registry, source-location, cancellation, diagnostics, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.4.1 adds dart/lib/src/runtime/bounded_child_parse_authority.dart without exporting it from the Dart umbrella or importing it into ActionIR/interpreter/generated carriers. ProgressiveRegistry deeply owns validated logical ids, sha256 fingerprints, allowed top rules, capabilities, ceilings, and already-compiled synchronous callbacks; register and load are typed denials and no path/provider/compiler authority exists. Each ProgressiveInvocation owns one existing SourceAuthority over copied decoded snapshots plus the sole source id, identity-bearing cancellation token, monotonic deadline, shared steps, active global-span chain, depth limit, and total-call limit. Dispatch intersects grants and policies, takes ceiling minima, charges before child work, observes pre/post safe points, requires a contained strictly smaller repeat, and deeply detaches node-bounded plain results. ProgressiveSourceView materializes only one typed direct span, rebases local Unicode-scalar positions/spans/diagnostics to the original identity, and expires after callback completion or failure. Dart cannot express Rust's borrowed invocation callback safely, so nested dispatch is exposed only by ProgressiveDispatchRequest.dispatchNested; it consults the same expired view before delegation, preventing a retained callback request from preserving live invocation authority. The analyzed-but-undiscovered authority consumer passes four groups covering every neutral 8-view, 6-authority, 6-cancellation, 8-chain, 4-execution case and all 26 diagnostics plus nesting, rebasing, expiry, retained-request denial, registry-input isolation, cyclic/live/oversized result rejection, callback containment, and UTF-8 diagnostic bounding. Full Dart analysis and 408 ordinary tests pass. The separate final-path consumer remains exact at +4/-1 missing-node RED; rollout stays 3/9/95 and .14.6.4.2-.3 exclusively own carriers and admission."
evidence_update_2026_08_17_carriers: "FUTURE-PARITY-BACKLOG.14.6.4.2 now attaches this authority through an opaque ProgressiveExecutionSeed that starts fresh execution-local invocation state. One exclusive ActionProgressiveDispatchSpanExpr and native/reconstructed/generated-plan/independently analyzed emitted-source carriers are GREEN; callbacks and authority remain absent from serialized/generated data. The final-path consumer remains dormant and Dart rollout stays pending for .4.3."
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings lib/src/runtime/bounded_child_parse_authority.dart test_dormant/progressive_span_dispatch_authority_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/progressive_span_dispatch_authority_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/progressive_span_dispatch_contract_test.dart"
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

The dedicated expression and four execution carriers now consume this core through a fresh opaque host seed.
`.14.6.4.3` alone may admit the unchanged final-path consumer and advance Dart rollout.

## Links

- Neutral model: [[progressive-span-dispatch-audit-plan]].
- Historical final-path RED: [[dart-progressive-span-dispatch-dormant-red]].
- Current carriers: [[dart-progressive-span-dispatch-carriers]].
- Typed source authority: [[typed-source-location-cursor-algebra-direction]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.6.4.1`.

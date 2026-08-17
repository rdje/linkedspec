---
id: dart-progressive-span-dispatch-dormant-red
title: Dart progressive span dispatch historically had a dormant RED at the dedicated-node boundary
answers:
  - "is progressive span dispatch implemented in Dart"
  - "where is the dormant Dart progressive span dispatch RED consumer"
  - "how does Dart currently compile dispatch_span"
  - "what happens when Dart executes dispatch_span today"
  - "which Dart carriers preserve the progressive dispatch RED"
  - "does ordinary Dart test discovery run the progressive dispatch consumer"
  - "does canonical CI run the Dart progressive dispatch consumer"
  - "which leaves implement Dart progressive span dispatch"
date: 2026-08-17
status: historical RED superseded by admitted GREEN carriers; retained only as pre-implementation evidence
tags: [dart, progressive-parsing, red-test, generated-source, staged-registry, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.4.0 adds dart/test_dormant/progressive_span_dispatch_contract_test.dart outside ordinary and canonical discovery. The consumer derives neutral 3/9/95 truth, proves the unrelated staged function-body registry rejects expr-v1 at resolve, and compiles the exact reserved assignment. Current Dart retains one generic ActionCallExpr named dispatch_span and no progressive_dispatch_span / PROGRESSIVE_DISPATCH_SPAN node. Native, SpecFile-JSON reconstructed, validated generated-plan, and independently analyzed/executed emitted-source routes all reach the same structured unknown_helper diagnostic for dispatch_span. The explicit repository-routed run passes four test groups and fails only at the dedicated-node assertion. Production sources retain committed blobs action_ast d424a4c0, action_parser 099ec90c, action_contracts 6cc5850e, interpreter 2c962b54, staged registry 8eb8b7e1, source emitter 6fd55f4f, and source-location authority 40d1e318. Leaf .14.6.4.1 owns authority/core, .2 owns the node and four carriers, and .3 alone owns ordinary/canonical admission plus Dart rollout."
evidence_update_2026_08_17_carriers: "FUTURE-PARITY-BACKLOG.14.6.4.2 preserves this exact test path and authored fixture but turns the historical boundary GREEN with one dedicated logical-only node, exact static and transaction rejection, and native/reconstructed/generated-plan/independently analyzed emitted carriers through fresh host authority. The consumer remains dormant; .4.3 still owns admission and Dart rollout."
evidence_update_2026_08_17_admission: "FUTURE-PARITY-BACKLOG.14.6.4.3 preserves the exact fixture and seven GREEN groups while moving the consumer from test_dormant to dart/test/progressive_span_dispatch_contract_test.dart. Ordinary discovery and one exact canonical requirement/marker/invocation now own it; no dormant duplicate remains. Progressive rollout is 4/9 with 103 mutations, while Julia/Lua, recurrence, typed projection, public no-drift, and outward surfaces remain pending."
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings test/progressive_span_dispatch_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/progressive_span_dispatch_contract_test.dart"
  - "test ! -e dart/test_dormant/progressive_span_dispatch_contract_test.dart"
---

# Historical Dart dormant progressive-dispatch boundary

Dart's current parser accepts the reserved authored spelling as an ordinary `ActionCallExpr`. Runtime helper
resolution rejects that call with the existing structured `unknown_helper` diagnostic; this consistent failure is
not child-parser execution. Rebuilding from `SpecFile` JSON, running the generated-v2 plan, and independently
analyzing plus executing fresh emitted source preserve the same boundary.

The consumer lives under `dart/test_dormant/`, so ordinary package discovery omits it while fatal analysis still
checks it. Its first four groups are GREEN; its final assertion is the exact intentional RED for the missing
dedicated node. The separate staged registry still accepts only `actionir-body.spec` and rejects `expr-v1` without
loading a path.

That exact RED is now historical. `.14.6.4.2` added static syntax, the dedicated node, and authority plumbing
across the four carriers without changing the test identity. `.14.6.4.3` moves that unchanged proof into ordinary
and exact canonical discovery and promotes only Dart rollout.

Authority leaf `.14.6.4.1` is now implemented independently under
`dart/lib/src/runtime/bounded_child_parse_authority.dart`; its separate dormant consumer is GREEN. This historical
final-path consumer is now GREEN and admitted through the carriers documented in
[[dart-progressive-span-dispatch-carriers]].

---
id: dart-logical-helper-neutral-runtime
title: Dart logical helpers and lazy controls share one typed truth and pre-effect arity boundary
answers:
  - "does Dart support and or not receiver methods"
  - "do Dart logical receiver results preserve scalar value copies"
  - "where is Dart logical truthiness implemented"
  - "are Dart logical helpers eager or short circuit"
  - "does Dart validate logical helper arity before operand effects"
  - "do Dart logical helpers and lazy controls share truthiness"
  - "which Dart generated roles prove the logical helper contract"
  - "what fields are in a Dart logical arity diagnostic"
  - "does Dart logical parity activate explicit codeblock literals"
date: 2026-10-27
status: current
tags: [dart, logical, truthiness, arity, runtime, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "TYPE23.3.17.3 public producer/shared/rejected-effect/actual-Bool/source-error native-restored-plan and direct neutral/default focused proof. Full prior July/September admission/reading/replay record at Git41b61a86bb51cdc872c71e3b6940f69bdec6f67d for this path."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/logical_result_receivers_test.dart test/default_selected_receivers_test.dart test/logical_receiver_methods_test.dart"

---

runtimeLogicalTruth owns typed truth for helpers and lazy conditions: null,
false, zero/negative-zero, empty String/List/Map are false; other finite numbers,
nonempty Strings including "0"/"false" and nonempty aggregates are true. Valid
and/or/not operands evaluate once left to right into real Bool results. Original
ActionCallExpr arity is checked first; and/or need1+, not exactly1. Native
RuntimeDiagnostic retains helper/code/actual/expected/rule fields, generated
framing keeps deterministic detail, and unrelated diagnostic JSON stays intact.

Logical17.3 independently confirms producers, eager truth/strict numeric-null,
valid bridges/default/source kinds and five typed source-error shapes. Shared
RED reaches container[] instead ofnull; rejected take additionally runs operandA
(orderSA). Actual selected/block/literal Boolean sources also yield[] on sorted.
_evaluateFluentCallsWithValue now starts scalarResult for actual Bool and
retains that boundary after any link yielding Bool. Compatible explicit
containers still release it. Existing named container-context normalization,
free signatures, logical truthiness/error validation and adapters are unchanged.
Fifteen focused tests across new producer/shared/rejected-effect/actual-Bool/
source-error cases, direct defaults and three actual named neutral fixtures
pass native/restored/plan with format/fatal selected analysis. LR/LRC/S source
prefixes survive rejection while incompatible consumer operands stay skipped.
No standalone-emitted or complete domain/context/portable admission follows.

At July admission the typed ActionBlock model row was inert/truthy without
invocation; executable source block operands were separate. Later explicit
callable syntax remains under its own owner rather than this projection. The
full dated 3/5 rollout point, standalone package/CLI/corpus checks and September
consumer-source observations are historical at the exact Git pointer above.

Related: [[logical-helper-neutral-contract]], [[dart-helper-action-surface-bridge]],
[[cross-backend-condition-truthiness-drift]], [[rust-logical-helper-neutral-runtime]].

## Ordinary logical receiver methods, October27

TYPE23.3 adds positional method-shape preflight and a logical receiver branch.
Source snapshot precedes eager RHS; free and receiver calls share evaluated-value
composition without changing runtimeLogicalTruth or free pre-effect validation.
Existing actual-Bool/explicit-container/scope guards suffice. Nine new native/
restored/plan tests plus nine direct logical-result tests pass with format/fatal
analysis: SRTC/kinds/copies, malformed skip, SR/SRC, with restoration/recovery and
typed source-error fields/tokens. Generic value copies preserve Bool (pre-change
and(true).copy()/true.copy()/copy(false) are true/true/false); retain this local
compatibility. TYPE1.2.1.4.2 resolves the differing backend scalar-copy domains
and necessary repairs after family23, before full method/portable admission.
No standalone emitted/context/deferred/callback/serialized-model expansion.

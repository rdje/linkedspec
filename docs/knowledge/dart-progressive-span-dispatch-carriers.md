---
id: dart-progressive-span-dispatch-carriers
title: Dart privately carries progressive span dispatch through four dormant execution routes
answers:
  - "does Dart progressive span dispatch use a dedicated node"
  - "how does Dart compile dispatch_span"
  - "which Dart routes execute progressive span dispatch"
  - "how does Dart seed progressive dispatch authority"
  - "does generated Dart source serialize progressive callbacks"
  - "does Dart reject progressive dispatch in recognition transactions"
  - "why can recognition cleanup mask a Dart runtime error"
  - "is the Dart progressive dispatch consumer admitted in CI"
  - "what remains before Dart progressive rollout"
date: 2026-08-17
status: private Dart carriers complete and dormant; canonical admission and Dart rollout pending
tags: [dart, progressive-parsing, actionir, generated-source, recognition-transaction, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.4.2 replaces the generic helper fallback with one exclusive ActionProgressiveDispatchSpanExpr carrying only target, literal parser id, literal top rule, and bare span binding. The five reserved malformed-operand diagnostics and any residual generic dispatch_span call fail during compilation; runtime also rejects a generic node defensively. Recognition effect closure rejects a recognize_once-reachable rule/function graph containing parser_registry_or_staged_dispatch, while the execution context independently reports live tokens. ProgressiveExecutionSeed is an opaque host-only recipe whose start method creates fresh invocation budget/call state for every top-level parse. Native, SpecFile-JSON reconstructed, generated-plan, and independently analyzed/executed emitted-source routes return the same detached payload. Generated data carries the logical node but no fingerprint, callback, registry, cancellation token, source snapshot, or mutable invocation. Focused testing also found that recognition cleanup replaced an existing runtime error with recognition_terminal_required; leaveRecognitionInvocation now preserves the primary error after the authority has restored and invalidated the unfinished token, while still reporting terminal-required when no prior error exists. The historical final-path consumer is GREEN at 7 groups but remains under test_dormant and absent from canonical CI. Neutral governance records 9 Rust + 8 Dart carrier paths, 2 Julia/Lua pending guards over 8 paths, 10 outward guards, 26 diagnostics, 3/9 rollout, and 100 mutations. Fatal analysis, the 4-group authority consumer, and all 408 ordinary Dart tests pass."
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/progressive_span_dispatch_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/progressive_span_dispatch_authority_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "test ! -e dart/test/progressive_span_dispatch_contract_test.dart && ! rg -q 'dart/test_dormant/progressive_span_dispatch_contract_test[.]dart' tools/run_ci_local.sh"
---

# Private Dart progressive carriers

The authored assignment is one whole-statement node, not a normal helper call:

```text
value = dispatch_span("expr-v1", "Expr", span)
```

Only `value`, `expr-v1`, `Expr`, and `span` enter compiled and generated data. A host supplies an unexported
`ProgressiveExecutionSeed` containing the immutable callback registry, source snapshot, cancellation identity,
budget, capabilities, and ceilings. Each top-level native or generated execution starts fresh invocation state;
all nested dispatch within that execution shares the same narrowing authority and accounting.

The compiler accepts exactly two string literals plus one bare span binding. Malformed direct assignments and
generic calls that escape that exclusive parser fail before execution. Static effect closure rejects any
recognition attempt whose target can reach the node through rule or user-function calls, and the runtime still
checks live tokens defensively for precompiled or reconstructed state.

Native, reconstructed, generated-plan, and independently analyzed emitted source all delegate through the same
logical carrier and return detached child data without advancing the parent cursor. The emitted adapter accepts
the opaque seed as a host argument; it does not serialize callbacks, registry entries, fingerprints, source text,
cancellation handles, budgets, or mutable authority.

The exact consumer remains dormant. `.14.6.4.3` alone may move that unchanged identity into ordinary/canonical
discovery and promote Dart rollout.

## Links

- Authority: [[dart-progressive-span-dispatch-authority]].
- Historical RED: [[dart-progressive-span-dispatch-dormant-red]].
- Neutral model: [[progressive-span-dispatch-audit-plan]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.6.4.2`.

---
id: dart-logical-helper-neutral-runtime
title: Dart logical helpers and lazy controls share one typed truth and pre-effect arity boundary
answers:
  - "where is Dart logical truthiness implemented"
  - "are Dart logical helpers eager or short circuit"
  - "does Dart validate logical helper arity before operand effects"
  - "do Dart logical helpers and lazy controls share truthiness"
  - "which Dart generated roles prove the logical helper contract"
  - "what fields are in a Dart logical arity diagnostic"
  - "does Dart logical parity activate explicit codeblock literals"
date: 2026-07-17
status: current
tags: [dart, logical, truthiness, arity, runtime, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.4 makes runtimeLogicalTruth the Dart helper/control truth seam and validates original ActionCallExpr shape before evaluating operands. dart/test/logical_helper_contract_test.dart consumes linkedspec-logical-helper-v1 across 17 typed rows, values, ordered effects, receivers, lazy controls, four invalid calls, native compiled, normalized reconstruction, generated plan, primary CLI, and an offline compiled standalone emitted package. Format/analyze, 245 tests, CLI 62x2, and corpus 105/105 pass; rollout is 3 complete / 5 pending."
reverify: "bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py && (cd dart && bash ../tools/run_dart_project_data.sh test test/logical_helper_contract_test[.]dart test/diagnostic_output_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings) && rg -n 'runtimeLogicalTruth|_validateLogicalHelperArity|helper_arity_mismatch' dart/lib/src/runtime/interpreter.dart dart/test/logical_helper_contract_test.dart"
---

`runtimeLogicalTruth` is Dart's one typed logical boundary. Null, false, numeric zero including negative zero, the
empty string, and empty lists/maps are false. Every other finite number, every nonempty string including `"0"`
and `"false"`, and every nonempty aggregate are true. Rendering and numeric parsing remain separate operations.

The runtime validates the original `ActionCallExpr` before it evaluates any operand: `and`/`or` require one or
more positional arguments and `not` requires exactly one. Valid operand expressions are then evaluated exactly
once left-to-right into a value list before boolean composition. Lazy condition paths call the same truth seam but
still execute only the selected branch or loop body.

Logical arity failures carry `code`, `helper_name`, `actual_arity`, and `expected_arity` in `RuntimeDiagnostic`,
alongside existing rule/source attribution. Those fields are optional and supplied only by the logical arity path,
so unrelated diagnostics retain their prior JSON shape. Generated framing preserves the deterministic neutral
tokens in its causal detail, and the primary CLI retains its stable invocation-failure projection.

Dart can represent an inert parsed `ActionBlock` at the typed runtime boundary, so the consumer proves the
codeblock row without invoking it. Portable source block expressions remain executable operands; this model-level
test does not activate the separately owned explicit `{|...| ... }` literal program.

Related facts: [[logical-helper-neutral-contract]], [[logical-helper-five-backend-audit]],
[[cross-backend-condition-truthiness-drift]], [[dart-helper-action-surface-bridge]],
[[rust-logical-helper-neutral-runtime]].

## September 10 complete logical-consumer reading

`DART-STARTUP-READING.1.39` reads all 454 lines of the logical-helper consumer. The selected
40-test suite passes, including its independent emitted caller. The neutral checker now
reports seventeen truth rows, ten helper cases, three effect cases, eight complete/zero
pending legs, nineteen public documents, fourteen stale-current denials and twenty-six
mutations; the earlier 3/5 admission count above is historical.

All four invalid arities are exercised through native, reconstructed, generated direct/
traced and primary routes. The separate offline caller is strictly analyzed and executes
three value/effect/control modules plus only the `not_many` invalid module. Its paired
direct/traced failure checks preserve source identity and causal arity detail; this is
not independent emitted coverage of all four invalid cases. The typed ActionBlock truth
row does not itself execute a portable literal. Existing callback nesting limitations
remain owned by [[dart-callback-helper-recursion-identity-gap]]; no new defect is confirmed.

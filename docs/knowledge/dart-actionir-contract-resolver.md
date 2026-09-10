---
id: dart-actionir-contract-resolver
title: Dart ActionIR resolves typed helper/action nodes against the current helper contract table
answers:
  - does Dart resolve ActionIR helper contracts
  - where is the Dart ActionIR contract resolver
  - does Dart encode non-current helper spellings
  - how does Dart classify non-current helper calls
  - does Dart reserve built-in helper names for functions
  - how does Dart resolve user function calls before helper fallback
date: 2026-09-09
status: current
tags: [dart, actionir, contracts, helper-surface, validation, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.3.2 adds dart/lib/src/action/action_contracts.dart and test/action_contracts_test.dart. The resolver entrypoints walk typed ActionIR calls, receiver methods, structural assignments, structured controls, nested arguments, block values, shapes, and access expressions, recording current canonical helper/control contracts. Non-current helper-looking calls produce unknown_helper. spec_validator.dart now shares isKnownActionIrCallName(...) so user functions collide with active built-in helper/control names. DART-BACKEND-PARITY.3.3 adds optional UserFunctionRegistry input to the resolver entrypoints so exact-arity user calls classify before helper fallback, while wrong-arity registered calls diagnose as user_function_arity_mismatch. Focused Dart tests and analyzer pass."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded test/action_contracts_test.dart test/action_ast_parser_test.dart test/uniform_binding_contract_test.dart test/callable_codeblock_literal_contract_test.dart"
---

Dart ActionIR contract resolution lives in
`dart/lib/src/action/action_contracts.dart`.

Public resolver entrypoints:

- `resolveActionBlockContracts(...)`
- `resolveActionStatementContracts(...)`
- `resolveActionExpressionContracts(...)`
- `canonicalActionHelperName(...)`
- `isKnownActionIrCallName(...)`

The resolver records current canonical helper/control contracts from typed
ActionIR nodes: function calls, receiver methods, structural assignments,
structured controls, nested arguments, block values, shape literals, and direct
access expressions. It does not carry a compatibility table for non-current helper
spellings. Helper-looking names outside the current contract table produce the
generic `unknown_helper` diagnostic.

When callers pass `UserFunctionRegistry`, the resolver checks exact-arity user
function calls before helper fallback. Exact matches record `family =
user_function`; wrong-arity registered calls produce
`user_function_arity_mismatch` instead of `unknown_helper`.

`dart/lib/src/validation/spec_validator.dart` shares the same current-name table
for user-function registry collision checks, so validation no longer maintains a
second helper list.

## Startup reading reconciliation — 2026-09-09

DART-STARTUP-READING.1.2 physically reads action_ast.dart lines 660–1470 and
action_contracts.dart lines 1–689: 1,500 fragments / 36,093 baseline-identical
bytes. Together with .1.1 this completes the node model. Assignment and mutation
nodes retain typed targets, callback bodies and ordinary continuation calls;
structured controls retain their branch/body nodes and spans.

The current known-name union includes supported canonical names, numeric
aliases, current aliases and accepted source-boundary compatibility aliases.
For example, add maps to num_add, when maps to if, and capture_from_rule_start
maps to capture_slice. These are accepted names in the current table; the
generic unknown_helper statement above concerns names outside that table.
The range ends inside _familyForCanonical; the remaining classifier and
resolver implementation are owned by .1.3 and are not newly credited here.

The complete AST's exact array/hash selector walk treats callable literal
bodies as deferred leaves, consistent with [[dart-callable-codeblock-literal-state]].
Its presence does not revive removed selectors or imply eager body execution.
The old scaffold-era whole-Dart text negation in this card's verification
command is replaced with current focused tests, which pass 50/50. This refresh
changes documentation only and establishes no new code defect.

Related facts: [[dart-actionir-ast-parser]], [[dart-backend-scaffold-package]],
[[dart-function-registry]], [[text-to-ast-backend-doctrine]],
[[dart-backend-interpreter-first-plan]].

## 2026-09-10 — initial action test-source reading

`DART-STARTUP-READING.1.35` reads all 189 action-parser test lines and
action-contract tests 1-203. Assertions cover typed literals/access/assignments,
fluent and contextual trailing blocks, quoted delimiters, controls and Raw
fallback; canonical numeric/helper mappings, nested writes, generic diagnostics,
registry collisions, gap-family membership and exact-arity user calls. The last
two contract helper lines remain .1.36 reading. All 35 selected validator/action/
root/gap/duplicate tests pass. Existing switch, lexical, registry and semantic
findings retain their separate repair owners; no stronger completeness follows
from these selected examples.

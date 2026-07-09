---
id: dart-actionir-contract-resolver
title: Dart ActionIR resolves typed helper/action nodes against the current helper contract table
answers:
  - does Dart resolve ActionIR helper contracts
  - where is the Dart ActionIR contract resolver
  - does Dart encode non-current helper spellings
  - how does Dart classify non-current helper calls
  - does Dart reserve built-in helper names for functions
date: 2026-07-09
status: current
tags: [dart, actionir, contracts, helper-surface, validation, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.3.2 adds dart/lib/src/action/action_contracts.dart and test/action_contracts_test.dart. The resolver entrypoints walk typed ActionIR calls, receiver methods, structural assignments, structured controls, nested arguments, block values, shapes, and access expressions, recording current canonical helper/control contracts. Non-current helper-looking calls produce unknown_helper. spec_validator.dart now shares isKnownActionIrCallName(...) so user functions collide with active built-in helper/control names. Focused Dart tests, analyzer, and Dart-tree source scans pass."
reverify: "cd dart && dart test test/action_contracts_test.dart test/action_ast_parser_test.dart test/spec_parser_test.dart test/spec_validator_test.dart && dart analyze --fatal-infos --fatal-warnings && cd .. && ! rg -n 'retired|replacement map|non-current helper spelling table' dart"
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

`dart/lib/src/validation/spec_validator.dart` shares the same current-name table
for user-function registry collision checks, so validation no longer maintains a
second helper list.

Related facts: [[dart-actionir-ast-parser]], [[dart-backend-scaffold-package]],
[[text-to-ast-backend-doctrine]], [[dart-backend-interpreter-first-plan]].

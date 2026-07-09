---
id: dart-function-registry
title: Dart user-function registry preserves staged sidecars and resolves exact-arity calls before helper fallback
answers:
  - where is the Dart user function registry
  - how does Dart preserve function body parse jobs
  - how does Dart resolve user function calls before helper fallback
  - does Dart stitch function body AST into registry records
date: 2026-07-09
status: current
tags: [dart, actionir, functions, staged-parsing, registry, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.3.3 adds dart/lib/src/action/function_registry.dart, exports UserFunctionRegistry/UserFunctionEntry/UserFunctionCallResolution, and threads optional registry input through the ActionIR contract resolver. DART-BACKEND-PARITY.5.1 adds Dart staged body_ast stitching before later runtime execution. test/function_registry_test.dart verifies ordered entries, staged body_parse_job exposure, body_payload/body_ast preservation, exact match, wrong arity, missing name, and duplicate-name rejection. test/action_contracts_test.dart verifies exact-arity user calls classify before helper fallback and wrong arity reports user_function_arity_mismatch. test/staged_parser_registry_test.dart verifies body_ast stitching."
reverify: "cd dart && dart test test/function_registry_test.dart test/action_contracts_test.dart test/staged_parser_registry_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart's user-function registry lives in
`dart/lib/src/action/function_registry.dart`.

`UserFunctionRegistry.fromSpec(...)` and `UserFunctionRegistry.fromFunctions(...)`
build ordered `UserFunctionEntry` records from `FunctionDefinition` values. Each
entry preserves the function params, arity, source/body spans, `body_payload`,
`body_parse_job`, and optional stitched `body_ast`. The registry exposes
`bodyParseJobs`; the staged registry can now dispatch those jobs and return a
stitched `SpecFile` before later user-function runtime execution.

The ActionIR contract resolver accepts an optional `UserFunctionRegistry`. With
that registry, exact-arity function calls classify as `user_function` before
helper fallback. If the name is registered but the arity is wrong, the resolver
emits `user_function_arity_mismatch` instead of treating the call as an unknown
helper.

Related facts: [[dart-actionir-contract-resolver]], [[dart-backend-scaffold-package]],
[[dart-function-definition-shell-projection]], [[dart-staged-function-body-registry]],
[[staged-linked-parsing-architecture]].

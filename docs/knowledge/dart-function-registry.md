---
id: dart-function-registry
title: Dart user-function registry preserves staged sidecars and resolves fixed or variadic calls before helper fallback
answers:
  - where is the Dart user function registry
  - how does Dart preserve function body parse jobs
  - how does Dart resolve user function calls before helper fallback
  - does Dart stitch function body AST into registry records
date: 2026-07-09
status: current
tags: [dart, actionir, functions, staged-parsing, registry, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.3.3/.5.1/.5.2 established exact-arity registry/staged/runtime execution. FUTURE-PARITY-BACKLOG.4.3.1 adds typed v2 signatures, minimum-arity resolution, positional-only diagnostics, and fresh rest binding while preserving fixed v1 behavior."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/function_registry_test[.]dart test/action_contracts_test[.]dart test/staged_parser_registry_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart's user-function registry lives in
`dart/lib/src/action/function_registry.dart`.

`UserFunctionRegistry.fromSpec(...)` and `UserFunctionRegistry.fromFunctions(...)`
build ordered `UserFunctionEntry` records from `FunctionDefinition` values. Each
entry preserves the function signature, normalized params/arity, source/body spans, `body_payload`,
`body_parse_job`, and optional stitched `body_ast`. The registry exposes
`bodyParseJobs`; the staged registry can dispatch those jobs and return a
stitched `SpecFile`, and the runtime interpreter executes fixed exact-arity or
variadic minimum-arity registered calls before helper fallback.

The ActionIR contract resolver accepts an optional `UserFunctionRegistry`. With
that registry, accepted fixed or variadic function calls classify as `user_function` before
helper fallback. Keywords diagnose as unsupported. If the name is registered but the arity is wrong, the resolver
emits `user_function_arity_mismatch` instead of treating the call as an unknown
helper.

## Registry and callable reading — 2026-09-09

DART-STARTUP-READING.1.5 physically completes function_registry.dart and
callable_contract.dart. Registry construction rejects duplicate names before
insertion, preserves source order and freezes its entry/name containers.
Descriptor records select version 3 for typed parameter kinds, otherwise v1
without a signature or v2 with one; fixed/variadic matching stays metadata-owned.

Final-codeblock normalization is structural and may recurse into retained
callable bodies. It is distinct from eager helper/dependency resolution and
runtime body execution. Builtin/helper/receiver and typed user-function metadata
select the final slot; unadmitted parenthesized candidates become eager blocks,
while unadmitted attached candidates fail. Existing canonical callable facts
remain authoritative; the 55 selected tests pass. The same reading checkpoint's
regex defects are separately owned in [[dart-regex-brace-scanner-defects]].

Related facts: [[dart-actionir-contract-resolver]], [[dart-backend-scaffold-package]],
[[dart-function-definition-shell-projection]], [[dart-staged-function-body-registry]],
[[dart-user-function-runtime-execution]], [[staged-linked-parsing-architecture]].

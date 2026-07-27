---
id: dart-variadic-user-functions
title: Dart preserves v1 fixed functions and executes v2 variadic functions natively and from generated state
answers:
  - "does Dart support variadic user functions"
  - "where does Dart bind a rest parameter"
  - "does Dart evaluate variadic arguments left to right"
  - "are Dart rest arrays fresh per invocation"
  - "does Dart preserve variadic signatures in staged records"
  - "does Dart generated source preserve callable signatures"
  - "does Dart allow keyword arguments for user functions"
date: 2026-07-12
status: current
tags: [dart, functions, variadic, rest-parameter, descriptor, staged-parsing, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.4.3.1 updates Dart AST/staged projection, validation, registry/action resolution, runtime, descriptors, and normalized emitted state. Six tests in variadic_user_function_contract_test.dart consume the unchanged neutral fixture; tools/run_dart_local.sh passes 190 package tests, 61x2 CLI, and 105 corpus."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/variadic_user_function_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart accepts `fn name(fixed, ...rest) { ... }` through the shared spec-defined shell. A typed
`CallableSignature` survives `FunctionDefinition`, `StagedParseJob`, registry entries, exact descriptor projection,
normalized source-emitter JSON, generated-plan execution, and generated-state reconstruction. Internally derived
prefix params and minimum arity reuse the established execution model; v2 staged/public records omit those legacy
keys and expose only the authoritative signature. Fixed v1 records remain unchanged.

The registry accepts an argument count when it equals fixed v1 arity or meets v2 `min_arity`. ActionIR and runtime
resolution reject keyword arguments for registered functions, so Dart named-argument behavior does not enter the
`.spec` contract. Accepted arguments evaluate once left-to-right in caller scope. The runtime clears to fresh local
stores, binds fixed params, and uses the ordinary deep-copying parameter binder to store a newly allocated list of
all extras under the rest name. Empty, nested, hash, boolean, and null values preserve their shapes.

`emitDartSourceV2` needs no host-specific rest logic: `SpecFile.toJson()` emits the v1/v2 union into its strict
UTF-8/Base64 payload, and the generated library reconstructs `SpecFile.fromJson()` before compiling and executing
the same runtime. The neutral fixture passes both direct generated-plan execution and this serialization round-trip.

---
id: dart-backend-scaffold-package
title: Dart backend scaffold package lives under dart/ and has manifest IO, AST types, parser, validator, ActionIR contracts, and a function registry
answers:
  - where is the Dart backend package
  - how do I run the Dart backend scaffold checks
  - what does the Dart scaffold implement so far
  - how does the Dart corpus runner validate the manifest
  - where are the Dart AST data types
  - where is the Dart spec parser
  - where is the Dart spec validator
  - where is the Dart ActionIR contract resolver
  - where is the Dart user function registry
  - does the Dart package implement runtime semantics yet
  - is pubspec.lock committed for the Dart backend
date: 2026-07-09
status: current
tags: [dart, backends, package, scaffold, corpus, ast, parser, validation, actionir, contracts, tests]
evidence: "DART-BACKEND-PARITY.1.2 creates the Dart package scaffold; DART-BACKEND-PARITY.1.3 adds corpus manifest IO; DART-BACKEND-PARITY.2.1 adds dart/lib/src/ast/spec_ast.dart and JSON round-trip tests; DART-BACKEND-PARITY.2.2 adds dart/lib/src/parser/spec_parser.dart and parser fixtures; DART-BACKEND-PARITY.2.3 adds dart/lib/src/validation/spec_validator.dart and validation fixtures; DART-BACKEND-PARITY.3.1 adds typed ActionIR parsing; DART-BACKEND-PARITY.3.2 adds dart/lib/src/action/action_contracts.dart; DART-BACKEND-PARITY.3.3 adds dart/lib/src/action/function_registry.dart and exact-arity user-call classification."
reverify: "git ls-files dart && (cd dart && dart format --set-exit-if-changed . && dart analyze --fatal-infos --fatal-warnings && dart test && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus)"
---

The Dart backend scaffold is the repo-owned package under `dart/`. It currently provides package
metadata, a committed `pubspec.lock`, analyzer options, a package README, public scaffold API,
`bin/linkedspec_dart.dart`, `bin/corpus_runner.dart`, corpus manifest IO, source-level AST/data types,
the core `parseSpec(...)` rule parser, `validateSpec(...)`, and `package:test` smoke/parser/validation tests.

The corpus IO layer loads the checked-in corpus under `rust/linkedspec-runtime/tests/corpus/`, validates
manifest format/count/name shape, detects missing or stale fixture directories, requires `input.spec`,
`input.txt`, and `expected.json`, and parses expected JSON.

`dart/lib/src/ast/spec_ast.dart` defines AST/staged-parse-job types that round-trip through JSON.
`dart/lib/src/parser/spec_parser.dart` parses core `.spec` rule paragraphs into those AST types.
`dart/lib/src/validation/spec_validator.dart` validates parsed source ASTs in non-strict or strict mode.
`dart/lib/src/parser/user_function_definition_shell.dart` projects spec-returned function-definition nodes
into `FunctionDefinition` records without raw-scanning `fn` source.
`dart/lib/src/action/action_parser.dart` now parses helper/action source into typed ActionIR nodes.
`dart/lib/src/action/action_contracts.dart` resolves those nodes against the current helper/control
contract table. `dart/lib/src/action/function_registry.dart` builds ordered user-function registry entries
from `FunctionDefinition` records, exposes staged body parse jobs, and lets contract resolution classify
exact-arity user calls before helper fallback. The package does not implement compiled-spec state, runtime
semantics, or corpus output comparison yet.

Related facts: [[dart-core-spec-parser]], [[dart-frontend-validation]],
[[dart-function-definition-shell-projection]], [[dart-actionir-ast-parser]],
[[dart-actionir-contract-resolver]], [[dart-function-registry]],
[[dart-backend-interpreter-first-plan]],
[[text-to-ast-backend-doctrine]], [[rust-perl-output-oracle]].

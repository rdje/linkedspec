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
  - does Dart have a controlled corpus execution harness
  - does the Dart corpus runner have opt-in execute mode
  - is pubspec.lock committed for the Dart backend
date: 2026-07-09
status: current
tags: [dart, backends, package, scaffold, corpus, ast, parser, validation, actionir, contracts, tests]
evidence: "DART-BACKEND-PARITY.1.2 creates the Dart package scaffold; DART-BACKEND-PARITY.1.3 adds corpus manifest IO; DART-BACKEND-PARITY.2.1 adds dart/lib/src/ast/spec_ast.dart and JSON round-trip tests; DART-BACKEND-PARITY.2.2 adds dart/lib/src/parser/spec_parser.dart and parser fixtures; DART-BACKEND-PARITY.2.3 adds dart/lib/src/validation/spec_validator.dart and validation fixtures; DART-BACKEND-PARITY.3.1 adds typed ActionIR parsing; DART-BACKEND-PARITY.3.2 adds dart/lib/src/action/action_contracts.dart; DART-BACKEND-PARITY.3.3 adds dart/lib/src/action/function_registry.dart and exact-arity user-call classification; DART-BACKEND-PARITY.3.4 adds compiled-spec state; DART-BACKEND-PARITY.4.1 adds runtime matching; DART-BACKEND-PARITY.4.2 adds the first runtime rule interpreter; DART-BACKEND-PARITY.6.1 adds executeCorpusFixtures for controlled manifest fixtures; DART-BACKEND-PARITY.6.2.1 adds opt-in named/bounded corpus execution selection; DART-BACKEND-PARITY.6.3 enables full-manifest CLI execution and proves the checked-in 99-fixture corpus green."
reverify: "git ls-files dart && (cd dart && bash ../tools/run_dart_project_data.sh format --set-exit-if-changed . && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && bash ../tools/run_dart_project_data.sh test && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute)"
---

The Dart backend scaffold is the repo-owned package under `dart/`. It currently provides package
metadata, a committed `pubspec.lock`, analyzer options, a package README, public scaffold API,
`bin/linkedspec_dart.dart`, `bin/corpus_runner.dart`, corpus manifest IO, source-level AST/data types,
the core `parseSpec(...)` rule parser, `validateSpec(...)`, and `package:test` smoke/parser/validation tests.

The corpus IO layer loads the checked-in corpus under `rust/linkedspec-runtime/tests/corpus/`, validates
manifest format/count/name shape, detects missing or stale fixture directories, requires `input.spec`,
`input.txt`, and `expected.json`, and parses expected JSON. The executable corpus layer now also exposes
`executeCorpusFixtures(...)` for manifest-backed fixtures; it runs parse/compile/runtime and compares
the Dart engine output against `[expected]` with structural JSON equality. It now supports `caseNames`, `offset`,
and `limit`, and `bin/corpus_runner.dart --execute` exposes named/bounded execution plus full-manifest execution
when no selector is supplied. The checked-in 99-fixture corpus is green through Dart execute mode.

`dart/lib/src/ast/spec_ast.dart` defines AST/staged-parse-job types that round-trip through JSON.
`dart/lib/src/parser/spec_parser.dart` parses core `.spec` rule paragraphs into those AST types.
`dart/lib/src/validation/spec_validator.dart` validates parsed source ASTs in non-strict or strict mode.
`dart/lib/src/parser/user_function_definition_shell.dart` projects spec-returned function-definition nodes
into `FunctionDefinition` records without raw-scanning `fn` source.
`dart/lib/src/action/action_parser.dart` now parses helper/action source into typed ActionIR nodes.
`dart/lib/src/action/action_contracts.dart` resolves those nodes against the current helper/control
contract table. `dart/lib/src/action/function_registry.dart` builds ordered user-function registry entries
from `FunctionDefinition` records, exposes staged body parse jobs, and lets contract resolution classify
exact-arity user calls before helper fallback. It now also builds compiled-spec
state, performs runtime regex matching, executes the rule-dispatch interpreter
layer, and runs the checked-in 99-fixture corpus through execute mode.

Related facts: [[dart-core-spec-parser]], [[dart-frontend-validation]],
[[dart-function-definition-shell-projection]], [[dart-actionir-ast-parser]],
[[dart-actionir-contract-resolver]], [[dart-function-registry]],
[[dart-compiled-spec-state]], [[dart-runtime-matching-state]],
[[dart-runtime-rule-interpreter]], [[dart-controlled-corpus-execution]],
[[dart-backend-interpreter-first-plan]], [[text-to-ast-backend-doctrine]],
[[rust-perl-output-oracle]].

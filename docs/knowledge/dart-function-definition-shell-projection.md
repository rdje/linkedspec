---
id: dart-function-definition-shell-projection
title: Dart consumes spec-returned user-function definition AST nodes instead of raw-scanning fn source
answers:
  - does Dart parse user function definitions
  - does Dart raw-scan fn definitions
  - how does Dart consume specs/user_function_definition.spec output
  - where is Dart function-definition shell projection
  - does Dart preserve function body parse jobs
  - what owns Dart function-definition shell semantics
date: 2026-07-09
status: current
tags: [dart, parser, user-functions, staged-parsing, ast]
evidence: "DART-BACKEND-PARITY.2.4 adds dart/lib/src/parser/user_function_definition_shell.dart and test/user_function_definition_shell_test.dart. The projection APIs consume function_definition / function_definition_error nodes returned by specs/user_function_definition.spec, validate spans and staged sidecars, normalize parent_ast_path and body_parse_job ids, strip returned source spans, and attach FunctionDefinition records before rule parsing. Tests assert successful projection, malformed-node diagnostics, sidecar drift rejection, and that empty-node parsing does not raw-scan a leading fn shell."
reverify: "cd dart && dart test test/user_function_definition_shell_test.dart test/spec_ast_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart function-definition shell semantics now follow the same owner boundary as
Perl and Rust: `specs/user_function_definition.spec` owns the returned
`function_definition` / `function_definition_error` AST shape.

The Dart frontend does not execute that `.spec` yet and does not raw-scan `fn`
source as a replacement. Instead, `parseSpecWithUserFunctionDefinitionAsts(...)`
and `projectUserFunctionDefinitionAsts(...)` consume the node list returned by
the owning spec. The projection validates source/body spans against the original
source, validates `body_payload` and `body_parse_job`, normalizes source-order
`parent_ast_path` values to `functions.<index>.body_source`, derives the
deterministic body parse-job id, strips the returned definition spans while
preserving line layout, and attaches ordered `FunctionDefinition` records before
ordinary rule parsing.

`StagedParseJob` now preserves the function-body sidecar metadata emitted by the
spec (`version`, `function_name`, `params`, `arity`, and `diagnostic_owner`) in
JSON round-trips. Dispatching the body parse job into a typed `body_ast` remains
a later helper/action AST and staged-registry lane.

Related facts: [[spec-defined-user-function-definition-parser]],
[[function-body-parse-job-sidecar]], [[dart-core-spec-parser]],
[[dart-frontend-ast-json-contract]].

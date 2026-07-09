---
id: dart-frontend-ast-json-contract
title: Dart frontend AST types mirror Rust parsed-AST and staged parse-job JSON fields
answers:
  - what Dart types represent parsed spec files
  - how do Dart AST types serialize to JSON
  - what fields does the Dart staged parse job use
  - where are Dart rule mode and body element data types
  - what Dart AST types does the parser produce
date: 2026-07-09
status: current
tags: [dart, ast, parser, json, staged-parsing]
evidence: "DART-BACKEND-PARITY.2.1 adds dart/lib/src/ast/spec_ast.dart and dart/test/spec_ast_test.dart; the tests round-trip SpecFile, FunctionDefinition, SourceSpan, StagedParseJob, RuleMode, body elements, edges, and fluent calls through JSON. DART-BACKEND-PARITY.2.2 adds parseSpec(...) as the first producer of these rule AST types."
reverify: "cd dart && dart test test/spec_ast_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart source-level AST/data types live in `dart/lib/src/ast/spec_ast.dart`.
They cover `SpecFile`, `FunctionDefinition`, `SourceSpan`, `StagedParseJob`,
`Rule`, `RuleHeader`, `RuleMode`, body element variants, `EdgeTarget`, and `FluentCall`.

The JSON names intentionally follow the existing Rust/mdBook contracts, including
`functions`, `rules`, `source_span`, `body_span`, `body_parse_job`, `line_start`,
`line_end`, `parent_ast_path`, `result_policy`, and `failure_policy`.

Dart `parseSpec(...)` now produces these rule AST types. Function-definition
body ASTs remain neutral JSON sidecars until later helper/action AST leaves type
them further.

Related facts: [[dart-core-spec-parser]], [[dart-backend-scaffold-package]],
[[dart-backend-interpreter-first-plan]], [[text-to-ast-backend-doctrine]].

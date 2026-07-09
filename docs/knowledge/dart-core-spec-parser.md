---
id: dart-core-spec-parser
title: Dart core spec parser produces source ASTs for rule paragraphs
answers:
  - does Dart parse spec files yet
  - where is the Dart spec parser
  - what does parseSpec support
  - does Dart parse shipped specs
  - does Dart parse corpus input specs
  - are Dart function definitions parsed yet
  - what is the Dart parser validation boundary
  - does Dart validation exist after parsing
date: 2026-07-09
status: current
tags: [dart, parser, ast, corpus, shipped-specs]
evidence: "DART-BACKEND-PARITY.2.2 adds dart/lib/src/parser/spec_parser.dart and dart/test/spec_parser_test.dart. Tests cover focused Rust-compatible parser seams, all checked-in specs/*.spec files, and corpus input.spec files that do not start with top-level fn definitions. DART-BACKEND-PARITY.2.3 adds validateSpec(...) as the next source-AST validation layer. DART-BACKEND-PARITY.2.4 keeps parseSpec(...) rule-only while adding a separate spec-returned function-definition projection path."
reverify: "cd dart && dart test test/spec_parser_test.dart test/spec_validator_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart `parseSpec(...)` lives in `dart/lib/src/parser/spec_parser.dart` and is
exported from `dart/lib/linkedspec_dart.dart`. It parses core `.spec` rule
paragraphs into the source AST types from `dart/lib/src/ast/spec_ast.dart`.

Supported parser shapes include rule headers, rule modes, header-rest body
elements, regex literals, lifecycle blocks, action and blind-call edges,
action-edge fluent continuations, receiver-fluent `when/otherwise` blocks,
split/conditional markers, comments, raw fallback lines, and nested block
boundaries.

The parser deliberately mirrors the Rust core parser boundary: it is permissive
source parsing, with `validateSpec(...)` providing the next validation layer.
It still does not raw-scan top-level `fn name(args) { ... }` definitions from
source. Dart function definitions now enter through the separate
`parseSpecWithUserFunctionDefinitionAsts(...)` projection path, which consumes
the node shape returned by `specs/user_function_definition.spec`.

Related facts: [[dart-frontend-ast-json-contract]], [[dart-backend-scaffold-package]],
[[dart-frontend-validation]], [[dart-function-definition-shell-projection]],
[[text-to-ast-backend-doctrine]].

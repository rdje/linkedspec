---
id: dart-actionir-ast-parser
title: Dart parses helper/action source into typed ActionIR AST nodes
answers:
  - does Dart parse helper action code into AST
  - where is the Dart ActionIR AST parser
  - what Dart ActionIR nodes exist
  - does Dart parse receiver chains
  - does Dart parse attached control flow
  - does Dart use text to AST for helper code
date: 2026-07-09
status: current
tags: [dart, actionir, ast, parser, text-to-ast]
evidence: "DART-BACKEND-PARITY.3.1 adds dart/lib/src/action/action_ast.dart, dart/lib/src/action/action_parser.dart, and test/action_ast_parser_test.dart. The parser entrypoints parseActionBlock/parseActionStatement/parseActionExpression cover calls, positional and keyword args, literals, variables, indexed/nested access, array/hash literals, scalar/array/hash/nested assignments, block values, attached controls, receiver chains, trailing block args, value-drop statements, and structural raw_perl fallback."
reverify: "cd dart && dart test test/action_ast_parser_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart helper/action text now has a typed ActionIR parser seam:
`dart/lib/src/action/action_parser.dart`. Its public entrypoints are
`parseActionBlock(...)`, `parseActionStatement(...)`, and
`parseActionExpression(...)`; the node model lives in
`dart/lib/src/action/action_ast.dart`.

The parser produces structural nodes for action blocks, standalone value-drop
statements, calls, positional and keyword arguments, primitive literals, regex
literals, variables, indexed and nested access, array/hash shape literals,
scalar assignment, array append, hash-index assignment, nested-access assignment,
expression-valued blocks, receiver-dot fluent chains, trailing block arguments,
and attached `if`/`when`/`elseif`/`else`/`otherwise`, `while`, and
`switch`/`case`/`default` controls.

Unsupported expressions stay as explicit `raw_perl` nodes. This preserves the
frontend shape for diagnostics without doing text-to-text rewriting or host-code
fallback. Canonical helper-family mapping is now owned by
[[dart-actionir-contract-resolver]]; compiled-spec construction and runtime
execution remain later Dart leaves.

Related facts: [[text-to-ast-backend-doctrine]],
[[perl-actionir-ast-parser-seam]], [[dart-backend-interpreter-first-plan]],
[[dart-actionir-contract-resolver]], [[dart-backend-scaffold-package]].

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
  - does Dart support punctuation light zero argument calls
  - can Dart receiver methods omit final parentheses
  - is bare next a statement or variable in Dart
date: 2026-07-13
status: current
tags: [dart, actionir, ast, parser, text-to-ast]
evidence: "DART-BACKEND-PARITY.3.1 adds dart/lib/src/action/action_ast.dart, dart/lib/src/action/action_parser.dart, and test/action_ast_parser_test.dart. The parser entrypoints parseActionBlock/parseActionStatement/parseActionExpression cover calls, positional and keyword args, literals, variables, indexed/nested access, array/hash literals, scalar/array/hash/nested assignments, block values, attached controls, receiver chains, trailing block args, value-drop statements, and structural raw_perl fallback. FUTURE-PARITY-BACKLOG.16.4 adds exact statement-context bare next and final-only bare receiver normalization, with equal typed ASTs and unchanged exclusions proved by punctuation_light_zero_arg_contract_test.dart."
reverify: "cd dart && dart test test/action_ast_parser_test.dart test/punctuation_light_zero_arg_contract_test.dart && dart analyze --fatal-infos --fatal-warnings"
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

The punctuation-light seam is deliberately contextual. Exact bare `next` becomes a zero-argument call only when
parsed as a complete statement; expression/value-position `next` remains a variable. A generic bare receiver
identifier becomes the existing empty-argument fluent call only in the final chain segment. Intermediate receiver
segments, condition headers, general calls, and trailing-block receivers retain their parenthesized grammar.

Unsupported expressions stay as explicit `raw_perl` nodes. This preserves the
frontend shape for diagnostics without doing text-to-text rewriting or host-code
fallback. Canonical helper-family mapping is now owned by
[[dart-actionir-contract-resolver]]. Later `DART-BACKEND-PARITY` leaves have
since added compiled-spec construction and the first runtime interpreter layers.

Related facts: [[text-to-ast-backend-doctrine]],
[[perl-actionir-ast-parser-seam]], [[dart-backend-interpreter-first-plan]],
[[dart-actionir-contract-resolver]], [[dart-runtime-value-control-tree-helpers]],
[[dart-backend-scaffold-package]].

---
id: dart-middle-corpus-batch
title: Dart middle corpus batch is green except for spec-defined fn shell routing
answers:
  - "does Dart pass the middle helper corpus batch"
  - "which Dart corpus fixtures still fail in the middle batch"
  - "why do Dart top-level fn corpus fixtures still fail"
  - "does Dart preserve assignment expressions inside call arguments"
  - "does Dart inline if support a plain else value"
  - "does Dart read scalar-held arrays through array(name)"
  - "what does DART-BACKEND-PARITY.6.2.3 prove"
date: 2026-07-09
status: current
tags: [dart, corpus, runtime, actionir, user-functions, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.3 updates dart/lib/src/action/action_parser.dart and dart/lib/src/runtime/interpreter.dart. ActionIR call arguments now preserve `items = [value]` as ActionAssignScalarExpr positional arguments; inline if accepts plain third-argument fallback values; numeric aggregate reducers evaluate single bare-array args through the aggregate-aware path; array/hash/copy reads prefer scalar-held list/map values; explicit aggregate writes clear stale scalar-held values. The middle corpus window is 25/28 green via split bounded runs around three routed top-level fn cases. The routed failures are parseSpec failures for terse_3_3_1_scalar_assignment_expressions, terse_3_3_4_assignment_expression_closure, and terse_4_3_2_user_function_runtime because the corpus runner does not yet obtain spec-produced function_definition nodes."
reverify: "cd dart && dart test test/action_ast_parser_test.dart test/runtime_interpreter_test.dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 40 --limit 17 && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 58 --limit 2 && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 62 --limit 6 && dart analyze --fatal-infos --fatal-warnings"
---

`DART-BACKEND-PARITY.6.2.3` closes the non-`fn` middle helper/control/receiver
corpus fixtures on Dart. The owned window is 25/28 green.

Runtime/parser behavior locked by this leaf:

- `items = [value]` inside helper argument lists remains an assignment
  expression, not a keyword argument with the side effect stripped.
- Inline value `if(...)` accepts both branch-helper form
  `if(cond, then, else(value))` and plain fallback form `if(cond, then, value)`.
- Function-style numeric aggregate reducers such as `min(scores)` and
  `max(scores)` read bare array working variables.
- Scalar-held list/map values from the duck-typed assignment contract are visible
  through `array(name)`, `hash(name)`, and `copy(name)`.
- Explicit aggregate writes such as `set(array(name), ...)` and
  `set_key(hash(name), ...)` clear stale scalar-held values before later
  wrapper/receiver reads.

The remaining middle-window failures are the top-level `fn` corpus fixtures:
`terse_3_3_1_scalar_assignment_expressions`,
`terse_3_3_4_assignment_expression_closure`, and
`terse_4_3_2_user_function_runtime`. Dart can execute registered functions once
they are projected, but the corpus runner currently calls `parseSpec(...)`
directly and has no spec-produced `function_definition` nodes to pass into
`parseSpecWithStagedUserFunctionDefinitionAsts(...)`. That gap is routed to
`DART-BACKEND-PARITY.6.2.5`; adding a Dart raw scanner would contradict the
current function-shell boundary.

Related facts: [[dart-controlled-corpus-execution]],
[[dart-function-definition-shell-projection]],
[[dart-user-function-runtime-execution]], [[dart-starter-corpus-batch]],
[[terse-duck-typed-assignment-perl-reference]].

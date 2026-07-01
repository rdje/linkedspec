---
id: terse-user-defined-functions-mvp-contract
title: SPEC-FORMAT-TERSE.4 user-defined function MVP contract
answers:
  - "are user-defined functions accepted in specc"
  - "what is the first user function syntax"
  - "does fn name(args) work"
  - "can a function call be a receiver-dot receiver"
  - "are function calls value expressions"
  - "what happens when a function return value is unused"
  - "are unused function call results dropped"
  - "does the MVP include recursion closures lambdas currying"
  - "which task owns user-defined functions"
  - "where should fn syntax be implemented"
  - "should fn live in the bootstrap parser"
  - "should fn support be removed from the bootstrap parser"
  - "does spec.spec own user function syntax"
date: 2026-07-01
status: current
tags: [spec-format-terse, user-functions, value-expressions, receiver-dot, task-tree]
evidence: "SPEC-FORMAT-TERSE.4 was split/owned on 2026-07-01 after explicit user direction to implement custom/user-defined functions. The task-tree acceptance contract defines the MVP as top-level fn name(args) { ... } with explicit parentheses, pure value/block bodies, explicit positional parameters, no implicit caller-state capture, and no recursion/closures/lambdas/currying. User clarification requires function calls to be ordinary value expressions whose results can feed receiver-dot chains, and unused standalone call results to be silently discarded. PERL-ACTIONIR-AST-MIGRATION.5.4 locked permanent fn grammar ownership to specs/spec.spec and proved bootstrap has no current first-class fn support."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.4|Function calls are ordinary value expressions|standalone call silently drops|specs/spec\\.spec|bootstrap-parser fn|bootstrap parser support' docs/tasks/SPEC-FORMAT-TERSE.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md"
---

`SPEC-FORMAT-TERSE.4` owns user-defined pure functions in `.spec` before implementation.

The accepted MVP starts narrow:

- top-level `fn name(args) { ... }`
- explicit parentheses for every arity, including `fn name() { ... }`
- explicit positional parameters
- pure value/block bodies over the existing helper DSL
- no implicit caller working-variable capture, recursion, closures, lambdas, or currying

A user-function call is an ordinary value expression. It can be nested in helper arguments, assigned,
returned, appended, used as a mutation value, or used as the receiver of a compatible receiver-dot value chain.
If a function call appears as a standalone statement, the return value is silently discarded.

Permanent function syntax belongs in `specs/spec.spec`, not as a lasting hardcoded
bootstrap-parser extension. Any bootstrap support for `fn <name>(...) { ... }` is
temporary migration debt and should be removed once the text-to-AST path and
`spec.spec` can own the surface. `PERL-ACTIONIR-AST-MIGRATION.5.4` proved there is no
current first-class bootstrap support, so `SPEC-FORMAT-TERSE.4.1` can start from the
self-hosted ownership boundary.

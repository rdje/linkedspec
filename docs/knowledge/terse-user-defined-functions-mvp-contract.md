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
  - "what is SPEC-FORMAT-TERSE.4.1"
  - "can user functions capture caller variables"
  - "can user functions be recursive"
  - "do user functions have exact arity"
  - "what function name collisions are rejected"
  - "does SPEC-FORMAT-TERSE.4.2.1 execute user functions"
  - "does SPEC-FORMAT-TERSE.4.2.2 execute user functions"
  - "does SPEC-FORMAT-TERSE.4.2.3 implement standalone discard"
  - "does SPEC-FORMAT-TERSE.4.3.1 add Rust user function registry"
date: 2026-07-01
status: current
tags: [spec-format-terse, user-functions, value-expressions, receiver-dot, task-tree]
evidence: "SPEC-FORMAT-TERSE.4 was split/owned on 2026-07-01 after explicit user direction to implement custom/user-defined functions. SPEC-FORMAT-TERSE.4.1 then locked the MVP contract/inventory before code: top-level fn name(args) { ... }, exact explicit arity, eager argument evaluation, fresh function-local parameter/work-variable scope, pure value/block bodies, final-expression or return(expr) result, no implicit caller-state capture, and no recursion/closures/lambdas/currying/host-code escape. Function names share the helper call surface, so definitions must reject collisions with built-in helper/control/lifecycle names, rule labels, reserved runtime symbols, and other functions. User clarification requires function calls to be ordinary value expressions whose results can feed receiver-dot chains, and unused standalone call results to be silently discarded. PERL-ACTIONIR-AST-MIGRATION.5.4 locked permanent fn grammar ownership to specs/spec.spec and proved bootstrap has no current first-class fn support. SPEC-FORMAT-TERSE.4.2.1 landed definition registration; SPEC-FORMAT-TERSE.4.2.2 landed Perl exact-arity registered value-call execution and receiver-chain composition; SPEC-FORMAT-TERSE.4.2.3 landed registered standalone discard and hardening diagnostics; SPEC-FORMAT-TERSE.4.3.1 landed Rust parsed/compiled registry parity without runtime execution."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.4\\.1|SPEC-FORMAT-TERSE\\.4\\.2\\.1|SPEC-FORMAT-TERSE\\.4\\.3\\.1|top-level fn name\\(args\\)|exact arity|fresh function-local|standalone.*discard|CompiledUserFunction|Frontier moves to \\.4\\.3\\.2' docs/tasks/SPEC-FORMAT-TERSE.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md docs/knowledge/rust-user-function-registry-parity.md"
---

`SPEC-FORMAT-TERSE.4` owns user-defined pure functions in `.spec` before implementation.

The accepted MVP starts narrow:

- top-level `fn name(args) { ... }`
- explicit parentheses for every arity, including `fn name() { ... }`
- explicit positional parameters
- exact arity; no overloads or optional/default parameters in the MVP
- eager argument evaluation in the caller context
- fresh function-local parameter and working-variable scope
- pure value/block bodies over the existing helper DSL
- final-expression result, or the payload of the first body-local `return(expr)`
- no implicit caller working-variable capture, recursion, closures, lambdas, currying, host-code escape,
  parser-state helpers, or side-effect helpers

A user-function call is an ordinary value expression. It can be nested in helper arguments, assigned,
returned, appended, used as a mutation value, or used as the receiver of a compatible receiver-dot value chain.
If a function call appears as a standalone statement, the return value is silently discarded.

Function names share the `callee(args)` helper call surface, so a function definition must be rejected if its
name collides with a built-in helper, control/lifecycle keyword, rule label, reserved runtime symbol, or another
function definition. Parameter names must be unique valid identifiers and must not use reserved runtime symbols.

Permanent function syntax belongs in `specs/spec.spec`, not as a lasting hardcoded
bootstrap-parser extension. `PERL-ACTIONIR-AST-MIGRATION.5.4` proved there is no current
first-class bootstrap support. `SPEC-FORMAT-TERSE.4.2.1` then landed the self-hosted
`function_definition` grammar and Perl descriptor registry seam through a temporary
pre-bootstrap extraction bridge. `.4.2.2` then made exact-arity registered calls
executable in Perl value positions and compatible receiver chains. `.4.2.3` added
registered standalone discard through `VALUE_DROP` and locked recursion/unsupported-body
diagnostics with zero raw fallback. `.4.3.1` added Rust parsed/compiled registry parity:
Rust records top-level definitions on `SpecFile.functions`, compiles them into
`CompiledUserFunction` entries with parsed `CodeBlock` bodies, and leaves runtime
execution/oracle parity to `.4.3.2`.

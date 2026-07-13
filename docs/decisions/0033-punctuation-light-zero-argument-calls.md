# ADR 0033: Punctuation-light zero-argument calls are narrow aliases

- Date: 2026-07-13
- Status: accepted
- Tags: dsl, actionir, calls, control-flow, syntax, portability, cross-variant-parity

## Context

LinkedSpec already documents and partially implements parenthesis-free zero-argument control markers such as
`else`, `endif`, `.else`, and `.endif`, but the exact accepted parser paths differ by backend. The director also
requested `next` as an alias for `next()` and proposed that a final zero-argument receiver call may omit `()`.
The separate possibility of writing condition-bearing headers as `if condition { ... }` or
`while condition { ... }` was not part of that request and could create a broader grammar problem.

## Decision

Parentheses remain the general call grammar. We add only these aliases:

1. Where their parenthesized statement forms are valid, `else`, `endif`, `default`, `endcase`, `endswitch`, and
   `next` are equivalent to the corresponding zero-argument calls.
2. The final call in an ActionIR receiver chain may be written `.method` instead of `.method()` when no arguments
   are authored. The normal contract/arity resolver still decides whether that method accepts zero arguments.
3. Existing punctuation-light control-marker suffixes remain valid in rule-edge/lifecycle fluent syntax.
4. Parenthesized spellings remain valid and canonical AST/runtime semantics do not change.

This decision does not admit parenthesis-free calls with arguments, intermediate generic receiver segments,
ordinary helper or user-function calls, attached final-codeblock calls, or condition-bearing headers such as
`if condition { ... }` and `while condition { ... }`.

## Consequences

- The final bare receiver segment has an unambiguous boundary: it is an identifier after `.` at the end of the
  ActionIR expression. A following dot, argument list, or block leaves the existing grammar in control.
- A terminal method that requires arguments parses as a zero-argument call and fails through the normal typed
  arity/contract diagnostic; the syntax alias does not bypass method signatures.
- All five backends and generated paths must converge on the same AST and diagnostics.
- The older general `callee(args)` contract remains true, with these explicitly enumerated exceptions.
- Parenthesis-free `if`/`while` headers remain deferred until a separate ambiguity audit and decision authorize
  them.

## Links

- Task tree: `FUTURE-PARITY-BACKLOG.16`
- Audit/split: `FUTURE-PARITY-BACKLOG.16.0`
- Related: ADR 0007, `docs/knowledge/terse-call-spacing-contract.md`

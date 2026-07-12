# 0030 — Variadic user functions use one explicit final rest parameter and typed array binding

- Date: 2026-07-12
- Status: accepted
- Tags: architecture, functions, helpers, methods, arity, variadic, staged-parsing, descriptor, portability

## Context

The user-function MVP accepts only exact-arity `fn name(params) { ... }` definitions. A director directive now
requires routines whose purpose is unbounded to accept unlimited arguments and delegates the user-function syntax
decision to the project.

The pre-code audit found two different existing mechanisms:

- built-in helpers already distinguish exact, bounded, and open upper arities by purpose; receiver methods inject
  the receiver into the effective helper argument list; and
- user-function exact `arity` is duplicated through the spec-owned definition AST, staged body payload/job,
  outward descriptor, backend parsed/compiled registries, call resolution, native/generated execution, and Lua's
  prepared invocation frame.

User-function names are unique and duplicate definitions are rejected. The extension therefore does not need or
justify overload sets, default parameters, named arguments, or host-language splat dispatch.

## Decision

1. The accepted variadic definition syntax is:

   ```text
   fn collect(prefix, ...items) {
     return({ "prefix": prefix, "items": items })
   }
   ```

   `...` and the rest identifier are one token with no intervening whitespace. A definition may have zero or more
   fixed positional parameters followed by at most one rest parameter. The rest parameter must be final.
2. Version-1 fixed definitions remain unchanged and exact: their public/staged representation keeps `params` plus
   `arity` and their calls accept exactly that many positional values.
3. A variadic definition is function-definition version 2 and carries one version-1 `callable_signature` object:

   ```json
   {
     "kind": "callable_signature",
     "version": 1,
     "positional_params": ["prefix"],
     "rest_param": "items",
     "min_arity": 1,
     "max_arity": null
   }
   ```

   Its outer definition record, staged payload, and body parse job carry `signature` instead of the version-1
   `params`/`arity` pair. Versioning is a permanent union, not a temporary ambiguous reinterpretation of `arity`.
4. Calls are positional only. Every argument evaluates exactly once, left to right, in caller scope. Fixed prefix
   values bind as before; all remaining values bind to the rest name as one fresh typed LinkedSpec array. No extras
   produce an empty typed array. Aggregate/codeblock values keep their ordinary value identity inside that array.
5. Fixed functions retain exact-arity diagnostics. A variadic call below `min_arity` reports
   `user_function_arity_mismatch` with “at least N”; it has no upper-bound failure. Any keyword argument reports
   `user_function_keyword_arguments_unsupported` rather than being counted positionally or mapped by name.
6. Function results remain ordinary values and may feed compatible receiver chains. This decision does not make
   user-defined functions callable as receiver methods.
7. Existing built-in signatures remain purpose-specific. Open-bound helper functions and their receiver forms stay
   open; exact operations are not made variadic merely because the syntax can express a rest parameter.
8. `capability_conformance/callable_signature_contract.json` is the executable neutral contract. Its offline
   checker is a recurring canonical local-CI input before any backend implementation lands.

## Consequences

- `specs/user_function_definition.spec` and the formal `specs/spec.spec` grammar must return version-2 variadic
  records while leaving version-1 fixed records stable.
- Every backend must understand both definition versions and preserve exact signature identity through staged
  parsing, public descriptors, native execution, diagnostics, and generated source.
- Perl, Rust, Dart, and Julia roll out against the unchanged fixture in separately committed leaves. Variadic
  capability remains future/owned until exact admission; current fixed-function capability stays pass.
- Lua already has the necessary typed registry/invocation-frame seam but does not yet execute user-function bodies.
  Final no-drift routes its signature work to the first dependency-complete Lua function-execution leaf.
- Optional/default/named parameters, overloads, user-defined receiver methods, recursion, closures, currying, and
  namespaces remain outside this decision.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`.4.1`)
- Executable contract: `capability_conformance/callable_signature_contract.json`
- Prior function AST: ADR `0017`
- Backend parity: ADR `0023`
- Existing function MVP: `docs/knowledge/terse-user-defined-functions-mvp-contract.md`
- Audit fact: `docs/knowledge/variadic-callable-signature-seams.md`

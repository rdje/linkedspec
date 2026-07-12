# 0032 — A final contextual codeblock parameter is declared as `name: codeblock`

- Date: 2026-07-12
- Status: accepted
- Tags: architecture, codeblock, callable, parameters, functions, helpers, methods, actionir, portability

## Context

ADR 0031 requires callable signatures to govern attached and parenthesized final-codeblock syntax, but it did not
define the declaration that tells a parser which final parameter accepts that syntax. The Perl audit in
`FUTURE-PARITY-BACKLOG.11.3.3.0` found only untyped user-function names/arity/rest, lowering-local helper arities,
and name-gated receiver parsing.

An initial repair proposal combined the parameter's value kind with a second callback signature, for example
`callback: codeblock(item, ...rest)`. The director rejected that as unnecessary: LinkedSpec needs a `codeblock`
value kind and a declaration that the parameter accepts it. An explicit codeblock value already owns its callable
signature through `{|params| body }`.

## Decision

1. The exact user-function parameter declaration is `name: codeblock`. For example:

   ```text
   fn apply(value, callback: codeblock) {
     return(callback())
   }
   ```

2. `codeblock` is a parameter value-kind declaration, not a nested function type. It carries no argument list.
   `callback: codeblock(item)` is invalid.
3. A declared codeblock parameter must be the final parameter. No fixed or rest parameter may follow it. This
   makes attached braces unambiguously the final argument.
4. The supplied value owns any invocation signature. An explicit `{|item, ...rest| body }` retains and enforces
   that signature when called; the receiving parameter does not duplicate or constrain it.
5. In a final `codeblock` position, attached `call(args) { body }` and parenthesized
   `call(args, { body })` normalize to the same contextual `codeblock_argument`. A contextual block declares no
   positional parameters, is invoked with zero positional arguments, and reads the callee's current dynamic
   context. Code requiring explicit positional bindings uses a `{|params| body }` value instead.
6. Helper and receiver-method registries expose the same final-parameter kind metadata as user functions. Parsers
   consult that metadata; they do not hard-code `with` or traversal method names.
7. Ordinary parameters remain untyped/duck-typed. This decision does not introduce general static typing or
   change the runtime identity of scalar, array, harray, or codeblock values.
8. A harray is never promoted merely because it occupies a `codeblock` slot. Non-codeblock final values,
   non-final declarations, nested declaration argument lists, and unknown type names receive typed diagnostics.

## Consequences

- The callable-signature schema gains optional final-parameter kind metadata while existing untyped signatures
  remain exact and source-compatible.
- Function-definition grammar, staged payloads, registries, descriptors, ActionIR, generated state, and every
  backend must preserve `callback: codeblock` before generic syntax is admitted.
- Existing `with` and traversal behavior migrates behind registered callable metadata without changing its dynamic
  callback context.
- Contextual blocks are deliberately different from explicit parameterized literals: they rely on dynamic context
  and take zero positional arguments.
- The neutral callable-codeblock checker locks the declaration, four invalid forms, and equivalent helper,
  user-function, and receiver surfaces before Perl behavior changes.

## Links

- Clarifies: ADR `0031`
- Parameter/arity baseline: ADR `0030`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`.11.3.3.1`)
- Executable contract: `capability_conformance/callable_codeblock_contract.json`
- Gap fact: `docs/knowledge/perl-final-codeblock-signature-declaration-gap.md`

---
id: callable-codeblock-literal-contract
title: Callable codeblocks use brace-pipe literals and dynamic caller context
answers:
  - "how do I initialize a codeblock variable"
  - "what is the callable codeblock literal syntax"
  - "can I call a codeblock variable with cb parentheses"
  - "does a LinkedSpec codeblock capture lexical variables"
  - "how are codeblock literals distinguished from harray literals"
  - "what is the zero argument codeblock literal"
  - "can codeblock literals have a rest parameter"
  - "does with remain after callable codeblocks"
date: 2026-07-12
status: accepted-design
tags: [codeblock, callable, literal, dynamic-scope, harray, actionir, FUTURE-PARITY-BACKLOG]
evidence: "Director agreement on 2026-07-12 selects {|args| ...} and dynamic caller context; ADR 0031 defines literals/invocation, ADR 0032 defines final-only name: codeblock, .11.2 adopts linkedspec-callable-codeblock-v1, and Perl .11.3.1-.2 consume its literal/invocation fixture while generic final-block behavior and backend parity remain future."
reverify: "python3 tools/check_callable_codeblock_contract.py && rg -n '0031|0032|name: codeblock|dynamic caller|FUTURE-PARITY-BACKLOG\\.11\\.[1-7]' docs/decisions/0031-callable-codeblock-literal-and-dynamic-context.md docs/decisions/0032-final-codeblock-parameter-declaration.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

The accepted callable codeblock literal is:

```text
cb = {|left, right|
  return(cat(left, right))
}

result = cb("a", "b")
```

The opener is exactly `{|`. `{|| body }` declares no parameters. A final `...rest` reuses the callable-signature
rules from ADR 0030. Construction stores a typed signature/body/source value and does not execute the body.

This prefix is distinct from every current brace value: `{}` and `{ key : value }` are harrays, while a nonempty
`{ statements }` without a top-level hash pair remains an immediately evaluated block expression. A codeblock
literal therefore does not need to guess from colon/statement content and cannot silently become an harray.

`cb(args)` evaluates positional arguments once left-to-right. Copied parameter values and a fresh rest array bind
temporarily, then prior same-name bindings restore. The body resolves all other variables from the caller's current
stores at invocation time; it captures no lexical environment at construction. Nonparameter mutation remains
visible to the caller. `return(...)` is block-local and the final value can chain or be discarded.

Governed static helpers/controls and registered user functions retain call precedence over same-named variables.
Bound non-codeblocks diagnose as not callable; recursion is initially rejected. `with` remains an ordinary helper,
and generic attached/contextual final blocks normalize under callable signatures rather than name-gated parsing.
Lexical capture is explicitly deferred behind a new decision if a real need appears.

ADR 0032 declares only the receiving value kind: a final `callback: codeblock` parameter. It has no argument list;
explicit `{|params| ...}` values own their signatures, while contextual `{ ... }` values take zero positional
arguments and read dynamic context.

`linkedspec-callable-codeblock-v1` machine-locks seven literals, eleven valid calls, sixteen invalid syntax/call
cases, four invalid declarations, eight contextual forms, and one deterministic fixture. Perl `.11.3.1` implements typed literal
construction/preservation and `.11.3.2` executes `cb(args)` with the neutral dynamic-context behavior. Generic
final blocks and backend parity remain active/future, so the complete feature is not yet portable behavior.

Related facts: [[generic-trailing-codeblock-argument-correction]], [[variadic-user-function-contract]],
[[terse-expression-valued-blocks-ground-truth]], [[hash-literal-dynamic-key-contract]].

---
id: perl-callable-codeblock-literal-record
title: Perl preserves callable codeblock literals as inert typed data
answers:
  - "does Perl parse callable codeblock literals"
  - "what fields are in a Perl callable codeblock literal"
  - "does constructing a Perl codeblock execute its body"
  - "does a Perl codeblock literal capture an environment"
  - "can Perl codeblock values pass through user functions"
  - "how does generated Perl preserve codeblock source text"
  - "where is Perl callable codeblock invocation implemented"
date: 2026-07-12
status: current
tags: [perl, actionir, codeblock, callable, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.3.1 adds exact {| recognition in ActionIR AST parsing, a version-1 eight-field literal record with callable signature/body/source/spans and no environment, canonical JSON-to-ASCII-hex generated-state reconstruction, and t/callable_codeblock_literal_contract.t proof across 126 assertions. Invocation remains owned by .11.3.2."
reverify: "prove -v -Iperl t/callable_codeblock_literal_contract.t && prove -q -Iperl t/actionir_ast_parser.t"
---

# Perl Callable Codeblock Literal Record

The Perl reference now recognizes exact `{|params| body }` before the existing harray/eager-block classifier.
Valid literals produce exactly these top-level fields:

- `kind = codeblock_literal`
- `version = 1`
- `signature`
- `body_source`
- `body_ast`
- `source_text`
- `source_span`
- `body_span`

The callable signature supports zero/fixed params and one final `...rest`. Literal and nested body spans use the
containing ActionIR expression's coordinate space. Nine malformed neutral cases remain typed
`codeblock_literal_error` nodes with the contract's diagnostic codes.

Lowering serializes the record as canonical UTF-8 JSON, stores its bytes as ASCII hex in generated Perl, and
decodes it back to ordinary arrays/hashes/scalars at runtime. This prevents later source-rewrite passes, Perl
interpolation, or a host coderef from changing the body/source record. Construction is inert and captures no
environment. Assignment/copying and user-function arguments/results preserve the record.

This fact does not claim `cb(args)` support. Variable-call resolution and dynamic caller execution begin in
`FUTURE-PARITY-BACKLOG.11.3.2`.

Related facts: [[callable-codeblock-literal-contract]], [[perl-actionir-ast-block-value-lowering]],
[[variadic-user-function-contract]].

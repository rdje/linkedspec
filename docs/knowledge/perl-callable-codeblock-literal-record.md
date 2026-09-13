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
evidence: "FUTURE-PARITY-BACKLOG.11.3.1 adds exact {| recognition in ActionIR AST parsing, a version-1 eight-field literal record with callable signature/body/source/spans and no environment, canonical JSON-to-ASCII-hex generated-state reconstruction, and contract-focused proof. FUTURE-PARITY-BACKLOG.11.3.2 subsequently adds invocation without changing the record."
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

Variable-call resolution and dynamic caller execution have since landed under
`FUTURE-PARITY-BACKLOG.11.3.2`; see [[perl-callable-codeblock-dynamic-invocation]].

Related facts: [[callable-codeblock-literal-contract]], [[perl-actionir-ast-block-value-lowering]],
[[variadic-user-function-contract]].


## September 13 callable literal consumer reading

`CONFORMANCE-SOURCE-READING.1.33` reads `t/callable_codeblock_literal_contract.t`
lines 1-345. It covers exact literal fields and spans, inert construction,
user-function transport, the neutral dynamic-caller fixture, generated execution
loaded into a package in the same process, static callable precedence and typed
invocation failures. The direct failing-body control restores its shadowed
parameter. This is not a fresh-process generated-artifact test.

Fresh managed execution of the complete target passes ten top-level tests.
Neutral validation passes seven literals, 11 calls, nine invalid literals, seven
invalid calls, four invalid declarations, eight contextual forms and 23 rejected
governance mutations. Executing the entire target adds no physical-reading credit
for lines 346-565, which remain `.1.34`-owned. The same leaf completes the AST
parser-test reading and retains its unchanged 23-test proof from `.1.32` at
`3d633f3b6`; its lowering-string assertions are not execution of every emitted
fragment or admission of deliberately injected older internal AST shapes.

```bash
bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/callable_codeblock_literal_contract.t
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py
```

[[perl-callable-codeblock-dynamic-invocation]] retains the current caller-binding
model. [[perl-codeblock-boolean-literal-kind-drift]] and
[[perl-dynamic-codeblock-receiver-guard-gap]] remain open under startup `.35` and
`.19`. These finite passing fixtures close neither defect. Current keyword-call
rejection remains separate from the approved parked named-argument direction.

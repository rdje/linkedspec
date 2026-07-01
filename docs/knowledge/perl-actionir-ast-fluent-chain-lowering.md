---
id: perl-actionir-ast-fluent-chain-lowering
title: Perl MethodLowering consumes AST fluent_chain nodes for receiver-dot value chains
answers:
  - "are receiver-dot chains lowered from AST in Perl"
  - "does Perl fluent_chain lowering still split source text"
  - "how does Perl lower receiver-dot value chains after text to AST"
  - "does MethodLowering consume fluent_chain AST nodes"
  - "does malformed chain substr leak as host Perl substr"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, receiver-dot, fluent-chain]
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.3 changed MethodLowering so _lower_method_value_expr dispatches AST fluent_chain nodes before the legacy receiver-dot normalizers. The dispatcher traverses typed receiver/call/argument nodes for array, hash, string, and number receiver families, then reuses the existing Perl helper catalog through the compatibility bridge. Focused fake-source tests in t/actionir_ast_parser.t poison chain/call/receiver/argument source fields and prove number, string-to-array, block-array, hash-to-array, invalid numeric terminal, and malformed substr chain cases do not reuse source text. Malformed covered chain helpers use the .3.2.3 unresolved-helper sentinel path."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now consumes
`LinkedSpec::ActionIR::AST` `fluent_chain` nodes for receiver-dot value chains before
the legacy receiver-dot source splitters run.

The AST dispatcher covers the existing array, hash, string, and number receiver-family
contracts. It preserves bare scalar/hash receiver wrapping, block-valued receivers,
array pipeline private helper names, `join_values` delimiter-first mapping,
string/hash-to-array bridges, numeric arity checks, and numeric terminal continuation
behavior. The dispatcher rebuilds the same helper-family surfaces from typed AST fields
and then enters the existing Perl helper catalog through the compatibility bridge for
byte-compatible generated output.

The old receiver-dot text normalizers still exist only as compatibility fallback for
raw or unparsed expressions. Supported parsed `fluent_chain` value expressions are now
owned by AST traversal. Unsupported covered chain helper forms, such as malformed
`"abc".substr()`, report through the unresolved-helper sentinel path instead of lowering
to generated host Perl calls.

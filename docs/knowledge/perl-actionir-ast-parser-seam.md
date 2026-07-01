---
id: perl-actionir-ast-parser-seam
title: Perl ActionIR has an additive typed AST parser seam
answers:
  - "where is the Perl ActionIR AST parser"
  - "does Perl ActionIR have a text to AST parser seam"
  - "can function calls be receiver chain receivers in Perl AST"
  - "are standalone function call results dropped"
  - "does the Perl AST parser replace RewritePipeline yet"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, parser, migration]
evidence: "PERL-ACTIONIR-AST-MIGRATION.2 added LinkedSpec::ActionIR::AST and LinkedSpec::ActionIR::AST::Parser plus t/actionir_ast_parser.t. The parser covers action blocks/statements, calls, literals, variables, direct access, shape literals, block values, assignments, and receiver-dot chains with source spans. It is additive: RewritePipeline and MethodLowering remain authoritative until later migration leaves switch consumers."
reverify: "prove -Iperl t/actionir_ast_parser.t && perl -Iperl -c perl/LinkedSpec/ActionIR/AST.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm"
---

The Perl reference now has an additive typed parser seam for ActionIR helper/action text:

- Facade: `perl/LinkedSpec/ActionIR/AST.pm`
- Parser: `perl/LinkedSpec/ActionIR/AST/Parser.pm`
- Focused tests: `t/actionir_ast_parser.t`

The seam parses action blocks and expression statements into typed nodes with `kind`,
`source`, and `source_span` fields. It covers calls, primitive literals, variables,
indexed and nested direct access, array/hash shape literals, block values, scalar
assignment, array append, hash-index assignment, and receiver-dot `fluent_chain` nodes.

Standalone expression statements carry `drops_value => 1`, so helper calls and future
user-defined function calls silently discard their value when not consumed. A function
call, numeric literal, or block value can be a receiver-chain receiver.

This parser does not replace production lowering yet. `RewritePipeline`,
`MethodLowering`, and `RuleIR::EmitContext` still own the current generated Perl behavior
until `PERL-ACTIONIR-AST-MIGRATION.3+` switches value/receiver and statement/control
consumers over to AST.

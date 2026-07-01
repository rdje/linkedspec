---
id: perl-actionir-ast-parser-seam
title: Perl ActionIR has an additive typed AST parser seam
answers:
  - "where is the Perl ActionIR AST parser"
  - "does Perl ActionIR have a text to AST parser seam"
  - "can function calls be receiver chain receivers in Perl AST"
  - "are standalone function call results dropped"
  - "does the Perl AST parser replace RewritePipeline yet"
  - "does Perl MethodLowering consume the ActionIR AST"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, parser, migration]
evidence: "PERL-ACTIONIR-AST-MIGRATION.2 added LinkedSpec::ActionIR::AST and LinkedSpec::ActionIR::AST::Parser plus t/actionir_ast_parser.t. The parser covers action blocks/statements, calls, literals, variables, direct access, shape literals, block values, assignments, and receiver-dot chains with source spans. PERL-ACTIONIR-AST-MIGRATION.3.1 switched MethodLowering non-call value nodes to consume this AST; .3.2.1 switched value-only helper-call composition to consume AST call nodes; .3.2.2 switched deprecated wrappers plus aggregate/collection/reducer/hash helper calls to slot-aware AST call lowering; .3.2.3 added unresolved-helper diagnostics for unsupported covered helper calls; .3.3 switched receiver-dot fluent_chain value chains to AST traversal. Statement/control lowering and return-payload substitution remain queued."
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

This parser does not replace all production lowering yet. `MethodLowering` now consumes
the AST for non-call value nodes: primitive literals, scoped bare scalar reads, direct
indexed/nested access, array/hash shape literals, and block values. It also consumes AST
`call` nodes for value-only helper-call composition: scalar normalization, string
predicate/composition, coalesce/concat, and scalar-argument numeric helpers. It also
consumes AST `call` nodes for deprecated wrapper aliases plus aggregate-wrapper,
collection/reducer, and hash helper families while preserving existing symbol/value
slot policies. Unsupported covered helper forms now report unresolved-helper metadata
instead of leaking as generated host-language calls. Receiver-dot `fluent_chain` value
chains now lower from typed AST receiver/call nodes. Statement/control lowering and
remaining return-payload helper substitution still migrate in later
`PERL-ACTIONIR-AST-MIGRATION.3+` leaves.

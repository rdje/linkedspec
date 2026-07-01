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
  - "does the Perl AST parser parse structured control flow"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, parser, migration]
evidence: "PERL-ACTIONIR-AST-MIGRATION.2 added LinkedSpec::ActionIR::AST and LinkedSpec::ActionIR::AST::Parser plus t/actionir_ast_parser.t. The parser covers action blocks/statements, calls, literals, variables, direct access, shape literals, block values, assignments, and receiver-dot chains with source spans. PERL-ACTIONIR-AST-MIGRATION.3.1 switched MethodLowering non-call value nodes to consume this AST; .3.2.1 switched value-only helper-call composition to consume AST call nodes; .3.2.2 switched deprecated wrappers plus aggregate/collection/reducer/hash helper calls to slot-aware AST call lowering; .3.2.3 added unresolved-helper diagnostics for unsupported covered helper calls; .3.3 switched receiver-dot fluent_chain value chains to AST traversal; .3.4 switched typed return payloads to AST traversal before raw fallback; .4.1 switched assignment/mutation operator statements to AST field lowering; .4.2 switched helper-call statements, returns, and array end-mutation receiver statements to AST call/fluent-chain lowering; .4.3 switched block-value side effects, block-local returns, and final expressions to AST block/statement fields; .4.4.1 added typed control_if/control_else/control_while/control_switch/control_case/default/end marker parser nodes while production structured-control lowering remains queued."
reverify: "prove -Iperl t/actionir_ast_parser.t && perl -Iperl -c perl/LinkedSpec/ActionIR/AST.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm"
---

The Perl reference now has an additive typed parser seam for ActionIR helper/action text:

- Facade: `perl/LinkedSpec/ActionIR/AST.pm`
- Parser: `perl/LinkedSpec/ActionIR/AST/Parser.pm`
- Focused tests: `t/actionir_ast_parser.t`

The seam parses action blocks and expression statements into typed nodes with `kind`,
`source`, and `source_span` fields. It covers calls, primitive literals, variables,
indexed and nested direct access, array/hash shape literals, block values, scalar
assignment, array append, hash-index assignment, helper-call statements, and receiver-dot
`fluent_chain` nodes. It also parses structured-control statement syntax into typed
control nodes: `control_if`, `control_else`, `control_endif`, `control_while`,
`control_switch`, `control_case`, `control_default`, `control_endcase`, and
`control_endswitch`.

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
chains now lower from typed AST receiver/call nodes. Typed return payloads now lower from
AST before the narrow raw fallback; see
`docs/knowledge/perl-actionir-ast-return-payload-lowering.md`. Assignment/mutation
operator statements now lower from AST fields; see
`docs/knowledge/perl-actionir-ast-statement-operator-lowering.md`. Helper-call statements
and expression-valued block internals now also consume typed AST fields; structured
control statement lowering still migrates in later `PERL-ACTIONIR-AST-MIGRATION` leaves.

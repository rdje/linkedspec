---
id: perl-actionir-ast-value-lowering-dispatcher
title: Perl MethodLowering consumes ActionIR AST for non-call value nodes
answers:
  - "does Perl MethodLowering consume the ActionIR AST"
  - "which Perl value nodes lower from AST"
  - "does Perl value lowering still use text rescans"
  - "are receiver chains lowered from AST in Perl yet"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, migration]
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.1 added a MethodLowering AST dispatcher. _lower_method_value_expr now parses with LinkedSpec::ActionIR::AST and lowers primitive literals, scoped bare scalar reads, direct indexed/nested access, array/hash shape literals, and block values from typed nodes. PERL-ACTIONIR-AST-MIGRATION.3.2.1 added AST lowering for value-only helper-call composition, .3.2.2 added slot-aware AST lowering for deprecated wrappers plus aggregate-wrapper, collection/reducer, and hash helper calls, and .3.2.3 added unresolved-helper diagnostics for unsupported covered helper calls. Top-level fluent_chain receiver lowering, statement/control lowering, and remaining return-payload substitution are still later leaves."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now has a partial AST consumer for
ActionIR value expressions. The dispatcher parses `_lower_method_value_expr(...)` input
through `LinkedSpec::ActionIR::AST` unless the call is deliberately inside the
compatibility bridge.

The `.3.1` AST-lowered surface is:

- primitive literals (`number`, `string`, `boolean`, `regex`, `undef`);
- scoped bare scalar reads where the surrounding value slot already accepted them;
- direct indexed/nested access with the legacy reserved-segment guard preserved;
- array and hash shape literals;
- block values, with statement-level side effects still delegated to the existing
  statement compatibility path until the statement/control leaf lands.

Value-only helper calls moved to the AST call dispatcher in
`PERL-ACTIONIR-AST-MIGRATION.3.2.1`; see
`docs/knowledge/perl-actionir-ast-value-only-call-lowering.md`. Aggregate-wrapper,
collection/reducer, and hash helper calls moved to the slot-aware AST call dispatcher in
`PERL-ACTIONIR-AST-MIGRATION.3.2.2`; see
`docs/knowledge/perl-actionir-ast-aggregate-call-lowering.md`. `fluent_chain`
receiver-dot chains still use compatibility paths. Nested unsupported call nodes inside
AST-lowered values from known helper families now report unresolved-helper diagnostics
through `PERL-ACTIONIR-AST-MIGRATION.3.2.3`; unknown call names remain future/function
resolution territory.

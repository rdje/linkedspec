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
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.1 added a MethodLowering AST dispatcher. _lower_method_value_expr now parses with LinkedSpec::ActionIR::AST and lowers primitive literals, scoped bare scalar reads, direct indexed/nested access, array/hash shape literals, and block values from typed nodes. Helper-call nodes use an explicit compatibility bridge; top-level fluent_chain receiver lowering, helper-call composition, statement/control lowering, and remaining return-payload substitution are still later leaves."
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

Top-level helper calls and `fluent_chain` receiver-dot chains still use the legacy
lowering path. Nested call nodes inside AST-lowered shapes/blocks go through an explicit
compatibility bridge so later leaves can replace helper-call composition separately.

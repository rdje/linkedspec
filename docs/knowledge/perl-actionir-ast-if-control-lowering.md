---
id: perl-actionir-ast-if-control-lowering
title: Perl if/when/otherwise statement controls lower from ActionIR AST condition and body nodes
answers:
  - "are Perl if statements lowered from AST"
  - "are Perl when otherwise controls lowered from AST"
  - "does ControlFlow consume control_if nodes"
  - "which leaf moved if-family control lowering to AST"
  - "do if-family controls still use original source text"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, control-flow, lowering]
evidence: "PERL-ACTIONIR-AST-MIGRATION.4.4.2 changed ActionIR::ControlFlow so if/i/when, elseif/elif, else/otherwise, and endif statements parse through LinkedSpec::ActionIR::AST before entering the existing branch lowerers. The bridge materializes trusted control statements from typed condition/body fields and focused t/actionir_ast_parser.t fake-source tests poison original text plus AST source fields for attached if/elseif/else, when/otherwise, and marker if/elseif/else/endif. Existing generated Perl branch shape, implicit-close behavior, and when/otherwise alias semantics remain stable."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`PERL-ACTIONIR-AST-MIGRATION.4.4.2` moves the first structured-control lowering family
onto typed AST consumption.

Covered statement forms:

- `if(...)`, `i(...)`, and `when(...)`;
- `elseif(...)` and `elif(...)`;
- `else`, `else()`, and `otherwise`;
- `endif` and `endif()`.

`ControlFlow` still owns the branch engine. The new bridge parses a control statement
through `LinkedSpec::ActionIR::AST`, reconstructs a trusted statement from typed
condition/body nodes, then delegates to the existing lowerers. That preserves established
attached-block implicit close, marker-style close, and when/otherwise alias semantics.

The focused tests intentionally poison both original control text and every AST `source`
field. Passing output must contain only values reconstructed from typed fields, proving
the if-family path is no longer driven by textual marker reconstruction.

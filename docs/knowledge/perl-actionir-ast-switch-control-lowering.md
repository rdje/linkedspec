---
id: perl-actionir-ast-switch-control-lowering
title: Perl switch/case/default statement controls lower from ActionIR AST nodes
answers:
  - "are Perl switch controls lowered from AST"
  - "which leaf moved switch control lowering to AST"
  - "do switch/case/default controls still use original source text"
  - "does Perl ActionIR AST lowering preserve switch stack behavior"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, control-flow, switch, lowering]
evidence: "PERL-ACTIONIR-AST-MIGRATION.4.4.3 changed ActionIR::ControlFlow so switch, case, default, endcase, and endswitch statements parse through LinkedSpec::ActionIR::AST before entering the existing switch lowerers. The bridge materializes switch source expressions, case match values, attached case/default bodies, parsed switch branch lists, and end markers from typed fields; attached control_switch nodes prefer parsed cases/default over generic body fallback. Focused t/actionir_ast_parser.t fake-source tests poison original text, fake fallback bodies, and AST source fields for attached and marker forms. Existing switch stack behavior, branch order, default-once semantics, and generated Perl shape remain stable."
reverify: "prove -Iperl t/actionir_ast_parser.t && perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm"
---

`PERL-ACTIONIR-AST-MIGRATION.4.4.3` moves the switch-family structured-control
lowering path onto the Perl ActionIR AST bridge.

Covered statement forms:

- `switch(...)`
- `case(...)`
- `default` / `default()`
- `endcase` / `endcase()`
- `endswitch` / `endswitch()`

The parser already emits typed `control_switch`, `control_case`, `control_default`,
`control_endcase`, and `control_endswitch` nodes. `ControlFlow` now materializes trusted
control statements from those typed fields before reusing the existing switch stack
lowerers. Attached `control_switch` nodes use parsed `cases` and optional `default`
branch fields when available, so fake fallback bodies and `source` fields are not
authoritative.

The migration is behavior-preserving: switch sources are still evaluated once, cases keep
their existing branch order, only one default branch can run, and marker `endcase` /
`endswitch` still close the existing switch stack.

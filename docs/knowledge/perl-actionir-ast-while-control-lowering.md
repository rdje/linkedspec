---
id: perl-actionir-ast-while-control-lowering
title: Perl attached while statement controls lower from ActionIR AST nodes
answers:
  - "are Perl while controls lowered from AST"
  - "which leaf moved while control lowering to AST"
  - "do while controls still use original source text"
  - "does Perl ActionIR AST lowering preserve the while safety guard"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, control-flow, while, lowering]
evidence: "PERL-ACTIONIR-AST-MIGRATION.4.4.4 changed ActionIR::ControlFlow so attached while(cond) { ... } statements parse through LinkedSpec::ActionIR::AST before entering the existing while lowerer. The bridge materializes loop conditions and attached body statements from typed control_while fields. Focused t/actionir_ast_parser.t fake-source tests poison original text and AST source fields for attached while forms, while asserting that the deterministic 10000-iteration guard remains in generated output. Bodyless while(...) marker nodes still parse for node-shape consistency but remain parser-shape-only for lowering because the current DSL has no endwhile product syntax."
reverify: "prove -Iperl t/actionir_ast_parser.t && perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm"
---

`PERL-ACTIONIR-AST-MIGRATION.4.4.4` moves attached while-loop lowering onto the Perl
ActionIR AST bridge.

Covered production statement form:

- `while(cond) { ... }`

`ControlFlow` now materializes the loop condition and attached body from typed
`control_while` fields before reusing the existing while lowerer. That keeps generated
Perl behavior stable: the condition is re-evaluated before each iteration, the attached
body lowers through the same branch-action path, and the deterministic guard still dies
after 10000 iterations with the existing diagnostic.

The parser also recognizes bodyless `while(...)` as `control_while` for node-shape
consistency. That form is not a new lowering surface because LinkedSpec has no current
`endwhile` syntax to delimit a marker-style loop body.

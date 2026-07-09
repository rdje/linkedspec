---
id: text-to-ast-backend-doctrine
title: LinkedSpec backend text-to-AST doctrine
answers:
  - "must backends parse helper code to AST"
  - "is text-to-text lowering allowed"
  - "should Perl ActionIR move to AST"
  - "do Julia Dart Lua backends use text to AST"
  - "can user-defined functions be implemented as text macros"
  - "what doctrine replaced Perl source text lowering"
date: 2026-07-01
status: current
tags: [architecture, actionir, ast, cross-variant-parity, perl-reference]
evidence: "User directive on 2026-07-01 adopted Rust-style text-to-AST as the cross-variant doctrine and required the Perl variant to move away from text-to-text lowering. ADR 0011 and task tree PERL-ACTIONIR-AST-MIGRATION own the migration."
reverify: "rg -n 'text-to-AST|text-to-text|PERL-ACTIONIR-AST-MIGRATION|0011' docs/decisions docs/tasks docs/linkedspec-book/src"
---

LinkedSpec backend helper/action semantics must parse source text into typed AST/IR nodes
before lowering, interpretation, or code emission.

Text-to-text rewriting is legacy migration debt. The Perl reference backend must migrate
its ActionIR lowering carefully, starting with an inventory and parser seam, then replacing
value/receiver and statement/control lowering families under regression locks.

New supported surfaces, including user-defined functions, must consume AST/IR call nodes.
They must not be implemented as broad textual macros or by relying on generated
host-language fallback. Rust already follows this direction with typed `Expr` and `Stmt`
nodes. Future Dart, Julia, and Lua backends inherit the same text-to-AST requirement under
ADR 0021.

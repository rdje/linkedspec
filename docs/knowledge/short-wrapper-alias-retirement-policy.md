---
id: short-wrapper-alias-retirement-policy
title: s/a/h wrapper aliases are retirement targets, not permanent syntax
answers:
  - "are s a h aliases permanent LinkedSpec syntax"
  - "should s() a() h() be retired"
  - "what are the canonical scalar array hash wrapper spellings"
  - "which task owns retiring s a h wrapper aliases"
date: 2026-07-01
status: current
tags: [actionir, ast, aliases, retirement, spec-format]
evidence: "User directive on 2026-07-01: s(), a(), and h() should also be retired. PERL-ACTIONIR-AST-MIGRATION.5.3 split the prior user-function handoff leaf so PERL-ACTIONIR-AST-MIGRATION.5.3.1 owns shorthand wrapper alias retirement before .5.3.2 resumes user-function AST call handoff."
reverify: "rg -n 'PERL-ACTIONIR-AST-MIGRATION\\.5\\.3\\.1|s\\(\\.\\.\\.\\)|a\\(\\.\\.\\.\\)|h\\(\\.\\.\\.\\)|short wrapper alias' docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md ROADMAP_V2.md"
---

`s(...)`, `a(...)`, and `h(...)` are retirement targets. The canonical long wrapper
spellings are `scalar(...)`, `array(...)`, and `hash(...)`; direct shape literals remain
the preferred constructor surface where applicable.

`PERL-ACTIONIR-AST-MIGRATION.5.3.1` owns the migration of repo-owned specs, tests, and
docs away from the short aliases plus removal or explicit compatibility fencing of the
Perl lowering support. `PERL-ACTIONIR-AST-MIGRATION.5.3.2` then resumes user-function AST
call handoff. See [[perl-actionir-ast-value-drop-statement-lowering]] for the immediately
preceding dropped-value statement boundary.

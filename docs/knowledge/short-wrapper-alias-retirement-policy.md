---
id: short-wrapper-alias-retirement-policy
title: s/a/h wrapper aliases are retirement targets, not permanent syntax
answers:
  - "are s a h aliases permanent LinkedSpec syntax"
  - "should s() a() h() be retired"
  - "what are the canonical scalar array hash wrapper spellings"
  - "which task owns retiring s a h wrapper aliases"
  - "what happens if a spec uses s() a() h() now"
date: 2026-07-01
status: current
tags: [actionir, ast, aliases, retirement, spec-format]
evidence: "PERL-ACTIONIR-AST-MIGRATION.5.3.1 migrated repo-owned specs/docs/tests to scalar()/array()/hash(), removed s/a/h normalization from Perl and Rust wrapper dispatch paths, and locked retired calls as unresolved-helper diagnostics with zero raw fallback."
reverify: "rg -n '\\b(?:s|a|h)\\s*\\(' specs tests/corpus rust/linkedspec-runtime/tests/corpus; perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{s(foo)})'"
---

`s(...)`, `a(...)`, and `h(...)` are retired wrapper aliases. The canonical long wrapper
spellings are `scalar(...)`, `array(...)`, and `hash(...)`; direct shape literals remain
the preferred constructor surface where applicable.

`PERL-ACTIONIR-AST-MIGRATION.5.3.1` completed the migration of repo-owned specs, tests,
and docs away from the short aliases. Residual `s(...)`, `a(...)`, or `h(...)` calls now
enter the same unresolved-helper diagnostic path as other retired helper spellings:
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:s|a|h`, no raw-Perl fallback, and not
language-agnostic ready. `PERL-ACTIONIR-AST-MIGRATION.5.3.2` resumes user-function AST
call handoff. See [[perl-actionir-ast-value-drop-statement-lowering]] for the immediately
preceding dropped-value statement boundary.

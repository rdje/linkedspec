---
id: perl-actionir-ast-covered-call-diagnostics
title: Perl AST-covered helper calls diagnose unsupported forms instead of leaking host calls
answers:
  - "do unsupported covered helper calls leak as generated Perl calls"
  - "how are malformed AST helper calls diagnosed"
  - "what is LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER"
  - "does unsupported substr lower to host Perl substr"
  - "does unsupported count lower to host Perl count"
  - "does covered-call diagnostics increment raw Perl dependencies"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, diagnostics, method-lowering, helper-calls]
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.2.3 changed MethodLowering so known helper-family AST call nodes covered by .3.2.1/.3.2.2 but unsupported in their specific arity/argument form lower to a harmless LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name> sentinel instead of generated host-language calls. ActionIR::Diagnostics scans that sentinel into unresolved_helper_count/unresolved_helpers, marks the rule not language-agnostic-ready, and keeps raw_perl_dependency_count == 0. Focused tests cover substr, count, nested cat(substr(...)), and descriptor metadata; SPEC-FORMAT-TERSE.8.3 retired old concat(...) separately."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

Known helper-family calls that are already owned by AST lowering no longer fall through
to generated host-language calls when their exact AST form is unsupported. Examples
covered by the `.3.2.3` tests include malformed `substr(...)`, `count()`, and
`cat(substr(...), ...)` shapes.

`MethodLowering` emits a harmless expression containing the internal sentinel
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` and yielding `undef`. `ActionIR::Diagnostics`
then converts that sentinel into the existing unresolved-helper descriptor metadata:
`unresolved_helper_count`, `unresolved_helpers`, and not-language-agnostic-ready status.

This is diagnostics plumbing, not public DSL syntax. Unknown call names remain reserved
for future user-defined function resolution; supported helper forms still lower through
the existing helper catalog.

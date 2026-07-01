---
id: perl-actionir-ast-value-drop-statement-lowering
title: Perl standalone supported value statements lower as VALUE_DROP nodes
answers:
  - "do standalone Perl value helper statements lower from AST"
  - "what is VALUE_DROP in Perl ActionIR"
  - "does trim as a standalone statement remain raw Perl"
  - "are standalone user function calls value drops yet"
  - "do s a h compatibility probes return expressions or dropped statements"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, value-drop]
evidence: "PERL-ACTIONIR-AST-MIGRATION.5.2 added the value_drop_statement contract, scanner event, canonical VALUE_DROP mapping, and focused t/actionir_ast_parser.t coverage. Supported standalone value statements such as trim(\" x \"), concat(\"a\",\"b\"), and \" x \".trim() lower through MethodLowering AST value traversal and then discard the value; malformed covered helpers report unresolved-helper metadata; unknown user-function-shaped calls/chains remain .5.3 handoff work."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`PERL-ACTIONIR-AST-MIGRATION.5.2` gives supported standalone value expressions a
canonical statement-level path. The scanner recognizes covered helper calls and simple
receiver chains as `VALUE_DROP`, `MethodLowering` lowers the typed AST value, and the
statement wrapper discards the result with `undef`.

Malformed covered standalone helpers still use the unresolved-helper sentinel path
instead of raw fallback. Compatibility value-expression probes for `s(...)`, `a(...)`,
and `h(...)` still return expressions through `call_spec_handler_subst`; they are not
treated as dropped statements by that compatibility API. Unknown user-function-shaped
standalone calls/chains remain raw until `PERL-ACTIONIR-AST-MIGRATION.5.3` owns
resolution/diagnostics. See also [[perl-actionir-ast-value-only-call-lowering]] and
[[perl-actionir-ast-covered-call-diagnostics]].

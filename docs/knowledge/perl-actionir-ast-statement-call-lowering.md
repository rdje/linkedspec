---
id: perl-actionir-ast-statement-call-lowering
title: Perl helper-call statements consume ActionIR AST call nodes
answers:
  - "are Perl helper-call statements lowered from AST"
  - "does set assign statement lowering consume AST call nodes"
  - "does push statement lowering consume AST call nodes"
  - "does return statement lowering consume AST call nodes"
  - "does return_undef statement lowering consume AST call nodes"
  - "which leaf moved statement helper calls to AST"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, statements]
evidence: "PERL-ACTIONIR-AST-MIGRATION.4.2 changed MethodLowering and DeclareMethod so statement-form return, return_undef, set/assign, set_key, push, push_value, push_nonempty, and array end-mutation receiver statements consume typed AST call/fluent-chain fields before legacy source-text fallback. Focused t/actionir_ast_parser.t coverage poisons original source text and AST source fields across these statement families. Unsupported covered push_nonempty statements now surface the LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER sentinel instead of remaining as generated host calls."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now has a typed statement-call bridge for
the statement helper family:

- `return(...)` and `return_undef()`;
- `set_key(...)`;
- `push(...)`, `push_value(...)`, and `push_nonempty(...)`;
- receiver-dot array end mutations such as `items.push_back(value)`;
- block side-effect `assign(...)`/`set(...)` through MethodLowering.

Top-level `set(...)` / `assign(...)` goes through `perl/LinkedSpec/ActionIR/DeclareMethod.pm`,
so `.4.2` added a lazy AST bridge there too. That bridge intentionally stays inside the
lowerer body rather than in `default_deps_for_package(...)`, preserving the synthetic
owner dependency-builder test contract.

The AST path does not make AST `source` fields authoritative. It materializes supported
arguments from typed node fields and then re-enters the existing statement helper catalog.
This preserves existing slot behavior: `push_value`/`push_nonempty` keep their legacy value
slot, while `set_key` and array end mutations keep mutation scalar-read slots. Raw
compatibility arguments such as `scalaref(retv, {content})` and host-style
`substr($$STRING, ...)` still fall back to the legacy path until a later leaf types them.

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
evidence: "PERL-ACTIONIR-AST-MIGRATION.4.2 changed MethodLowering and DeclareMethod so statement-form return, return_undef, set/assign, set_key, push, and array end-mutation receiver statements consume typed AST call/fluent-chain fields before legacy source-text fallback. SPEC-FORMAT-TERSE.8.3 later retired Perl `push_value(...)` and `push_nonempty(...)`; focused t/actionir_ast_parser.t coverage now poisons original source text and AST source fields while proving current `push(...)` still lowers from typed AST fields and retired old append helpers emit LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER sentinels instead of generated host calls."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now has a typed statement-call bridge for
the statement helper family:

- `return(...)` and `return_undef()`;
- `set_key(...)`;
- `push(...)`;
- retired `push_value(...)` and `push_nonempty(...)` diagnostic paths;
- receiver-dot array end mutations such as `items.push_back(value)`;
- block side-effect `assign(...)`/`set(...)` through MethodLowering.

Top-level `set(...)` / `assign(...)` goes through `perl/LinkedSpec/ActionIR/DeclareMethod.pm`,
so `.4.2` added a lazy AST bridge there too. That bridge intentionally stays inside the
lowerer body rather than in `default_deps_for_package(...)`, preserving the synthetic
owner dependency-builder test contract.

The AST path does not make AST `source` fields authoritative. It materializes supported
arguments from typed node fields and then re-enters the existing statement helper catalog.
This preserves existing slot behavior for current helpers: `push(...)` keeps explicit append
slots, retired `push_value(...)`/`push_nonempty(...)` return diagnostics, and `set_key`
plus array end mutations keep mutation scalar-read slots. Raw
compatibility arguments such as host-style `substr($$STRING, ...)` still fall back to the
legacy path until a later leaf types them. The former `scalaref(retv, {content})` example
was migrated to direct nested access and then removed under `SCALAREF-RETIREMENT`.

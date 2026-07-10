# 0011 — Backend helper/action semantics must parse text to AST before lowering or execution

- Date: 2026-07-01
- Status: accepted
- Tags: architecture, compiler, actionir, ast, doctrine, cross-variant-parity, perl-reference

## Context

LinkedSpec is a universal `.spec` language with multiple backends. The Rust variant
already parses helper/action code into typed expression statements (`Expr::Call`,
`Expr::FluentChain`, assignment nodes, block values, literals, and related nodes) before
runtime evaluation.

The Perl reference backend still contains legacy ActionIR paths that lower many helper
and receiver-chain expressions by structured source-text scanning and generated Perl
source emission. Those scanners are more disciplined than arbitrary regex replacement,
but the architecture is still text-to-text for important surfaces. That is too fragile
for the next language features, especially user-defined functions where accidental
host-language fallback would be unacceptable.

## Decision

Adopt text-to-AST as a cross-variant doctrine:

1. Every conforming backend must parse `.spec` helper/action language text into typed
   AST/IR nodes before lowering, interpretation, or code emission.
2. Text-to-text rewriting is legacy migration debt, not an accepted architecture for new
   supported surfaces.
3. The Perl reference backend must migrate away from ActionIR text-to-text lowering in
   careful, regression-locked slices.
4. New features, including user-defined functions, must consume AST/IR call nodes and
   must not add broad textual macro expansion or host-language fallback.
5. Future Julia and Dart backends must be text-to-AST from the start. ADR `0021`
   later accepted Lua as a scheduled backend target after Dart and Julia; Lua
   inherits the same doctrine.

## Consequences

- The mdBook backend handoff and compiler pipeline chapters now state AST/IR as a backend
  conformance requirement, not an implementation preference.
- The Perl migration is owned by `PERL-ACTIONIR-AST-MIGRATION`; it must start with an
  inventory and parser seam before replacing lowering families.
- Existing behavior remains regression-locked while the internals change. The doctrine
  changes implementation architecture; it does not by itself change `.spec` user syntax.
- Supported helper/value/control surfaces should diagnose unsupported calls instead of
  leaking into generated host-language subroutines or host-language expression parsing.

## Links

- Task tree: `docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md`
- Related: ADR `0006` multi-backend vision, ADR `0007` terse format direction, ADR `0003`
  raw-Perl-free spec authoring

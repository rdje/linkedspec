# 0021 - Future backend rollout order: Dart, then Julia, then Lua

- Date: 2026-07-09
- Status: accepted
- Tags: architecture, portability, backends, roadmap, cross-variant-parity

## Context

ADR `0006` accepted the multi-backend vision with Perl as the reference backend, Rust as
the first additional backend, and Julia/Dart as future targets. Later task-tree and
Knowledge Map records deliberately kept Lua outside the accepted backend set until an
explicit decision adopted it.

After the language-reference closeout, the director asked for the deferred backlog to be
captured as task-tree work and explicitly directed the backend rollout order: start with
Dart, then Julia, then Lua. The stated goal is full parity with Perl5 and Rust.

## Decision

1. The future backend rollout order is:
   - Dart first
   - Julia second
   - Lua third
2. Lua is now adopted as a future LinkedSpec backend target. It inherits the same universal
   `.spec` contract, helper/action AST doctrine, staged parsing contract, runtime semantics,
   diagnostics, and language-neutral corpus parity obligations as Dart and Julia.
3. Perl5 remains the reference backend and Rust remains the implemented lockstep backend.
   Dart, Julia, and Lua must converge to full parity with both.
4. No backend implementation starts without an owning task-tree leaf. The active owner is
   `FUTURE-PARITY-BACKLOG`, whose first executable backend leaf is
   `FUTURE-PARITY-BACKLOG.1.1` for Dart parity scoping.

## Consequences

- Existing "Lua blocked until decision" wording is superseded by this record.
- Backend documentation should name Dart, Julia, and Lua as scheduled future targets in
  that order.
- Any Dart/Julia/Lua implementation must use typed AST/IR for helper/action semantics and
  must not introduce per-backend `.spec` dialects.
- The mdBook backend handoff remains the implementation entry point for all future
  backends.

## Links

- Task tree: `docs/tasks/FUTURE-PARITY-BACKLOG.md`
- Original backend vision: `docs/decisions/0006-multi-backend-vision.md`
- Text-to-AST doctrine: `docs/decisions/0011-text-to-ast-backend-doctrine.md`
- Backend handoff: `docs/linkedspec-book/src/appendix/backend-handoff.md`

# BACKBONE-ACTION-IR-LOWERING: Backbone Item 3 — ActionIR/Rewrite/Lowering Pipeline

## Metadata

- Tree ID: `BACKBONE-ACTION-IR-LOWERING`
- Status: `active`
- Roadmap lane: `Backbone refactor track`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
- Owner: repo-local workflow

## Goal

Complete the structured ActionIR/rewrite/lowering pipeline: finish the remaining ActionIR/EmitContext owner-contract cleanup, reduce compatibility-surface coupling, and drive toward the final objective of eliminating raw Perl code blocks in `.spec`.

## Non-Goals

- Full action AST/IR lowering (still planned but deferred past close-out).
- New DSL features outside the ActionIR lowering surface.
- Bootstrap grammar changes (Backbone Item 1, done).

## Acceptance Criteria

- All ActionIR owners spend `OwnerDispatch` uniformly with no duplicate local validators.
- EmitContext owner-contract is clean and auditable.
- Compatibility-surface reduction is complete for the current shipped surface.
- `t/phase0_regression.t` stays green.
- Backbone Item 3 tracker flips to `done`.

## Task Tree

- ID: `BACKBONE-ACTION-IR-LOWERING`
  Status: `active`
  Goal: `Complete the ActionIR lowering pipeline close-out.`
  Children: `BACKBONE-ACTION-IR-LOWERING.1`

- ID: `BACKBONE-ACTION-IR-LOWERING.1`
  Status: `pending`
  Goal: `Audit remaining ActionIR owner surfaces: verify that every ActionIR owner (Scanner, StatementSplit, CanonicalEvents, Diagnostics, RewritePipeline, ArrayPipeline, Contracts, ControlFlow, MethodLowering, ValueExpr, FlowExpr, DeclareMethod) has clean OwnerDispatch usage and no stale duplicate validators.`
  Acceptance: `Task file lists each ActionIR owner, its OwnerDispatch status, any remaining duplicate validators or compatibility wrappers, and names the next close-out leaf.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `BACKBONE-ACTION-IR-LOWERING.1` | `pending` | Need an ActionIR owner-contract audit before declaring Backbone Item 3 done. |

## Decisions

- `2026-05-16`: Created task tree. Backbone Item 3 is `mostly done` per `ROADMAP_V2.md` with extensive OwnerDispatch centralization already landed.

## Open Questions

- Are there remaining local `_require_dep(...)` wrappers in any ActionIR owner? (Answer pending audit.)

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| — | — | — | — |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| — | — | — | — |

## Changelog

- `2026-05-16`: Created task tree from template.

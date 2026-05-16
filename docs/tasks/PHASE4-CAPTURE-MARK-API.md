# PHASE4-CAPTURE-MARK-API: Phase 4 Capture/Mark API Formalization

## Metadata

- Tree ID: `PHASE4-CAPTURE-MARK-API`
- Status: `active`
- Roadmap lane: `Phase 4`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
- Owner: repo-local workflow

## Goal

Complete the capture/mark API formalization: finish the first-class mark/checkpoint and capture-helper surface, close out remaining compatibility-alias cleanup, and ensure all shipped `.spec` files use the canonical helper surface.

## Non-Goals

- New capture primitives beyond the already-planned surface.
- Parse-mode semantics (Phase 3).
- Runtime/diagnostics changes (Phase 5).

## Acceptance Criteria

- Named marks and anonymous capture boundaries are first-class, transparent concepts.
- All capture/mark helpers have clear documented semantics.
- Legacy `$CAPTURE` and compatibility aliases are preserved but documented as legacy.
- Shipped `.spec` files use canonical helpers where practical.
- Phase 4 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE4-CAPTURE-MARK-API`
  Status: `active`
  Goal: `Complete capture/mark API formalization.`
  Children: `PHASE4-CAPTURE-MARK-API.1`

- ID: `PHASE4-CAPTURE-MARK-API.1`
  Status: `pending`
  Goal: `Inventory current capture/mark surface: list every shipped helper, its documentation status, remaining compatibility-alias surface, and any gap between what is implemented and what the roadmap promised.`
  Acceptance: `Task file maps each helper family (anonymous boundary, named mark, cursor, whole-input, immediate-match, local-match) to implementation status, doc coverage, and remaining work.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE4-CAPTURE-MARK-API.1` | `pending` | Need a complete surface inventory before closing out or extending. |

## Decisions

- `2026-05-16`: Created task tree. The capture/mark API has an extensive landed surface spanning anonymous-boundary, named-mark, cursor, whole-input, immediate-match, and local-match families.

## Open Questions

- Are there remaining raw `$IPOS`/`$IMATCH`/`$$STRING` occurrences in shipped `.spec` files that should migrate? (Answer pending inventory.)

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

# PHASE3-EXECUTION-SEMANTICS: Phase 3 Execution Semantics Clarification

## Metadata

- Tree ID: `PHASE3-EXECUTION-SEMANTICS`
- Status: `active`
- Roadmap lane: `Phase 3`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
- Owner: repo-local workflow

## Goal

Complete formal parse-mode semantics: `seek` and `consume` modes with clear documented behavior contracts, orthogonal to `OR`/`AND` rule composition, and explicit about the non-backtracking forward-moving model.

## Non-Goals

- Full parser-engine backtracking (explicitly out of scope per roadmap).
- Capture/mark API (Phase 4).
- Runtime modernization (Phase 5).

## Acceptance Criteria

- `seek` and `consume` modes have deterministic documented behavior.
- Mode selection is orthogonal to rule composition.
- Backtracking helpers (`BACKTRACK`, `IBACKTRACK`) are documented as local cursor-rewind, not systemic search-tree rollback.
- Phase 3 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE3-EXECUTION-SEMANTICS`
  Status: `active`
  Goal: `Complete parse-mode semantics clarification.`
  Children: `PHASE3-EXECUTION-SEMANTICS.1`

- ID: `PHASE3-EXECUTION-SEMANTICS.1`
  Status: `pending`
  Goal: `Inventory current parse-mode surface: what is shipped, what is documented, and what gaps remain between the implemented contract and the documented contract.`
  Acceptance: `Task file lists each shipped parse-mode feature, its documentation status, known behavior gaps, and names the next executable leaf.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE3-EXECUTION-SEMANTICS.1` | `pending` | Need an accurate surface inventory before further semantics work. |

## Decisions

- `2026-05-16`: Created task tree. First-slice parse modes (`seek`/`consume`) are already landed with public `parse_mode` option.

## Open Questions

- Are there edge cases where `seek` vs `consume` behavior diverges from the documented contract? (Answer pending inventory.)

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

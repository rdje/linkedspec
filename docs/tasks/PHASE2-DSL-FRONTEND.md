# PHASE2-DSL-FRONTEND: Phase 2 DSL Frontend Hardening

## Metadata

- Tree ID: `PHASE2-DSL-FRONTEND`
- Status: `active`
- Roadmap lane: `Phase 2`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
- Owner: repo-local workflow

## Goal

Complete deterministic DSL frontend validation so that no malformed `.spec`
token, rule header, edge target, action fluent, block delimiter, or split
marker is silently accepted or skipped by the parser.

## Non-Goals

- Execution semantics changes (Phase 3).
- Capture/mark API formalization (Phase 4).
- Runtime/compiler backend modernization (Phase 5).
- Self-hosted `.spec` grammar (Phase 7).

## Acceptance Criteria

- Deterministic DSL validation for all shipped `specs/*.spec`.
- No silent token-loss in strict mode.
- High-quality error messages with rule/source context for every validation rejection.
- Compatibility mode or explicit migration path for legacy `.spec` authoring patterns.
- Phase 2 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE2-DSL-FRONTEND`
  Status: `active`
  Goal: `Complete deterministic DSL frontend hardening.`
  Children: `PHASE2-DSL-FRONTEND.1`

- ID: `PHASE2-DSL-FRONTEND.1`
  Status: `in_progress`
  Goal: `Inventory current DSL frontend validation coverage: list every validation point, error surface, known gap, and the next hardening priority.`
  Acceptance: `The task file documents each currently-rejected malformed pattern from ROADMAP.md line 213, maps them to the owning validation code, lists any remaining silent-acceptance gaps, and names the next executable leaf.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE2-DSL-FRONTEND.1` | `in_progress` | Need an accurate validation-coverage inventory before hardening further. |

## Decisions

- `2026-05-16`: Created task tree with one inventory leaf. Phase 2 hardening continues from the existing shipped validation points listed in `ROADMAP.md` line 213.

## Open Questions

- Which validation points still silently accept malformed input? (Answer pending inventory.)
- Should strict mode be default for new `.spec` files or opt-in? (Pending decision.)

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-16` | `PHASE2-DSL-FRONTEND.1` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `PHASE2-DSL-FRONTEND.1` | `pending` | `pending` |

## Changelog

- `2026-05-16`: Created task tree from `docs/tasks/TEMPLATE.md`.

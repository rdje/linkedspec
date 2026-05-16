# PHASE6-DOCUMENTATION: Phase 6 Documentation and Adoption

## Metadata

- Tree ID: `PHASE6-DOCUMENTATION`
- Status: `active`
- Roadmap lane: `Phase 6`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
- Owner: repo-local workflow

## Goal

Maintain and expand project documentation so every user-facing surface, architecture decision, and workflow convention is clearly explained, current at each commit, and usable for both new users and returning maintainers.

## Non-Goals

- New DSL features or behavior changes.
- Self-hosted grammar (Phase 7).

## Acceptance Criteria

- `USER_GUIDE.md` covers practical patterns, anti-patterns, and major DSL families with extensive worked examples.
- `ARCHITECTURE_STATE.md` is refreshed after each major structural change.
- `DEVELOPMENT_NOTES.md` records architecture rationale.
- `MEMORY.md` and `LIVE_ACHIEVEMENT_STATUS.md` are updated per slice.
- `docs/linkedspec-book/` reflects the current public understanding of LinkedSpec.
- Doc paths use repo-root-relative references (regression-locked).
- Phase 6 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE6-DOCUMENTATION`
  Status: `active`
  Goal: `Maintain project documentation at production quality.`
  Children: `PHASE6-DOCUMENTATION.1`

- ID: `PHASE6-DOCUMENTATION.1`
  Status: `pending`
  Goal: `Inventory documentation coverage: map each user-facing DSL surface, architecture component, and workflow to its current doc coverage, identify thin spots, and name the highest-priority backfill leaf.`
  Acceptance: `Task file lists doc gaps with priority ordering, and the next executable documentation leaf is defined.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE6-DOCUMENTATION.1` | `pending` | Need a doc-coverage inventory before targeted backfill. |

## Decisions

- `2026-05-16`: Created task tree. Documentation is maintained live per the documentation quality contract in `ROADMAP.md`.

## Open Questions

- Which user-facing DSL families have the thinnest documentation? (Answer pending inventory.)

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

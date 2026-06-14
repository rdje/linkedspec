# PLUGIN-ACTION-MIGRATION-STALE-REFERENCES: Fix stale "proposed" → "retired" references

## Metadata

- Tree ID: `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES`
- Status: `completed`
- Roadmap lane: `Overall roadmap — documentation and tracker maintenance`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Fix all stale references that still describe `PLUGIN-ACTION-MIGRATION` as "proposed" or "pending" when the tree is actually `retired` (all 5 leaves done; 17 dead files deleted; 19 kept as legacy corpus).

## Non-Goals

- Do not rewrite dated historical log entries in CHANGES.md, DEVELOPMENT_NOTES.md, or LIVE_ACHIEVEMENT_STATUS.md that were accurate at the time they were written.
- Do not change the retired tree file itself (docs/tasks/PLUGIN-ACTION-MIGRATION.md — already correct).
- Do not change any code.

## Acceptance Criteria

- All 10 stale references updated from "proposed"/"pending" to "retired".
- Memory architecture self-check passes.
- Live docs updated (CHANGES.md, DEVELOPMENT_NOTES.md, LIVE_ACHIEVEMENT_STATUS.md, MEMORY.md).
- Tree moved to Completed.

## Task Tree

- ID: `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES`
  Status: `completed`
  Goal: `Fix stale PLUGIN-ACTION-MIGRATION status references`
  Children: `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1`

- ID: `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1`
  Status: `done`
  Goal: `Fix all 10 stale references across 6 files that still describe PLUGIN-ACTION-MIGRATION as "proposed" instead of "retired".`
  Acceptance: `All 10 references updated; memory-arch check passes; live docs updated; committed.`
  Verification: `PASS`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |

## Decisions

- `2026-06-14`: Single-leaf tree — all 10 references are the same class of fix.
- `2026-06-14`: Historical dated log entries (CHANGES.md older entries, DEVELOPMENT_NOTES.md older entries, LIVE_ACHIEVEMENT_STATUS.md older entries) are NOT being rewritten — they were accurate for their timestamp. Only current-state claims are being fixed.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1` | `scripts/check_memory_architecture.sh` PASS; grep verify zero remaining stale "proposed" references; syntax OK | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1` | `c2f3294` — Docs: PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1 — fix 10 stale proposed → retired references | |

## Changelog

- `2026-06-14`: Created task tree.

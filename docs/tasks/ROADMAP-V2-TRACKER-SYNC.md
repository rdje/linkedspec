# ROADMAP-V2-TRACKER-SYNC: Roadmap V2 Tracker Synchronization

## Metadata

- Tree ID: `ROADMAP-V2-TRACKER-SYNC`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and tracker maintenance`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Bring the ROADMAP_V2.md live tracker into accurate sync with the completed task trees
(COMPAT-ALIAS-RETIREMENT-V2, COMPAT-ALIAS-TEST-CLEANUP, PLUGIN-ACTION-MIGRATION),
audit the mdBook for drift against the current codebase, and update all live docs
so the next session resumes from an accurate state.

## Non-Goals

- No new feature implementation.
- No spec/DSL changes.
- No plugin migration work (PLUGIN-ACTION-MIGRATION is retired).
- No architecture refactoring.

## Acceptance Criteria

- ROADMAP_V2.md tracker accurately reflects all completed task trees.
- ROADMAP.md tracker is synchronized with ROADMAP_V2.md.
- LIVE_ACHIEVEMENT_STATUS.md, MEMORY.md, CHANGES.md, and DEVELOPMENT_NOTES.md are updated.
- mdBook chapters are audited for drift and updated where stale.
- Local CI gate passes.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `ROADMAP-V2-TRACKER-SYNC`
  Status: `active`
  Goal: `Synchronize ROADMAP_V2.md tracker with completed task trees, audit mdBook, update live docs.`
  Children: `ROADMAP-V2-TRACKER-SYNC.1`, `ROADMAP-V2-TRACKER-SYNC.2`, `ROADMAP-V2-TRACKER-SYNC.3`, `ROADMAP-V2-TRACKER-SYNC.4`, `ROADMAP-V2-TRACKER-SYNC.5`

- ID: `ROADMAP-V2-TRACKER-SYNC.1`
  Status: `pending`
  Goal: `Audit current empirical state: verify all 20 specs compile, check compatibility-surface counts, enumerate all ROADMAP_V2.md tracker staleness items.`
  Acceptance: `A documented inventory of every stale/incorrect row in the ROADMAP_V2.md tracker, with each item mapped to the completed task tree that resolved it.`
  Verification: `pending`
  Commit: `pending`

- ID: `ROADMAP-V2-TRACKER-SYNC.2`
  Status: `pending`
  Goal: `Update ROADMAP_V2.md tracker to reflect reality: fix method-like DSL migration track status, remove stale "remaining open" items, update overall roadmap status if warranted. Sync ROADMAP.md tracker if needed.`
  Acceptance: `ROADMAP_V2.md tracker rows are accurate. All "remaining open" items are resolved or accurately reflect current state. ROADMAP.md tracker is aligned.`
  Verification: `pending`
  Commit: `pending`

- ID: `ROADMAP-V2-TRACKER-SYNC.3`
  Status: `pending`
  Goal: `Update live docs: LIVE_ACHIEVEMENT_STATUS.md (latest completed slice), MEMORY.md (resume pointer), CHANGES.md (technical history), DEVELOPMENT_NOTES.md (rationale).`
  Acceptance: `All four live docs reflect the current state. MEMORY.md within size cap.`
  Verification: `pending`
  Commit: `pending`

- ID: `ROADMAP-V2-TRACKER-SYNC.4`
  Status: `pending`
  Goal: `Audit mdBook chapters for drift against current codebase state. Update any stale references, deprecation notes, or out-of-date status claims.`
  Acceptance: `All mdBook chapters reviewed; stale references identified and fixed. Book SUMMARY.md and chapter content aligned with codebase reality.`
  Verification: `pending`
  Commit: `pending`

- ID: `ROADMAP-V2-TRACKER-SYNC.5`
  Status: `pending`
  Goal: `Finalization: run full CI gate, verify all docs are consistent, close out the tree.`
  Acceptance: `Local CI gate passes. Tree moved to Completed in TASK_TREE.md. MEMORY.md updated.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `ROADMAP-V2-TRACKER-SYNC.1` | `pending` | Must inventory staleness before making any tracker changes. |

## Decisions

- `2026-06-14`: This tree covers documentation/tracker sync only — no feature work. If the audit discovers real implementation gaps, those will be spun into a separate follow-on task tree.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `ROADMAP-V2-TRACKER-SYNC.1` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `ROADMAP-V2-TRACKER-SYNC.1` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree. No active trees existed; ROADMAP_V2.md tracker is stale after COMPAT-ALIAS-RETIREMENT-V2 and COMPAT-ALIAS-TEST-CLEANUP completions.

# TASK-TREE-INDEX-SYNC: Reconcile stale frontier column in docs/TASK_TREE.md

## Metadata

- Tree ID: `TASK-TREE-INDEX-SYNC`
- Status: `completed`
- Roadmap lane: `Overall roadmap — documentation and tracker maintenance`
- Created: `2026-06-16`
- Last updated: `2026-06-16`
- Owner: repo-local workflow

## Goal

Make the `Active Task Trees` table in `docs/TASK_TREE.md` honest: its `Current frontier`
column had drifted out of sync with the per-tree `## Current Frontier` sections (the
authoritative source) after leaves completed without the index row being refreshed.

## Non-Goals

- Does not change any project code, tests, book content, or the per-tree task files
  themselves (those frontiers were already correct).
- Does not re-order or re-prioritise any frontier; only mirrors the already-true value.
- Does not address the `RTLUTILS-REGEX-HANG` blocker (separate, unowned — flagged in MEMORY.md).

## Acceptance Criteria

- `docs/TASK_TREE.md` `Active Task Trees` row for `SPEC-SPEC-SELFHOST` shows frontier
  `SPEC-SPEC-SELFHOST.4` (matches `docs/tasks/SPEC-SPEC-SELFHOST.md` `## Current Frontier`).
- `docs/TASK_TREE.md` `Active Task Trees` row for `RUST-PARITY` shows frontier
  `RUST-PARITY.5` (matches `docs/tasks/RUST-PARITY.md` `## Current Frontier`; `.4` superseded).
- The `MDBOOK-VARIANT-AGNOSTIC` row (frontier `.1`) is already correct — left unchanged.
- This tree is listed in the `Completed Task Trees` table.
- Memory-architecture self-check passes; live docs updated; committed per `COMMIT.md`.

## Task Tree

- ID: `TASK-TREE-INDEX-SYNC`
  Status: `completed`
  Goal: `Reconcile stale frontier column in docs/TASK_TREE.md against the per-tree frontiers`
  Children: `TASK-TREE-INDEX-SYNC.1`

- ID: `TASK-TREE-INDEX-SYNC.1`
  Status: `done`
  Goal: `Fix the SPEC-SPEC-SELFHOST (.2 -> .4) and RUST-PARITY (.1 -> .5) frontier index rows; register this tree as completed`
  Acceptance: `Index frontier column matches each tree's authoritative ## Current Frontier section`
  Verification: `grep of docs/TASK_TREE.md rows vs per-tree frontiers; scripts/check_memory_architecture.sh exit 0`
  Commit: `TASK-TREE-INDEX-SYNC.1 — reconcile stale frontier index in docs/TASK_TREE.md`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `TASK-TREE-INDEX-SYNC.1` | `done` | Single administrative reconcile; tree complete |

## Decisions

- `2026-06-16`: The per-tree `## Current Frontier` sections in `docs/tasks/*.md` are the
  authoritative frontier source; the `docs/TASK_TREE.md` index `Current frontier` column is a
  derived mirror that must be refreshed whenever a leaf completes. The drift here was caused by
  prior `SPEC-SPEC-SELFHOST.2/.3` and `RUST-PARITY.2` completions not refreshing the index row.
- `2026-06-16`: Modelled on the completed one-leaf `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES`
  tree (same shape: a small tracker-hygiene fix made visible in the ledger before landing).

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `TASK-TREE-INDEX-SYNC.1` | index rows vs per-tree frontiers; `scripts/check_memory_architecture.sh` | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `TASK-TREE-INDEX-SYNC.1` | `TASK-TREE-INDEX-SYNC.1 — reconcile stale frontier index in docs/TASK_TREE.md` | Populated after commit |

## Changelog

- `2026-06-16`: Created tree and completed `.1` in one slice — reconciled the stale
  `Active Task Trees` frontier column (`SPEC-SPEC-SELFHOST` `.2`->`.4`, `RUST-PARITY` `.1`->`.5`).

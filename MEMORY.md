# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL (Perl). This file is **layer A** of
`MEMORY_ARCHITECTURE.md`: the bounded, overwrite-only pointer to *now* — not a log. Its
full history lives in git (layer D); per-unit work lives in the task-trees (layer B);
durable cross-cutting facts live in `docs/decisions/` (layer C).

## How to resume
- Read `MEMORY_ARCHITECTURE.md` (the memory system — mandatory and mechanically enforced)
  and `README.md` (project objective/layout), then `SESSION_BOOTSTRAP.md`.
- Work is tracked in task-trees under `docs/tasks/` (index: `docs/TASK_TREE.md`); follow
  the commit workflow in `COMMIT.md` with the task-tree leaf id in the subject.
- Durable facts/decisions live in `docs/decisions/` (index: `INDEX.md`).
- Doctrine (non-negotiable): no change without an owning task-tree leaf first — see
  `docs/decisions/0001-task-tree-and-commit-doctrine.md`.
- Before committing, run `scripts/check_memory_architecture.sh` (git hooks + the local CI
  gate `tools/run_ci_local.sh` enforce it).

## Current state (OVERWRITE this block each update — do not append)
- latest_commit: `cffac62` — "PLUGIN-ACTION-MIGRATION.5 — delete 7 dead Category D .plg files; tree COMPLETE"
- active_work_unit: none — `PLUGIN-ACTION-MIGRATION` complete (5/5 leaves). All task trees complete. PNT idle.
- next_action: PNT from roadmap priorities or await user direction. Remaining deferred work: action-body migration for 19 .plg files (future tree).
- regression baseline: 17 .plg files deleted (1,030 lines, 45 actions). 19 files remain. Corpus regression discovers dynamically.
- in_flight_uncommitted: MEMORY.md hash backfill (cosmetic only)
- blockers: none.

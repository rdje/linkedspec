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
- latest_commit: `644c1a8` — "PLUGIN-ACTION-MIGRATION.5 — post-commit cleanup: fix MEMORY.md hash drift"
- active_work_unit: `COMPAT-ALIAS-RETIREMENT` → frontier leaf: `COMPAT-ALIAS-RETIREMENT.1` (`done`)
- next_action: continue PNT: `COMPAT-ALIAS-RETIREMENT.2` (remove medium-term aliases from implementation)
- regression baseline: 1004 PASS (phase0). Short-term aliases (tail/drop_last/flatten/array_values) removed from 5 impl files.
- in_flight_uncommitted: COMPAT-ALIAS-RETIREMENT.1 complete; about to commit
- blockers: none.

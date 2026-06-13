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
- latest_commit: `6053050` — "MEDIUM-IMPACT.3.5 — Wire spec.spec as dual-path parse in BootstrapSpec.pm"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.3.6` (full regression verification + documentation — committed below)
- next_action: Run full CI gate (tools/run_ci_local.sh) and verify phase0 regression baseline.
- .3.6 completed: ARCHITECTURE_STATE.md refreshed (2026-06-13), knowledge map card updated, task tree closed out (.3.4.4+.3.5→done, frontier→.3.6, commit hashes backfilled), CHANGES/DEVELOPMENT_NOTES/LIVE_ACHIEVEMENT_STATUS updated. 20/20 specs compile OK. Cross-check at 2/20 match.
- Completed leaves: .1.1→.1.5, .2.1→.2.4, .3.1, .3.2, .3.3, .3.4.1→.3.4.4, .3.5, .3.6.
  Pending: none — MEDIUM-IMPACT tree exhausted. PNT idle.
- regression baseline: 20/20 specs compile (quick smoke). Full CI pending.
- in_flight_uncommitted: .3.6 commit being prepared.
- blockers: none

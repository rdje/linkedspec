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
- latest_commit: `6a8cb80` — "Docs: post-commit hash fix — MEMORY.md latest_commit → 662b642"
- active_work_unit: `RUST-FUNCTIONAL-PARITY` → frontier: `.3.1` (expr parser hardening), `.4.1` (compiler), `.5.1` (regex engine), `.5.2` (lifecycle), `.6.1` (expr interpreter), `.7.1–.7.3` (helpers)
- next_action: PNT from .3.1 → continue expanding helpers (.7.1–.7.3)
- in_flight_uncommitted: RUST-FUNCTIONAL-PARITY.1 + .2 — 51 tests pass, 20/20 specs parse+validate+compile
- blockers: none

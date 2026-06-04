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
- latest_commit: `4f4b5d7` — "Wire KM gate (pre-commit + CI) + reconcile pointers + ADR 0005 (KNOWLEDGE-MAP-DOC.3)"  (well ahead of origin/main; push only on explicit ask or after a requested batch)
- active_work_unit: none — `KNOWLEDGE-MAP-DOC` complete (4/4 leaves). No active task trees; PNT is idle. (Proposed-only: `PLUGIN-ACTION-MIGRATION`, not yet activated.)
- next_action: none pending — await direction (e.g. activate `PLUGIN-ACTION-MIGRATION`) or a new task. Durable memory (layers A–D) + the Knowledge Map retrieval layer are both adopted and gated; keep committing per `COMMIT.md` so the pre-commit + local CI gates stay green, and write a `docs/knowledge/` card whenever you establish a durable fact or catch archaeology.
- regression baseline: phase0 `Files=1, Tests=1004, PASS` (`bash tools/run_ci_local.sh`, which runs the memory-arch self-check + the Knowledge Map check before perl -c + phase0).
- in_flight_uncommitted: none after this commit.
- blockers: none.

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
- latest_commit: `7355f08` — "Verify memory-architecture end-to-end (full local gate green) + close tree (MEMORY-ARCHITECTURE-DOC.5)"  (well ahead of origin/main; push only on explicit ask or after a requested batch)
- active_work_unit: `KNOWLEDGE-MAP-DOC` → frontier leaf: `KNOWLEDGE-MAP-DOC.3` (.1–.2 done — bundle vendored, 6 fact cards seeded, KNOWLEDGE_MAP.md = 6 facts / 29 keys, check OK)
- next_action: implement `KNOWLEDGE-MAP-DOC.3` — wire the KM gate into `.githooks/pre-commit` (replace the `exec` so the memory-arch self-check AND the KM regenerate+stage+check both run) and into `tools/run_ci_local.sh`; reconcile the bootstrap pointers (AGENTS/CLAUDE/.cursorrules/copilot) to reference `KNOWLEDGE_MAP.md`; add decision record 0005; prove the KM gate bites.
- regression baseline: phase0 `Files=1, Tests=1004, PASS` (`bash tools/run_ci_local.sh`, which runs the memory-arch self-check first; the KM check joins the gate in `.3`).
- in_flight_uncommitted: none after this commit.
- blockers: none.

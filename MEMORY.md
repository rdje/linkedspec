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
- latest_commit: `654b9c0` — "MEDIUM-IMPACT.1.1 — SpecEntry Perl coupling inventory"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.2.2` (fuzz _parse_rule_label_line)
- next_action: PNT — execute MEDIUM-IMPACT.2.2 or next eligible leaf.
- MEDIUM-IMPACT.2.1 done: fuzzing harness at t/phase0_validation_fuzz.t (5 subtests, 168 combinatorial cases).
- MEDIUM-IMPACT.1.1 done: SpecEntry coupling inventory.
- MEDIUM-IMPACT.3.4 blocked: AND handler architecture limitation.
- regression baseline: 1005 PASS (phase0). Fuzz harness: 5/5 subtests PASS.
- in_flight_uncommitted: MEDIUM-IMPACT.2.1 completion (pending commit).
- blockers: MEDIUM-IMPACT.3.4.

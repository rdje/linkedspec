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
- latest_commit: `316262f` — "MEDIUM-IMPACT.3.3 — post-commit hash fix: MEMORY.md latest_commit → 5725f87"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.1.1` (SpecEntry coupling inventory)
- next_action: PNT — execute MEDIUM-IMPACT.1.1: inventory all Perl coupling points in SpecEntry.pm.
  Document eval sites, generated-code patterns, Perl-variable assumptions, LinkedRE::or dependencies
  across the 12 handler-variant builders. Pure documentation leaf — no code changes.
- MEDIUM-IMPACT.3.4 blocked: AND handler routes I-block to preamble where return() exits before
  edge processing. Needs infrastructure plan. Three fix approaches documented in task tree.
- regression baseline: 1005 PASS (phase0). Cross-check: 10/20 match, 10/20 inflated candidate counts.
- in_flight_uncommitted: none
- blockers: MEDIUM-IMPACT.3.4 (AND handler architecture limitation — see task tree).

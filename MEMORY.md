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
- latest_commit: `5725f87` — "MEDIUM-IMPACT.3.3 — post-commit hash fix: MEMORY.md latest_commit → e2ea174"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.3.4` (fix cross-check gaps:
  AND handler E-block support, body_element over-matching)
- next_action: PNT — execute MEDIUM-IMPACT.3.4 (fix spec.spec gaps from .3.3 cross-check).
  Primary gap: rule_paragraph AND handler lacks E-block body collection (all 10 mismatched
  specs over-count body elements). Also: body_element:* too broad (matches individual body
  lines as separate rule paragraphs).
- regression baseline: 1005 PASS (phase0). Cross-check: 10/20 match, 10/20 inflated candidate counts.
- in_flight_uncommitted: MEMORY.md hash update only (5725f87 not yet committed).
- blockers: none.

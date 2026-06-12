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
- latest_commit: `edc6255` — "Docs: post-commit hash fix — MEMORY.md latest_commit → 90a1e91"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.3.4` (fix cross-check gaps:
  AND handler E-block support, body_element over-matching)
- next_action: Execute MEDIUM-IMPACT.3.4 — fix the 10 spec gaps found in .3.3 cross-check.
  Primary: add E-block body collection to spec.spec rule_paragraph AND handler. Secondary: tighten
  body_element:* to not over-match body lines as separate rule paragraphs.
- regression baseline: 1005 PASS (phase0).
- in_flight_uncommitted: MEDIUM-IMPACT.3.3 completion (cross-check harness built, results documented,
  pending commit).
- blockers: none.

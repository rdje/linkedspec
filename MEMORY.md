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
- latest_commit: `7425c8f` — "MEDIUM-IMPACT.2.4 — validate_dsl_syntax/validate_spec_content fuzzing + .2 container complete"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.1.3` (define HandlerIR)
- next_action: PNT — execute MEDIUM-IMPACT.1.3 (HandlerIR definition) or next eligible leaf.
- Completed this session (10 commits): session bootstrap + restructure, .3.3 cross-check,
  .3.4 blocked analysis, .1.1 SpecEntry inventory, .2.1→.2.4 validation fuzzing (container complete),
  .1.2 HandlerVariantEmitter extraction, COMPAT-ALIAS-RETIREMENT completed, mdBook sync.
- MEDIUM-IMPACT.3.4 blocked: AND handler architecture limitation.
- regression baseline: 1005 PASS (phase0). Fuzz harness: 5/5 PASS. HandlerVariantEmitter: OK.
- in_flight_uncommitted: MEDIUM-IMPACT.1.2 completion (pending commit).
- blockers: MEDIUM-IMPACT.3.4.

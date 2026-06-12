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
- latest_commit: `bee195c` — "Docs: enrich MEDIUM-IMPACT.3.4 with detailed AND-handler root cause analysis + HandlerIR implications"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.1.4` (backend emitter interface)
- next_action: PNT — execute MEDIUM-IMPACT.1.4 (backend emitter interface with dispatch table).
- MEDIUM-IMPACT.3.4 blocked: AND handler architecture limitation (E-block missing from AND_SINGLE_ACODE).
  Three fix approaches identified; unblock condition: choose approach, split into child leaves.
- Completed leaves: .1.1, .1.2 (HandlerVariantEmitter extraction), .1.3 (HandlerIR),
  .2.1→.2.4 (fuzzing container done), .3.1, .3.2, .3.3 (cross-check), .3.4 (blocked analysis).
  Pending: .1.4, .1.5, .3.4 (blocked), .3.5, .3.6.
- HandlerIR: 10 variant kinds, builders→IR + emitter→Perl, SpecEntry dead code removed (452 lines).
- regression baseline: 1005 PASS (phase0). All 19 specs compile through HandlerIR pipeline.
- knowledge: language-agnostic-backend-vision.md captures Rust/Julia/Dart backend direction.
- in_flight_uncommitted: none
- blockers: MEDIUM-IMPACT.3.4.

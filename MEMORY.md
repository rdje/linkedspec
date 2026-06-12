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
- latest_commit: `ece03ca` — "Docs: MEDIUM-IMPACT.3.4.3 — cross-check re-run + MIXED_ACTIONS root cause analysis"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.3.5` (claim parity + wire spec.spec as primary)
- next_action: Implement .3.5 — wire spec.spec-generated parser as primary parse path in Compiler.pm, with BootstrapSpec::Core as fallback.
- .3.4.4 completed: Four coordinated changes resolve MIXED_ACTIONS. (1) RuleIR: AND I-blocks → and_icode_entries (not acode_entries), avoids acode_count increment → no MIXED_ACTIONS. (2) EmitContext: processes and_icode_entries into and_icode via rewriter. (3) SpecEntry: simplified, uses and_icode from emit_ctx, passes REs+and_icode to AND_BCODE. (4) HandlerVariantEmitter: AND_SINGLE_ACODE prepends assignment to edge acodes so results flow into @collect. Cross-check: 2/20 exact match, significant improvement (ds_vhistory 11/12, simenv 18/17). 20/20 specs compile OK.
- Completed leaves: .1.1→.1.5, .2.1→.2.4, .3.1, .3.2, .3.3, .3.4.1, .3.4.2, .3.4.3, .3.4.4.
  Pending: .3.5, .3.6.
- regression baseline: 1005 PASS (phase0). Cross-check baseline: 2/20 match, significant improvement across all specs.
- in_flight_uncommitted: .3.4.4 code changes (RuleIR.pm, EmitContext.pm, SpecEntry.pm, HandlerVariantEmitter.pm) + task tree update
- blockers: none
- in_flight_uncommitted: MEDIUM-IMPACT.md updated with .3.4.3 assessment + .3.4.4 leaf
- blockers: none

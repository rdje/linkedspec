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
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.3.4.4` (resolve MIXED_ACTIONS conflict)
- next_action: Implement .3.4.4 — avoid MIXED_ACTIONS by routing AND I-blocks as a separate field (not acode_entries), extend AND_BCODE handler with and_icode support (IMATCH bridge + return→assignment + push to @collect after regex match, then normal bcode dispatch).
- .3.4.3 completed: Cross-check re-run confirms AND fix correctly makes edges fire, but exposed MIXED_ACTIONS conflict. RuleIR routes AND I-block to acode_entries (acode_count=1), edge -> body_element is bcode (bcode_count=1). RuleIR variant detection returns MIXED_ACTIONS (invalid) → handler falls back to _default → empty @collect. Cross-check: 1/20 match (was 10/20 before fix).
- MIXED_ACTIONS root cause: RuleIR line 34 returns 'MIXED_ACTIONS' when both acode_count && bcode_count. Execution shape is 'invalid_mixed_actions'. Handler selection falls back to _default.
- Path forward (.3.4.4): RuleIR emits AND I-block as and_icode field (not acode_entry). SpecEntry passes to AND_BCODE variant. AND_BCODE emitter extended: IMATCH bridge + return→assignment + push to @collect after regex match, then normal bcode dispatch. No acode_count increment → no MIXED_ACTIONS → AND_BCODE handler selected.
- Completed leaves: .1.1→.1.5, .2.1→.2.4, .3.1, .3.2, .3.3, .3.4.1, .3.4.2, .3.4.3.
  Pending: .3.4.4, .3.5, .3.6.
- regression baseline: 1005 PASS (phase0). Cross-check baseline: 1/20 match (was 10/20 pre-AND-fix).
- in_flight_uncommitted: MEDIUM-IMPACT.md updated with .3.4.3 assessment + .3.4.4 leaf
- blockers: none

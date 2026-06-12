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
- latest_commit: `1a16396` — "Docs: MEDIUM-IMPACT.3.4 — honest assessment after deep investigation"
- active_work_unit: `MEDIUM-IMPACT` → frontier leaf: `MEDIUM-IMPACT.3.4.2` (implement AND handler fix)
- next_action: Re-run cross-check harness (MEDIUM-IMPACT.3.4.3) to confirm AND fix results,
  then assess body_element:* over-consumption (issue b).
- MEDIUM-IMPACT.3.4 investigation: Two compounding issues in spec.spec rule_paragraph:AND:
  (a) I-block return(hash(...)) runs BEFORE regex match → handler exits, edges never run.
  (b) body_element:* is REP → if edges did run, one call consumes ALL body elements,
      starving subsequent rule_paragraph calls. Fix (a) via approach (1); (b) may
      resolve naturally if body_element:* stops at non-matching rule headers.
  Three approaches attempted; approach (1) chosen: modify RuleIR.pm line 207 to route
  AND ICODE→acode_entries (like REP/OR), update _emit_and_single_acode_handler with
  return→assignment + IMATCH←LMATCH bridge. Approach (3) spec.spec grammar restructure
  attempted but reverted (body_element over-consumption prevented multi-rule parsing).
- .3.4 split into: .3.4.1 design (done), .3.4.2 implement (in_progress), .3.4.3 re-cross-check.
- Completed leaves: .1.1→.1.5 (.1 container done), .2.1→.2.4 (.2 container done),
  .3.1, .3.2, .3.3, .3.4.1.
  Pending: .3.4.2, .3.4.3, .3.5, .3.6.
- HandlerIR: 10 variant kinds; Backend dispatch: %BACKEND_EMITTERS = (perl, json).
- regression baseline: 1005 PASS (phase0). Cross-check baseline: 10/20 match, 10/20 mismatch.
- in_flight_uncommitted: none (all code reverted to 1d99a32 baseline, only docs changed)
- blockers: none (approach chosen, implementation in progress)

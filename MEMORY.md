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
- latest_commit: `e7416b3` — "RUST-EDGE-SEMANTICS.2 — compiler: build regex_patterns from child rule dependency refs"
- active_work_unit: `RUST-EDGE-SEMANTICS`  →  frontier leaf: `.3` (pending — add regression tests for edge dispatch)
- next_action: PNT `.3` — add regression tests: (a) rule with only `->` edges dispatches correctly, (b) rule with mixed `/regex/` and `->` edges, (c) self-recursive rule with `-> same_rule[N]`, (d) `-> A | B { code }` grouped targets
- in_flight_uncommitted: RUST-EDGE-SEMANTICS.2 complete (two-phase compiler rewrite, 159/159 PASS, 8 new tests); live docs being updated for commit
- blockers: none

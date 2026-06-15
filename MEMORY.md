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
- latest_commit: `f058d6b` — "RUST-EDGE-SEMANTICS.1 — hash-fix: post-commit MEMORY.md + commit-log update"
- active_work_unit: `RUST-EDGE-SEMANTICS`  →  frontier leaf: `.2` (pending — rewrite compiler.rs to build regex patterns from child rule dependency refs)
- next_action: PNT `.2` — rewrite compiler.rs: build regex_patterns from child rule dependency refs (mirroring Perl's build_dependency_regex_map), recompute AcodeEntry.regex_idx to align with alternation order
- in_flight_uncommitted: RUST-EDGE-SEMANTICS.1 audit complete (full code-path inventory + Perl pipeline trace + 5-row delta table documented in task tree); live docs being updated for commit
- blockers: none

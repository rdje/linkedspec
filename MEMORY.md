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
- latest_commit: `206a79e` — "MDBOOK-FORMAT-CORRECTNESS.1 — fix lifecycle-nesting bug in runtime-semantics §5.2/§5.3" (the `.2` commit lands on top; ahead of origin: ~127; push at 300)
- active_work_unit: `MDBOOK-FORMAT-CORRECTNESS` → frontier leaf: `MDBOOK-FORMAT-CORRECTNESS.3` (pending — finalize/close). Other active: `RUST-PARITY` (frontier `RUST-PARITY.5.1`, the retv fix — Rust code).
- next_action: do `MDBOOK-FORMAT-CORRECTNESS.3` — finalize: confirm `mdbook build` exit 0, add a DEVELOPMENT_NOTES note (the lifecycle-blocks-are-siblings format rule + the format-vs-framing audit distinction) + a CHANGES finalize entry, move the tree to Completed in `docs/TASK_TREE.md`. After this tree, `RUST-PARITY.5.1` (recommend a fresh session for that engine surgery).
- done: `MDBOOK-FORMAT-CORRECTNESS.2` — full-book format sweep (Explore audit over all 41 pages, 4 violation classes). Found + fixed 2 MORE lifecycle-nesting instances in `appendix/formal-grammar.md` (§8.1 + §12); zero other violation classes; whole-book re-scan clean. `mdbook build` exit 0. (`.1` fixed runtime-semantics §5.2/§5.3 earlier.)
- in_flight_uncommitted: `.2` (formal-grammar §8.1/§8.2/§12 fixes + task-file/CHANGES) staged for the `MDBOOK-FORMAT-CORRECTNESS.2` commit (committing now).
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

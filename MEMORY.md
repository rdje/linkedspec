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
- latest_commit: `93687d0` — "RUST-PARITY.5 — split into .5.1–.5.5" (the `MDBOOK-FORMAT-CORRECTNESS.1` commit lands on top; ahead of origin: ~126; push at 300)
- active_work_unit: `MDBOOK-FORMAT-CORRECTNESS` → frontier leaf: `MDBOOK-FORMAT-CORRECTNESS.2` (pending — full-book `.spec` format-validity sweep). New tree (a user caught a malformed lifecycle-in-edge-block example in `appendix/runtime-semantics.md`). Other active: `RUST-PARITY` (frontier `RUST-PARITY.5.1`, the retv fix — Rust code).
- next_action: do `MDBOOK-FORMAT-CORRECTNESS.2` — sweep every `.spec` code fence in the book against the bootstrap grammar + shipped specs (lifecycle markers `I/LS/LE/E/EX/IT/LX` must be top-level paragraph members, siblings of `->`/`=>` edges, NOT nested in an edge `{…}`; check edge/block/header/marker/helper forms); fix any structural errors or confirm clean. Then `.3` finalize/close. After this tree, `RUST-PARITY.5.1` (recommend a fresh session for that engine surgery).
- done: `MDBOOK-FORMAT-CORRECTNESS.1` — fixed `appendix/runtime-semantics.md` §5.2/§5.3 (lifecycle blocks were wrongly nested inside `-> Bar {…}`; now top-level siblings of the edge), grounded in `tablegrep.spec`/`value-container`. `mdbook build` exit 0. (Earlier this session: closed `MDBOOK-VARIANT-AGNOSTIC` + `SPEC-SPEC-SELFHOST`; split `RUST-PARITY.5`.)
- in_flight_uncommitted: `.1` (new tree file + TASK_TREE register + §5.2/§5.3 fix + task-file/CHANGES) staged for the `MDBOOK-FORMAT-CORRECTNESS.1` commit (committing now).
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

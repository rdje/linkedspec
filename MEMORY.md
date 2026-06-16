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
- latest_commit: `1832c7e` — "REPO-HYGIENE.1 hash-sync" (the `MDBOOK-VARIANT-AGNOSTIC.6` commit lands on top of this; ahead of origin: ~118; push at 300)
- active_work_unit: `MDBOOK-VARIANT-AGNOSTIC` → frontier leaf: `MDBOOK-VARIANT-AGNOSTIC.7` (pending — final build + cross-chapter consistency + live-docs sync; closes the tree)
- next_action: do `MDBOOK-VARIANT-AGNOSTIC.7` (FINAL leaf) — rebuild the book and run a whole-book cross-chapter consistency sweep: every chapter now uses the `.spec`=universal-contract / Perl=reference-backend frame, so verify no chapter still presents Perl as the only backend and that the per-page banners + the shared corpus driver-frame read consistently; confirm `mdbook build` exit 0; then sync ROADMAP_V2.md/CHANGES.md/MEMORY.md and move the tree to Completed in `docs/TASK_TREE.md`. Other live frontiers: `SPEC-SPEC-SELFHOST.4`, `RUST-PARITY.5` (retv BLOCKER).
- done: `MDBOOK-VARIANT-AGNOSTIC.6` — reframed appendix (3) + 6 corpus walkthroughs + development CI page (2 confirmed CLEAN). Shared backend-neutral corpus driver frame; `pos($input)`→cursor + cursor-terminology note in `runtime-semantics`; `hashref AST`→`structured AST` in `backend-handoff`; Perl-reference banners on the `plugin/` migration narrative + `pplugin`. **Caught + fixed `ebnf` walkthrough raw-Perl drift** vs the migrated shipped `specs/ebnf.spec:187` helper-DSL rule. `git diff --check` clean; `mdbook build` exit 0; self-check exit 0.
- in_flight_uncommitted: `.6` book edits + task-file/TASK_TREE-index/live-doc updates staged for the `MDBOOK-VARIANT-AGNOSTIC.6` commit (committing now).
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

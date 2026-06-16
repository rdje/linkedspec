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
- latest_commit: `4ea4c89` — "Docs: push policy raised to every 300 commits (was 200)"   (ahead of origin: ~105; push at 300)
- active_work_unit: `MDBOOK-VARIANT-AGNOSTIC` → frontier leaf: `MDBOOK-VARIANT-AGNOSTIC.1` (pending — variant-agnostic audit)
- next_action: complete `MDBOOK-VARIANT-AGNOSTIC.1` — full per-page audit of `docs/linkedspec-book/src/` for Perl-specific leakage vs the variant-agnostic mandate (Perl = reference; Rust/Julia/Dart variants), with a per-file remediation list; then `.2` overview chapters. Other live frontiers: `SPEC-SPEC-SELFHOST.4` (docs sync+finalize), `RUST-PARITY.5` (retv-propagation BLOCKER + match/entry split + missing helpers).
- done: `TASK-TREE-INDEX-SYNC.1` — reconciled the stale `docs/TASK_TREE.md` frontier index (`SPEC-SPEC-SELFHOST` `.2`→`.4`, `RUST-PARITY` `.1`→`.5`); one-leaf owning tree created+completed, registered in the Completed table.
- in_flight_uncommitted: none.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

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
- latest_commit: `92d43ff` — "MDBOOK-VARIANT-AGNOSTIC.1 — complete variant-agnostic audit of the mdBook"   (ahead of origin: ~108; push at 300)
- active_work_unit: `MDBOOK-VARIANT-AGNOSTIC` → frontier leaf: `MDBOOK-VARIANT-AGNOSTIC.2` (pending — remediate overview chapters)
- next_action: do `MDBOOK-VARIANT-AGNOSTIC.2` — reframe overview chapters (what-is-linkedspec, design-rationale; verify documentation-layers/project-status) so the book treats the `.spec` file as the ONE universal contract and variants (Perl reference, Rust/Julia/Dart) as mere execution platforms. Per-file remediation map is in the task file's "## Audit Findings (.1)". Other live frontiers: `SPEC-SPEC-SELFHOST.4` (docs sync+finalize), `RUST-PARITY.5` (retv BLOCKER + match/entry split + missing helpers).
- done: `MDBOOK-VARIANT-AGNOSTIC.1` — variant-agnostic audit of all 41 book pages; 3-way classification (CLEAN/REMEDIATE/LABEL) + per-leaf remediation map recorded in the task file. (Prior: `TASK-TREE-INDEX-SYNC.1` frontier-index reconcile.)
- in_flight_uncommitted: none.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

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
- latest_commit: `013f212` — "MDBOOK-VARIANT-AGNOSTIC.3 — reframe user-model chapters as variant-agnostic"   (ahead of origin: ~113; push at 300; .4 hash pending REPO-HYGIENE sync)
- active_work_unit: `MDBOOK-VARIANT-AGNOSTIC` → frontier leaf: `MDBOOK-VARIANT-AGNOSTIC.5` (pending — remediate DSL + compiler/architecture chapters)
- next_action: do `MDBOOK-VARIANT-AGNOSTIC.5` — per `.1` audit, the `dsl/*` pages are mostly CLEAN (helper-contract-catalog is the gold standard); the real work is the **compiler chapters** (`pipeline-overview`, `compiled-state-model`, `generated-handlers-and-dispatch`, `diagnostics` — Perl module names/line counts, `LinkedRE::or`, `JSON::PP`, `pos($$STRING)`, `$BACKEND`) and the **`architecture/owner-tree.md` LABEL** (~500 lines Perl owner narrative → reference-impl banner). Re-grep each page for genuine Perl-API, don't trust `.1` CLEAN tags blindly. Other live frontiers: `SPEC-SPEC-SELFHOST.4`, `RUST-PARITY.5` (retv BLOCKER).
- done: `MDBOOK-VARIANT-AGNOSTIC.4` — reframed 4 public-api chapters (Option A per-chapter frames; resolved the Open Question): entry points/options/descriptor-shape/trace-model = backend-neutral contracts, concrete signatures/encodings/constants = Perl reference; `plugin-registry` deprecated/Perl-reference banner. `mdbook build` exit 0. (Prior: `.3` user-model reframe.)
- in_flight_uncommitted: none.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

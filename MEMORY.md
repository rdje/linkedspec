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
- latest_commit: `31e8a57` — "REPO-HYGIENE.1 hash-sync" (the `SPEC-SPEC-SELFHOST.4` commit lands on top of this; ahead of origin: ~122; push at 300)
- active_work_unit: none — `SPEC-SPEC-SELFHOST` COMPLETE (4/4 leaves; moved to Completed) and `MDBOOK-VARIANT-AGNOSTIC` COMPLETE (7/7) earlier this session. Only `RUST-PARITY` remains active, frontier `RUST-PARITY.5` — BLOCKED on retv. `SPEC-FORMAT-TERSE` is `proposed` (not PNT-eligible; gated by the phase0-hang blocker).
- next_action: PNT — evaluate `RUST-PARITY.5` (read `docs/tasks/RUST-PARITY.md`): if its `retv` blocker is still unresolved, the only remaining active frontier is blocked → PNT has no eligible leaf (autonomous-loop exhaustion). At exhaustion, surface options to the user: (a) own + fix the unowned phase0-hang blocker via new tree `RTLUTILS-REGEX-HANG` (also gates `SPEC-FORMAT-TERSE`), (b) unblock `RUST-PARITY.5`, (c) activate `SPEC-FORMAT-TERSE`. RUST-PARITY work is Rust code (cargo; phase0 only with a hard timeout).
- done: `SPEC-SPEC-SELFHOST.4` — docs-sync finalization for the `specs/spec.spec` rewrite (`4c667b7`); tree CLOSED. DEVELOPMENT_NOTES status note (now full 20/20 cross-check parity, was 2/20), mdBook `pipeline-overview` dual-path parity note, extension-surface policy confirmed preserved in the new spec.spec header. (Earlier this session: `MDBOOK-VARIANT-AGNOSTIC` `.6`/`.7` closed.)
- in_flight_uncommitted: `.4` docs/task-file/TASK_TREE/live-doc updates staged for the `SPEC-SPEC-SELFHOST.4` commit (committing now).
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

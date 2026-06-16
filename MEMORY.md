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
- latest_commit: `c8a5c24` — "REPO-HYGIENE.1 hash-sync" (the `RUST-PARITY.5` split commit lands on top of this; ahead of origin: ~124; push at 300)
- active_work_unit: `RUST-PARITY` → frontier leaf: `RUST-PARITY.5.1` (pending — the child-return/`retv` propagation BLOCKER). NOTE: `RUST-PARITY.5` was NOT blocked — its formal Blockers section is "None"; `retv` is the defect `.5` *fixes*. `.5` was split (PNT rule 5, too broad) into `.5.1`–`.5.5`. (`MDBOOK-VARIANT-AGNOSTIC` + `SPEC-SPEC-SELFHOST` both CLOSED this session.)
- next_action: implement `RUST-PARITY.5.1` — fix child-return (`retv`) propagation in `rust/` (engine.rs `execute_rule` + runtime.rs; complete or remove the dead `set_retv`) so `scalar(retv)` in an `LE` block resolves to the child's `return(expr)` value, not undef. Spec = the 3-agent audit in `docs/tasks/RUST-PARITY.md` Decisions. Rust baseline = **182 tests green**; gate with `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy`. **Recommend a FRESH SESSION** for this correctness-critical engine surgery (repo is handoff-ready). Then `.5.2`–`.5.5`.
- done: split `RUST-PARITY.5` into `.5.1`–`.5.5` (too broad; PNT rule 5); confirmed Rust baseline green (182 tests, 0 failed) before splitting. Earlier this session: closed `MDBOOK-VARIANT-AGNOSTIC` (`.6`/`.7`) and `SPEC-SPEC-SELFHOST` (`.4`).
- in_flight_uncommitted: the `RUST-PARITY.5` split (task-file + live-doc updates) staged for the split commit (committing now).
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

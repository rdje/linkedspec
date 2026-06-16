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
- latest_commit: `RUST-PARITY.6 — strict_syntax validation mode in the Rust variant` (validation.rs + 4 tests + knowledge card; hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~142; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.7` (pending). `.1`–`.6` all done; `.7`–`.9` remain.
- next_action: `RUST-PARITY.7` — expand the Rust runtime test corpus to the 20 shipped specs (audit Gap 7): only ~4 specs are runtime-exercised in Rust (the rest are compile-only). Build a Perl↔Rust output oracle: run each shipped `specs/*.spec` through the Perl reference and the Rust engine on the same input and assert identical output (cross-variant-output-parity doctrine). Add corpus files under `rust/linkedspec-runtime/tests/corpus/` + a regression guard. Gate `cargo test --manifest-path rust/Cargo.toml` + clippy (zero NEW vs baseline: runtime 13, core validation.rs 4). Baseline now 237. NOTE: phase0 hang is Perl-side (RTLUtils) — if the oracle drives Perl over corpus inputs, guard with a hard timeout / skip the RTLUtils-touching path.
- done: `RUST-PARITY.6` — strict_syntax validation mode (audit Gap 4). `validate_with_options(spec, strict_syntax: bool)` in `rust/linkedspec-core/src/validation.rs`; `validate(spec)` now a non-strict wrapper (all call sites unchanged). Strict adds `check_unused_rules` (`unused = defined − used`) → hard error, parity with Perl `Validation.pm validate_dsl_syntax(strict_syntax=>1)`, verified empirically (top rule NOT exempt; undefined reported first). Undefined refs already fatal here every mode (`check_edge_targets`, runs first) — a pre-existing default-stricter-than-Perl divergence left as-is; strict's only new behavior is the unused-rule rejection. 4 new tests; `cargo test` 237/237; clippy core validation.rs 4 = baseline 4, runtime 13 = baseline 13. No book change (strict contract already documented in `compiler/pipeline-overview.md`; book sync `.9`). Card `docs/knowledge/rust-strict-syntax-validation.md`.
- in_flight_uncommitted: none after commit. Repo handoff-ready; next leaf `RUST-PARITY.7`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). Perl-side only — does NOT gate the Rust `cargo test` work. `perl/RTLUtils.pm` last touched e6e8a96. Run phase0 only with a hard timeout until fixed; also gates `SPEC-FORMAT-TERSE` (proposed).

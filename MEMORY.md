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
- latest_commit: `5fd7b8c` — "MDBOOK-FORMAT-CORRECTNESS.3 — finalize; close the format-correctness tree"   (ahead of origin: ~129; push at 300)
- active_work_unit: none — `MDBOOK-FORMAT-CORRECTNESS` COMPLETE (3/3; moved to Completed). This session closed THREE trees (`MDBOOK-VARIANT-AGNOSTIC`, `SPEC-SPEC-SELFHOST`, `MDBOOK-FORMAT-CORRECTNESS`) and split `RUST-PARITY.5`. Only `RUST-PARITY` remains active, frontier `RUST-PARITY.5.1` (retv fix — Rust engine code).
- next_action: `RUST-PARITY.5.1` — fix child-return (`retv`) propagation in `rust/` (engine.rs `execute_rule` + runtime.rs; complete or remove the dead `set_retv`) so `scalar(retv)` in an `LE` block resolves to the child's `return(expr)` value. Spec = the 3-agent audit in `docs/tasks/RUST-PARITY.md` Decisions. Rust baseline = 182 tests green; gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy`. **RECOMMEND A FRESH SESSION** for this correctness-critical engine surgery (repo handoff-ready).
- done: `MDBOOK-FORMAT-CORRECTNESS.3` — closed the format-correctness tree (DEVELOPMENT_NOTES format rule + 2 lessons; CHANGES finalize). 3 malformed `.spec` examples fixed total (`runtime-semantics` §5.2/§5.3 via `.1`; `formal-grammar` §8.1/§12 via `.2`).
- in_flight_uncommitted: none (`MDBOOK-FORMAT-CORRECTNESS.3` committed `5fd7b8c`, tree closed; this hash-sync bumps the resume pointer). Repo handoff-ready; next leaf `RUST-PARITY.5.1`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

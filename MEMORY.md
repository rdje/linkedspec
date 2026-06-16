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
- latest_commit: `7549f79` — "RUST-PARITY.5.1 — fix child-return (retv) propagation in the Rust engine"   (ahead of origin: ~131; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.5.2` (pending). `.5.1` done; `.5.2`–`.5.5` remain under `.5`, then `.6`–`.9`.
- next_action: `RUST-PARITY.5.2` — separate `match_*` from `entry_*` in `rust/linkedspec-runtime/src/engine.rs` (lines ~187: the match block sets `entry_groups` AND `match_groups`/`*_named` to the same regex groups, so nested-match reads via `match_*` wrongly get the entry match). Spec = 3-agent audit in `docs/tasks/RUST-PARITY.md` Decisions. Baseline now 186 tests; gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy` (clippy: ignore pre-existing vendored pgen/rgx-core warnings + the `len_zero` at integration_test.rs:199; goal = no NEW linkedspec-runtime warnings).
- done: `RUST-PARITY.5.1` — retv-propagation BLOCKER fixed. `execute_rule` now returns the rule's own value via a per-invocation save/restore channel in `RuntimeContext`; `->`(acode) + `=>`(bcode) dispatch call `ctx.set_retv(child_retv)`; `return(...)` feeds the channel while still pushing the accumulator (baseline contract intact); dead `set_retv` wired in; latent `call(child)` rule-name-resolution bug fixed (enables `assign(s(retv), call(child))`). 4 new integration tests (acode/OR, blind-call/AND, REP, `call`). 186/186 green; no new clippy warnings. No book change (contract already specified retv; Rust now conforms — book sync is `.9`).
- in_flight_uncommitted: none. Repo handoff-ready; next leaf `RUST-PARITY.5.2`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

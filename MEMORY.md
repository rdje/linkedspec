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
- latest_commit: `RUST-PARITY.5.2 — separate entry_* from match_* in the Rust engine` (hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~132; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.5.3` (pending). `.5.1`/`.5.2` done; `.5.3`–`.5.5` remain under `.5`, then `.6`–`.9`.
- next_action: `RUST-PARITY.5.3` — char-based (not byte) indexing for slicing + cursor line/col, and fix hardcoded `entry/match_start_pos` (currently `0.0`) in `rust/linkedspec-runtime/src/engine.rs` (`substr`/`input_slice`/`capture_slice`/`capture_from`). Spec = 3-agent audit in `docs/tasks/RUST-PARITY.md` Decisions. Baseline now 189 tests; gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy -p linkedspec-runtime --tests` (clippy: ignore pre-existing vendored pgen/rgx-core warnings + the `len_zero` at integration_test.rs:199; goal = no NEW linkedspec-runtime warnings — diff touched-file warning set vs a stashed baseline).
- done: `RUST-PARITY.5.2` — separated `entry_*` from `match_*`. `execute_rule` emulates Perl's per-handler `IMATCH`/`LMATCH` lexicals via a `SavedMatchState` save/restore: entry match = the dispatcher's local match (`$info = $minfo`, `MethodLowering.pm:332`); the rule's own match updates only the local registers; entry seeded from the first own match only for the dispatcher-less top rule; both registers restore on exit. 3 new tests (`match_5_2_*`). 189/189 green; no new clippy warnings. Knowledge card `docs/knowledge/rust-entry-match-separation.md`. No book change (contract already documents `entry_*`/`match_*`; Rust now conforms — book sync is `.9`).
- in_flight_uncommitted: none. Repo handoff-ready; next leaf `RUST-PARITY.5.3`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

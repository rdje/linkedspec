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
- latest_commit: `RUST-PARITY.5.5 — split into family sub-leaves (.5.5.1–.5.5.4)` (tree-structuring, no code; hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~135; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.5.5.1` (pending). `.5.1`–`.5.4` done; `.5.5` split into `.5.5.1`–`.5.5.4`; then `.6`–`.9`.
- next_action: `RUST-PARITY.5.5.1` — add the 8 named-group readers in `rust/linkedspec-runtime/src/engine.rs` `call_helper`: `entry_named(name)`→`ctx.entry_named.get` (string), `entry_has(name)`→`contains_key` (bool), `entry_map()`/`entry_named_map()`→`ctx.entry_named` as a Hash; same 4 for `match_*` reading `ctx.match_named`. Spec = `docs/linkedspec-book/src/appendix/helper-contract-catalog.md` §entry_named/§match_*. The `entry_named`/`match_named` HashMaps already exist + populate from `m.named` and save/restore in `SavedMatchState`. Per-family tests; baseline now 198; gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy -p linkedspec-runtime --tests` (ignore vendored pgen/rgx-core warns + `len_zero` at integration_test.rs:199; goal = no NEW linkedspec-runtime warnings — diff vs stashed baseline). NOTE the alias-policy Open Question parked under `.5.5.2`.
- done: `RUST-PARITY.5.5` split (PNT rule 5 — too broad: ~28 helpers across ~7 families). Audited engine.rs (only `drop_front`/`drop_back`/`array_copy`/`flat_array` of the family exist). Sub-leaves: `.5.5.1` named-group readers, `.5.5.2` input-boundary + real compat aliases, `.5.5.3` mark-based capture family, `.5.5.4` anonymous capture-slice variants. Parked alias-retirement Open Question (book says "retired", roadmap says "remain compat") for `.5.5.2`. Doc-only (tree structuring).
- in_flight_uncommitted: none. Repo handoff-ready; next leaf `RUST-PARITY.5.5.1`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

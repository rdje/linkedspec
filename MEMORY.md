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
- latest_commit: `RUST-PARITY.5.5.1 — named-group reader helpers in the Rust engine` (engine.rs +184; hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~136; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.5.5.2` (pending). `.5.1`–`.5.4` + `.5.5.1` done; `.5.5.2`–`.5.5.4` remain, then `.6`–`.9`.
- next_action: `RUST-PARITY.5.5.2` — in `rust/linkedspec-runtime/src/engine.rs` `call_helper`: add input-boundary helpers `input_end_line`/`input_end_col` (char line/col at end-of-input) + the real compat aliases `tail`→`drop_front`, `drop_last`→`drop_back`, `flatten`→`flat` (add `flat` if absent). FIRST resolve the parked Open Question (book helper-contract-catalog says these are "retired aliases"; `ROADMAP_V2` says they "remain compatibility syntax"): check whether the **Perl reference** runtime still recognizes each and add only those it accepts. Spec = `docs/linkedspec-book/src/appendix/helper-contract-catalog.md` §7/§9 + §Compatibility-Aliases. Per-family tests; baseline now 204; gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy -p linkedspec-runtime --tests` (ignore vendored pgen/rgx-core warns + `len_zero` at integration_test.rs:199; goal = zero NEW linkedspec-runtime warnings vs stashed baseline = 13).
- done: `RUST-PARITY.5.5.1` — 8 named-group readers (`entry_named`/`entry_has`/`entry_map`/`entry_named_map` + the four `match_*`) added as `call_helper` arms reading the existing `ctx.entry_named`/`ctx.match_named` maps (populate at engine.rs:280/291, save/restore in `SavedMatchState`); retired `_named_map` forms implemented as combined-arm aliases; new free `named_map_to_hash` sorts keys so `entry_map`/`match_map` are deterministic. 6 tests (`helpers_5_5_1_*`, e2e via `(?P<name>…)`); `cargo test` 204/204; clippy zero new (13=13). No book change (catalog §8 conforms; book sync `.9`); no knowledge card (localized additive).
- in_flight_uncommitted: none. Repo handoff-ready; next leaf `RUST-PARITY.5.5.2`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

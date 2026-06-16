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
- latest_commit: `RUST-PARITY.5.4 — dedup shadowed arms + fix REP zero-progress guard in the Rust engine` (hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~134; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.5.5` (pending). `.5.1`–`.5.4` done; `.5.5` last under `.5`, then `.6`–`.9`.
- next_action: `RUST-PARITY.5.5` — implement the ~30 missing capture/mark/entry/match/input helpers from the `.1` inventory (`capture_*_from`, `capture_between`, `mark_copy`/`mark_input_start`/`mark_input_end`, `entry_named`/`entry_has`/`entry_map`/`entry_named_map`, `match_named`/`match_has`/`match_map`/`match_named_map`, `input_end_line`/`input_end_col`, anonymous `capture_*_until_cursor`/`capture_take_*` variants) plus the real Perl aliases `tail`/`drop_last`/`flatten` — in `rust/linkedspec-runtime/src/engine.rs` (`call_helper`). Do NOT add `array_values`/`return_imatch`/`return_im` (not real Perl helpers). See `.1` Inventory (Gap 5) in `docs/tasks/RUST-PARITY.md`. Use char offsets (`.5.3`) for any new positions, and the stored `entry/match_*_byte` spans + `entry_named`/`match_named`. Baseline now 198 tests; gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy -p linkedspec-runtime --tests` (clippy: ignore pre-existing vendored pgen/rgx-core warnings + the `len_zero` at integration_test.rs:199; goal = no NEW linkedspec-runtime warnings — diff touched-file warning set vs a stashed baseline).
- done: `RUST-PARITY.5.4` — dedup shadowed `call_helper` arms (`print`, `hash`/`h`, `hash_copy`) so the better later arms win (Hash-arg merge, `resolve_array_target`, consolidated `say|print|print_each`); cleared 3 `unreachable_patterns`. Fixed the REP zero-progress guard: snapshot `pos_before` per iteration, break on `ctx.pos == pos_before` (Perl `loop_end_pos == loop_start_pos`) instead of a `matches > 100` cap. 2 new tests. 198/198 green; clippy touched-file warnings 15 → 12. No card (localized). No book change (book sync is `.9`).
- in_flight_uncommitted: none. Repo handoff-ready; next leaf `RUST-PARITY.5.5`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).

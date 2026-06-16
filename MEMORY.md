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
- latest_commit: `RUST-PARITY.5.5.3 — mark-based capture family in the Rust engine` (engine.rs + 16 tests + book catalog §7 + knowledge card; hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~140; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.5.5.4` (pending). `.5.1`–`.5.4` + `.5.5.1`–`.5.5.3` done; `.5.5.4` remains, then `.6`–`.9`.
- next_action: `RUST-PARITY.5.5.4` — anonymous capture-slice variants (`capture_slice_until_cursor`(+`_len`), `capture_take_until_cursor`(+`_len`), `capture_take_len`, `capture_take_rest`(+`_len`)) operating on the anonymous `ctx.capture_start`/cursor per `Contracts.pm` ~368–656. **Also fix the existing anonymous `capture_slice`/`capture_slice_len` endpoint** (engine.rs ~1012): they read to `ctx.pos` (cursor) but the contract (and the now-corrected book catalog §7) is the **start of the current match** (`ctx.match_start_byte`) — `.5.5.3` corrected the catalog, leaving a tracked book↔Rust gap to close here. Char at the DSL boundary (`.5.3` `byte_to_char_offset`); multibyte tests; baseline now 223; gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy -p linkedspec-runtime --tests` (zero NEW vs baseline 13; ignore vendored pgen/rgx-core + `len_zero` at integration_test.rs:199).
- done: `RUST-PARITY.5.5.3` — mark-based capture family + `capture_from` parity fix (Open Question RESOLVED option (a), user-confirmed). `capture_from` now ends at `ctx.match_start_byte` (was `ctx.pos`); 15 new `call_helper` arms (`capture_*_from`/`_len_from`, `capture_between`/`_len_between`, `mark_input_start`/`mark_input_end`/`mark_copy` 2-arg) from authoritative `Contracts.pm` ~690–1047 + guarded `span_text`/`span_char_len`; `_take_*` advance the mark; text→slice, `_len_*`→char count; missing-mark/reversed→undef. Landed test `helpers_5_2_mark_and_capture_from` updated `"hello"`→`""`. **Book catalog §7 corrected** to the contract (user-requested). `cargo test` 223/223; clippy 13 = baseline 13; `mdbook build` exit 0. Knowledge card `docs/knowledge/rust-mark-based-capture-family.md`. Discovered (recorded): anon `capture_slice` endpoint gap (`.5.5.4`) + inventory-missing `mark_match_*`/`mark_entry_*`/`capture_take(mark)`/`capture_take_between(_len)` (follow-up leaf).
- in_flight_uncommitted: none after commit. Repo handoff-ready; next leaf `RUST-PARITY.5.5.4`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). Perl-side only — does NOT gate the Rust `cargo test` work. `perl/RTLUtils.pm` last touched e6e8a96. Run phase0 only with a hard timeout until fixed; also gates `SPEC-FORMAT-TERSE` (proposed).

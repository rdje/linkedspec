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
- latest_commit: `RUST-PARITY.5.5.4 — anonymous capture-slice family in the Rust engine` (engine.rs + 10 new tests + book catalog §7 entries + knowledge card; hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~141; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.6` (pending). `.1`–`.5` all done (`.5.5` + `.5` closed); `.6`–`.9` remain.
- next_action: `RUST-PARITY.6` — strict_syntax validation mode in the Rust variant (audit Gap 4): `rust/linkedspec-core/src/validation.rs` has 6 checks but no `strict_syntax` mode; the Perl reference `Validation.pm validate_dsl_syntax(..., strict_syntax => 1)` promotes reference warnings (unused/undefined rule refs) to hard errors. Add the mode + a regression test. Gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy -p linkedspec-runtime --tests` (zero NEW vs baseline 13; ignore vendored pgen/rgx-core + `len_zero` at integration_test.rs:199). Baseline now 233.
- done: `RUST-PARITY.5.5.4` — full **anonymous** capture-slice family + `capture_slice`/`capture_slice_len` endpoint fix to match-start (`ctx.match_start_byte`, was `ctx.pos`) — the anonymous analog of the `.5.5.3` `capture_from` fix, closing the book↔Rust gap `.5.5.3` handed off. 10 new `call_helper` arms on `ctx.capture_start` (Perl `$IPOS`) from `Contracts.pm` ~366–656, reusing `span_text`/`span_char_len`: `capture_slice_until_cursor`(+`_len`)→cursor; `capture_take`(+`_len`)→match-start; `capture_take_until_cursor`(+`_len`)→cursor; `capture_rest`(+`_len`)→end; `capture_take_rest`(+`_len`)→end. `_take_*` advance `capture_start` to the cursor (or end for `_rest`), only on a valid span; text→slice, `_len`→char count; reversed→undef. Folded in inventory-missing `capture_rest`/`_len`/`capture_take` for family completeness. Book catalog §7 gained the 10 entries + refined intro/`_take_` notes; 2 landed `helpers_5_2_capture_slice_*` tests updated (`"hello"`→`""`, `>0`→`0`). `cargo test` 233/233; clippy 13 = baseline 13; `mdbook build` 0. Card `docs/knowledge/rust-anonymous-capture-slice-family.md`. Closed `.5.5` + `.5`. STILL deferred (different family): `mark_match_*`/`mark_entry_*`/`capture_take(mark)`/`capture_take_between(_len)` follow-up leaf.
- in_flight_uncommitted: none after commit. Repo handoff-ready; next leaf `RUST-PARITY.6`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). Perl-side only — does NOT gate the Rust `cargo test` work. `perl/RTLUtils.pm` last touched e6e8a96. Run phase0 only with a hard timeout until fixed; also gates `SPEC-FORMAT-TERSE` (proposed).

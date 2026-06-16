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
- latest_commit: `ALIAS-RETIREMENT-DOC-SYNC.1 — retire array-edge alias claims across book + roadmaps` (docs-only; 16 lines / 3 files; hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~138; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree; `ALIAS-RETIREMENT-DOC-SYNC` completed) → frontier leaf `RUST-PARITY.5.5.3` (pending). `.5.1`–`.5.4` + `.5.5.1`–`.5.5.2` done; `.5.5.3`–`.5.5.4` remain, then `.6`–`.9`.
- next_action: `RUST-PARITY.5.5.3` — in `rust/linkedspec-runtime/src/engine.rs` `call_helper`: add the mark-based capture family per Helper Contract Catalog §7 (`docs/linkedspec-book/src/appendix/helper-contract-catalog.md`): `capture_len_from`, `capture_until_cursor_from`, `capture_take_until_cursor_from`, `capture_take_len_from`, `capture_rest_from`, `capture_take_rest_from`, `capture_between`, `capture_len_between`, and mark writers `mark_copy`/`mark_input_start`/`mark_input_end`. FIRST re-inventory which arms already exist (`capture_from`/`capture_rest_from`/`capture_until_cursor_from` partially present per Gap 5). Each reads named mark(s) (byte offsets in `ctx.marks`) and returns char-correct text/length via the `.5.3` `byte_to_char_offset`/`char_substr` boundary (no multibyte panic). Per-family tests with multibyte input; baseline now 207; gate `cargo test --manifest-path rust/Cargo.toml` + `cargo clippy -p linkedspec-runtime --tests` (zero NEW linkedspec-runtime warnings vs baseline 13; ignore vendored pgen/rgx-core + `len_zero` at integration_test.rs:199).
- done: `ALIAS-RETIREMENT-DOC-SYNC.1` (new 1-leaf tree, completed) — zero-drift doc correction following `RUST-PARITY.5.5.2`'s resolution + user direction that the variant-agnostic book/docs must be correct. The array-edge aliases `tail`/`drop_last`/`flatten`/`array_values` are retired (`COMPAT-ALIAS-RETIREMENT.1`; not recognized by the Perl reference, 0 spec uses, 0 `t/` locks, "Retired" in the book catalog). Corrected 16 stale "remains/preserving … compatibility alias/syntax" claims → retirement, preserving historical "Landed …" records: book `appendix/formal-grammar.md:357`; `ROADMAP_V2.md` (182 ×3 + 256/257/260/262); `ROADMAP.md` (735/736/993/994/997/999/1189/1190/1191/1242). Book now internally consistent with its own catalog. Capture / named-map aliases left out of scope (separate audit). `mdbook build` exit 0; gates pass; no code. (Prior slice `RUST-PARITY.5.5.2`: added `input_end_line`/`input_end_col`/`flat`; retired aliases NOT added to Rust — see git + RUST-PARITY tree.)
- in_flight_uncommitted: none. Repo handoff-ready; next leaf `RUST-PARITY.5.5.3`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). Perl-side only — does NOT gate the Rust `cargo test` work. `perl/RTLUtils.pm` last touched e6e8a96. Run phase0 only with a hard timeout until fixed; also gates `SPEC-FORMAT-TERSE` (proposed).

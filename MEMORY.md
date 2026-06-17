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
- latest_commit: `RUST-PARITY.7.5.1 — fix the header-line-regex → 0-regex parser bug in the Rust variant` (hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~146; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.7.5.3` (pending). `.1`–`.6` done; `.7.1` done; `.7.5.1` done; `.7.5` now has 3 children (`.7.5.1` done / `.7.5.2` scalaref / `.7.5.3` action-edge fluent); `.7.2`/`.7.3` blocked on `.7.5`; `.7.4`/`.8`/`.9` remain.
- next_action: `RUST-PARITY.7.5.3` — lower **action-edge fluent continuations** so tclite reproduces the Perl reference (`[]`→`["?tcl_script:",[["?command_subst:",[]]]]`, `""`→`["?tcl_script:",[["?double_quote:",[]]]]`). **Root cause confirmed:** tclite accumulates via `.push`/`.return(...)` fluent chains on ACTION edges (`-> command_subst .push`, `-> command_subst[1] .return(...)`), but the Rust parser attaches a `.method` chain only to a BLIND edge (`=>`, `parser.rs:443`); after a `->` edge the `.push`/`.return(...)` parses as a standalone `FluentChain` that the compiler discards (`compiler.rs:171`) → edges dispatch but never accumulate, so tclite still yields `[]` even after `.7.5.1`. **Scope:** parser (add `fluent_chain` to `ActionEdge`, parse it after a `->` edge), compiler (lower onto `AcodeEntry` like `BcodeEntry.fluent_chain`), engine (execute after dispatch in the acode loop, `engine.rs:340-351`). Then re-enable the tclite cases in `tools/gen_oracle_corpus.pl` → oracle green. Sibling `.7.5.2` (`expr.rs:299` `{…}` hash-literal) greens Lispish (uses `{ }` blocks, unaffected by `.7.5.3`). Gate `cargo test` + clippy zero-NEW (core 10 / runtime 13 / validation.rs 4). Evidence: `docs/knowledge/rust-perl-output-oracle.md`.
- done: `RUST-PARITY.7.5.1` — `parser.rs:86` `(\S*)`→`([^\s/]*)`; header-line regexes register, bracket-pairs repaired (open[0]/close[1]); 4 unit tests (3 parser + 1 compiler); `cargo test` 242/242; clippy zero-new. The oracle proved it necessary-but-not-sufficient for tclite → split off `.7.5.3`.
- in_flight_uncommitted: none after commit. Repo handoff-ready; next leaf `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input; subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs. Perl-side only — does NOT gate the Rust `cargo test` work; run phase0 with a hard timeout. (2) PRE-EXISTING `cargo clippy --tests` exit-101: `approx_constant` deny-error on `3.14` in untouched `expr.rs:687`/`types_test.rs:143` — predates RUST-PARITY; the clippy gate measures the warning multiset, not exit code. Both unowned, both need small dedicated hygiene leaves.

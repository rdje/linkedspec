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
- latest_commit: `RUST-PARITY.7.1 — Perl↔Rust output-oracle mechanism + green first proof` (hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~144; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.7.5` (pending). `.1`–`.6` done; `.7` split into `.7.1`(done)–`.7.5`; `.8`–`.9` remain.
- next_action: `RUST-PARITY.7.5` — fix the Rust engine output-parity gaps the `.7.1` oracle caught, to unblock the corpus (`.7.2`/`.7.3`). Two evidenced gaps: (a) **compiler** — a single-regex rule written `name : /re/` (single colon; incl. inline `name : /re/  I.return(...)`) compiles as **0-regex**, so `-> child[0]` edges never fire (root cause: tclite `[]`→Rust `[]` vs Perl `["?tcl_script:",[["?command_subst:",[]]]]`; Lispish→`exit_now(1)`; `::` single-regex rules are fine); (b) **parser** — `scalaref(retv, {content})` hashref-field accessor unparsed. Acceptance: tclite (`[]`,`""`) + Lispish (`(x y)`) reproduce the Perl reference modulo the one-level wrap, re-enable their cases in `tools/gen_oracle_corpus.pl`, fixture-runner green. **LIKELY SPLIT on pick** (PNT rule 5). Also evaluate the child-`return` accumulator leak (Rust pushes child return into parent accumulator; Perl→retv) + the group-indexing divergence. Gate `cargo test --manifest-path rust/Cargo.toml` + clippy zero-NEW. Baseline 238 / core 10 / runtime 13 / validation.rs 4. Evidence: `docs/knowledge/rust-perl-output-oracle.md`.
- done: `RUST-PARITY.7.1` — built the output oracle (Perl generator `tools/gen_oracle_corpus.pl`, `alarm`-guarded + `JSON::PP->canonical(1)`, emits `rust/linkedspec-runtime/tests/corpus/<case>/{input.spec,input.txt,expected.json}`; Rust runner `tests/corpus_oracle.rs` asserts `execute==[reference]`). Oracle DISPROVED the `.7`-split "matches modulo wrap" claim (→ `.7.5`); proven green on 2 controlled authored grammars. 238/238; clippy zero-new; self-check exit 0. Card `docs/knowledge/rust-perl-output-oracle.md`.
- in_flight_uncommitted: none after commit. Repo handoff-ready; next leaf `RUST-PARITY.7.5`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). Perl-side only — does NOT gate the Rust `cargo test` work. `perl/RTLUtils.pm` last touched e6e8a96. Run phase0 only with a hard timeout until fixed; also gates `SPEC-FORMAT-TERSE` (proposed).

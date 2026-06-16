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
- latest_commit: `RUST-PARITY.7.5 — split into parser-header-regex (.7.5.1) + scalaref-hash-literal (.7.5.2) sub-leaves` (tree structuring only; hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~145; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.7.5.1` (pending). `.1`–`.6` done; `.7.1` done; `.7.5` split into `.7.5.1`/`.7.5.2`; `.7.2`/`.7.3` blocked on `.7.5`; `.7.4`/`.8`/`.9` remain.
- next_action: `RUST-PARITY.7.5.1` — fix the header-line-regex → 0-regex parser bug (the shared root cause the `.7.1` oracle caught for tclite/Lispish/most specs). **Root cause confirmed:** `rust/linkedspec-core/src/parser.rs:86` — header regex `^(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)` uses `(\S*)` for the mode suffix, which eats a `/…/` regex on the header line (`parse_mode_suffix("/;/")`→Default, regex discarded). Bites `:` AND `::` rules with a header-line regex; tests dodge it via a separate body line. **Fix sketch** `(\S*)`→`([^\s/]*)`. **FOUNDATIONAL — verify carefully:** every rule header hits this; today an open/close pair (`command_subst`/`parenthesis`/`curlyb`) registers "1 regex" (group 3 eats the first), so confirm the fix preserves bracket-pair semantics (both now land in `rest`), full suite green, and re-enable the tclite cases in `tools/gen_oracle_corpus.pl` → oracle green. Then `.7.5.2` (`expr.rs:299` `{…}` hash-literal for Lispish `scalaref(retv,{content})`). Gate `cargo test` (baseline 238) + clippy zero-NEW (core 10 / runtime 13 / validation.rs 4). Evidence: `docs/knowledge/rust-perl-output-oracle.md`.
- done: `RUST-PARITY.7.1` (output oracle landed; caught the gap) + `.7.5` split (parser bug at `parser.rs:86`, scalaref at `expr.rs:299`, confirmed independent).
- in_flight_uncommitted: none after commit. Repo handoff-ready; next leaf `RUST-PARITY.7.5.1`. **Recommend a FRESH SESSION** to implement `.7.5.1` — foundational parser change after a long session.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). Perl-side only — does NOT gate the Rust `cargo test` work. `perl/RTLUtils.pm` last touched e6e8a96. Run phase0 only with a hard timeout until fixed; also gates `SPEC-FORMAT-TERSE` (proposed).

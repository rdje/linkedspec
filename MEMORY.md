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
- latest_commit: `RUST-PARITY.7 — split into Perl↔Rust output-oracle sub-leaves (.7.1–.7.4)` (tree structuring only; hash backfilled by next REPO-HYGIENE hash-sync; ahead of origin: ~143; push at 300)
- active_work_unit: `RUST-PARITY` (only active tree) → frontier leaf `RUST-PARITY.7.1` (pending). `.1`–`.6` done; `.7` split into `.7.1`–`.7.4`; `.8`–`.9` remain.
- next_action: `RUST-PARITY.7.1` — build the Perl↔Rust output-oracle mechanism + canonical comparison form + first proof. Design (fixed in `.7` split): a timeout-guarded Perl generator tool (`tools/`) emits canonical-JSON fixtures (`JSON::PP->canonical(1)`) into `rust/linkedspec-runtime/tests/corpus/`; a Rust fixture-runner integration test asserts `engine.execute(input)` matches — Perl-free `cargo test`. RECONCILE + document the output-shape mapping: Perl returns the top rule's value DIRECTLY (`tclite [] → ["?tcl_script:",[["?command_subst:",[]]]]`; `Lispish (x y) → ["x",["y"]]`) while Rust wraps it one level in the accumulator (`[<value>]`). Prove on tclite (`[]`,`""`) + Lispish (`(x y)`). Rust pipeline: `parse_spec → validate → compile → Engine::new → engine.execute(input) → serde_json::Value`. Gate `cargo test --manifest-path rust/Cargo.toml` + clippy zero-NEW (runtime 13, core 10 / validation.rs 4). Baseline 237. Guard the RTLUtils hang with a hard timeout (`alarm`) in the Perl generator.
- done: `RUST-PARITY.7` split — two-agent read-only investigation (Rust test infra + Perl reference output path) confirmed no oracle mechanism / canonical output form exists yet, an output-shape reconciliation is needed (Perl `X` vs Rust `[X]`), ~16/20 specs lack input fixtures, and the RTLUtils hang needs a timeout guard. Split into `.7.1` (mechanism+proof), `.7.2`/`.7.3` (corpus batches), `.7.4` (drift guard+finalize). Architecture = fixture generator (not live cross-process), realizing ADR 0006 §Phase 8.6 language-neutral corpus.
- in_flight_uncommitted: none after commit. Repo handoff-ready; next leaf `RUST-PARITY.7.1`.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). Perl-side only — does NOT gate the Rust `cargo test` work. `perl/RTLUtils.pm` last touched e6e8a96. Run phase0 only with a hard timeout until fixed; also gates `SPEC-FORMAT-TERSE` (proposed).

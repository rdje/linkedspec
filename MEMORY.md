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
- latest_commit: `DOC-DRIFT-SYNC.1 — sync ROADMAP.md to ROADMAP_V2.md (Phase 8/9 + Overall done)` (hash backfilled by next hash-sync; ahead of origin: ~147; push deferred, threshold ~300)
- active_work_unit: `DOC-DRIFT-SYNC` (doc-drift sync; user chose "fix doc drift first") → frontier leaf `DOC-DRIFT-SYNC.2` (pending). `.1` done (ROADMAP.md now agrees with ROADMAP_V2.md on Overall + Phases 0–9). `RUST-PARITY` stays active and resumes once DOC-DRIFT-SYNC closes.
- next_action: `DOC-DRIFT-SYNC.2` — in `docs/linkedspec-book/src/appendix/formal-grammar.md:68-69` swap the transposed `:&`/`:|` description cells: `:&` → "Ordered sequence (equivalent to `:AND`)."; `:|` → single-choice (`:OR{1}`). Verified vs `Core.pm:347-348` (`&`→AND, `|`→OR) + `user-model/rule-modes-and-parse-modes.md`. Gate: `scripts/check_memory_architecture.sh` + KM + `mdbook build`.
- queued_after: (a) NEW USER REQUEST (2026-06-17) — make the book fully + variant-agnostically document the ENTIRE `.spec` syntax + semantics with many examples so the next variant (Julia/Dart) needs no archaeology; add KM cards. Owns its own tree, after `.2`. (b) `RUST-PARITY.7.5.3` — action-edge fluent lowering (`-> Child .push`/`.return(...)`); compiler discards `.method` after a `->` edge (`compiler.rs:171`); greens tclite.
- in_flight_uncommitted: none after this commit (`.1` committed). Repo handoff-ready.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (UNOWNED — run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates this doc work.

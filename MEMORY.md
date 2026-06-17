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
- latest_commit: `DOC-DRIFT-SYNC.2 — fix transposed :& / :| rule-mode cells in formal-grammar.md` (hash backfilled by next hash-sync; ahead of origin: ~148; push deferred, threshold ~300)
- active_work_unit: NEXT = NEW USER REQUEST (2026-06-17) — make the book FULLY + variant-agnostically document the ENTIRE `.spec` syntax + semantics with many examples, so the next variant (Julia/Dart/…) needs no archaeology; add KM cards. Needs its own task tree (being set up). `DOC-DRIFT-SYNC` COMPLETE (`.1` ROADMAP.md Phase 8/9 + Overall `done`; `.2` formal-grammar.md `:&`/`:|`). `RUST-PARITY` remains active (frontier `.7.5.3`), resumes after the doc work.
- next_action: create the owning tree for the new request — audit the FULL `.spec` surface (rule labels `:`/`::`, all rule modes incl. `:&`/`:|`/`:+`/`:*`/`:?`/`:AND{N,M}`/`:OR{N,M}`, parse modes seek/consume, lifecycle markers I/LS/LE/E/EX/IT/LX, action `->` vs blind `=>` edges + `[N]` indexing, capture/mark families, the full helper-contract catalog, regex clusters/paragraph model) vs the book; fill every gap variant-agnostically with worked examples; add KM cards. Then implement leaf-by-leaf per COMMIT.md.
- queued_after: `RUST-PARITY.7.5.3` — action-edge fluent lowering (`-> Child .push`/`.return(...)`); compiler discards `.method` after a `->` edge (`compiler.rs:171`); greens tclite.
- in_flight_uncommitted: none after this commit (DOC-DRIFT-SYNC complete + moved to Completed in docs/TASK_TREE.md). Repo handoff-ready.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.

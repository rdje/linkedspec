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
- Durable facts/decisions live in `docs/decisions/` (index: `INDEX.md`); fact cards in
  `docs/knowledge/` (retrieval index `KNOWLEDGE_MAP.md`).
- Doctrine (non-negotiable): no change without an owning task-tree leaf first — see
  `docs/decisions/0001-task-tree-and-commit-doctrine.md`.
- Before committing, run `scripts/check_memory_architecture.sh` (git hooks + the local CI
  gate `tools/run_ci_local.sh` enforce it).

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `SPEC-FORMAT-TERSE.12.1` — reactivated and split hash-tree attached-block traversal before
  implementation; the accepted MVP surface is receiver-only `walk_leaves`, `map_leaves`, and `reduce_leaves`.
- prior_leaf: `STAGED-LINKED-PARSING.6` — metadata closeout: the exhausted staged linked parsing tree is now
  `done`, moved from Active to Completed, and no longer points PNT at already-closed `TOP-RULE-AS-NORMAL.3.2`.
- latest_commit: HEAD containing this pointer should be
  `SPEC-FORMAT-TERSE.12.1 - activate hash-tree traversal split`; parent before this slice is
  `961cc086 STAGED-LINKED-PARSING.6 - close staged linked parsing tree`.
  **Branch is over the documented 300 push threshold; still do NOT push mid-PNT unless explicitly instructed.**
- active_work_unit: `SPEC-FORMAT-TERSE.12` hash-tree traversal lane reactivated by user directive 2026-07-08;
  `.12.1` owns the committed split/spec contract before code.
- next_action: implement `SPEC-FORMAT-TERSE.12.2` Perl reference receiver attached-block traversal
  (`walk_leaves`, `map_leaves`, `reduce_leaves`) using the existing immediate trailing-block model.
- latest_bootstrap_read: 2026-07-08 read README, memory architecture, session bootstrap, task-tree index/active
  trees, relevant ADR/KM facts, mdBook source, core Perl/Rust implementation, shipped specs, tooling, and focused
  test harness inventory. Startup found isolated Rust README drift now owned by `RUST-README-DRIFT-SYNC`.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first. A future doctrine
  tracking update may be opened only after this repo is clean.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests (e.g. 102 pplugin lazy-load) fail on the stale checkout. Full phase0 needs the **10-min timeout** (`timeout:600000`), else it caps mid-run (exit 144/143). **Generated Perl handlers are NON-strict.** **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`). Current phase0 reaches **PASS `1..1026`**. oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL; **95** fixtures → **run in background**; `manifest.json` + drift guards). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Rust numbered capture helpers are captures-only (`0`=first capture); whole match = `entry_text()`/`match_text()`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Remaining open deferred/paused lanes outside current `.12`: `SPEC-FORMAT-TERSE`
  `.10`/`.13`, `DOCTRINE-ENFORCEMENT-ADOPT.3`, and `SPEC-LANG-REFERENCE`.
- blockers: none. in_flight_uncommitted: `.12.1` tracking/docs until committed; do not pivot unless the repo is
  handoff-ready.

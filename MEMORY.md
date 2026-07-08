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
- latest_completed_leaf: `ROADMAP-POST-12-DRIFT-SYNC.1` — docs-only long-roadmap count drift correction completed;
  `ROADMAP.md` now matches phase0 `1..1027` and the 96-fixture Rust interpreter oracle baseline.
- prior_leaf: `SPEC-FORMAT-TERSE.12.4` — final hash-tree traversal mdBook/Knowledge Map/live-doc no-drift closeout
  completed; `.12` is exhausted.
- latest_commit: HEAD containing this pointer should be
  `ROADMAP-POST-12-DRIFT-SYNC.1 - sync long roadmap baseline`; parent before this slice is
  `1d6783bb SPEC-FORMAT-TERSE.12.4 - close hash-tree traversal drift`.
  **Branch is over the documented 300 push threshold; still do NOT push mid-PNT unless explicitly instructed.**
- active_work_unit: none after `ROADMAP-POST-12-DRIFT-SYNC` closes; `SPEC-FORMAT-TERSE.12` is closed/exhausted.
- next_action: no current PNT-eligible leaf remains in the active frontier. `SPEC-FORMAT-TERSE.10` and `.13` stay
  deferred/backlog, `DOCTRINE-ENFORCEMENT-ADOPT.3` stays deferred, and `SPEC-LANG-REFERENCE` stays paused unless
  explicitly activated by the director.
- latest_bootstrap_read: 2026-07-08 read README, memory architecture, session bootstrap, task-tree index/active
  trees, relevant ADR/KM facts, ROADMAP/ROADMAP_V2, mdBook status/helper/backend/dev chapters, core Perl/Rust
  implementation, shipped specs, tooling, and focused test harness inventory.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first. A future doctrine
  tracking update may be opened only after this repo is clean.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests (e.g. 102 pplugin lazy-load) fail on the stale checkout. Full phase0 needs the **10-min timeout** (`timeout:600000`), else it caps mid-run (exit 144/143). **Generated Perl handlers are NON-strict.** **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`). Current phase0 reaches **PASS `1..1027`**. oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL; **96** fixtures → **run in background**; `manifest.json` + drift guards). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Rust numbered capture helpers are captures-only (`0`=first capture); whole match = `entry_text()`/`match_text()`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Remaining open deferred/paused lanes: `SPEC-FORMAT-TERSE` `.10`/`.13`,
  `DOCTRINE-ENFORCEMENT-ADOPT.3`, and `SPEC-LANG-REFERENCE`.
- blockers: none. in_flight_uncommitted: none once this pointer commit lands; do not pivot unless the repo is
  handoff-ready.

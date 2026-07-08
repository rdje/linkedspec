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
- latest_completed_leaf: `SPEC-FORMAT-TERSE.13.1` — array-tree traversal accepted and split before parser/runtime
  code; frontier moves to `.13.2` for the Perl reference implementation.
- prior_leaf: `SPEC-FORMAT-TERSE.10.1` — dynamic/computed direct hash-literal keys ratified as the current
  `{ key_expr : value_expr }` contract; no parser/runtime behavior changed and `.10` is closed.
- latest_commit: HEAD containing this pointer should be
  `SPEC-FORMAT-TERSE.13.1 - split array-tree traversal`; parent before this slice is
  `a10b8c40 SPEC-FORMAT-TERSE.10.1 - ratify dynamic hash-literal keys`.
- push_policy: check `git status -sb` for the live ahead count; do not push mid-PNT unless explicitly instructed
  or the documented 300-commit threshold policy is deliberately invoked.
- active_work_unit: `SPEC-FORMAT-TERSE.13.2` — Perl reference implementation for array-tree traversal receiver
  blocks.
- next_action: implement Perl `array_value.walk_leaves() { ... }`, `.map_leaves() { ... }`, and
  `.reduce_leaves(initial) { ... }` on array-valued receivers per `.13.1`, while preserving existing `.12`
  hash-tree behavior. `DOCTRINE-ENFORCEMENT-ADOPT.3` stays deferred, and `SPEC-LANG-REFERENCE` stays paused unless
  explicitly activated by the director.
- latest_bootstrap_read: 2026-07-08 read README, memory architecture, session bootstrap, task-tree index/active
  trees, relevant ADR/KM facts, ROADMAP/ROADMAP_V2, mdBook status/helper/backend/dev chapters, core Perl/Rust
  implementation, shipped specs, tooling, and focused test harness inventory.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first. A future doctrine
  tracking update may be opened only after this repo is clean.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests (e.g. 102 pplugin lazy-load) fail on the stale checkout. Full phase0 needs the **10-min timeout** (`timeout:600000`), else it caps mid-run (exit 144/143). **Generated Perl handlers are NON-strict.** **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`). Current phase0 reaches **PASS `1..1027`**. oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL; **96** fixtures → **run in background**; `manifest.json` + drift guards). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Rust numbered capture helpers are captures-only (`0`=first capture); whole match = `entry_text()`/`match_text()`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Remaining open deferred/paused lanes outside the current
  `SPEC-FORMAT-TERSE.13` implementation pass: `DOCTRINE-ENFORCEMENT-ADOPT.3` and `SPEC-LANG-REFERENCE`.
- blockers: none. in_flight_uncommitted: none once this pointer commit lands; do not pivot unless the repo is
  handoff-ready.

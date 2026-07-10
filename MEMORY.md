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
- latest_completed_leaf: `JULIA-BACKEND-PARITY.1.2` — `julia/` now has the minimal `LinkedSpecJulia` package
  scaffold: `Project.toml`, committed `Manifest.toml`, module status helpers, CLI/corpus stubs, README commands,
  and smoke tests. No parser/runtime/corpus execution semantics yet.
- prior_leaf: `JULIA-BACKEND-PARITY.1.1` — Homebrew Julia 1.12.6 matches the official current stable release, and
  `Pkg`/`Test` work with a writable depot.
- recent_context: `DART-BACKEND-PARITY.7.5` — Dart's scoped interpreter-first milestone is complete:
  99/99 corpus execution, focused Dart verification, Dart-specific CLI productization, mdBook/live-doc alignment,
  and generated-source deferral are all recorded.
- latest_commit: this resume block is prepared for commit
  `JULIA-BACKEND-PARITY.1.2 - scaffold Julia package`; previous committed HEAD is
  `0a780be3 JULIA-BACKEND-PARITY.1.1 - verify Julia toolchain preflight`.
- push_policy: check `git status -sb` for the live ahead count; do not push mid-PNT unless explicitly instructed
  or the documented 300-commit threshold policy is deliberately invoked.
- active_work_unit: `JULIA-BACKEND-PARITY`; current frontier after the current commit is `.1.3`.
- next_action: resume PNT at `JULIA-BACKEND-PARITY.1.3` to add manifest-backed corpus directory IO and drift
  detection in Julia before any `.spec` parser/runtime semantics.
  The director's single-source `foo.spec` parser+stimuli roundtrip idea is parked in `FUTURE-PARITY-BACKLOG.8.1`;
  the corrected AND/OR edge-default model is parked in `.9.1`; neither is the next backend rollout leaf.
- latest_bootstrap_read: 2026-07-10 read README, memory architecture, session bootstrap, COMMIT, task-tree index,
  completed Dart task tree, active future-backlog/Julia task context, ROADMAP/ROADMAP_V2, mdBook
  trace/runtime/status/backend-handoff chapters, relevant ADR/KM facts, Dart runtime/package/corpus/CLI source
  owners through `.7.5`, Rust staged-registry/trace references, and the completed cursor-control split.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests fail on the stale checkout. Full phase0 needs the **10-min timeout**. Current phase0 reaches **PASS `1..1028`**. Rust oracle = **99** fixtures. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Richer pplugin runtime parity remains a Rust follow-up, but `pplugin.spec`
  source format is closed.
- blockers: none. in_flight_uncommitted: none expected after the `JULIA-BACKEND-PARITY.1.2` commit; do not pivot unless the repo
  is handoff-ready.

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
- latest_completed_leaf: `DART-BACKEND-PARITY.6.2.2` — Dart now executes the starter shipped-corpus batch green:
  `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 40`
  passes after empty aggregate returns count as successful matches and marker-form if/else/endif chains execute
  as grouped branches.
- prior_leaf: `DART-BACKEND-PARITY.6.2.1` — Dart corpus execution has named/bounded selection:
  `executeCorpusFixtures(...)` accepts `caseNames`/`offset`/`limit`, and `bin/corpus_runner.dart --execute`
  reports selected fixture PASS/FAIL summaries while requiring `--case` or `--limit`.
- latest_commit: this resume block is prepared for commit
  `DART-BACKEND-PARITY.6.2.2 - close Dart starter corpus batch`; previous committed HEAD is
  `e055185e DART-BACKEND-PARITY.6.2.1 - add Dart executable corpus selection`.
- push_policy: check `git status -sb` for the live ahead count; do not push mid-PNT unless explicitly instructed
  or the documented 300-commit threshold policy is deliberately invoked.
- active_work_unit: `DART-BACKEND-PARITY`; current frontier `.6.2.3` after the current commit is clean.
- next_action: resume PNT at `DART-BACKEND-PARITY.6.2.3` for helper/control/receiver/user-function/tree traversal
  corpus fixtures. The director's single-source `foo.spec` parser+stimuli roundtrip idea is brainstorming for
  later, not a current pivot. The AND-only compact sequence / child-edge
  quantifier idea remains deferred in `BACKTRACK-SURFACE-RUST-ALIGNMENT`.
- latest_bootstrap_read: 2026-07-09 read README, memory architecture, session bootstrap, COMMIT, task-tree index,
  active Dart task tree, ROADMAP/ROADMAP_V2, mdBook trace/runtime/status/backend-handoff chapters, relevant ADR/KM
  facts, Dart runtime/package/corpus source owners through `.6.1`, Rust staged-registry/trace references, and the
  completed cursor-control split.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests fail on the stale checkout. Full phase0 needs the **10-min timeout**. Current phase0 reaches **PASS `1..1028`**. Rust oracle = **99** fixtures. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Richer pplugin runtime parity remains a Rust follow-up, but `pplugin.spec`
  source format is closed.
- blockers: none. in_flight_uncommitted: none expected after the `.6.2.2` commit; do not pivot unless the repo is
  handoff-ready.

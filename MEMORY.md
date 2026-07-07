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
- latest_completed_leaf: `SPEC-FORMAT-TERSE.9.4` — current specs, corpus inputs, generated oracle inputs, active
  tests, mdBook examples, root docs, and current Knowledge facts now prefer `{ key : value }` for direct
  hash-literal association. Remaining `=>` owners are classified, not migrated accidentally.
- prior_leaf: `SPEC-FORMAT-TERSE.9.3` — Rust parser/runtime colon hash-literal parity is complete; Perl/Rust still
  accept old hash-literal `=>` only for the migration window until `.9.5`, while blind-call edge `=>` is separate.
- latest_commit: HEAD containing this pointer should be
  `SPEC-FORMAT-TERSE.9.4 - migrate hash literals to colon`; parent before this slice is commit `853d30ac`
  (`SPEC-FORMAT-TERSE.9.3 - add Rust colon hash literals`).
  **Branch is over the documented 300 push threshold; still do NOT push mid-PNT unless explicitly instructed.**
- active_work_unit: after this `.9.4` commit is clean and `git status` is handoff-ready, the next frontier is
  `SPEC-FORMAT-TERSE.9.5` old hash-literal `=>` hard retirement.
- next_action: finish `.9.4` commit workflow, clear `git_message_brief.txt`, verify clean status, then implement
  `SPEC-FORMAT-TERSE.9.5` if continuing PNT; do not push unless explicitly instructed.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first. A future doctrine
  tracking update may be opened only after this repo is clean.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests (e.g. 102 pplugin lazy-load) fail on the stale checkout. Full phase0 needs the **10-min timeout** (`timeout:600000`), else it caps mid-run (exit 144/143). **Generated Perl handlers are NON-strict.** **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`). Current phase0 reaches **PASS `1..1023`**. oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL; **93** fixtures → **run in background**; `manifest.json` + drift guards). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Rust numbered capture helpers are captures-only (`0`=first capture); whole match = `entry_text()`/`match_text()`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Deferred lanes behind `.9`: `.10`/`.12`/`.13`/`.14` backlog;
  `ROADMAP-DRIFT-RECONCILE`, `DOCTRINE-ENFORCEMENT-ADOPT.3`, `SPEC-LANG-REFERENCE`.
- blockers: none for `.9.4` ownership. in_flight_uncommitted: none after the `.9.4` commit lands; do
  not pivot unless the repo is handoff-ready.

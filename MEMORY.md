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
- latest_completed_leaf: `SPEC-FORMAT-TERSE.8.2.2.4` — Perl phase0 helper strings are migrated or classified:
  current fixtures use `cat(...)`, `push(...)`, and `copy(...)`; retained old-helper residue is owned by scoped
  declaration compatibility, `push_nonempty(...)` semantic filtering, aggregate-copy compatibility, helper-renaming
  equivalence, canonical old-side equivalence, or current `.hash_copy()` receiver-method surface.
- prior_leaf: `SPEC-FORMAT-TERSE.8.2.2.3` (commit `2afd9231`) — generated oracle corpus helper fixture inputs were
  migrated/classified with no oracle expected-output drift.
- latest_commit: HEAD containing this pointer should be
  `SPEC-FORMAT-TERSE.8.2.2.4 - migrate Perl phase0 helper strings`; parent before this slice was
  `2afd9231`. **Branch is over the documented 300 push threshold; still do NOT push mid-PNT unless explicitly
  instructed.**
- active_work_unit: next frontier is `SPEC-FORMAT-TERSE.8.2.2.5` (active-test/corpus helper-string residue scans)
  and it may start only after this `.8.2.2.4` commit is clean and `git status` is handoff-ready.
- next_action: after this `.8.2.2.4` commit is clean, pick `SPEC-FORMAT-TERSE.8.2.2.5`; do not push unless
  explicitly instructed.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first. A future doctrine
  tracking update may be opened only after this repo is clean.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests (e.g. 102 pplugin lazy-load) fail on the stale checkout. Full phase0 needs the **10-min timeout** (`timeout:600000`), else it caps mid-run (exit 144/143). **Generated Perl handlers are NON-strict.** **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`). Current phase0 reaches **PASS `1..1022`**. oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL; **93** fixtures → **run in background**; `manifest.json` + drift guards). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Rust numbered capture helpers are captures-only (`0`=first capture); whole match = `entry_text()`/`match_text()`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Deferred lanes behind `.8.2`: `.9` (hash `=>`→`:`),
  `.10`/`.12`/`.13`/`.14` backlog; `ROADMAP-DRIFT-RECONCILE`, `DOCTRINE-ENFORCEMENT-ADOPT.3`,
  `SPEC-LANG-REFERENCE`.
- blockers: none for `.8.2.2.5` ownership. in_flight_uncommitted: none after the `.8.2.2.4` commit lands; do
  not pivot unless the repo is handoff-ready.

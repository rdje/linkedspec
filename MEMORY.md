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
- latest_completed_leaf: `SPEC-FORMAT-TERSE.15.2.3` (Rust bare-read parity + switch case-label alignment) — Rust
  statement/attached switch and inline lazy `switch(...)` now keep bare `case(foo)` labels literal while `switch(kind)`,
  `num_lt(n,5)`, and `if(c,...)` read scalar variables. Perl inline `switch(..., case(foo,...))` was aligned to the
  same literal-label rule after the oracle exposed a divergence. `specs/spec.spec` now initializes `paragraphs` /
  `current` with explicit `array(...)` targets so aggregate `push(...)` mutations work under `.11` duck-typed
  assignment. Rust oracle corpus PASS over **93** fixtures; full phase0 reaches `ok 1022` with **1021 pass** and only
  known baseline `not ok 796`.
- latest_commit: pending this slice commit (`SPEC-FORMAT-TERSE.15.2.3 - align Rust bare-read switch parity`);
  previous `3153f9c8` (`.15.2.2`). **~306 commits ahead of origin — OVER the documented 300 push threshold
  (LIVE_ACHIEVEMENT_STATUS); still do NOT push mid-PNT unless explicitly instructed.**
- active_work_unit: next frontier is `SPEC-FORMAT-TERSE.15.2.4` (source/corpus/docs/KM migration from `:name` to bare,
  now output-preserving). Do **not** start it until the `.15.2.3` commit is complete and the repo is handoff-ready.
- next_action: Complete `.15.2.3` commit workflow: run mdBook/KM/memory/doctrine gates, commit only owned files with
  the `.15.2.3` leaf id, clear `git_message_brief.txt`, verify status leaves only pre-existing noise. Then, and only
  then, PNT may pick `.15.2.4`.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first. A future doctrine
  tracking update may be opened only after this repo is clean.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests (e.g. 102 pplugin lazy-load) fail on the stale checkout. Full phase0 needs the **10-min timeout** (`timeout:600000`), else it caps mid-run (exit 144/143). **Generated Perl handlers are NON-strict.** **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`). Baseline phase0 = **1021 pass / 1 pre-existing unrelated fail** (test 796 `emit_context_lowers_split_tagged_records_helper`). oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL; ~90 fixtures → **run in background**; `manifest.json` + drift guards). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Rust numbered capture helpers are captures-only (`0`=first capture); whole match = `entry_text()`/`match_text()`.
- noise / deferred: `rgx` (submodule pointer) + `.claude/projects/` are untracked local noise — keep UNSTAGED. `docs/tasks/TRACE-OBSERVABILITY.md` stale-commit-hash edit is unowned noise (not this slice). Deferred lanes behind `.15`: `.8` (legacy-helper removal), `.9` (hash `=>`→`:`), `.10`/`.12`/`.13`/`.14` backlog; `ROADMAP-DRIFT-RECONCILE`, `DOCTRINE-ENFORCEMENT-ADOPT.3`, `SPEC-LANG-REFERENCE`.
- blockers: none for ownership. in_flight_uncommitted: `.15.2.3` closeout is dirty until committed; do not pivot.

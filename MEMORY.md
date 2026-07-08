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
- latest_completed_leaf: `SPEC-LANG-REFERENCE.10.5.18` — reverified
  `portmap-spec-walkthrough.md` output-shape examples against the Perl reference; the current page
  already matches the live nested JSON for bare, bit, slice, constant, and concatenation cases.
- prior_leaf: `SPEC-LANG-REFERENCE.10.5.17` — fixed `tablegrep-spec-walkthrough.md`
  output drift and descriptor helper metadata.
- latest_commit: HEAD containing this pointer should be
  `SPEC-LANG-REFERENCE.10.5.18 - verify portmap walkthrough outputs`; parent before this slice is
  `SPEC-LANG-REFERENCE.10.5.17 - fix tablegrep walkthrough outputs`.
- push_policy: check `git status -sb` for the live ahead count; do not push mid-PNT unless explicitly instructed
  or the documented 300-commit threshold policy is deliberately invoked.
- active_work_unit: `SPEC-LANG-REFERENCE.10.5.19` is the next active leaf in the reactivated
  language-reference scorch.
- next_action: from a clean repo, execute `.10.5.19`: run the planned whole-book scorch closeout
  re-greps, reverify any remaining claimed I/O that the sweep surfaces, and run `mdbook build`.
- latest_bootstrap_read: 2026-07-08 read README, memory architecture, session bootstrap, task-tree index/active
  trees, relevant ADR/KM facts, ROADMAP/ROADMAP_V2, mdBook status/dev/architecture chapters, core import tree,
  enforcement scripts/hooks, shipped specs, tooling, and focused test harness inventory.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests fail on the stale checkout. Full phase0 needs the **10-min timeout**. Current phase0 reaches **PASS `1..1028`**. Rust oracle = **99** fixtures. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Richer pplugin runtime parity remains a Rust follow-up, but `pplugin.spec`
  source format is closed.
- blockers: none. in_flight_uncommitted: none once this pointer commit lands; do not pivot unless the repo is
  handoff-ready.

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
- latest_completed_leaf: `DART-BACKEND-PARITY.6.2.4.6` — bounded Dart structural matchers and action-edge
  `push(child, index)` parity close the seven PCRE structural fixtures; shipped-spec/parser-smoke is 31/31 green.
- prior_leaf: `DART-BACKEND-PARITY.6.2.4.5` — final no-drift closeout confirmed the non-PCRE residual group was
  closed at the 24/31 boundary before the structural regex slice.
- latest_commit: this resume block is prepared for commit
  `DART-BACKEND-PARITY.6.2.4.6 - close Dart structural regex smoke`; previous committed HEAD is
  `0291ba89 DART-BACKEND-PARITY.6.2.4.5 - close parser smoke no drift`.
- push_policy: check `git status -sb` for the live ahead count; do not push mid-PNT unless explicitly instructed
  or the documented 300-commit threshold policy is deliberately invoked.
- active_work_unit: `DART-BACKEND-PARITY`; current frontier `.6.2.5` after the current commit is clean.
- next_action: resume PNT at `DART-BACKEND-PARITY.6.2.5` for top-level `fn` corpus fixtures:
  `terse_3_3_1_scalar_assignment_expressions`, `terse_3_3_4_assignment_expression_closure`, and
  `terse_4_3_2_user_function_runtime`. They must route through the spec-defined function shell or a documented
  staged equivalent, not a Dart raw `fn` scanner. The director's single-source `foo.spec` parser+stimuli
  roundtrip idea is parked in `FUTURE-PARITY-BACKLOG.8.1`; the corrected AND/OR edge-default model is parked in
  `.9.1`; neither is a current pivot.
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
- blockers: none. in_flight_uncommitted: none expected after the `DART-BACKEND-PARITY.6.2.4.6` commit; do not pivot unless the repo
  is handoff-ready.

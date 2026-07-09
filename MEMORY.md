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
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.0` — director's corrected AND/OR edge-default model is captured
  as parked design leaf `.9.1`; no parser/runtime behavior changed.
- prior_leaf: `DART-BACKEND-PARITY.6.2.4.4.4` — Dart `push(Child)` now appends child results to the current rule
  accumulator, so `regdef_nested_register_fields` passes and the parser-smoke window is 23/31 green.
- latest_commit: this resume block is prepared for commit
  `FUTURE-PARITY-BACKLOG.9.0 - capture AND OR edge default correction`; previous committed HEAD is
  `09ee1f2f DART-BACKEND-PARITY.6.2.4.4.4 - close Dart legacy accumulator smoke`.
- push_policy: check `git status -sb` for the live ahead count; do not push mid-PNT unless explicitly instructed
  or the documented 300-commit threshold policy is deliberately invoked.
- active_work_unit: `DART-BACKEND-PARITY`; current frontier `.6.2.4.4.5` after the current commit is clean.
- next_action: resume PNT at `DART-BACKEND-PARITY.6.2.4.4.5` for residual parser-smoke closeout, starting with
  `ds_vhistory_version_entry`'s `cur_object[1]` direct-access/oracle mismatch. `.6.2.4.6` owns deeper PCRE
  structural regex constructs including
  Lispish `(?R)`, EBNF `\K`/`(?&name)`/`(?(DEFINE)...)`, and spec.spec recursive block regexes. `.6.2.5` owns the
  routed top-level `fn` corpus-shell gap. The director's single-source `foo.spec` parser+stimuli roundtrip idea is
  parked in `FUTURE-PARITY-BACKLOG.8.1`; the corrected AND/OR edge-default model is parked in `.9.1`; neither is
  a current pivot.
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
- blockers: none. in_flight_uncommitted: none expected after the `FUTURE-PARITY-BACKLOG.9.0` commit; do not pivot unless the repo
  is handoff-ready.

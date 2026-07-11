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
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.1.6.4.4` — added Julia native named/file resolution.
- prior_leaf: `FUTURE-PARITY-BACKLOG.1.6.4.3` — added Dart native named/file resolution.
- recent_context: Public Julia progressive resolver/loader/compiler consumes 14/9/4 exact cases, preserves strict
  UTF-8/source identity, returns typed structured exceptions, builds an attributed engine, and owns CLI name/file
  work without recursive fallback. Package 1,110 assertions, 61x2 CLI, and 105 corpus pass; census 56/1/3.
- latest_commit: this resume block is prepared for commit
  `FUTURE-PARITY-BACKLOG.1.6.4.4 - add Julia native spec resolution`; previous committed HEAD is
  `a529e5bd FUTURE-PARITY-BACKLOG.1.6.4.3 - add Dart native spec resolution`.
- push_policy: check `git status -sb` for the live ahead count; do not push mid-PNT unless explicitly instructed
  or the documented 300-commit threshold policy is deliberately invoked.
- active_work_unit: `FUTURE-PARITY-BACKLOG`; `.1.6.4.5` exact native-resolution admission is active.
- next_action: audit Perl direct-library coverage against the shared fixture, add only the missing exact proof or
  compatibility adapter required for all four backends, run recurring native/CLI gates, close `.1.6.4`, and advance
  to Dart full-pipeline trace `.1.6.5`.
  The director's single-source `foo.spec` parser+stimuli roundtrip idea is parked in
  `FUTURE-PARITY-BACKLOG.8.1`;
  the corrected AND/OR edge-default model is parked in `.9.1`; semantic introspection/MCP is parked in `.10.1`;
  generic final-codeblock equivalence and `with` disposition are parked in `.11.1`;
  none is the next backend rollout leaf.
- latest_bootstrap_read: 2026-07-10 read the full roadmap and roadmap-v2, full codebase inventory and active Julia source/tests,
  full mdBook source, README/memory architecture/session bootstrap/COMMIT/task-tree doctrine, active
  Julia tree, relevant ADR/KM/toolbox facts, Dart matching/interpreter source/tests/task evidence, lifecycle/retv
  contract, Rust/Perl cursor/capture references, and final nested-value assignment contract before implementing
  `.4.1` through `.6.1`, Dart staged registry/runtime/descriptor/corpus reference facts, and the portable staged registry contract;
  Dart diagnostics/trace split and implementation facts, and the portable trace
  capability contract, canonical statement-separator fact, Julia depot-aware cleanup boundary, history public-
  parser leading-trivia fact, the director's native in-memory multi-backend rationale, four-backend CLI source/
  target audit, public Rust source-emitter export, ADR `0023` exact interface/capability contract, and Julia
  primary CLI argument/loading/execution/canonical JSON/failures/trace, nine direct process families, the precise
  `runtime-corpus-primary-cli` status, the 1,020/99 proof, and the current Perl/Rust/Dart/Julia narrow trailing-block
  implementations versus the director's four-kind generic final-codeblock model.
- pivot_guard: User directive 2026-07-06 — never pivot to another task-tree or new task-tree while the repo is dirty
  or not handoff-ready. Even if the user asks, finish/commit/clean the current owned leaf first.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests fail on the stale checkout. Full phase0 needs the **10-min timeout**. Current phase0 reaches **PASS `1..1030`**. Rust oracle = **105** fixtures. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- noise / deferred: `.claude/projects/` is intentionally ignored; `rgx` remains a tracked submodule with dirty
  worktree ignored by submodule policy. Richer pplugin runtime parity remains a Rust follow-up, but `pplugin.spec`
  source format is closed.
- blockers: none. in_flight_uncommitted: none after this commit; generated Rust/Dart/Julia caches are absent after cleanup.

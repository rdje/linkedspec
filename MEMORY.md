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
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5` — exhaustive current capability admission.
- prior_leaf: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3` — Julia closed governed capture/mark semantics.
- recent_context: the final current ActionIR inventory is 239 names. Strict coverage checks inventory → mdBook/
  neutral source and neutral current Perl-contract calls → Dart/Julia inventories. Six governed semantic families
  are now mandatory, raising the exact cross-backend corpus to 105. Rust, Dart, Julia, and full Perl/local gates
  pass; the census is 51 pass / one partial / eight gap.
- latest_commit: this resume block is prepared for commit
  `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 - admit exhaustive capability corpus`; previous committed HEAD is
  `0fe63298 FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3 - complete Julia capture marks`.
- push_policy: check `git status -sb` for the live ahead count; do not push mid-PNT unless explicitly instructed
  or the documented 300-commit threshold policy is deliberately invoked.
- active_work_unit: `FUTURE-PARITY-BACKLOG`; `.1.6.2` outward Rust descriptor parity is active.
- next_action: audit the canonical outward compiled-descriptor contract and Rust's public/internal `CompiledSpec`
  seam, then split/implement the smallest roadmap-aligned descriptor projection leaf.
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

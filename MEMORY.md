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
- latest_commit: `<this commit>` — `SPEC-FORMAT-TERSE.1.1.1 — Perl auto-existing working variables (engine + book + 3 phase0 locks)` (hash backfills on the next slice). Prior: `07c82d4` (`ROADMAP-DRIFT-RECONCILE.0`). Ahead of origin ~43 — push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — `.1.1.1` **DONE** 2026-06-24 (Perl auto-existing variables: collector `RuleIR::EmitContext::_collect_auto_working_var_decls`, injection in `SpecEntry::compile_spec_entry`; 19/20 specs byte-identical, tkgui +1 legit `my` behavior-preserved; +3 phase0 locks → **968 green**; gate EXIT 0; book taught). In a **PNT loop** (user 2026-06-23): commit per leaf, keep picking until exhausted or paused. Frontier → `.1.1.2`.
- next_action: **PNT → implement `SPEC-FORMAT-TERSE.1.1.2`** (Rust lockstep parity for auto-existing variables; ADR 0006/0007 — `.1.1.1` is not "landed against the universal contract" until this closes). First **assess blocked-vs-doable**: the non-recursive auto-exist specs (the `.1.1.1` locks) should be reproducible on the Rust backend independent of the known recursive-grammar `RUST-PARITY` gap. Mirror the Perl design — the Rust runtime auto-supplies the same per-invocation working-var binding when a `.spec` references a working var via a typed wrapper with no declare. Accept: Rust reproduces `.1.1.1`'s behavior on the same minimal specs (auto-exist works; declare-form unchanged), Rust suite green, cross-check/oracle parity. If the Rust working-var model blocks this independent of `RUST-PARITY`, record the blocker; else implement. Then `.1.2` (remove wrappers + type inference), `.1.4` (helper renames).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict** (`SpecEntry.pm` has no `use strict`). Rust workspace at `rust/`. phase0 baseline = **968 green**; run phase0 FOREGROUND (`timeout 600000`; background OK via run_in_background). `LinkedSpec::Get` takes **flat** option pairs, not a hashref.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3`, `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit.

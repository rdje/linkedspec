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
- latest_commit: `PENDING` — `SPEC-FORMAT-TERSE.1.3.4 — split operator syntax family into scalar, array, and hash leaves` slice is in commit workflow. Prior committed slice: `d89838f` (`SPEC-FORMAT-TERSE.1.3.3`; handoff commit `d97c571`). Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — **`.1.3.4` SPLIT/COMMIT PENDING 2026-06-29** (operator syntax family). KM + TOOLBOX recon shows `name = value`, `items += value`, and `name["k"] = value` are RAW_PERL blockers on Perl and unsupported by Rust's expression-statement-only lifecycle AST. `.1.3.4` is now a container: `.1.3.4.1` scalar assignment, `.1.3.4.2` array append, `.1.3.4.3` hash-index assignment. No engine/book behavior change. User in a **PNT loop** (2026-06-23).
- next_action: **`SPEC-FORMAT-TERSE.1.3.4.1`** — implement scalar assignment operator `name = value` equivalent to `set(name,value)` / `assign(name,value)`; start with focused Perl/Rust parser probes and avoid claiming Channel 2 bare value reads.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs`. phase0 baseline = **976 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: `.1.3.4` split docs/KM/live-doc changes are ready to commit after doctrine/KM checks; handoff commit must replace this pending pointer with the real split hash.

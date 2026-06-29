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
- latest_commit: `pending .1.3 split commit` — previous HEAD `fa47603` handoff for `SPEC-FORMAT-TERSE.1.4.2` (slice commit `0117029`). Ahead of origin ~58; push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — **`.1.3` SPLIT/DOCS-KM DONE pending commit** (mutation surface). TOOLBOX-first probes show `.1.3` is too broad: `set(name,val)` already lands via `.1.4`; `push_value(name,val)` works but requested `push(name,val)` collides with child-call `push(Rule[,target[,index]])`; `set_key(name,k,v)` is pure hash-valued expression today, not standalone mutation; operator forms are raw/new syntax. `.1.3.1` scalar function-form audit is DONE by `.1.4` evidence; `.1.3.2` array function spelling is next; `.1.3.3` hash mutation and `.1.3.4` operators are later. User in a **PNT loop** (2026-06-23).
- next_action: **`SPEC-FORMAT-TERSE.1.3.2`** — decide/implement array mutation function spelling without breaking the existing child-call `push(...)` convention; no code change before `.1.3.2` scoping/acceptance is task-tree-owned.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs`. phase0 baseline = **975 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: `.1.3` split docs/KM/live-doc commit in progress; backfill this hash in `MEMORY.md` after commit.

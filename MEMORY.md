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
- latest_commit: `pending this slice` — `SPEC-FORMAT-TERSE.1.4.2 — Rust recognize terse helper renames (engine + oracle + integration locks)`. Prior git HEAD: `f0fe686` handoff for `.1.4.1`; prior slice commit: `223723d` `.1.4.1`. After the slice commit lands, make the standard handoff commit that backfills the new hash into this line. Ahead of origin ~56; push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — **`.1.4.2` DONE 2026-06-29** (Rust lockstep parity for `.1.4.1`). `Engine::call_helper()` recognizes `"assign" | "set"`, `"concat" | "cat"`, and a dedicated unified `"copy"` arm; `resolve_hash_target` + one-bare-variable `hash`/`h` references align `copy(h(m))` with `hash_copy(h(m))` without broadening Channel 2 bare value-position reads. Locks: 2 Perl-oracle fixtures (`terse_1_4_2_*`) + 3 integration tests; full runtime suite PASS (116 unit + 11 oracle fixtures + 36 integration); clippy zero-new (existing 13-warning baseline); phase0 **975 green**; full gate EXIT 0. **`.1.4` container done; `.1.4.1` is landed against the universal contract on both variants.** `.1.2` remains active for Channel 2 later. User in a **PNT loop** (2026-06-23).
- next_action: **`SPEC-FORMAT-TERSE.1.3`** — mutation surface (`name = val`/`set(name,val)`, `name += val`/`push(name,val)`, `name[k] = v`/`set_key(name,k,v)`). First action is TOOLBOX-first scoping and likely split before code; no code change until the leaf is owned/split with precise acceptance.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs`. phase0 baseline = **975 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: this slice commit only; after commit, backfill its hash in the standard handoff commit.

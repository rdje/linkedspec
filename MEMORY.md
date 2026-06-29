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
- latest_commit: `f347f52` — `SPEC-FORMAT-TERSE.1.2.3.3.1 — implement scalar source-slot bare reads`. Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — **`.1.2.3.3.2` DONE 2026-06-29; frontier -> `.1.2.3.3.3`**. Perl scalar mutation-slot bare reads landed for `items += VALUE`, `set_key(meta, KEY, VALUE)`, and `meta[KEY] = VALUE`; direct path atoms are next. User in a **PNT loop** (2026-06-23).
- next_action: Pick **`SPEC-FORMAT-TERSE.1.2.3.3.3`** — Perl scalar bare reads for direct-access bare path atoms (`foo["a"][z]`) after the key-vs-index rule is made explicit, while preserving source/mutation bare-read behavior and `push(A,B)` child-call routing.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy source baseline runtime 13 warnings; oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs` (**25 fixtures after `.1.2.3.2`**). phase0 baseline = **986 green after `.1.2.3.3.2`**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none; known unrelated untracked paths `rgx` and `.claude/projects/` must remain unstaged.

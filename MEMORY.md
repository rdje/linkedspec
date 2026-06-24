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
- latest_commit: `<pending-this-commit>` — `SPEC-FORMAT-TERSE.1.2.2 — Rust lockstep parity for arg-position bare working-variable auto-existence (engine + oracle + 4 integration locks)`. Prior: `b77510a` `.1.2.1`, `a5208e1` `.1.2 split`. Ahead of origin ~51 — push threshold ~300; do NOT push mid-PNT. (Hash backfilled by the follow-up handoff commit, per repo pattern.)
- active_work_unit: `SPEC-FORMAT-TERSE` — `.1.2.2` **DONE** 2026-06-24 (Rust parity for `.1.2.1`). **Channel 1 (arg-position bare working-var auto-existence) now complete on BOTH variants.** Unlike `.1.1.2`, `.1.2.2` REQUIRED a Rust engine change: `resolve_scalar_target`/`resolve_array_target` (`rust/linkedspec-runtime/src/engine.rs`) now map a bare `Expr::Variable` target to the working-var name (mirroring Perl's `^\w+$` fallback), scoped via an `allow_bare` flag (push_value/push_nonempty true; value-reads array_copy/hash_copy false = Channel 2); the per-parse HashMap auto-vivifies it. Probe: bare `[null]`/`[[]]` → `["ok"]`/`[["a","b"]]` (= wrapped = Perl reference). 2 oracle fixtures (`autoexist_{scalar,array}_bare_arg`) + 4 `terse_1_2_2_*` tests → **cargo 248→252 green**; clippy zero-new; phase0 971 (Perl untouched); gate EXIT 0; no book change (variant-agnostic). `.1.2` stays **active** — Channel 2 (`.1.2.3`+: value-position bare-word reads + RHS-shape) pending, added once `.1.5` is designed. User in a **PNT loop** (2026-06-23), single-leaf cadence this session. Frontier → `.1.4`.
- next_action: **`.1.4`** (helper renames `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy` — both spellings lower identically; old names kept as deprecated aliases during migration, gradual ADR 0007; +phase0 locks; book teach; then Rust parity). `.1.3` (mutation operators `=`/`+=`/`name[k]=v`) + Channel 2 (`.1.2.3`+, needs `.1.5` literal design) also pending. **Context is long after the `.1.2.1`+`.1.2.2` pair — a FRESH SESSION is recommended for `.1.4`** (repo is handoff-ready; bootstrap, dump-don't-guess).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict** (`SpecEntry.pm` has no `use strict`). **Rust = interpreter** at `rust/` (no codegen/eval; working vars in `RuntimeContext` HashMaps auto-vivify; fresh ctx per `execute`); cargo baseline **252 green**, clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` (Perl) → `corpus_oracle.rs`. phase0 baseline = **971 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity — owns the deferred recursive/REP auto-exist idiom too), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit.

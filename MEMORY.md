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
- latest_commit: `<pending-this-commit>` — `SPEC-FORMAT-TERSE.1.2.1 — Perl arg-position bare working-variable auto-existence (Channel 1; engine + book + 3 phase0 locks)`. Prior: `a5208e1` `.1.2 split`, `c3cd50d` `.1.1.2`. Ahead of origin ~49 — push threshold ~300; do NOT push mid-PNT. (Hash backfilled by the follow-up handoff commit, per repo pattern.)
- active_work_unit: `SPEC-FORMAT-TERSE` — `.1.2.1` **DONE** 2026-06-24 (Perl Channel 1: bare arg-position auto-existence). Extended the `.1.1.1` collector `RuleIR::EmitContext::_collect_auto_working_var_decls` with a bare arg-position pass (shared `$record` dedup): `assign(NAME,…)`→`my $NAME` (scalar — assign lowers scalar-first), `push_value`/`push_nonempty(NAME,…)`→`my @NAME`; the `\s*,` guard keeps WRAPPED targets on the `.1.1.1` wrapped path (no double-collection). All 20 specs **byte-identical (0 diff)**; +3 phase0 subtests/17 asserts → **971 green**; gate EXIT 0; ratio 1.0000; book taught (3 pages, variant-agnostic). **Scope (signoff):** Channel 1 = unambiguous first-arg value-helper positions only; child-append `push(Rule[,target])`/`.push(target)` target (rule-name first arg — ambiguous) + bare hash (value-position read) = Channel 2 (deferred, evidence in tree Decisions + KM [[terse-bare-working-vars-engine-gaps]]). User is in a **PNT loop** (2026-06-23) but chose **single-leaf PNT** this turn (implement `.1.2.1`, then stop & report). Frontier → `.1.2.2`.
- next_action: **`.1.2.2`** (Rust lockstep parity for `.1.2.1`, ADR 0006) — likely holds by architecture (the interpreter's per-parse `RuntimeContext` HashMaps auto-vivify working vars regardless of wrapper/bare/`declare`); assess blocked-vs-doable, lock with `autoexist_*`-style oracle fixtures + integration tests (mirror `.1.1.2`). **Per the user's single-leaf-PNT choice this turn, AWAIT a go-signal before starting `.1.2.2`** (or the next PNT pick). Read `rust/linkedspec-runtime/src/{runtime,engine}.rs` + `tools/gen_oracle_corpus.pl`, dump-don't-guess.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict** (`SpecEntry.pm` has no `use strict`). **Rust = interpreter** at `rust/` (no codegen/eval; working vars in `RuntimeContext` HashMaps auto-vivify; fresh ctx per `execute`); cargo baseline **248 green**, clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` (Perl) → `corpus_oracle.rs`. phase0 baseline = **971 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity — owns the deferred recursive/REP auto-exist idiom too), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit.

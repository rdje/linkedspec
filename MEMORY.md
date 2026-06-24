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
- latest_commit: this slice = `SPEC-FORMAT-TERSE.1.2 — split into .1.2.1 (Perl, Channel 1) + .1.2.2 (Rust parity); record bare-working-var ground truth + KM card` (exact hash via `git log -1`; prior `c3cd50d` `.1.1.2`, `55c9b2f` `.1.1.1`). Ahead of origin ~46 — push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — `.1.2` **SPLIT** 2026-06-24 (DOCS/TREE/KM only, no engine/book change). TOOLBOX `dump_parser_source` ground truth (KM [[terse-bare-working-vars-engine-gaps]]): a **bare** (un-wrapped) working var has two inference channels — (1) **arg position** already lowers to the right sigil'd var (`assign(count,v)`→`$count=v`; `push_value(items,..)`→`push @items`) BUT gets **no auto-`my`** (the `.1.1.1` collector matches only WRAPPED forms) → leaky package global; (2) **value position** is NOT a var read (`return(count)`→ bareword `return count ;`, not `$count`) + RHS-shape. Split Perl-first by channel: `.1.2.1` (Perl, Channel 1: arg-position auto-existence) + `.1.2.2` (Rust parity); Channel 2 (`.1.2.3`+) added once `.1.2.1` lands + `.1.5` designed. In a **PNT loop** (user 2026-06-23): commit per leaf, keep picking until exhausted/paused. Frontier → `.1.2.1`.
- next_action: **PNT → implement `SPEC-FORMAT-TERSE.1.2.1`** (Perl reference, Channel 1: a bare working var in a type-implying helper arg position — scalar LHS of `assign`/`set`; array target of `push`/`push_value`; hash key-set — auto-exists as a per-invocation `my` with the position-implied sigil, closing the leaky-global gap; extend the `.1.1.1` collector `RuleIR::EmitContext::_collect_auto_working_var_decls` + the sigil source. Keep wrapped/declare specs byte-identical (dedup vs `@<label>` + lowered `my`); ratio 1.0000; +phase0 locks (bare arg-position scalar+array auto-exist + cross-parse no-leak); book teach; then `.1.2.2` Rust parity). **`.1.2.1` is signoff-critical Perl codegen — a FRESH SESSION is reasonable**; bootstrap, read `RuleIR/EmitContext.pm` (collector) + `ActionIR/{ValueExpr,MethodLowering}.pm` + `SpecEntry.pm` preamble, dump-don't-guess.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict** (`SpecEntry.pm` has no `use strict`). **Rust = interpreter** at `rust/` (no codegen/eval; working vars in `RuntimeContext` HashMaps auto-vivify; fresh ctx per `execute`); cargo baseline **248 green**, clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` (Perl) → `corpus_oracle.rs`. phase0 baseline = **968 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity — owns the deferred recursive/REP auto-exist idiom too), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit.

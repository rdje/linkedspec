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
- latest_commit: `55c9b2f` — `SPEC-FORMAT-TERSE.1.1.1` (Perl auto-existing vars). **`.1.1.2` (Rust parity) is being committed now** — its hash backfills here in a follow-up handoff commit. Prior: `c36652c` (`.1.1.1` handoff). Ahead of origin ~44 — push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — `.1.1.2` **DONE** 2026-06-24 (Rust lockstep parity for auto-existing variables; **NO engine change** — the Rust interpreter's per-parse `RuntimeContext` HashMaps auto-vivify working vars + fresh ctx per `execute`, so auto-existence is inherent; no Perl-style leaky-global hazard. Locked: 5 `autoexist_*` oracle fixtures (`tools/gen_oracle_corpus.pl` → `corpus_oracle.rs`, Rust==Perl ref) + 4 `terse_1_1_2_*` integration tests; **cargo 244→248 green**, 7/7 oracle PASS, clippy zero-new, **phase0 968 green** (Perl untouched), gate EXIT 0). **`.1.1` container DONE; `.1.1.1` now landed against the universal contract.** In a **PNT loop** (user 2026-06-23): commit per leaf, keep picking until exhausted/paused. Frontier → `.1.2`.
- next_action: **PNT → implement `SPEC-FORMAT-TERSE.1.2`** (remove `scalar()/array()/hash()` wrappers + add type inference: RHS shape `[]`→array/`{}`→hash/scalar + helper arg position; old wrapper forms aliased during migration per ADR 0007). This is a Perl-reference engine+grammar change (bootstrap-grammar + ActionIR lowering) with a follow-on Rust parity obligation (ADR 0006) — likely split into `.1.2.1` (Perl) + `.1.2.2` (Rust) like `.1.1` was. Then `.1.4` (helper renames `assign`→`set`, `concat`→`cat`, `*_copy`→`copy`), `.1.3`/`.1.5`/`.1.6`. **`.1.2` is signoff-critical Perl codegen — a FRESH SESSION is reasonable**; bootstrap, read `BootstrapSpec/Core.pm` + `ActionIR/*`, dump-don't-guess.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict** (`SpecEntry.pm` has no `use strict`). **Rust = interpreter** at `rust/` (no codegen/eval; working vars in `RuntimeContext` HashMaps auto-vivify; fresh ctx per `execute`); cargo baseline **248 green**, clippy source baseline engine.rs 11 / helpers.rs 2; oracle = `tools/gen_oracle_corpus.pl` (Perl) → `corpus_oracle.rs`. phase0 baseline = **968 green**; run phase0 FOREGROUND (`timeout 600000`). `LinkedSpec::Get` takes **flat** option pairs.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity — owns the deferred recursive/REP auto-exist idiom too), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit.

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
- latest_commit: `<this commit>` — `ROADMAP-DRIFT-RECONCILE.0 — create tree to own deferred ROADMAP.md/ARCHITECTURE_STATE.md drift (tracking-only)` (hash backfills on the next slice). Prior substantive: `2b7cbd5` (`SPEC-FORMAT-TERSE.1.1` split). Ahead of origin ~42 — push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` → frontier leaf `.1.1.1` (`pending` — Perl auto-existing working variables). In a **PNT loop** (user 2026-06-23): start at `.1.1.1`, commit per leaf, keep picking until exhausted or paused.
- next_action: **implement `SPEC-FORMAT-TERSE.1.1.1`** (Perl auto-existing variables) per the recorded design (tree Decisions + KM [[working-vars-no-strict-need-my-lexical]]). A **rule-level** pass collects typed-wrapper var refs `scalar(NAME)`/`array(NAME)`/`hash(NAME)` (+ `s/a/h`; single bare-identifier arg ONLY — NOT the 2-arg `scalar(container,key)` read) across all of a rule's blocks → inject one `my $NAME`/`@NAME`/`%NAME` in the handler **PREAMBLE** (sigil FROM wrapper, no inference = `.1.2`; dedup vs `@<label>` accumulator + explicit declares; NOT inline-per-edge). Seams: collect in `RuleIR::EmitContext::build_rule_ir_emit_context`; inject in `SpecEntry::compile_spec_entry`→`_build_handler_preamble`. Accept: no-declare path works; declare path byte-identical generated source; ratio 1.0000; phase0 stays green (965)+new locks; gate EXIT 0; book updated (declare optional). **TOOLBOX-first** — re-ground exact seams/lines via `dump_parser_source` + `tools/inspect_spec_codegen.pl` BEFORE editing (the agent line numbers are illustrative). Then `.1.1.2` (Rust parity, follow-on).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated handlers are NON-strict** (`SpecEntry.pm` has no `use strict`) → a no-`declare` working var is a leaky package global. Recursion seam: Perl `…{$rule}{handler}` closure. phase0 baseline = **965 green**; run phase0 FOREGROUND (`timeout 600000`; background killed ~120s).
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — created today, parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3`, `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit.

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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.2.2.2 — split cluster B1 into .2.2.2.1 (return_array) + .2.2.2.2 (return_a/return_m)` (hash backfilled next; ahead of origin ~19 — push threshold ~300; do NOT push mid-PNT). Prior: `b691c02` (.2.2.1).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; `.3`+`.4` engine fixes DONE (ADR `0008`); `.2.1`/`.2.2.1` DONE; `.2.2`/`.2.2.2` SPLIT. **`.2.2.2` SPLIT 2026-06-21** (recon + verified helper-mapping archaeology — decomposition slice, no test change).
- **`.2.2.2` (B1 = 21) split → `.2.2.2.1` + `.2.2.2.2`:** 17 use `return_array` (incl. 2 BOTH @17289/@20105); 4 use `return_a`/`return_m` (incl. 3rd BOTH `method_like_action_chain…` + `blind_call_fluent…`). Verified canonical rewrites (KM [[retired-return-helpers-canonical-rewrite]]): `return_array(L,e1,e2)`=pure alias → `return(array(e1,e2))` (drop L, quote barewords; expected usually already canonical → input-rewrite); `return_a(L)`→`return(array("?L:", array_copy(array(L))))`; `return_m(L)`→`return(array("?L:", entry_groups()))` (re-dump + re-bless).
- next_action: **`.2.2.2.1`** — rewrite the 17 `return_array(L, …)` direct-`call_spec_handler_subst` assertions to `return(array(…))` (drop L, quote barewords), verify each against the engine (expected usually unchanged), full-suite `comm` set-diff. Then `.2.2.2.2` (4 accumulator, re-dump + judgment), `.2.3` (C `emit_context` ×20), `.2.4` (F=3+G=2), `.5` green-phase0 (+ corpus tail = missing `plugin/` dir, rmdir'd by NONCORE-QUARANTINE), `.6` book `:AND`.
- phase0 now **47 failing** = 20 `method_like` (B1+BOTH, `.2.2.2`) + 20 `emit_context` (`.2.3`) + 7 other (`.2.4`/`.5`, incl. `corpus_regression` tail). `comm` set-diff is the reliable proof. NOTE: `parser_invalid_input_fails_at_runtime_parser_boundary` (a `Lispish` `open3` subprocess test) is CPU-contention **flaky** — a clean re-run passes (`ok 137`); not a regression source.
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c -Iperl t/phase0_regression.t` OK; phase0 = 47 fail after `.2.2.1` (set-diff ×2 runs = exactly 55 cleared, 0 regressions).
- blockers: (1) phase0 not yet green — 46 STALE re-bless (`.2.2.2`/`.2.3`/`.2.4`, TEST-ONLY) + corpus tail (`.5`); gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `RTLUtils`/`VHDL::ConstantEval` retired/gone) — docs-only refresh pending.

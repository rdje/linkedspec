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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.2.2.2.2 — re-bless cluster B1-accumulator (4 return_a/return_m, TEST-ONLY); 4 cleared` (hash backfilled next; ahead of origin ~23 — push threshold ~300; do NOT push mid-PNT). Prior: `6b9288c` (.2.2.2.1).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; `.3`+`.4` engine fixes DONE (ADR `0008`); `.2.1`/`.2.2.1`/`.2.2.2.1`/`.2.2.2.2` DONE; `.2.2`/`.2.2.2` SPLIT→both children done (cluster B1 fully re-blessed). Frontier → **`.2.3`**.
- **`.2.2.2.2` DONE (TEST-ONLY, closes cluster B1):** 4 `return_a`/`return_m` subtests → `.return_a().return_m()`=`.return(1).return(array("?Top:", entry_groups()))` (×3 fluent, replace_all), block `return_m(Top)`→`return(array("?Top:", entry_groups()))` (×2, line-scoped — @39745 is a passing non-target, EXCLUDED), blind-call `.return_a()`→`.return(1)` (@6342), subtest-1 `RETURN_A`/`RETURN_M` greps → `grep RETURN`+`is(hits{RETURN},2)` (distinct-variant feature retired into one RETURN). Pre-flight probe replicated EVERY assertion of all 4 subtests → all PASS before editing.
- next_action: **`.2.3`** — Cluster C `emit_context` ×20 (white-box). **Delete/rewrite** (prefer over re-bless) the seams that monkeypatch the removed `LinkedSpec::Deps::*` (traps can't fire); fix the stale `plan 89`→88; re-bless `return_imatch`/`return_array` passthrough + the `a(IMATCH)`⇒`[IMATCH]` case. The `return_imatch(Top, semantic_annotation)` site is at L12436. Then `.2.4` (F=3 migration-summary `return(1)` resolved-not-blocked + G=2 `return(1)` AST scalar), `.5` green-phase0 (+ corpus tail), `.6` book `:AND`.
- phase0 now **26 failing** = 20 `emit_context` (`.2.3`) + 5 (F=3+G=2, `.2.4`) + 1 `corpus_regression` tail (`.5`). `comm` name set-diff on a **complete** TAP is the reliable proof. NOTE: a full gate run is SIGALRM-killed (exit 144) when external CPU load >~30 (e.g. an unrelated `cargo`/`rustc` build) exceeds the 10-min runner cap — a truncated TAP gives a FALSE "cleared" set; re-run at low load to the natural exit-255 corpus stop. `parser_invalid_input…` `open3` test is a separate CPU-contention flake.
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c -Iperl t/phase0_regression.t` OK; `perl -c perl/LinkedSpec.pm` OK; phase0 = 26 fail after `.2.2.2.2` (complete-TAP `comm` set-diff = exactly the 4 cleared, 0 regressions).
- blockers: (1) phase0 not yet green — 25 STALE re-bless (`.2.3`/`.2.4`, TEST-ONLY) + corpus tail (`.5`); gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `RTLUtils`/`VHDL::ConstantEval` retired/gone) — docs-only refresh pending.

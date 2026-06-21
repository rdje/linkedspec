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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.2.3 — re-bless/rewrite cluster C emit_context (20, TEST-ONLY); 20 cleared` (hash backfilled next; ahead of origin ~24 — push threshold ~300; do NOT push mid-PNT). Prior: `50d0308` (.2.2.2.2).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; `.3`+`.4` engine fixes DONE (ADR `0008`); `.2.1`/`.2.2.*`/`.2.3` DONE (clusters A, B, C re-blessed). Frontier → **`.2.4`**.
- **`.2.3` DONE (TEST-ONLY, cluster C):** 20 `emit_context` white-box subtests. Root: `return(1)`→plain `return 1` (resolved; node `RETURN`, contract `return_general`, ready) + retired `return_a`/`return_imatch`/`return_array` (passthrough). Changes: deps-builder `return ['?Top:', \@Top]`/`RETURN_A`→`return 1`/`RETURN`; facade passthrough re-bless; `a(IMATCH)`→`[IMATCH]`; 2 plan off-by-ones (89→88, 80→79); dropped removed `_lower_return_array_statement` probe (plan 8→6); `_find_unresolved_action_helpers` input `return(1)`→`return_a(1)`; `_parse_method_function_expr('return(1)')` args `'Top'`→`'1'`; descriptor-meta `RETURN_A`→`RETURN`, with 5 meta-tests' specs RESTORED to expr-bearing returns (`return(Top, $x + 1)`/`return(do { my $x = 1; $x })`/`return(Leaf, $x)`) to keep coverage. Kept harmless dead `LinkedSpec::Deps::*` traps (Deps-unloaded covered by `emit_context_require_avoids_linkedspec_deps_load`); deferred consistent dead-trap sweep of all 13 deps siblings.
- next_action: **`.2.4`** — cluster F ×3 (`return_descriptor_exposes_action_rewriter_migration_summary`/`…_blocker_type_breakdown` + `compatibility_surface_metadata_includes_legacy_helper_wrappers`: re-bless `return(1)` as resolved-not-blocked; Unresolved rule now ready) + G STALE ×2 (`bootstrap_registry_curly_brace_recursion_smoke`, `get_avoids_runtime_run_get_from_args_wrapper`: `return(1)` AST = scalar `1`). Then `.5` green-phase0 (+ corpus tail) + gate flips, `.6` book `:AND`.
- phase0 now **6 failing** = 5 F/G (`.2.4`) + 1 `corpus_regression` tail (`.5`).
- VERIFY-UNDER-LOAD: a full gate run is SIGALRM-killed (exit 144) at the corpus tail when external CPU load >~20 (e.g. an unrelated `cargo`/`rustc` build) — a truncated TAP gives a FALSE "cleared" set, so **check the reach (last `ok N`) before trusting `comm`**; re-run at low load to the natural corpus stop. To verify late subtests under load, extract those `subtest {…}` blocks (brace-balanced) and run them in a focused Test::More harness (load-independent).
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c -Iperl t/phase0_regression.t` OK; `perl -c perl/LinkedSpec.pm` OK; phase0 = 6 fail after `.2.3` (focused harness 9/9 for late subtests + low-load full `comm` set-diff = exactly the 20 cleared, 0 regressions).
- blockers: (1) phase0 not yet green — 5 STALE re-bless (`.2.4`, TEST-ONLY) + corpus tail (`.5`); gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `RTLUtils`/`VHDL::ConstantEval` retired/gone) — docs-only refresh pending.

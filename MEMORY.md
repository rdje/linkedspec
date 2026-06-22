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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.2.4 — re-bless cluster F+G (5, TEST-ONLY); 5 cleared (cluster .2 complete)` (hash backfilled next; ahead of origin ~25 — push threshold ~300; do NOT push mid-PNT). Prior: `9ab8c56` (.2.3).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; `.3`+`.4` engine fixes DONE (ADR `0008`); `.2.1`/`.2.2.*`/`.2.3`/`.2.4` DONE → **cluster `.2` COMPLETE** (all 108 STALE re-blessed). Frontier → **`.5`**.
- **`.2.4` DONE (TEST-ONLY, closes cluster `.2`):** 5 F/G. G×2 (`bootstrap_registry_curly_brace_recursion_smoke`, `get_avoids_runtime_run_get_from_args_wrapper`): `return(1)`→plain `return 1` ⇒ single-top-rule parser returns scalar `1`, re-blessed `ok(ref $ast eq 'ARRAY')`→`is($ast,1)`. F×3 (migration-summary corpora): the `return(1)` rules used to be unresolved-blocked → **restored** to genuinely-unresolved `return(Leaf, $x)` (mixed = `+ my $tmp = 2`) so original aggregates/coverage hold (2 spec + 1 payload edit, 0 other assert changes); `compatibility_surface_…legacy_helper_wrappers` obsolete-premise (`return_m`/`return_a` retired→RAW_PERL, not ready compat) **adapted** to live compat helpers (`Top`→`return(a("?Top:"))` keeping `assign_call_my`+`capture_if`; `Leaf`→bare `return 1`=`return_bare`).
- next_action: **`.5`** — green-phase0 verification + downstream gate flips. phase0 is now **1 "failing" = ONLY the `corpus_regression` natural-stop tail (subtest 941, exit-255)**; subtests 1–940 all green. Determine whether subtest-941 "No tests run for corpus_regression" is the intended natural-stop boundary or a real corpus gap; then flip the gates: `SPEC-FORMAT-TERSE`, `LEGACY-VHDL-RETIRE.4/.5`, `NONCORE-QUARANTINE.V`. Then `.6` book `:AND` reconciliation.
- phase0 now **1 failing** = `corpus_regression` natural-stop tail (`.5`); subtests 1–940 all green.
- VERIFY-UNDER-LOAD: a full gate run is SIGALRM-killed (exit 144) at the corpus tail when external CPU load >~20 (e.g. an unrelated `cargo`/`rustc` build) — a truncated TAP gives a FALSE "cleared" set, so **check the reach (last `ok N`) before trusting `comm`**; re-run at low load to the natural exit-255 corpus stop. To verify late subtests under load, extract those `subtest {…}` blocks (brace-balanced) and run them in a focused Test::More harness (load-independent).
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c -Iperl t/phase0_regression.t` OK; `perl -c perl/LinkedSpec.pm` OK; phase0 = 1 fail (corpus tail only) after `.2.4` (focused harness 5/5 + gold-standard full run reached the exit-255 corpus stop with 0 failures excl corpus; `comm` set-diff = exactly the 5 F/G cleared, 0 regressions).
- blockers: (1) phase0 front 940 GREEN; only the `corpus_regression` natural-stop tail remains (`.5` — confirm natural-stop vs real, then flip gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `RTLUtils`/`VHDL::ConstantEval` retired/gone) — docs-only refresh pending.

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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.2.1 — re-bless cluster A (7 parser-collection-shape, TEST-ONLY)` (hash backfilled next; ahead of origin ~16 — push threshold ~300; do NOT push mid-PNT). Prior: `b26a5c4` (.4 input-boundary).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; `.3`+`.4` engine fixes DONE (ADR `0008` — sanctioned scoped exception; engine-frozen doctrine otherwise STANDS). **`.2.1` DONE 2026-06-21 — cluster A re-bless (7, TEST-ONLY).**
- **`.2.1` (cluster A re-bless):** 13 `is_deeply` expecteds in `t/phase0_regression.t` only — retired auto-tag `['?Rule:',[]]` → current child-return `[1,1]` / scalar `1` / `[[1,1],…]` (dumped real engine output first). Subtests 144/149/152/153/156/163/166. **Cluster A = 7, not triaged 8**: the 8th (`blind_call_fluent_post_call_chain` 206) is a retired-`return_a` failure → cluster B (`.2.2`). 109 → 102 failing; `comm` full set-diff = exactly the 7, 0 regressions. Engine untouched.
- next_action: **`.2.2`** — re-bless cluster B `method_like` ×76 (retired `return_a/return_m/return_ma/return_imatch/return_im/return_array` helpers + `RETURN_A/RETURN_M` nodes; **includes re-bucketed subtest 206**). Then `.2.3` (C `emit_context` ×20 white-box — incl. delete/rewrite the removed-`Deps::*` monkeypatch seams), `.2.4` (F=3 + G=2). Then `.5` green-phase0 (+ `corpus_regression` subtest-941 tail = missing `plugin/` dir, rmdir'd by NONCORE-QUARANTINE) + downstream gate flips. Then `.6` book `:AND` reconciliation (may need a user policy check).
- phase0 now **102 failing** = 101 STALE (`.2.2`–`.2.4`) + 1 `corpus_regression` tail (`.5`). Baseline+after TAP `/tmp/phase0_pnt.tap` + `/tmp/phase0_after_2_1.snapshot.tap` (transient). NOTE: external `bin/fsmgen --quiet` (another session) at ~99% CPU SIGALRM-kills the gate at the corpus tail — runs still reach subtest 941; the `comm` set-diff is the reliable proof.
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c -Iperl t/phase0_regression.t` OK; phase0 = 102 fail (deterministic) after `.2.1`.
- blockers: (1) phase0 not yet green — 101 STALE re-bless (`.2.2`–`.2.4`, TEST-ONLY) + corpus tail (`.5`); gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `RTLUtils`/`VHDL::ConstantEval` retired/gone) — docs-only refresh pending.

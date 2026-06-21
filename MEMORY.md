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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.4 — engine fix: input-boundary-validation regression (#2)` (hash backfilled next; ahead of origin ~15 — push threshold ~300; do NOT push mid-PNT). Prior: `a410d93` (.3 AND-codegen).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; **`.3`+`.4` DONE 2026-06-21 — BOTH reference-engine defects fixed.** User **authorized BOTH engine fixes** 2026-06-21 (ADR `0008` — sanctioned scoped exception to the engine-frozen doctrine; the doctrine otherwise STANDS for any other `perl/` touch).
- **`.3` (Defect #1 — AND action-codegen):** `HandlerVariantEmitter.pm` — both AND-acode emitters rewrote an edge `return(...)` via `s/\breturn.../\$" . …/eg` where bare `\$"` = ref to `$"` (→ `SCALAR(0x…)`); now emit edge acodes **verbatim** (raw author payload; correct in direct-AND + `sub{}`-wrapped REP-AND). KM [[and-return-edge-codegen-defect]] → resolved.
- **`.4` (Defect #2 — input-boundary):** `Runtime.pm` — gated the `pos($$input_ref)=0`/comment-skip behind `if (ref($input_ref) eq 'SCALAR')` + always delegate to `$original_parser` so the documented inner guard (`Compiler.pm:1109`) fires → friendly error + populated `last_error`. KM [[runtime-input-boundary-validation-regression]] → resolved.
- next_action: **`.2.1`** — re-bless cluster A (8, TEST-ONLY, lowest risk): `or_plus_blind_call`/`explicit_and`/`blind_call_*`/`and_plus`/`bounded_and` expect the retired auto-tag `['?Rule:',[]]`; engine correctly returns `[1,1]` (each child's `return(1)`). Re-bless the expectations in `t/phase0_regression.t` only. Then `.2.2` (B `method_like` ×75), `.2.3` (C `emit_context` ×20 white-box), `.2.4` (F+G). Then `.5` green-phase0 (+ `corpus_regression` subtest-941 "No tests run" tail) + downstream gate flips. Then `.6` book `:AND` reconciliation (may need a user policy check: document `::AND`+regex as supported vs steer to the 2-rule idiom).
- phase0 now **109 failing** = 108 STALE (`.2.x`) + 1 `corpus_regression` tail (`.5`). Run reached subtest 941 (> prior 880); EXIT=255 on the corpus tail. TAP `/tmp/phase0_after_d4.tap` (transient).
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c perl/LinkedSpec.pm` + `HandlerVariantEmitter.pm` OK; phase0 = 111 fail (deterministic) after `.3`.
- blockers: (1) phase0 not yet green — 108 STALE re-bless (`.2.x`, TEST-ONLY) + Defect #2 (`.4`) + corpus tail (`.5`); gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `VHDL::ConstantEval` gone) — docs-only refresh pending.

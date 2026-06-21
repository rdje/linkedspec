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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.3 — engine fix: AND-rule action-codegen defect (#1)` (hash backfilled next; ahead of origin ~14 — push threshold ~300; do NOT push mid-PNT). Prior: `f3c8a9b`/`3a6d25b` (.1 triage).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). `.1` triage DONE; **`.3` DONE 2026-06-21**. User **authorized BOTH engine fixes** 2026-06-21 (ADR `0008` — sanctioned scoped exception to the engine-frozen doctrine; the doctrine otherwise STANDS for any other `perl/` touch).
- **`.3` landed (Defect #1 — AND-rule action-codegen):** fixed `perl/LinkedSpec/HandlerVariantEmitter.pm` — both AND-acode emitters (`_emit_and_acode_seq_handler` + `_emit_and_single_acode_handler`) rewrote an edge `return(...)` via `s/\breturn.../\$" . $label . " = "/eg` where bare `\$"` = a *ref to* `$"` (→ `SCALAR(0x…)`); now emit edge acodes **verbatim** (already lowered to `return [...]`, surfaces raw author payload; correct in direct-AND and `sub{}`-wrapped REP-AND). Full phase0 **173 → 111 failing (62 cleared, 0 regressions)**; all cluster-D capture/mark + named-G AND tests pass. KM card [[and-return-edge-codegen-defect]] → `resolved`.
- next_action: **`.4`** — fix Defect #2 (input-boundary). In `perl/LinkedSpec/Runtime.pm` the comment-skip wrapper (`~line 126`) runs `pos($$input_ref)=0` BEFORE the SCALAR-ref guard; gate that block behind `if (ref($input_ref) eq 'SCALAR') { ... }` and always `return $original_parser->($input_ref)` so the documented inner guard (`Compiler.pm:1109`, `ref ne 'SCALAR'`) fires → friendly error + populated `last_error`. Re-confirmed objectively 2026-06-21 (`Not a SCALAR reference at … Runtime.pm line 126`, empty `last_error`). Unblocks 2 subtests (`parser_invalid_input_fails_at_runtime_parser_boundary`, `get_parser_runtime_ctx_ref_records_invalid_input_ref_with_spec_identity`). See [[runtime-input-boundary-validation-regression]]. Then `.2.x` re-bless the 108 STALE (TEST-ONLY), then `.5` green-phase0 (+ the `corpus_regression` subtest-941 "No tests run" tail). A `.6` book leaf reconciles the `:AND` docs (the now-fixed `::AND`+regex+return form vs the book's "Body rule only"/"no regex on top" idiom statements).
- remaining 111 phase0 failures = 108 STALE (`.2.x`) + 2 Defect #2 (`.4`) + 1 `corpus_regression` tail (`.5`). Run reached subtest 941 (further than the prior 880); EXIT=255 on the corpus tail. TAP `/tmp/phase0_after_d3.tap` (transient).
- TRACE-OBSERVABILITY (active): discoverable CLI trace control + "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works). `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED.
- verify: `perl -c perl/LinkedSpec.pm` + `HandlerVariantEmitter.pm` OK; phase0 = 111 fail (deterministic) after `.3`.
- blockers: (1) phase0 not yet green — 108 STALE re-bless (`.2.x`, TEST-ONLY) + Defect #2 (`.4`) + corpus tail (`.5`); gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`). (3) `ARCHITECTURE_STATE.md` lines 288–302 stale (domain owners moved to `noncore/`; `VHDL::ConstantEval` gone) — docs-only refresh pending.
